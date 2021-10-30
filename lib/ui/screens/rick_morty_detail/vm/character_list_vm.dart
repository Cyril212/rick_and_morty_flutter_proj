import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_list_response.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';

enum CharacterListState { idle, loading, success, error }
enum ListFilterMode {
  none,
  favourite
}

class CharacterListEvent {
  final CharacterListState state;
  final List<Character>? characterList;
  final SourceException? error;

  const CharacterListEvent(this.state, {this.characterList, this.error});
}

class CharacterListVM extends Cubit<CharacterListEvent> {
  final CharacterListRepository repository;
  ListFilterMode listFilterMode;

  CharacterListVM(this.repository, {this.listFilterMode = ListFilterMode.none}) : super(const CharacterListEvent(CharacterListState.idle));

  void _getCharacters([shouldFetch = true]) {
    emit(const CharacterListEvent(CharacterListState.loading));

    repository.getCharactersWithFavouriteState(listFilterMode, shouldFetch).then((response) {
      if (repository.error != null) {
        emit(CharacterListEvent(CharacterListState.error, error: repository.error));
      } else {
        emit(CharacterListEvent(CharacterListState.success, characterList: response));
      }
    });
  }

  void fetchCharacterList(){
    _getCharacters(true);
  }

  void updateCharacterList(bool isFilter){
    if(isFilter){
      listFilterMode = ListFilterMode.favourite;
    } else {
      listFilterMode = ListFilterMode.none;
    }
    _getCharacters(false);
  }

  void setFavouriteForCharacter(int characterId, bool state) => repository.putCharacterToStoreById(characterId, state);

  void getFavouriteCharacterState(character) => repository.getFavouriteCharacterStateById(character.id);
}
