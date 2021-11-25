import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/cache.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

class CharacterListCache extends Cache<CharacterListResponse> {
  CharacterListCache(InMemoryStore store, String method) : super(store, method);

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

  Character getCharacterById(int characterId) {
    final cachedServicesAsEntries = store.data.entries.where((entry) => entry.key.contains(method)).toList();

    return cachedServicesAsEntries
        .map((cache) => CharacterListResponse.fromJson(cache.value).results)
        .flattened
        .firstWhere((character) => character.id == characterId);
  }

  @override
  String resolveQuery(String query) => query.replaceAll(RegExp('([?&]page=\\d+)'), "");
}
