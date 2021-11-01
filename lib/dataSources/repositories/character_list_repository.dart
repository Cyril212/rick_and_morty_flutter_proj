import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/utlis/list.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'dart:convert';

class CharacterListRepository extends AbstractRepository<CharacterListSource> {
  final DataClient client;
  final CharacterListSource _source;
  String? searchPhrase;

  CharacterListRepository(this.client, this._source);

  List<Character> get characterListByMode => currentListByMode;

  SourceException? get error => _source.error;

  @override
  String get favouriteListTag => "favouriteList";

  @override
  bool get hasNextPage => _source.response?.info.next != null;

  @override
  Future<CharacterListSource> fetchPage() => client.executeQuery(_source);

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
      return fetchPage().then((value) {
        if (_source.response != null) {
          filterListByFilterMode(listFilterMode, shouldFetch);

          if (hasNextPage) {
            incrementPage();
          }
        } else {
          return null;
        }
      });
    } else {
      filterListByFilterMode(listFilterMode, shouldFetch);
    }
  }

  @override
  List<Character>? filterListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch) {

    //merge new response with characters from store
    List<Character> mergeFavouritesCharacterFromStore = _mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListFilterMode.none:
        if (shouldFetch) {//if it's from getCharacters(true) update mergedList
          if (mergedList.isNotEmpty) {
            mergedList.addAll(mergeFavouritesCharacterFromStore);
          } else {
            mergedList = mergeFavouritesCharacterFromStore;
          }
        }

        //set current state from filteredListByMode to mergedList
        _setCurrentFavouriteStateFromCurrentListMode();

        //update
        currentListByMode
          ..clear()
          ..addAll(mergedList);
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

  void _setCurrentFavouriteStateFromCurrentListMode() {
    mergedList.forEach((mergedCharacter) {
      currentListByMode.forEach((character) {
        if(mergedCharacter.id == character.id) {
          mergedCharacter.isFavourite = character.isFavourite;
        }
      });
    });
  }

  void putFavouriteCharacterStateById(int characterId, bool state, VoidCallback? actualizeList) {
    final Character? characterById = mergedList.firstWhereOrNull((character) => character.id == characterId);

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

    client.store!.put(favouriteListTag, json.encode(filteredList));
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
