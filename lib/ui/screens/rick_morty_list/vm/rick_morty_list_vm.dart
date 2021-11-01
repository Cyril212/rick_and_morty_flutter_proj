import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/rick_morty_detail_screen.dart';

enum CharacterListState { idle, loading, success, empty, error }
enum ListFilterMode { none, favourite }

class CharacterListEvent {
  final CharacterListState state;
  final SourceException? error;

  const CharacterListEvent(this.state, {this.error});
}

class RickMortyListVM extends Cubit<CharacterListEvent> {
  final CharacterListRepository repository;

  ListFilterMode listFilterMode;
  int? currentCharacterId;
  bool isFetching;

  RickMortyListVM(this.repository, {this.listFilterMode = ListFilterMode.none, this.isFetching = false})
      : super(const CharacterListEvent(CharacterListState.idle));

  List<Character> get characterList => repository.characterListByMode;

  bool get isSearchPhraseEmpty => repository.searchPhrase?.isEmpty ?? true;

  bool get isFavouriteState => listFilterMode == ListFilterMode.favourite;

  void _getCharacters([shouldFetch = true]) {

    emit(const CharacterListEvent(CharacterListState.loading));

    repository.fetchCharacterList(listFilterMode, shouldFetch).then((response) {
      if (repository.error != null) {
        emit(CharacterListEvent(CharacterListState.error, error: repository.error));
      } else {
        if (repository.characterListByMode.isNotEmpty) {
          emit(const CharacterListEvent(CharacterListState.success));
        } else {
          emit(const CharacterListEvent(CharacterListState.empty));
        }
      }
    });
  }

  void fetchCharacterList() => _getCharacters(true);

  void updateCharacterList() =>
    _getCharacters(false);

  void setSearchPhraseIfAvailable(String searchPhrase)=>
      repository.searchPhrase = searchPhrase;

  void updateCharacterListBySearchPhrase(String searchPhrase){
    setSearchPhraseIfAvailable(searchPhrase);
    updateCharacterList();
  }


  void setFilterMode(bool isFilter){
    //move to func
    if (isFilter) {
      listFilterMode = ListFilterMode.favourite;
    } else {
      listFilterMode = ListFilterMode.none;
    }
    updateCharacterList();
  }

  void setFavouriteCharacterState(int characterId, bool state,{VoidCallback? shouldActualizeList}) => repository.putFavouriteCharacterStateById(characterId, state, shouldActualizeList);

  bool getFavouriteCharacterState(int characterId) => repository.getFavouriteCharacterStateById(characterId);

  void moveToDetailScreen(BuildContext context) => pushNamed(context, RickMortyDetailScreen.route);
}
