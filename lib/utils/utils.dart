import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prefs/prefs.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/push_messages_module.dart';

import '../core/repository/store/store.dart';

double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;

Future<void> initDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHiveForFlutter();
  await Prefs.init();
  await PushMessagesModule.instance.initFirebaseMessaging();
}

/// Init Hive database to be able to interact with [boxes]
Future<void> _initHiveForFlutter() async {
  await Hive.initFlutter();
  await Hive.openBox(HiveStore.defaultBoxName);
}