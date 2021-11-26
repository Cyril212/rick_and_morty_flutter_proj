import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

/// Used to communicate between VM and Manager
abstract class BaseRepository {
  final BaseDataClient client;

  ///Controller to update VM
  final StreamController<void> _resultController;

  ///Controller to allow broadcasting services
  StreamController<ResponseDataModel>? _serviceController;

  ///Controller to allow broadcasting store operations(put,delete,reset) by [dataId]
  StreamController<String>? _storeController;

  ///Result of serviceBroadcast
  Stream get result => _resultController.stream;

  ///Result of serviceBroadcast
  Stream<ResponseDataModel>? get serviceBroadcastResult => _serviceController?.stream;

  ///Result of storeBroadcast
  Stream<String>? get storeBroadcastResult => _storeController?.stream;

  @protected
  List<Service> services = [];

  Service get mainService => services[0];

  BaseRepository({required this.client, List<Service>? serviceList, List<String>? dataIdList}) : _resultController = StreamController() {
    if (serviceList != null) {
      services = serviceList;

      _serviceController = StreamController<ResponseDataModel>();

      for (var service in services) {
        service.stream.listen(onBroadcastDataFromService);
      }
    }

    if (dataIdList != null) {
      _storeController = StreamController<String>();

      for (var dataId in dataIdList) {
        client.broadcastDataFromStore(dataId).listen(onBroadcastDataFromStore);
      }
    }
  }

  ///Emits service to process in vm
  @protected
  void notify() => _resultController.sink.add(null);

  /// Broadcasts actual services
  @protected
  void onBroadcastDataFromService(ResponseDataModel response) {
    for (var currentService in services) {
      if (currentService.response.runtimeType == response.runtimeType) {
        currentService.response = response;
      }
    }
  }

  @protected
  void onBroadcastDataFromStore(String dataId);

  void registerSources() {
    if (_serviceController != null) {
      for (var element in services) {
        element.registerService(client.manager);
      }
    }
  }

  void _unregisterControllers() {
    _resultController.close();
    _serviceController?.close();
    _storeController?.close();
  }

  void unregisterSources() {
    for (var element in services) {
      element.unregisterService(client.manager, int.parse(element.serviceId));
    }
    _unregisterControllers();
  }
}
