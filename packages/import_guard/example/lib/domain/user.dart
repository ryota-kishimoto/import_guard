// OK: domain layer can import within domain
import 'package:import_guard_example/domain/entity.dart';

// NG: domain layer cannot import presenter layer
// This import triggers import_guard warning
import 'package:import_guard_example/presenter/widget.dart';

class User extends Entity {
  final String name;
  User(this.name) : super('user-1');

  // This reference is intentional to demonstrate the violation
  UserWidget get widget => UserWidget();
}
