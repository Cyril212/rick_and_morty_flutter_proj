import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prefs/prefs.dart';
import '../app.dart';
import '../app.dart';
import '../utils/utils.dart';
import 'flavors.dart';

void main() async {
  await initDependencies();

  FlavorManager.appFlavor = Flavor.PROD;
  runApp(const RickAndMortyApp());
}
