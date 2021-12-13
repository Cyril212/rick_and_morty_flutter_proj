import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/common_user.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

enum AuthType { email, googleSignIn }

class CommonUserStore {
  final Store store;

  CommonUserStore({required this.store});

  CommonUser? get user {
    if (store.get(AppConstants.kUserDB) == null) {
      return null;
    }

    Map<String, dynamic> decodedUser = Map<String, dynamic>.from(store.get(AppConstants.kUserDB));
    return CommonUser.fromJson(decodedUser);
  }

  void putUser({required User firebaseUser, required AuthType authType}) {
    // Writing data to server because here is a new user
    FirebaseFirestore.instance.collection(FirestoreConstants.kPathUserCollection).doc(firebaseUser.uid).set({
      FirestoreConstants.kNickname: firebaseUser.displayName,
      FirestoreConstants.kPhotoUrl: firebaseUser.photoURL,
      FirestoreConstants.kId: firebaseUser.uid,
      FirestoreConstants.kCreatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
      FirestoreConstants.kChattingWith: null
    });

    CommonUser commonUser =
        CommonUser(id: firebaseUser.uid, nickname: firebaseUser.displayName ?? "", aboutMe: "", photoUrl: firebaseUser.photoURL ?? "");

    store.put(AppConstants.kAuthType, authType.name);
    store.put(AppConstants.kUserDB, commonUser.toJson());
  }

  void clear() {
    store.delete(AppConstants.kUserDB);
    store.delete(AppConstants.kAuthType);
  }
}
