class MfSchemeModel {
  final String id;
  final String schemeCode;
  final String schemeName;
  final String amcCode;
  final String amcName;
  final String isin;
  final String category;
  final String subCategory;
  final double nav;
  final DateTime? navDate;
  final double cagr1Y;
  final double cagr3Y;
  final double cagr5Y;
  final double minPurchaseAmount;
  final double minSipAmount;
  final int rating;
  final String riskLevel;
  final String fundManager;
  final double aum;
  final double expenseRatio;
  final bool isPopular;
  final bool isFeatured;
  final List<NavHistoryPoint> navHistory;

  MfSchemeModel({
    required this.id,
    required this.schemeCode,
    required this.schemeName,
    required this.amcCode,
    required this.amcName,
    required this.isin,
    required this.category,
    required this.subCategory,
    required this.nav,
    this.navDate,
    required this.cagr1Y,
    required this.cagr3Y,
    required this.cagr5Y,
    required this.minPurchaseAmount,
    required this.minSipAmount,
    required this.rating,
    required this.riskLevel,
    required this.fundManager,
    required this.aum,
    required this.expenseRatio,
    required this.isPopular,
    required this.isFeatured,
    this.navHistory = const [],
  });

  factory MfSchemeModel.fromJson(Map<String, dynamic> json) {
    return MfSchemeModel(
      id: json['_id']?.toString() ?? '',
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      amcCode: json['amcCode']?.toString() ?? '',
      amcName: json['amcName']?.toString() ?? '',
      isin: json['isin']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Equity',
      subCategory: json['subCategory']?.toString() ?? '',
      nav: (json['nav'] as num?)?.toDouble() ?? 10.0,
      navDate: json['navDate'] != null ? DateTime.tryParse(json['navDate'].toString()) : null,
      cagr1Y: (json['cagr1Y'] as num?)?.toDouble() ?? 0.0,
      cagr3Y: (json['cagr3Y'] as num?)?.toDouble() ?? 0.0,
      cagr5Y: (json['cagr5Y'] as num?)?.toDouble() ?? 0.0,
      minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toDouble() ?? 1000.0,
      minSipAmount: (json['minSipAmount'] as num?)?.toDouble() ?? 500.0,
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      riskLevel: json['riskLevel']?.toString() ?? 'Very High',
      fundManager: json['fundManager']?.toString() ?? 'Fund Manager',
      aum: (json['aum'] as num?)?.toDouble() ?? 0.0,
      expenseRatio: (json['expenseRatio'] as num?)?.toDouble() ?? 0.85,
      isPopular: json['isPopular'] == true,
      isFeatured: json['isFeatured'] == true,
      navHistory: (json['navHistory'] as List<dynamic>?)
              ?.map((e) => NavHistoryPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class NavHistoryPoint {
  final String date;
  final double nav;

  NavHistoryPoint({required this.date, required this.nav});

  factory NavHistoryPoint.fromJson(Map<String, dynamic> json) {
    return NavHistoryPoint(
      date: json['date']?.toString() ?? '',
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
