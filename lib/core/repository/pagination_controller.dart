import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/character_list_service.dart';

abstract class PaginationController<T extends DataModel> {

  List<T> allPagesList = [];

  @protected
  int pageNumber = 1;

  bool hasNextPage = false;

  int incrementPage() => ++pageNumber;

  void setDefaultPage() {
    pageNumber = 1;
  }

}

