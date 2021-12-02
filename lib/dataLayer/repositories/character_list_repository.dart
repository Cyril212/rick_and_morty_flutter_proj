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

import 'mediators/character_list_mediator.dart';

enum ListMode { basic, basicSearch }

///CharacterListSource to communicate between CharacterListVM and DataSource
class CharacterListRepository extends BaseRepository {
  late final CharacterListMediator characterListsMediator;

  ListType _currentListType = ListType.basic;

  List<Character> _currentList = [];

  /// Gets current character list
  List<Character> get currentList => _currentList;

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
    _setCurrentListByType(RepositoryNotifyState.service);
  }

  @override
  void onBroadcastDataFromStore(String dataId) {
    _setCurrentListByType(RepositoryNotifyState.store);
  }

  ///Filters list by [listFilterMode], then in case [searchPhrase] != null filters list by searchPhrase
  void _setCurrentListByType(RepositoryNotifyState state) {

    switch (_currentListType) {
      case ListType.basic:
        List<Character> listFromResponse = characterListService.response?.results ?? [];

        _currentList = characterListsMediator.mergedCharacterListWithFavouriteStorage(listFromResponse);
        break;
      case ListType.favourite:
        _currentList = characterListsMediator.favouriteList;
        break;
    }
    notify(state);
  }

  ///Response is processed in [onBroadcastDataFromService()]
  Future _fetchCharacterList({bool shouldFetch = false}) {
    characterListsMediator.setPageNumToRequestByListMode();

    return client
        .executeService(characterListService, HttpOperation.get, fetchPolicy: shouldFetch == true ? FetchPolicy.network : FetchPolicy.cache)
        .then((service) {
      if (mainService.requestDataModel.fetchPolicy != FetchPolicy.cache) {
        characterListsMediator.setNextPageNumToListByListMode(service.response?.info.nextPageNum);
      }
    });
  }

  ///Response is processed in [onBroadcastDataFromStore()]
  void _getFavouritesCharacterList() => onBroadcastDataFromStore(AppConstants.kFavouriteListDataId);

  /// Gets new page if [shouldFetch] is true, otherwise calls [filterAllPagesListByFilterMode()] to update [characterListByType]
  void getCharacterList({ListType listType = ListType.basic, bool shouldFetch = false}) async {
    _currentListType = listType;

    switch (listType) {
      case ListType.basic:
        _fetchCharacterList(shouldFetch: shouldFetch);
        break;
      case ListType.favourite:
        _getFavouritesCharacterList();
        break;
    }
  }

  /// Resets page number due to new search phrase, and actualize list depending on [isSearchPhraseNotEmpty]
  void getCharacterListBySearchPhrase({ListType listFilterType = ListType.basic, String searchPhrase = ""}) {
    //Each time there's new search phrase we should reset pageNumber.
    characterListsMediator
      ..setSearchPhrase(searchPhrase)
      ..setDefaultPageNum();

    getCharacterList(listType: listFilterType, shouldFetch: searchPhrase.isNotEmpty);
  }
}
