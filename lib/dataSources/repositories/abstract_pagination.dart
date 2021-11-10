import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';

class PaginationController<T extends DataModel> {

  List<T> allPagesList = [];

  int pageNumber = 1;

  bool hasNextPage = false;

  void incrementPage(){
    pageNumber++;
  }

  void setDefaultPage(){
    pageNumber = 1;
  }
}
