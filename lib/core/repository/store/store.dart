import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

// TODO decide if [Store] should have save, etc
// TODO figure out how to reference non-imported symbols
/// Raw key-value datastore API leveraged by the [Cache]
@immutable
abstract class Store {
  final StreamController<String> _storeController = StreamController<String>.broadcast();

  final List<String> storageIdList = [];

  Sink<String> get sink => _storeController.sink;

  Stream<String> get stream => _storeController.stream;

  dynamic get(String storageId);

  /// Write [value] into this store under the key [storageId]
  void put(String storageId, dynamic value) {
    storageIdList.add(storageId);
    sink.add(storageId);
  }

  /// Delete the value of the [storageId] from the store, if preset
  void delete(String storageId) {
    storageIdList.add(storageId);
    sink.add(storageId);
  }

  /// Empty the store
  void reset() {
    for (var storageId in storageIdList) {
      sink.add(storageId);
    }
  }

  /// Return the entire contents of the cache as [Map].
  ///
  /// NOTE: some [Store]s might return mutable objects
  /// referenced by the store itself.
  Map<String, Map<String, dynamic>> toMap();
}

@immutable
class InMemoryStore extends Store {
  /// Normalized map that backs the store.
  /// Defaults to an empty [HashMap]
  @protected
  @visibleForTesting
  final Map<String, dynamic> data;

  /// Creates an InMemoryStore inititalized with [data],
  /// which defaults to an empty [HashMap]
  InMemoryStore([
    Map<String, dynamic>? data,
  ]) : data = data ?? HashMap<String, dynamic>();

  List<MapEntry> getMapEntriesByKey(String key) => data.entries.where((entry) => entry.key.contains(key)).toList();

  @override
  Map<String, dynamic>? get(String storageId) => data[storageId];

  @override
  void put(String storageId, dynamic value) {
    data[storageId] = value;
    super.put(storageId, value);
  }

  @override
  void delete(String storageId) => data.remove(storageId);

  /// Return the  underlying [data] as an unmodifiable [Map].
  @override
  Map<String, Map<String, dynamic>> toMap() => Map.unmodifiable(data);

  @override
  void reset() {
    data.clear();
    super.reset();
  }
}

@immutable
class HiveStore extends Store {
  /// Default box name for the `graphql/client.dart` cache store (`graphqlClientStore`)
  static const defaultBoxName = 'clientStore';

  /// Opens a box. Convenience pass through to [Hive.openBox].
  ///
  /// If the box is already open, the instance is returned and all provided parameters are being ignored.
  static final openBox = Hive.openBox;

  /// Convenience factory for `HiveStore(await openBox(boxName ?? 'graphqlClientStore', path: path))`
  ///
  /// [boxName]  defaults to [defaultBoxName], [path] is optional.
  /// For full configuration of a [Box] use [HiveStore()] in tandem with [openBox] / [Hive.openBox]
  static Future<HiveStore> open({
    String boxName = defaultBoxName,
    String? path,
  }) async =>
      HiveStore(await openBox(boxName, path: path));

  /// Direct access to the underlying [Box].
  ///
  /// **WARNING**: Directly editing the contents of the store will not automatically
  /// rebroadcast operations.
  final Box box;

  /// Creates a HiveStore inititalized with the given [box], defaulting to `Hive.box(defaultBoxName)`
  ///
  /// **N.B.**: [box] must already be [opened] with either [openBox], [open], or `initHiveForFlutter` from `graphql_flutter`.
  /// This lets us decouple the async initialization logic, making store usage elsewhere much more straightforward.
  ///
  /// [opened]: https://docs.hivedb.dev/#/README?id=open-a-box
  HiveStore([Box? box]) : box = box ?? Hive.box(defaultBoxName);

  @override
  dynamic get(String storageId) {
    final result = box.get(storageId);
    if (result == null) return null;
    return result;
  }

  @override
  void put(String storageId, dynamic value) {
    box.put(storageId, value);
    super.put(storageId, value);
  }

  @override
  void delete(String storageId) {
    box.delete(storageId);
    super.delete(storageId);
  }

  @override
  Map<String, Map<String, dynamic>> toMap() => Map.unmodifiable(box.toMap());
}
