class MfAmcModel {
  final String id;
  final String amcCode;
  final String amcName;
  final String displayName;
  final bool isActive;
  final int schemeCount;
  final String logoUrl;
  final int customRank;

  MfAmcModel({
    required this.id,
    required this.amcCode,
    required this.amcName,
    required this.displayName,
    this.isActive = true,
    this.schemeCount = 0,
    this.logoUrl = '',
    this.customRank = 9999,
  });

  bool get isRanked => customRank > 0 && customRank < 9999;

  factory MfAmcModel.fromJson(Map<String, dynamic> json) {
    return MfAmcModel(
      id: json['_id']?.toString() ?? '',
      amcCode: json['amcCode']?.toString() ?? '',
      amcName: json['amcName']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['amcName']?.toString() ?? '',
      isActive: json['isActive'] != false,
      schemeCount: (json['schemeCount'] as num?)?.toInt() ?? 0,
      logoUrl: json['logoUrl']?.toString() ?? '',
      customRank: (json['customRank'] as num?)?.toInt() ?? 9999,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amcCode': amcCode,
      'amcName': amcName,
      'displayName': displayName,
      'isActive': isActive,
      'schemeCount': schemeCount,
      'logoUrl': logoUrl,
      'customRank': customRank,
    };
  }
}
