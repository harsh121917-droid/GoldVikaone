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
  final double? day1ChangeAmount;
  final double? day1ChangePct;

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
    this.day1ChangeAmount,
    this.day1ChangePct,
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
      day1ChangeAmount: (json['day1ChangeAmount'] as num?)?.toDouble() ?? (json['todayChangeAmount'] as num?)?.toDouble(),
      day1ChangePct: (json['day1ChangePct'] as num?)?.toDouble() ?? (json['todayChangePct'] as num?)?.toDouble(),
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
  final String dob;
  final String fullName;
  final String gender;

  MfUccModel({
    required this.clientCode,
    required this.pan,
    required this.nseStatus,
    required this.accountNo,
    required this.ifsc,
    required this.bankName,
    this.dob = '',
    this.fullName = '',
    this.gender = 'M',
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
      dob: json['dob']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'M',
    );
  }
}

class MfOrderModel {
  final String id;
  final String orderId;
  final String schemeCode;
  final String schemeName;
  final String transactionType;
  final double orderAmount;
  final double estimatedUnits;
  final double allottedUnits;
  final double? allottedNav;
  final double? navAtOrder;
  final String orderStatus;
  final String paymentStatus;
  final String allotmentStatus;
  final String? paymentLink;
  final String? nseTrxnOrderId;
  final String? nseStatus;
  final DateTime createdAt;
  final String displayStatus;
  final String subStatus;
  final String expectedAllotmentDate;
  final bool isPaymentDone;

  MfOrderModel({
    required this.id,
    required this.orderId,
    required this.schemeCode,
    required this.schemeName,
    required this.transactionType,
    required this.orderAmount,
    required this.estimatedUnits,
    required this.allottedUnits,
    this.allottedNav,
    this.navAtOrder,
    required this.orderStatus,
    required this.paymentStatus,
    required this.allotmentStatus,
    this.paymentLink,
    this.nseTrxnOrderId,
    this.nseStatus,
    required this.createdAt,
    required this.displayStatus,
    this.subStatus = '',
    required this.expectedAllotmentDate,
    this.isPaymentDone = false,
  });

  bool get isProcessing =>
      allotmentStatus != 'ALLOTTED' &&
      (paymentStatus == 'SUCCESS' ||
          orderStatus == 'PROCESSING' ||
          orderStatus == 'SUBMITTED' ||
          orderStatus == 'PAYMENT_SUCCESS') &&
      orderStatus != 'CANCELLED' &&
      orderStatus != 'REJECTED' &&
      orderStatus != 'FAILED' &&
      orderStatus != 'PAYMENT_PENDING';

  String get typeLabel {
    if (transactionType == 'R') return 'Redeem';
    if (transactionType == 'S') return 'Switch';
    return 'Lump Sum';
  }

  String get badgeLabel {
    if (allotmentStatus == 'ALLOTTED') return 'Allotted';
    if (orderStatus == 'CANCELLED' || orderStatus == 'REJECTED' || orderStatus == 'FAILED') return 'Failed';
    if (orderStatus == 'PAYMENT_PENDING' || paymentStatus == 'PENDING') return 'Pending';
    if (displayStatus.toLowerCase().contains('processing') || displayStatus.toLowerCase().contains('in progress') || isProcessing) {
      return 'In Progress';
    }
    return displayStatus.isNotEmpty ? displayStatus : 'In Progress';
  }

  String get subStatusLabel {
    if (allotmentStatus == 'ALLOTTED') return 'Units Allotted • Available in Holdings';
    if (orderStatus == 'CANCELLED' || orderStatus == 'REJECTED' || orderStatus == 'FAILED') return 'Order Rejected / Expired';
    if (orderStatus == 'PAYMENT_PENDING' || paymentStatus == 'PENDING') return 'Awaiting Payment Authorization';
    if (subStatus.isNotEmpty) return subStatus;
    return 'Payment Confirmed • Allotment Pending from AMC';
  }

  factory MfOrderModel.fromJson(Map<String, dynamic> json) {
    return MfOrderModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? 'Mutual Fund Investment',
      transactionType: json['transactionType']?.toString() ?? 'P',
      orderAmount: (json['orderAmount'] as num?)?.toDouble() ?? 0.0,
      estimatedUnits: (json['estimatedUnits'] as num?)?.toDouble() ?? 0.0,
      allottedUnits: (json['allottedUnits'] as num?)?.toDouble() ?? 0.0,
      allottedNav: (json['allottedNav'] as num?)?.toDouble(),
      navAtOrder: (json['navAtOrder'] as num?)?.toDouble(),
      orderStatus: json['orderStatus']?.toString() ?? 'PAYMENT_PENDING',
      paymentStatus: json['paymentStatus']?.toString() ?? 'PENDING',
      allotmentStatus: json['allotmentStatus']?.toString() ?? 'PENDING',
      paymentLink: json['paymentLink']?.toString(),
      nseTrxnOrderId: json['nseTrxnOrderId']?.toString(),
      nseStatus: json['nseStatus']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      displayStatus: json['displayStatus']?.toString() ?? 'Order Placed',
      subStatus: json['subStatus']?.toString() ?? '',
      expectedAllotmentDate: json['expectedAllotmentDate']?.toString() ?? 'Tomorrow',
      isPaymentDone: json['isPaymentDone'] == true ||
          json['paymentStatus'] == 'SUCCESS' ||
          json['orderStatus'] == 'PROCESSING' ||
          json['orderStatus'] == 'PAYMENT_SUCCESS',
    );
  }
}

