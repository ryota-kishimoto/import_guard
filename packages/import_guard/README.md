# import_guard

An analyzer plugin to guard imports between folders. Enforce clean architecture layer dependencies with configurable deny rules.

> **Requires Dart 3.10+**. For older Dart versions, use [import_guard_custom_lint](https://pub.dev/packages/import_guard_custom_lint).

## Installation

```yaml
dependencies:
  import_guard: ^1.0.0
```

Enable the plugin in `analysis_options.yaml`:

```yaml
plugins:
  import_guard: ^1.0.0
```

## Usage

Create `import_guard.yaml` in any directory to define deny rules:

```yaml
# lib/domain/import_guard.yaml
deny:
  - package:my_app/infrastructure/**
  - package:my_app/presentation/**
```

Files in `lib/domain/` will now show warnings when importing from `infrastructure` or `presentation`.

## Pattern Syntax

| Pattern | Description |
|---------|-------------|
| `package:foo` | Exact match or prefix |
| `package:foo/*` | Direct children only |
| `package:foo/**` | All descendants |
| `dart:mirrors` | Dart SDK library |
| `../data/**` | Relative path patterns |

## Example

```
lib/
├── domain/
│   ├── import_guard.yaml  # deny presenter/infrastructure
│   └── user.dart          # Cannot import from presenter/
├── presenter/
│   └── user_page.dart     # Can import from domain/
└── import_guard.yaml      # deny dart:mirrors globally
```

## Related Packages

- [import_guard_custom_lint](https://pub.dev/packages/import_guard_custom_lint) - custom_lint implementation (Dart 3.6+)
- [import_guard_core](https://pub.dev/packages/import_guard_core) - Core logic
