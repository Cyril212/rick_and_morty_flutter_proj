/**
 * This class will have more sense once we start using flavors
 */

import 'package:flutter/foundation.dart';

class Logger {

  static const _forceEnableLogging = false;
  static const defaultTag = 'UNKNOWN_TAG';

  static void d(String message, {String tag = defaultTag}) {
    if (_forceEnableLogging || !kReleaseMode) {
      debugPrint('$tag: $message');
    }
  }
}