import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_flutter_proj/core/logger.dart';

/// To run test type in:
/// flutter drive --driver=integration_test/driver.dart --target=integration_test/performance_test.dart --profile --no-dds
///
/// To run test with cached shaders type in:
/// flutter drive --driver=integration_test/driver.dart --target=integration_test/performance_test.dart --profile --no-dds --bundle-sksl-path sksl/(ios/android)_shader_cache.sksl.json
///
/// Info about manual shader warm-up check out: [https://docs.flutter.dev/perf/shader#how-to-use-sksl-warmup]
///
/// To warm up shaders during the test
/// flutter drive --driver=integration_test/driver.dart --target=integration_test/performance_test.dart --profile --no-dds --cache-sksl --purge-persistent-cache
///
/// At the end, driver generates performance_report.json to build folder
///
/// In the future, test should be performed over mocked environment.
///
/// Current shader cache located in sksl folder
enum _DragDirection { left, right, up, down }

const int _kDefaultDelayDuration = 5;

/// Swipe widget by [finder] in given [direction]
Future<void> _dragFinderElement({
  required WidgetTester tester,
  required Finder finder,
  required double distanceInPx,
  required _DragDirection direction,
  int? durationInSec,
}) {
  late Offset offset;
  switch (direction) {
    case _DragDirection.left:
      offset = Offset(-distanceInPx, 0);
      break;
    case _DragDirection.right:
      offset = Offset(distanceInPx, 0);
      break;
    case _DragDirection.up:
      offset = Offset(0, distanceInPx);
      break;
    case _DragDirection.down:
      offset = Offset(0, -distanceInPx);
      break;
  }
  return tester
      .drag(
        finder,
        offset,
      )
      .then(
        (_) => _wait(
            tester: tester,
            durationInSec: durationInSec ?? _kDefaultDelayDuration),
      );
}

/// Swipe sequence of [pageCount] times
Future<void> _dragFinderElementSequence({
  required WidgetTester tester,
  required Finder finder,
  required double distanceInPx,
  required _DragDirection direction,
  required int pageCount,
  int? durationInSec,
  int? changeDirectionIndex,
}) async {
  _DragDirection getCurrentDirection(
    _DragDirection direction,
    int? changeDirectionIndex,
    int index,
  ) {
    late _DragDirection currentDirection;
    if (changeDirectionIndex == null) {
      currentDirection = direction;
    } else {
      switch (direction) {
        case _DragDirection.left:
          currentDirection = index <= changeDirectionIndex
              ? currentDirection = _DragDirection.left
              : currentDirection = _DragDirection.right;
          break;
        case _DragDirection.right:
          currentDirection = index <= changeDirectionIndex
              ? currentDirection = _DragDirection.right
              : currentDirection = _DragDirection.left;
          break;
        case _DragDirection.up:
          currentDirection = index <= changeDirectionIndex
              ? currentDirection = _DragDirection.up
              : currentDirection = _DragDirection.down;
          break;
        case _DragDirection.down:
          currentDirection = index <= changeDirectionIndex
              ? currentDirection = _DragDirection.down
              : currentDirection = _DragDirection.up;
          break;
      }
    }
    return currentDirection;
  }

  for (int index = 0; index < pageCount; index++) {
    await _dragFinderElement(
      tester: tester,
      finder: finder,
      distanceInPx: distanceInPx,
      direction: getCurrentDirection(direction, changeDirectionIndex, index),
      durationInSec: durationInSec,
    );
  }
  return Future<void>.value();
}

/// Dummy wait to avoid asynchronous gaps
Future<void> _wait({required WidgetTester tester, int durationInSec = 4}) {
  return tester.runAsync(
    () => Future<void>.delayed(
      Duration(seconds: durationInSec),
    ),
  );
}

/// Finds widget by [key], and taps on it
Future<void> _tapRedirectActionByKey(
    {required WidgetTester tester,
    required String widgetName,
    required Key key,
    int durationInSeconds = 2}) async {
  final Finder finder = find.byKey(key);
  Logger.d('$widgetName found');

  await tester.tap(finder);
  Logger.d('$widgetName tapped');

  return tester.pump(
    Duration(seconds: durationInSeconds),
  );
}

/// Finds widget by [type], and taps on it,
/// in case there's a need to pop at the end set [shouldPop] to true.
Future<void> _tapRedirectActionByType({
  required WidgetTester tester,
  required String widgetName,
  required Type type,
  required GlobalKey<NavigatorState> navigatorKey,
  int? index,
  int durationInSeconds = 2,
  bool shouldPop = false,
  int? waitAfterExecutionInSeconds,
}) async {
  final Finder finder = find.byType(type);
  Logger.d('$widgetName found');

  await tester.tap(index != null ? finder.at(index) : finder);
  Logger.d('$widgetName tapped');

  await tester.pump(
    Duration(seconds: durationInSeconds),
  );

  if (shouldPop) Navigator.pop(navigatorKey.currentContext!);

  return waitAfterExecutionInSeconds != null
      ? _wait(tester: tester)
      : Future<void>.value();
}

/// Finds a scrollable by tag and scrolls down
Future<void> _scrollDownByTag(
    {required WidgetTester tester,
    required Key key,
    required String widgetName,
    required GlobalKey<NavigatorState> navigatorKey}) async {
  Logger.d(widgetName);

  final Finder screenContentFinder = find.byKey(key);
  Logger.d('$widgetName - Content found');

  await _dragFinderElement(
    tester: tester,
    finder: screenContentFinder,
    distanceInPx: 2000,
    direction: _DragDirection.down,
    durationInSec: 3,
  );
  Logger.d('$widgetName - Content found - Scroll');

  Navigator.pop(
    navigatorKey.currentContext!,
  );

  await _wait(tester: tester, durationInSec: 5);

  Logger.d('Wine Details Screen - Content found - pop');
}
