import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../Logger.dart';
import 'model/response_data_model.dart';

abstract class Cache<T extends ResponseDataModel> {
  final InMemoryStore store;
  final String method;

  Cache(this.store, this.method);

  T put(String query, T data) {
    Logger.d("Query: $query", tag: "onPut");

    final resolvedQuery = resolveQuery(query);
    final processedCache = onCacheWrite(store, resolvedQuery, data);

    store.put(resolvedQuery, processedCache.toJson());

    return data;
  }

  T get(String dataId) => store.get(dataId) as T;

  @protected
  T onCacheWrite(InMemoryStore store, String dataId, T response) => response;

  @protected
  String resolveQuery(String query) => query;
}
