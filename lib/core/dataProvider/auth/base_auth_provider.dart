import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/common_user.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/common_user_store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/models/auth_event.dart';

abstract class BaseAuthProvider extends Cubit<AuthEvent> {
  @protected
  final Store store;

  @protected
  final List<BaseAuthenticationModule> auths;

  BaseAuthProvider(this.store, List<BaseAuthenticationModule> authenticationModuleList)
      : auths = authenticationModuleList,
        super(AuthEvent());

  @protected
  CommonUser? get currentUser {
    if (store.get(AppConstants.kUserDB) == null) {
      return null;
    }

    Map<String, dynamic> decodedUser = Map<String, dynamic>.from(store.get(AppConstants.kUserDB));
    return CommonUser.fromJson(decodedUser);
  }

  AuthType? get authType {
    final String? authTypeAsString = store.get(AppConstants.kAuthType);
    if (authTypeAsString != null) {
      return AuthType.values.byName(store.get(AppConstants.kAuthType));
    }
  }
}
