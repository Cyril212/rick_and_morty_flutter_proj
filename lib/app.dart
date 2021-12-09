import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/auth/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/authorization/authorization_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

import 'constants/text_constants.dart';
import 'constants/theme_constants.dart';
import 'core/dataProvider/client/data_client.dart';
import 'core/repository/store/store.dart';
import 'core/router/router_v1.dart';
import 'dataLayer/repositories/character_list_repository.dart';

/// Init Hive database to be able to interact with [boxes]
class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({Key? key}) : super(key: key);

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext buildContext) {
    return MultiProvider(
        providers: [
          Provider<HiveStore>(
            lazy: false,
            create: (context) => HiveStore(),
          ),
          Provider<AuthProvider>(
            lazy: false,
            create: (context) => AuthProvider(context.read<HiveStore>()),
          ),
          Provider<DataClient>(
            lazy: false,
            create: (context) => DataClient(store: context.read<HiveStore>(), authenticationManager: context.read<AuthProvider>()),
          ),
          BlocProvider(create: (context) => RickMortyListVM(CharacterListRepository(context.read<DataClient>()))),
        ],
        child: MaterialApp(
          title: TextConstants.kAppTitle,
          onGenerateRoute: onGenerateRoute,
          initialRoute: AuthorizationScreen.route,
          theme: ThemeData(
            primarySwatch: kMaterialColorBlue,
            backgroundColor: kColorPrimary,
            textTheme: kTextTheme,
          ),
        ));
  }
}
