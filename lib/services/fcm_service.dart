import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background push received: ${message.messageId}');
}

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _token;

  static Future<void> initialize() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground push: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Push tapped: ${message.data}');
    });

    _token = await _messaging.getToken();

    FirebaseMessaging.instance.onTokenRefresh.listen((String refreshedToken) {
      _token = refreshedToken;
      debugPrint('FCM token refreshed');
    });
  }

  static String? getToken() {
    return _token;
  }

  static Future<String?> refreshToken() async {
    _token = await _messaging.getToken();
    return _token;
  }
}
