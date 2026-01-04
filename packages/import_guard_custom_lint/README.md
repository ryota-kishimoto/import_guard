# import_guard_custom_lint

A custom_lint package to guard imports between folders. Enforce clean architecture layer dependencies with configurable deny rules.

> For Dart 3.10+, consider using [import_guard](https://pub.dev/packages/import_guard) which uses the native analyzer plugin API.

## Installation

```yaml
dev_dependencies:
  import_guard_custom_lint: ^1.0.0
  custom_lint: ^0.8.0
```

Enable custom_lint in `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## Usage

Create `import_guard.yaml` in any directory to define deny rules:

```yaml
# lib/domain/import_guard.yaml
deny:
  - package:my_app/infrastructure/**
  - package:my_app/presentation/**
```

Files in `lib/domain/` will now show errors when importing from `infrastructure` or `presentation`.

## Configuration

### Severity

Configure severity in `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    - import_guard:
      severity: warning  # error (default), warning, or info
```

### Pattern Syntax

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

- [import_guard](https://pub.dev/packages/import_guard) - Native analyzer plugin (Dart 3.10+)
- [import_guard_core](https://pub.dev/packages/import_guard_core) - Core logic
