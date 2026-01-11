# import_guard

analysis_server_plugin based implementation for import guarding.

## Architecture

```
lib/
├── main.dart                     # Entry point (plugin getter)
└── src/
    ├── import_guard_rule.dart    # AnalysisRule implementation
    └── core/
        ├── config.dart           # YAML config loading & caching
        ├── pattern_matcher.dart  # Glob pattern matching
        └── pattern_trie.dart     # Trie for O(n) pattern lookup
```

## Key Design Decisions

### Caching Strategy

- `ConfigCache`: Singleton that scans all `import_guard.yaml` files once per repo
- `_matcherCache`: Static cache for PatternMatcher instances
- Performance: 10,000 calls in ~13ms

### Pattern Matching

- Absolute patterns (`package:`, `dart:`) use Trie for O(path_length) matching
- Relative patterns (`./`, `../`) require context-aware resolution

## Development

### Run tests

```bash
dart test
```

### Test in IDE

Use example/ directory or link from another project:

```yaml
# In test project's pubspec.yaml
dev_dependencies:
  import_guard:
    path: /path/to/import_guard/packages/import_guard
```

Then add to `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - import_guard
```

### Run CLI

```bash
dart analyze
# or
flutter analyze
```

## Version Compatibility

See [doc/version_compatibility.md](doc/version_compatibility.md) for details.

**TL;DR**: Requires Dart 3.9+ with `analysis_server_plugin`.

## Common Issues

### IDE not showing warnings

1. Check Dart version (must be 3.9+)
2. Restart Dart Analysis Server
3. Check `analysis_options.yaml` has `import_guard` in plugins

### Plugin not loading

`analysis_server_plugin` requires Dart 3.9+. For older Dart versions, use [import_guard_custom_lint](../import_guard_custom_lint/) instead.

## Related

- [import_guard_custom_lint](../import_guard_custom_lint/) - custom_lint version (Dart 3.6+)
- Shared core logic is in `src/core/` (synced between packages)
