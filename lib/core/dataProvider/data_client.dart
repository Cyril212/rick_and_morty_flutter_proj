import 'package:rick_and_morty_flutter_proj/core/dataProvider/abstract_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class DataClient extends AbstractDataClient<RestManager> {
  DataClient({Store? store, manager}) : super(manager: manager);

  @override
  Future<T> executeQuery<T extends DataSource>(T dataSource) async {
    return manager.processData<T>(dataSource, store!);
  }

  @override
  void putDataToStore(String dataId, data) => store!.put(dataId, data);

  @override
  void putEnumToStore(String dataId, ListFilterMode mode) => store!.put(dataId, {"listMode": mode});

  @override
  dynamic getDataFromStore(String dataId) => store!.get(dataId);
}
