import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

abstract class AbstractDataClient<T extends AbstractManager> {
  final Store? store;
  final T manager;

  AbstractDataClient({Store? store, required this.manager})
      : store = store ?? HiveStore();

  Future<R> executeQuery<R extends DataSource>(R dataSource) async {
    return manager.processData<R>(dataSource, store!);
  }

  void putDataToStore(String dataId, Map<String, dynamic> data) => store!.put(dataId, data);

  void putEnumToStore(String dataId, ListFilterMode mode) => store!.put(dataId, {dataId: mode});

  dynamic getDataFromStore(String dataId) => store!.get(dataId);
}
