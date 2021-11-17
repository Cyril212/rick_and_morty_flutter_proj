import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

class UserChat extends ResponseDataModel{
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;

  UserChat({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe}) : super.fromJson({});

  @override
  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}
    return UserChat(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }
}
