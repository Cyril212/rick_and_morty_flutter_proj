import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_source.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

/// Used to communicate between VM and Manager
abstract class AbstractRepository<R extends ResponseDataModel> {
  final StreamController<DataSource> _controller;

  Stream<DataSource> get result => _controller.stream;

  @protected
  List<DataSource> sources = [];

  AbstractRepository(List<DataSource> sourceList)
      : sources = sourceList,
        _controller = StreamController<DataSource>.broadcast() {
    for (var source in sources) {
      source.stream.listen(onResponse);
    }
  }

  void emit(DataSource event) => _controller.sink.add(event);

  @protected
  Future<DataSource> fetchResult();

  @protected
  void onResponse(DataSource source);

  @protected
  void registerSources();

  @protected
  void unregisterSources();
}
