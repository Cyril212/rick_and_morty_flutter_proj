import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

import 'cache_handler.dart';
import 'model/request_data_model.dart';
import 'model/response_data_model.dart';
import 'source_exception.dart';

abstract class Service<T extends RequestDataModel, R extends ResponseDataModel, C extends CacheHandler> {
  /// The identity of this query within the [Manager]
  late String serviceId;

  final C cache;

  /// Request of given source
  final T requestDataModel;

  /// Process json to serialize it to object
  final R Function(Map<String, dynamic> json) processResponse;

  /// Response object
  R? response;

  late StreamController<R> _controller;

  Sink<R> get sink => _controller.sink;

  Stream<R> get stream => _controller.stream;

  /// Init
  Service(this.requestDataModel, this.processResponse, this.cache) {
    _controller = StreamController<R>();
  }

  void registerService(BaseDataManager manager) {
    serviceId = manager.registerService(this).toString();
  }

  void unregisterService(BaseDataManager manager, int serviceId) {
    manager.unregisterService(serviceId);
  }
}
