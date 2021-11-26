import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';

///CharacterList request model
class CharacterListRequest extends RequestDataModel {
  /// Initial page, by default is 1
  int pageNum;

  String? name;

  CharacterListRequest(FetchPolicy fetchPolicy, {Map<String, String>? headers, this.pageNum = 1}) : super("/character", headers, fetchPolicy);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (name != null && name!.isNotEmpty) {
      data['name'] = name;
    }

    data['page'] = pageNum;

    return data;
  }
}
