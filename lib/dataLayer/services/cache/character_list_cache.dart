import 'package:rick_and_morty_flutter_proj/core/dataProvider/cache.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

class CharacterListCache extends Cache<CharacterListResponse> {
  CharacterListCache(InMemoryStore store) : super(store);

  @override
  CharacterListResponse onCacheWrite(InMemoryStore store, String query, CharacterListResponse response) {
    final cachedResponse = store.get(query);

    bool hasNextPage = response.info.next != null;
    if (hasNextPage) {
      final pageNumber = response.info.nextPageNum!;
      final alreadyFetchedFirstPage = cachedResponse != null && pageNumber > 2;

      if (alreadyFetchedFirstPage) {
        CharacterListResponse characterListResponseFromCache = CharacterListResponse.fromJson(cachedResponse!);

        List<Character> mergedCurrentResponseWithCache = List.from(characterListResponseFromCache.results)
          ..addAll(response.results); // to avoid concurrent modification

        response.results = mergedCurrentResponseWithCache;
      }
    }

    return response;
  }

  @override
  String resolveQuery(String query) => query.replaceAll(RegExp('([?&]page=\\d+)'), "");
}
