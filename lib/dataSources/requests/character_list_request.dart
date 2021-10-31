import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';

class CharacterListRequest extends RequestDataModel {
  int pageNum;

  CharacterListRequest(String method,{Map<String, String>? headers,this.pageNum = 1}) : super(method, headers);

  @override
  Map<String, dynamic> toJson() {
    return {"page" : pageNum};
  }
}
