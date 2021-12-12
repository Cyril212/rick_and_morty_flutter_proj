import 'package:flutter/material.dart';

@immutable
class EmailSignInCredentials{
  final String email;
  final String password;

  const EmailSignInCredentials({required this.email, required this.password});
}