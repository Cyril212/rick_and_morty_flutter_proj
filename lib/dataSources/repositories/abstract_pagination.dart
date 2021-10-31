import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:prefs/prefs.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/data_model.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

abstract class AbstractPagination<T extends DataModel> {

  @protected
  int pageNum;

  @protected
  ListFilterMode get filterListState => EnumToString.fromString(ListFilterMode.values, Prefs.getString(listModePrefKey)) ?? ListFilterMode.none;

  @protected
  List<T> mergedList;

  @protected
  List<T> filteredListByMode;

  String get listModePrefKey;

  AbstractPagination({this.pageNum = 0})
      : mergedList = [],
        filteredListByMode = [];

  @protected
  void incrementPage();

  @protected
  bool get hasNextPage;

  @protected
  List<T>? filterListByFilterMode(ListFilterMode listFilterMode, bool shouldFetch);
}
