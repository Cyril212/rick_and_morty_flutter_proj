import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';

import 'store/store.dart';

abstract class AbstractRepository<T extends DataTask> {

  AbstractRepository();

  Future<T> fetchData();

  Future<T> unsubscribe();

// Future<T> onDataFetched();
}