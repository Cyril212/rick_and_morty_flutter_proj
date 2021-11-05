import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/abstract_manager.dart';

import 'model/request_data_model.dart';
import 'model/response_data_model.dart';
import 'source_exception.dart';

abstract class DataSource<T extends RequestDataModel, R extends ResponseDataModel> {

  /// The identity of this query within the [Manager]
  late String sourceId;

  /// Request of given source
  final T requestDataModel;

  /// Process json to serialize it to object
  final R Function(Map<String, dynamic> json) processResponse;

  /// Response object
  R? response;

  late StreamController<DataSource> _controller;

  Sink<DataSource> get sink => _controller.sink;

  Stream<DataSource> get stream => _controller.stream;

  /// Error object to describe negative use cases
  SourceException? error;

  /// Init
  DataSource(this.requestDataModel, this.processResponse, {this.error}){
    _controller = StreamController<DataSource<T,R>>.broadcast();
  }

  void registerSource(AbstractManager manager) {
    sourceId = manager.registerSource(this).toString();
  }

  void unregisterSource(AbstractManager manager, int sourceId){
    manager.unregisterSource(sourceId);
  }

}
