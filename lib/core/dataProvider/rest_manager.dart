import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:http/http.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
abstract class AbstractManager {
  String baseUrl;

  AbstractManager(this.baseUrl);

  /// [Sources] registry
  Map<String, DataSource> queries = <String, DataSource>{};

  int idCounter = 0;

  @protected
  Future<Response> query(RequestDataModel dataRequest);

  Future<T> processData<T extends DataSource<RequestDataModel,ResponseDataModel>>(T dataTask, Store store);
}
class RestManager extends AbstractManager {

  RestManager(baseUrl): super(baseUrl);

  @override
  Future<T> processData<T extends DataSource>(T dataTask, Store store) async {
    try {
      final Response response = await query(dataTask.requestDataModel);

      if (response.statusCode >= 400) {
        dataTask.error = SourceException(
          originalException: null,
          httpStatusCode: response.statusCode,
        );
      } else{
        final rawResponse = jsonDecode(response.body);
        dataTask.response = dataTask.processResponse(rawResponse);

        store.put(dataTask.queryId, rawResponse);
      }

    } catch (e) {
      dataTask.error = SourceException(originalException: e);
    }

    return dataTask;
  }

  int generateQueryId() {
    final int requestId = idCounter;

    idCounter++;

    return requestId;
  }

  @override
  Future<Response> query(RequestDataModel dataRequest) async {
    final List<String> values = [];

    dataRequest.toJson().forEach((key, value) {
      values.add('$key=$value');
    });

    final String url = '${baseUrl}${dataRequest.method}?${values.join('&')}';

    final Response response = await get(
      Uri.parse(url),
      headers: dataRequest.headers,
    );

    return response;
  }

}
class DataSource<T extends RequestDataModel, R extends ResponseDataModel> {
  /// The identity of this query within the [Manager]
  final String queryId;

  final T requestDataModel;
  final R Function(Map<String, dynamic> json) processResponse;
  R? response;

  SourceException? error;

  DataSource(this.requestDataModel, this.processResponse, RestManager manager, {this.error}) : queryId = manager.generateQueryId().toString();
}

class SourceException {
  final Object? originalException;
  final int? httpStatusCode;

  /// SourceException initialization
  SourceException({
    required this.originalException,
    this.httpStatusCode,
  });
}
