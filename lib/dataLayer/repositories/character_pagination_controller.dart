import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/pagination_controller.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';

//
//It seems what you need is a wrapper for all the parameters that define a page (say, pageNumber, pageSize, sortType, totalCount, etc.) and use this DataRequest object as the key for your caching mechanism. From this point you have a number of options to handle the cache:

//Implement some sort of timeout mechanism to refresh the cache (based on how often the data changes).
//Have a listener that checks database changes and updates the cache based the above parameters.
//If the changes are done by the same process, you can always mark the cache as outdated with every change and check this flag when a page is requested.
//The first two might involve a scheduler mechanism to trigger on some interval or based on an event. The last one might be the simpler if you have a single data access point.

//Lastly, as @DanPichelman mentioned, it can quickly become an overly complicated algorithm that outweighs the benefits, so be sure the gain in performance justify the complexity of the algorithm.

class CharacterPaginationController extends PaginationController<Character> {
  final CharacterListService service;

  CharacterPaginationController(this.service);

  @override
  bool get hasNextPage => service.response?.info.next != null;

  @override
  void setDefaultPage() {
    super.setDefaultPage();
    service.requestDataModel.pageNum = 1;
  }

  /// Merges [favouriteCharacterList] isFavourite state with [allPagesList]
  List<Character> mergedCharacterListWithFavouriteStorage(List<Character> favouriteCharacterList, List<Character> characterListFromResponse) {
    List<Character> mergedCharacterList = [];

    for (var characterFromAllPageList in characterListFromResponse) {
      final characterFromFavouriteListByAllPagesList =
          favouriteCharacterList.firstWhereOrNull((element) => element.id == characterFromAllPageList.id);

      characterFromAllPageList.isFavourite = characterFromFavouriteListByAllPagesList != null;
    }
    mergedCharacterList.addAll(characterListFromResponse);

    return mergedCharacterList;
  }
}
