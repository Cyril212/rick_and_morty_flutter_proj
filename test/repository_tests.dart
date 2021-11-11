// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_manager.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/repositories/mock/mock_character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/service/mock/mock_character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';

import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const ListEvent(ListState.idle));
  });

  group('Test CharacterListRepository', ()  {

    //Init dependencies
    final client = MockDataClient(store: InMemoryStore(), manager: MockManager(""));
    final source = MockCharacterListService(client.manager, CharacterListRequest(""));
    final repository = MockCharacterListRepository(client, [source]);

    test('isFetchPage successful', () async {
      MockCharacterListService source = await repository.fetchResult();
      expect(source.response != null && source.response!.results.isNotEmpty, true);
    });

    test('Does fetchPage has no error', () async {
      MockCharacterListService source = await repository.fetchResult();
      expect(source.error == null, true);
    });

    test('Can filter list by ListFilterMode.none if source has no successful response', () async {
      repository._filterAllPagesListByFilterMode(ListType.basic, false);

      expect(repository.currentList.isEmpty, true);
    });

    test('Can filter list by ListFilterMode.none if source has successful response', () async {
      await repository.fetchCharacterList(ListType.basic, true);
      repository._filterAllPagesListByFilterMode(ListType.basic, false);

      expect(repository.currentList.isNotEmpty, true);
    });

    test('Does page number iterates after first fetch', () async {
      source.requestDataModel.pageNum = 1;
      await repository.fetchCharacterList(ListType.basic, true);

      expect(source.requestDataModel.pageNum, 2);
    });

    test('is list filtered by phrase', () async {
      await repository.fetchCharacterList(ListType.basic, true);

      repository.setPhraseAndTryToSearch("Rick S");

      expect("Rick Sanchez", repository.currentList.firstWhere((character) => character.name == "Rick Sanchez").name);
    });

  });
}
