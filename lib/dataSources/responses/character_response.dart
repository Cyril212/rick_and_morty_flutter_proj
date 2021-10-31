import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';

import 'character_list_response.dart';

class Character extends DataModel{
  late final int id;
  late final String name;
  late final String status;
  late final String species;
  late final String type;
  late final String gender;
  late final Origin origin;
  late final Origin location;
  late final String image;
  late final List<String> episode;
  late final String url;
  late final String created;

  bool isFavourite = false;

  Character.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    species = json['species'];
    type = json['type'];
    gender = json['gender'];
    origin = Origin.fromJson(json['origin']);
    location = Origin.fromJson(json['location']);
    image = json['image'];
    episode = json['episode'].cast<String>();
    url = json['url'];
    created = json['created'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['species'] = species;
    data['type'] = type;
    data['gender'] = gender;
    data['origin'] = origin.toJson();
    data['location'] = location.toJson();
    data['image'] = image;
    data['episode'] = episode;
    data['url'] = url;
    data['created'] = created;
    data['isFavourite'] = isFavourite;
    return data;
  }
}
