import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';

class Info extends DataModel {
  late final int count;
  late final int pages;
  String? next;
  String? prev;

  Info.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    count = json['count'];
    pages = json['pages'];
    next = json['next'];
    prev = json['prev'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['pages'] = pages;
    data['next'] = next;
    data['prev'] = prev;
    return data;
  }
}
