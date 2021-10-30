import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/utlis/list.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_list_response.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/vm/character_list_vm.dart';

class CharacterListRepository extends AbstractRepository<CharacterListSource> {
  final RestClient client;
  final CharacterListSource _source;

  CharacterListRepository(this.client, this._source);

  SourceException? get error => _source.error;

  @override
  Future<CharacterListSource> fetchData() => client.addQueryData(_source);

  //todo: encapsulate somewhere
  putCharacterToStoreById(int characterId, bool state) {
    final Character? characterById = _source.response?.results.firstWhereOrNull((character) => character.id == characterId);

    if (characterById != null) {
      characterById.isFavourite = state;
      client.putDataToStore(characterById.id.toString(), characterById.toJson());
    } else {
      //todo:Create logger to avoid prod leak
      print("character was not found");
    }
  }

  void mergeFavouritesCharacterFromStore() {
    _source.response!.results.forEach(setActualFavoriteStateByCharacter);
  }

  void setActualFavoriteStateByCharacter(Character character) {
    character.isFavourite = getFavouriteCharacterStateById(character.id);
  }

  List<Character>? _returnSourceByFilterMode(ListFilterMode listFilterMode) {
    mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListFilterMode.none:
        return _source.response?.results;
      case ListFilterMode.favourite:
        final filteredList = _source.response?.results.where((character) => character.isFavourite).toList();
        return filteredList;
    }
  }

  Future<List<Character>?> getCharactersWithFavouriteState([ListFilterMode listFilterMode = ListFilterMode.none, bool shouldFetch = false]) {
    if (shouldFetch) {
      return fetchData().then((value) {
        if (_source.response != null) {
          return _returnSourceByFilterMode(listFilterMode);
        } else {
          return _source.response?.results;
        }
      });
    } else {
      final sourceByFilterMode = _returnSourceByFilterMode(listFilterMode);
      return Future.value(sourceByFilterMode);
    }
  }

  //todo: encapsulate somewhere
  bool getFavouriteCharacterStateById(int characterId) {
    final characterFromStore = client.getDataFromStore(characterId.toString());
    return characterFromStore != null ? characterFromStore["isFavourite"] : false;
  }

  @override
  Future<CharacterListSource> unsubscribe() => Future.value();
}
