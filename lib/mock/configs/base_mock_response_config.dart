import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rick_and_morty_flutter_proj/core/logger.dart';
import 'package:rick_and_morty_flutter_proj/mock/configs/mock_default_response_config.dart';

const String _kDefaultResponsePath = 'default_response';

///Generates [BaseMockResponseConfig] classes by endpoint path
abstract class BaseMockResponseConfig {
  BaseMockResponseConfig({RequestOptions? options, String? responseKey})
      : url = options?.uri,
        baseResponsePath = responseKey ?? _kDefaultResponsePath;

  factory BaseMockResponseConfig.generate({Uri? url, String? responseKey}) {
    Logger.d('[Intercepted request]: $url');

    return MockDefaultResponseConfig(responseKey);
  }

  /// Current url
  @protected
  Uri? url;

  /// Defines query parameters to concat them to mock files.
  /// For example check [MockVintagesResponseConfig]'s 'find' path.
  /// In this class we request mocks with [page] parameter which we fetch from cyrrent request.
  List<String> get queryFilter => <String>[];

  /// Folds query from [url], filters each key by [queryFilter] and maps it to pathQuery
  /// so later we can concat it to [baseResponsePath] by [resolveMockPathByQueryFilter]
  /// in order to find mocked response.
  String get pathQuery {
    if (url?.queryParameters.isEmpty ?? true) {
      return '';
    }

    final String? foldedQuery = url?.queryParameters.entries.fold('',
        (String? previousValue, MapEntry<String, String> element) {
      if (element.value.isEmpty || !queryFilter.contains(element.key)) {
        return '$previousValue';
      } else {
        return '$previousValue${element.key}_${element.value}_';
      }
    });
    return (foldedQuery != null && foldedQuery.isNotEmpty)
        ? foldedQuery.substring(0, foldedQuery.length - 1)
        : '';
  }

  /// Returns path to mocked response
  @protected
  String resolveMockPathByQueryFilter(String baseResponsePath) =>
      pathQuery.isNotEmpty
          ? '${baseResponsePath}_$pathQuery'
          : baseResponsePath;

  /// Base path of mock file
  @protected
  String baseResponsePath;

  @protected
  int? _statusCode;

  @protected
  int get statusCode => _statusCode ?? 200;

  /// Default header
  @protected
  Headers get headers => Headers.fromMap({
        'content-type': ['application/json; charset=UTF-8']
      });

  @protected
  bool containsPath(String query) => url?.path.contains(query) ?? false;

  /// Allows to define mocked path by endpoint
  @protected
  Future<String> setup() => retrieve(_kDefaultResponsePath);

  /// Gets response body and sends it to [MockClient]
  Future<Response> dispatch() async {
    final String responseBody = await setup();

    return Response(
        data: json.decode(responseBody),
        statusCode: statusCode,
        headers: headers,
        requestOptions: RequestOptions(path: url?.path ?? ''));
  }

  /// Gets filteredQuery and returns corresponding mock
  @protected
  Future<String> retrieve(String path) {
    final String mockedPathByQueryFilter = resolveMockPathByQueryFilter(path);
    final String assetPath = 'assets/mocks/$mockedPathByQueryFilter.json';

    Logger.d('[Currently mocked response json]: $mockedPathByQueryFilter');

    return rootBundle.loadString(assetPath);
  }
}
