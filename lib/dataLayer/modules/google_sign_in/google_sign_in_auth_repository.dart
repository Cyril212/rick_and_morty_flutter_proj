import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/common_user.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/common_user_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/handler/firebase_auth_handler.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

class GoogleSignInRepository extends BaseAuthenticationRepository {
  late final GoogleSignIn googleSignIn;

  final FirebaseAuth firebaseAuth;
  final FirebaseAuthHandler firebaseAuthHandler;

  final CommonUserStore userStore;

  GoogleSignInRepository({required Store store, required userStore})
      : googleSignIn = GoogleSignIn(),
        firebaseAuth = FirebaseAuth.instance,
        userStore = CommonUserStore(store: store),
        firebaseAuthHandler = FirebaseAuthHandler(commonUserStore: userStore),
        super(store: store);

  @override
  CommonUser? getUser() => userStore.user;

  @override
  Future<AuthEvent> signUp() {
    return firebaseAuthHandler.handleGoogleSignInAuthentication(googleSignIn).then((authStatusHandler) => authStatusHandler.event);
  }

  @override
  Future<void> logOut() async {
    if (isAnonymous == false) {
      await firebaseAuth.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      userStore.clear();
    }
  }

  @override
  Future<AuthEvent> logIn() => Future.value(AuthEvent(status: AuthStatus.uninitialized));
}
