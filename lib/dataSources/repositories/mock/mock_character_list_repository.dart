import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/mock/mock_character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'dart:convert';

class MockCharacterListRepository extends AbstractRepository<MockCharacterListSource> {
  final MockDataClient client;
  final MockCharacterListSource _source;
  String? searchPhrase;

  MockCharacterListRepository(this.client, this._source);

  List<Character> get characterListByMode => currentListByMode;

  SourceException? get error => _source.error;

  @override
  String get favouriteListTag => "favouriteList";

  @override
  bool get hasNextPage => _source.response?.info.next != null;

  @override
  Future<MockCharacterListSource> fetchResult() => client.executeQuery(_source);

  @override
  void incrementPage() => _source.requestDataModel.pageNum++;

  List<Character> _mergeFavouritesCharacterFromStore() {
    List<Character> list = _source.response?.results ?? [];
    list.forEach((character) {
      character.isFavourite = getFavouriteCharacterStateById(character.id);
    });
    return list;
  }

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

        //update
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

  @visibleForTesting
  void setPhraseAndTryToSearch(String phrase){
    searchPhrase = phrase;
    _tryToSearch();
  }

  void _setCurrentFavouriteStateFromCurrentListMode() {
    allPagesList.forEach((mergedCharacter) {
      currentListByMode.forEach((character) {
        if(mergedCharacter.id == character.id) {
          mergedCharacter.isFavourite = character.isFavourite;
        }
      });
    });
  }

  void putFavouriteCharacterStateById(int characterId, bool state, VoidCallback? actualizeList) {
    final Character? characterById = allPagesList.firstWhereOrNull((character) => character.id == characterId);

    List<Character> filteredList = List<Character>.from(_getFavouriteCharacters());

    final alreadyContainsFavourite = filteredList.firstWhereOrNull((character) => character.id == characterId) != null;
    if (alreadyContainsFavourite && state == false) {
      filteredList.removeWhere((character) => character.id == characterId);

      if (actualizeList != null) {
        actualizeList();
      }
    } else if (alreadyContainsFavourite) {
      filteredList.firstWhere((character) => character.id == characterId).isFavourite = state;
    } else {
      characterById?.isFavourite = state;
      filteredList.add(characterById!);
    }

    client.putDataToStore(favouriteListTag, json.encode(filteredList));
  }

  bool getFavouriteCharacterStateById(int characterId) {
    Character? character = _getFavouriteCharacters().firstWhereOrNull((character) => character.id == characterId);

    if (character != null) {
      return character.isFavourite;
    } else {
      return false;
    }
  }

  List<Character> _getFavouriteCharacters() {
    String characterListAsString = client.getDataFromStore(favouriteListTag) ?? "";

    List<Map<String, dynamic>> characterStringList =
        characterListAsString.isNotEmpty ? (List<Map<String, dynamic>>.from(json.decode(characterListAsString))) : [];

    return characterStringList.map((json) => Character.fromJson(json)).where((character) => character.isFavourite == true).toList();
  }
}
