import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class RickMortyDetailVM extends Cubit {
  RickMortyDetailVM() : super(null);

 Character? getCharacterById(BuildContext context) {
    final rickMortyListVMReference = context.read<RickMortyListVM>();

    return rickMortyListVMReference.characterList.firstWhere((character) => character.id == rickMortyListVMReference.currentCharacterId);
  }
}
