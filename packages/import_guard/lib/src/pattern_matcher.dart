import 'package:path/path.dart' as p;

/// Matches import URIs against deny patterns.
class PatternMatcher {
  const PatternMatcher({
    required this.configDir,
    required this.packageRoot,
    required this.packageName,
  });

  final String configDir;
  final String packageRoot;
  final String? packageName;

  /// Check if an import URI matches a deny pattern.
  bool matches({
    required String importUri,
    required String pattern,
    required String filePath,
  }) {
    if (pattern.startsWith('./') || pattern.startsWith('../')) {
      return _matchesRelativePattern(
        importUri: importUri,
        pattern: pattern,
        filePath: filePath,
      );
    }
    return matchesAbsolutePattern(importUri, pattern);
  }

  bool _matchesRelativePattern({
    required String importUri,
    required String pattern,
    required String filePath,
  }) {
    final resolvedPatternPath = p.normalize(p.join(configDir, pattern));

    if (importUri.startsWith('.')) {
      final fileDir = p.dirname(filePath);
      final resolvedImportPath = p.normalize(p.join(fileDir, importUri));
      return pathMatchesPattern(resolvedImportPath, resolvedPatternPath);
    }

    if (packageName != null && importUri.startsWith('package:$packageName/')) {
      final importPath = importUri.substring('package:$packageName/'.length);
      final absoluteImportPath = p.join(packageRoot, 'lib', importPath);
      return pathMatchesPattern(absoluteImportPath, resolvedPatternPath);
    }

    return false;
  }

  /// Match a file path against a pattern with glob support.
  /// Exposed for testing.
  static bool pathMatchesPattern(String path, String pattern) {
    String patternBase = pattern;
    bool matchChildren = false;
    bool matchAll = false;

    if (pattern.endsWith('/**')) {
      patternBase = pattern.substring(0, pattern.length - 3);
      matchAll = true;
    } else if (pattern.endsWith('/*')) {
      patternBase = pattern.substring(0, pattern.length - 2);
      matchChildren = true;
    }

    patternBase = p.normalize(patternBase);

    if (matchAll) {
      return path.startsWith(patternBase);
    }

    if (matchChildren) {
      if (!path.startsWith('$patternBase${p.separator}')) return false;
      final remainder = path.substring(patternBase.length + 1);
      return !remainder.contains(p.separator);
    }

    return path == patternBase || path.startsWith('$patternBase${p.separator}');
  }

  /// Match an import URI against an absolute pattern (package:, dart:).
  /// Exposed for testing.
  static bool matchesAbsolutePattern(String importUri, String pattern) {
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

    return importUri == pattern || importUri.startsWith('$pattern/');
  }
}
