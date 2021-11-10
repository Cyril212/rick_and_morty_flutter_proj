import 'dart:async';

import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/search_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/abstract_pagination.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';
import 'dart:convert';

///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends AbstractRepository<Character> with SearchModule {
  late final PaginationController<Character> _basicListPagination;
  late final PaginationController<Character> _searchListPagination; //todo: lazy init

  final DataClient client;

  String? searchPhrase;

  /// Init
  CharacterListRepository(this.client, List<Service> serviceList) : super(serviceList) {
    _basicListPagination = PaginationController<Character>();
    _searchListPagination = PaginationController<Character>();
  }

  /// Gets [CharacterListSource]
  CharacterListService get _characterListSource => (sources[0] as CharacterListService);

  /// Gets current character list
  List<Character> characterListByMode = [];

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => _characterListSource.error;

  /// List tag to put/get current favourite list to [HiveStore]
  String get favouriteListTag => "favouriteList";

  /// Gets true if response contains link to next page otherwise returns null
  bool hasNextPage() {
    if (searchPhrase != null && searchPhrase!.isEmpty) {
      return _basicListPagination.hasNextPage;
    } else {
      return _searchListPagination.hasNextPage;
    }
  }

  /// Gets new page if [shouldFetch] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByMode]
  void getCharacterList([ListType listFilterMode = ListType.basic]) async {
    switch (listFilterMode) {
      case ListType.basic:
        _characterListSource.requestDataModel.name = searchPhrase;

        client.executeQuery(_characterListSource).then((value) {
          _incrementPage();
          return value;
        });
        break;
      case ListType.favourite:
        filterAllPagesListByFilterMode(listFilterMode, false);

        emit(_characterListSource);
        break;
    }
  }

  void setDefaultPageAndGetCharacterList([ListType listFilterMode = ListType.basic]) {
    _setDefaultPage();
    getCharacterList(listFilterMode);
  }

  @override
  void broadcast(source) {
    filterAllPagesListByFilterMode(ListType.basic, true);
    emit(source);
  }

  /// Init page
  void _incrementPage() {
    int resultPage;
    if (searchPhrase?.isEmpty ?? true) {
      resultPage = _basicListPagination.pageNumber;
    } else {
      resultPage = _searchListPagination.pageNumber;
    }
    _characterListSource.requestDataModel.pageNum = resultPage;
  }

  void _setDefaultPage() {
    if (searchPhrase?.isEmpty ?? true) {
      _basicListPagination.setDefaultPage();
    } else {
      _searchListPagination.setDefaultPage();
    }
  }

  void setDefaultPageToCharacterListRequest() => _characterListSource.requestDataModel.pageNum = 1;

  /// Returns merge of current response with favouriteCharacters from [HiveStore]
  List<Character> _mergeFavouritesCharacterFromStore() {
    List<Character> list = _characterListSource.response?.results ?? [];
    for (var character in list) {
      character.isFavourite = getFavouriteCharacterStateById(character.id);
    }
    return list;
  }

  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  void filterAllPagesListByFilterMode(ListType listFilterMode, bool shouldFetch) {
    //merge new response with characters from store
    List<Character> mergeFavouritesCharacterFromStore = _mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListType.basic:
        if (shouldFetch) {
          //if it's from getCharacters(true) update mergedList
          if (_basicListPagination.allPagesList.isNotEmpty) {
            _basicListPagination.allPagesList.addAll(mergeFavouritesCharacterFromStore);
          } else {
            _basicListPagination.allPagesList = mergeFavouritesCharacterFromStore;
          }
        }

        //set current state from filteredListByMode to mergedList
        _setCurrentFavouriteStateFromCurrentListMode();

        //update current list mode
        characterListByMode
          ..clear()
          ..addAll(_basicListPagination.allPagesList);
        break;
      case ListType.favourite:
        characterListByMode = _getFavouriteCharacters();
        tryToSearch(characterListByMode);
        break;
    }

    //search if searchPhrase is present
  }

  void tryToSearch(List currentList) {
    if (searchPhrase != null && searchPhrase!.isNotEmpty) {
      final tmp = [...currentList];
      currentList.clear();
      for (var item in tmp) {
        if (item.name.contains(searchPhrase!)) {
          currentList.add(item);
        }
      }
    }
  }

  /// Merges [allPagesList] isFavourite state with [currentList]
  void _setCurrentFavouriteStateFromCurrentListMode() {
    for (var mergedCharacter in _basicListPagination.allPagesList) {
      for (var character in characterListByMode) {
        if (mergedCharacter.id == character.id) {
          mergedCharacter.isFavourite = character.isFavourite;
        }
      }
    }
  }

  /// Puts favourite character to storage
  void putFavouriteCharacterStateById(int characterId, bool state) {
    //Get character
    final Character? characterById = _basicListPagination.allPagesList.firstWhereOrNull((character) => character.id == characterId);

    //Get current list of favorite characters
    List<Character> filteredList = List<Character>.from(_getFavouriteCharacters());

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
    Character? character = _getFavouriteCharacters().firstWhereOrNull((character) => character.id == characterId);

    if (character != null) {
      return character.isFavourite;
    } else {
      return false;
    }
  }

  ///Gets favourite characters
  List<Character> _getFavouriteCharacters() {
    String characterListAsString = client.getDataFromStore(favouriteListTag) ?? "";

    List<Map<String, dynamic>> characterStringList =
        characterListAsString.isNotEmpty ? (List<Map<String, dynamic>>.from(json.decode(characterListAsString))) : [];

    return characterStringList.map((json) => Character.fromJson(json)).toList();
  }

  @override
  void registerServices() {
    for (var element in sources) {
      element.registerSource(client.manager);
    }
  }

  @override
  void unregisterServices() {
    for (var element in sources) {
      element.unregisterSource(client.manager, int.parse(element.sourceId));
    }
  }
}
