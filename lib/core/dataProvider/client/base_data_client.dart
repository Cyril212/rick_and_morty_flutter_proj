import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import '../service.dart';

enum FetchPolicy { cache, network, cacheFirst }

/// Abstraction over data client, mainly used to create custom one and be able to Mock app by using [MockDataClient]
/// Responsible for holding [store] and [manager] within scope tree and used as delegate for repository
abstract class BaseDataClient<T extends BaseDataManager> {
  final Store store;
  final T manager;

  ///Init data client, in case store is empty set it to defaultStore [HiveStore()]
  BaseDataClient({required this.store, required this.manager});

  ///Executes query from repository to fetch data from [manager]
  Future<R> executeService<R extends Service>(R service, HttpOperation operation, FetchPolicy fetchPolicy) {
    return manager.execute<R>(service, store, operation);
  }

  ///Fetches data from store ([Hive] or [inMemory])
  void putDataToStore(String dataId, dynamic data) => store.put(dataId, data);

  ///Gets data from store ([Hive] or [inMemory])
  dynamic getDataFromStore(String dataId) => store.get(dataId);

  Stream<String> broadcastDataFromStore(String dataId) => store.stream.where((id) => dataId == id);
}
