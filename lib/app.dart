

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/rick_morty_list_screen.dart';

import 'constants/text_constants.dart';
import 'constants/theme_constants.dart';
import 'core/dataProvider/client/data_client.dart';
import 'core/router/router_v1.dart';
import 'dataLayer/repositories/character_list_repository.dart';
import 'flavors/flavors.dart';
import 'ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

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
  Widget _flavorBanner({
    required Widget child,
    bool show = true,
  }) =>
      show
          ? Banner(
        child: child,
        location: BannerLocation.topStart,
        message: FlavorManager.name,
        color: Colors.green.withOpacity(0.6),
        textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12.0,
            letterSpacing: 1.0),
        textDirection: TextDirection.ltr,
      )
          : Container(
        child: child,
      );
}
