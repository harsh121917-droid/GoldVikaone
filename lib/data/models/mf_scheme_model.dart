class MfSchemeModel {
  final String id;
  final String schemeCode;
  final String schemeName;
  final String amcCode;
  final String amcName;
  final String isin;
  final String category;
  final String subCategory;
  final double? nav;
  final DateTime? navDate;
  final double? cagr1Y;
  final double? cagr3Y;
  final double? cagr5Y;
  final double? return1M;
  final double? return3M;
  final double? return6M;
  final double? minPurchaseAmount;
  final double? minSipAmount;
  final int? rating;
  final String riskLevel;
  final String? fundManager;
  final double? aum;
  final double? expenseRatio;
  final String? benchmark;
  final String? exitLoad;
  final String? navSource;
  final bool isPopular;
  final bool isFeatured;
  final bool isRecommended;
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
    this.nav,
    this.navDate,
    this.cagr1Y,
    this.cagr3Y,
    this.cagr5Y,
    this.return1M,
    this.return3M,
    this.return6M,
    this.minPurchaseAmount,
    this.minSipAmount,
    this.rating,
    required this.riskLevel,
    this.fundManager,
    this.aum,
    this.expenseRatio,
    this.benchmark,
    this.exitLoad,
    this.navSource,
    required this.isPopular,
    required this.isFeatured,
    this.isRecommended = false,
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
      nav: (json['nav'] as num?)?.toDouble(),
      navDate: json['navDate'] != null ? DateTime.tryParse(json['navDate'].toString()) : null,
      cagr1Y: (json['cagr1Y'] as num?)?.toDouble(),
      cagr3Y: (json['cagr3Y'] as num?)?.toDouble(),
      cagr5Y: (json['cagr5Y'] as num?)?.toDouble(),
      return1M: (json['return1M'] as num?)?.toDouble(),
      return3M: (json['return3M'] as num?)?.toDouble(),
      return6M: (json['return6M'] as num?)?.toDouble(),
      minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toDouble(),
      minSipAmount: (json['minSipAmount'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toInt(),
      riskLevel: json['riskLevel']?.toString() ?? 'Moderate',
      fundManager: json['fundManager']?.toString(),
      aum: (json['aum'] as num?)?.toDouble(),
      expenseRatio: (json['expenseRatio'] as num?)?.toDouble(),
      benchmark: json['benchmark']?.toString(),
      exitLoad: json['exitLoad']?.toString(),
      navSource: json['navSource']?.toString(),
      isPopular: json['isPopular'] == true,
      isFeatured: json['isFeatured'] == true,
      isRecommended: json['isRecommended'] == true,
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
