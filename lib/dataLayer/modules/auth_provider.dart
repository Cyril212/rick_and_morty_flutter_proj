import 'package:rick_and_morty_flutter_proj/core/repository/store/credentials_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/model/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';

import '../../core/dataProvider/auth/base_auth_provider.dart';
import '../../core/repository/store/common_user_store.dart';
import 'models/auth_event.dart';

class AuthProvider extends BaseAuthProvider {
  final EmailAuthModule emailSignInAuthModule;
  final GoogleSignInAuthModule googleSignInAuthModule;

  final CredentialsStore credentialsStore;

  AuthProvider(store, {required this.credentialsStore, required this.emailSignInAuthModule, required this.googleSignInAuthModule})
      : super(store, [emailSignInAuthModule, googleSignInAuthModule]);

  bool get isAuthorized => currentUser != null;

  void signInWithEmail({required EmailSignInCredentials credentials}) {
    emit(AuthEvent(status: AuthStatus.loading));
    emailSignInAuthModule.logIn(credentials: credentials).then((state) => emit(state));
  }

  void signInWithGoogle() {
    emit(AuthEvent(status: AuthStatus.loading));
    googleSignInAuthModule.signUp().then((state) => emit(state));
  }

  Future autologinIfPossible() async {
    if (isAuthorized && authType != null) {
      switch (authType!) {
        case AuthType.email:
          credentialsStore.credentials.then((credentials) => signInWithEmail(credentials: credentials!));
          break;
        case AuthType.googleSignIn:
          signInWithGoogle();
          break;
      }
    } else {
      emit(AuthEvent(status: AuthStatus.uninitialized));
    }
  }

  Future logOut() async {
    for (var auth in auths) {
      await auth.logOut();
    }
  }
}
