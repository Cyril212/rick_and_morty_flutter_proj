import 'dart:async';

import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/base_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/list_vm.dart';

import 'character_pagination_controller.dart';
import 'helpers/character_storage_helper.dart';

enum ListMode { basic, basicSearch }

abstract class PaginationListMediator {
  bool hasNextPage();

  void setNextPageNumToListByListMode(int? nextPageNum);

  void setPageNumToRequestByListMode([int? pageNum]);

  void setDefaultPageNum();

  void setSearchPhrase(String searchPhrase) {}
}

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

  List<Character> get favouriteList => characterStorageHelper.getFavouriteCharactersBySearch(_currentSearch);

  String? get _currentSearch => _characterListService.requestDataModel.name;

  bool get _isCurrentSearchNotEmpty => _currentSearch != null && _currentSearch!.replaceAll(" ", "").isNotEmpty;

  ListMode get listMode => _isCurrentSearchNotEmpty ? ListMode.basicSearch : ListMode.basic;

  List<Character> mergedCharacterListWithFavouriteStorage(List<Character> characterListFromResponse) {
    switch (listMode) {
      case ListMode.basic:
        return _basicList.mergedCharacterListWithFavouriteStorage(characterStorageHelper.getFavouriteCharacters(), characterListFromResponse);
      case ListMode.basicSearch:
        return _basicSearchList.mergedCharacterListWithFavouriteStorage(characterStorageHelper.getFavouriteCharacters(), characterListFromResponse);
    }
  }

  /// Gets true if response contains link to next page otherwise returns null
  @override
  bool hasNextPage() {
    switch (listMode) {
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
      switch (listMode) {
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
    switch (listMode) {
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
    switch (listMode) {
      case ListMode.basic:
        break;
      case ListMode.basicSearch:
        _basicSearchList.setDefaultPage();
        break;
    }
  }

  @override
  void setSearchPhrase(String searchPhrase) {
    _basicSearchList.service.requestDataModel.name = searchPhrase;
  }
}

///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends BaseRepository {
  late final CharacterListMediator characterListsMediator;

  ListType currentListType = ListType.basic;

  /// Gets current character list
  List<Character> characterListByType = [];

  /// Init
  CharacterListRepository(client)
      : super(
            client: client,
            dataIdList: [AppConstants.kFavouriteListDataId],
            serviceList: [CharacterListService(client.manager, CharacterListRequest(FetchPolicy.network))]) {
    characterListsMediator = CharacterListMediator(client, characterListService);
  }

  /// Gets [CharacterListSource]
  CharacterListService get characterListService => (services[0] as CharacterListService);

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => characterListService.response?.error;

  @override
  void onBroadcastDataFromService(response) {
    super.onBroadcastDataFromService(response);
    _setCharacterListByType();
  }

  @override
  void onBroadcastDataFromStore(String dataId) {
    _setCharacterListByType();
  }

  void setSearchPhrase(String searchPhrase) {
    characterListsMediator.setSearchPhrase(searchPhrase);
  }

  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  void _setCharacterListByType() {
    //merge new response with characters from store
    List<Character> listFromResponse = characterListService.response?.results ?? [];

    switch (currentListType) {
      case ListType.basic:
        characterListByType = characterListsMediator.mergedCharacterListWithFavouriteStorage(listFromResponse);
        break;
      case ListType.favourite:
        characterListByType = characterListsMediator.favouriteList;
        break;
    }

    notify();
  }

  /// Gets new page if [refreshList] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByType]
  void getCharacterList([ListType listType = ListType.basic, bool refreshList = false]) async {
    currentListType = listType;

    characterListsMediator.setPageNumToRequestByListMode();

    switch (listType) {
      case ListType.basic:
        client
            .executeService(characterListService, HttpOperation.get, fetchPolicy: refreshList == true ? FetchPolicy.network : FetchPolicy.cache)
            .then((service) {
          if (mainService.requestDataModel.fetchPolicy != FetchPolicy.cache) {
            characterListsMediator.setNextPageNumToListByListMode(service.response?.info.nextPageNum);
          }
        });
        break;
      case ListType.favourite:
        _setCharacterListByType();
        break;
    }
  }

  /// Resets page number due to new search phrase, and actualize list depending on [isSearchPhraseNotEmpty]
  void setDefaultPageAndGetCharacterList([ListType listFilterMode = ListType.basic]) {
    //Each time there's new search phrase we should reset pageNumber.
    characterListsMediator.setDefaultPageNum();

    getCharacterList(listFilterMode, characterListsMediator._isCurrentSearchNotEmpty);
  }
}
