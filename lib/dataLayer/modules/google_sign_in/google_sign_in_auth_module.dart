import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/unique_event.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_repository.dart';

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

class GoogleSignInAuthModule extends BaseAuthenticationModule {
  GoogleSignInAuthModule(store) : super(store, GoogleSignInRepository(store: store));
}
