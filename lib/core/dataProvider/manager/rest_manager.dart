import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:dio/dio.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../service.dart';

///Fetches and processes data from Http.get request, for more [BaseDataManager]
class RestManager extends BaseDataManager {

  late Dio _dio;

  /// Init
  RestManager({required String baseUrl, required UnauthorizedRequestHandler onUnauthenticatedRequest}) : super(baseUrl){

    _dio = Dio(BaseOptions(baseUrl: baseUrl))..interceptors.add(InterceptorsWrapper(
        onRequest:(options, handler){
          // Do something before request is sent
          return handler.next(options); //continue
          // If you want to resolve the request with some custom data，
          // you can resolve a `Response` object eg: `handler.resolve(response)`.
          // If you want to reject the request with a error message,
          // you can reject a `DioError` object eg: `handler.reject(dioError)`
        },

        onResponse:(response,handler) {
          // Do something with response data
          return handler.next(response); // continue
          // If you want to reject the request with a error message,
          // you can reject a `DioError` object eg: `handler.reject(dioError)`
        },

        onError: (DioError e, handler) {
          // Do something with response error

          return  handler.next(e);//continue
          // If you want to resolve the request with some custom data，
          // you can resolve a `Response` object eg: `handler.resolve(response)`.
        }
    ));
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

    broadcastServicesByMethod(dataTask);

    return dataTask;
  }

}

