import '../core/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('🔥 FCM Background Notification: ${message.notification?.title}');
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize Local Notifications for Foreground display
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            _handleNotificationClick(response.payload!);
          }
        },
      );

      // Subscribe to all users topic
      await _messaging.subscribeToTopic('all_users');

      // Get device FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        if (kDebugMode) print('🔥 FCM Token: $token');
        await syncFcmTokenToBackend(token);
      }

      _messaging.onTokenRefresh.listen(syncFcmTokenToBackend);

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      // Notification click listener (background / terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        String? deepLink = message.data['deepLink'];
        if (deepLink != null) _handleNotificationClick(deepLink);
      });
    } catch (e) {
      if (kDebugMode) print('❌ NotificationService Init Error: $e');
    }
  }

  static Future<String?> _downloadAndSaveFile(String url, String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final dio = Dio();
      await dio.download(url, filePath);
      return filePath;
    } catch (e) {
      if (kDebugMode) print('❌ Error downloading notification image: $e');
      return null;
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      String? imageUrl = notification.android?.imageUrl ??
          notification.apple?.imageUrl ??
          message.data['imageUrl'] ??
          message.data['image'];

      AndroidNotificationDetails androidDetails;
      DarwinNotificationDetails iosDetails = const DarwinNotificationDetails();

      if (imageUrl != null && imageUrl.isNotEmpty) {
        String? filePath = await _downloadAndSaveFile(imageUrl, 'notification_image_${notification.hashCode}');
        if (filePath != null) {
          androidDetails = AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(filePath),
              largeIcon: FilePathAndroidBitmap(filePath),
              contentTitle: notification.title,
              summaryText: notification.body,
            ),
          );
          iosDetails = DarwinNotificationDetails(
            attachments: [DarwinNotificationAttachment(filePath)],
          );
        } else {
          androidDetails = const AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );
        }
      } else {
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );
      }

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: message.data['deepLink'] ?? 'home',
      );
    }
  }

  static void _handleNotificationClick(String deepLink) {
    switch (deepLink) {
      case 'buy_gold':
        Get.toNamed('/buy-gold');
        break;
      case 'schemes':
        Get.toNamed('/schemes');
        break;
      case 'wallet':
        Get.toNamed('/wallet');
        break;
      case 'rewards':
        Get.toNamed('/rewards');
        break;
      case 'jewellery':
        Get.toNamed('/jewellery');
        break;
      case 'home':
      default:
        Get.offAllNamed('/dashboard');
        break;
    }
  }

  static Future<void> syncFcmTokenToBackend(String fcmToken) async {
    try {
      final storage = GetStorage();
      final userToken = storage.read<String>('bsqft_token');
      if (userToken == null || userToken.isEmpty) return;

      await ApiClient.instance.post(
        '/notifications/fcm-token',
        data: {'fcmToken': fcmToken},
      );
      if (kDebugMode) print('✅ FCM token synced to backend successfully');
    } catch (e) {
      if (kDebugMode) print('⚠️ FCM token sync error: $e');
    }
  }

  static Future<void> syncCurrentToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await syncFcmTokenToBackend(token);
      }
    } catch (_) {}
  }
}
