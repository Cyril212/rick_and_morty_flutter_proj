
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/abstract_pagination.dart';

import 'abstract_repository.dart';

abstract class PaginationRepository<R extends ResponseDataModel> extends AbstractRepository<R> with AbstractPagination<R>  {
  PaginationRepository(List<Service> sourceList) : super(sourceList);
}