import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

import 'cache/character_list_cache.dart';

/// CharacterListSource data source
class CharacterListService extends Service<CharacterListRequest, CharacterListResponse, CharacterListCache> {
  CharacterListService(RestManager restManager, CharacterListRequest requestDataModel, {Map<String, dynamic>? responseDataModel})
      : super(requestDataModel, (Map<String, dynamic> json) {
          final response = CharacterListResponse.fromJson(json);
          if (response.info.nextPageNum != null) {
            requestDataModel.pageNum = response.info.nextPageNum!;
          }
          return CharacterListResponse.fromJson(json);
        }, CharacterListCache(restManager.inMemoryStore));
}
