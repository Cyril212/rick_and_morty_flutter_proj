import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

/// Info response model
class Info extends ResponseDataModel {
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

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['pages'] = pages;
    data['next'] = next;
    data['prev'] = prev;
    return data;
  }
}
