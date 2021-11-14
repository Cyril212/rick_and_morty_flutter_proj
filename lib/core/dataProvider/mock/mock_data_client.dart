import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/abstract_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../service.dart';
import 'mock_manager.dart';

///Mock class of DataClient
class MockDataClient extends AbstractDataClient<MockManager> {
  MockDataClient({Store? store, manager}) : super(store:store, manager: manager);

  @override
  Future<T> executeService<T extends Service>(T service) async {
    return manager.processData<T>(service, store!);
  }

  @override
  void putDataToStore(String dataId, dynamic data) => store!.put(dataId, data);

  @override
  dynamic getDataFromStore(String dataId) => store!.get(dataId);
}
