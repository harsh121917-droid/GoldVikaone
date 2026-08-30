import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/app_notification_model.dart';

class NotificationRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<AppNotificationModel>> fetchMyNotifications({
    int page = 1,
    int limit = 40,
    Set<String>? readIds,
  }) async {
    try {
      final res = await _dio.get('/notifications/my-notifications', queryParameters: {
        'page': page,
        'limit': limit,
      });

      if (res.data != null && res.data['success'] == true) {
        final list = (res.data['notifications'] as List? ?? []);
        return list.map((item) {
          final id = item['_id']?.toString() ?? '';
          final isRead = readIds != null && readIds.contains(id);
          return AppNotificationModel.fromJson(Map<String, dynamic>.from(item), isRead: isRead);
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
