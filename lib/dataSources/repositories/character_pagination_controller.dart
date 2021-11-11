import 'package:collection/src/iterable_extensions.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/pagination_controller.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/character_list_service.dart';

class CharacterPaginationController extends PaginationController<Character> {
  CharacterListService service;

  CharacterPaginationController(this.service);

  @override
  bool get hasNextPage => service.response?.info.next != null;

  void updateAllPages(
      List<Character> characterListByMode, List<Character> characterListFromResponse, List<Character> favouriteCharacterList, bool shouldFetch) {
    if (shouldFetch) {
      if (allPagesList.isNotEmpty && service.requestDataModel.pageNum > 2) {
        List<Character> tmp = List.from(allPagesList);// to avoid concurrent modification
        tmp.addAll(characterListFromResponse);
        allPagesList = tmp;
      } else {
        allPagesList = characterListFromResponse;
      }
    }

    mergeWithFavouriteStorage(favouriteCharacterList);
  }

  @override
  void setDefaultPage() {
    super.setDefaultPage();
    service.requestDataModel.pageNum = 1;
  }

  /// Merges [allPagesList] isFavourite state with [allPagesList]
  void mergeWithFavouriteStorage(List<Character> favouriteCharacterList) {
    for (var page in allPagesList) {
      page.isFavourite = false;
    }

    for (var characterFromAllPageList in allPagesList) {
      final characterById = favouriteCharacterList.firstWhereOrNull((element) => element.id == characterFromAllPageList.id);
      if (characterById != null) {
        characterFromAllPageList.isFavourite = characterById.isFavourite;
      }
    }
  }
}
