// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/modules/google_sign_in/google_sign_in_auth_module.dart';
import 'package:rick_and_morty_flutter_proj/core/dataProvider/mock/mock_data_client.dart';
import 'package:rick_and_morty_flutter_proj/core/repository/store/store.dart';
import 'package:rick_and_morty_flutter_proj/dataLayer/repositories/mock/mock_character_list_repository.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_list/vm/list_vm.dart';

import 'package:mocktail/mocktail.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ListEvent(ListState.idle));
  });

  group('Test CharacterListRepository', () {
    //Init dependencies

    final store = InMemoryStore();
    final client = MockDataClient(store: store, authModule: GoogleSignInAuthModule(store));
    final repository = MockCharacterListRepository(client);

    test('isFetchPage successful', () async {
      repository.getCharacterList(ListType.basic, false);
      expect(repository.characterListService.response != null && repository.characterListService.response!.results.isNotEmpty, true);
    });

    test('Does fetchPage has no error', () async {
      repository.getCharacterList(ListType.basic, false);
      expect(repository.characterListService.error == null, true);
    });

    test('Can filter list by ListFilterMode.none if source has no successful response', () async {
      repository.getCharacterList(ListType.basic, false);

      expect(repository.characterListByType.isEmpty, true);
    });

    test('Can filter list by ListFilterMode.none if source has successful response', () async {
      repository.getCharacterList(ListType.basic, true);
      repository.filterAllPagesListByFilterMode(ListType.basic, false);

      expect(repository.characterListByType.isNotEmpty, true);
    });

    test('Does page number iterates after first fetch', () async {
      repository.characterListService.requestDataModel.pageNum = 1;
      repository.getCharacterList(ListType.basic, true);

      expect(repository.characterListService.requestDataModel.pageNum, 2);
    });
  });
}
