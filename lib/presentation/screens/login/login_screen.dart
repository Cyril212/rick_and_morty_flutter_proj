import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/model/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/registration/registration_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/buttons/rm_text_form.dart';
import 'package:sign_button/sign_button.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/rick_morty_list_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  static const String route = '/';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController;
  final TextEditingController _passwordController;

  LoginScreen({Key? key})
      : _emailController = TextEditingController(),
        _passwordController = TextEditingController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => context.read<AuthProvider>().autologinIfPossible());

    return Scaffold(
      backgroundColor: kColorPrimary,
      body: BlocConsumer<AuthProvider, AuthEvent>(
        listener: (context, event) {
          if (event.status == AuthStatus.authenticated) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            pushNamed(context, RickMortyListScreen.route).then((value) => context.read<AuthProvider>());
          } else if (event.status == AuthStatus.loading) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Loading"),
              backgroundColor: Colors.blue,
            ));
          } else if (event.status != AuthStatus.uninitialized) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(event.message),
              backgroundColor: Colors.blue,
            ));
          }
        },
        builder: (context, state) {
          return Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      child: Image.asset(
                    "assets/images/ic_rick.png",
                    height: 150,
                    width: 150,
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  RMTextFormField.email(
                    controller: _emailController,
                  ),
                  RMTextFormField.password(
                    controller: _passwordController,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 42.0),
                    child: TextButton(
                        onPressed: () {
                          pushNamed(context, RegistrationScreen.route);
                        },
                        child: const Text(
                          "Register user",
                          textAlign: TextAlign.end,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: PrimaryButton(
                        label: "Sign in",
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            final credentials = EmailSignInCredentials(email: _emailController.text, password: _passwordController.text);
                            context.read<AuthProvider>().signInWithEmail(credentials: credentials);
                          }
                        }),
                  ),
                  SignInButton(
                    buttonType: ButtonType.google,
                    onPressed: () {
                      context.read<AuthProvider>().signInWithGoogle();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
