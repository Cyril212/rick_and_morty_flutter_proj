import 'dart:convert';

import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/abstract_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:http/http.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../service.dart';

///Fetches and processes data from Http.get request, for more [AbstractManager]
class RestManager extends AbstractManager {

  /// Init
  RestManager(baseUrl): super(baseUrl);

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

  @override
  Future<T> processData<T extends Service>(T dataTask, Store store) async {
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

        store.put(dataTask.sourceId, rawResponse);
      }

    } catch (e) {
      dataTask.error = SourceException(originalException: e);
    }

    dataTask.sink.add(dataTask);

    refreshSimilarSourcesByMethod(dataTask);

    return dataTask;
  }

}


