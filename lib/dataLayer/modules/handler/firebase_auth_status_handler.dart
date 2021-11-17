import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

class AuthStatusHandler {
  final AuthStatus status;
  final List<DocumentSnapshot>? documents;
  final User? firebaseUser;

  AuthStatusHandler({this.status = AuthStatus.uninitialized, this.documents, this.firebaseUser});
}
