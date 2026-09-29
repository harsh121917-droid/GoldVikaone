import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../views/mf_ucc_onboarding_view.dart';
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

  // ── Search History & Dedicated Search State ──
  final RxList<String> searchHistory = <String>[].obs;
  final RxList<MfSchemeModel> searchResults = <MfSchemeModel>[].obs;
  final RxBool isSearchLoading = false.obs;

  // ── All Mutual Funds View & Advanced Filters State ──
  final RxString allMfSort = 'Popularity'.obs;
  final RxSet<String> allMfCategories = <String>{}.obs;
  final RxSet<String> allMfSubCategories = <String>{}.obs;
  final RxSet<String> allMfRisks = <String>{}.obs;
  final RxSet<int> allMfRatings = <int>{}.obs;

  final RxList<MfSchemeModel> allSchemes = <MfSchemeModel>[].obs;
  final RxBool isAllSchemesLoading = false.obs;
  final RxBool isAllSchemesLoadingMore = false.obs;
  final RxInt allSchemesPage = 1.obs;
  final RxInt allSchemesTotalPages = 1.obs;
  final RxInt allSchemesTotalCount = 0.obs;
  final RxBool allSchemesHasMore = true.obs;
  final RxString allMfReturnPeriod = '3Y'.obs;

  // ── Dedicated Popular Funds State ──
  final RxList<MfSchemeModel> popularSchemesList = <MfSchemeModel>[].obs;
  final RxBool isPopularLoading = false.obs;

  final RxList<MfSchemeModel> schemes = <MfSchemeModel>[].obs;
  final RxList<String> watchlistSchemeCodes = <String>['1001', '1003', '1004'].obs;
  final RxList<MfSchemeModel> recentlyViewed = <MfSchemeModel>[].obs;

  final Rx<MfPortfolioSummary?> portfolioSummary = Rx<MfPortfolioSummary?>(null);
  final RxList<MfHolding> holdings = <MfHolding>[].obs;
  final RxList<MfActiveSip> activeSips = <MfActiveSip>[].obs;
  final Rx<MfUccModel?> userUcc = Rx<MfUccModel?>(null);
  final RxBool hasUcc = false.obs;
  final RxMap<String, dynamic> uccPrefill = <String, dynamic>{}.obs;

  // ── Onboarding & SIP Readiness (Step 1: UCC, Step 2: Mandate) ──
  final RxInt onboardingStep = 1.obs; // 1: Needs UCC, 2: Needs Mandate, 3: SIP Ready
  final RxMap<String, dynamic> onboardingData = <String, dynamic>{}.obs;
  final RxBool isOnboardingLoading = false.obs;

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
    fetchOnboardingStatus();
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

  // ── Fetch Onboarding & SIP Readiness Status (Step 1: UCC, Step 2: Mandate) ──
  Future<void> fetchOnboardingStatus() async {
    isOnboardingLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/onboarding-status');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final d = res.data['data'] as Map<String, dynamic>? ?? {};
        onboardingData.assignAll(d);
        onboardingStep.value = (d['step'] as num?)?.toInt() ?? 1;
        hasUcc.value = d['hasUcc'] == true;
        if (d['clientCode'] != null && userUcc.value == null) {
          userUcc.value = MfUccModel(
            clientCode: d['clientCode'].toString(),
            pan: d['pan']?.toString() ?? '',
            nseStatus: d['uccStatus']?.toString() ?? 'ACTIVE',
            accountNo: d['accountNo']?.toString() ?? '',
            ifsc: d['ifsc']?.toString() ?? '',
            bankName: d['bankName']?.toString() ?? '',
          );
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchOnboardingStatus error: $e');
    } finally {
      isOnboardingLoading.value = false;
    }
  }

  // ── Initiate Bank AutoPay (eNACH Mandate) Setup ──
  Future<void> initiateMandateSetup(BuildContext context) async {
    try {
      final dio = ApiClient.instance;
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF00D09C))),
        barrierDismissible: false,
      );

      final res = await dio.post('/mutual-funds/mandates/setup', data: {'amount': 50000});
      Get.back(); // close progress dialog

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>? ?? {};
        final authUrl = data['authUrl']?.toString() ?? '';
        final mandateId = data['mandateId']?.toString() ?? '';
        final bank = data['bankName']?.toString() ?? 'Registered Bank';

        showMandateAuthBottomSheet(context, authUrl: authUrl, mandateId: mandateId, bankName: bank);
      } else {
        Get.snackbar(
          'Setup Issue',
          res.data['message'] ?? 'Could not initiate bank mandate with exchange',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // close progress dialog if open
      Get.snackbar('Error', 'Failed to connect to exchange: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // ── Show Mandate Authorization Bottom Sheet ──
  void showMandateAuthBottomSheet(BuildContext context, {required String authUrl, required String mandateId, required String bankName}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF131722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF222938))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09C).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_outlined, color: Color(0xFF00D09C), size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NSE eNACH AutoPay Mandate',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'One-time authorization for automated monthly SIPs',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2234),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF222F48)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Linked Bank', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text(bankName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Auto-Debit Limit', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text('₹50,000 / month', style: TextStyle(color: Color(0xFF00D09C), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Authentication Mode', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text('Net Banking / Debit Card', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (authUrl.isNotEmpty) {
                    try {
                      final uri = Uri.parse(authUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
                      debugPrint('Error launching url: $e');
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.black),
                label: const Text('Authorize with Bank OTP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () async {
                  Get.back();
                  // Verify mandate status
                  try {
                    final dio = ApiClient.instance;
                    final vRes = await dio.post('/mutual-funds/mandates/$mandateId/verify');
                    if (vRes.statusCode == 200 && vRes.data['success'] == true) {
                      await fetchOnboardingStatus();
                      Get.snackbar(
                        'AutoPay Ready',
                        'Bank mandate authorized successfully. You can now start monthly SIPs.',
                        backgroundColor: const Color(0xFF00D09C),
                        colorText: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  } catch (_) {}
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E3E5C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('I Have Completed Authorization', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Show Mandate Required Alert Dialog ──
  void showMandateRequiredDialog(BuildContext context, {VoidCallback? onSwitchToLumpSum}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF131722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF222938))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF00D09C).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_outlined, color: Color(0xFF00D09C), size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bank AutoPay (e-Mandate) Required',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'To register an automated monthly SIP on NSE MFSS, your bank account must have an active eNACH Mandate. You can authorize AutoPay now, or invest via One-Time Lump Sum instantly.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  initiateMandateSetup(context);
                },
                icon: const Icon(Icons.lock_outline_rounded, size: 18, color: Colors.black),
                label: const Text('Authorize AutoPay (1 Min)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            if (onSwitchToLumpSum != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                    onSwitchToLumpSum();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00D09C)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Invest Lump Sum (UPI Instant)', style: TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
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
  // ── Instant PAN Verification (Groww Flow) ──
  Future<Map<String, dynamic>?> verifyPan(String pan) async {
    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/pan/verify', data: {
        'pan': pan.trim().toUpperCase(),
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        return res.data['data'] as Map<String, dynamic>? ?? res.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        return e.response!.data as Map<String, dynamic>;
      }
      return null;
    }
  }

  // ── Register User UCC (Groww-Style Modern Paperless Flow via NSE MFSS) ──
  Future<Map<String, dynamic>?> registerUcc({
    required String pan,
    String? fullName,
    String? accountNo,
    String? ifsc,
    String? bankName,
    String? nomineeName,
    String? nomineeRelation,
    String? dob,
    String? gender,
    String? occupationCode,
  }) async {
    isUccLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final payload = <String, dynamic>{
        'pan': pan.trim().toUpperCase(),
        'dob': dob ?? '01/01/1990',
        'gender': gender ?? 'M',
        'occupationCode': occupationCode ?? '01',
      };
      if (fullName != null && fullName.isNotEmpty) payload['fullName'] = fullName;
      if (accountNo != null && accountNo.isNotEmpty) payload['accountNo'] = accountNo;
      if (ifsc != null && ifsc.isNotEmpty) payload['ifsc'] = ifsc.trim().toUpperCase();
      if (bankName != null && bankName.isNotEmpty) payload['bankName'] = bankName;
      if (nomineeName != null && nomineeName.isNotEmpty) {
        payload['nomineeName'] = nomineeName;
        payload['nomineeRelation'] = nomineeRelation ?? '01';
      }

      final res = await dio.post('/mutual-funds/ucc/register', data: payload);

      if (res.statusCode == 200 && res.data['success'] == true) {
        hasUcc.value = true;
        if (res.data['data'] != null) {
          userUcc.value = MfUccModel.fromJson(Map<String, dynamic>.from(res.data['data']));
        }
        await fetchOnboardingStatus();
        return {
          'success': true,
          'clientCode': userUcc.value?.clientCode ?? '',
          'authUrl': res.data['authUrl']?.toString(),
          'message': res.data['message']?.toString() ?? 'UCC registered with NSE MFSS',
        };
      } else {
        Get.snackbar(
          'Registration Failed',
          res.data['message']?.toString() ?? 'Could not register UCC with NSE',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }
    } catch (e) {
      String errMsg = 'Failed to connect to NSE gateway: $e';
      if (e is DioException) {
        final serverMsg = e.response?.data?['message'];
        if (serverMsg != null) {
          errMsg = serverMsg.toString();
        }
      }
      Get.snackbar(
        'Registration Failed',
        errMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
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



  // ── Place Redemption Order (Sell Units Back to AMC) ──
  Future<Map<String, dynamic>> redeemUnits({
    required String schemeCode,
    required double units,
    bool allUnits = false,
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.post(
        '/mutual-funds/orders/redeem',
        data: {
          'schemeCode': schemeCode,
          'units': units,
          'allUnits': allUnits,
        },
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        await fetchPortfolio();
        return {
          'success': true,
          'message': res.data['message'] ?? 'Redemption request placed successfully. Payout will be credited to your bank account.',
          'data': res.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? 'Redemption failed. Please try again.',
        };
      }
    } catch (e) {
      debugPrint('[MutualFundsController] redeemUnits error: ' + e.toString());
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      isSubmittingOrder.value = false;
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

  String extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final resData = e.response?.data;
      if (resData is Map && resData['message'] != null) {
        return resData['message'].toString();
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please check your internet connection.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Network connection error. Please check your internet connection.';
      }
    }
    final raw = e.toString();
    return raw.replaceAll(RegExp(r'DioException.*?:s*'), '').replaceAll(RegExp(r'Exception:s*'), '');
  }

  void showUccRequiredDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF131722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF222938))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF00D09C).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xFF00D09C), size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'One-Time Investor Onboarding',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'As per SEBI regulations, a one-time profile registration (PAN, Bank details & Nominee) is required before investing in Mutual Funds on NSE MFSS.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Get.back();
                  Get.to(() => const MfUccOnboardingView());
                },
                child: const Text('Complete Onboarding (2 Mins)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Maybe Later', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showErrorPopup({required String title, required String message}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF131722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF222938))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2538),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => Get.back(),
                child: const Text('Dismiss', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }


  // ═══════════════════════════════════════════════════════════════════════════
  // ── Search History & Dedicated Search ──
  // ═══════════════════════════════════════════════════════════════════════════
  void loadSearchHistory() {
    try {
      final box = GetStorage();
      final List<dynamic>? list = box.read<List<dynamic>>('mf_search_history');
      if (list != null) {
        searchHistory.assignAll(list.map((e) => e.toString()).toList());
      }
    } catch (e) {
      debugPrint('[MutualFundsController] loadSearchHistory error: $e');
    }
  }

  void addSearchHistory(String term) {
    final clean = term.trim();
    if (clean.isEmpty) return;
    searchHistory.remove(clean);
    searchHistory.insert(0, clean);
    if (searchHistory.length > 15) searchHistory.removeLast();
    try {
      final box = GetStorage();
      box.write('mf_search_history', searchHistory.toList());
    } catch (e) {
      debugPrint('[MutualFundsController] saveSearchHistory error: $e');
    }
  }

  void removeSearchHistory(String term) {
    searchHistory.remove(term);
    try {
      final box = GetStorage();
      box.write('mf_search_history', searchHistory.toList());
    } catch (e) {}
  }

  void clearSearchHistory() {
    searchHistory.clear();
    try {
      final box = GetStorage();
      box.remove('mf_search_history');
    } catch (e) {}
  }

  Future<void> executeLiveSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchResults.clear();
      isSearchLoading.value = false;
      return;
    }

    isSearchLoading.value = true;
    // Clean tokens for fuzzy multi-word matching (e.g. "UTI health" matches "UTI - Healthcare Fund")
    final cleanTokens = q
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      final dio = ApiClient.instance;
      List<MfSchemeModel> list = [];

      // 1. Direct query with user's search string
      try {
        final res = await dio.get('/mutual-funds/schemes', queryParameters: {
          'search': q,
          'limit': 50,
        });

        if (res.statusCode == 200 && res.data['success'] == true) {
          list = (res.data['data'] as List<dynamic>?)
                  ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
        }
      } catch (e) {
        debugPrint('[MutualFundsController] direct search API error: $e');
      }

      // 2. Multi-word smart fallback: if direct query returns 0 items and there are multiple tokens,
      // query the server using each token (e.g. "UTI" or "health") and filter candidates so all tokens match
      if (list.isEmpty && cleanTokens.length > 1) {
        for (final token in cleanTokens) {
          if (token.length < 2) continue;
          try {
            final fallbackRes = await dio.get('/mutual-funds/schemes', queryParameters: {
              'search': token,
              'limit': 100,
            });
            if (fallbackRes.statusCode == 200 && fallbackRes.data['success'] == true) {
              final candidates = (fallbackRes.data['data'] as List<dynamic>?)
                      ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              final matched = candidates.where((s) {
                final text = '${s.schemeName} ${s.amcName} ${s.subCategory} ${s.category} ${s.schemeCode}'
                    .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
                    .toLowerCase();
                return cleanTokens.every((t) => text.contains(t));
              }).toList();

              if (matched.isNotEmpty) {
                list = matched;
                break;
              }
            }
          } catch (e) {
            debugPrint('[MutualFundsController] token search fallback error: $e');
          }
        }
      }

      // 3. Supplement with local pool of schemes (all cached schemes in controller)
      final allPool = <MfSchemeModel>[...schemes, ...allSchemes, ...popularSchemesList, ...recentlyViewed];
      final seenCodes = list.map((s) => s.schemeCode).toSet();
      for (final s in allPool) {
        if (seenCodes.contains(s.schemeCode)) continue;
        final text = '${s.schemeName} ${s.amcName} ${s.subCategory} ${s.category} ${s.schemeCode}'
            .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
            .toLowerCase();
        if (cleanTokens.every((t) => text.contains(t))) {
          list.add(s);
          seenCodes.add(s.schemeCode);
        }
      }

      searchResults.assignAll(list);
    } catch (e) {
      debugPrint('[MutualFundsController] executeLiveSearch error: $e');
      final allPool = <MfSchemeModel>[...schemes, ...allSchemes, ...popularSchemesList, ...recentlyViewed];
      final localMatches = allPool.where((s) {
        final text = '${s.schemeName} ${s.amcName} ${s.subCategory} ${s.category} ${s.schemeCode}'
            .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
            .toLowerCase();
        return cleanTokens.every((t) => text.contains(t));
      }).toSet().toList();
      searchResults.assignAll(localMatches);
    } finally {
      isSearchLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── All Mutual Funds Screen: Advanced Groww-Style Filtering & Sorting ──
  // ═══════════════════════════════════════════════════════════════════════════
  int get activeFiltersCount {
    int count = 0;
    if (allMfSort.value != 'Popularity') count++;
    count += allMfCategories.length;
    count += allMfSubCategories.length;
    count += allMfRisks.length;
    count += allMfRatings.length;
    return count;
  }

  void resetAllFilters() {
    allMfSort.value = 'Popularity';
    allMfCategories.clear();
    allMfSubCategories.clear();
    allMfRisks.clear();
    allMfRatings.clear();
  }

  Future<void> fetchAllSchemes({bool isRefresh = false, int page = 1}) async {
    if (isRefresh || page == 1) {
      isAllSchemesLoading.value = true;
      allSchemesPage.value = 1;
      allSchemesHasMore.value = true;
    } else {
      if (isAllSchemesLoadingMore.value || !allSchemesHasMore.value) return;
      isAllSchemesLoadingMore.value = true;
    }

    try {
      final dio = ApiClient.instance;
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': 20,
      };

      // Map sort
      if (allMfSort.value == 'Popularity') {
        queryParams['sort'] = 'popularity';
      } else if (allMfSort.value == '1Y Returns') {
        queryParams['sort'] = 'returns1y';
      } else if (allMfSort.value == '3Y Returns' || allMfSort.value == '3Y Re') {
        queryParams['sort'] = 'returns3y';
      } else if (allMfSort.value == '5Y Returns' || allMfSort.value == '5Y') {
        queryParams['sort'] = 'returns5y';
      } else if (allMfSort.value == 'Rating') {
        queryParams['sort'] = 'rating';
      }

      if (allMfCategories.isNotEmpty) {
        queryParams['categories'] = allMfCategories.join(',');
      }
      if (allMfSubCategories.isNotEmpty) {
        queryParams['subCategories'] = allMfSubCategories.join(',');
      }
      if (allMfRisks.isNotEmpty) {
        queryParams['risks'] = allMfRisks.join(',');
      }
      if (allMfRatings.isNotEmpty) {
        queryParams['ratings'] = allMfRatings.join(',');
      }

      final res = await dio.get('/mutual-funds/schemes', queryParameters: queryParams);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>?)
                ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        allSchemesTotalCount.value = res.data['total'] ?? list.length;
        allSchemesTotalPages.value = res.data['pages'] ?? 1;
        allSchemesPage.value = res.data['page'] ?? page;
        allSchemesHasMore.value = allSchemesPage.value < allSchemesTotalPages.value;

        if (page == 1) {
          allSchemes.assignAll(list);
        } else {
          final existingCodes = allSchemes.map((s) => s.schemeCode).toSet();
          for (final item in list) {
            if (!existingCodes.contains(item.schemeCode)) {
              allSchemes.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchAllSchemes error: $e');
    } finally {
      isAllSchemesLoading.value = false;
      isAllSchemesLoadingMore.value = false;
    }
  }

  Future<void> loadMoreAllSchemes() async {
    if (isAllSchemesLoading.value || isAllSchemesLoadingMore.value || !allSchemesHasMore.value) return;
    await fetchAllSchemes(page: allSchemesPage.value + 1);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ── Dedicated Popular Funds Fetcher ──
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> fetchPopularSchemes() async {
    isPopularLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/schemes', queryParameters: {
        'sort': 'popularity',
        'limit': 50,
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>?)
                ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        popularSchemesList.assignAll(list);
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchPopularSchemes error: $e');
    } finally {
      isPopularLoading.value = false;
    }
  }

}
