class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? referralCode;
  final double referralBalance;
  final String kycStatus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.referralCode,
    this.referralBalance = 0.0,
    this.kycStatus = 'not_submitted',
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['_id'] ?? j['id'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'],
    role: j['role'] ?? 'user',
    referralCode: j['referralCode'],
    referralBalance: (j['referralBalance'] as num?)?.toDouble() ?? 0.0,
    kycStatus: j['kycStatus']?.toString() ?? 'not_submitted',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'referralCode': referralCode,
    'referralBalance': referralBalance,
    'kycStatus': kycStatus,
  };
}
