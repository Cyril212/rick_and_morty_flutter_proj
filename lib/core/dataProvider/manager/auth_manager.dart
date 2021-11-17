import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

class AuthenticationManager extends Cubit<AuthStatus>{
  final Store store;

  final GoogleSignInAuthModule _googleSignInAuthModule;

  late List<AbstractAuthenticationModule> auths;

  AuthenticationManager(this.store, this._googleSignInAuthModule) : super(AuthStatus.uninitialized){
    auths = [GoogleSignInAuthModule(store)];
  }

  void authorizeWithGoogleSignIn(){
    _googleSignInAuthModule.logIn().then((state) => emit(state));
  }

  void logOut(){
    for (var auth in auths) {
      auth.logOut();
    }}
}