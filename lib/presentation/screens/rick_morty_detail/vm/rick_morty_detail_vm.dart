import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/rick_morty_detail_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class RickMortyDetailVM extends Cubit {
  final RickMortyDetailRepository repository;

  RickMortyDetailVM(DataClient dataClient)
      : repository = RickMortyDetailRepository(dataClient),
        super(null);

  Character? currentCharacter;

  /// Gets character id from parent [RickMortyListVM] bloc
  Character? getCharacterById(BuildContext context, int characterId) {
    currentCharacter = repository.getCharacter(characterId);
  }

  void setFavouriteCharacterState(bool isChosen) {
    repository.setFavouriteCharacter(currentCharacter!.id, state);
  }

}
