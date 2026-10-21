import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../views/mf_ucc_onboarding_view.dart';
import '../views/mf_cart_view.dart';
import '../views/mf_ucc_auth_webview.dart';
import '../views/mf_payment_webview.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
// Dedicated NSE MF II Gateway - Zero 3rd-party PG
// AuthService not needed without Razorpay prefill
import '../../../core/network/api_client.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../../../data/models/mf_portfolio_model.dart';
import '../../../data/models/mf_cart_model.dart';
import '../../../data/models/mf_profile_model.dart';

class MutualFundsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPortfolioLoading = false.obs;
  final RxBool isSubmittingOrder = false.obs;
  final RxBool isUccLoading = false.obs;

  // Dedicated NSE MF II Gateway (Zero 3rd-party PG)

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
  final RxList<String> watchlistSchemeCodes = <String>[].obs;
  final RxList<MfSchemeModel> recentlyViewed = <MfSchemeModel>[].obs;

  final Rx<MfPortfolioSummary?> portfolioSummary = Rx<MfPortfolioSummary?>(null);
  final RxList<MfHolding> holdings = <MfHolding>[].obs;
  final RxList<MfActiveSip> activeSips = <MfActiveSip>[].obs;
  final RxList<MfOrderModel> inProgressOrders = <MfOrderModel>[].obs;
  final RxList<MfOrderModel> myOrders = <MfOrderModel>[].obs;
  final RxBool isOrdersLoading = false.obs;
  final Rx<MfUccModel?> userUcc = Rx<MfUccModel?>(null);
  final RxBool hasUcc = false.obs;
  final RxMap<String, dynamic> uccPrefill = <String, dynamic>{}.obs;
  final RxString selectedDob = ''.obs;
  final RxString selectedGender = 'M'.obs;
  final RxString selectedOccupation = '01'.obs;

  // ── Onboarding & SIP Readiness (Step 1: UCC, Step 2: Mandate) ──
  final RxInt onboardingStep = 1.obs; // 1: Needs UCC, 2: Needs Mandate, 3: SIP Ready
  final RxMap<String, dynamic> onboardingData = <String, dynamic>{}.obs;
  final RxBool isOnboardingLoading = false.obs;

  // ── Mutual Funds Cart State ──
  final Rx<MfCartData> cartData = MfCartData.empty().obs;
  final RxBool isCartLoading = false.obs;
  int get cartCount => cartData.value.count;
  double get cartTotal => cartData.value.totalAmount;

  // ── Mutual Funds NFO State ──
  final RxList<Map<String, dynamic>> openNfos = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingNfos = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> closedNfos = <Map<String, dynamic>>[].obs;
  final RxBool isNfoLoading = false.obs;

  // ── Mutual Funds Profile & Account State ──
  final Rx<MfProfileData?> mfProfile = Rx<MfProfileData?>(null);
  final RxBool isProfileLoading = false.obs;

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
    // Razorpay initialization removed for MF
    fetchSchemes();
    checkUserUcc();
    fetchOnboardingStatus();
    fetchPortfolio();
    fetchRecentlyViewed();
    fetchCart();
    fetchMfProfile();
    fetchNfos();
  }

  // _initRazorpay removed

  @override
  void onClose() {
    // _razorpay.clear removed
    _debounceTimer?.cancel();
    super.onClose();
  }

  List<MfSchemeModel> get popularFunds {
    if (schemes.isEmpty) return [];
    final list = List<MfSchemeModel>.from(schemes);
    list.sort((a, b) => (b.cagr3Y ?? 0.0).compareTo(a.cagr3Y ?? 0.0));
    return list.take(6).toList();
  }

  List<MfSchemeModel> get watchlistSchemes {
    return schemes.where((s) => watchlistSchemeCodes.contains(s.schemeCode)).toList();
  }

  List<MfSchemeModel> get filteredSchemes {
    var list = List<MfSchemeModel>.from(schemes);
    final period = selectedReturnPeriod.value;
    if (period == '1Y') {
      list.sort((a, b) => (b.cagr1Y ?? -9999.0).compareTo(a.cagr1Y ?? -9999.0));
    } else if (period == '5Y') {
      list.sort((a, b) => (b.cagr5Y ?? -9999.0).compareTo(a.cagr5Y ?? -9999.0));
    } else {
      list.sort((a, b) => (b.cagr3Y ?? -9999.0).compareTo(a.cagr3Y ?? -9999.0));
    }
    return list;
  }

  void toggleWatchlist(String schemeCode) {
    if (watchlistSchemeCodes.contains(schemeCode)) {
      watchlistSchemeCodes.remove(schemeCode);
    } else {
      watchlistSchemeCodes.add(schemeCode);
    }
  }

  // ── Recently Viewed Schemes (API synced & persistent) ──
  void recordRecentlyViewed(MfSchemeModel scheme) {
    recentlyViewed.removeWhere((s) => s.schemeCode == scheme.schemeCode);
    recentlyViewed.insert(0, scheme);
    if (recentlyViewed.length > 10) recentlyViewed.removeLast();

    // Async record to backend
    unawaited(() async {
      try {
        await ApiClient.instance.post('/mutual-funds/recently-viewed', data: {
          'schemeCode': scheme.schemeCode,
        });
      } catch (e) {
        debugPrint('[recordRecentlyViewed API error]: $e');
      }
    }());
  }

  Future<void> fetchRecentlyViewed() async {
    try {
      final res = await ApiClient.instance.get('/mutual-funds/recently-viewed');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = res.data['data'] as List<dynamic>? ?? [];
        final parsed = list.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>)).toList();
        if (parsed.isNotEmpty) {
          recentlyViewed.assignAll(parsed);
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchRecentlyViewed error: $e');
    }
  }

  // ── Mutual Funds Cart Operations ──
  Future<void> fetchCart() async {
    try {
      isCartLoading.value = true;
      final res = await ApiClient.instance.get('/mutual-funds/cart');
      if (res.statusCode == 200 && res.data['success'] == true) {
        cartData.value = MfCartData.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchCart error: $e');
    } finally {
      isCartLoading.value = false;
    }
  }

  Future<bool> addToCart({
    required MfSchemeModel scheme,
    required double amount,
    String investmentType = 'SIP',
    String frequency = 'MONTHLY',
    int sipDay = 5,
    String folioNo = '',
  }) async {
    try {
      final res = await ApiClient.instance.post('/mutual-funds/cart/add', data: {
        'schemeCode': scheme.schemeCode,
        'schemeName': scheme.schemeName,
        'amcName': scheme.amcName,
        'category': scheme.category,
        'investmentType': investmentType,
        'amount': amount,
        'frequency': frequency,
        'sipDay': sipDay,
        'folioNo': folioNo,
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        await fetchCart();
        Get.snackbar(
          'Added to Cart',
          '${scheme.schemeName} added to your Mutual Funds cart.',
          backgroundColor: const Color(0xFF1E2535),
          colorText: const Color(0xFF00D09C),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () => Get.to(() => const MfCartView()),
            child: const Text('View Cart', style: TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold)),
          ),
        );
        return true;
      }
    } catch (e) {
      Get.snackbar(
        'Cart Error',
        ApiClient.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return false;
  }

  Future<void> removeFromCart(String itemId) async {
    try {
      final res = await ApiClient.instance.delete('/mutual-funds/cart/$itemId');
      if (res.statusCode == 200 && res.data['success'] == true) {
        await fetchCart();
      }
    } catch (e) {
      debugPrint('[removeFromCart error]: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final res = await ApiClient.instance.delete('/mutual-funds/cart');
      if (res.statusCode == 200 && res.data['success'] == true) {
        cartData.value = MfCartData.empty();
      }
    } catch (e) {
      debugPrint('[clearCart error]: $e');
    }
  }

  // ── Mutual Funds NFO Operations ──
  Future<void> fetchNfos() async {
    try {
      isNfoLoading.value = true;
      final res = await ApiClient.instance.get('/mutual-funds/nfos');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>;
        final rawOpen = data['open'] as List<dynamic>? ?? [];
        final rawUpcoming = data['upcoming'] as List<dynamic>? ?? [];
        final rawClosed = data['closed'] as List<dynamic>? ?? [];

        openNfos.assignAll(rawOpen.map((e) => Map<String, dynamic>.from(e as Map)).toList());
        upcomingNfos.assignAll(rawUpcoming.map((e) => Map<String, dynamic>.from(e as Map)).toList());
        closedNfos.assignAll(rawClosed.map((e) => Map<String, dynamic>.from(e as Map)).toList());
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchNfos error: $e');
    } finally {
      isNfoLoading.value = false;
    }
  }

  // ── Mutual Funds Profile, Bank & Orders ──
  Future<void> fetchMfProfile() async {
    try {
      isProfileLoading.value = true;
      final res = await ApiClient.instance.get('/mutual-funds/profile');
      if (res.statusCode == 200 && res.data['success'] == true) {
        mfProfile.value = MfProfileData.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchMfProfile error: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<bool> addBank({
    required String accountNumber,
    required String ifsc,
    String bankName = 'Bank Account',
    String accountType = 'savings',
    String accountHolder = '',
  }) async {
    try {
      final res = await ApiClient.instance.post('/mutual-funds/profile/bank', data: {
        'accountNumber': accountNumber.trim(),
        'ifsc': ifsc.trim().toUpperCase(),
        'bankName': bankName.trim(),
        'accountType': accountType,
        'accountHolder': accountHolder.trim(),
      });
      if (res.statusCode == 200 && res.data['success'] == true) {
        Get.snackbar(
          'Bank Added',
          'Bank account added successfully.',
          backgroundColor: const Color(0xFF1E2535),
          colorText: const Color(0xFF00D09C),
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchMfProfile();
        return true;
      }
    } catch (e) {
      Get.snackbar(
        'Bank Linking Failed',
        ApiClient.formatError(e),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    return false;
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

      final effectiveSort = selectedSort.value.isNotEmpty
          ? selectedSort.value
          : '${selectedReturnPeriod.value} Returns';

      if (effectiveSort == '3Y Returns' || effectiveSort == '3Y' || effectiveSort == '3Y Re') {
        queryParams['sort'] = 'returns3y';
      } else if (effectiveSort == '1Y Returns' || effectiveSort == '1Y') {
        queryParams['sort'] = 'returns1y';
      } else if (effectiveSort == '5Y Returns' || effectiveSort == '5Y') {
        queryParams['sort'] = 'returns5y';
      } else if (effectiveSort == 'Rating') {
        queryParams['sort'] = 'rating';
      } else if (effectiveSort == 'NAV') {
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
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreSchemes() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    await fetchSchemes(page: currentPage.value + 1);
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

      final res = await dio.post('/mutual-funds/mandates/setup', data: {'amount': 50000, 'forceNew': true});
      Get.back(); // close progress dialog

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>? ?? {};
        final authUrl = data['authUrl']?.toString() ?? '';
        final mandateId = data['mandateId']?.toString() ?? '';
        final bank = data['bankName']?.toString() ?? 'Registered Bank';

        showMandateAuthBottomSheet(context, authUrl: authUrl, mandateId: mandateId, bankName: bank);
      } else {
        final errMsg = extractErrorMessage(res.data, fallback: 'Could not initiate bank mandate with exchange.');
        Get.snackbar(
          'Mandate Setup Issue',
          errMsg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.back(); // close progress dialog if open

      dynamic resData;
      if (e is DioException) {
        resData = e.response?.data;
      }
      final code = (resData is Map) ? resData['code']?.toString() : null;
      final d = (resData is Map && resData['data'] is Map) ? resData['data'] as Map : null;
      final clActLink = d?['clActLink']?.toString();
      final clientCode = d?['clientCode']?.toString();

      if (code == 'NSE_CLIENT_ACTIVATION_PENDING') {
        showClientActivationBottomSheet(context, clActLink: clActLink, clientCode: clientCode);
        return;
      }

      final errMsg = extractErrorMessage(e, fallback: 'Failed to connect to exchange for mandate setup. Please try again.');
      Get.snackbar(
        'Mandate Setup Issue',
        errMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // ── Show Client Activation Bottom Sheet (When UCC is Pending NSE OTP) ──
  void showClientActivationBottomSheet(BuildContext context, {String? clActLink, String? clientCode}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: const BoxDecoration(
          color: Color(0xFF131722),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFFEAB308), width: 1.5)),
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
                    color: const Color(0xFFEAB308).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_outlined, color: Color(0xFFEAB308), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NSE Account Activation Required',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Client Code: ${clientCode ?? ''} • 1-Time Verification',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2234),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF222F48)),
              ),
              child: const Text(
                'NSE MFSS has dispatched an official one-time activation OTP to your registered mobile and email. Please verify this OTP to activate your investor account on the exchange before setting up Bank AutoPay.',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.45),
              ),
            ),
            const SizedBox(height: 20),
            if (clActLink != null && clActLink.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final uri = Uri.parse(clActLink);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } catch (e) {
                      debugPrint('Error launching url: $e');
                    }
                  },
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18, color: Colors.black),
                  label: const Text('Verify OTP on NSE Official Portal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  initiateMandateSetup(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('I Have Verified OTP → Continue AutoPay Setup', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () async {
                  try {
                    final dio = ApiClient.instance;
                    final rRes = await dio.post('/mutual-funds/ucc/resend-act');
                    if (rRes.statusCode == 200 && rRes.data['success'] == true) {
                      Get.snackbar(
                        'OTP Re-sent',
                        'NSE has re-dispatched the activation SMS/Email OTP to your phone.',
                        backgroundColor: const Color(0xFF00D09C),
                        colorText: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  } catch (_) {}
                },
                child: const Text('Resend OTP SMS to Mobile', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Open In-App NSE UCC 2FA Client Authorization WebView ──
  Future<dynamic> openUccAuthWebView(BuildContext context, {String? authUrl, String? clientCode}) async {
    final code = clientCode ?? userUcc.value?.clientCode ?? onboardingData['clientCode']?.toString();
    var url = authUrl ?? onboardingData['authUrl']?.toString();
    if (url == null || url.trim().isEmpty || url.contains('nsenmf.com')) {
      url = 'https://www.nseinvest.com/mf/';
    }
    return await Get.to(() => MfUccAuthWebView(initialUrl: url, clientCode: code));
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
                        duration: const Duration(seconds: 4),
                      );
                    } else {
                      final msg = extractErrorMessage(vRes.data, fallback: 'Mandate authorization is still pending with your bank.');
                      Get.snackbar(
                        'Mandate Status',
                        msg,
                        backgroundColor: Colors.amber.shade800,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 4),
                      );
                    }
                  } catch (e) {
                    final msg = extractErrorMessage(e, fallback: 'Mandate authorization is being processed by your bank. Please check back shortly.');
                    Get.snackbar(
                      'Mandate Status',
                      msg,
                      backgroundColor: Colors.amber.shade800,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 4),
                    );
                  }
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
      return {
        'success': false,
        'message': extractErrorMessage(res.data, fallback: 'PAN verification failed. Please enter a valid registered PAN.'),
      };
    } catch (e) {
      if (e is DioException) {
        dynamic data = e.response?.data;
        if (data is String) {
          try {
            data = jsonDecode(data);
          } catch (_) {}
        }
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      return {
        'success': false,
        'message': extractErrorMessage(e, fallback: 'Unable to verify PAN with exchange. Please try again.'),
      };
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
        final errMsg = extractErrorMessage(res.data, fallback: 'Could not register UCC with NSE.');
        Get.snackbar(
          'Registration Failed',
          errMsg,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        return null;
      }
    } catch (e) {
      final errMsg = extractErrorMessage(e, fallback: 'Failed to complete registration with NSE gateway. Please verify your details.');
      Get.snackbar(
        'Registration Failed',
        errMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return null;
    } finally {
      isUccLoading.value = false;
    }
  }

  Future<void> openNsePaymentGateway(String paymentUrl, {required String title, required String message}) async {
    final cleanUrl = paymentUrl.trim();
    if (cleanUrl.isEmpty) return;

    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF00D09C),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );

    // Open dedicated In-App NSE Payment WebView directly
    try {
      await Get.to(() => MfPaymentWebView(
        paymentUrl: cleanUrl,
        title: title,
      ));
    } catch (_) {
      final uri = Uri.parse(cleanUrl);
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  // ── Groww-Style In-App UPI Collect Modal with Live Exchange Status Polling ──
  Future<bool> showUpiApprovalModal({
    required String orderId,
    required double orderAmount,
    required String vpa,
    required String schemeName,
    String? paymentLink,
    String? nseTrxnOrderId,
  }) async {
    final context = Get.context;
    if (context == null) return false;

    Timer? pollTimer;
    Timer? countdownTimer;
    int secondsLeft = 300; // 5 minute countdown
    String status = 'PENDING'; // PENDING, SUCCESS, FAILED
    String statusMessage = 'Collect request sent by NSE Clearing Limited';

    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsLeft > 0 && status == 'PENDING') {
                setState(() => secondsLeft--);
              } else if (secondsLeft <= 0 && status == 'PENDING') {
                t.cancel();
                pollTimer?.cancel();
                setState(() {
                  status = 'FAILED';
                  statusMessage = 'Payment request timed out. Please try again.';
                });
              }
            });

            pollTimer ??= Timer.periodic(const Duration(seconds: 3), (t) async {
              if (status != 'PENDING') {
                t.cancel();
                return;
              }
              final orderData = await syncOrderStatus(orderId);
              final pStatus = orderData?['paymentStatus']?.toString().toUpperCase();
              final oStatus = orderData?['orderStatus']?.toString().toUpperCase();

              if (pStatus == 'SUCCESS' || oStatus == 'PAYMENT_SUCCESS') {
                t.cancel();
                countdownTimer?.cancel();
                if (ctx.mounted) {
                  setState(() {
                    status = 'SUCCESS';
                    statusMessage = 'Payment confirmed by NSE Clearing Limited! 🎉';
                  });
                }
                fetchPortfolio();
                await Future.delayed(const Duration(milliseconds: 1800));
                if (Navigator.canPop(sheetContext)) {
                  Navigator.pop(sheetContext, true);
                }
              } else if (pStatus == 'FAILED' || oStatus == 'REJECTED' || oStatus == 'FAILED') {
                t.cancel();
                countdownTimer?.cancel();
                if (ctx.mounted) {
                  setState(() {
                    status = 'FAILED';
                    statusMessage = orderData?['remarks']?.toString() ?? 'Payment was declined or failed.';
                  });
                }
              }
            });

            final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
            final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

            const bg = Color(0xFF10141E);
            const cardBg = Color(0xFF181F2E);
            const mintGreen = Color(0xFF00D09C);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (status == 'SUCCESS') ...[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: mintGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: mintGreen, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Confirmed! 🎉',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${orderAmount.toInt()} received by NSE Clearing Limited.',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Units will be allotted as per official exchange NAV cutoff.',
                      style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                  ] else if (status == 'FAILED') ...[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 48),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Not Completed',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E2638),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: mintGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_rounded, color: mintGreen, size: 14),
                              SizedBox(width: 4),
                              Text('NSE CLEARING LIMITED', style: TextStyle(color: mintGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Approve Payment in UPI App',
                      style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${orderAmount.toInt()}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF222B3D)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Collect sent to', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              Text(vpa, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(color: Color(0xFF222B3D), height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Time remaining', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 14),
                                  const SizedBox(width: 4),
                                  Text('$minutes:$seconds', style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap "Pay via UPI App" to open Google Pay/PhonePe, or approve the notification in your UPI app. If no request appears, tap "Pay via NSE Gateway" to complete payment.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                countdownTimer?.cancel();
                                pollTimer?.cancel();
                                Navigator.pop(sheetContext, false);
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF222B3D)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final cleanAmount = orderAmount.toStringAsFixed(2);
                                final encodedPn = Uri.encodeComponent('NSE Clearing Limited');
                                final encodedTn = Uri.encodeComponent('MF Order $orderId');
                                final upiUri = Uri.parse(
                                  'upi://pay?pa=nseclearing.nseinvest.cc@validhdfc&pn=$encodedPn&am=$cleanAmount&cu=INR&tn=$encodedTn&tr=${nseTrxnOrderId ?? orderId}',
                                );
                                try {
                                  final launched = await launchUrl(upiUri, mode: LaunchMode.externalApplication);
                                  if (!launched) {
                                    await launchUrl(Uri.parse('upi://pay'), mode: LaunchMode.externalApplication);
                                  }
                                } catch (_) {
                                  try {
                                    await launchUrl(Uri.parse('upi://pay'), mode: LaunchMode.externalApplication);
                                  } catch (_) {}
                                }
                              },
                              icon: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 16),
                              label: const Text('Pay via UPI App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mintGreen,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (paymentLink != null && paymentLink.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            openNsePaymentGateway(
                              paymentLink,
                              title: 'NSE Clearing Gateway',
                              message: 'Official NSE portal opened. Select UPI or NetBanking to complete payment.',
                            );
                          },
                          icon: const Icon(Icons.language_rounded, size: 16, color: mintGreen),
                          label: const Text(
                            'Didn\'t get request? Pay via NSE Gateway',
                            style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF222B3D)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        );
      },
    );

    countdownTimer?.cancel();
    pollTimer?.cancel();
    return result ?? false;
  }

  // ── Place Lumpsum Purchase Order via Official NSE MF II Gateway ──
  Future<bool> createPurchaseOrder({
    required String schemeCode,
    required double orderAmount,
    String? schemeName,
    String? folioNo,
    String paymentMode = 'NSE_GATEWAY',
    String? vpa,
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final payload = {
        'schemeCode': schemeCode,
        'orderAmount': orderAmount,
        'folioNo': folioNo,
        'paymentMode': paymentMode,
      };
      if (vpa != null && vpa.isNotEmpty) {
        payload['vpa'] = vpa.trim();
      }
      final res = await dio.post('/mutual-funds/orders/purchase', data: payload);

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final paymentLink = data?['paymentLink']?.toString();
        final orderId = (data?['orderId'] ?? data?['order']?['orderId'])?.toString();
        final serverPaymentMode = data?['paymentMode']?.toString() ?? paymentMode;

        fetchPortfolio();

        if (serverPaymentMode == 'UPI' && orderId != null && orderId.isNotEmpty) {
          await showUpiApprovalModal(
            orderId: orderId,
            orderAmount: orderAmount,
            vpa: vpa ?? data?['vpa']?.toString() ?? 'your UPI app',
            schemeName: schemeName ?? 'Mutual Fund',
            paymentLink: paymentLink,
            nseTrxnOrderId: (data?['nsePaymentRefNo'] ?? data?['nseTrxnOrderId'] ?? data?['order']?['nseTrxnOrderId'] ?? data?['order']?['nsePaymentRefNo'])?.toString(),
          );
        } else if (paymentLink != null && paymentLink.isNotEmpty) {
          await openNsePaymentGateway(
            paymentLink,
            title: 'NSE Exchange Payment (UPI / NetBanking)',
            message: 'Official NSE gateway opened. Select UPI (GPay/PhonePe/Paytm) or NetBanking to pay directly to NSE Clearing Ltd.',
          );
          if (orderId != null && orderId.isNotEmpty) {
            Future.delayed(const Duration(seconds: 4), () => syncOrderStatus(orderId));
          }
        }

        return true;
      } else {
        final code = (res.data is Map) ? res.data['code']?.toString() : null;
        final errMsg = extractErrorMessage(res.data, fallback: 'This mutual fund is currently unavailable for purchase through NSE.');
        if (code == 'NSE_UCC_NOT_READY') {
          showUccRequiredDialog();
        } else {
          Get.snackbar(
            'Order Failed',
            errMsg,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
        }
        return false;
      }
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        final code = data['code']?.toString();
        if (code == 'NSE_UCC_NOT_READY') {
          showUccRequiredDialog();
          return false;
        }
      }
      final msg = extractErrorMessage(e, fallback: 'Order could not be processed with NSE exchange. Please try again.');
      Get.snackbar(
        'Order Failed',
        msg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      isSubmittingOrder.value = false;
    }
  }

  // ── Authoritative Status Check from NSE MFSS ──
  Future<Map<String, dynamic>?> syncOrderStatus(String orderId) async {
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/orders/' + orderId + '/status');
      if (res.statusCode == 200 && res.data['success'] == true) {
        fetchPortfolio();
        return res.data['data']?['order'];
      }
    } catch (e) {
      debugPrint('[syncOrderStatus Error]: ' + e.toString());
    }
    return null;
  }

  // ── Register SIP / XSIP via Official NSE MFSS Mandate ──
  Future<bool> registerSipOrder({
    required String schemeCode,
    required double installmentAmount,
    String? schemeName,
    String frequency = 'MONTHLY',
    DateTime? startDate,
    bool stepUpRequired = false,
    double stepUpAmount = 0,
    String paymentMode = 'NSE_GATEWAY',
    bool? firstOrderToday,
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final payload = {
        'schemeCode': schemeCode,
        'installmentAmount': installmentAmount,
        'frequency': frequency,
        'startDate': startDate?.toIso8601String(),
        'stepUpRequired': stepUpRequired,
        'stepUpAmount': stepUpAmount,
        'paymentMode': paymentMode,
      };
      if (firstOrderToday != null) {
        payload['firstOrderToday'] = firstOrderToday;
      }
      final res = await dio.post('/mutual-funds/sip/register', data: payload);

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final paymentLink = data?['paymentLink']?.toString();
        final userMsg = res.data['userMessage']?.toString() ??
            res.data['message']?.toString() ??
            'SIP registered on NSE MFSS with your Bank AutoPay Mandate.';

        if (paymentLink != null && paymentLink.isNotEmpty) {
          await openNsePaymentGateway(
            paymentLink,
            title: 'SIP Registered • AutoPay Active',
            message: userMsg,
          );
        } else {
          Get.snackbar(
            'SIP Registered Successfully! 🎉',
            userMsg,
            backgroundColor: const Color(0xFF00D09C),
            colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 6),
          );
        }
        fetchPortfolio();
        fetchMyOrders();
        return true;
      } else {
        final code = (res.data is Map) ? res.data['code']?.toString() : null;
        final msg = extractErrorMessage(res.data, fallback: 'Could not register SIP with NSE exchange.');
        if (code == 'NSE_UCC_NOT_READY') {
          showUccRequiredDialog();
        } else if (code == 'NSE_MANDATE_NOT_READY') {
          if (Get.context != null) {
            showMandateRequiredDialog(Get.context!);
          }
        } else {
          Get.snackbar(
            'SIP Registration Failed',
            msg,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 5),
          );
        }
        return false;
      }
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response!.data as Map;
        final code = data['code']?.toString();
        if (code == 'NSE_UCC_NOT_READY') {
          showUccRequiredDialog();
          return false;
        } else if (code == 'NSE_MANDATE_NOT_READY' && Get.context != null) {
          showMandateRequiredDialog(Get.context!);
          return false;
        }
      }
      final msg = extractErrorMessage(e, fallback: 'Failed to register SIP with exchange. Please try again.');
      Get.snackbar(
        'SIP Registration Failed',
        msg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return false;
    } finally {
      isSubmittingOrder.value = false;
    }
  }

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
        if (data['inProgressOrders'] != null) {
          inProgressOrders.assignAll(
            (data['inProgressOrders'] as List<dynamic>)
                .map((e) => MfOrderModel.fromJson(e as Map<String, dynamic>))
                .toList(),
          );
        }
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchPortfolio error: $e');
    } finally {
      isPortfolioLoading.value = false;
    }
  }

  // ── Fetch User Order History & Track In-Progress Transactions ──
  Future<void> fetchMyOrders() async {
    isOrdersLoading.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/orders/my');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final list = (res.data['data'] as List<dynamic>?)
                ?.map((e) => MfOrderModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        myOrders.assignAll(list);
        inProgressOrders.assignAll(list.where((o) => o.isProcessing).toList());
      }
    } catch (e) {
      debugPrint('[MutualFundsController] fetchMyOrders error: $e');
    } finally {
      isOrdersLoading.value = false;
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
  Future<Map<String, dynamic>> redeemHolding({
    required String schemeCode,
    String redeemMode = 'UNITS', // 'UNITS' or 'AMOUNT'
    double? units,
    double? amount,
    bool allUnits = false,
    String? folioNo,
    String? idempotencyKey,
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final payload = <String, dynamic>{
        'schemeCode': schemeCode,
        'redeemMode': redeemMode,
        'allUnits': allUnits,
      };
      if (redeemMode == 'AMOUNT' && amount != null) {
        payload['amount'] = amount;
        payload['orderAmount'] = amount;
      } else if (units != null) {
        payload['units'] = units;
      }
      if (folioNo != null && folioNo.isNotEmpty) {
        payload['folioNo'] = folioNo;
      }
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
        payload['idempotencyKey'] = idempotencyKey;
      }

      final res = await dio.post(
        '/mutual-funds/orders/redeem',
        data: payload,
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        await fetchPortfolio();
        return {
          'success': true,
          'message': res.data['message'] ?? 'Redemption request placed successfully. Payout will be credited to your bank account.',
          'data': res.data['data'],
        };
      } else {
        final errMsg = extractErrorMessage(res.data, fallback: 'Redemption failed. Please try again.');
        return {
          'success': false,
          'message': errMsg,
        };
      }
    } catch (e) {
      debugPrint('[MutualFundsController] redeemHolding error: ' + e.toString());
      final errMsg = extractErrorMessage(e, fallback: 'Redemption failed. Please try again later.');
      return {
        'success': false,
        'message': errMsg,
      };
    } finally {
      isSubmittingOrder.value = false;
    }
  }

  // Backwards-compatible alias for existing callers
  Future<Map<String, dynamic>> redeemUnits({
    required String schemeCode,
    required double units,
    bool allUnits = false,
  }) => redeemHolding(
        schemeCode: schemeCode,
        redeemMode: 'UNITS',
        units: units,
        allUnits: allUnits,
      );

  // Helper to fetch scheme model for Add Investment
  Future<MfSchemeModel?> getSchemeByCode(String code) async {
    final existing = schemes.firstWhereOrNull((s) => s.schemeCode == code);
    if (existing != null) return existing;
    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/mutual-funds/schemes/$code');
      if (res.statusCode == 200 && res.data['success'] == true && res.data['data'] != null) {
        return MfSchemeModel.fromJson(res.data['data']);
      }
    } catch (_) {}
    return null;
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
      final msg = extractErrorMessage(e, fallback: 'Failed to reset test account.');
      Get.snackbar(
        'Reset Failed',
        msg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String extractErrorMessage(dynamic e, {String fallback = 'An unexpected error occurred. Please try again.'}) {
    return ApiClient.formatError(e, fallback: fallback);
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
      final sortVal = allMfSort.value.isNotEmpty ? allMfSort.value : '${allMfReturnPeriod.value} Returns';
      if (sortVal == 'Popularity') {
        queryParams['sort'] = 'popularity';
      } else if (sortVal == '1Y Returns' || sortVal == '1Y') {
        queryParams['sort'] = 'returns1y';
      } else if (sortVal == '3Y Returns' || sortVal == '3Y Re' || sortVal == '3Y') {
        queryParams['sort'] = 'returns3y';
      } else if (sortVal == '5Y Returns' || sortVal == '5Y') {
        queryParams['sort'] = 'returns5y';
      } else if (sortVal == 'Rating') {
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
