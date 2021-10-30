import 'package:enum_to_string/enum_to_string.dart';
import 'package:prefs/prefs.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/utlis/list.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/character_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class CharacterListRepository extends AbstractRepository<CharacterListSource> {
  final String listModePrefKey = "listMode";
  final DataClient client;
  final CharacterListSource _source;

  SourceException? get error => _source.error;

  ListFilterMode get filterListState => EnumToString.fromString(ListFilterMode.values, Prefs.getString(listModePrefKey)) ?? ListFilterMode.none;

  CharacterListRepository(this.client, this._source);

  @override
  Future<CharacterListSource> fetchData() => client.addQueryData(_source);

  Future putFilterListState(ListFilterMode filterMode) => Prefs.setString(listModePrefKey, EnumToString.convertToString(filterMode));

  //todo: encapsulate somewhere
  putCharacterToStoreById(int characterId, bool state) {
    final Character? characterById = _source.response?.results.firstWhereOrNull((character) => character.id == characterId);

    if (characterById != null) {
      characterById.isFavourite = state;
      client.putMapDataToStore(characterById.id.toString(), characterById.toJson());
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
    bool isFavourite = characterFromStore?["isFavourite"] ?? false;

    return characterFromStore != null ? isFavourite : false;
  }

  @override
  Future<CharacterListSource> unsubscribe() => Future.value();
}
