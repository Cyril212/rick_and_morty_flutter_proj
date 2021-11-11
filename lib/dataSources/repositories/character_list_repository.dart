import 'dart:async';

import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/search_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';
import 'dart:convert';

import 'character_pagination_controller.dart';

///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends AbstractRepository<Character> with SearchModule {
  late final CharacterPaginationController _basicListPagination;
  late final CharacterPaginationController _searchListPagination; //todo: lazy init

  late FavouritesStorageHelper favouritesStorageHelper;

  final DataClient client;

  String? searchPhrase;

  /// Init
  CharacterListRepository(this.client, List<Service> serviceList) : super(serviceList) {
    _basicListPagination = CharacterPaginationController(_characterListSource);
    _searchListPagination = CharacterPaginationController(_characterListSource);

    favouritesStorageHelper = FavouritesStorageHelper(client, _basicListPagination, _searchListPagination);
  }

  /// Gets [CharacterListSource]
  CharacterListService get _characterListSource => (sources[0] as CharacterListService);

  /// Gets current character list
  List<Character> characterListByMode = [];

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => _characterListSource.error;

  @override
  void registerServices() {
    for (var element in sources) {
      element.registerSource(client.manager);
    }
  }

  /// Gets true if response contains link to next page otherwise returns null
  bool hasNextPage() {
    if (searchPhrase != null && searchPhrase!.isEmpty) {
      return _basicListPagination.hasNextPage;
    } else {
      return _searchListPagination.hasNextPage;
    }
  }

  void _incrementPage() {
    int resultPage;
    if (searchPhrase?.isEmpty ?? true) {
      resultPage = _basicListPagination.incrementPage();
    } else {
      resultPage = _searchListPagination.incrementPage();
    }
    _characterListSource.requestDataModel.pageNum = resultPage;
  }

  /// Gets new page if [allowFetch] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByMode]
  void getCharacterList([ListType listFilterMode = ListType.basic, bool refreshList = false]) async {
    _characterListSource.requestDataModel.name = searchPhrase;

    if (refreshList) {

      client.executeQuery(_characterListSource).then((value) {
        _incrementPage();
        return value;
      });
    } else {
      _filterAllPagesListByFilterMode(listFilterMode, false);

      emit(_characterListSource);
    }
  }

  void _setDefaultSearchPage() {
    _searchListPagination.setDefaultPage();
  }

  void setDefaultPageAndGetCharacterList([ListType listFilterMode = ListType.basic]) {
    _setDefaultSearchPage();
    getCharacterList(listFilterMode, true);
  }

  @override
  void broadcast(service) {
    _filterAllPagesListByFilterMode(ListType.basic, true);
    emit(service);
  }

  /// Returns merge of current response with favouriteCharacters from [HiveStore]
  List<Character> _mergeFavouritesCharacterFromStore() {
    List<Character> list = _characterListSource.response?.results ?? [];
    for (var character in list) {
      character.isFavourite = favouritesStorageHelper.getFavouriteCharacterStateById(character.id);
    }
    return list;
  }

  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  void _filterAllPagesListByFilterMode(ListType listFilterMode, bool shouldFetch) {
    //merge new response with characters from store
    List<Character> mergeFavouritesCharacterFromStore = _mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListType.basic:
        if (searchPhrase != null && searchPhrase!.isNotEmpty) {
          if (shouldFetch) {
            //if it's from getCharacters(true) update mergedList
            _searchListPagination.fillAllPagesList(characterListByMode, mergeFavouritesCharacterFromStore);
          }

          _searchListPagination.setCurrentFavouriteStateFromCurrentListMode(characterListByMode);
          //update current list mode
          characterListByMode
            ..clear()
            ..addAll(_searchListPagination.allPagesList);
        } else {
          if (shouldFetch) {
            //if it's from getCharacters(true) update mergedList
            _basicListPagination.fillAllPagesList(characterListByMode, mergeFavouritesCharacterFromStore);
          }

          _basicListPagination.setCurrentFavouriteStateFromCurrentListMode(characterListByMode);
          //update current list mode
          characterListByMode
            ..clear()
            ..addAll(_basicListPagination.allPagesList);
        }
        break;
      case ListType.favourite:
        characterListByMode = favouritesStorageHelper.filterFavouritesListBySearch(searchPhrase);
        break;
    }

    //search if searchPhrase is present
  }

  @override
  void unregisterServices() {
    for (var element in sources) {
      element.unregisterSource(client.manager, int.parse(element.sourceId));
    }
  }
}

class FavouritesStorageHelper {
  DataClient client;

  late final CharacterPaginationController _basicListPagination;
  late final CharacterPaginationController _searchListPagination;

  /// List tag to put/get current favourite list to [HiveStore]
  String get favouriteListTag => "favouriteList";

  FavouritesStorageHelper(this.client, this._basicListPagination, this._searchListPagination);

  /// Puts favourite character to storage
  void putFavouriteCharacterStateById(int characterId, bool state) {
    //Get character
    final Character? characterById = _basicListPagination.allPagesList.firstWhereOrNull((character) => character.id == characterId) ??
        _searchListPagination.allPagesList.firstWhereOrNull((character) => character.id == characterId);

    //Get current list of favorite characters
    List<Character> filteredList = List<Character>.from(getFavouriteCharacters());

    //Find out if it already contains this char
    final alreadyContainsFavourite = filteredList.firstWhereOrNull((character) => character.id == characterId) != null;

    // if contains character and isFavourite(state) false remove item from list
    if (state == false) {
      filteredList.removeWhere((character) => character.id == characterId);
    } else if (alreadyContainsFavourite) {
      //if contains character and state is true
      filteredList.firstWhere((character) => character.id == characterId).isFavourite = state;
    } else if (alreadyContainsFavourite == false && state) {
      // if character hasn't been added
      characterById?.isFavourite = state;
      filteredList.add(characterById!);
    }

    client.putDataToStore(favouriteListTag, json.encode(filteredList));
  }

  /// Gets favourite state by [characterId]
  bool getFavouriteCharacterStateById(int characterId) {
    Character? character = getFavouriteCharacters().firstWhereOrNull((character) => character.id == characterId);

    if (character != null) {
      return character.isFavourite;
    } else {
      return false;
    }
  }

  ///Gets favourite characters
  List<Character> getFavouriteCharacters() {
    String characterListAsString = client.getDataFromStore(favouriteListTag) ?? "";

    List<Map<String, dynamic>> characterStringList =
        characterListAsString.isNotEmpty ? (List<Map<String, dynamic>>.from(json.decode(characterListAsString))) : [];

    return characterStringList.map((json) => Character.fromJson(json)).toList();
  }

  List<Character> filterFavouritesListBySearch(String? searchPhrase) {
    final favouriteList = getFavouriteCharacters();
    if (searchPhrase != null && searchPhrase.isNotEmpty) {
      final tmp = [...favouriteList];
      favouriteList.clear();
      for (var item in tmp) {
        if (item.name.contains(searchPhrase)) {
          favouriteList.add(item);
        }
      }
    }
    return favouriteList;
  }
}
