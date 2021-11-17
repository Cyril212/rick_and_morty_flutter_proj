import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

abstract class BaseAuthenticationRepository {
  String? getUserId();

  Future<bool> isLoggedIn();

  Future<AuthStatus> signIn();

  Future<AuthStatus> logIn();

  Future<void> logOut();
}