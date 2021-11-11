import 'package:rick_and_morty_flutter_proj/core/repository/pagination_controller.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/character_list_service.dart';

class CharacterPaginationController extends PaginationController<Character> {

  CharacterListService service;

  CharacterPaginationController(this.service);

  @override
  bool get hasNextPage => service.response?.info.next != null;

  void fillAllPagesList(List<Character> characterListByMode, List<Character> mergedFavouritesCharacterFromStore){
    if (allPagesList.isNotEmpty && service.requestDataModel.pageNum > 2) {
      List<Character> tmp = List.from(allPagesList);
      tmp.addAll(mergedFavouritesCharacterFromStore);
      allPagesList = tmp;
    } else {
      allPagesList = mergedFavouritesCharacterFromStore;
    }
  }

  @override
  void setDefaultPage() {
    // TODO: implement setDefaultPage
    super.setDefaultPage();
    service.requestDataModel.pageNum = 1;
  }

  /// Merges [allPagesList] isFavourite state with [currentList]
  void setCurrentFavouriteStateFromCurrentListMode(List<Character> currentList) {
    for (var mergedCharacter in allPagesList) {
      for (var character in currentList) {
        if (mergedCharacter.id == character.id) {
          mergedCharacter.isFavourite = character.isFavourite;
        }
      }
    }
  }


}
