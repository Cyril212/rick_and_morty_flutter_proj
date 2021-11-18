import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

class BaseAuthenticationModule extends Cubit<AuthStatus> {
  final BaseAuthenticationRepository repository;
  final Store store;

  BaseAuthenticationModule(this.store, this.repository) : super(AuthStatus.uninitialized);

  CommonUser? getUser() => repository.getUser();

  bool isLoggedIn() => repository.isLoggedIn();

  Future<AuthStatus> signIn() async {
    emit(AuthStatus.loading);
    return repository.signIn();
  }

  Future<AuthStatus> logIn() async {
    emit(AuthStatus.loading);
    return repository.logIn();
  }

  Future<void> logOut() async => repository.logOut();
}
