import 'package:firebase_auth/firebase_auth.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/handler/firebase_auth_handler.dart';

class EmailAuthRepository extends BaseAuthenticationRepository {
  late final FirebaseAuth _firebaseAuth;
  late final FirebaseAuthHandler _authHandler;
  late EmailSignInCredentials emailSignIn;

  EmailAuthRepository({required store})
      : _firebaseAuth = FirebaseAuth.instance,
        _authHandler = FirebaseAuthHandler(store: store),
        super(store: store);

  @override
  CommonUser? getUser() {
    if (store.get(AppConstants.kUserDB) == null) {
      return null;
    }

    Map<String, dynamic> decodedUser = Map<String, dynamic>.from(store.get(AppConstants.kUserDB));
    return CommonUser.fromJson(decodedUser);
  }

  @override
  Future<AuthEvent> logIn() {
    return _authHandler.handleEmailSignInAuthentication(emailSignIn).then((authStatusHandler) {
      if (authStatusHandler.documents == null) {
        return Future.value(authStatusHandler.event);
      }

      final isAuthenticatedSuccessfully = authStatusHandler.documents!.isNotEmpty;
      if (isAuthenticatedSuccessfully) {
        return resolveLogIn(authStatusHandler.documents![0]);
      } else {
        return Future.value(authStatusHandler.event);
      }
    });
  }

  @override
  Future<void> logOut() async {
    if (isAnonymous == false) {
      await _firebaseAuth.signOut();
      store.delete(AppConstants.kUserDB);
    }
  }

  @override
  Future<AuthEvent> signUp() {
    return _authHandler.createUserWithEmailAndPassword(emailSignIn).then((firebaseAuthHandlerStatus) {
      return firebaseAuthHandlerStatus.event;
    });
  }
}
