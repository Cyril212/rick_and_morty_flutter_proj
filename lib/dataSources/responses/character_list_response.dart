import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

import 'character_response.dart';
import 'info_response.dart';

class CharacterListResponse extends ResponseDataModel{
  late final Info info;
  late List<Character> results;

  CharacterListResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    info = Info.fromJson(json['info']);
    results = <Character>[];
    json['results'].forEach((v) {
      results.add(Character.fromJson(v));
    });
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['info'] = info.toJson();
    data['results'] = results.map((v) => v.toJson()).toList();

    return data;
  }
}

class Origin extends DataModel{
 late final String name;
 late final String url;


  Origin.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    name = json['name'];
    url = json['url'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
