import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

class RestClient {
  @protected
  final Store? store;

  @protected
  final RestManager manager;

  RestClient({Store? store, required this.manager}) : store = store ?? HiveStore();

  Future<T> addQueryData<T extends DataTask>(T dataTask) async {
    return manager.queryData<T>(dataTask, store!);
  }

  Future<T> removeQueryData<T extends DataTask>(T dataTask) async {
    return manager.queryData(dataTask, store!);
  }

  void putDataToStore(String dataId, Map<String,dynamic> data) =>
    store!.put(dataId, data);

  Map<String,dynamic>? getDataFromStore(String dataId) => store!.get(dataId);


}
