import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';

import '../main_data_provider.dart';

class DataSource<T extends DataModel> {
  String get identifier {
    String identifier = method;

   final requestAsJson = request.toJson();
    if (requestAsJson.isNotEmpty) {
      for (String key in requestAsJson.keys) {
        identifier += '_${key}_${requestAsJson[key]}';
      }
    }

    return identifier;
  }

  bool get isCollection => true;

  final MainDataProviderSource source;
  MainDataProviderSource? sourceRegisteredTo;
  final MockUpRequestOptions? mockUpRequestOptions;
  final String method;
  final RequestDataModel request;
  final T? Function(Map<String, dynamic> json) processResponse;
  T? result;
  SourceException? error;

  /// DataRequest initialization
  DataSource({
    required this.source,
    this.mockUpRequestOptions,
    required this.method,
    required this.request,
    required this.processResponse,
  });
}

class MockUpRequestOptions {
  final bool delayedResult;
  final int minDelayMilliseconds;
  final int maxDelayMilliseconds;
  final String? assetDataPath;

  /// MockUpRequestOptions initialization
  const MockUpRequestOptions({
    this.delayedResult = false,
    this.minDelayMilliseconds = 200,
    this.maxDelayMilliseconds = 2000,
    this.assetDataPath,
  });
}
