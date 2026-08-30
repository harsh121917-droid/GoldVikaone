class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String deepLink;
  final String targetType;
  final DateTime createdAt;
  bool isRead;

  AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.deepLink,
    required this.targetType,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json, {bool isRead = false}) {
    return AppNotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      body: (json['body'] ?? '').toString(),
      imageUrl: (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty)
          ? json['imageUrl'].toString()
          : null,
      deepLink: (json['deepLink'] ?? 'home').toString(),
      targetType: (json['targetType'] ?? 'all').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: isRead,
    );
  }
}
