import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';

abstract class BaseAuthenticationRepository {

  final Store store;

  BaseAuthenticationRepository({required this.store});

  CommonUser? getUser();

  bool get isAnonymous => getUser() == null;

  bool get isLoggedIn => getUser() != null ? true : false;

  Future<AuthEvent> signUp();

  Future<AuthEvent> logIn();

  @protected
  Future<AuthEvent> resolveLogIn(DocumentSnapshot<Object?> documentSnapshot) {
    CommonUser userChat = CommonUser.fromDocument(documentSnapshot);

    // Write data to local
    store.put(AppConstants.kUserDB, userChat.toJson());

    final authEvent = AuthEvent(status: AuthStatus.authenticated);
    return Future.value(authEvent);
  }

  Future<void> logOut();
}
