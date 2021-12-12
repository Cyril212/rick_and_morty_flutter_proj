import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/user_chat.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';

class FirebaseAuthHandlerStatus {
  final AuthEvent event;
  final List<DocumentSnapshot>? documents;
  final User? firebaseUser;

  FirebaseAuthHandlerStatus({event, this.documents, this.firebaseUser}) : event = event ?? AuthEvent();
}

@immutable
class FirebaseAuthHandler {
  final Store store;

  const FirebaseAuthHandler({required this.store});

  Future<FirebaseAuthHandlerStatus> createUserWithEmailAndPassword(EmailSignInCredentials emailSignIn) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailSignIn.email, password: emailSignIn.password);

      final firebaseAuthHandlerStatus = FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.registered));
      _writeUserToStore(store, firebaseAuthHandlerStatus);

      return Future.value(firebaseAuthHandlerStatus);
    } on FirebaseAuthException catch (exception) {
      return Future.value(FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateError, message: exception.message!)));
    }
  }

  Future<FirebaseAuthHandlerStatus> handleEmailSignInAuthentication(EmailSignInCredentials userCredentials) async {
    final AuthCredential credential = EmailAuthProvider.credential(
      email: userCredentials.email,
      password: userCredentials.password,
    );

    return _handleAuthentication(credential);
  }

  Future<FirebaseAuthHandlerStatus> handleGoogleSignInAuthentication(GoogleSignIn googleSignIn) async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _handleAuthentication(credential);
    } else {
      return Future.value(FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateCanceled)));
    }
  }

  Future<FirebaseAuthHandlerStatus> _handleAuthentication(AuthCredential credential) async {
    try {
      late FirebaseAuthHandlerStatus firebaseAuthStatus;

      User? firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(FirestoreConstants.kPathUserCollection)
            .where(FirestoreConstants.kId, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;

        firebaseAuthStatus =
            FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticated), documents: documents, firebaseUser: firebaseUser);

        _writeUserToStore(store, firebaseAuthStatus);
      } else {
        firebaseAuthStatus = FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateError));
      }

      return Future.value(firebaseAuthStatus);
    } on FirebaseAuthException catch (exception) {
      return Future.value(FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateError, message: exception.message!)));
    }
  }

  void _writeUserToStore(Store store, FirebaseAuthHandlerStatus authHandlerStatus) {
    // Writing data to server because here is a new user
    User firebaseUser = authHandlerStatus.firebaseUser!;
    FirebaseFirestore.instance.collection(FirestoreConstants.kPathUserCollection).doc(firebaseUser.uid).set({
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
  }
}
