class KycModel {
  final String? id;
  final String fullName;
  final String dob;
  final String addressLine1;
  final String city;
  final String state;
  final String pincode;
  final String panNumber;
  final String? aadhaarNumber;
  final String? panImageUrl;
  final String? aadhaarFrontUrl;
  final String? aadhaarBackUrl;
  final String? bankAccountHolderName;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankName;
  final String status; // not_submitted | pending | approved | rejected
  final String? rejectionReason;
  final bool isSoldier;
  final String? soldierIdNumber;
  final String? serviceBranch;
  final String? soldierIdCardUrl;
  final String soldierStatus; // not_submitted | pending | approved | rejected
  final String? soldierRejectionReason;

  KycModel({
    this.id,
    required this.fullName,
    required this.dob,
    required this.addressLine1,
    required this.city,
    required this.state,
    required this.pincode,
    required this.panNumber,
    this.aadhaarNumber,
    this.panImageUrl,
    this.aadhaarFrontUrl,
    this.aadhaarBackUrl,
    this.bankAccountHolderName,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankName,
    required this.status,
    this.rejectionReason,
    this.isSoldier = false,
    this.soldierIdNumber,
    this.serviceBranch,
    this.soldierIdCardUrl,
    this.soldierStatus = 'not_submitted',
    this.soldierRejectionReason,
  });

  factory KycModel.fromJson(Map<String, dynamic> j) {
    final soldier = j['soldierDetails'] as Map<String, dynamic>?;
    return KycModel(
      id: j['_id'],
      fullName: j['fullName'] ?? '',
      dob: j['dob'] ?? '',
      addressLine1: j['address']?['line1'] ?? '',
      city: j['address']?['city'] ?? '',
      state: j['address']?['state'] ?? '',
      pincode: j['address']?['pincode'] ?? '',
      panNumber: j['panNumber'] ?? '',
      aadhaarNumber: j['aadhaarNumber'],
      panImageUrl: j['panImage']?['url'],
      aadhaarFrontUrl: j['aadhaarFront']?['url'],
      aadhaarBackUrl: j['aadhaarBack']?['url'],
      bankAccountHolderName: j['bankDetails']?['accountHolderName'],
      bankAccountNumber: j['bankDetails']?['accountNumber'],
      bankIfscCode: j['bankDetails']?['ifscCode'],
      bankName: j['bankDetails']?['bankName'],
      status: j['status'] ?? 'pending',
      rejectionReason: j['rejectionReason'],
      isSoldier: soldier?['isSoldier'] == true,
      soldierIdNumber: soldier?['soldierIdNumber']?.toString(),
      serviceBranch: soldier?['serviceBranch']?.toString(),
      soldierIdCardUrl: soldier?['soldierIdCardUrl']?.toString(),
      soldierStatus: soldier?['status']?.toString() ?? 'not_submitted',
      soldierRejectionReason: soldier?['rejectionReason']?.toString(),
    );
  }

  bool get isApproved => status == 'approved';
  bool get isPending  => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get notSubmitted => status == 'not_submitted';
  bool get isSoldierApproved => soldierStatus == 'approved';
  bool get isSoldierPending => soldierStatus == 'pending';
  bool get isSoldierRejected => soldierStatus == 'rejected';
}