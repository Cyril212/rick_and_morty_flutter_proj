import 'dart:convert';

import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/cache/character_list_cache.dart';

class CharacterStorageHelper<T extends BaseDataClient<BaseDataManager>> {
  final T _client;
  final CharacterListCache _cache;

  CharacterStorageHelper(this._client, this._cache);

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
    final Character characterById = getCharacterById(characterId)..isFavourite = state;
    _updateFavouriteCharacter(characterById);
  }

  /// Puts favourite character to storage
  void putFavouriteCharacter(Character newCharacter, bool state) {
    //Get character
    final Character characterWithNewState = newCharacter..isFavourite = state;
    _updateFavouriteCharacter(characterWithNewState);
  }

  void _updateFavouriteCharacter(Character newCharacter) {
    //Get current list of favorite characters
    List<Character> filteredList = List<Character>.from(getFavouriteCharacters());

    //Find out if it already contains this char
    final alreadyContainsFavourite = filteredList.firstWhereOrNull((character) => character.id == newCharacter.id) != null;

    // if contains character and isFavourite(state) false remove item from list
    if (newCharacter.isFavourite == false) {
      filteredList.removeWhere((character) => character.id == newCharacter.id);
    } else if (alreadyContainsFavourite) {
      //if contains character and state is true
      filteredList.firstWhere((character) => character.id == newCharacter.id).isFavourite = newCharacter.isFavourite;
    } else if (alreadyContainsFavourite == false && newCharacter.isFavourite) {
      // if character hasn't been added
      filteredList.add(newCharacter);
    }

    _client.putDataToStore(AppConstants.kFavouriteListDataId, json.encode(filteredList));
  }

  Character getCharacterById(int characterId) => getFavouriteCharacterById(characterId) ?? _cache.getCharacterById(characterId);

  /// Gets favourite state by [characterId]
  Character? getFavouriteCharacterById(int characterId) => getFavouriteCharacters().firstWhereOrNull((character) => character.id == characterId);

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
    String characterListAsString = _client.getDataFromStore(AppConstants.kFavouriteListDataId) ?? "";

    List<Map<String, dynamic>> characterStringList =
        characterListAsString.isNotEmpty ? (List<Map<String, dynamic>>.from(json.decode(characterListAsString))) : [];

    return characterStringList.map((json) => Character.fromJson(json)).toList();
  }

  List<Character> getFavouriteCharactersBySearch(String? searchPhrase) {
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
