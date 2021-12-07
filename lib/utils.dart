import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prefs/prefs.dart';

import 'core/logger.dart';
import 'core/repository/store/store.dart';

double statusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;

Future<void> initDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHiveForFlutter();
  await Prefs.init();
  await Firebase.initializeApp();
  await _firebaseMessagingHandler();
}

Future<void> onBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message $message');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingHandler() async {
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //   apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
      //   appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
      //   messagingSenderId: '448618578101',
      //   projectId: 'react-native-firebase-testing',
      // ),
      );

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(onBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'rick_and_morty_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('test'),
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await FirebaseMessaging.instance.getToken();
    Logger.d("MESSAGING TOKEN:$token");
  }
}

/// Init Hive database to be able to interact with [boxes]
Future<void> _initHiveForFlutter({String? subDir, Iterable<String> boxes = const [HiveStore.defaultBoxName]}) async {
  await Hive.initFlutter();
  await Hive.openBox(HiveStore.defaultBoxName);
}
