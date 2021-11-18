import 'package:flutter/foundation.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/auth_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';


typedef UnauthorizedRequestHandler = Function();

///DataClient to communicate with [RestManager] for more [BaseDataClient]
class DataClient extends BaseDataClient<RestManager> {
  final AuthenticationManager authenticationManager;

  DataClient({required this.authenticationManager, @required store})
      : super(
          manager: RestManager(
              baseUrl: "https://rickandmortyapi.com/api",
              onUnauthenticatedRequest: () {
                authenticationManager.logOut();
              }),
          store: store,
        );
}
