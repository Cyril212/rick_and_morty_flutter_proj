import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:prefs/prefs.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/rick_morty_list_screen.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'constants/text_constants.dart';
import 'constants/theme_constants.dart';
import 'core/dataProvider/client/data_client.dart';
import 'core/repository/store/store.dart';
import 'dataLayer/repositories/character_list_repository.dart';

/// Endpoint
void main() async {
  await initHiveForFlutter();
  await Prefs.init();

  runApp(const RickAndMortyApp());
}

/// Init Hive database to be able to interact with [boxes]
Future<void> initHiveForFlutter({String? subDir, Iterable<String> boxes = const [HiveStore.defaultBoxName]}) async {
  await Hive.initFlutter();
  await Hive.openBox(HiveStore.defaultBoxName);
}

/// Init Hive database to be able to interact with [boxes]
class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({Key? key}) : super(key: key);

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<DataClient>(
            lazy: false,
            create: (context) => DataClient(),
          ),
          BlocProvider(create: (context) => RickMortyListVM(CharacterListRepository(context.read<DataClient>()))),
        ],
        child: MaterialApp(
          title: appTitle,
          onGenerateRoute: onGenerateRoute,
          initialRoute: RickMortyListScreen.route,
          theme: ThemeData(
            primarySwatch: kMaterialColorBlue,
            backgroundColor: kColorPrimary,
            textTheme: textTheme,
          ),
        ));
  }
}
