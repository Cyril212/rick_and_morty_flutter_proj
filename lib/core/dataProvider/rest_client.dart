import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class DataClient {
  final Store? store;
  final RestManager manager;

  DataClient({Store? store, required this.manager})
      : store = store ?? HiveStore();

  Future<T> addQueryData<T extends DataTask>(T dataTask) async {
    return manager.queryData<T>(dataTask, store!);
  }

  Future<T> removeQueryData<T extends DataTask>(T dataTask) async {
    return manager.queryData(dataTask, store!);
  }

  void putMapDataToStore(String dataId, Map<String, dynamic> data) => store!.put(dataId, data);

  void putEnumToStore(String dataId, ListFilterMode mode) => store!.put(dataId, {"listMode": mode});

  Map<String, dynamic>? getDataFromStore(String dataId) => store!.get(dataId);
}
