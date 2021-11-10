import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/rick_morty_detail_screen.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';

/// View model of [RickMortyListScreen]
class RickMortyListVM extends ListVM {
  /// CharacterList repo
  final CharacterListRepository _repository;

  /// Init
  RickMortyListVM(this._repository) : super(_repository);

  @override
  List get currentList => _repository.characterListByMode;

  bool get isBasic => listType == ListType.basic;

  bool get isSearchPhraseEmpty => _repository.searchPhrase?.isEmpty ?? true;

  @override
  bool get shouldFetch => isBasic && isSearchPhraseEmpty;

  /// Emits current [state] depending on result of [fetchCharacterList()]
  void getCharacters() {
    _repository.getCharacterList(listType);
  }

  @override
  void onEndOfList() {
    if (isBasic) {
      if (_repository.hasNextPage()) {
        emit(const ListEvent(ListState.loading));
        getCharacters();
      }
    }
  }

  @override
  void updateList() {
    getCharacters();
  }

  /// Sets searchPhrase value
  void setSearchPhraseIfAvailable(String searchPhrase) => _repository.searchPhrase = searchPhrase;

  /// Sets searchPhrase value and locally update list
  void updateCharacterListBySearchPhrase(String searchPhrase) {
    setSearchPhraseIfAvailable(searchPhrase);

    if(listType == ListType.basic) {
      emit(const ListEvent(ListState.loading));
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
  void setFavouriteCharacterState(int characterId, bool state) => _repository.putFavouriteCharacterStateById(characterId, state);

  /// Gets favourite character state
  bool getFavouriteCharacterState(int characterId) => _repository.getFavouriteCharacterStateById(characterId);

  /// Redirects to detail screen
  void moveToDetailScreen(BuildContext context) => pushNamed(context, RickMortyDetailScreen.route);
}
