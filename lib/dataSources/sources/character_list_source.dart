import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_list_response.dart';

class CharacterListSource extends DataSource<CharacterListRequest, CharacterListResponse> {
  CharacterListSource(RestManager model, CharacterListRequest requestDataModel, {Map<String, dynamic>? responseDataModel})
      : super(requestDataModel, (Map<String, dynamic> json) => CharacterListResponse.fromJson(json), model);
}
