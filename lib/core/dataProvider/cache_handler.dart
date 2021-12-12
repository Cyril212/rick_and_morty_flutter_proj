import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../Logger.dart';
import 'model/response_data_model.dart';

abstract class CacheHandler<T extends ResponseDataModel> {
  final InMemoryStore store;
  final String method;

  CacheHandler(this.store, this.method);

  @protected
  T put(String query, T data) {
    Logger.d("Query: $query", tag: "onPut");

    final resolvedQuery = resolveQuery(query);
    final processedCache = onCacheWrite(store, resolvedQuery, data);

    store.put(resolvedQuery, processedCache.toJson());

    return data;
  }

  @protected
  T get(String dataId) => store.get(dataId) as T;

  @protected
  T onCacheWrite(InMemoryStore store, String query, T response) => response;

  @protected
  String resolveQuery(String query) => query;
}
