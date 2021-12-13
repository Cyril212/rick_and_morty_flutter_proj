import 'package:firebase_auth/firebase_auth.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/common_user.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/credentials_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/model/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/common_user_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/handler/firebase_auth_handler.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

class EmailAuthRepository extends BaseAuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseAuthHandler _authHandler;

  final CommonUserStore userStore;
  final CredentialsStore credentialsStore;

  late EmailSignInCredentials emailSignIn;

  EmailAuthRepository({required store, required userStore, required this.credentialsStore})
      : _firebaseAuth = FirebaseAuth.instance,
        userStore = CommonUserStore(store: store),
        _authHandler = FirebaseAuthHandler(commonUserStore: userStore, credentialsStore: credentialsStore),
        super(store: store);

  @override
  CommonUser? getUser() => userStore.user;

  @override
  Future<AuthEvent> signUp() {
    return _authHandler.createUserWithEmailAndPassword(emailSignIn).then((authStatusHandler) => authStatusHandler.event);
  }

  @override
  Future<AuthEvent> logIn() {
    return _authHandler.handleEmailSignInAuthentication(emailSignIn).then((authStatusHandler) => authStatusHandler.event);
  }

  @override
  Future<void> logOut() async {
    if (isAnonymous == false) {
      await _firebaseAuth.signOut();
      await credentialsStore.clear();
      userStore.clear();
    }
  }
}
