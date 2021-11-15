import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/repository/store/store.dart';

double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;

/// Init Hive database to be able to interact with [boxes]
Future<void> initHiveForFlutter({String? subDir, Iterable<String> boxes = const [HiveStore.defaultBoxName]}) async {
  await Hive.initFlutter();
  await Hive.openBox(HiveStore.defaultBoxName);
}