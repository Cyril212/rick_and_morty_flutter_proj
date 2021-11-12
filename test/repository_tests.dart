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
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/mock/mock_character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/requests/character_list_request.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/service/mock/mock_character_list_service.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/list_vm.dart';

import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ListEvent(ListState.idle));
  });

  group('Test CharacterListRepository', ()  {

    //Init dependencies
    final client = MockDataClient(store: InMemoryStore(), manager: MockManager(""));
    final source = MockCharacterListService(client.manager, CharacterListRequest());
    final repository = MockCharacterListRepository(client, [source]);

    test('isFetchPage successful', () async {
     await repository.getCharacterList(ListType.basic, false);
      expect(source.response != null && source.response!.results.isNotEmpty, true);
    });

    test('Does fetchPage has no error', () async {
      await repository.getCharacterList(ListType.basic, false);
      expect(source.error == null, true);
    });

    test('Can filter list by ListFilterMode.none if source has no successful response', () async {
      repository.getCharacterList(ListType.basic, false);

      expect(repository.characterListByMode.isEmpty, true);
    });

    test('Can filter list by ListFilterMode.none if source has successful response', () async {
      await repository.getCharacterList(ListType.basic, true);
      repository.filterAllPagesListByFilterMode(ListType.basic, false);

      expect(repository.characterListByMode.isNotEmpty, true);
    });

    test('Does page number iterates after first fetch', () async {
      source.requestDataModel.pageNum = 1;
      await repository.getCharacterList(ListType.basic, true);

      expect(source.requestDataModel.pageNum, 2);
    });

  });
}
