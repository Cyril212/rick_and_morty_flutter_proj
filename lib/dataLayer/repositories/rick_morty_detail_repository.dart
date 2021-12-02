import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/helpers/character_storage_helper.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/cache/character_list_cache_handler.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';

class RickMortyDetailRepository extends BaseRepository {
  late CharacterStorageHelper characterStorageHelper;

  RickMortyDetailRepository(DataClient client)
      : super(client: client, serviceList: [CharacterListService(client.manager, CharacterListRequest(FetchPolicy.network))]) {
    characterStorageHelper = CharacterStorageHelper(client, mainService.cache as CharacterListCacheHandler);
  }

  Character getCharacter(int characterId) => characterStorageHelper.getCharacterById(characterId);

  void setFavouriteCharacter(Character character, bool state) {
    characterStorageHelper.putFavouriteCharacter(character, state);
  }
}
