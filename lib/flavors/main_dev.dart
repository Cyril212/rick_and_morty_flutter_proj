import 'package:flutter/material.dart';
import '../app.dart';
import '../utils/utils.dart';
import 'flavors.dart';

void main() async {
  await initDependencies();

  FlavorManager.appFlavor = Flavor.DEV;
  runApp(const RickAndMortyApp(options: RickAndMortyAppOptions(isMock: true),));
}
