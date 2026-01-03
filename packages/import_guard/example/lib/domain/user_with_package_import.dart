import 'package:import_guard_example/domain/entity.dart';
import 'package:import_guard_example/infrastructure/user_repository.dart';

class UserWithInfraImport extends Entity {
  final String name;
  UserWithInfraImport(this.name) : super('user-2');

  UserRepository get repository => UserRepository();
}
