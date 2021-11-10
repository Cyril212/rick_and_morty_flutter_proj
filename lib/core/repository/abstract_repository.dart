import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';

/// Used to communicate between VM and Manager
abstract class AbstractRepository<R extends ResponseDataModel> {
  final StreamController<Service> _controller;

  Stream<Service> get result => _controller.stream;

  @protected
  List<Service> sources = [];

  AbstractRepository(List<Service> sourceList)
      : sources = sourceList,
        _controller = StreamController<Service>.broadcast() {
    for (var source in sources) {
      source.stream.listen(onResponse);
    }
  }

  void emit(Service event) => _controller.sink.add(event);

  @protected
  Future<Service> fetchResult();

  @protected
  void onResponse(Service source);

  void registerServices();

  void unregisterServices();
}
