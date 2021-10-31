import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';

import 'abstract_repository.dart';
import 'store/store.dart';

abstract class AbstractListRepository<T extends DataSource> extends AbstractRespository<T> {

  AbstractListRepository();

  @override
  Future<T> fetchPage();

  @override
  Future<T> unsubscribe() => Future.value();

// Future<T> onDataFetched();
}