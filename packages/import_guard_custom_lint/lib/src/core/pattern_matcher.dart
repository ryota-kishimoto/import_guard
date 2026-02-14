import 'package:path/path.dart' as p;

/// Utility class for matching import patterns.
class PatternMatcher {
  /// Directory path where the config file is located.
  final String configDir;

  /// Name of the Dart package, used for resolving package: imports.
  final String? packageName;

  /// Root directory of the Dart package.
  final String? packageRoot;

  /// Pre-computed package prefix for faster matching.
  late final String? _packagePrefix;

  /// Cache for normalized pattern paths.
  final _normalizedPatternCache = <String, String>{};

  /// Creates a [PatternMatcher] for the given config directory and package.
  PatternMatcher({
    required this.configDir,
    this.packageName,
    this.packageRoot,
  }) {
    _packagePrefix = packageName != null ? 'package:$packageName/' : null;
  }

  /// Check if an import matches a pattern.
  bool matches({
    required String importUri,
    required String pattern,
    required String filePath,
  }) {
    // Handle absolute patterns (package:, dart:)
    if (pattern.startsWith('package:') || pattern.startsWith('dart:')) {
      return matchesAbsolutePattern(importUri, pattern);
    }

    // Handle relative patterns (./, ../)
    if (pattern.startsWith('./') || pattern.startsWith('../')) {
      return _matchesRelativePattern(importUri, pattern, filePath);
    }

    return false;
  }

  /// Match absolute patterns like package:foo/bar or dart:mirrors.
  static bool matchesAbsolutePattern(String importUri, String pattern) {
    // Handle ** glob (all descendants)
    if (pattern.endsWith('/**')) {
      final prefix = pattern.substring(0, pattern.length - 3);
      return importUri.startsWith(prefix) && importUri.length > prefix.length;
    }

    // Handle * glob (direct children only)
    if (pattern.endsWith('/*')) {
      final prefix = pattern.substring(0, pattern.length - 2);
      if (!importUri.startsWith(prefix)) return false;
      final rest = importUri.substring(prefix.length);
      // Should have exactly one path segment after prefix
      return rest.startsWith('/') && !rest.substring(1).contains('/');
    }

    // Exact match or prefix match
    return importUri == pattern || importUri.startsWith('$pattern/');
  }

  /// Match relative patterns like ./foo or ../bar.
  bool _matchesRelativePattern(
    String importUri,
    String pattern,
    String filePath,
  ) {
    // Get cached normalized pattern path, or compute and cache it
    var absolutePatternPath = _normalizedPatternCache[pattern];
    if (absolutePatternPath == null) {
      absolutePatternPath = p.normalize(p.join(configDir, pattern));
      _normalizedPatternCache[pattern] = absolutePatternPath;
    }

    // Convert import URI to absolute path
    final absoluteImportPath = _resolveImportPath(importUri, filePath);
    if (absoluteImportPath == null) return false;

    return pathMatchesPattern(absoluteImportPath, absolutePatternPath);
  }

  /// Resolve import URI to absolute file path.
  String? _resolveImportPath(String importUri, String filePath) {
    if (importUri.startsWith('package:')) {
      return _packageImportToPath(importUri);
    }

    if (importUri.startsWith('./') ||
        importUri.startsWith('../') ||
        !importUri.contains(':')) {
      return p.normalize(p.join(p.dirname(filePath), importUri));
    }

    return null;
  }

  /// Convert package: import to absolute file path.
  String? _packageImportToPath(String importUri) {
    final prefix = _packagePrefix;
    final root = packageRoot;
    if (prefix == null || root == null || !importUri.startsWith(prefix)) {
      return null;
    }

    final relativePath = importUri.substring(prefix.length);
    return p.join(root, 'lib', relativePath);
  }

  /// Check if a file path matches a pattern path.
  static bool pathMatchesPattern(String filePath, String patternPath) {
    // Handle ** glob
    if (patternPath.endsWith('/**')) {
      final prefix = patternPath.substring(0, patternPath.length - 3);
      return filePath.startsWith(prefix);
    }

    // Handle * glob
    if (patternPath.endsWith('/*')) {
      final prefix = patternPath.substring(0, patternPath.length - 2);
      if (!filePath.startsWith(prefix)) return false;
      final rest = filePath.substring(prefix.length);
      // Should have exactly one path segment after prefix
      return rest.startsWith('/') && !rest.substring(1).contains('/');
    }

    // Exact match or prefix match
    return filePath == patternPath || filePath.startsWith('$patternPath/');
  }
}
