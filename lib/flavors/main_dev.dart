import 'package:flutter/material.dart';
import '../app.dart';
import '../utils.dart';
import 'flavors.dart';

void main() async {
  await initDependencies();

  FlavorManager.appFlavor = Flavor.DEV;
  runApp(const RickAndMortyApp());
}
