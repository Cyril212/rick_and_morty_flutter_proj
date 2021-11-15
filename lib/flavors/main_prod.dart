import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import '../app.dart';
import '../app.dart';
import '../utils.dart';
import 'flavors.dart';

void main() async {
  await initHiveForFlutter();
  await Prefs.init();
  FlavorManager.appFlavor = Flavor.PROD;
  runApp(const RickAndMortyApp());
}
