import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/repository/store/store.dart';

void main() async {
  await initHiveForFlutter();
  
  
  runApp(const MyApp());
}

Future<void> initHiveForFlutter({String? subDir,  Iterable<String> boxes = const [ HiveStore.defaultBoxName ] }) async {

  await Hive.initFlutter();
  await Hive.openBox(HiveStore.defaultBoxName);
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // var appDir = await getApplicationDocumentsDirectory();
  // var path = appDir.path;
  // if (subDir != null) {
  //   path = join(path, subDir);
  // }
  //  Hive.init(path);
  //
  // for (var box in boxes){
  //   await Hive.openBox(box);
  // }

}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<RestClient>(
      lazy: false,
      create: (context) => RestClient(manager: RestManager("https://rickandmortyapi.com/api/")),
      child: MaterialApp(
        title: 'Rick and Morty',
        onGenerateRoute: onGenerateRoute,
        initialRoute: RickMortyListScreen.route,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          backgroundColor: Color(0xFF736AB7),
          textTheme: TextTheme(bodyText1: TextStyle(color: Colors.white),bodyText2: TextStyle(color: Colors.white),caption: TextStyle(color: Colors.white),overline: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
