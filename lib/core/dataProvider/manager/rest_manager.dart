import 'dart:convert';

import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/abstract_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:dio/dio.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../service.dart';

///Fetches and processes data from Http.get request, for more [AbstractManager]
class RestManager extends AbstractManager {

  late Dio _dio;

  /// Init
  RestManager(baseUrl) : super(baseUrl){
    _dio = Dio(BaseOptions(baseUrl: baseUrl));
  }

  @override
  Future<Response> query(RequestDataModel dataRequest) async {
    final Response response = await _dio.get(
      dataRequest.method,
      queryParameters: dataRequest.toJson(),
      options: Options(headers: dataRequest.headers),
    );

    return response;
  }

  @override
  Future<T> processData<T extends Service>(T dataTask, Store store) async {
    try {
      final Response response = await query(dataTask.requestDataModel);

      if (response.statusCode! >= 400) {
        dataTask.error = SourceException(
          originalException: null,
          httpStatusCode: response.statusCode,
        );
      } else {
        final rawResponse = response.data;
        dataTask.response = dataTask.processResponse(rawResponse);

        dataTask.error = null;
      }

    } catch (e) {
      dataTask.error = SourceException(originalException: e);
    }

    dataTask.sink.add(dataTask);

    refreshSimilarSourcesByMethod(dataTask);

    return dataTask;
  }

}


