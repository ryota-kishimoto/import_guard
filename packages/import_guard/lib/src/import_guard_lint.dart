import 'dart:io';

import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Configuration for import_guard loaded from import_guard.yaml
class ImportGuardConfig {
  final List<String> deny;

  ImportGuardConfig({required this.deny});

  factory ImportGuardConfig.fromYaml(YamlMap yaml) {
    final denyList = yaml['deny'] as YamlList?;
    return ImportGuardConfig(
      deny: denyList?.map((e) => e.toString()).toList() ?? [],
    );
  }

  static ImportGuardConfig? loadFromFile(String packagePath) {
    final configFile = File(p.join(packagePath, 'import_guard.yaml'));
    if (!configFile.existsSync()) return null;

    final content = configFile.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap?;
    if (yaml == null) return null;

    return ImportGuardConfig.fromYaml(yaml);
  }
}

class ImportGuardLint extends DartLintRule {
  ImportGuardLint() : super(code: _code);

  static const _code = LintCode(
    name: 'import_guard',
    problemMessage: 'This import is not allowed: {0}',
    errorSeverity: ErrorSeverity.ERROR,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Find package root by looking for pubspec.yaml
    final filePath = resolver.source.fullName;
    final packagePath = _findPackageRoot(filePath);
    if (packagePath == null) return;

    final config = ImportGuardConfig.loadFromFile(packagePath);
    if (config == null || config.deny.isEmpty) return;

    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      for (final pattern in config.deny) {
        if (_matchesPattern(importUri, pattern)) {
          reporter.atNode(
            node,
            _code,
            arguments: [importUri],
          );
          break;
        }
      }
    });
  }

  String? _findPackageRoot(String filePath) {
    var dir = Directory(p.dirname(filePath));
    while (dir.path != dir.parent.path) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir.path;
      }
      dir = dir.parent;
    }
    return null;
  }

  bool _matchesPattern(String importUri, String pattern) {
    // Handle glob-like patterns
    // package:foo/** -> matches package:foo/anything
    // package:foo/* -> matches package:foo/single_segment
    // package:foo -> exact match or prefix match

    if (pattern.endsWith('/**')) {
      final prefix = pattern.substring(0, pattern.length - 3);
      return importUri.startsWith(prefix);
    }

    if (pattern.endsWith('/*')) {
      final prefix = pattern.substring(0, pattern.length - 2);
      if (!importUri.startsWith('$prefix/')) return false;
      final remainder = importUri.substring(prefix.length + 1);
      return !remainder.contains('/');
    }

    // Exact match or prefix match (package:foo matches package:foo/bar)
    return importUri == pattern || importUri.startsWith('$pattern/');
  }
}
