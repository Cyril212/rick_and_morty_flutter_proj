import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_source.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

/// Used to communicate between VM and Manager
abstract class AbstractRepository<R extends ResponseDataModel> {
  final StreamController<Serivce> _controller;

  Stream<Serivce> get result => _controller.stream;

  @protected
  List<Serivce> sources = [];

  AbstractRepository(List<Serivce> sourceList)
      : sources = sourceList,
        _controller = StreamController<Serivce>.broadcast() {
    for (var source in sources) {
      source.stream.listen(onResponse);
    }
  }

  void emit(Serivce event) => _controller.sink.add(event);

  @protected
  Future<Serivce> fetchResult();

  @protected
  void onResponse(Serivce source);

  @protected
  void registerServices();

  @protected
  void unregisterServices();
}
