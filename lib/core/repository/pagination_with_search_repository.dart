import 'package:rick_and_morty_flutter_proj/core/dataProvider/data_source.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/search_module.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/abstract_pagination.dart';

import 'abstract_repository.dart';

abstract class PaginationWithSearchRepository<R extends ResponseDataModel> extends AbstractRepository<R> with AbstractPagination<R>, SearchModule {
  PaginationWithSearchRepository(List<Serivce> sourceList) : super(sourceList);
}

