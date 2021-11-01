import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
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
  int idCounter = 0;

  ///Executes request
  @protected
  Future<Response> query(RequestDataModel dataRequest);

  ///Process data after [query] was executed
  Future<T> processData<T extends DataSource<RequestDataModel,ResponseDataModel>>(T dataTask, Store store);

  ///Increment [idCounter] per [DataSource] initialization
  int generateDataSourceId() {
    final int requestId = idCounter;

    idCounter++;

    return requestId;
  }
}