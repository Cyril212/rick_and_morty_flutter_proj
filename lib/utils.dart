import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prefs/prefs.dart';

import 'core/repository/store/store.dart';

double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;



Future<void> initDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHiveForFlutter();
  await Prefs.init();
  await Firebase.initializeApp();
}
/// Init Hive database to be able to interact with [boxes]
Future<void> _initHiveForFlutter({String? subDir, Iterable<String> boxes = const [HiveStore.defaultBoxName]}) async {
  await Hive.initFlutter();
  await Hive.openBox(HiveStore.defaultBoxName);
}