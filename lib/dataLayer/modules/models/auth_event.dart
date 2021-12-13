import 'package:flutter/foundation.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/unique_event.dart';

enum AuthStatus {
  uninitialized,
  registered,
  authenticated,
  loading,
  authenticateError,
  authenticateErrorUserNotExist,
  authenticateErrorUserAlreadyExists,
  authenticateCanceled,
}

@immutable
class AuthEvent extends UniqueEvent {
  final AuthStatus status;
  final String message;

  AuthEvent({this.status = AuthStatus.uninitialized, this.message = "Something went wrong"});
}
