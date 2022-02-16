import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/rick_morty_detail_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class RickMortyDetailVM extends Cubit {
  final RickMortyDetailRepository _repository;
  late Character currentCharacter;

  RickMortyDetailVM(DataClient dataClient)
      : _repository = RickMortyDetailRepository(dataClient),
        super(null);

  /// Gets character id from parent [RickMortyListVM] bloc
  Character? getCharacterById(BuildContext context, int characterId) {
    currentCharacter = _repository.getCharacter(characterId);
    return null;
  }

  void setFavouriteCharacterState(bool isChosen) {
    _repository.setFavouriteCharacter(currentCharacter, isChosen);
  }

  @override
  Future<void> close() {
    _repository.unregisterSources();
    return super.close();
  }
}
