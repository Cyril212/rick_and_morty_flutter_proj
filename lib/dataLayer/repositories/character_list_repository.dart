import 'dart:async';

import 'package:rick_and_morty_flutter_proj/constants/app_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/manager/rest_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/list_vm.dart';

import 'character_pagination_controller.dart';
import 'helpers/favourites_storage_helper.dart';

///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends BaseRepository<Character> {
  late final CharacterPaginationController _basicListPagination;
  late final CharacterPaginationController _searchListPagination;

  late FavouritesStorageHelper favouritesStorageHelper;

  String? searchPhrase;

  ListType lastListType = ListType.basic;

  /// Gets current character list
  List<Character> characterListByMode = [];

  /// Init
  CharacterListRepository(client)
      : super(
            client: client,
            dataIdList: [AppConstants.kFavouriteListDataId],
            serviceList: [CharacterListService(client.manager, CharacterListRequest())]) {
    _basicListPagination = CharacterPaginationController(_characterListService);
    _searchListPagination = CharacterPaginationController(_characterListService);

    favouritesStorageHelper = FavouritesStorageHelper<DataClient>(client, _basicListPagination, _searchListPagination);
  }

  /// Gets [CharacterListSource]
  CharacterListService get _characterListService => (services[0] as CharacterListService);

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => _characterListService.error;

  bool get isSearchPhraseNotEmpty => searchPhrase != null && searchPhrase!.isEmpty;

  @override
  void onBroadcastDataFromService(service) {
    _filterAllPagesListByFilterMode(true, type: lastListType);
    notify();
  }

  @override
  void onBroadcastDataFromStore(String dataId) {
    _filterAllPagesListByFilterMode(false, type: lastListType);
    notify();
  }

  /// Gets true if response contains link to next page otherwise returns null
  bool hasNextPage() {
    if (isSearchPhraseNotEmpty) {
      return _basicListPagination.hasNextPage;
    } else {
      return _searchListPagination.hasNextPage;
    }
  }

  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  void _filterAllPagesListByFilterMode(bool shouldFetch, {ListType type = ListType.basic}) {
    //merge new response with characters from store
    List<Character> listFromResponse = _characterListService.response?.results ?? [];

    switch (type) {
      case ListType.basic:
        if (isSearchPhraseNotEmpty) {
          characterListByMode = _searchListPagination.updateAllPages(
              characterListByMode, listFromResponse, favouritesStorageHelper.getFavouriteCharacters(), shouldFetch);
        } else {
          characterListByMode = _basicListPagination.updateAllPages(
              characterListByMode, listFromResponse, favouritesStorageHelper.getFavouriteCharacters(), shouldFetch);
        }
        break;
      case ListType.favourite:
        characterListByMode = favouritesStorageHelper.filterFavouritesListBySearch(searchPhrase);
        break;
    }

    lastListType = type;
  }

  void _incrementPage() {
    int resultPage;
    if (searchPhrase?.isEmpty ?? true) {
      resultPage = _basicListPagination.incrementPage();
    } else {
      resultPage = _searchListPagination.incrementPage();
    }
    _characterListService.requestDataModel.pageNum = resultPage;
  }

  /// Gets new page if [refreshList] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByMode]
  void getCharacterList([ListType listType = ListType.basic, bool refreshList = false]) async {
    _characterListService.requestDataModel.name = searchPhrase;

    if (refreshList) {
      client.executeService(_characterListService, HttpOperation.get).then((value) {
        _incrementPage();
        return value;
      });
    } else {
      _filterAllPagesListByFilterMode(false, type: listType);

      notify();
    }
  }

  /// Resets page number, only called during search bar input
  void _setDefaultSearchPage() {
    _searchListPagination.setDefaultPage();
  }

  /// Resets page number and fetches new response
  void setDefaultPageAndGetCharacterList([ListType listFilterMode = ListType.basic]) {
    _setDefaultSearchPage();
    getCharacterList(listFilterMode, true);
  }
}
