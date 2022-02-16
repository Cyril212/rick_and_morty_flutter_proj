import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';

abstract class PaginationController<T extends DataModel> {

  int pageNumber = 1;

  bool hasNextPage = false;

  void setDefaultPage() {
    pageNumber = 1;
  }
}

