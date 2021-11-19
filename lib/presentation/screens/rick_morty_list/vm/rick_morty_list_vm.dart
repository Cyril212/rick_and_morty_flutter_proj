import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_detail/rick_morty_detail_screen.dart';

import 'list_vm.dart';

/// View model of [RickMortyListScreen]
class RickMortyListVM extends ListVM {

  /// CharacterList repo
  final CharacterListRepository _repository;

  /// Init
  RickMortyListVM(this._repository) : super(_repository);

  @override
  List get currentList => _repository.characterListByMode;

  bool get isBasic => listType == ListType.basic;

  @override
  bool get allowFetch => isBasic && _repository.hasNextPage();

  /// Emits current [state] depending on result of [fetchCharacterList()]
  void getCharacters(bool refreshList) {
    _repository.getCharacterList(listType, refreshList);
  }

  /// Called when list reached the [maxExtend] and allowed to fetch
  @override
  void onEndOfList() {
    if (isBasic) {
      if (_repository.hasNextPage()) {
        isFetching = true;

        getCharacters(true);
      } else {
        isFetching = false;
      }
    }
  }

  /// Locally updates list, in case user changed [ListType] or [isFavourite] value of [Character]
  @override
  void updateList() {
    getCharacters(false);
  }

  /// Sets searchPhrase value
  void _setSearchPhraseIfAvailable(String searchPhrase) => _repository.searchPhrase = searchPhrase;

  /// Sets searchPhrase value and fetches new result
  void updateCharacterListBySearchPhrase(String searchPhrase) {
    _setSearchPhraseIfAvailable(searchPhrase);

    if(listType == ListType.basic) {
      emit(ListEvent(ListState.loading));
      _repository.setDefaultPageAndGetCharacterList();
    } else {
      updateList();
    }
  }

  /// Sets current list
  void setListMode(bool isFilter) {
    //move to func
    if (isFilter) {
      listType = ListType.favourite;
    } else {
      listType = ListType.basic;
    }

    updateList();
  }

  /// Sets favourite character state
  void setFavouriteCharacterState(int characterId, bool state) => _repository.favouritesStorageHelper.putFavouriteCharacterStateById(characterId, state);

  /// Gets favourite character state
  bool getFavouriteCharacterState(int characterId) => _repository.favouritesStorageHelper.getFavouriteCharacterStateById(characterId);
}
