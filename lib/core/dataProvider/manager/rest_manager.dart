import 'dart:convert';

import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:dio/dio.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../service.dart';

enum HttpOperation { post, get, put, delete }

///Fetches and processes data from Http.get request, for more [BaseDataManager]
class RestManager extends BaseDataManager {
  late Dio _dio;

  /// Init
  RestManager({required String baseUrl, required UnauthorizedRequestHandler onUnauthenticatedRequest}) : super(baseUrl) {
    _dio = Dio(BaseOptions(baseUrl: baseUrl))
      ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        // Do something before request is sent
        return handler.next(options); //continue
        // If you want to resolve the request with some custom data，
        // you can resolve a `Response` object eg: `handler.resolve(response)`.
        // If you want to reject the request with a error message,
        // you can reject a `DioError` object eg: `handler.reject(dioError)`
      }, onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
        // If you want to reject the request with a error message,
        // you can reject a `DioError` object eg: `handler.reject(dioError)`
      }, onError: (DioError e, handler) {
        // Do something with response error

        return handler.next(e); //continue
        // If you want to resolve the request with some custom data，
        // you can resolve a `Response` object eg: `handler.resolve(response)`.
      }));
  }

  @override
  Future<Response> post(RequestDataModel dataRequest) async {
    final Response response = await _dio.post(
      dataRequest.method,
      queryParameters: dataRequest.toJson(),
      options: Options(headers: dataRequest.headers),
    );

    return response;
  }

  @override
  Future<Response> put(RequestDataModel dataRequest) async {
    final Response response = await _dio.put(
      dataRequest.method,
      queryParameters: dataRequest.toJson(),
      options: Options(headers: dataRequest.headers),
    );

    return response;
  }

  @override
  Future<Response> delete(RequestDataModel dataRequest) async {
    final Response response = await _dio.delete(
      dataRequest.method,
      queryParameters: dataRequest.toJson(),
      options: Options(headers: dataRequest.headers),
    );

    return response;
  }

  @override
  Future<Response> get(RequestDataModel dataRequest) async {
    final Response response = await _dio.get(
      dataRequest.method,
      queryParameters: dataRequest.toJson(),
      options: Options(headers: dataRequest.headers),
    );

    return response;
  }

  @override
  Future<T> execute<T extends Service>(T dataTask, Store store, HttpOperation operation) async {
    try {
      late Response response;
      switch (operation) {
        case HttpOperation.post:
          response = await post(dataTask.requestDataModel);
          break;
        case HttpOperation.get:
          response = await get(dataTask.requestDataModel);
          break;
        case HttpOperation.put:
          response = await put(dataTask.requestDataModel);
          break;
        case HttpOperation.delete:
          response = await delete(dataTask.requestDataModel);
          break;
      }
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

    broadcastServices(dataTask);

    return dataTask;
  }
}
