import 'dart:collection';
import 'dart:convert';

import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:http/http.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

class RestManager {
  final String baseUrl;


  /// [Sources] registry
  Map<String, DataTask> queries = <String, DataTask>{};

  int idCounter = 0;

  RestManager(this.baseUrl);

  Future<Response> _query(RequestDataModel dataRequest) async {
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

  Future<T> queryData<T extends DataTask>(T dataTask, Store store) async {

    try {
      final Response response = await _query(dataTask.requestDataModel);

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
}
class DataTask<T extends RequestDataModel, R extends ResponseDataModel>{
  /// The identity of this query within the [Manager]
  final String queryId;

  final T requestDataModel;
  final R Function(Map<String, dynamic> json) processResponse;
  R? response;

  SourceException? error;

  DataTask(this.requestDataModel, this.processResponse, RestManager manager, {this.error}) : queryId = manager.generateQueryId().toString();
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
