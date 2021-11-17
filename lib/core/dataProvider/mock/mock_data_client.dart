import 'package:flutter/foundation.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

import '../service.dart';
import 'mock_manager.dart';

///Mock class of DataClient
class MockDataClient extends BaseDataClient<MockManager> {
  final GoogleSignInAuthModule authModule;

  MockDataClient({required this.authModule, @required store})
      : super(
    manager: MockManager(
        baseUrl: "https://rickandmortyapi.com/api",
        onUnauthenticatedRequest: () {
          authModule.logOut();
        }),
    store: store,
  );
}
