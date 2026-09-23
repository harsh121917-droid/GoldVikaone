import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../../../data/models/mf_portfolio_model.dart';

class MutualFundsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPortfolioLoading = false.obs;
  final RxBool isSubmittingOrder = false.obs;
  final RxBool isUccLoading = false.obs;

  // ── Dedicated Razorpay Mutual Funds Gateway ──
  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingCheckout;
  Completer<bool>? _paymentCompleter;

  // ── Pagination & Search State ──
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalSchemesCount = 0.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  Timer? _debounceTimer;

  final RxString selectedCategory = 'All'.obs;
  final RxString selectedFilterChip = 'All'.obs;
  final RxString selectedSort = '3Y Returns'.obs;
  final RxString selectedReturnPeriod = '3Y'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<MfSchemeModel> schemes = <MfSchemeModel>[].obs;
  final RxList<String> watchlistSchemeCodes = <String>['1001', '1003', '1004'].obs;
  final RxList<MfSchemeModel> recentlyViewed = <MfSchemeModel>[].obs;

  final Rx<MfPortfolioSummary?> portfolioSummary = Rx<MfPortfolioSummary?>(null);
  final RxList<MfHolding> holdings = <MfHolding>[].obs;
  final RxList<MfActiveSip> activeSips = <MfActiveSip>[].obs;
  final Rx<MfUccModel?> userUcc = Rx<MfUccModel?>(null);
  final RxBool hasUcc = false.obs;
  final RxMap<String, dynamic> uccPrefill = <String, dynamic>{}.obs;

  final List<String> categories = const [
    'All',
    'Equity',
    'Gold & Commodity',
    'Tax Saver (ELSS)',
    'Hybrid',
    'Debt',
    'Liquid & Overnight',
  ];

  final List<String> filterChips = const [
    'All',
    'Index only',
    'Flexi Cap',
    'Small Cap',
    'Mid Cap',
    'Large Cap',
    'Gold & Silver',
    'High Return',
  ];

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    fetchSchemes();
    checkUserUcc();
    fetchPortfolio();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRzpSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRzpError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRzpExternal);
  }

  @override
  void onClose() {
    _razorpay.clear();
    _debounceTimer?.cancel();
    super.onClose();
  }

  List<MfSchemeModel> get popularFunds {
    if (schemes.isEmpty) return [];
    final list = List<MfSchemeModel>.from(schemes);
    list.sort((a, b) => b.cagr3Y.compareTo(a.cagr3Y));
    return list.take(6).toList();
  }

  List<MfSchemeModel> get watchlistSchemes {
    return schemes.where((s) => watchlistSchemeCodes.contains(s.schemeCode)).toList();
  }

  List<MfSchemeModel> get filteredSchemes {
    return schemes;
  }

  void toggleWatchlist(String schemeCode) {
    if (watchlistSchemeCodes.contains(schemeCode)) {
      watchlistSchemeCodes.remove(schemeCode);
    } else {
      watchlistSchemeCodes.add(schemeCode);
    }
  }

  void recordRecentlyViewed(MfSchemeModel scheme) {
    recentlyViewed.removeWhere((s) => s.schemeCode == scheme.schemeCode);
    recentlyViewed.insert(0, scheme);
    if (recentlyViewed.length > 6) recentlyViewed.removeLast();
  }

  // ── Fetch Schemes with Server Pagination & Live Search ──
  Future<void> fetchSchemes({
    String? category,
    String? search,
    int page = 1,
    bool isRefresh = false,
  }) async {
    if (isRefresh || page == 1) {
      isLoading.value = true;
      currentPage.value = 1;
      hasMore.value = true;
    } else {
      if (isLoadingMore.value || !hasMore.value) return;
      isLoadingMore.value = true;
    }

    try {
      final dio = ApiClient.instance;
      final cat = category ?? selectedCategory.value;
      final q = search ?? searchQuery.value;

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': 20,
      };
      if (cat != 'All') queryParams['category'] = cat;
      if (q.trim().isNotEmpty) queryParams['search'] = q.trim();

      if (selectedSort.value == '3Y Returns') {
        queryParams['sort'] = 'returns3y';
      } else if (selectedSort.value == '1Y Returns') {
        queryParams['sort'] = 'returns1y';
      } else if (selectedSort.value == '5Y Returns') {
        queryParams['sort'] = 'returns5y';
      } else if (selectedSort.value == 'Rating') {
        queryParams['sort'] = 'rating';
      } else if (selectedSort.value == 'NAV') {
        queryParams['sort'] = 'nav';
      }

      final res = await dio.get('/mutual-funds/schemes', queryParameters: queryParams);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>?)
                ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        totalSchemesCount.value = res.data['total'] ?? list.length;
        totalPages.value = res.data['pages'] ?? 1;
        currentPage.value = res.data['page'] ?? page;
        hasMore.value = currentPage.value < totalPages.value;

        if (page == 1) {
          schemes.assignAll(list);
        } else {
          final existingCodes = schemes.map((s) => s.schemeCode).toSet();
          for (final item in list) {
            if (!existingCodes.contains(item.schemeCode)) {
              schemes.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchSchemes error: $e');
    } finally {
      if (recentlyViewed.isEmpty && schemes.isNotEmpty) {
        recentlyViewed.assignAll(schemes.take(3));
      }
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreSchemes() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    await fetchSchemes(page: currentPage.value + 1);
  }

  // ── Verified Default Schemes Matching Reference Groww Catalog ──
  List<MfSchemeModel> _getDefaultSchemes() {
    final raw = [
      {
        '_id': '1',
        'schemeCode': '1001',
        'schemeName': 'Bandhan Small Cap Fund',
        'amcName': 'Bandhan Mutual Fund',
        'amcCode': 'BANDHAN',
        'category': 'Equity Small Cap',
        'nav': 38.64,
        'cagr1Y': 34.20,
        'cagr3Y': 24.78,
        'cagr5Y': 29.40,
        'riskLevel': 'Very High',
        'rating': 5,
        'minSipAmount': 100.0,
        'minPurchaseAmount': 1000.0,
        'expenseRatio': 0.72,
        'aum': 5420.0,
        'fundManager': 'Manish Gunwani',
      },
      {
        '_id': '2',
        'schemeCode': '1002',
        'schemeName': 'SBI Gold Direct Plan-Growth',
        'amcName': 'SBI Mutual Fund',
        'amcCode': 'SBI',
        'category': 'Commodities Gold',
        'nav': 24.15,
        'cagr1Y': 28.50,
        'cagr3Y': 35.89,
        'cagr5Y': 21.30,
        'riskLevel': 'Moderately High',
        'rating': 4,
        'minSipAmount': 500.0,
        'minPurchaseAmount': 5000.0,
        'expenseRatio': 0.45,
        'aum': 8120.0,
        'fundManager': 'Raviprakash Sharma',
      },
      {
        '_id': '3',
        'schemeCode': '1003',
        'schemeName': 'Parag Parikh Flexi Cap Fund',
        'amcName': 'PPFAS Mutual Fund',
        'amcCode': 'PPFAS',
        'category': 'Equity Flexi Cap',
        'nav': 74.20,
        'cagr1Y': 26.80,
        'cagr3Y': 20.40,
        'cagr5Y': 24.10,
        'riskLevel': 'Very High',
        'rating': 5,
        'minSipAmount': 1000.0,
        'minPurchaseAmount': 1000.0,
        'expenseRatio': 0.65,
        'aum': 62400.0,
        'fundManager': 'Rajeev Thakkar',
      },
      {
        '_id': '4',
        'schemeCode': '1004',
        'schemeName': 'HDFC Mid Cap Fund',
        'amcName': 'HDFC Mutual Fund',
        'amcCode': 'HDFC',
        'category': 'Equity Mid Cap',
        'nav': 182.50,
        'cagr1Y': 22.40,
        'cagr3Y': 17.22,
        'cagr5Y': 23.50,
        'riskLevel': 'Very High',
        'rating': 5,
        'minSipAmount': 100.0,
        'minPurchaseAmount': 5000.0,
        'expenseRatio': 0.85,
        'aum': 71300.0,
        'fundManager': 'Chirag Setalvad',
      },
      {
        '_id': '5',
        'schemeCode': '1005',
        'schemeName': 'Motilal Oswal Midcap Fund',
        'amcName': 'Motilal Oswal Mutual Fund',
        'amcCode': 'MOTILAL',
        'category': 'Equity Mid Cap',
        'nav': 98.40,
        'cagr1Y': 24.10,
        'cagr3Y': 18.81,
        'cagr5Y': 22.70,
        'riskLevel': 'Very High',
        'rating': 4,
        'minSipAmount': 500.0,
        'minPurchaseAmount': 5000.0,
        'expenseRatio': 0.70,
        'aum': 14200.0,
        'fundManager': 'Niket Shah',
      },
      {
        '_id': '6',
        'schemeCode': '1006',
        'schemeName': 'Nippon India Small Cap Fund',
        'amcName': 'Nippon India Mutual Fund',
        'amcCode': 'NIPPON',
        'category': 'Equity Small Cap',
        'nav': 148.90,
        'cagr1Y': 21.00,
        'cagr3Y': 15.41,
        'cagr5Y': 27.80,
        'riskLevel': 'Very High',
        'rating': 4,
        'minSipAmount': 100.0,
        'minPurchaseAmount': 5000.0,
        'expenseRatio': 0.75,
        'aum': 56100.0,
        'fundManager': 'Samir Rachh',
      },
      {
        '_id': '7',
        'schemeCode': '1007',
        'schemeName': 'HDFC Silver ETF FoF Direct-Growth',
        'amcName': 'HDFC Mutual Fund',
        'amcCode': 'HDFC',
        'category': 'Commodities Silver',
        'nav': 16.80,
        'cagr1Y': 42.10,
        'cagr3Y': 45.95,
        'cagr5Y': 30.50,
        'riskLevel': 'Very High',
        'rating': 4,
        'minSipAmount': 100.0,
        'minPurchaseAmount': 1000.0,
        'expenseRatio': 0.35,
        'aum': 3400.0,
        'fundManager': 'Nirman Morakhia',
      },
      {
        '_id': '8',
        'schemeCode': '1008',
        'schemeName': 'ICICI Prudential Bluechip Fund',
        'amcName': 'ICICI Prudential Mutual Fund',
        'amcCode': 'ICICI',
        'category': 'Large Cap',
        'nav': 112.40,
        'cagr1Y': 19.80,
        'cagr3Y': 16.45,
        'cagr5Y': 18.20,
        'riskLevel': 'Very High',
        'rating': 5,
        'minSipAmount': 100.0,
        'minPurchaseAmount': 1000.0,
        'expenseRatio': 0.90,
        'aum': 52000.0,
        'fundManager': 'Anish Tawakley',
      },
    ];
    return raw.map((m) => MfSchemeModel.fromJson(m)).toList();
  }

  // ── Check User UCC ──
  Future<void> checkUserUcc() async {
    isUccLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/ucc/me');
      if (res.statusCode == 200 && res.data['success'] == true) {
        hasUcc.value = res.data['exists'] == true;
        if (hasUcc.value && res.data['data'] != null) {
          userUcc.value = MfUccModel.fromJson(res.data['data']);
        } else if (res.data['prefill'] != null) {
          uccPrefill.assignAll(Map<String, dynamic>.from(res.data['prefill']));
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] checkUserUcc error: $e');
    } finally {
      isUccLoading.value = false;
    }
  }

  // ── Register User UCC ──
  Future<bool> registerUcc({
    required String pan,
    required String accountNo,
    required String ifsc,
    String? bankName,
    String? nomineeName,
    String? nomineeRelation,
    String? dob,
    String? gender,
  }) async {
    isUccLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/ucc/register', data: {
        'pan': pan.trim().toUpperCase(),
        'accountNo': accountNo.trim(),
        'ifsc': ifsc.trim().toUpperCase(),
        'bankName': bankName ?? '',
        'nomineeName': nomineeName ?? '',
        'nomineeRelation': nomineeRelation ?? '01',
        'dob': dob ?? '01/01/1990',
        'gender': gender ?? 'M',
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        hasUcc.value = true;
        userUcc.value = MfUccModel.fromJson(res.data['data']);
        Get.snackbar(
          'UCC Registered',
          'Your NSE investor code has been activated: ${userUcc.value?.clientCode}',
          backgroundColor: const Color(0xFF00D09C),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          'Registration Failed',
          res.data['message'] ?? 'Could not register UCC with NSE',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to connect to NSE gateway: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUccLoading.value = false;
    }
  }

  // ── Place Lumpsum Purchase Order via Razorpay MF Gateway ──
  Future<bool> createPurchaseOrder({
    required String schemeCode,
    required double orderAmount,
    String? schemeName,
    String paymentMode = 'RAZORPAY',
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/orders/purchase', data: {
        'schemeCode': schemeCode,
        'orderAmount': orderAmount,
        'paymentMode': paymentMode,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final rzpOrderId = data?['razorpayOrderId']?.toString();
        final rzpKey = data?['key']?.toString();

        final paymentLink = data?['paymentLink']?.toString();

        // If user chose NSE Official Gateway / payment link
        if (paymentMode == 'NSE_GATEWAY' || paymentMode == 'NSE_PAYMENT_LINK') {
          if (paymentLink != null && paymentLink.isNotEmpty) {
            final uri = Uri.parse(paymentLink);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
          Get.snackbar(
            'NSE Official Payment Link',
            'Payment link opened in browser. Please authorize transaction.',
            backgroundColor: const Color(0xFF00D09C),
            colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
          fetchPortfolio();
          return true;
        }

        if (rzpOrderId != null && rzpOrderId.isNotEmpty && rzpKey != null && rzpKey.isNotEmpty) {
          final user = Get.isRegistered<AuthService>() ? Get.find<AuthService>().currentUser : null;
          final orderId = data['order']?['orderId'] ?? rzpOrderId;
          _pendingCheckout = {
            'type': 'PURCHASE',
            'orderId': orderId,
            'razorpayOrderId': rzpOrderId,
            'schemeCode': schemeCode,
            'schemeName': schemeName ?? 'Mutual Fund',
            'amount': orderAmount,
          };

          _paymentCompleter = Completer<bool>();
          final options = {
            'key': rzpKey,
            'amount': (orderAmount * 100).round(),
            'name': 'Payvika Mutual Funds',
            'description': 'Lumpsum - ${schemeName ?? schemeCode}',
            'order_id': rzpOrderId,
            'prefill': {
              'name': user?.name ?? 'Investor',
              'email': user?.email ?? '',
              'contact': user?.phone ?? '',
            },
            'theme': {'color': '#00D09C'},
          };

          _razorpay.open(options);
          return await _paymentCompleter!.future;
        }

        // Fallback: If no Razorpay keys configured
        final paymentLink = data?['paymentLink']?.toString();
        if (paymentLink != null && paymentLink.isNotEmpty) {
          final uri = Uri.parse(paymentLink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        Get.snackbar(
          'Order Placed',
          'Order confirmed and allotted in your portfolio.',
          backgroundColor: const Color(0xFF00D09C),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchPortfolio();
        return true;
      } else {
        Get.snackbar(
          'Order Failed',
          res.data['message'] ?? 'Could not submit order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit order: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      if (_paymentCompleter == null || _paymentCompleter!.isCompleted) {
        isSubmittingOrder.value = false;
      }
    }
  }

  // ── Register SIP / XSIP with Razorpay 1st Installment ──
  Future<bool> registerSipOrder({
    required String schemeCode,
    required double installmentAmount,
    String? schemeName,
    String frequency = 'MONTHLY',
    DateTime? startDate,
    bool stepUpRequired = false,
    double stepUpAmount = 0,
    String paymentMode = 'RAZORPAY',
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/sip/register', data: {
        'schemeCode': schemeCode,
        'installmentAmount': installmentAmount,
        'frequency': frequency,
        'startDate': startDate?.toIso8601String(),
        'stepUpRequired': stepUpRequired,
        'stepUpAmount': stepUpAmount,
        'paymentMode': paymentMode,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final rzpOrderId = data?['razorpayOrderId']?.toString();
        final rzpKey = data?['key']?.toString();
        final sipId = data?['sipId']?.toString() ?? data?['sip']?['_id']?.toString();

        final paymentLink = data?['paymentLink']?.toString();

        // If user chose NSE Official Gateway / payment link
        if (paymentMode == 'NSE_GATEWAY' || paymentMode == 'NSE_PAYMENT_LINK') {
          if (paymentLink != null && paymentLink.isNotEmpty) {
            final uri = Uri.parse(paymentLink);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
          Get.snackbar(
            'NSE Payment Link Opened',
            'Official NSE XSIP mandate / payment link opened in browser.',
            backgroundColor: const Color(0xFF00D09C),
            colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
          fetchPortfolio();
          return true;
        }

        // Razorpay for testing
        if (paymentMode == 'RAZORPAY' && rzpOrderId != null && rzpOrderId.isNotEmpty && rzpKey != null && rzpKey.isNotEmpty) {
          final user = Get.isRegistered<AuthService>() ? Get.find<AuthService>().currentUser : null;
          _pendingCheckout = {
            'type': 'SIP',
            'sipId': sipId,
            'razorpayOrderId': rzpOrderId,
            'schemeCode': schemeCode,
            'schemeName': schemeName ?? 'Mutual Fund SIP',
            'amount': installmentAmount,
          };

          _paymentCompleter = Completer<bool>();
          final options = {
            'key': rzpKey,
            'amount': (installmentAmount * 100).round(),
            'name': 'Payvika Mutual Funds',
            'description': '1st Installment - ${schemeName ?? schemeCode}',
            'order_id': rzpOrderId,
            'prefill': {
              'name': user?.name ?? 'Investor',
              'email': user?.email ?? '',
              'contact': user?.phone ?? '',
            },
            'theme': {'color': '#00D09C'},
          };

          _razorpay.open(options);
          return await _paymentCompleter!.future;
        }

        Get.snackbar(
          'SIP Registered',
          'Monthly SIP scheduled successfully on NSE MFSS',
          backgroundColor: const Color(0xFF00D09C),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
        fetchPortfolio();
        return true;
      } else {
        Get.snackbar(
          'SIP Registration Failed',
          res.data['message'] ?? 'Could not register SIP with NSE',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to register SIP: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      if (_paymentCompleter == null || _paymentCompleter!.isCompleted) {
        isSubmittingOrder.value = false;
      }
    }
  }

  // ── Razorpay Callback Handlers ──
  Future<void> _handleRzpSuccess(PaymentSuccessResponse response) async {
    try {
      final dio = ApiClient.instance;
      final checkout = _pendingCheckout;
      if (checkout == null) {
        _paymentCompleter?.complete(true);
        return;
      }

      if (checkout['type'] == 'PURCHASE') {
        final res = await dio.post('/mutual-funds/orders/verify', data: {
          'orderId': checkout['orderId'],
          'razorpayOrderId': response.orderId ?? checkout['razorpayOrderId'] ?? '',
          'razorpayPaymentId': response.paymentId ?? '',
          'razorpaySignature': response.signature ?? '',
        });

        if (res.statusCode == 200 && res.data['success'] == true) {
          Get.snackbar(
            '🎉 Investment Successful!',
            '₹${checkout['amount']} invested in ${checkout['schemeName']} via Razorpay MF.',
            backgroundColor: const Color(0xFF00D09C),
            colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          fetchPortfolio();
          _paymentCompleter?.complete(true);
        } else {
          Get.snackbar('Verification Failed', res.data['message'] ?? 'Could not verify investment payment', backgroundColor: Colors.red, colorText: Colors.white);
          _paymentCompleter?.complete(false);
        }
      } else if (checkout['type'] == 'SIP') {
        final res = await dio.post('/mutual-funds/sip/verify', data: {
          'sipId': checkout['sipId'],
          'razorpayOrderId': response.orderId ?? checkout['razorpayOrderId'] ?? '',
          'razorpayPaymentId': response.paymentId ?? '',
          'razorpaySignature': response.signature ?? '',
        });

        if (res.statusCode == 200 && res.data['success'] == true) {
          Get.snackbar(
            '🎉 SIP Activated Successfully!',
            '1st installment paid via Razorpay MF and monthly schedule is active.',
            backgroundColor: const Color(0xFF00D09C),
            colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          fetchPortfolio();
          _paymentCompleter?.complete(true);
        } else {
          Get.snackbar('Verification Failed', res.data['message'] ?? 'Could not verify SIP payment', backgroundColor: Colors.red, colorText: Colors.white);
          _paymentCompleter?.complete(false);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment verification error: $e', backgroundColor: Colors.red, colorText: Colors.white);
      _paymentCompleter?.complete(false);
    } finally {
      isSubmittingOrder.value = false;
      _pendingCheckout = null;
    }
  }

  void _handleRzpError(PaymentFailureResponse response) {
    isSubmittingOrder.value = false;
    _pendingCheckout = null;
    Get.snackbar(
      'Payment Cancelled',
      response.message ?? 'Mutual fund payment was not completed.',
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    _paymentCompleter?.complete(false);
  }

  void _handleRzpExternal(ExternalWalletResponse response) {}

  // ── Fetch Portfolio ──
  Future<void> fetchPortfolio() async {
    isPortfolioLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/portfolio');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        if (data['summary'] != null) {
          portfolioSummary.value = MfPortfolioSummary.fromJson(data['summary']);
        }
        if (data['holdings'] != null) {
          holdings.assignAll(
            (data['holdings'] as List<dynamic>).map((e) => MfHolding.fromJson(e as Map<String, dynamic>)).toList(),
          );
        }
        if (data['activeSips'] != null) {
          activeSips.assignAll(
            (data['activeSips'] as List<dynamic>).map((e) => MfActiveSip.fromJson(e as Map<String, dynamic>)).toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchPortfolio error: $e');
    } finally {
      isPortfolioLoading.value = false;
    }
  }

  void onCategorySelected(String cat) {
    selectedCategory.value = cat;
    fetchSchemes(category: cat, page: 1, isRefresh: true);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      fetchSchemes(search: query, page: 1, isRefresh: true);
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    _debounceTimer?.cancel();
    fetchSchemes(search: '', page: 1, isRefresh: true);
  }

  void onFilterChipSelected(String chip) {
    selectedFilterChip.value = chip;
    if (chip == 'All') {
      fetchSchemes(search: '', page: 1, isRefresh: true);
    } else if (chip == 'High Return') {
      selectedSort.value = '3Y Returns';
      fetchSchemes(page: 1, isRefresh: true);
    } else {
      fetchSchemes(search: chip, page: 1, isRefresh: true);
    }
  }



  // ── Reset Test Account (Sandbox Helper) ──
  Future<void> resetTestAccount() async {
    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/test/reset');
      if (res.statusCode == 200) {
        hasUcc.value = false;
        userUcc.value = null;
        portfolioSummary.value = null;
        holdings.clear();
        activeSips.clear();
        Get.snackbar(
          'Sandbox Reset',
          'Test UCC and portfolio reset. Ready for fresh test run.',
          backgroundColor: const Color(0xFF00D09C),
          colorText: Colors.black,
        );
      }
    } catch (e) {
      debugPrint('[MutualFundsController] resetTestAccount error: $e');
    }
  }
}
