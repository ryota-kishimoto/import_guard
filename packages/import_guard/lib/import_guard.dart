library import_guard;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:import_guard/src/import_guard_lint.dart';

PluginBase createPlugin() => _ImportGuardPlugin();

class _ImportGuardPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        ImportGuardLint(),
      ];
}
