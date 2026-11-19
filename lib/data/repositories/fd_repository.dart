import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/fd_models.dart';

class FdRepository {
  final Dio _dio = ApiClient.instance;

  /// Fetches available FD Companies (Bajaj, Shriram, Mahindra), their schemes, and prefill data
  Future<Map<String, dynamic>> getCompanies() async {
    try {
      final res = await _dio.get('/fixed-deposits/companies');
      if (res.data != null && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>?)
                ?.map((item) => FdCompanyModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        final prefill = res.data['prefill'] as Map<String, dynamic>? ?? {};
        return {
          'companies': list,
          'prefill': prefill,
        };
      }
      return {'companies': <FdCompanyModel>[], 'prefill': <String, dynamic>{}};
    } catch (e) {
      rethrow;
    }
  }

  /// Submits an end-to-end IRIS FD Application
  Future<Map<String, dynamic>> submitApplication(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/fixed-deposits/apply', data: payload);
      if (res.data != null && res.data['success'] == true) {
        return res.data as Map<String, dynamic>;
      }
      throw Exception(res.data?['message'] ?? 'Failed to submit application');
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves all FD applications submitted by the logged-in customer
  Future<List<FdApplicationModel>> getMyApplications() async {
    try {
      final res = await _dio.get('/fixed-deposits/my-applications');
      if (res.data != null && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>?)
                ?.map((item) => FdApplicationModel.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];
        return list;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves single FD application details
  Future<FdApplicationModel?> getApplicationDetails(String id) async {
    try {
      final res = await _dio.get('/fixed-deposits/applications/$id');
      if (res.data != null && res.data['success'] == true && res.data['data'] != null) {
        return FdApplicationModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves Bonds portal configuration & details
  Future<BondsConfigModel> getBondsConfig() async {
    try {
      final res = await _dio.get('/fixed-deposits/bonds');
      if (res.data != null && res.data['success'] == true && res.data['data'] != null) {
        return BondsConfigModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
      return BondsConfigModel(
        websiteUrl: 'https://www.vikaone.com/bonds',
        title: 'VikaOne Fixed Income & Bonds',
        description: 'Invest in Sovereign Gold Bonds, Government Bonds, and AAA-rated Corporate Bonds.',
        features: [
          'Guaranteed periodic coupon payouts (up to 9.25% p.a.)',
          'Sovereign / PSU / AAA-grade corporate security',
          'Section 54EC Capital Gains tax exemption options',
          'Zero demat requirement for secondary market purchase',
        ],
        bondCategories: [
          {'name': 'Sovereign Gold Bonds (SGB)', 'interestRate': '2.50% + Gold Appreciation', 'tenure': '8 Years', 'risk': 'Sovereign / Nil'},
          {'name': 'PSU / Bharat Bonds', 'interestRate': '7.45% - 7.80% p.a.', 'tenure': '3 - 10 Years', 'risk': 'Very Low'},
          {'name': 'Corporate AAA High-Yield Bonds', 'interestRate': '8.20% - 9.40% p.a.', 'tenure': '1 - 5 Years', 'risk': 'Moderate'},
          {'name': '54EC Capital Gains Bonds', 'interestRate': '5.25% p.a. (Tax Exemption)', 'tenure': '5 Years', 'risk': 'Sovereign / Nil'},
        ],
      );
    } catch (e) {
      return BondsConfigModel(
        websiteUrl: 'https://www.vikaone.com/bonds',
        title: 'VikaOne Fixed Income & Bonds',
        description: 'Invest in Sovereign Gold Bonds, Government Bonds, and AAA-rated Corporate Bonds.',
        features: [
          'Guaranteed periodic coupon payouts (up to 9.25% p.a.)',
          'Sovereign / PSU / AAA-grade corporate security',
          'Section 54EC Capital Gains tax exemption options',
        ],
        bondCategories: [
          {'name': 'Sovereign Gold Bonds (SGB)', 'interestRate': '2.50% + Gold Appreciation', 'tenure': '8 Years', 'risk': 'Sovereign / Nil'},
          {'name': 'Corporate AAA High-Yield Bonds', 'interestRate': '8.20% - 9.40% p.a.', 'tenure': '1 - 5 Years', 'risk': 'Moderate'},
        ],
      );
    }
  }
}
