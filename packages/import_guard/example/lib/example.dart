import 'dart:mirrors';

void main() {
  final mirror = reflectClass(Object);
  print('import_guard example: ${mirror.simpleName}');
}
