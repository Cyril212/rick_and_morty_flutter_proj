import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character_list_response.dart';

enum RepositoryNotifyState { service, store }

/// Used to communicate between VM and Manager
abstract class BaseRepository {
  final BaseDataClient client;

  ///Controller to allow broadcasting services
  final List<StreamSubscription> _serviceSubscriptions;

  ///Controller to allow broadcasting store operations(put,delete,reset) by [dataId]
  final List<StreamSubscription> _storeSubscriptions;

  ///Controller to update VM
  final StreamController<RepositoryNotifyState> _repositoryNotifier;

  @protected
  final List<Service> services = [];

  Stream<RepositoryNotifyState> get result => _repositoryNotifier.stream;

  Service get mainService => services[0];

  BaseRepository({required this.client, List<Service>? serviceList, List<String>? storageIdList})
      : _serviceSubscriptions = [],
        _storeSubscriptions = [],
        _repositoryNotifier = StreamController<RepositoryNotifyState>() {
    if (serviceList != null) {
      services.addAll(serviceList);

      for (var service in services) {
        final serviceSubscription = service.stream.listen(onBroadcastDataFromService);
        _serviceSubscriptions.add(serviceSubscription);

        service.registerService(client.manager);
      }
    }

    if (storageIdList != null) {
      for (var storageId in storageIdList) {
        final storeSubscription = client.broadcastDataFromStore(storageId).listen(onBroadcastDataFromStore);
        _storeSubscriptions.add(storeSubscription);
      }
    }
  }

  ///Emits service to process in vm
  @protected
  void notify(RepositoryNotifyState state) => _repositoryNotifier.sink.add(state);

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
  void onBroadcastDataFromStore(String dataId) {}

  void _unregisterController() {
    _repositoryNotifier.close();
  }

  void _unregisterServices() {
    for (var service in services) {
      service.unregisterService(client.manager, int.parse(service.serviceId));
    }
    for (var subscription in _serviceSubscriptions) {
      subscription.cancel();
    }
  }

  void _unregisterStore() {
    for (var subscription in _storeSubscriptions) {
      subscription.cancel();
    }
  }

  void unregisterSources() {
    _unregisterServices();
    _unregisterStore();
    _unregisterController();
  }
}
