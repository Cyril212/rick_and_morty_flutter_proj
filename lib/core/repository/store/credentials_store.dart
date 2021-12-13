import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/email/model/email_sign_in_credentials.dart';

class CredentialsStore {
  final FlutterSecureStorage _storage;

  const CredentialsStore() : _storage = const FlutterSecureStorage();

  Future<EmailSignInCredentials?> get credentials async => _storage.read(key: AppConstants.kCredentials).then((credentials) {
        if (credentials != null) {
          return EmailSignInCredentials.fromJson(json.decode(credentials));
        }
      });

  Future<void> write(EmailSignInCredentials credentials) => _storage.write(key: AppConstants.kCredentials, value: json.encode(credentials.toJson()));

  Future clear() {
    return _storage.delete(key: AppConstants.kCredentials);
  }
}
