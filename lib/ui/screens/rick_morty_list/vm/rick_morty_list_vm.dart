import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/rick_morty_detail.dart';

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

  void _getCharacters([shouldFetch = true]) {

    emit(const CharacterListEvent(CharacterListState.loading));

    repository.getCharactersWithFavouriteState(listFilterMode, shouldFetch).then((response) {
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

  void updateCharacterList([bool? isFilter]) async {
    isFilter ??= repository.filterListState == ListFilterMode.favourite;

    //move to func
    if (isFilter) {
      listFilterMode = ListFilterMode.favourite;
    } else {
      listFilterMode = ListFilterMode.none;
    }

    await repository.putFilterListState(listFilterMode);

    _getCharacters(false);
  }

  void setFavouriteCharacterState(int characterId, bool state) => repository.putFavouriteCharacterStateById(characterId, state);

  void getFavouriteCharacterState(character) => repository.getFavouriteCharacterStateById(character.id);

  void moveToDetailScreen(BuildContext context) => pushNamed(context, RickMortyDetailScreen.route);
}
