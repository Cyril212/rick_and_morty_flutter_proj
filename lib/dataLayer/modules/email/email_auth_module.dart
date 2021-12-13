import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/credentials_store.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_auth_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/model/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/common_user_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

class EmailAuthModule extends BaseAuthenticationModule<EmailAuthRepository> {
  EmailAuthModule(Store store, CredentialsStore credentialsStore)
      : super(store, EmailAuthRepository(store: store, userStore: CommonUserStore(store: store), credentialsStore: credentialsStore));

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
