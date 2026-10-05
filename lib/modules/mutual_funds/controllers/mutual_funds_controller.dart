import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../views/mf_ucc_onboarding_view.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
// Dedicated NSE MF II Gateway - Zero 3rd-party PG
// AuthService not needed without Razorpay prefill
import '../../../core/network/api_client.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../../../data/models/mf_portfolio_model.dart';

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
    // Razorpay initialization removed for MF
    fetchSchemes();
    checkUserUcc();
    fetchOnboardingStatus();
    fetchPortfolio();
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

  // ── Place Lumpsum Purchase Order via Official NSE MF II Gateway ──
  Future<bool> createPurchaseOrder({
    required String schemeCode,
    required double orderAmount,
    String? schemeName,
    String? folioNo,
    String paymentMode = 'NSE_PAYMENT_LINK',
  }) async {
    isSubmittingOrder.value = true;
    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/orders/purchase', data: {
        'schemeCode': schemeCode,
        'orderAmount': orderAmount,
        'folioNo': folioNo,
        'paymentMode': paymentMode,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        final paymentLink = data?['paymentLink']?.toString();
        final orderId = data?['order']?['orderId']?.toString();

        if (paymentLink != null && paymentLink.isNotEmpty) {
          final uri = Uri.parse(paymentLink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }

        Get.snackbar(
          'NSE Payment Gateway',
          'Official NSE MFSS payment link opened. Please complete payment in your browser/UPI app.',
          backgroundColor: const Color(0xFF00D09C),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );

        fetchPortfolio();

        if (orderId != null && orderId.isNotEmpty) {
          Future.delayed(const Duration(seconds: 4), () => syncOrderStatus(orderId));
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
        final paymentLink = data?['paymentLink']?.toString();

        if (paymentLink != null && paymentLink.isNotEmpty) {
          final uri = Uri.parse(paymentLink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }

        Get.snackbar(
          'NSE SIP Mandate Opened',
          'Official NSE XSIP mandate / payment authorization opened in browser.',
          backgroundColor: const Color(0xFF00D09C),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        fetchPortfolio();
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
