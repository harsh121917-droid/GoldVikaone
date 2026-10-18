class MfAccountDetails {
  final String clientCode;
  final String status;
  final String pan;
  final bool isUccRegistered;

  MfAccountDetails({
    required this.clientCode,
    required this.status,
    required this.pan,
    required this.isUccRegistered,
  });

  factory MfAccountDetails.fromJson(Map<String, dynamic> json) {
    return MfAccountDetails(
      clientCode: json['clientCode']?.toString() ?? 'NOT_REGISTERED',
      status: json['status']?.toString() ?? 'INACTIVE',
      pan: json['pan']?.toString() ?? '',
      isUccRegistered: json['isUccRegistered'] == true,
    );
  }
}

class MfPersonalDetails {
  final String fullName;
  final String pan;
  final String dob;
  final String gender;
  final String occupation;
  final String taxStatus;
  final String holdingNature;
  final Map<String, dynamic> address;
  final Map<String, dynamic> nominee;

  MfPersonalDetails({
    required this.fullName,
    required this.pan,
    required this.dob,
    required this.gender,
    required this.occupation,
    required this.taxStatus,
    required this.holdingNature,
    required this.address,
    required this.nominee,
  });

  factory MfPersonalDetails.fromJson(Map<String, dynamic> json) {
    return MfPersonalDetails(
      fullName: json['fullName']?.toString() ?? '',
      pan: json['pan']?.toString() ?? '',
      dob: json['dob']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      occupation: json['occupation']?.toString() ?? '',
      taxStatus: json['taxStatus']?.toString() ?? '',
      holdingNature: json['holdingNature']?.toString() ?? 'Single',
      address: json['address'] is Map<String, dynamic> ? json['address'] as Map<String, dynamic> : {},
      nominee: json['nominee'] is Map<String, dynamic> ? json['nominee'] as Map<String, dynamic> : {},
    );
  }

  String get formattedAddress {
    final a1 = address['address1']?.toString() ?? '';
    final city = address['city']?.toString() ?? '';
    final state = address['state']?.toString() ?? '';
    final pin = address['pincode']?.toString() ?? '';
    final parts = [a1, city, state, pin].where((p) => p.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }
}

class MfBankItem {
  final String id;
  final String accountNumber;
  final String ifsc;
  final String bankName;
  final String accountType;
  final String accountHolder;
  final bool isDefault;
  final bool isVerified;

  MfBankItem({
    required this.id,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
    required this.accountType,
    required this.accountHolder,
    required this.isDefault,
    required this.isVerified,
  });

  factory MfBankItem.fromJson(Map<String, dynamic> json) {
    return MfBankItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifsc: json['ifsc']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? 'Bank Account',
      accountType: json['accountType']?.toString() ?? 'savings',
      accountHolder: json['accountHolder']?.toString() ?? '',
      isDefault: json['isDefault'] == true,
      isVerified: json['isVerified'] == true,
    );
  }

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '•••• •••• ${accountNumber.substring(accountNumber.length - 4)}';
  }
}

class MfOrderItem {
  final String id;
  final String orderId;
  final String schemeCode;
  final String schemeName;
  final double amount;
  final double units;
  final double nav;
  final String orderType;
  final String status;
  final String passFailStatus; // 'PASSED', 'FAILED', 'PENDING'
  final String rejectionReason;
  final DateTime? createdAt;

  MfOrderItem({
    required this.id,
    required this.orderId,
    required this.schemeCode,
    required this.schemeName,
    required this.amount,
    required this.units,
    required this.nav,
    required this.orderType,
    required this.status,
    required this.passFailStatus,
    required this.rejectionReason,
    this.createdAt,
  });

  factory MfOrderItem.fromJson(Map<String, dynamic> json) {
    return MfOrderItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      schemeCode: json['schemeCode']?.toString() ?? '',
      schemeName: json['schemeName']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      units: (json['units'] as num?)?.toDouble() ?? 0.0,
      nav: (json['nav'] as num?)?.toDouble() ?? 0.0,
      orderType: json['orderType']?.toString() ?? 'PURCHASE',
      status: json['status']?.toString() ?? 'CREATED',
      passFailStatus: json['passFailStatus']?.toString() ?? 'PENDING',
      rejectionReason: json['rejectionReason']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  bool get isPassed => passFailStatus == 'PASSED';
  bool get isFailed => passFailStatus == 'FAILED';
  bool get isPending => !isPassed && !isFailed;
}

class MfProfileData {
  final String investorName;
  final String email;
  final String phone;
  final MfAccountDetails accountDetails;
  final MfPersonalDetails personalDetails;
  final List<MfBankItem> bankAccounts;
  final List<MfOrderItem> orders;

  MfProfileData({
    required this.investorName,
    required this.email,
    required this.phone,
    required this.accountDetails,
    required this.personalDetails,
    required this.bankAccounts,
    required this.orders,
  });

  factory MfProfileData.fromJson(Map<String, dynamic> json) {
    final accMap = json['accountDetails'] is Map<String, dynamic> ? json['accountDetails'] as Map<String, dynamic> : <String, dynamic>{};
    final persMap = json['personalDetails'] is Map<String, dynamic> ? json['personalDetails'] as Map<String, dynamic> : <String, dynamic>{};
    final rawBanks = json['bankAccounts'] as List<dynamic>? ?? [];
    final rawOrders = json['orders'] as List<dynamic>? ?? [];

    return MfProfileData(
      investorName: json['investorName']?.toString() ?? 'Investor',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      accountDetails: MfAccountDetails.fromJson(accMap),
      personalDetails: MfPersonalDetails.fromJson(persMap),
      bankAccounts: rawBanks.map((e) => MfBankItem.fromJson(e as Map<String, dynamic>)).toList(),
      orders: rawOrders.map((e) => MfOrderItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
