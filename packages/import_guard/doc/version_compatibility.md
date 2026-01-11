# Version Compatibility

## Requirements

| Dependency | Version |
|------------|---------|
| Dart SDK | ^3.9.0 |
| analysis_server_plugin | ^0.3.0 |
| analyzer | ^8.2.0 |

## analysis_server_plugin

This package uses `analysis_server_plugin`, which is the official Dart analyzer plugin system.

### Key differences from custom_lint

| | import_guard | import_guard_custom_lint |
|---|--------------|-------------------------|
| Plugin system | analysis_server_plugin | custom_lint |
| Min Dart version | 3.9+ | 3.6+ |
| Run command | `dart analyze` | `dart run custom_lint` |
| IDE integration | Native | Via custom_lint |

### Why analysis_server_plugin?

- Official Dart analyzer plugin system
- Native IDE integration (no additional setup)
- Works with `dart analyze` / `flutter analyze`
- Better performance in large codebases

### Trade-off

- Requires Dart 3.9+ (newer SDK requirement)
- For older Dart versions, use [import_guard_custom_lint](../../import_guard_custom_lint/)

## SDK Compatibility

| Dart SDK | Status |
|----------|--------|
| >=3.9.0 | ✅ Supported |
| 3.6.0 - 3.8.x | ❌ Use import_guard_custom_lint |
| <3.6.0 | ❌ Not supported |

## analyzer version

This package requires analyzer ^8.2.0, which is bundled with Dart 3.9+.

| Dart SDK | analyzer version |
|----------|------------------|
| 3.9.x | 8.x |
| 3.10.x | 8.x |

## Choosing the right package

| Your environment | Recommended package |
|------------------|---------------------|
| Dart 3.9+ | **import_guard** (this package) |
| Dart 3.6 - 3.8 | import_guard_custom_lint |
| Need custom_lint ecosystem | import_guard_custom_lint |

## Testing Guide

```yaml
# pubspec.yaml
dev_dependencies:
  import_guard: ^0.0.6
```

```yaml
# analysis_options.yaml
analyzer:
  plugins:
    - import_guard
```

Then:
1. `dart pub get`
2. `dart analyze`
3. Check if warnings are reported in IDE
