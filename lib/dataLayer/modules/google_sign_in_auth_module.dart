import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_repository.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  loading,
  authenticateError,
  authenticateErrorUserNotExist,
  authenticateErrorUserAlreadyExists,
  authenticateCanceled,
}

class GoogleSignInAuthModule extends BaseAuthenticationModule {
  GoogleSignInAuthModule(store) : super(store, GoogleSignInRepository(store: store));
}
