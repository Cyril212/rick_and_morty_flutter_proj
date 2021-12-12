import 'package:flutter/foundation.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

typedef UnauthorizedRequestHandler = Function();

///DataClient to communicate with [RestManager] for more [BaseDataClient]
class DataClient extends BaseDataClient<RestManager> {
  final AuthProvider authenticationManager;
  final InMemoryStore cache;

  DataClient({required this.authenticationManager, @required store})
      : cache = InMemoryStore(),
        super(
          manager: RestManager(
              baseUrl: "https://rickandmortyapi.com/api",
              onUnauthenticatedRequest: () {
                authenticationManager.logOut();
              }),
          store: store,
        );
}
