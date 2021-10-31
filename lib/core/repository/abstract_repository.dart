import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';

import 'store/store.dart';

abstract class AbstractRespository<T extends DataSource> {

  AbstractRespository();

  Future<T> fetchPage();

  Future<T> unsubscribe();

}