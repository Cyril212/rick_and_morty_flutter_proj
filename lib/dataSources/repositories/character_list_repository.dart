import 'dart:async';

import 'package:rick_and_morty_flutter_proj/core/dataProvider/client/data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/service.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/source_exception.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/abstract_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';

import 'character_pagination_controller.dart';
import 'helpers/favourites_storage_helper.dart';

///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends AbstractRepository<Character> {
  late final CharacterPaginationController _basicListPagination;
  late final CharacterPaginationController _searchListPagination; //todo: lazy init

  late FavouritesStorageHelper favouritesStorageHelper;

  final DataClient client;

  String? searchPhrase;

  /// Init
  CharacterListRepository(this.client, List<Service> serviceList) : super(serviceList) {
    _basicListPagination = CharacterPaginationController(_characterListSource);
    _searchListPagination = CharacterPaginationController(_characterListSource);

    favouritesStorageHelper = FavouritesStorageHelper(client, _basicListPagination, _searchListPagination);
  }

  /// Gets [CharacterListSource]
  CharacterListService get _characterListSource => (sources[0] as CharacterListService);

  /// Gets current character list
  List<Character> characterListByMode = [];

  /// Gets error to send error state in CharacterListVM
  SourceException? get error => _characterListSource.error;

  @override
  void registerServices() {
    for (var element in sources) {
      element.registerSource(client.manager);
    }
  }

  @override
  void unregisterServices() {
    for (var element in sources) {
      element.unregisterSource(client.manager, int.parse(element.sourceId));
    }
  }

  /// Gets true if response contains link to next page otherwise returns null
  bool hasNextPage() {
    if (searchPhrase != null && searchPhrase!.isEmpty) {
      return _basicListPagination.hasNextPage;
    } else {
      return _searchListPagination.hasNextPage;
    }
  }

  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  void _filterAllPagesListByFilterMode(ListType listFilterMode, bool shouldFetch) {
    //merge new response with characters from store
    List<Character> listFromResponse = _characterListSource.response!.results;

    switch (listFilterMode) {
      case ListType.basic:
        if (searchPhrase != null && searchPhrase!.isNotEmpty) {
          characterListByMode = _searchListPagination.updateAllPages(characterListByMode, listFromResponse, favouritesStorageHelper.getFavouriteCharacters(), shouldFetch);
        } else {
          characterListByMode =  _basicListPagination.updateAllPages(characterListByMode,  listFromResponse, favouritesStorageHelper.getFavouriteCharacters(), shouldFetch);
        }
        break;
      case ListType.favourite:
        characterListByMode = favouritesStorageHelper.filterFavouritesListBySearch(searchPhrase);
        break;
    }
  }

  @override
  void broadcast(service) {
    _filterAllPagesListByFilterMode(ListType.basic, true);
    emit(service);
  }

  void _incrementPage() {
    int resultPage;
    if (searchPhrase?.isEmpty ?? true) {
      resultPage = _basicListPagination.incrementPage();
    } else {
      resultPage = _searchListPagination.incrementPage();
    }
    _characterListSource.requestDataModel.pageNum = resultPage;
  }

  /// Gets new page if [allowFetch] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByMode]
  void getCharacterList([ListType listFilterMode = ListType.basic, bool refreshList = false]) async {
    _characterListSource.requestDataModel.name = searchPhrase;

    if (refreshList) {
      client.executeQuery(_characterListSource).then((value) {
        _incrementPage();
        return value;
      });
    } else {
      _filterAllPagesListByFilterMode(listFilterMode, false);

      emit(_characterListSource);
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
