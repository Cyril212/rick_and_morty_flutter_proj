import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/abstract_pagination.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

import 'store/store.dart';

abstract class AbstractRepository<T extends DataSource> extends AbstractPagination<Character>{

  AbstractRepository();

  Future<T> fetchPage();

}