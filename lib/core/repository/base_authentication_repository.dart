import 'package:firebase_auth/firebase_auth.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

abstract class BaseAuthenticationRepository {
  CommonUser? getUser();

  bool isLoggedIn();

  Future<AuthStatus> signIn();

  Future<AuthStatus> logIn();

  Future<void> logOut();
}