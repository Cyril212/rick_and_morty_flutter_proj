import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../model/request_data_model.dart';
import '../model/response_data_model.dart';
import 'package:http/http.dart';

import '../service.dart';

///Used for fetching data from defined client
abstract class AbstractManager {

  ///Default Endpoint
  String baseUrl;

  ///Init
  AbstractManager(this.baseUrl);

  ///Counter for query id for debug purposes
  int sourceCounter = 0;

  Map<int, Service> sources = {};

  ///Executes request
  @protected
  Future<Response> query(RequestDataModel dataRequest);

  ///Process data after [query] was executed
  Future<T> processData<T extends Service<RequestDataModel,ResponseDataModel>>(T dataTask, Store store);

  ///Increment [sourceCounter] per [Service] initialization
  int generateDataSourceId() {
    final int requestId = sourceCounter;

    sourceCounter++;

    return requestId;
  }

  int registerSource(Service dataSource) {
   sources.putIfAbsent(sourceCounter, () => dataSource);

   return generateDataSourceId();
  }

  @protected
  void refreshSimilarSourcesByMethod(Service task) {
     sources.forEach((id, value) {
       if(value.requestDataModel.method == task.requestDataModel.method){
          if(id != int.parse(task.sourceId)){//make sure we don't update source which was already fetched
            value.sink.add(task);
          }
       }
     });
  }

 void unregisterSource(int sourceId) => sources.removeWhere((key, value) => sourceId == key);
}