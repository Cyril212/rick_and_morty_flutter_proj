import 'package:rick_and_morty_flutter_proj/core/Logger.dart';
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

  int? get nextPageNum {
    if (next != null) {
      RegExp exp = RegExp('([?&]page=\\d+)');
      Iterable<Match> matches = exp.allMatches(next!);

      final nextPage = matches.first.group(0).toString().split(RegExp("=")).last;

      Logger.d(nextPage,tag:"nextPage");

      return int.parse(nextPage);
    } else {
      return null;
    }
  }
}
