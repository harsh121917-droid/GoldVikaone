/// Represents a Corporate Fixed Deposit Issuer (Bajaj Finance, Shriram Finance, Mahindra Finance, etc.)
class FdCompanyModel {
  final String code;
  final String name;
  final String shortName;
  final String tagline;
  final String creditRating;
  final String ratingAgency;
  final String? logo;
  final double minAmount;
  final double maxAmount;
  final double maxRate;
  final double seniorCitizenBonus;
  final double womenInvestorBonus;
  final List<int> tenuresMonths;
  final List<String> payoutOptions;
  final List<String> highlights;
  final List<FdSchemeModel> schemes;

  FdCompanyModel({
    required this.code,
    required this.name,
    required this.shortName,
    required this.tagline,
    required this.creditRating,
    required this.ratingAgency,
    this.logo,
    required this.minAmount,
    required this.maxAmount,
    required this.maxRate,
    required this.seniorCitizenBonus,
    required this.womenInvestorBonus,
    required this.tenuresMonths,
    required this.payoutOptions,
    required this.highlights,
    required this.schemes,
  });

  String get logoAsset {
    if (logo != null && logo!.isNotEmpty && !logo!.startsWith('http')) return logo!;
    final c = code.toUpperCase();
    if (c.contains('BAJAJ')) return 'assets/images/fd/bajaj_finance.png';
    if (c.contains('SHRIRAM')) return 'assets/images/fd/shriram_finance.png';
    if (c.contains('MAHINDRA')) return 'assets/images/fd/mahindra_finance.png';
    if (c.contains('PNB')) return 'assets/images/fd/pnb_housing.png';
    if (c.contains('LIC')) return 'assets/images/fd/lic_housing.png';
    return 'assets/images/fd/bajaj_finance.png';
  }

  factory FdCompanyModel.fromJson(Map<String, dynamic> json) {
    return FdCompanyModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortName: json['shortName']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? '',
      creditRating: json['creditRating']?.toString() ?? 'AAA',
      ratingAgency: json['ratingAgency']?.toString() ?? 'CRISIL',
      logo: json['logo']?.toString(),
      minAmount: (json['minAmount'] as num?)?.toDouble() ?? 5000.0,
      maxAmount: (json['maxAmount'] as num?)?.toDouble() ?? 50000000.0,
      maxRate: (json['maxRate'] as num?)?.toDouble() ?? 8.65,
      seniorCitizenBonus: (json['seniorCitizenBonus'] as num?)?.toDouble() ?? 0.25,
      womenInvestorBonus: (json['womenInvestorBonus'] as num?)?.toDouble() ?? 0.0,
      tenuresMonths: (json['tenuresMonths'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [12, 24, 36, 48, 60],
      payoutOptions: (json['payoutOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['CUMULATIVE', 'MONTHLY', 'QUARTERLY', 'HALF_YEARLY', 'ANNUALLY'],
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      schemes: (json['schemes'] as List<dynamic>?)
              ?.map((e) => FdSchemeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FdSchemeModel {
  final int tenureMonths;
  final double generalRate;
  final double seniorCitizenRate;
  final double womenRate;
  final String label;
  final String? tag;

  FdSchemeModel({
    required this.tenureMonths,
    required this.generalRate,
    required this.seniorCitizenRate,
    required this.womenRate,
    required this.label,
    this.tag,
  });

  factory FdSchemeModel.fromJson(Map<String, dynamic> json) {
    return FdSchemeModel(
      tenureMonths: (json['tenureMonths'] as num?)?.toInt() ?? 12,
      generalRate: (json['generalRate'] as num?)?.toDouble() ?? 7.0,
      seniorCitizenRate: (json['seniorCitizenRate'] as num?)?.toDouble() ?? 7.25,
      womenRate: (json['womenRate'] as num?)?.toDouble() ?? 7.0,
      label: json['label']?.toString() ?? '',
      tag: json['tag']?.toString(),
    );
  }
}

/// Dynamic FD Return Calculation Result
class FdCalculationResult {
  final double depositAmount;
  final int tenureMonths;
  final double interestRate;
  final String depositType;
  final String payoutFrequency;
  final double maturityAmount;
  final double periodicPayoutAmount;
  final double totalInterestEarned;

  FdCalculationResult({
    required this.depositAmount,
    required this.tenureMonths,
    required this.interestRate,
    required this.depositType,
    required this.payoutFrequency,
    required this.maturityAmount,
    required this.periodicPayoutAmount,
    required this.totalInterestEarned,
  });
}

/// User Submitted Fixed Deposit Application
class FdApplicationModel {
  final String id;
  final String applicationId;
  final String company;
  final String depositType;
  final String payoutFrequency;
  final double amount;
  final int tenureMonths;
  final double interestRate;
  final bool seniorCitizen;
  final bool womenInvestor;
  final double maturityAmount;
  final double periodicPayoutAmount;
  final bool autoRenewal;
  final String fullName;
  final String panNumber;
  final String mobileNumber;
  final String email;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String status;
  final String? irisApplicationNumber;
  final String? irisFolioNumber;
  final String? irisFDRNo;
  final String? adminRemarks;
  final DateTime createdAt;

  FdApplicationModel({
    required this.id,
    required this.applicationId,
    required this.company,
    required this.depositType,
    required this.payoutFrequency,
    required this.amount,
    required this.tenureMonths,
    required this.interestRate,
    required this.seniorCitizen,
    required this.womenInvestor,
    required this.maturityAmount,
    required this.periodicPayoutAmount,
    required this.autoRenewal,
    required this.fullName,
    required this.panNumber,
    required this.mobileNumber,
    required this.email,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.status,
    this.irisApplicationNumber,
    this.irisFolioNumber,
    this.irisFDRNo,
    this.adminRemarks,
    required this.createdAt,
  });

  factory FdApplicationModel.fromJson(Map<String, dynamic> json) {
    final deposit = json['depositDetails'] as Map<String, dynamic>? ?? {};
    final personal = json['personalDetails'] as Map<String, dynamic>? ?? {};
    final contact = json['contactDetails'] as Map<String, dynamic>? ?? {};
    final bank = json['bankDetails'] as Map<String, dynamic>? ?? {};
    final iris = json['irisTracking'] as Map<String, dynamic>? ?? {};

    return FdApplicationModel(
      id: json['_id']?.toString() ?? '',
      applicationId: json['applicationId']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      depositType: deposit['depositType']?.toString() ?? 'CUMULATIVE',
      payoutFrequency: deposit['payoutFrequency']?.toString() ?? 'CUMULATIVE',
      amount: (deposit['amount'] as num?)?.toDouble() ?? 0.0,
      tenureMonths: (deposit['tenureMonths'] as num?)?.toInt() ?? 12,
      interestRate: (deposit['interestRate'] as num?)?.toDouble() ?? 0.0,
      seniorCitizen: deposit['seniorCitizen'] == true,
      womenInvestor: deposit['womenInvestor'] == true,
      maturityAmount: (deposit['maturityAmount'] as num?)?.toDouble() ?? 0.0,
      periodicPayoutAmount: (deposit['periodicPayoutAmount'] as num?)?.toDouble() ?? 0.0,
      autoRenewal: deposit['autoRenewal'] == true,
      fullName: personal['fullName']?.toString() ?? '',
      panNumber: personal['panNumber']?.toString() ?? '',
      mobileNumber: contact['mobileNumber']?.toString() ?? '',
      email: contact['email']?.toString() ?? '',
      bankName: bank['bankName']?.toString() ?? '',
      accountNumber: bank['accountNumber']?.toString() ?? '',
      ifscCode: bank['ifscCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'SUBMITTED',
      irisApplicationNumber: iris['irisApplicationNumber']?.toString(),
      irisFolioNumber: iris['irisFolioNumber']?.toString(),
      irisFDRNo: iris['irisFDRNo']?.toString(),
      adminRemarks: iris['adminRemarks']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Bonds Configuration for WebView / External Website Launch
class BondsConfigModel {
  final String websiteUrl;
  final String title;
  final String description;
  final List<String> features;
  final List<Map<String, dynamic>> bondCategories;

  BondsConfigModel({
    required this.websiteUrl,
    required this.title,
    required this.description,
    required this.features,
    required this.bondCategories,
  });

  factory BondsConfigModel.fromJson(Map<String, dynamic> json) {
    return BondsConfigModel(
      websiteUrl: json['websiteUrl']?.toString() ?? 'https://www.vikaone.com/bonds',
      title: json['title']?.toString() ?? 'VikaOne Fixed Income & Bonds',
      description: json['description']?.toString() ?? 'Invest in Government, PSU, and AAA-rated Corporate Bonds.',
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      bondCategories: (json['bondCategories'] as List<dynamic>?)
              ?.map((e) => (e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
