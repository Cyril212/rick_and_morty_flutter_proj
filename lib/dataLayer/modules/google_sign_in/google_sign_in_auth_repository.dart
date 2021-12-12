import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/handler/firebase_auth_handler.dart';

class GoogleSignInRepository extends BaseAuthenticationRepository {
  late final GoogleSignIn googleSignIn;

  late final FirebaseAuth firebaseAuth;
  late final FirebaseAuthHandler firebaseAuthHandler;

  late final FirebaseFirestore firebaseFirestore;

  GoogleSignInRepository({required Store store})
      : googleSignIn = GoogleSignIn(),
        firebaseAuth = FirebaseAuth.instance,
        firebaseFirestore = FirebaseFirestore.instance,
        firebaseAuthHandler = FirebaseAuthHandler(store: store),
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
  Future<AuthEvent> signUp() async {
    return firebaseAuthHandler.handleGoogleSignInAuthentication(googleSignIn).then((authStatusHandler) {
      if (authStatusHandler.documents == null || authStatusHandler.documents!.isEmpty) {
        return Future.value(authStatusHandler.event);
      } else {
        return resolveLogIn(authStatusHandler.documents![0]);
      }
    });
  }

  @override
  Future<AuthEvent> logIn() async {
    return firebaseAuthHandler.handleGoogleSignInAuthentication(googleSignIn).then((authStatusHandler) {
      if (authStatusHandler.documents == null) {
        return Future.value(authStatusHandler.event);
      }

      if (authStatusHandler.documents!.isNotEmpty) {
        return resolveLogIn(authStatusHandler.documents![0]);
      } else {
        return Future.value(AuthEvent(status: AuthStatus.authenticateErrorUserNotExist));
      }
    });
  }

  @override
  Future<void> logOut() async {
    if (isAnonymous == false) {
      await firebaseAuth.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      store.delete(AppConstants.kUserDB);
    }
  }
}
