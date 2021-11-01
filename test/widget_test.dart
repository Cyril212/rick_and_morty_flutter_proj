// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/widgets/rick_morty_list_widget.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';

class MockRickMortyListVM extends MockCubit<CharacterListEvent> implements RickMortyListVM {}

void main() {
  setUpAll(() {
    registerFallbackValue(CharacterListEvent(CharacterListState.idle));
  });

  group('whenListen', () {
    test('can mock the stream of a single cubit with an empty Stream', () {
      final counterCubit = MockRickMortyListVM();
      whenListen(counterCubit, const Stream<CharacterListEvent>.empty());
      expectLater(counterCubit.stream, emitsInOrder(<CharacterListEvent>[]));
    });

    test('can mock the stream of a single cubit', () async {
      final counterCubit = MockRickMortyListVM();
      whenListen(
        counterCubit,
        Stream.fromIterable([CharacterListEvent(CharacterListState.idle)]),
      );
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(CharacterListEvent(CharacterListState.idle)), emitsDone],
        ),
      );
    });

    testWidgets(
        'should show a Message when the Authentication state is Error',
            (WidgetTester tester) async {
          // arrange
          final mockAuthenticationBloc = MockRickMortyListVM();
          when(() => mockAuthenticationBloc.state).thenReturn(
            CharacterListEvent(CharacterListState.idle), // the desired state
          );
          // BlocProvider(
          //     create: (context) => RickMortyListVM(CharacterListRepository(
          //         context.read<DataClient>(), CharacterListSource(context.read<DataClient>().manager, CharacterListRequest("character"))))),
          // find
          final widget = RickMortyListWidget();
          final listWidget = find.byKey(const Key("RickMortyListWidgetKey"));

          // test
          await tester.pumpWidget(
            BlocProvider<MockRickMortyListVM>(
              create: (context) => mockAuthenticationBloc,
              child: MaterialApp(
                title: 'Widget Test',
                home: Scaffold(body: widget),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // expect
          expect(listWidget, findsOneWidget);


        });
  });

}
