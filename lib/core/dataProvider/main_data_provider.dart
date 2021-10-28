import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'main_data_provider/data_request.dart';
import 'main_data_provider/data_task.dart';
import 'main_data_provider/main_data_source.dart';
import 'model/data_model.dart';
import 'package:http/http.dart';

enum MainDataProviderSource {
  none,
  mockUp,
  httpClient,
}

class MainDataProviderOptions {
  MockUpOptions? mockUpOptions;
  HTTPClientOptions? httpClientOptions;

  /// MainDataProviderOptions initialization
  MainDataProviderOptions({
    this.mockUpOptions,
    this.httpClientOptions,
  });
}


class MainDataProviderStatus<T extends DataModel>{
  MainDataProviderStates state;
  T? result;

  MainDataProviderStatus({this.result ,this.state = MainDataProviderStates.idle});
}

enum MainDataProviderStates {
  idle,
  loading,
  success,
  error
}

class MainDataProvider {

  List<AbstractSource> get initializedSources => _initializedSources.toList(growable: false);

  final MainDataProviderOptions _options;
  List<AbstractSource> _initializedSources = <AbstractSource>[];

  /// MainDataProvider initialization
  MainDataProvider({
    required MainDataProviderOptions options,
  }) : _options = options {

    final theMockUpOptions = options.mockUpOptions;
    if (theMockUpOptions != null) {
      _initializedSources.add(MockUpSource(options: theMockUpOptions,provider: this));
    }

    final theHttpClientOptions = options.httpClientOptions;
    if (theHttpClientOptions != null) {
      _initializedSources.add(HTTPSource(options: theHttpClientOptions,provider: this));
    }
  }

  /// Get source if it was initialized
  AbstractSource? _initialisedSource(MainDataProviderSource source, [MockUpRequestOptions? mockUpOptions]) {
    AbstractSource? theSource;

    switch (source) {
      case MainDataProviderSource.mockUp:
        theSource = _initializedSources.firstWhereOrNull((element) => element is MockUpSource);
        break;
      case MainDataProviderSource.httpClient:
        theSource = _initializedSources.firstWhereOrNull((element) => element is HTTPSource);
        break;
      default:
        throw Exception('Cannot get not implemented source $source');
    }

    return theSource;
  }

  /// Create new DataSource for DataRequests and register it to source for data, will throw Exception if you try to register on not initialized source
  MainSource registerDataSource(List<DataSource> dataSource) {
    final MainSource source = MainSource(dataSource);

    for (DataSource dataRequest in dataSource) {
      AbstractSource? theSource = _initialisedSource(dataRequest.source, dataRequest.mockUpRequestOptions);

      if (theSource is MockUpSource) {
        dataRequest.sourceRegisteredTo = MainDataProviderSource.mockUp;
      }

      if (theSource == null) {
        throw Exception('Cannot register for not initialized source ${dataRequest.source}');
      }

      theSource.registerSource(source);
    }

    return source;
  }

  /// UnRegister the DataSource from source/s
  void unRegisterDataSource(MainSource dataSource) {
    for (MainDataProviderSource source in dataSource.sourcesRegisteredTo) {
      AbstractSource? theSource = _initialisedSource(source);

      if (theSource == null) {
        throw Exception('Cannot unRegister for not initialized source $source');
      }

      theSource.unRegisterSource(dataSource);
    }
  }

  /// Check if DataRequest has next page
  bool dataSourceHasNextPage(DataSource dataRequest) {
    AbstractSource? theSource = _initialisedSource(dataRequest.source, dataRequest.mockUpRequestOptions);

    if (theSource == null) {
      throw Exception('Cannot check nextPage for not initialized source ${dataRequest.source}');
    }

    return theSource.dataSourceHasNextPage(dataRequest);
  }

  /// Request to load next page of DataRequest
  dataSourceLoadNextPage(DataSource dataRequest) {
    AbstractSource? theSource = _initialisedSource(dataRequest.source, dataRequest.mockUpRequestOptions);

    if (theSource == null) {
      throw Exception('Cannot load nextPage for not initialized source ${dataRequest.source}');
    }

    theSource.dataSourceLoadNextPage(dataRequest);
  }

  /// Async execute one time DataTask using initialized source
  Future<T> executeDataTask<T extends DataTask>(T dataTask) async {
    AbstractSource? theSource;

    if (dataTask.mockUpTaskOptions != null) {
      theSource = _initializedSources.firstWhereOrNull((element) => element is MockUpSource);

      if (theSource != null) {
        final T executeSourceDataTask = await theSource.executeDataTask<T>(dataTask);
        return executeSourceDataTask;
      }
    }

    if (dataTask.options is MockUpTaskOptions) {
      theSource = _initializedSources.firstWhereOrNull((element) => element is MockUpSource);
    } else if (dataTask.options is HTTPTaskOptions) {
      theSource = _initializedSources.firstWhereOrNull((element) => element is HTTPSource);
    } else {
      throw Exception('Cannot get not implemented source for options ${dataTask.options}');
    }

    if (theSource == null) {
      throw Exception('Cannot execute DataTask for not initialized source for options ${dataTask.options}');
    }

    return theSource.executeDataTask<T>(dataTask);
  }

  /// ReFetch data for DataRequest of initialized source based on methods or identifiers
  Future<void> reFetchData(MainDataProviderSource source, {List<String>? methods, List<String>? identifiers}) {
    AbstractSource? theSource = _initialisedSource(source);

    if (theSource == null) {
      throw Exception('Cannot reFetchData for not initialized source $source');
    }

    return theSource.reFetchData(methods: methods, identifiers: identifiers);
  }

  /// Update the of MainDataSource based on state of sources used by it
  void _updateMainDataSourceState(MainSource mainDataSource) {
    final List<MainDataProviderSourceState> states = [];

    mainDataSource.sourcesRegisteredTo.forEach((MainDataProviderSource source) {
      AbstractSource? theSource = _initialisedSource(source);

      if (theSource == null) {
        states.add(MainDataProviderSourceState.unAvailable);
      } else {
        states.add(theSource.state.value);
      }
    });

    if (states.contains(MainDataProviderSourceState.unAvailable)) {
      mainDataSource.state.value = MainDataProviderSourceState.unAvailable;
    } else if (states.contains(MainDataProviderSourceState.connecting)) {
      mainDataSource.state.value = MainDataProviderSourceState.connecting;
    } else {
      mainDataSource.state.value = MainDataProviderSourceState.ready;
    }
  }
}

enum MainDataProviderSourceState {
  unAvailable,
  ready,
  connecting,
}

abstract class AbstractSource {

  @protected
  late final MainDataProvider mainDataProvider;

  MainDataProviderSource get isSource;
  ValueNotifier<MainDataProviderSourceState> state = ValueNotifier(MainDataProviderSourceState.unAvailable);

  final List<MainSource> _dataSources = <MainSource>[];
  final List<String> _identifiers = <String>[];
  final Map<String, DataSource> _identifierRequests = {};


  /// Register the DataSource for data
  registerSource(MainSource dataSource);

  /// Register DataSource DataRequests for identifiers and example DataRequests mapping
  @protected
  registerDataSources(MainSource dataSource, MainDataProvider provider) {
    dataSource.identifiers.forEach((String identifier) {
      if (_identifiers.contains(identifier)) {
        final DataSource dataRequest = dataSource.requestForIdentifier(identifier)!;

        if (dataRequest.source != isSource) {
          return;
        }

        _identifiers.add(identifier);

        _identifierRequests[identifier] = dataRequest;
      }
    });
  }

  /// UnRegister the DataSource from receiving data
  unRegisterSource(MainSource dataSource);

  /// UnRegister DataSource DataRequests for identifiers if no other DataSource has equal
  @protected
  unRegisterDataSource(MainSource dataSource) {
    dataSource.identifiers.forEach((String identifier) {
      final DataSource dataRequest = dataSource.requestForIdentifier(identifier)!;

      if (dataRequest.source != isSource) {
        return;
      }

      for (MainSource otherDataSource in _dataSources) {
        if (otherDataSource != dataSource) {
          for (String otherDataSourceMethod in otherDataSource.identifiers) {
            if (otherDataSourceMethod == identifier) {
              return;
            }
          }
        }
      }

      _identifiers.remove(identifier);
      _identifierRequests.remove(identifier);
    });
  }

  /// Check if DataRequest has next page
  bool dataSourceHasNextPage(DataSource dataRequest);

  /// Request to load next page of DataRequest
  dataSourceLoadNextPage(DataSource dataRequest);

  /// Execute one time DataTask against the source
  Future<T> executeDataTask<T extends DataTask>(T dataTask);

  /// ReFetch data for DataRequest based on methods or identifiers
  Future<void> reFetchData({List<String>? methods, List<String>? identifiers});

  MainDataProviderSource sourceForTaskOptions(DataTaskOptions options) {
    if (options is MockUpTaskOptions) {
      return MainDataProviderSource.mockUp;
    } else if (options is HTTPTaskOptions) {
      return MainDataProviderSource.httpClient;
    } else {
      throw Exception('Cannot get source for options $options');
    }
  }
}

class MockUpOptions {
  final String assetsDataPath;

  /// MockUpOptions initialization
  const MockUpOptions({
    this.assetsDataPath = 'assets/mockUpData',
  });
}

class MockUpSource extends AbstractSource {
  @override
  MainDataProviderSource get isSource => MainDataProviderSource.mockUp;

  final MockUpOptions _options;
  final Map<MainDataProviderSource, Map<String, dynamic>> _mockUpData = {};

  /// MockUpSource initialization
  MockUpSource({
    required MockUpOptions options,
    required MainDataProvider provider,
  }) : _options = options {
    state = ValueNotifier(MainDataProviderSourceState.ready);
    mainDataProvider = provider;
  }

  /// Get mockUp data for MainDataProviderSource, if not exists try to load from assets
  Future<Map<String, dynamic>> _sourceMockUpData(MainDataProviderSource source) async {
    Map<String, dynamic>? data = _mockUpData[source];

    if (data == null) {
      String assetPath = _options.assetsDataPath;

      switch (source) {
        case MainDataProviderSource.httpClient:
          assetPath = join(assetPath, 'HTTPClient.json');
          break;
        default:
          throw Exception('Cannot init mockUp data for source $source');
      }

      String assetData = await rootBundle.loadString(assetPath);

      _mockUpData[source] = jsonDecode(assetData);

      data = _mockUpData[source]!;
    }

    return data;
  }

  /// Query data from mockup in memory data
  Future<dynamic> _query(MainDataProviderSource source, String identifier, [String? assetDataPath]) async {
    if (assetDataPath != null) {
      String assetData = await rootBundle.loadString(assetDataPath);

      return jsonDecode(assetData);
    } else {
      Map<String, dynamic> data = await _sourceMockUpData(source);

      final dynamic identifierData = data[identifier];

      if (identifierData == null) {
        throw Exception('Missing mockUpData for identifier $identifier');
      }

      return identifierData;
    }
  }

  /// Query data from mockup in memory data and update DataSources
  Future<void> _queryDataUpdate(DataSource dataRequest) async {
    SourceException? exception;

    if (dataRequest.source == MainDataProviderSource.httpClient) {
      String? json;

      try {
        dynamic data = await _query(dataRequest.source, dataRequest.identifier, dataRequest.mockUpRequestOptions?.assetDataPath);

        if (data is Map) {
          data = Map<String, dynamic>.from(data);
        } else {
          data = List<Map<String, dynamic>>.from(data);
        }

        json = jsonEncode(data);
      } catch (e) {
        exception = SourceException(originalException: e);
      }

      _dataSources.forEach((MainSource dataSource) {
        if (dataSource.identifiers.contains(dataRequest.identifier)) {
          dataSource.setResult(
            dataRequest.identifier,
            <String, dynamic>{
              'response': json,
            },
            exception,
          );
        }
      });
    } else {
      List<Map<String, dynamic>>? results;

      try {
        results = List<Map<String, dynamic>>.from(await _query(dataRequest.source, dataRequest.identifier, dataRequest.mockUpRequestOptions?.assetDataPath));
      } catch (e) {
        exception = SourceException(originalException: e);
      }

      _dataSources.forEach((MainSource dataSource) {
        if (dataSource.identifiers.contains(dataRequest.identifier)) {
          dataSource.setResult(
            dataRequest.identifier,
            <String, dynamic>{
              'list': results,
            },
            exception,
          );
        }
      });
    }
  }

  /// Register the DataSource for data
  @override
  registerSource(MainSource dataSource) {
    _dataSources.add(dataSource);

    registerDataSources(dataSource, mainDataProvider);

    mainDataProvider._updateMainDataSourceState(dataSource);

    int minDelayMilliseconds = dataSource.mockupMinDelayMilliseconds;
    int maxDelayMilliseconds = dataSource.mockupMaxDelayMilliseconds;

    if (maxDelayMilliseconds > 0 && maxDelayMilliseconds > minDelayMilliseconds) {
      final random = Random();

      int delay = random.nextInt(maxDelayMilliseconds - minDelayMilliseconds) + minDelayMilliseconds;

      Future.delayed(Duration(milliseconds: delay)).then((value) {
        reFetchData(identifiers: dataSource.identifiers);
      });
    } else {
      reFetchData(identifiers: dataSource.identifiers);
    }
  }

  /// UnRegister the DataSource from receiving data
  @override
  unRegisterSource(MainSource dataSource) {
    unRegisterDataSource(dataSource);

    _dataSources.remove(dataSource);

    dataSource.dispose();
  }

  /// Check if DataRequest has next page
  @override
  bool dataSourceHasNextPage(DataSource dataRequest) {
    throw Exception('MockUpSource is not implemented');
  }

  /// Request to load next page of DataRequest
  @override
  dataSourceLoadNextPage(DataSource dataRequest) {
    throw Exception('MockUpSource is not implemented');
  }

  /// Execute one time DataTask against the source
  @override
  Future<T> executeDataTask<T extends DataTask>(T dataTask) async {
    final options = dataTask.mockUpTaskOptions!;

    String identifier = dataTask.method;
    final Map<String, dynamic> data = dataTask.data.toJson();
    if (data.isNotEmpty) {
      for (String key in data.keys) {
        identifier += '_${key}_${data[key]}';
      }
    }

    final random = Random();
    int delay = 0;

    if (options.maxDelayMilliseconds > 0 && options.maxDelayMilliseconds > options.minDelayMilliseconds) {
      delay = random.nextInt(options.maxDelayMilliseconds - options.minDelayMilliseconds) + options.minDelayMilliseconds;

      await Future.delayed(Duration(milliseconds: delay ~/ 2));
    }

    switch (options.type) {
      case MockUpType.Query:
        Map<String, dynamic>? results;
        SourceException? exception;

        try {
          results = Map<String, dynamic>.from(await _query(
            sourceForTaskOptions(dataTask.options),
            identifier,
            dataTask.mockUpTaskOptions?.assetDataPath,
          ));
        } catch (e) {
          exception = SourceException(originalException: e);
        }

        if (options.maxDelayMilliseconds > 0 && options.maxDelayMilliseconds > options.minDelayMilliseconds) {
          await Future.delayed(Duration(milliseconds: delay ~/ 2));
        }

        dataTask.result = results != null ? dataTask.processResult(results) : null;
        dataTask.error = exception;
        break;
    }

    if (dataTask.reFetchMethods != null) {
      await reFetchData(methods: dataTask.reFetchMethods);
    }

    return dataTask;
  }

  /// ReFetch data for DataRequest based on methods or identifiers
  @override
  Future<void> reFetchData({List<String>? methods, List<String>? identifiers}) async {
    if (methods == null && identifiers == null) {
      throw Exception('Provide either methods or identifiers');
    }

    if (methods != null) {
      final List<String> identifiers = <String>[];

      for (String method in methods) {
        for (MainSource dataSource in _dataSources) {
          final DataSource? dataRequest = dataSource.requestForMethod(method);

          if (dataRequest != null && !identifiers.contains(dataRequest.identifier)) {
            identifiers.add(dataRequest.identifier);
          }
        }
      }

      await reFetchData(identifiers: identifiers);
    }

    if (identifiers != null) {
      for (String identifier in identifiers) {
        for (MainSource dataSource in _dataSources) {
          final DataSource? dataRequest = dataSource.requestForIdentifier(identifier);

          if (dataRequest != null) {
            await _queryDataUpdate(dataRequest);
            break;
          }
        }
      }
    }
  }
}

class HTTPClientOptions {
  final String hostUrl;
  final Map<String, String>? headers;

  /// HTTPClientOptions initialization
  HTTPClientOptions({
    required this.hostUrl,
    this.headers,
  }) : assert(hostUrl.isNotEmpty);
}

class HTTPSource extends AbstractSource {
  @override
  MainDataProviderSource get isSource => MainDataProviderSource.httpClient;

  final HTTPClientOptions _options;

  /// HTTPSource initialization
  HTTPSource({
    required HTTPClientOptions options,
    required MainDataProvider provider,
  }) : _options = options {
    state = ValueNotifier(MainDataProviderSourceState.ready);
    mainDataProvider = provider;
  }

  /// Query data from remote API
  Future<Response> query(DataSource dataRequest) async {
    final List<String> values = [];
    dataRequest.request.toJson().forEach((key, value) {
      values.add('$key=$value');
    });

    final String url = '${_options.hostUrl}${dataRequest.method}?${values.join('&')}';

    final Response response = await get(
      Uri.parse(url),
      headers: _options.headers,
    );

    return response;
  }

  /// Query data from remote API and update DataSources
  Future<void> _queryDataUpdate(DataSource dataRequest) async {
    String? json;
    SourceException? exception;

    try {
      final response = await query(dataRequest);

      json = response.body;

      if (response.statusCode >= 400) {
        exception = SourceException(
          originalException: null,
          httpStatusCode: response.statusCode,
        );
      }
    } catch (e) {
      exception = SourceException(originalException: e);
    }

    _dataSources.forEach((MainSource dataSource) {
      if (dataSource.identifiers.contains(dataRequest.identifier)) {
        dataSource.setResult(
          dataRequest.identifier,
          <String, dynamic>{
            'response': json,
          },
          exception,
        );
      }
    });
  }

  /// Register the DataSource for data
  @override
  registerSource(MainSource dataSource) {
    _dataSources.add(dataSource);

    registerDataSources(dataSource, mainDataProvider);

    mainDataProvider._updateMainDataSourceState(dataSource);

    reFetchData(identifiers: dataSource.identifiers);
  }

  /// UnRegister the DataSource from receiving data
  @override
  unRegisterSource(MainSource dataSource) {
    unRegisterDataSource(dataSource);

    _dataSources.remove(dataSource);

    dataSource.dispose();
  }

  /// Check if DataRequest has next page
  @override
  bool dataSourceHasNextPage(DataSource dataRequest) {
    throw Exception('HTTPSource is not implemented');
  }

  /// Request to load next page of DataRequest
  @override
  dataSourceLoadNextPage(DataSource dataRequest) {
    throw Exception('HTTPSource is not implemented');
  }

  /// Execute one time DataTask against the source
  @override
  Future<T> executeDataTask<T extends DataTask>(T dataTask) async {
    final options = dataTask.options as HTTPTaskOptions;

    final String hostUrl = options.url ?? _options.hostUrl;
    final Map<String, dynamic> data = dataTask.data.toJson();

    switch (options.type) {
      case HTTPType.Get:
        final List<String> values = [];
        data.forEach((key, value) {
          values.add('$key=$value');
        });

        final String url = '$hostUrl?${values.join('&')}';

        try {
          final Response response = await get(
            Uri.parse(url),
            headers: options.headers,
          );

          if (options.processBody != null) {
            final result = options.processBody!(response.body);

            dataTask.result = dataTask.processResult(result);
          } else {
            final decodeResult = jsonDecode(response.body);
            if(decodeResult is List){
              dataTask.result = dataTask.processResult({'': List<LinkedHashMap<dynamic, dynamic>>.from(decodeResult)});
            }else{
              dataTask.result = dataTask.processResult(decodeResult);
            }

          }

          if (response.statusCode >= 400) {
            dataTask.error = SourceException(
              originalException: null,
              httpStatusCode: response.statusCode,
            );
          }
        } catch (e) {
          dataTask.result = null;
          dataTask.error = SourceException(originalException: e);
        }
        break;
      case HTTPType.Post:
        try {
          final Response response = await post(
            Uri.parse(hostUrl),
            headers: options.headers,
            body: data,
          );

          if (options.processBody != null) {
            final result = options.processBody!(response.body);

            dataTask.result = dataTask.processResult(result);
          } else {
            dataTask.result = dataTask.processResult(jsonDecode(response.body));
          }

          if (response.statusCode >= 400) {
            dataTask.error = SourceException(
              originalException: null,
              httpStatusCode: response.statusCode,
            );
          }
        } catch (e) {
          dataTask.result = null;
          dataTask.error = SourceException(originalException: e);
        }
        break;
    }

    if (dataTask.reFetchMethods != null) {
      await reFetchData(methods: dataTask.reFetchMethods);
    }

    return dataTask;
  }

  /// ReFetch data for DataRequest based on methods or identifiers
  @override
  Future<void> reFetchData({List<String>? methods, List<String>? identifiers}) async {
    if (methods == null && identifiers == null) {
      throw Exception('Provide either methods or identifiers');
    }

    if (methods != null) {
      final List<String> identifiers = <String>[];

      for (String method in methods) {
        for (MainSource dataSource in _dataSources) {
          final DataSource? dataRequest = dataSource.requestForMethod(method);

          if (dataRequest != null && !identifiers.contains(dataRequest.identifier)) {
            identifiers.add(dataRequest.identifier);
          }
        }
      }

      await reFetchData(identifiers: identifiers);
    }

    if (identifiers != null) {
      for (String identifier in identifiers) {
        for (MainSource dataSource in _dataSources) {
          final DataSource? dataRequest = dataSource.requestForIdentifier(identifier);

          if (dataRequest != null) {
            await _queryDataUpdate(dataRequest);
            break;
          }
        }
      }
    }
  }
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