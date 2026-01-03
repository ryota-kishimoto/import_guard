// This file demonstrates import_guard in action.
// Some imports below should trigger lint errors.

// OK - allowed imports
import 'dart:async';
import 'dart:convert';

// NG - should be flagged by import_guard
import 'dart:mirrors'; // deny: dart:mirrors

// If you had these packages, they would be flagged:
// import 'package:http/http.dart'; // deny: package:http
// import 'package:domain/repository/user_repository.dart'; // deny: package:domain/repository/**

void main() {
  print('import_guard example');
}
