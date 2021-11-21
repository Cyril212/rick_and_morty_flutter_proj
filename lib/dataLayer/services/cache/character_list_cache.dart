import 'package:rick_and_morty_flutter_proj/core/dataProvider/cache.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

class CharacterListCache extends Cache<CharacterListResponse> {
  CharacterListCache(InMemoryStore store) : super(store);

  @override
  CharacterListResponse onCacheWrite(InMemoryStore store, String dataId, CharacterListResponse response) {
    final cachedResponse = store.get(dataId);

    if (cachedResponse != null && response.info.pages > 2) {
      CharacterListResponse characterListResponseFromCache = CharacterListResponse.fromJson(cachedResponse);
      List<Character> mergedCurrentResponseWithCache = List.from(characterListResponseFromCache.results)..addAll(response.results); // to avoid concurrent modification
      response.results = mergedCurrentResponseWithCache;
    }
    return response;
  }
}