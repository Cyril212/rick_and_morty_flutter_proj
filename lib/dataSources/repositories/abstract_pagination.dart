import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';

mixin AbstractPagination<T extends DataModel> {

  @protected
  List<T> allPagesList = [];

  @protected
  List<T> currentListByMode = [];

  @protected
  bool get hasNextPage;

  String get favouriteListTag;

  @protected
  void incrementPage();

  @protected
  void filterAllPagesListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch);
}
