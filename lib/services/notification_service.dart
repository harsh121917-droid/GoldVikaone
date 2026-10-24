import '../core/network/api_client.dart';
import '../routes/app_routes.dart';
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
    print('🔥 [VikaOne] FCM Background Notification: ${message.notification?.title}');
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

      // Request push notification permissions
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

      // Get device FCM token & sync to backend
      String? token = await _messaging.getToken();
      if (token != null) {
        if (kDebugMode) print('🔥 [VikaOne] FCM Token: $token');
        await syncFcmTokenToBackend(token);
      }

      _messaging.onTokenRefresh.listen(syncFcmTokenToBackend);

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      // Notification click listener (background -> opened)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        String? deepLink = message.data['deepLink'];
        if (deepLink != null && deepLink.isNotEmpty) {
          _handleNotificationClick(deepLink);
        }
      });

      // Terminated / Cold-start notification click handler
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        String? deepLink = initialMessage.data['deepLink'];
        if (deepLink != null && deepLink.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 600), () {
            _handleNotificationClick(deepLink);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ [VikaOne] NotificationService Init Error: $e');
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
            channelDescription: 'Notifications for VikaOne DigiGold rates, scheme reminders, and offers',
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
            channelDescription: 'Notifications for VikaOne DigiGold rates, scheme reminders, and offers',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );
        }
      } else {
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Notifications for VikaOne DigiGold rates, scheme reminders, and offers',
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

  /// Parses deep link and safely routes within VikaOne app
  static void _handleNotificationClick(String deepLink) {
    if (kDebugMode) print('🔗 [VikaOne] Handling Notification Deep Link: $deepLink');

    // Clean scheme and host if passed as URI e.g. vikaone://schemes or https://vikaone.com/buy-gold
    String link = deepLink.trim().toLowerCase();
    link = link.replaceAll('vikaone://', '');
    link = link.replaceAll('payvika://', '');
    link = link.replaceAll('https://vikaone.com/', '');
    link = link.replaceAll('http://vikaone.com/', '');
    if (link.startsWith('/')) link = link.substring(1);

    // ── Mutual Fund Intelligent Deep Linking ──
    if (link.contains('tab=sips') || link.startsWith('mutual_funds/sip') || link == 'mf_sip' || link == 'mf_sips') {
      Get.toNamed(AppRoutes.mfPortfolio, arguments: {'tab': 'sips'});
      return;
    }
    if (link.contains('tab=orders') || link.startsWith('mutual_funds/order') || link == 'mf_order' || link == 'mf_orders') {
      Get.toNamed(AppRoutes.mfPortfolio, arguments: {'tab': 'orders'});
      return;
    }
    if (link.startsWith('mutual_funds/portfolio') || link == 'mf_portfolio') {
      Get.toNamed(AppRoutes.mfPortfolio, arguments: {'tab': 'dashboard'});
      return;
    }
    if (link == 'mutual_funds' || link == 'mutualfunds' || link == 'mf') {
      Get.toNamed(AppRoutes.mutualFunds);
      return;
    }

    switch (link) {
      case 'buy_gold':
      case 'buygold':
      case 'gold':
      case 'digi-gold/buy':
      case 'buy':
        Get.toNamed(AppRoutes.buyGold);
        break;

      case 'schemes':
      case 'scheme':
      case 'gold_scheme':
      case 'digi-gold/schemes':
        Get.toNamed(AppRoutes.goldSchemes);
        break;

      case 'sip':
      case 'savings':
      case 'digi-gold/savings':
        Get.toNamed(AppRoutes.digiGoldSavings);
        break;

      case 'wallet':
      case 'passbook':
        Get.toNamed(AppRoutes.wallet);
        break;

      case 'rewards':
      case 'reward':
      case 'referral':
      case 'referrals':
      case 'profile/rewards':
        Get.toNamed(AppRoutes.rewards);
        break;

      case 'kyc':
        Get.toNamed(AppRoutes.kyc);
        break;

      case 'bank':
      case 'banks':
      case 'wallet/banks':
      case 'bank_accounts':
        Get.toNamed(AppRoutes.bankAccounts);
        break;

      case 'mutual_funds/portfolio':
      case 'mf_portfolio':
        Get.toNamed(AppRoutes.mfPortfolio);
        break;

      case 'orders':
      case 'my-orders':
        Get.toNamed(AppRoutes.orders);
        break;

      case 'transactions':
      case 'history':
        Get.toNamed(AppRoutes.transactions);
        break;

      case 'silver':
      case 'buy_silver':
      case 'silver/buy':
        Get.toNamed(AppRoutes.buySilver);
        break;

      case 'mutual_funds':
      case 'mutualfunds':
      case 'mf':
      case 'portfolio':
        Get.toNamed(AppRoutes.mutualFunds);
        break;

      case 'notifications':
      case 'alerts':
        Get.toNamed(AppRoutes.notifications);
        break;

      case 'home':
      case 'dashboard':
      default:
        Get.offAllNamed(AppRoutes.home);
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
        data: {
          'fcmToken': fcmToken,
          'app': 'digigold',
        },
      );
      if (kDebugMode) print('✅ [VikaOne] FCM token synced to backend successfully (digigold)');
    } catch (e) {
      if (kDebugMode) print('⚠️ [VikaOne] FCM token sync error: $e');
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
