import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'dart:convert';


///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends AbstractRepository<CharacterListSource> {

  final DataClient client;
  final CharacterListSource _source;

  /// Search phrase for filtering [characterListByMode]
  String? searchPhrase;

  /// Init
  CharacterListRepository(this.client, this._source);

  /// Gets current character list
  List<Character> get characterListByMode => currentListByMode;

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => _source.error;

  /// List tag to put/get current favourite list to [HiveStore]
  @override
  String get favouriteListTag => "favouriteList";

  /// Gets true if response contains link to next page otherwise returns null
  @override
  bool get hasNextPage => _source.response?.info.next != null;

  /// Fetch next page
  @override
  Future<CharacterListSource> fetchResult() => client.executeQuery(_source);

  /// Init page
  @override
  void incrementPage() => _source.requestDataModel.pageNum++;

  /// Returns merge of current response with favouriteCharacters from [HiveStore]
  List<Character> _mergeFavouritesCharacterFromStore() {
    List<Character> list = _source.response?.results ?? [];
    list.forEach((character) {
      character.isFavourite = getFavouriteCharacterStateById(character.id);
    });
    return list;
  }

  /// Gets new page if [shouldFetch] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByMode]
  Future<void> fetchCharacterList([ListFilterMode listFilterMode = ListFilterMode.none, bool shouldFetch = false]) async {
    if (shouldFetch) {
      return fetchResult().then((value) {
        if (_source.response != null) {
          filterAllPagesListByFilterMode(listFilterMode, shouldFetch);

          if (hasNextPage) {
            incrementPage();
          }
        } else {
          return null;
        }
      });
    } else {
      filterAllPagesListByFilterMode(listFilterMode, shouldFetch);
    }
  }


  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  @override
  void filterAllPagesListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch) {

    //merge new response with characters from store
    List<Character> mergeFavouritesCharacterFromStore = _mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListFilterMode.none:
        if (shouldFetch) {//if it's from getCharacters(true) update mergedList
          if (allPagesList.isNotEmpty) {
            allPagesList.addAll(mergeFavouritesCharacterFromStore);
          } else {
            allPagesList = mergeFavouritesCharacterFromStore;
          }
        }

        //set current state from filteredListByMode to mergedList
        _setCurrentFavouriteStateFromCurrentListMode();

        //update current list mode
        currentListByMode
          ..clear()
          ..addAll(allPagesList);
        break;
      case ListFilterMode.favourite:
        currentListByMode = _getFavouriteCharacters();
        break;
    }

    //search if searchPhrase is present
    _tryToSearch();
  }

  /// Merges [allPagesList] isFavourite state with [currentList]
  void _setCurrentFavouriteStateFromCurrentListMode() {
    allPagesList.forEach((mergedCharacter) {
      currentListByMode.forEach((character) {
        if(mergedCharacter.id == character.id) {
          mergedCharacter.isFavourite = character.isFavourite;
        }
      });
    });
  }


  ///Filters [currentListByMode] by searchPhrase
  void _tryToSearch(){
    if(searchPhrase != null && searchPhrase!.isNotEmpty) {
      final tmp = [...currentListByMode];
      currentListByMode.clear();
      tmp.forEach((character) {
        if(character.name.contains(searchPhrase!)) {
          currentListByMode.add(character);
        }
      });
    }
  }


  /// Puts favourite character to storage
  void putFavouriteCharacterStateById(int characterId, bool state) {

    //Get character
    final Character? characterById = allPagesList.firstWhereOrNull((character) => character.id == characterId);

    //Get current list of favorite characters
    List<Character> filteredList = List<Character>.from(_getFavouriteCharacters());

    //Find out if it already contains this char
    final alreadyContainsFavourite = filteredList.firstWhereOrNull((character) => character.id == characterId) != null;

    // if contains character and isFavourite(state) false remove item from list
    if (alreadyContainsFavourite && state == false) {
      filteredList.removeWhere((character) => character.id == characterId);

    } else if (alreadyContainsFavourite) { //if contains character and state is true
      filteredList.firstWhere((character) => character.id == characterId).isFavourite = state;

    } else {
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

    return characterStringList.map((json) => Character.fromJson(json)).where((character) => character.isFavourite == true).toList();
  }
}
