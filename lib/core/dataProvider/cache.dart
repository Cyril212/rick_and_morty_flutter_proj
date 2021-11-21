import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import 'model/response_data_model.dart';

abstract class Cache<T extends ResponseDataModel> {
  final InMemoryStore store;

  Cache(this.store);

  T put(String dataId, T data) {
    final processedCache = onCacheWrite(store, dataId, data);

    store.put(dataId, processedCache.toJson());

    return data;
  }

  T get(String dataId) => store.get(dataId) as T;

  T onCacheWrite(InMemoryStore store, String dataId, T response) => response;
}
