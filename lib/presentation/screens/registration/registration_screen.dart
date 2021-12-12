import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/login/login_screen.dart';
import 'package:sign_button/sign_button.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/email_sign_in_credentials.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/rick_morty_list_screen.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/buttons/rm_text_form.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/primary_button.dart';

class RegistrationScreen extends StatelessWidget {
  static const String route = '/registration';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController;
  final TextEditingController _passwordController;
  final TextEditingController _passwordConfirmationController;

  RegistrationScreen({Key? key})
      : _emailController = TextEditingController(),
        _passwordController = TextEditingController(),
        _passwordConfirmationController = TextEditingController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => context.read<AuthProvider>().autologinIfPossible());

    return Scaffold(
      backgroundColor: kColorPrimary,
      body: BlocConsumer<EmailAuthModule, AuthEvent>(
        listener: (context, event) {
          if (event.status == AuthStatus.registered) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Congrats!'),
                content: const Text('The user has been registered!'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      pushNamedNewStack(context, RickMortyListScreen.route);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
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
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                    Flexible(
                        child: Image.asset(
                      "assets/images/ic_rick.png",
                      height: 150,
                      width: 150,
                    )),
                    RMTextFormField.email(
                      controller: _emailController,
                    ),
                    RMTextFormField.password(
                      controller: _passwordController,
                    ),
                    RMTextFormField.confirmPassword(
                      controller: _passwordConfirmationController,
                      valueToCompareController: _passwordController,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: PrimaryButton(
                          label: "Sign up",
                          onPress: () {
                            if (_formKey.currentState!.validate()) {
                              final credentials = EmailSignInCredentials(email: _emailController.text, password: _passwordController.text);
                              context.read<EmailAuthModule>().signUp(credentials: credentials);
                            }
                          }),
                    ),
                  ])));
        },
      ),
    );
  }
}
