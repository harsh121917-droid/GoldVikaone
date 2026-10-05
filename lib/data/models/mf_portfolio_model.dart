class MfPortfolioSummary {
  final double totalInvested;
  final double currentValuation;
  final double totalProfitLoss;
  final double totalProfitLossPct;
  final double? todayChangeAmount;
  final double? todayChangePct;
  final double? xirr;
  final int totalFunds;
  final int activeSipsCount;

  MfPortfolioSummary({
    required this.totalInvested,
    required this.currentValuation,
    required this.totalProfitLoss,
    required this.totalProfitLossPct,
    this.todayChangeAmount,
    this.todayChangePct,
    this.xirr,
    required this.totalFunds,
    required this.activeSipsCount,
  });

  factory MfPortfolioSummary.fromJson(Map<String, dynamic> json) {
    return MfPortfolioSummary(
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0.0,
      currentValuation: (json['currentValuation'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      totalProfitLossPct: (json['totalProfitLossPct'] as num?)?.toDouble() ?? 0.0,
      todayChangeAmount: (json['todayChangeAmount'] as num?)?.toDouble(),
      todayChangePct: (json['todayChangePct'] as num?)?.toDouble(),
      xirr: (json['xirr'] as num?)?.toDouble(),
      totalFunds: (json['totalFunds'] as num?)?.toInt() ?? 0,
      activeSipsCount: (json['activeSipsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MfHolding {
  final String schemeCode;
  final String schemeName;
  final String? amcName;
  final String? category;
  final String? subCategory;
  final double totalUnits;
  final double availableUnits;
  final double pendingRedemptionUnits;
  final String? folioNo;
  final bool isRedeemable;
  final double investedAmount;
  final double? averageNav;
  final double currentNav;
  final DateTime? navDate;
  final double currentValue;
  final double profitLoss;
  final double profitLossPct;
  final double? pendingUnits;

  MfHolding({
    required this.schemeCode,
    required this.schemeName,
    this.amcName,
    this.category,
    this.subCategory,
    required this.totalUnits,
    this.availableUnits = 0.0,
    this.pendingRedemptionUnits = 0.0,
    this.folioNo,
    this.isRedeemable = true,
    required this.investedAmount,
    this.averageNav,
    required this.currentNav,
    this.navDate,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPct,
    this.pendingUnits,
  });

  factory MfHolding.fromJson(Map<String, dynamic> json) {
    final tUnits = (json['totalUnits'] as num?)?.toDouble() ?? 0.0;
    final pRedUnits = (json['pendingRedemptionUnits'] as num?)?.toDouble() ?? 0.0;
    final aUnits = (json['availableUnits'] as num?)?.toDouble() ?? (tUnits - pRedUnits);

    return MfHolding(
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      amcName: json['amcName']?.toString(),
      category: json['category']?.toString(),
      subCategory: json['subCategory']?.toString(),
      totalUnits: tUnits,
      availableUnits: aUnits > 0 ? aUnits : (tUnits > 0 ? tUnits : 0.0),
      pendingRedemptionUnits: pRedUnits,
      folioNo: json['folioNo']?.toString(),
      isRedeemable: json['isRedeemable'] == true || (tUnits > 0 && aUnits > 0.0001),
      investedAmount: (json['investedAmount'] as num?)?.toDouble() ?? 0.0,
      averageNav: (json['averageNav'] as num?)?.toDouble(),
      currentNav: (json['currentNav'] as num?)?.toDouble() ?? 0.0,
      navDate: json['navDate'] != null ? DateTime.tryParse(json['navDate'].toString()) : null,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0.0,
      profitLossPct: (json['profitLossPct'] as num?)?.toDouble() ?? 0.0,
      pendingUnits: (json['pendingUnits'] as num?)?.toDouble(),
    );
  }
}

class MfActiveSip {
  final String id;
  final String sipRegNo;
  final String schemeCode;
  final String schemeName;
  final String frequency;
  final double installmentAmount;
  final DateTime? nextDueDate;
  final String status;
  final int installmentsPaid;

  MfActiveSip({
    required this.id,
    required this.sipRegNo,
    required this.schemeCode,
    required this.schemeName,
    required this.frequency,
    required this.installmentAmount,
    this.nextDueDate,
    required this.status,
    required this.installmentsPaid,
  });

  factory MfActiveSip.fromJson(Map<String, dynamic> json) {
    return MfActiveSip(
      id: json['_id']?.toString() ?? '',
      sipRegNo: json['sipRegNo']?.toString() ?? '',
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? 'MONTHLY',
      installmentAmount: (json['installmentAmount'] as num?)?.toDouble() ?? 0.0,
      nextDueDate: json['nextDueDate'] != null ? DateTime.tryParse(json['nextDueDate'].toString()) : null,
      status: json['status']?.toString() ?? 'ACTIVE',
      installmentsPaid: (json['installmentsPaid'] as num?)?.toInt() ?? 0,
    );
  }
}

class MfTransactionModel {
  final String id;
  final String schemeCode;
  final String schemeName;
  final String transactionType;
  final DateTime transactionDate;
  final double orderAmount;
  final double units;
  final double nav;
  final String status;
  final String? externalReference;

  MfTransactionModel({
    required this.id,
    required this.schemeCode,
    required this.schemeName,
    required this.transactionType,
    required this.transactionDate,
    required this.orderAmount,
    required this.units,
    required this.nav,
    required this.status,
    this.externalReference,
  });

  factory MfTransactionModel.fromJson(Map<String, dynamic> json) {
    return MfTransactionModel(
      id: json['_id']?.toString() ?? '',
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      transactionType: json['transactionType']?.toString() ?? 'PURCHASE',
      transactionDate: DateTime.tryParse(json['transactionDate']?.toString() ?? '') ?? DateTime.now(),
      orderAmount: (json['orderAmount'] as num?)?.toDouble() ?? 0.0,
      units: (json['units'] as num?)?.toDouble() ?? 0.0,
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'CONFIRMED',
      externalReference: json['externalReference']?.toString(),
    );
  }
}

class MfCapitalGainSummary {
  final String financialYear;
  final double totalProceeds;
  final double totalCost;
  final double netRealizedGain;
  final double stcg;
  final double ltcg;
  final int totalRedemptionsCount;
  final String disclaimer;

  MfCapitalGainSummary({
    required this.financialYear,
    required this.totalProceeds,
    required this.totalCost,
    required this.netRealizedGain,
    required this.stcg,
    required this.ltcg,
    required this.totalRedemptionsCount,
    required this.disclaimer,
  });

  factory MfCapitalGainSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return MfCapitalGainSummary(
      financialYear: json['financialYear']?.toString() ?? '',
      totalProceeds: (summary['totalProceeds'] as num?)?.toDouble() ?? 0.0,
      totalCost: (summary['totalCost'] as num?)?.toDouble() ?? 0.0,
      netRealizedGain: (summary['netRealizedGain'] as num?)?.toDouble() ?? 0.0,
      stcg: (summary['stcg'] as num?)?.toDouble() ?? 0.0,
      ltcg: (summary['ltcg'] as num?)?.toDouble() ?? 0.0,
      totalRedemptionsCount: (summary['totalRedemptionsCount'] as num?)?.toInt() ?? 0,
      disclaimer: summary['disclaimer']?.toString() ?? '',
    );
  }
}

class MfUccModel {
  final String clientCode;
  final String pan;
  final String nseStatus;
  final String accountNo;
  final String ifsc;
  final String bankName;

  MfUccModel({
    required this.clientCode,
    required this.pan,
    required this.nseStatus,
    required this.accountNo,
    required this.ifsc,
    required this.bankName,
  });

  factory MfUccModel.fromJson(Map<String, dynamic> json) {
    final primaryBank = json['primaryBank'] as Map<String, dynamic>? ?? {};
    return MfUccModel(
      clientCode: json['clientCode']?.toString() ?? '',
      pan: json['pan']?.toString() ?? '',
      nseStatus: json['nseStatus']?.toString() ?? 'ACTIVE',
      accountNo: primaryBank['accountNo']?.toString() ?? '',
      ifsc: primaryBank['ifsc']?.toString() ?? '',
      bankName: primaryBank['bankName']?.toString() ?? '',
    );
  }
}
