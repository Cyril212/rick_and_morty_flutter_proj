
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/abstract_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

import '../service.dart';



/// Abstraction over data client, mainly used to create custom one and be able to Mock app by using [MockDataClient]
/// Responsible for holding [store] and [manager] within scope tree and used as delegate for repository
abstract class AbstractDataClient<T extends AbstractManager> {
  final Store? store;
  final T manager;

  ///Init data client, in case store is empty set it to defaultStore [HiveStore()]
  AbstractDataClient({Store? store, required this.manager})
      : store = store ?? HiveStore();

  ///Executes query from repository to fetch data from [manager]
  Future<R> executeQuery<R extends Service>(R dataSource) async {
    return manager.processData<R>(dataSource, store!);
  }

  ///Fetches data from store ([Hive] or [inMemory])
  void putDataToStore(String dataId, dynamic data) => store!.put(dataId, data);

  ///Gets data from store ([Hive] or [inMemory])
  dynamic getDataFromStore(String dataId) => store!.get(dataId);
}
