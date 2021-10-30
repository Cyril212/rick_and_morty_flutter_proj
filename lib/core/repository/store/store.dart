import 'dart:collection';

import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

// TODO decide if [Store] should have save, etc
// TODO figure out how to reference non-imported symbols
/// Raw key-value datastore API leveraged by the [Cache]
@immutable
abstract class Store {
  Map<String, dynamic>? get(String dataId);

  /// Write [value] into this store under the key [dataId]
  void put(String dataId, Map<String, dynamic>? value);

  /// [put] all entries from [data] into the store
  ///
  /// Functionally equivalent to `data.map(put);`
  void putAll(Map<String, Map<String, dynamic>> data);

  /// Delete the value of the [dataId] from the store, if preset
  void delete(String dataId);

  /// Empty the store
  void reset();

  /// Return the entire contents of the cache as [Map].
  ///
  /// NOTE: some [Store]s might return mutable objects
  /// referenced by the store itself.
  Map<String, Map<String, dynamic>> toMap();
}

/// Simplest possible [Map]-backed store
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

  @override
  Map<String, dynamic>? get(String dataId) => data[dataId];

  @override
  void put(String dataId, Map<String, dynamic>? value) => data[dataId] = value;

  @override
  void putAll(Map<String, Map<String, dynamic>> entries) =>
      data.addAll(entries);

  @override
  void delete(String dataId) => data.remove(dataId);

  /// Return the  underlying [data] as an unmodifiable [Map].
  @override
  Map<String, Map<String, dynamic>> toMap() => Map.unmodifiable(data);

  void reset() => data.clear();
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
  HiveStore([Box? box]) : this.box = box ?? Hive.box(defaultBoxName);

  @override
  Map<String, dynamic>? get(String dataId) {
    final result = box.get(dataId);
    if (result == null) return null;
    return Map.from(result);
  }

  @override
  void put(String dataId, Map<String, dynamic>? value) {
    box.put(dataId, value);
  }

  @override
  void putAll(Map<String, Map<String, dynamic>> data) {
    box.putAll(data);
  }

  @override
  void delete(String dataId) {
    box.delete(dataId);
  }

  @override
  Map<String, Map<String, dynamic>> toMap() => Map.unmodifiable(box.toMap());

  Future<void> reset() => box.clear();
}

