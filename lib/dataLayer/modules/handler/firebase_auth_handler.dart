import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/credentials_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/model/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/common_user_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

class FirebaseAuthHandlerStatus {
  final AuthEvent event;
  final List<DocumentSnapshot>? documents;
  final User? firebaseUser;

  FirebaseAuthHandlerStatus({event, this.documents, this.firebaseUser}) : event = event ?? AuthEvent();
}

class FirebaseAuthHandler {
  final CommonUserStore commonUserStore;

  CredentialsStore? credentialsStore;

  FirebaseAuthHandler({required this.commonUserStore, this.credentialsStore});

  Future<FirebaseAuthHandlerStatus> createUserWithEmailAndPassword(EmailSignInCredentials emailSignIn) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailSignIn.email, password: emailSignIn.password);

      final firebaseAuthHandlerStatus = FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.registered));

      await credentialsStore?.write(emailSignIn);

      _writeUserToStore(firebaseAuthHandlerStatus, AuthType.email);

      return firebaseAuthHandlerStatus;
    } on FirebaseAuthException catch (exception) {
      return FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateError, message: exception.message!));
    }
  }

  Future<FirebaseAuthHandlerStatus> handleEmailSignInAuthentication(EmailSignInCredentials userCredentials) async {
    final AuthCredential credential = EmailAuthProvider.credential(
      email: userCredentials.email,
      password: userCredentials.password,
    );

    return _handleAuthentication(credential, AuthType.email).then((value) async {
      await credentialsStore?.write(userCredentials);
      return value;
    });
  }

  Future<FirebaseAuthHandlerStatus> handleGoogleSignInAuthentication(GoogleSignIn googleSignIn) async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return _handleAuthentication(credential, AuthType.googleSignIn);
    } else {
      return FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateCanceled));
    }
  }

  Future<FirebaseAuthHandlerStatus> _handleAuthentication(AuthCredential credential, AuthType authType) async {
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

        _writeUserToStore(firebaseAuthStatus, authType);
      } else {
        firebaseAuthStatus = FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateError));
      }

      return firebaseAuthStatus;
    } on FirebaseAuthException catch (exception) {
      return FirebaseAuthHandlerStatus(event: AuthEvent(status: AuthStatus.authenticateError, message: exception.message!));
    }
  }

  void _writeUserToStore(FirebaseAuthHandlerStatus authHandlerStatus, AuthType authType) =>
      commonUserStore.putUser(firebaseUser: authHandlerStatus.firebaseUser!, authType: authType);
}
