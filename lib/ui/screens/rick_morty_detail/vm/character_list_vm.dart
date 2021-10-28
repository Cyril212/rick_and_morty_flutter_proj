import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/sources/character_list_source.dart';

class CharacterListVM extends Cubit<CharacterListSource>{
  CharacterListVM(CharacterListSource initialState) : super(initialState);

}