import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

abstract class RickMortyScreenState<T extends AbstractScreen> extends AbstractScreenState {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthProvider, AuthEvent>(listener: (context, authEvent) {
      String? message;
      switch (authEvent.status) {
        case AuthStatus.loading:
          message = "loading";
          break;
        case AuthStatus.uninitialized:
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
        case AuthStatus.registered:
          message = "user has been registered";
          break;
      }
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ));
      }
    }, builder: (context, authStatus) {
      return super.build(context);
    });
  }
}
