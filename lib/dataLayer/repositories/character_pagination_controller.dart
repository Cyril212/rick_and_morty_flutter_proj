import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/pagination_controller.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';

class CharacterPaginationController extends PaginationController<Character> {
  CharacterListService service;

  CharacterPaginationController(this.service);

  @override
  bool get hasNextPage => service.response?.info.next != null;

  List<Character> updateAllPages(
      List<Character> characterListByMode, List<Character> characterListFromResponse, List<Character> favouriteCharacterList, bool shouldFetch) {
    if (shouldFetch) {
      //if it's second page of current response add it to list since some data already exist within the list
      if (allPagesList.isNotEmpty && service.requestDataModel.pageNum > 2) {
        List<Character> tmp = List.from(allPagesList); // to avoid concurrent modification
        tmp.addAll(characterListFromResponse);
        allPagesList = tmp;
      } else {
        allPagesList = characterListFromResponse;
      }
    }

    _mergeWithFavouriteStorage(favouriteCharacterList);

    return allPagesList;
  }

  @override
  void setDefaultPage() {
    super.setDefaultPage();
    service.requestDataModel.pageNum = 1;
  }

  /// Merges [favouriteCharacterList] isFavourite state with [allPagesList]
  void _mergeWithFavouriteStorage(List<Character> favouriteCharacterList) {
    for (var characterFromAllPageList in allPagesList) {
      final characterFromFavouriteListByAllPagesList = favouriteCharacterList.firstWhereOrNull((element) => element.id == characterFromAllPageList.id);

      characterFromAllPageList.isFavourite = characterFromFavouriteListByAllPagesList != null;
    }
  }
}
