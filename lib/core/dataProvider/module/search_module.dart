import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';

mixin SearchModule<R extends ResponseDataModel> {
  // /// Search phrase for filtering
  // String? searchPhrase;
  //
  // List<R>? searchList;
  //
  // int searchPageNum = 1;
  //
  // ///Filters [currentList] by searchPhrase
  // @protected
  // void tryToSearch(List currentList) {
  //   if (searchPhrase != null && searchPhrase!.isNotEmpty) {
  //     final tmp = [...currentList];
  //     currentList.clear();
  //     for (var item in tmp) {
  //       if (item.name.contains(searchPhrase!)) {
  //         currentList.add(item);
  //       }
  //     }
  //   }
  // }
}
