import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_authentication_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

class FirebaseAuthStatusHandler {
  final AuthStatus status;
  final List<DocumentSnapshot>? documents;
  final User? firebaseUser;

  FirebaseAuthStatusHandler({this.status = AuthStatus.uninitialized, this.documents, this.firebaseUser});
}

class GoogleSignInRepository extends BaseAuthenticationRepository {
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  final Store store;

  GoogleSignInRepository({required this.store})
      : googleSignIn = GoogleSignIn(),
        firebaseAuth = FirebaseAuth.instance,
        firebaseFirestore = FirebaseFirestore.instance;

  @override
  CommonUser? getUser() {
    if (store.get(AppConstants.kUserDB) == null) {
      return null;
    }

    Map<String, dynamic> decodedUser = Map<String, dynamic>.from(store.get(AppConstants.kUserDB));
    return CommonUser.fromJson(decodedUser);
  }

  bool get isAnonymous => getUser() == null;

  @override
  bool isLoggedIn() {
    if (getUser() != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<FirebaseAuthStatusHandler> _handleAuthentication() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await firebaseAuth.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.kPathUserCollection)
            .where(FirestoreConstants.kId, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;

        return Future.value(FirebaseAuthStatusHandler(documents: documents, firebaseUser: firebaseUser));
      } else {
        return Future.value(FirebaseAuthStatusHandler(status: AuthStatus.authenticateError));
      }
    } else {
      return Future.value(FirebaseAuthStatusHandler(status: AuthStatus.authenticateCanceled));
    }
  }

  @override
  Future<AuthStatus> signIn() async {
    return _handleAuthentication().then((authStatusHandler) {
      if (authStatusHandler.documents == null) {
        return Future.value(authStatusHandler.status);
      }

      if (authStatusHandler.documents!.isEmpty) {
        // Writing data to server because here is a new user
        User firebaseUser = authStatusHandler.firebaseUser!;
        firebaseFirestore.collection(FirestoreConstants.kPathUserCollection).doc(firebaseUser.uid).set({
          FirestoreConstants.kNickname: firebaseUser.displayName,
          FirestoreConstants.kPhotoUrl: firebaseUser.photoURL,
          FirestoreConstants.kId: firebaseUser.uid,
          FirestoreConstants.kCreatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.kChattingWith: null
        });

        // Write data to local storage
        User? currentUser = firebaseUser;

        CommonUser commonUser =
            CommonUser(id: currentUser.uid, nickname: currentUser.displayName ?? "", aboutMe: "", photoUrl: currentUser.photoURL ?? "");

        store.put(AppConstants.kUserDB, commonUser.toJson());
        return Future.value(AuthStatus.authenticated);
      } else {
        return _resolveLogIn(authStatusHandler.documents![0]);
      }
    });
  }

  @override
  Future<AuthStatus> logIn() async {
    return _handleAuthentication().then((authStatusHandler) {
      if (authStatusHandler.documents == null) {
        return Future.value(authStatusHandler.status);
      }

      if (authStatusHandler.documents!.isNotEmpty) {
        return _resolveLogIn(authStatusHandler.documents![0]);
      } else {
        return Future.value(AuthStatus.authenticateErrorUserNotExist);
      }
    });
  }

  Future<AuthStatus> _resolveLogIn(DocumentSnapshot documentSnapshot) {
    CommonUser userChat = CommonUser.fromDocument(documentSnapshot);

    // Write data to local
    store.put(AppConstants.kUserDB, userChat.toJson());

    return Future.value(AuthStatus.authenticated);
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
