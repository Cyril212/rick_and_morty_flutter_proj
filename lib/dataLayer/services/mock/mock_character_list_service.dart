import 'package:rick_and_morty_flutter_proj/core/dataProvider/cache.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/cache/character_list_cache.dart';

///Mock model of [CharacterListSource]
class MockCharacterListService extends Service<CharacterListRequest, CharacterListResponse, CharacterListCache> {
  MockCharacterListService(MockManager restManager, CharacterListRequest requestDataModel, {Map<String, dynamic>? responseDataModel})
      : super(requestDataModel, (Map<String, dynamic> json) => CharacterListResponse.fromJson(json),CharacterListCache(restManager.inMemoryStore));
}
