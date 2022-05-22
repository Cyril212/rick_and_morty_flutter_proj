// This file is provided as a convenience for running integration tests via the
// flutter drive command.
//
// flutter drive --driver integration_test/driver.dart --target integration_test/app_test.dart

import 'package:integration_test/integration_test_driver.dart';
import 'package:rick_and_morty_flutter_proj/core/logger.dart';

Future<void> main() => integrationDriver(
      responseDataCallback: (Map<String, dynamic>? data) async {
        if (data != null) {
          for (final MapEntry<String, dynamic> entry in data.entries) {
            Logger.d('Writing ${entry.key} to the disk.');
            await writeResponseData(
              entry.value as Map<String, dynamic>,
              testOutputFilename: entry.key,
            );
          }
        }
      },
    );
