import 'dart:convert';

import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_list_response.dart';

import '../character_pagination_controller.dart';

class FavouritesStorageHelper {
  DataClient client;

  late final CharacterPaginationController _basicListPagination;
  late final CharacterPaginationController _searchListPagination;

  /// List tag to put/get current favourite list to [HiveStore]
  String get favouriteListTag => "favouriteList";

  FavouritesStorageHelper(this.client, this._basicListPagination, this._searchListPagination);

  /// Returns merge of current response with favouriteCharacters from [HiveStore]
  List<Character> mergeFavouritesCharacterFromStore(CharacterListResponse? response) {
    List<Character> list = response?.results ?? [];
    for (var character in list) {
      character.isFavourite = getFavouriteCharacterStateById(character.id);
    }
    return list;
  }

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