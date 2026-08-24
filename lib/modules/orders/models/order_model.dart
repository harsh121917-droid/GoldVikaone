class StatusHistoryItem {
  final String status;
  final String title;
  final String description;
  final DateTime date;

  StatusHistoryItem({
    required this.status,
    required this.title,
    required this.description,
    required this.date,
  });

  factory StatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItem(
      status: json['status']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderModel {
  final String id;
  final String jewelleryName;
  final String metalType;
  final double weightGrams;
  final double makingCharges;
  final double gstAmount;
  final double totalPaid;
  final String paymentMethod;
  final String status;
  final String deliveryStatus;
  final String shippingAddress;
  final String trackingId;
  final String courierName;
  final String trackingUrl;
  final String estimatedDeliveryDate;
  final String statusNote;
  final DateTime createdAt;
  final List<StatusHistoryItem> statusHistory;
  final String? imageUrl;
  final String? purity;

  OrderModel({
    required this.id,
    required this.jewelleryName,
    required this.metalType,
    required this.weightGrams,
    required this.makingCharges,
    required this.gstAmount,
    required this.totalPaid,
    required this.paymentMethod,
    required this.status,
    required this.deliveryStatus,
    required this.shippingAddress,
    required this.trackingId,
    required this.courierName,
    required this.trackingUrl,
    required this.estimatedDeliveryDate,
    required this.statusNote,
    required this.createdAt,
    required this.statusHistory,
    this.imageUrl,
    this.purity,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String? img;
    String? pur;
    if (json['jewellery'] != null && json['jewellery'] is Map) {
      final jMap = json['jewellery'] as Map;
      img = jMap['imageUrl']?.toString()?.trim();
      if ((img == null || img.isEmpty) && jMap['images'] is List && (jMap['images'] as List).isNotEmpty) {
        img = jMap['images'][0]?.toString()?.trim();
      }
      if (img == null || img.isEmpty) {
        img = jMap['image']?.toString()?.trim();
      }
      pur = jMap['purity']?.toString();
    }
    if (img == null || img.isEmpty) {
      img = json['imageUrl']?.toString()?.trim() ?? json['image']?.toString()?.trim();
    }

    var historyList = <StatusHistoryItem>[];
    if (json['statusHistory'] != null && json['statusHistory'] is List) {
      historyList = (json['statusHistory'] as List)
          .map((i) => StatusHistoryItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['_id']?.toString() ?? '',
      jewelleryName: json['jewelleryName']?.toString() ?? 'Jewellery Item',
      metalType: json['metalType']?.toString() ?? 'gold',
      weightGrams: (json['weightGrams'] as num?)?.toDouble() ?? 0.0,
      makingCharges: (json['makingCharges'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod']?.toString() ?? 'razorpay',
      status: json['status']?.toString() ?? 'completed',
      deliveryStatus: json['deliveryStatus']?.toString() ?? 'placed',
      shippingAddress: json['shippingAddress']?.toString() ?? '',
      trackingId: json['trackingId']?.toString() ?? '',
      courierName: json['courierName']?.toString() ?? 'Vikaone Express Logistics',
      trackingUrl: json['trackingUrl']?.toString() ?? '',
      estimatedDeliveryDate: json['estimatedDeliveryDate']?.toString() ?? '',
      statusNote: json['statusNote']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statusHistory: historyList,
      imageUrl: img,
      purity: pur,
    );
  }
}
