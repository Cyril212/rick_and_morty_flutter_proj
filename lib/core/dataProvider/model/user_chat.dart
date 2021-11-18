import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rick_and_morty_flutter_proj/constants/firestore_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

class CommonUser extends DataModel{
  late String id;
  late String photoUrl;
  late String nickname;
  late String aboutMe;

  CommonUser({required this.id, required this.photoUrl, required this.nickname, required this.aboutMe, Map<String, dynamic>? json}) : super.fromJson(json ?? {});

  @override
  Map<String, String> toJson() {
    return {
      FirestoreConstants.kNickname: nickname,
      FirestoreConstants.kAboutMe: aboutMe,
      FirestoreConstants.kPhotoUrl: photoUrl,
    };
  }

  CommonUser.fromJson(Map<String, dynamic> json) : super.fromJson(json){
    nickname = json[FirestoreConstants.kNickname];
    aboutMe = json[FirestoreConstants.kAboutMe];
    photoUrl = json[FirestoreConstants.kPhotoUrl];
  }

  factory CommonUser.fromDocument(DocumentSnapshot doc) {
    String aboutMe = "";
    String photoUrl = "";
    String nickname = "";
    try {
      aboutMe = doc.get(FirestoreConstants.kAboutMe);
    } catch (e) {}
    try {
      photoUrl = doc.get(FirestoreConstants.kPhotoUrl);
    } catch (e) {}
    try {
      nickname = doc.get(FirestoreConstants.kNickname);
    } catch (e) {}
    return CommonUser(
      id: doc.id,
      photoUrl: photoUrl,
      nickname: nickname,
      aboutMe: aboutMe,
    );
  }
}
