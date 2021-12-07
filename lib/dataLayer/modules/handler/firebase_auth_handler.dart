import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

class FirebaseAuthHandlerStatus {
  final AuthStatus status;
  final List<DocumentSnapshot>? documents;
  final User? firebaseUser;

  const FirebaseAuthHandlerStatus({this.status = AuthStatus.uninitialized, this.documents, this.firebaseUser});
}

class FirebaseAuthHandler {
  final GoogleSignIn googleSignIn;

  const FirebaseAuthHandler({required this.googleSignIn});

  Future<FirebaseAuthHandlerStatus> handleAuthentication() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      User? firebaseUser = (await FirebaseAuth.instance.signInWithCredential(credential)).user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(FirestoreConstants.kPathUserCollection)
            .where(FirestoreConstants.kId, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;

        return Future.value(FirebaseAuthHandlerStatus(documents: documents, firebaseUser: firebaseUser));
      } else {
        return Future.value(const FirebaseAuthHandlerStatus(status: AuthStatus.authenticateError));
      }
    } else {
      return Future.value(const FirebaseAuthHandlerStatus(status: AuthStatus.authenticateCanceled));
    }
  }
}
