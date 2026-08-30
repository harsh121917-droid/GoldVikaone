import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/app_notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../routes/app_routes.dart';

class NotificationInboxController extends GetxController {
  static NotificationInboxController get to => Get.find<NotificationInboxController>();

  final NotificationRepository _repo = NotificationRepository();
  final _storage = GetStorage();

  final notifications = <AppNotificationModel>[].obs;
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs; // 'all', 'personal', 'offers', 'market'

  static const String _readStorageKey = 'read_notification_ids';

  Set<String> get _readIds {
    final list = _storage.read<List>(_readStorageKey) ?? [];
    return Set<String>.from(list.map((e) => e.toString()));
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final readSet = _readIds;
      final items = await _repo.fetchMyNotifications(readIds: readSet);
      notifications.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  List<AppNotificationModel> get filteredNotifications {
    if (selectedFilter.value == 'all') {
      return notifications;
    } else if (selectedFilter.value == 'personal') {
      return notifications.where((n) => n.targetType == 'user' || n.deepLink == 'kyc' || n.deepLink == 'wallet').toList();
    } else if (selectedFilter.value == 'offers') {
      return notifications.where((n) => n.deepLink == 'rewards' || n.deepLink == 'schemes' || n.title.toLowerCase().contains('offer') || n.title.toLowerCase().contains('reward')).toList();
    } else if (selectedFilter.value == 'market') {
      return notifications.where((n) => n.deepLink == 'buy_gold' || n.deepLink == 'jewellery' || n.title.toLowerCase().contains('rate') || n.title.toLowerCase().contains('gold')).toList();
    }
    return notifications;
  }

  void markAsRead(String id) {
    final readSet = _readIds;
    if (!readSet.contains(id)) {
      readSet.add(id);
      _storage.write(_readStorageKey, readSet.toList());
      
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        notifications.refresh();
      }
    }
  }

  void markAllAsRead() {
    final readSet = _readIds;
    for (final n in notifications) {
      readSet.add(n.id);
      n.isRead = true;
    }
    _storage.write(_readStorageKey, readSet.toList());
    notifications.refresh();
    Get.snackbar(
      'Marked as Read',
      'All notifications marked as read',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void handleNotificationTap(AppNotificationModel notification) {
    markAsRead(notification.id);

    final link = notification.deepLink.toLowerCase().trim();
    switch (link) {
      case 'buy_gold':
        Get.toNamed(AppRoutes.buyGold);
        break;
      case 'jewellery':
        Get.toNamed(AppRoutes.digiGold);
        break;
      case 'schemes':
        Get.toNamed(AppRoutes.goldSchemes);
        break;
      case 'wallet':
        Get.toNamed(AppRoutes.wallet);
        break;
      case 'rewards':
        Get.toNamed(AppRoutes.rewards);
        break;
      case 'kyc':
        Get.toNamed(AppRoutes.kyc);
        break;
      case 'home':
      default:
        Get.toNamed(AppRoutes.home);
        break;
    }
  }

  void removeNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    markAsRead(id);
  }
}
