import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize the plugin for background isolate
  await _initFlutterLocalNotifications();
  await _showNotificationFromRemoteMessage(message);
}

Future<void> _initFlutterLocalNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create channel for Android
  if (!kIsWeb && Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      _channel,
    );
  }
}

Future<void> _showNotificationFromRemoteMessage(RemoteMessage message) async {
  final RemoteNotification? notification = message.notification;
  final Map<String, dynamic> data = message.data;

  final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    _channel.id,
    _channel.name,
    channelDescription: _channel.description,
    importance: Importance.max,
    priority: Priority.high,
  );

  final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    id,
    notification?.title ?? data['title'] ?? '',
    notification?.body ?? data['body'] ?? '',
    platformChannelSpecifics,
    payload: jsonEncode(data),
  );
}

class NotificationsService {
  NotificationsService._();

  static Future<void> initialize() async {
    // initialize local notifications
    await _initFlutterLocalNotifications();

    // Request permissions for iOS
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    // Set background handler (must be a top-level function)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground: show a local notification when an FCM message arrives
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showNotificationFromRemoteMessage(message);
    });

    // Tapped notification when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // handle navigation or other logic here if needed
      if (kDebugMode) {
        debugPrint('onMessageOpenedApp: ${message.data}');
      }
    });
  }

  static Future<String?> getToken() => FirebaseMessaging.instance.getToken();
}
