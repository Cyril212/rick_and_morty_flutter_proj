// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

import 'package:mocktail/mocktail.dart';

class MockRickMortyListVM extends MockCubit<CharacterListEvent> implements RickMortyListVM {}

void main() {

  //Init dependencies
  setUpAll(() {
    registerFallbackValue(const CharacterListEvent(ListState.idle));
  });

  group('Can init RickMortyListVM', () {

    test('can mock the stream of a single cubit with an empty Stream', () {
      final counterCubit = MockRickMortyListVM();
      whenListen(counterCubit, const Stream<CharacterListEvent>.empty());
      expectLater(counterCubit.stream, emitsInOrder(<CharacterListEvent>[]));
    });

    test('can mock the stream of a single cubit and expect default response', () async {
      final counterCubit = MockRickMortyListVM();
      whenListen(
        counterCubit,
        Stream.fromIterable([const CharacterListEvent(ListState.idle)]),
      );
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(const CharacterListEvent(ListState.idle)), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single cubit and expect two states', () async {
      final counterCubit = MockRickMortyListVM();
      whenListen(
        counterCubit,
        Stream.fromIterable([const CharacterListEvent(ListState.idle),const CharacterListEvent(ListState.loading)]),
      );
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(const CharacterListEvent(ListState.idle)),equals(const CharacterListEvent(ListState.loading)), emitsDone],
        ),
      );
    });

    test('can mock the stream of a single cubit and expect three states where success is the last one', () async {
      final counterCubit = MockRickMortyListVM();
      whenListen(
        counterCubit,
        Stream.fromIterable([const CharacterListEvent(ListState.idle),const CharacterListEvent(ListState.loading), const CharacterListEvent(ListState.success)]),
      );
      await expectLater(
        counterCubit.stream,
        emitsInOrder(
          <Matcher>[equals(const CharacterListEvent(ListState.idle)),equals(const CharacterListEvent(ListState.loading),),equals(const CharacterListEvent(ListState.success)), emitsDone],
        ),
      );
    });
  });
}
