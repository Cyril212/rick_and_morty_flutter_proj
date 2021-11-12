import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:prefs/prefs.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/rick_morty_list_screen.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'core/dataProvider/client/data_client.dart';
import 'core/repository/store/store.dart';
import 'dataLayer/repositories/character_list_repository.dart';
import 'dataLayer/requests/character_list_request.dart';
import 'dataLayer/service/character_list_service.dart';

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
          BlocProvider(
              create: (context) => RickMortyListVM(CharacterListRepository(
                  context.read<DataClient>(), [CharacterListService(context.read<DataClient>().manager, CharacterListRequest())]))),
        ],
        child: MaterialApp(
          title: 'Rick and Morty',
          onGenerateRoute: onGenerateRoute,
          initialRoute: RickMortyListScreen.route,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            backgroundColor: const Color(0xFF736AB7),
            textTheme: const TextTheme(
                bodyText1: TextStyle(color: Colors.white),
                bodyText2: TextStyle(color: Colors.white),
                caption: TextStyle(color: Colors.white),
                overline: TextStyle(color: Colors.white)),
          ),
        ));
  }
}
