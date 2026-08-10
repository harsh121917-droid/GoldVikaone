import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/kyc_model.dart';

class KycRepository {
  final _dio = ApiClient.instance;

  /// Returns null if user hasn't submitted KYC yet.
  Future<KycModel?> getMyKyc() async {
    final res = await _dio.get(ApiConstants.kycMe);
    if (res.data['data'] == null) return null;
    final model = KycModel.fromJson(res.data['data']);
    // backend sends status separately too; prefer it if present
    return model;
  }

  Future<Map<String, dynamic>> submitKyc({
    required String fullName,
    required String dob, // yyyy-MM-dd
    required String addressLine1,
    required String city,
    required String state,
    required String pincode,
    required String panNumber,
    required String aadhaarNumber,
    String? bankAccountHolderName,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankName,
    required String panImagePath,
    required String aadhaarFrontPath,
    required String aadhaarBackPath,
  }) async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      'dob': dob,
      'address.line1': addressLine1,
      'address.city': city,
      'address.state': state,
      'address.pincode': pincode,
      'panNumber': panNumber,
      'aadhaarNumber': aadhaarNumber,
      'bankDetails.accountHolderName': bankAccountHolderName ?? '',
      'bankDetails.accountNumber': bankAccountNumber ?? '',
      'bankDetails.ifscCode': bankIfscCode ?? '',
      'bankDetails.bankName': bankName ?? '',
      'panImage': await MultipartFile.fromFile(panImagePath),
      'aadhaarFront': await MultipartFile.fromFile(aadhaarFrontPath),
      'aadhaarBack': await MultipartFile.fromFile(aadhaarBackPath),
    });

    final res = await _dio.post(ApiConstants.kycSubmit, data: formData);
    return res.data;
  }

  Future<Map<String, dynamic>> initiateDigio() async {
    final res = await _dio.post('/kyc/digio/initiate');
    return res.data;
  }

  Future<Map<String, dynamic>> verifyDigio(
    String kycId, {
    String? panNumber,
    String? aadhaarNumber,
  }) async {
    final res = await _dio.post('/kyc/digio/verify/$kycId', data: {
      if (panNumber != null) 'panNumber': panNumber,
      if (aadhaarNumber != null) 'aadhaarNumber': aadhaarNumber,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> initiateCashfreeOtp(String aadhaarNumber) async {
    final res = await _dio.post('/kyc/cashfree/otp', data: {
      'aadhaarNumber': aadhaarNumber,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> verifyCashfreeOtp({
    required String otp,
    required String refId,
    required String aadhaarNumber,
    String? panNumber,
  }) async {
    final res = await _dio.post('/kyc/cashfree/verify', data: {
      'otp': otp,
      'refId': refId,
      'aadhaarNumber': aadhaarNumber,
      if (panNumber != null) 'panNumber': panNumber,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> verifyCashfreePan({
    required String pan,
    required String name,
  }) async {
    final res = await _dio.post('/kyc/cashfree/pan', data: {
      'pan': pan,
      'name': name,
    });
    return res.data;
  }
}