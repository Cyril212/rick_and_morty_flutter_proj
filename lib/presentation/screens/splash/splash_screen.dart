import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/login/login_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/rick_morty_list_screen.dart';

import 'widgets/splash_loading_indicator_widget.dart';

class SplashScreen extends StatelessWidget {
  static const String route = '/';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => context.read<AuthProvider>().autologinIfPossible());

    return BlocConsumer<AuthProvider, AuthEvent>(listener: (context, event) {
      if (event.status == AuthStatus.authenticated) {
        pushNamedNewStack(context, RickMortyListScreen.route).then((value) => context.read<AuthProvider>());
      } else if (event.status == AuthStatus.uninitialized) {
        pushNamedNewStack(context, LoginScreen.route);
      }
    }, builder: (context, state) {
      return Scaffold(
        backgroundColor: kColorWhite,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/images/splash/ic_splash.png",
              ),
            ),
            if (state.status == AuthStatus.loading) const SplashLoadingIndicatorWidget()
          ],
        ),
      );
    });
  }
}
