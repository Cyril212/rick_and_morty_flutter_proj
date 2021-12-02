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

  bool get isBasic => listType == ListType.basic;

  @override
  bool get isInitialLoading => (_repository.characterListService.requestDataModel.pageNum == 1) && state.listState == ListState.loading;

  @override
  List get characterList => _repository.currentList;

  @override
  bool get allowFetch => isBasic && _repository.characterListsMediator.hasNextPage();

  /// Emits current [state] depending on result of [fetchCharacterList()]
  void getCharacters({bool shouldFetch = true}) {
    if (shouldFetch) {
      emit(ListEvent(ListState.loading));
    }
    _repository.getCharacterList(listType: listType, shouldFetch: shouldFetch);
  }

  /// Called when list reached the [maxExtend] and allowed to fetch
  @override
  void onEndOfList() {
    if (isBasic) {
      if (_repository.characterListsMediator.hasNextPage()) {
        isNextPageFetching = true;

        getCharacters();
      } else {
        isNextPageFetching = false;
      }
    }
  }

  /// Locally updates list, in case user changed [ListType] or [isFavourite] value of [Character]
  @override
  void updateList() {
    getCharacters(shouldFetch: false);
  }

  /// Sets searchPhrase value and fetches new result
  void getCharacterListBySearchPhrase(String searchPhrase) {
    switch (listType) {
      case ListType.basic:
        emit(ListEvent(ListState.loading));
        _repository.getCharacterListBySearchPhrase(searchPhrase: searchPhrase);
        break;
      case ListType.favourite:
        _repository.getCharacterListBySearchPhrase(listFilterType: ListType.favourite, searchPhrase: searchPhrase);
        break;
    }
  }

  /// Sets current list
  void setListMode(bool isFilter) {
    if (isFilter) {
      listType = ListType.favourite;
    } else {
      listType = ListType.basic;
    }

    updateList();
  }

  /// Sets favourite character state
  void setFavouriteCharacterState(int characterId, bool state) =>
      _repository.characterListsMediator.characterStorageHelper.putFavouriteCharacterStateById(characterId, state);
}
