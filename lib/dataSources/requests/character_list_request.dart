import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';

class CharacterListRequest extends RequestDataModel {
  CharacterListRequest(String method, {Map<String, String>? headers}) : super(method, headers);

  @override
  Map<String, dynamic> toJson() {
    return {};
  }
}
