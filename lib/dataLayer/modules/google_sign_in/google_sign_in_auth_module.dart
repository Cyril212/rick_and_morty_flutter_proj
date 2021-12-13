import 'package:rick_and_morty_flutter_proj/core/dataProvider/module/base_authentication_module.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_repository.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/common_user_store.dart';

class GoogleSignInAuthModule extends BaseAuthenticationModule {
  GoogleSignInAuthModule(store) : super(store, GoogleSignInRepository(store: store, userStore: CommonUserStore(store: store)));
}
