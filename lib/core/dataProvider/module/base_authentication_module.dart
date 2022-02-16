import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/common_user.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

class BaseAuthenticationModule<T extends BaseAuthenticationRepository> extends Cubit<AuthEvent> {
  final T repository;
  final Store store;

  BaseAuthenticationModule(this.store, this.repository) : super(AuthEvent());

  CommonUser? get user => repository.getUser();

  bool get isLoggedIn => repository.isLoggedIn;

  bool get isAbleToAutoLogin => false;

  Future<AuthEvent> signUp() async {
    emit(AuthEvent(status: AuthStatus.loading));
    return repository.signUp();
  }

  Future<AuthEvent> logIn() async {
    emit(AuthEvent(status: AuthStatus.loading));
    return repository.logIn();
  }

  Future<void> logOut() async => repository.logOut();
}
