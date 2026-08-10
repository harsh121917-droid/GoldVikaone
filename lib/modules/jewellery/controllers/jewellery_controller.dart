import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../data/repositories/jewellery_repository.dart';
import '../../digi_gold/controllers/digi_gold_controller.dart';
import '../../silver/controllers/silver_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';

class JewelleryController extends GetxController {
  static JewelleryController get to => Get.isRegistered<JewelleryController>()
      ? Get.find<JewelleryController>()
      : Get.put(JewelleryController());

  final _repo = JewelleryRepository();
  late Razorpay _razorpay;

  final isLoading = false.obs;
  final isRedeeming = false.obs;

  final categories = <Map<String, dynamic>>[].obs;
  final products = <Map<String, dynamic>>[].obs;

  final selectedCategory = 'All'.obs;
  final selectedMetal = 'all'.obs; // all, gold, silver
  final selectedSort = 'popular'.obs; // popular, price_low_high, price_high_low, weight_low_high, weight_high_low
  final searchQuery = ''.obs;

  // Pending Razorpay Redemption variables
  String? _pendingOrderId;
  String? _pendingRedemptionId;

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    loadAll();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final cats = await _repo.fetchCategories();
      categories.value = cats;
      await fetchProducts();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    try {
      final res = await _repo.fetchProducts(
        category: selectedCategory.value,
        metalType: selectedMetal.value,
        search: searchQuery.value,
        sort: selectedSort.value,
      );
      if (res.isNotEmpty) {
        products.value = res;
      } else {
        // Fallback default items if API returned empty
        products.value = _getDefaultProducts();
      }
    } catch (_) {
      products.value = _getDefaultProducts();
    }
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
    fetchProducts();
  }

  void selectMetal(String metal) {
    selectedMetal.value = metal;
    fetchProducts();
  }

  void setSort(String sort) {
    selectedSort.value = sort;
    fetchProducts();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    fetchProducts();
  }

  // Calculate product price based on live rates
  double calculateProductPrice(Map<String, dynamic> item) {
    final metal = (item['metalType'] ?? 'gold').toString().toLowerCase();
    final weight = (item['weightGrams'] ?? 0.0) is num
        ? (item['weightGrams'] as num).toDouble()
        : double.tryParse(item['weightGrams'].toString()) ?? 0.0;
    final making = (item['makingCharges'] ?? 1500) is num
        ? (item['makingCharges'] as num).toDouble()
        : double.tryParse(item['makingCharges'].toString()) ?? 1500.0;

    double ratePerGram = 7500.0; // Default Gold rate per g
    if (metal == 'gold') {
      if (Get.isRegistered<GoldController>()) {
        ratePerGram = GoldController.to.buyRate;
      }
    } else {
      if (Get.isRegistered<SilverController>()) {
        ratePerGram = SilverController.to.buyRate;
      } else {
        ratePerGram = 90.0; // Silver default rate
      }
    }

    final metalVal = weight * ratePerGram;
    final gst = (making * 0.03);
    return metalVal + making + gst;
  }

  // Initiate Redeem Flow
  Future<void> redeemItem(Map<String, dynamic> item, {String paymentMethod = 'razorpay'}) async {
    try {
      isRedeeming.value = true;
      final itemId = item['_id']?.toString() ?? '';

      final res = await _repo.initiateRedeemOrder(
        jewelleryId: itemId,
        paymentMethod: paymentMethod,
      );

      if (res['paidViaWallet'] == true) {
        isRedeeming.value = false;
        Get.snackbar(
          'Redeemed! 🎉',
          res['message'] ?? 'Jewellery order confirmed using wallet balance.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
        );
        // Refresh wallet
        if (Get.isRegistered<WalletController>()) {
          WalletController.to.loadWallet();
        }
        return;
      }

      if (res['success'] == true && res['orderId'] != null) {
        _pendingOrderId = res['orderId'];
        _pendingRedemptionId = res['redemptionId']?.toString();
        final amountInPaise = ((res['amount'] as num).toDouble() * 100).toInt();
        final keyId = res['keyId'] ?? 'rzp_test_dummy';

        final options = {
          'key': keyId,
          'amount': amountInPaise,
          'name': 'Payvika Jewellery Redeem',
          'description': 'Making charges & GST payment for ${item['name']}',
          'order_id': _pendingOrderId,
          'prefill': {
            'contact': '',
            'email': '',
          },
          'theme': {'color': '#D4A017'}
        };

        _razorpay.open(options);
      } else {
        isRedeeming.value = false;
        Get.snackbar(
          'Redeem Error',
          res['message'] ?? 'Failed to initiate redeem order',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isRedeeming.value = false;
      Get.snackbar(
        'Payment Failed',
        'Could not complete transaction: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: Colors.white,
      );
    }
  }

  void _onPaySuccess(PaymentSuccessResponse response) async {
    try {
      final verifyRes = await _repo.verifyRedeemOrder(
        orderId: response.orderId ?? _pendingOrderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
        redemptionId: _pendingRedemptionId ?? '',
      );

      isRedeeming.value = false;
      if (verifyRes['success'] == true) {
        Get.snackbar(
          'Redemption Successful! 🥇',
          'Your jewellery item is confirmed & will be dispatched soon.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        loadAll();
      } else {
        Get.snackbar(
          'Verification Failed',
          verifyRes['message'] ?? 'Payment completed but order verification failed',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isRedeeming.value = false;
      Get.snackbar(
        'Error',
        'Payment verification failed: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: Colors.white,
      );
    }
  }

  void _onPayError(PaymentFailureResponse response) {
    isRedeeming.value = false;
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Transaction cancelled or failed',
      backgroundColor: const Color(0xFFE53E3E),
      colorText: Colors.white,
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    isRedeeming.value = false;
  }

  List<Map<String, dynamic>> _getDefaultProducts() {
    final list = [
      {
        '_id': 'p1',
        'name': 'Premium 22K Gold Wedding Ring',
        'category': 'Rings',
        'metalType': 'gold',
        'purity': '22K Gold',
        'weightGrams': 5.5,
        'makingCharges': 2500,
        'gstPercentage': 3,
        'description': 'Exquisite 22K hallmarked gold wedding band crafted with elegance.',
        'imageUrl': '',
        'icon': Icons.diamond_outlined,
        'inStock': true,
        'isPopular': true,
      },
      {
        '_id': 'p2',
        'name': '18K Diamond Solitaire Band',
        'category': 'Rings',
        'metalType': 'gold',
        'purity': '18K Gold',
        'weightGrams': 4.2,
        'makingCharges': 4500,
        'gstPercentage': 3,
        'description': 'Sparkling 18K gold band set with lab-certified diamonds.',
        'imageUrl': '',
        'icon': Icons.diamond_outlined,
        'inStock': true,
        'isPopular': true,
      },
      {
        '_id': 'p3',
        'name': '22K Kundan Choker Necklace',
        'category': 'Necklaces',
        'metalType': 'gold',
        'purity': '22K Gold',
        'weightGrams': 28.4,
        'makingCharges': 12000,
        'gstPercentage': 3,
        'description': 'Royal royal Kundan choker handcrafted by master artisans.',
        'imageUrl': '',
        'icon': Icons.filter_vintage_outlined,
        'inStock': true,
        'isPopular': true,
      },
      {
        '_id': 'p4',
        'name': 'Traditional Gold Jhumka Earrings',
        'category': 'Earrings',
        'metalType': 'gold',
        'purity': '22K Gold',
        'weightGrams': 12.8,
        'makingCharges': 3500,
        'gstPercentage': 3,
        'description': 'Classic ethnic Indian Jhumkas in 22K yellow gold.',
        'imageUrl': '',
        'icon': Icons.spa_outlined,
        'inStock': true,
        'isPopular': false,
      },
      {
        '_id': 'p5',
        'name': '24K Designer Peacock Kada',
        'category': 'Kadas',
        'metalType': 'gold',
        'purity': '24K Pure Gold',
        'weightGrams': 22.0,
        'makingCharges': 8500,
        'gstPercentage': 3,
        'description': 'Intricately carved peacock design 24K pure gold Kada.',
        'imageUrl': '',
        'icon': Icons.circle_outlined,
        'inStock': true,
        'isPopular': true,
      },
      {
        '_id': 'p6',
        'name': '999 Sterling Silver Premium Kada',
        'category': 'Bracelets',
        'metalType': 'silver',
        'purity': '999 Fine Silver',
        'weightGrams': 45.0,
        'makingCharges': 950,
        'gstPercentage': 3,
        'description': 'Heavy 999 fine silver cuff Kada for daily wear.',
        'imageUrl': '',
        'icon': Icons.circle_outlined,
        'inStock': true,
        'isPopular': false,
      },
    ];

    if (selectedCategory.value != 'All') {
      return list.where((p) => p['category'] == selectedCategory.value).toList();
    }
    if (selectedMetal.value != 'all') {
      return list.where((p) => p['metalType'] == selectedMetal.value).toList();
    }
    return list;
  }
}
