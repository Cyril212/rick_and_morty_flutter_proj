import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/unique_event.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';


///CharacterList states
enum ListState { idle, loading, success, empty, error }

/// List modes
enum ListType { basic, favourite }

/// CharacterListEvent witch contains state and error status to process on UI
class ListEvent extends UniqueEvent {
  final ListState state;
  final SourceException? error;

  ListEvent(this.state, {this.error});
}

/// View model of [RickMortyListScreen]
abstract class ListVM extends Cubit<ListEvent> {
  /// CharacterList repo
  final AbstractRepository _repository;

  /// Filter mode
  ListType listType;

  /// Current character id to retrieve from detail screen
  int? currentCharacterId;

  late StreamSubscription listenOnDevice;

  bool isFetching = false;

  /// Init
  ListVM(this._repository, {this.listType = ListType.basic})
      : super(ListEvent(ListState.idle)) {
    registerSource();

    _repository.result.listen((dataSource) {

      //to make bloc builder receive the same state
        if (dataSource.error != null) {
          emit(ListEvent(ListState.error, error: dataSource.error));
        } else {
          if (currentList.isNotEmpty) {
            emit(ListEvent(ListState.success));
          } else {
            emit(ListEvent(ListState.empty));
          }
        }
    });
  }

  /// Current List
  List get currentList;

  bool get allowFetch;

  /// Called when list reached the [maxExtend] and allowed to fetch
  void onEndOfList();

  /// Locally updates [currentList]
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
