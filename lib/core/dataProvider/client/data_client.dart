import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/base_data_manager.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/auth_provider.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';

typedef UnauthorizedRequestHandler = Function();

///DataClient to communicate with [RestManager] for more [BaseDataClient]
class DataClient extends BaseDataClient<RestManager> {
  final AuthProvider? authenticationManager;
  final InMemoryStore cache;

  DataClient({
    required store,
    required RestManager manager,
    this.authenticationManager,
  })  : cache = InMemoryStore(),
        super(
          manager: manager,
          store: store,
        );
}
