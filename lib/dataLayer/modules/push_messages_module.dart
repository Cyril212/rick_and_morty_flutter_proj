import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rick_and_morty_flutter_proj/constants/firebase_constants.dart';
import 'package:rick_and_morty_flutter_proj/core/logger.dart';

Future<void> onBackgroundHandler(RemoteMessage message) async {
  Logger.d('Handling a background message $message');
}

class PushMessagesModule {
  static final PushMessagesModule _instance = PushMessagesModule._();

  static PushMessagesModule get instance => _instance;

  /// Singleton boilerplate
  PushMessagesModule._();

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Request permission on iOS & Web platforms
  Future<NotificationSettings> requestNotificationPermission() =>
      FirebaseMessaging.instance.requestPermission(
        sound: true,
        badge: true,
        alert: true,
      );

  Future<void> initFirebaseMessaging() async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: FirebaseConstants.kApiKey,
            appId: FirebaseConstants.kAppId,
            messagingSenderId: FirebaseConstants.kMessagingSenderId,
            projectId: FirebaseConstants.kProjectId));

    await requestNotificationPermission();

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(onBackgroundHandler);

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        FirebaseConstants.kAndroidNotificationChannelId, // id
        FirebaseConstants.kAndroidNotificationChannelTitle, // title
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token = await FirebaseMessaging.instance.getToken();
      Logger.d("Messaging token: $token");
    }
  }
}
