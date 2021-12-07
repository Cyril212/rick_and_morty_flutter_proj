import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

import 'base_authentication_manager.dart';

class AuthenticationManager extends BaseAuthenticationManager {
  AuthenticationManager(store) : super(store, [GoogleSignInAuthModule(store)]);

  GoogleSignInAuthModule get _googleSignInAuthModule => auths[0] as GoogleSignInAuthModule;

  bool get isAuthorized => _googleSignInAuthModule.isLoggedIn;

  void authorizeWithGoogle() {
    emit(AuthStatus.loading);
    _googleSignInAuthModule.signIn().then((state) => emit(state));
  }

  void autologinIfPossible() {
    if (isAuthorized) {
      emit(AuthStatus.loading);
      authorizeWithGoogle();
    }
  }

  void logOut() {
    for (var auth in auths) {
      auth.logOut();
    }
  }
}
