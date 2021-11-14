import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/abstract_manager.dart';

import 'model/request_data_model.dart';
import 'model/response_data_model.dart';
import 'source_exception.dart';

abstract class Service<T extends RequestDataModel, R extends ResponseDataModel> {

  /// The identity of this query within the [Manager]
  late String serviceId;

  /// Request of given source
  final T requestDataModel;

  /// Process json to serialize it to object
  final R Function(Map<String, dynamic> json) processResponse;

  /// Response object
  R? response;

  late StreamController<Service> _controller;

  Sink<Service> get sink => _controller.sink;

  Stream<Service> get stream => _controller.stream;

  /// Error object to describe negative use cases
  SourceException? error;

  /// Init
  Service(this.requestDataModel, this.processResponse, {this.error}){
    _controller = StreamController<Service<T,R>>.broadcast();
  }

  void registerService(AbstractManager manager) {
    serviceId = manager.registerService(this).toString();
  }

  void unregisterSource(AbstractManager manager, int serviceId){
    manager.unregisterService(serviceId);
  }

}
