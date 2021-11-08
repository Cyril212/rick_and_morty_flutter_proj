import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../data_source.dart';
import '../model/request_data_model.dart';
import '../model/response_data_model.dart';
import 'package:http/http.dart';

///Used for fetching data from defined client
abstract class AbstractManager {

  ///Default Endpoint
  String baseUrl;

  ///Init
  AbstractManager(this.baseUrl);

  ///Counter for query id for debug purposes
  int sourceCounter = 0;

  Map<int, Serivce> sources = {};

  ///Executes request
  @protected
  Future<Response> query(RequestDataModel dataRequest);

  ///Process data after [query] was executed
  Future<T> processData<T extends Serivce<RequestDataModel,ResponseDataModel>>(T dataTask, Store store);

  ///Increment [sourceCounter] per [Serivce] initialization
  int generateDataSourceId() {
    final int requestId = sourceCounter;

    sourceCounter++;

    return requestId;
  }

  int registerSource(Serivce dataSource) {
   sources.putIfAbsent(sourceCounter, () => dataSource);

   return generateDataSourceId();
  }

  @protected
  void refreshSimilarSourcesByMethod(Serivce task) {
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