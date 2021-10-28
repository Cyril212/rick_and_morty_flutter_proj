import 'package:flutter/material.dart';

import '../main_data_provider.dart';
import 'data_request.dart';
import 'package:collection/src/iterable_extensions.dart';

class MainSource {
  bool get disposed => _disposed;
  ValueNotifier<MainDataProviderSourceState> state = ValueNotifier(MainDataProviderSourceState.unAvailable);
  ValueNotifier<List<DataSource>> results;

  bool _disposed = false;
  final List<DataSource> _dataRequests;

  /// MainDataSource initialization
  MainSource(this._dataRequests)
      : assert(_dataRequests.isNotEmpty),
        results = ValueNotifier(_dataRequests);

  /// Manually dispose of resources
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;

    /// Unless someone else adds an listener, they do not need to be disposed
    /// We use them on for ValueListenableBuilder & they remove their listeners
    // state.dispose();
    // results.dispose();
  }

  /// Get list of identifiers by DataRequests
  List<String> get identifiers => _dataRequests.map((dataRequest) => dataRequest.identifier).toList();

  /// Get list of sources by DataRequests
  List<MainDataProviderSource> get sources => _dataRequests.map((dataRequest) => dataRequest.source).toList();

  /// Get list of sources to which DataSource is actually registered
  List<MainDataProviderSource> get sourcesRegisteredTo => _dataRequests.map((dataRequest) => dataRequest.sourceRegisteredTo ?? dataRequest.source).toList();

  /// Get minDelayMilliseconds for Mockup
  int get mockupMinDelayMilliseconds {
    int minDelayMilliseconds = 0;

    _dataRequests.forEach((dataRequest) {
      final theMockUpRequestOptions = dataRequest.mockUpRequestOptions;

      if (theMockUpRequestOptions != null) {
        minDelayMilliseconds += theMockUpRequestOptions.minDelayMilliseconds;
      }
    });

    return minDelayMilliseconds;
  }

  /// Get minDelayMilliseconds for Mockup
  int get mockupMaxDelayMilliseconds {
    int maxDelayMilliseconds = 0;

    _dataRequests.forEach((dataRequest) {
      final theMockUpRequestOptions = dataRequest.mockUpRequestOptions;

      if (theMockUpRequestOptions != null) {
        maxDelayMilliseconds += theMockUpRequestOptions.maxDelayMilliseconds;
      }
    });

    return maxDelayMilliseconds;
  }

  /// Find DataRequest of this DataSource for method
  DataSource? requestForMethod(String method) {
    return _dataRequests.firstWhereOrNull((dataRequest) => dataRequest.method == method);
  }

  /// Find DataRequest of this DataSource for identifier
  DataSource? requestForIdentifier(String identifier) {
    return _dataRequests.firstWhereOrNull((dataRequest) => dataRequest.identifier == identifier);
  }

  /// Find result for identifier if possible
  dynamic resultForIdentifier(String identifier) {
    final List<DataSource> dataRequests = List.from(_dataRequests);

    for (DataSource dataRequest in dataRequests) {
      if (dataRequest.identifier == identifier) {
        return dataRequest.result;
      }
    }

    return null;
  }

  /// Set response or already processed result from source as result
  void setResult(String identifier, Map<String, dynamic>? result, SourceException? exception) {
    final List<DataSource> dataRequests = List.from(_dataRequests);

    dataRequests.forEach((dataRequest) {
      if (dataRequest.identifier == identifier) {
        dataRequest.result = result != null ? dataRequest.processResponse(result) : null;
        dataRequest.error = exception;
      }
    });

    results.value = dataRequests;
  }

  /// Check if DataRequest has next page
  bool hasNextPageOfRequest<R>() {
    final List<DataSource> dataRequests = List.from(_dataRequests);

    for (DataSource dataRequest in dataRequests) {
      if (dataRequest is R) {
        // return CoreModule.instance.mainDataProvider.dataRequestHasNextPage(dataRequest); //TODO
      }
    }

    return false;
  }

  /// Request DataProvider to load next page of DataRequest
  requestNextPageOfRequest<R>() {
    final List<DataSource> dataRequests = List.from(_dataRequests);

    for (DataSource dataRequest in dataRequests) {
      if (dataRequest is R) {
        // CoreModule.instance.mainDataProvider.dataRequestLoadNextPage(dataRequest); //TODO
        break;
      }
    }
  }
}
