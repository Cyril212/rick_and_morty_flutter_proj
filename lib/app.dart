import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/interceptor/default_interceptor.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/interceptor/mock_interceptor.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/rick_morty_list_vm.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/splash/splash_screen.dart';

import 'constants/text_constants.dart';
import 'constants/theme_constants.dart';
import 'core/dataProvider/client/data_client.dart';
import 'core/repository/store/credentials_store.dart';
import 'core/repository/store/store.dart';
import 'core/router/router_v1.dart';
import 'dataLayer/repositories/character_list_repository.dart';

class RickAndMortyAppOptions {
  final bool isMock;

  const RickAndMortyAppOptions({this.isMock = false});
}

/// Init Hive database to be able to interact with [boxes]
class RickAndMortyApp extends StatelessWidget {
  final RickAndMortyAppOptions _options;

  const RickAndMortyApp({Key? key, RickAndMortyAppOptions? options})
      : _options = options ?? const RickAndMortyAppOptions(),
        super(key: key);

  /// This widget is the root of your application.
  @override
  Widget build(BuildContext buildContext) {
    return MultiProvider(
        providers: [
          Provider<HiveStore>(
            lazy: false,
            create: (context) => HiveStore(),
          ),
          Provider<CredentialsStore>(
            lazy: false,
            create: (context) => const CredentialsStore(),
          ),
          Provider<GoogleSignInAuthModule>(
            lazy: false,
            create: (context) =>
                GoogleSignInAuthModule(context.read<HiveStore>()),
          ),
          Provider<EmailAuthModule>(
            lazy: false,
            create: (context) => EmailAuthModule(
                context.read<HiveStore>(), context.read<CredentialsStore>()),
          ),
          Provider<AuthProvider>(
            lazy: false,
            create: (context) => AuthProvider(context.read<HiveStore>(),
                credentialsStore: context.read<CredentialsStore>(),
                emailSignInAuthModule: context.read<EmailAuthModule>(),
                googleSignInAuthModule: context.read<GoogleSignInAuthModule>()),
          ),
          Provider<RestManager>(
            lazy: false,
            create: (context) => RestManager(
                baseUrl: "https://rickandmortyapi.com/api",
                customInterceptor:
                    _options.isMock ? MockInterceptor() : DefaultInterceptor()),
          ),
          Provider<DataClient>(
            lazy: false,
            create: (context) => DataClient(
                authenticationManager: context.read<AuthProvider>(),
                store: context.read<HiveStore>(),
                manager: context.read<RestManager>()),
          ),
          BlocProvider(
              create: (context) => RickMortyListVM(
                  CharacterListRepository(context.read<DataClient>()))),
        ],
        child: MaterialApp(
          title: TextConstants.kAppTitle,
          onGenerateRoute: onGenerateRoute,
          initialRoute: SplashScreen.route,
          theme: ThemeData(
            primarySwatch: kMaterialColorBlue,
            backgroundColor: kColorPrimary,
            textTheme: kTextTheme,
          ),
        ));
  }
}
