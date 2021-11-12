import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';

/// Used to communicate between VM and Manager
abstract class AbstractRepository<R extends ResponseDataModel> {

  ///Controller to allow broadcasting services
  final StreamController<Service> _controller;

  ///Result of current [emit]
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

  ///Emits service to process in vm
  @protected
  void emit(Service service) => _controller.sink.add(service);

  /// Broadcasts actual services
  @protected
  void broadcast(Service service);

  /// Registers services
  void registerServices();

  /// Unregisters services
  void unregisterServices();
}
