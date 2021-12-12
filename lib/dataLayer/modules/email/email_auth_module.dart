import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_auth_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_sign_in_credentials.dart';

import '../google_sign_in/google_sign_in_auth_module.dart';

class EmailAuthModule extends BaseAuthenticationModule<EmailAuthRepository> {
  EmailAuthModule(Store store) : super(store, EmailAuthRepository(store: store));

  @override
  Future<AuthEvent> signUp({EmailSignInCredentials? credentials}) {
    repository.emailSignIn = credentials!;
    return super.signUp()..then((value) => emit(value));
  }

  @override
  Future<AuthEvent> logIn({EmailSignInCredentials? credentials}) {
    repository.emailSignIn = credentials!;
    return super.logIn()..then((value) => emit(value));
  }
}
