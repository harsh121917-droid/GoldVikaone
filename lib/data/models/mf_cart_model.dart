class MfCartItem {
  final String id;
  final String schemeCode;
  final String schemeName;
  final String amcName;
  final String category;
  final String investmentType; // 'SIP' or 'LUMPSUM'
  final double amount;
  final String frequency;
  final int sipDay;
  final String folioNo;
  final DateTime? addedAt;

  MfCartItem({
    required this.id,
    required this.schemeCode,
    required this.schemeName,
    this.amcName = '',
    this.category = '',
    this.investmentType = 'SIP',
    required this.amount,
    this.frequency = 'MONTHLY',
    this.sipDay = 5,
    this.folioNo = '',
    this.addedAt,
  });

  factory MfCartItem.fromJson(Map<String, dynamic> json) {
    return MfCartItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      amcName: json['amcName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      investmentType: json['investmentType']?.toString() ?? 'SIP',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      frequency: json['frequency']?.toString() ?? 'MONTHLY',
      sipDay: (json['sipDay'] as num?)?.toInt() ?? 5,
      folioNo: json['folioNo']?.toString() ?? '',
      addedAt: json['addedAt'] != null ? DateTime.tryParse(json['addedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schemeCode': schemeCode,
      'schemeName': schemeName,
      'amcName': amcName,
      'category': category,
      'investmentType': investmentType,
      'amount': amount,
      'frequency': frequency,
      'sipDay': sipDay,
      'folioNo': folioNo,
    };
  }
}

class MfCartData {
  final List<MfCartItem> items;
  final double totalAmount;
  final int count;

  MfCartData({
    required this.items,
    required this.totalAmount,
    required this.count,
  });

  factory MfCartData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((e) => MfCartItem.fromJson(e as Map<String, dynamic>)).toList();
    return MfCartData(
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? itemsList.length,
    );
  }

  factory MfCartData.empty() {
    return MfCartData(items: [], totalAmount: 0.0, count: 0);
  }
}
