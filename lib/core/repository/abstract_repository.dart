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

  AbstractRepository(List<Service> serviceList)
      : sources = serviceList,
        _controller = StreamController<Service>.broadcast() {
    for (var source in sources) {
      source.stream.listen(broadcast);
    }
  }

  @protected
  void emit(Service event) => _controller.sink.add(event);

  @protected
  void broadcast(Service source);

  @protected
  void registerServices();

  @protected
  void unregisterServices();
}
