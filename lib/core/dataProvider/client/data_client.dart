import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/abstract_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

import '../service.dart';


///DataClient to communicate with [RestManager] for more [AbstractDataClient]
class DataClient extends AbstractDataClient<RestManager> {
  DataClient({Store? store, manager}) : super(manager: manager);

  @override
  Future<T> executeQuery<T extends Service>(T dataSource) async {
    return manager.processData<T>(dataSource, store!);
  }

  @override
  void putDataToStore(String dataId, dynamic data) => store!.put(dataId, data);

  @override
  dynamic getDataFromStore(String dataId) => store!.get(dataId);
}
