import 'package:flutter/cupertino.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/base_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/helpers/favourites_storage_helper.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/services/mock/mock_character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/list_vm.dart';

import '../character_pagination_controller.dart';

class MockCharacterListRepository extends BaseRepository<Character> {
  final MockDataClient client;

  late final CharacterPaginationController _basicListPagination;
  late final CharacterPaginationController _searchListPagination; //todo: lazy init

  late FavouritesStorageHelper favouritesStorageHelper;
  late String? searchPhrase;

  /// Init
  MockCharacterListRepository(this.client) : super(serviceList: [MockCharacterListService(client.manager, CharacterListRequest())]) {
    _basicListPagination = CharacterPaginationController(characterListService);
    _searchListPagination = CharacterPaginationController(characterListService);

    favouritesStorageHelper = FavouritesStorageHelper(client, _basicListPagination, _searchListPagination);
  }

  @override
  List<Service> get services => [MockCharacterListService(client.manager, CharacterListRequest())];

  /// Gets [CharacterListSource]
  @visibleForTesting
  CharacterListService get characterListService => (services[0] as CharacterListService);

  /// Gets current character list
  List<Character> characterListByMode = [];

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => characterListService.error;

  bool get isSearchPhraseNotEmpty => searchPhrase != null && searchPhrase!.isEmpty;

  @override
  void registerServices() {
    for (var element in services) {
      element.registerService(client.manager);
    }
  }

  @override
  void unregisterServices() {
    for (var element in services) {
      element.unregisterSource(client.manager, int.parse(element.serviceId));
    }
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
  void filterAllPagesListByFilterMode(ListType listFilterMode, bool shouldFetch) {
    //merge new response with characters from store
    List<Character> listFromResponse = characterListService.response!.results;

    switch (listFilterMode) {
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
  }

  @override
  void broadcast(service) {
    filterAllPagesListByFilterMode(ListType.basic, true);
    emit(service);
  }

  void _incrementPage() {
    int resultPage;
    if (searchPhrase?.isEmpty ?? true) {
      resultPage = _basicListPagination.incrementPage();
    } else {
      resultPage = _searchListPagination.incrementPage();
    }
    characterListService.requestDataModel.pageNum = resultPage;
  }

  /// Gets new page if [allowFetch] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByMode]
  Future getCharacterList([ListType listFilterMode = ListType.basic, bool refreshList = false]) async {
    characterListService.requestDataModel.name = searchPhrase;

    if (refreshList) {
      return client.executeService(characterListService).then((value) {
        _incrementPage();
        return value;
      });
    } else {
      filterAllPagesListByFilterMode(listFilterMode, false);

      emit(characterListService);

      return Future.value();
    }
  }

  void _setDefaultSearchPage() {
    _searchListPagination.setDefaultPage();
  }

  void setDefaultPageAndGetCharacterList([ListType listFilterMode = ListType.basic]) {
    _setDefaultSearchPage();
    getCharacterList(listFilterMode, true);
  }
}
