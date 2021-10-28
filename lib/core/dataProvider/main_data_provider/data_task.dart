import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';

import '../main_data_provider.dart';

abstract class DataTaskOptions {
  /// DataTaskOptions initialization
  const DataTaskOptions();
}

enum HTTPType {
  Get,
  Post,
}

class HTTPTaskOptions extends DataTaskOptions {
  final HTTPType type;
  final String? url;
  final Map<String, String>? headers;
  final Map<String, dynamic> Function(String body)? processBody;

  /// HTTPTaskOptions initialization
  const HTTPTaskOptions({
    required this.type,
    this.url,
    this.headers,
    this.processBody,
  });
}

class DataTask<T extends DataModel, R extends DataModel> {
  final String method;
  final DataTaskOptions options;
  final MockUpTaskOptions? mockUpTaskOptions;
  final DataModel data;
  final R? Function(Map<String, dynamic> json) processResult;
  R? result;
  SourceException? error;
  final List<String>? reFetchMethods;

  /// DataTask initialization
  DataTask({
    required this.method,
    required this.options,
    this.mockUpTaskOptions,
    required this.data,
    required this.processResult,
    this.reFetchMethods,
  });
}

enum MockUpType {
  Query,
}

class MockUpTaskOptions {
  final MockUpType type;
  final bool delayedResult;
  final int minDelayMilliseconds;
  final int maxDelayMilliseconds;
  final String? assetDataPath;

  /// MockUpTaskOptions initialization
  const MockUpTaskOptions({
    required this.type,
    this.delayedResult = false,
    this.minDelayMilliseconds = 200,
    this.maxDelayMilliseconds = 2000,
    this.assetDataPath,
  });
}
