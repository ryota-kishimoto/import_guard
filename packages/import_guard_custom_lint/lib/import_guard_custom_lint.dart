import 'package:analyzer/error/error.dart' show ErrorSeverity;
import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/import_guard_lint.dart';

/// Entry point for custom_lint plugin.
PluginBase createPlugin() => _ImportGuardPlugin();

class _ImportGuardPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    final severity = _getSeverity(configs);
    return [ImportGuardLint(severity: severity)];
  }

  ErrorSeverity _getSeverity(CustomLintConfigs configs) {
    final rules = configs.rules;
    final config = rules['import_guard'];
    if (config == null) return ErrorSeverity.ERROR;

    final options = config.json;
    final severityStr = options['severity'] as String?;

    return switch (severityStr) {
      'warning' => ErrorSeverity.WARNING,
      'info' => ErrorSeverity.INFO,
      _ => ErrorSeverity.ERROR,
    };
  }
}
