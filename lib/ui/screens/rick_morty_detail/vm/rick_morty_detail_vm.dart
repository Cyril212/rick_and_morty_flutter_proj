import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class RickMortyDetailVM extends Cubit {
  RickMortyDetailVM() : super(null);

  /// Gets character id from parent [RickMortyListVM] bloc
  Character? getCharacterById(BuildContext context) {
    final rickMortyListVMReference = context.read<RickMortyListVM>();
    return rickMortyListVMReference.currentList.firstWhereOrNull((character) => character.id == rickMortyListVMReference.currentCharacterId);
  }
}
