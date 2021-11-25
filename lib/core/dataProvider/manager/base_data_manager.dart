import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../model/request_data_model.dart';
import 'package:dio/dio.dart';

import '../service.dart';

///Used for fetching data from defined client
abstract class BaseDataManager {

  ///Default Endpoint
  String baseUrl;

  ///Init
  BaseDataManager(this.baseUrl);

  ///Counter for query id for debug purposes
  int serviceCounter = 0;

  Map<int, Service> sources = {};

  ///Executes request
  @protected
  Future<Response> post(RequestDataModel dataRequest);

  @protected
  Future<Response> get(RequestDataModel dataRequest);

  @protected
  Future<Response> put(RequestDataModel dataRequest);

  @protected
  Future<Response> delete(RequestDataModel dataRequest);

  ///Process data after [query] was executed
  Future<T> execute<T extends Service>(T dataTask, Store store, HttpOperation operation);

  ///Increment [serviceCounter] per [Service] initialization
  int generateDataSourceId() {
    final int requestId = serviceCounter;

    serviceCounter++;

    return requestId;
  }

  int registerService(Service dataSource) {
   sources.putIfAbsent(serviceCounter, () => dataSource);

   return generateDataSourceId();
  }

  @protected
  void broadcastServices(Service task) {
     sources.forEach((id, value) {
       if(value.requestDataModel.toJson() == task.requestDataModel.toJson()){
          if(id != int.parse(task.serviceId)){//make sure we don't update source which was already fetched
            value.sink.add(task);
          }
       }
     });
  }

 void unregisterService(int serviceId) => sources.removeWhere((key, value) => serviceId == key);
}