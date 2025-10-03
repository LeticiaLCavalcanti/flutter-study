import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    var firebaseAvailable = false;
    try {
      await Firebase.initializeApp();
      firebaseAvailable = Firebase.apps.isNotEmpty;
    } catch (_) {
      firebaseAvailable = false;
    }

    // Android initialization
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _local.initialize(initSettings, onDidReceiveNotificationResponse: (payload) {
      // Handle tap
    });

    if (firebaseAvailable) {
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Request permissions on iOS
        if (Platform.isIOS) {
          await FirebaseMessaging.instance.requestPermission();
        }

        // Foreground message handler
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          if (notification != null) {
            showLocalNotification(notification.title ?? '', notification.body ?? '');
          }
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        });
      } catch (e) {
        // Ignore any FirebaseMessaging errors in environments where Firebase isn't fully set up.
      }
    }
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      channelDescription: 'Default channel for notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _local.show(0, title, body, details);
  }
}
