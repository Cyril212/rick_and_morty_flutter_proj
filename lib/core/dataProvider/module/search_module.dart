import 'package:flutter/material.dart';

mixin SearchModule {
  /// Search phrase for filtering
  String? searchPhrase;

  ///Filters [currentListByMode] by searchPhrase
  @protected
  void tryToSearch(List currentList) {
    if (searchPhrase != null && searchPhrase!.isNotEmpty) {
      final tmp = [...currentList];
      currentList.clear();
      for (var item in tmp) {
        if (item.name.contains(searchPhrase!)) {
          currentList.add(item);
        }
      }
    }
  }
}
