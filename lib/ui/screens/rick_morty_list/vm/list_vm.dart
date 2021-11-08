import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/rick_morty_detail_screen.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';


///CharacterList states
enum ListState { idle, loading, success, empty, error }

/// List modes
enum ListFilterMode { none, favourite }

/// CharacterListEvent witch contains state and error status to process on UI
class ListEvent {
  final ListState state;
  final SourceException? error;

  const ListEvent(this.state, {this.error});
}
/// View model of [RickMortyListScreen]
abstract class ListVM extends Cubit<ListEvent> {
  /// CharacterList repo
  final AbstractRepository _repository;

  /// Filter mode
  ListFilterMode listFilterMode;

  /// Current character id to retrieve from detail screen
  int? currentCharacterId;

  /// Status to show loading snackbar
  bool isFetching;

  late StreamSubscription listenOnDevice;

  /// Init
  ListVM(this._repository, {this.listFilterMode = ListFilterMode.none, this.isFetching = false})
      : super(const ListEvent(ListState.idle)) {
    registerSource();

    _repository.result.listen((dataSource) {
        if (dataSource.error != null) {
          emit(ListEvent(ListState.error, error: dataSource.error));
        } else {
          if (currentList.isNotEmpty) {
            emit(const ListEvent(ListState.success));
          } else {
            emit(const ListEvent(ListState.empty));
          }
        }
    });
  }

  /// Current List
  List get currentList;

  bool get shouldFetch;

  /// Fetches new characters
  void fetchList();

  /// Locally updates [characterList]
  void updateList();


  void registerSource() {
    _repository.registerServices();
  }

  @override
  Future<void> close() {
    _repository.unregisterServices();
    return super.close();
  }
}
