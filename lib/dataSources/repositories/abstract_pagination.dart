import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:prefs/prefs.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

abstract class AbstractPagination<T extends DataModel> {

  @protected
  List<T> allPagesList;

  @protected
  List<T> currentListByMode;

  @protected
  bool get hasNextPage;

  String get favouriteListTag;

  AbstractPagination()
      : allPagesList = [],
        currentListByMode = [];

  @protected
  void incrementPage();

  @protected
  void filterAllPagesListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch);
}
