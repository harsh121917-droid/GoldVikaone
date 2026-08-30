import '../../core/network/api_client.dart';

class JewelleryRepository {
  final _dio = ApiClient.instance;

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final res = await _dio.get('/jewellery/categories');
      if (res.data['success'] == true && res.data['data'] != null) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (_) {}
    return [
      {'name': 'All', 'icon': 'fas fa-gem'},
      {'name': 'Rings', 'icon': 'fas fa-ring'},
      {'name': 'Necklaces', 'icon': 'fas fa-gem'},
      {'name': 'Earrings', 'icon': 'fas fa-sparkles'},
      {'name': 'Bracelets', 'icon': 'fas fa-circle-notch'},
      {'name': 'Kadas', 'icon': 'fas fa-circle'},
      {'name': 'Coins', 'icon': 'fas fa-coins'},
    ];
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    String category = 'All',
    String metalType = 'all',
    String search = '',
    String sort = 'popular',
  }) async {
    try {
      final queryParams = {
        if (category != 'All') 'category': category,
        if (metalType != 'all') 'metalType': metalType,
        if (search.isNotEmpty) 'search': search,
        'sort': sort,
      };

      final res = await _dio.get('/jewellery/products', queryParameters: queryParams);
      if (res.data['success'] == true && res.data['data'] != null) {
        return List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (_) {}

    return [];
  }

  Future<Map<String, dynamic>> initiateRedeemOrder({
    required String jewelleryId,
    required String paymentMethod,
    bool useVault = false,
    double vaultGramsToUse = 0.0,
    String purchaseType = 'direct_buy',
  }) async {
    final res = await _dio.post('/jewellery/redeem/initiate', data: {
      'jewelleryId': jewelleryId,
      'paymentMethod': paymentMethod,
      'useVault': useVault,
      'vaultGramsToUse': vaultGramsToUse,
      'purchaseType': purchaseType,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> verifyRedeemOrder({
    required String orderId,
    required String paymentId,
    required String signature,
    required String redemptionId,
  }) async {
    final res = await _dio.post('/jewellery/redeem/verify', data: {
      'razorpay_order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_signature': signature,
      'redemptionId': redemptionId,
    });
    return res.data;
  }
}
