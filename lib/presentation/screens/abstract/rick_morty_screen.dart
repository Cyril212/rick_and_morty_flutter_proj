import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/auth_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

abstract class RickMortyScreenState<T extends AbstractScreen> extends AbstractScreenState {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationManager, AuthStatus>(listener: (context, state) {
      final String message;
      switch (state) {
        case AuthStatus.loading:
          message = "loading";
          break;
        case AuthStatus.uninitialized:
          message = "uninitialized";
          break;
        case AuthStatus.authenticateError:
          message = "authenticateError";
          break;
        case AuthStatus.authenticateErrorUserNotExist:
          message = "authenticateErrorUserNotExist";
          break;
        case AuthStatus.authenticateErrorUserAlreadyExists:
          message = "authenticateErrorUserAlreadyExists";
          break;
        case AuthStatus.authenticateCanceled:
          message = "authenticateCanceled";
          break;
        case AuthStatus.authenticated:
          message = "authenticated";
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    }, builder: (context, authStatus) {
      return super.build(context);
    });
  }
}
