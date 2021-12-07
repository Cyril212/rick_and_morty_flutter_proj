import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/mediators/pagination_list_mediator.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/character_pagination_controller.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/helpers/character_storage_helper.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';

import '../character_list_repository.dart';

class CharacterListMediator extends PaginationListMediator {
  final CharacterPaginationController _basicList;
  final CharacterPaginationController _basicSearchList;

  late CharacterStorageHelper characterStorageHelper;

  final CharacterListService _characterListService;

  CharacterListMediator(DataClient client, this._characterListService)
      : _basicList = CharacterPaginationController(_characterListService),
        _basicSearchList = CharacterPaginationController(_characterListService) {
    characterStorageHelper = CharacterStorageHelper<DataClient>(client, _characterListService.cache);
  }

  String? get _currentSearch => _basicSearchList.service.requestDataModel.name;

  bool get _isCurrentSearchNotEmpty => _currentSearch != null && _currentSearch!.replaceAll(" ", "").isNotEmpty;

  ListMode get _basicListMode => _isCurrentSearchNotEmpty ? ListMode.basicSearch : ListMode.basic;

  List<Character> get favouriteList => _isCurrentSearchNotEmpty
      ? characterStorageHelper.getFavouriteCharactersBySearch(_currentSearch!)
      : characterStorageHelper.getFavouriteCharacters();

  List<Character> mergedCharacterListWithFavouriteStorage(List<Character> characterListFromResponse) {
    switch (_basicListMode) {
      case ListMode.basic:
        return _basicList.mergedCharacterListWithFavouriteStorage(characterStorageHelper.getFavouriteCharacters(), characterListFromResponse);
      case ListMode.basicSearch:
        return _basicSearchList.mergedCharacterListWithFavouriteStorage(characterStorageHelper.getFavouriteCharacters(), characterListFromResponse);
    }
  }

  /// Gets true if response contains link to next page otherwise returns null
  @override
  bool hasNextPage() {
    switch (_basicListMode) {
      case ListMode.basic:
        return _basicList.hasNextPage;
      case ListMode.basicSearch:
        return _basicSearchList.hasNextPage;
    }
  }

  @override
  void setNextPageNumToListByListMode(int? nextPageNum) {
    //we are at the last page
    if (nextPageNum != null) {
      switch (_basicListMode) {
        case ListMode.basic:
          _basicList.pageNumber = nextPageNum;
          break;
        case ListMode.basicSearch:
          _basicSearchList.pageNumber = nextPageNum;
          break;
      }
    }

    setPageNumToRequestByListMode(nextPageNum);
  }

  @override
  void setPageNumToRequestByListMode([int? pageNum]) {
    switch (_basicListMode) {
      case ListMode.basic:
        _characterListService.requestDataModel.pageNum = pageNum ?? _basicList.pageNumber;
        break;
      case ListMode.basicSearch:
        _characterListService.requestDataModel.pageNum = pageNum ?? _basicSearchList.pageNumber;
        break;
    }
  }

  @override
  void setDefaultPageNum() {
    switch (_basicListMode) {
      case ListMode.basic:
        break;
      case ListMode.basicSearch:
        _basicSearchList.setDefaultPage();
        break;
    }
  }

  @override
  void setSearchPhrase(String searchPhrase) {
    _characterListService.requestDataModel.name = searchPhrase;
  }
}