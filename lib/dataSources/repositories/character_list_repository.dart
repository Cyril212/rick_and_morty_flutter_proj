import 'package:enum_to_string/enum_to_string.dart';
import 'package:prefs/prefs.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/utlis/list.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class CharacterListRepository extends AbstractListRepository<CharacterListSource> {
  final String listModePrefKey = "listMode";
  final DataClient client;
  final CharacterListSource _source;

  List<Character> _mergedCharacterList;

  List<Character> characterListByMode;

  SourceException? get error => _source.error;

  ListFilterMode get filterListState => EnumToString.fromString(ListFilterMode.values, Prefs.getString(listModePrefKey)) ?? ListFilterMode.none;

  CharacterListRepository(this.client, this._source)
      : _mergedCharacterList = [],
        characterListByMode = [];

  @override
  Future<CharacterListSource> fetchPage() => client.executeQuery(_source);

  @override
  Future<CharacterListSource> unsubscribe() => Future.value();

  Future putFilterListState(ListFilterMode filterMode) => Prefs.setString(listModePrefKey, EnumToString.convertToString(filterMode));

  List<Character> _mergeFavouritesCharacterFromStore() {
    List<Character> list = _source.response!.results..forEach((character) {
        character.isFavourite = getFavouriteCharacterStateById(character.id);
      });
    return list;
  }

  void incrementPage() => _source.requestDataModel.pageNum++;

  List<Character>? _filterCharacterListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch) {
    List<Character> mergeFavouritesCharacterFromStore = _mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListFilterMode.none:
        if (shouldFetch) {
          if (_mergedCharacterList.isNotEmpty) {
            _mergedCharacterList.addAll(mergeFavouritesCharacterFromStore);
          } else {
            _mergedCharacterList = mergeFavouritesCharacterFromStore;
          }
        }
        characterListByMode
          ..clear()
          ..addAll(_mergedCharacterList);
        break;
      case ListFilterMode.favourite:
        if (characterListByMode.isNotEmpty) {
          characterListByMode.removeWhere((character) => character.isFavourite == false);
        } else {
          final listFilteredByFavourite = _mergedCharacterList.where((character) => character.isFavourite == false);
          characterListByMode.addAll(listFilteredByFavourite);
        }
        break;
    }
  }

  Future<void> getCharactersWithFavouriteState([ListFilterMode listFilterMode = ListFilterMode.none, bool shouldFetch = false]) async {
    if (shouldFetch) {
      return fetchPage().then((value) {
        if (_source.response != null) {
          _filterCharacterListByFilterMode(listFilterMode, shouldFetch);

          incrementPage();
        } else {
          return null;
        }
      });
    } else {
      _filterCharacterListByFilterMode(listFilterMode, shouldFetch);
    }
  }

  //todo: encapsulate somewhere
  void putFavouriteCharacterStateById(int characterId, bool state) {
    final Character? characterById = _mergedCharacterList.firstWhereOrNull((character) => character.id == characterId);

    if (characterById != null) {
      characterById.isFavourite = state;
      client.putMapDataToStore(characterById.id.toString(), characterById.toJson());
    } else {
      //todo:Create logger to avoid prod leak
      print("character was not found");
    }
  }

  //todo: encapsulate somewhere
  bool getFavouriteCharacterStateById(int characterId) {
    final characterFromStore = client.getDataFromStore(characterId.toString());
    bool isFavourite = characterFromStore?["isFavourite"] ?? false;

    return characterFromStore != null ? isFavourite : false;
  }
}
