import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

import 'cache/character_list_cache_handler.dart';

/// CharacterListSource data source
class CharacterListService extends Service<CharacterListRequest, CharacterListResponse, CharacterListCacheHandler> {
  CharacterListService(RestManager restManager, CharacterListRequest requestDataModel, {Map<String, dynamic>? responseDataModel})
      : super(requestDataModel, (Map<String, dynamic> json) => CharacterListResponse.fromJson(json),
            CharacterListCacheHandler(restManager.inMemoryStore, requestDataModel.method));
}
