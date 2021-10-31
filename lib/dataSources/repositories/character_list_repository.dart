import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:prefs/prefs.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/utlis/list.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'dart:convert';

class CharacterListRepository extends AbstractRepository<CharacterListSource> {
  final DataClient client;
  final CharacterListSource _source;

  CharacterListRepository(this.client, this._source);

  List<Character> get characterListByMode => filteredListByMode;

  ListFilterMode get filterCharacterListState => super.filterListState;

  SourceException? get error => _source.error;

  @override
  String get listModePrefKey => "listMode";

  @override
  bool get hasNextPage => _source.response?.info.next != null;

  @override
  Future<CharacterListSource> fetchPage() => client.executeQuery(_source);

  Future putFilterListState(ListFilterMode filterMode) => Prefs.setString(listModePrefKey, EnumToString.convertToString(filterMode));

  List<Character> _mergeFavouritesCharacterFromStore() {
    List<Character> list = _source.response!.results
      ..forEach((character) {
        character.isFavourite = getFavouriteCharacterStateById(character.id);
      });
    return list;
  }

  @override
  void incrementPage() => _source.requestDataModel.pageNum++;

  Future<void> actualizeCharacters([ListFilterMode listFilterMode = ListFilterMode.none, bool shouldFetch = false]) async {
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

  //todo: encapsulate somewhere
  void putFavouriteCharacterStateById(int characterId, bool state, VoidCallback? actualizeList) {
    final Character? characterById = mergedList.firstWhereOrNull((character) => character.id == characterId);
    characterById?.isFavourite = state;

    Prefs.setBool(characterId.toString(), state);

    List<Character>? filteredList = List<Character>.from(getFavouriteCharactersState());

    if (filteredList != null) {
      final alreadyContainsFavourite = filteredList.firstWhereOrNull((character) => character.id == characterId) != null;
      if (alreadyContainsFavourite && state == false) {
        filteredList.removeWhere((character) => character.id == characterId);
        if (actualizeList != null) {
          actualizeList();
        }
      } else if (alreadyContainsFavourite == false) {
        filteredList.add(characterById!);
      }
    } else {
      filteredList = [];
    }

    client.store!.put("filteredList", json.encode(filteredList));
  }

  //todo: encapsulate somewhere
  bool getFavouriteCharacterStateById(int characterId) => Prefs.getBool(characterId.toString());

  //todo: encapsulate somewhere
  List<Character> getFavouriteCharactersState() {
    String characterListAsString = client.getDataFromStore("filteredList") ?? "";

    List<Map<String, dynamic>> characterStringList =
        characterListAsString.isNotEmpty ? (List<Map<String, dynamic>>.from(json.decode(characterListAsString))) : [];

    return characterStringList.map((json) => Character.fromJson(json)).toList();
  }

  @override
  List<Character>? filterListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch) {
    List<Character> mergeFavouritesCharacterFromStore = _mergeFavouritesCharacterFromStore();

    switch (listFilterMode) {
      case ListFilterMode.none:
        if (shouldFetch) {
          if (mergedList.isNotEmpty) {
            mergedList.addAll(mergeFavouritesCharacterFromStore);
          } else {
            mergedList = mergeFavouritesCharacterFromStore;
          }
        }
        filteredListByMode
          ..clear()
          ..addAll(mergedList);
        break;
      case ListFilterMode.favourite:
        filteredListByMode = getFavouriteCharactersState();
        // if (filteredListByMode.isNotEmpty) {
        //   filteredListByMode.removeWhere((character) => character.isFavourite == false);
        // } else {
        //   final listFilteredByFavourite = mergedList.where((character) => character.isFavourite == false);
        //   filteredListByMode.addAll(listFilteredByFavourite);
        // }
        break;
      case ListFilterMode.search:
        break;
    }
  }
}
