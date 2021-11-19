import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/request_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/model/response_data_model.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';

class RickMortyDetailRepository extends BaseRepository {
  RickMortyDetailRepository(client)
      : super(
      client: client,
      dataIdList: [AppConstants.kFavouriteListDataId]);

  @override
  void onBroadcastDataFromService(Service service) {
    // TODO: implement onBroadcastDataFromService
  }

  @override
  void onBroadcastDataFromStore(String dataId) {
    // TODO: implement onBroadcastDataFromStore
  }

}