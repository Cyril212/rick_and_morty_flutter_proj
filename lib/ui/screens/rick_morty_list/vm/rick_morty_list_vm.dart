import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/rick_morty_detail_screen.dart';

///CharacterList states
enum CharacterListState { idle, loading, success, empty, error }

/// List modes
enum ListFilterMode { none, favourite }

/// CharacterListEvent witch contains state and error status to process on UI
class CharacterListEvent {
  final CharacterListState state;
  final SourceException? error;

  const CharacterListEvent(this.state, {this.error});
}

/// View model of [RickMortyListScreen]
class RickMortyListVM extends Cubit<CharacterListEvent> {
  /// CharacterList repo
  final CharacterListRepository _repository;

  /// Filter mode
  ListFilterMode listFilterMode;

  /// Current character id to retrieve from detail screen
  int? currentCharacterId;

  /// Status to show loading snackbar
  bool isFetching;

  late StreamSubscription listenOnDevice;

  /// Init
  RickMortyListVM(this._repository, {this.listFilterMode = ListFilterMode.none, this.isFetching = false})
      : super(const CharacterListEvent(CharacterListState.idle)) {
    registerSource();

    _repository.result.listen((dataSource) {
        if (_repository.error != null) {
          emit(CharacterListEvent(CharacterListState.error, error: _repository.error));
        } else {
          if (characterList.isNotEmpty) {
            emit(const CharacterListEvent(CharacterListState.success));
          } else {
            emit(const CharacterListEvent(CharacterListState.empty));
          }
        }
    });
  }

  /// Current List
  List<Character> get characterList => _repository.characterListByMode;

  bool get isSearchPhraseEmpty => _repository.searchPhrase?.isEmpty ?? true;

  bool get isFavouriteState => listFilterMode == ListFilterMode.favourite;

  /// Emits current [state] depending on result of [fetchCharacterList()]
  void _getCharacters([shouldFetch = true]) {
    emit(const CharacterListEvent(CharacterListState.loading));

    _repository.fetchCharacterList(listFilterMode, shouldFetch);
  }



  /// Fetches new characters
  void fetchCharacterList() => _getCharacters(true);

  /// Locally updates [characterList]
  void updateCharacterList() => _getCharacters(false);

  /// Sets searchPhrase value
  void setSearchPhraseIfAvailable(String searchPhrase) => _repository.searchPhrase = searchPhrase;

  /// Sets searchPhrase value and locally update list
  void updateCharacterListBySearchPhrase(String searchPhrase) {
    setSearchPhraseIfAvailable(searchPhrase);
    updateCharacterList();
  }

  /// Sets current list
  void setFilterMode(bool isFilter) {
    //move to func
    if (isFilter) {
      listFilterMode = ListFilterMode.favourite;
    } else {
      listFilterMode = ListFilterMode.none;
    }
    updateCharacterList();
  }

  /// Sets favourite character state
  void setFavouriteCharacterState(int characterId, bool state) => _repository.putFavouriteCharacterStateById(characterId, state);

  /// Gets favourite character state
  bool getFavouriteCharacterState(int characterId) => _repository.getFavouriteCharacterStateById(characterId);

  /// Redirects to detail screen
  void moveToDetailScreen(BuildContext context) => pushNamed(context, RickMortyDetailScreen.route);

  void registerSource() {
    _repository.registerSources();
  }

  @override
  Future<void> close() {
    _repository.unregisterSources();
    return super.close();
  }
}
