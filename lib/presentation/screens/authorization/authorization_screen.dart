import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/auth/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/rick_morty_list_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/primary_button.dart';

class AuthorizationScreen extends StatefulWidget {
  static const String route = '/';

  const AuthorizationScreen({Key? key}) : super(key: key);

  @override
  _AuthorizationScreenState createState() => _AuthorizationScreenState();
}

class _AuthorizationScreenState extends State<AuthorizationScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => context.read<AuthProvider>().autologinIfPossible());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorPrimary,
      body: BlocConsumer<AuthProvider, AuthStatus>(
        listener: (context, state) {
          if (state == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            pushNamed(context, RickMortyListScreen.route);
          } else if (state == AuthStatus.loading) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Loading"),
              backgroundColor: Colors.blue,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Oops, something went wrong!"),
              backgroundColor: Colors.blue,
            ));
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: Image.asset("assets/images/ic_rick.png")),
                Flexible(
                  child: PrimaryButton(
                      label: "Sign in with Google",
                      onPress: () {
                        context.read<AuthProvider>().authorizeWithGoogle();
                      }),
                ),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: PrimaryButton(
                      label: "Proceed as anonymous",
                      onPress: () {
                        pushNamed(context, RickMortyListScreen.route);
                      }),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
