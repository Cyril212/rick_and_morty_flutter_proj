import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';

abstract class BaseAuthenticationManager extends Cubit<AuthStatus> {
  final Store store;
  final List<BaseAuthenticationModule> auths;

  BaseAuthenticationManager(this.store, List<BaseAuthenticationModule> authenticationModuleList)
      : auths = authenticationModuleList,
        super(AuthStatus.uninitialized);
}