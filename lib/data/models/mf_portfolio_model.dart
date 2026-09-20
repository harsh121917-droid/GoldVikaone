class MfPortfolioSummary {
  final double totalInvested;
  final double currentValuation;
  final double totalProfitLoss;
  final double totalProfitLossPct;
  final int totalFunds;
  final int activeSipsCount;

  MfPortfolioSummary({
    required this.totalInvested,
    required this.currentValuation,
    required this.totalProfitLoss,
    required this.totalProfitLossPct,
    required this.totalFunds,
    required this.activeSipsCount,
  });

  factory MfPortfolioSummary.fromJson(Map<String, dynamic> json) {
    return MfPortfolioSummary(
      totalInvested: (json['totalInvested'] as num?)?.toDouble() ?? 0.0,
      currentValuation: (json['currentValuation'] as num?)?.toDouble() ?? 0.0,
      totalProfitLoss: (json['totalProfitLoss'] as num?)?.toDouble() ?? 0.0,
      totalProfitLossPct: (json['totalProfitLossPct'] as num?)?.toDouble() ?? 0.0,
      totalFunds: (json['totalFunds'] as num?)?.toInt() ?? 0,
      activeSipsCount: (json['activeSipsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class MfHolding {
  final String schemeCode;
  final String schemeName;
  final double totalUnits;
  final double investedAmount;
  final double currentNav;
  final double currentValue;
  final double profitLoss;
  final double profitLossPct;

  MfHolding({
    required this.schemeCode,
    required this.schemeName,
    required this.totalUnits,
    required this.investedAmount,
    required this.currentNav,
    required this.currentValue,
    required this.profitLoss,
    required this.profitLossPct,
  });

  factory MfHolding.fromJson(Map<String, dynamic> json) {
    return MfHolding(
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      totalUnits: (json['totalUnits'] as num?)?.toDouble() ?? 0.0,
      investedAmount: (json['investedAmount'] as num?)?.toDouble() ?? 0.0,
      currentNav: (json['currentNav'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      profitLoss: (json['profitLoss'] as num?)?.toDouble() ?? 0.0,
      profitLossPct: (json['profitLossPct'] as num?)?.toDouble() ?? 0.0,
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
