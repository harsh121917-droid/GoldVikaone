import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/silver_repository.dart';

class SilverController extends GetxController {
  static SilverController get to => Get.find();

  final _repo = SilverRepository();

  // ── Observables ──────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isBuying = false.obs;
  final isSelling = false.obs;
  final rateLoading = false.obs;

  final rate = Rxn<SilverRateModel>();
  final balance = Rxn<SilverBalanceModel>();
  final transactions = <SilverTxnModel>[].obs;
  final errorMsg = ''.obs;

  final priceHistory = <Map<String, dynamic>>[].obs;
  final historyLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([
      loadRate(),
      loadBalance(),
      loadTransactions(),
      loadPriceHistory('1m'),
    ]);
    isLoading.value = false;
  }

  Future<void> loadPriceHistory(String period) async {
    try {
      historyLoading.value = true;
      priceHistory.value = await _repo.getPriceHistory('XAG', period);
    } catch (_) {} finally {
      historyLoading.value = false;
    }
  }

  // ── 1. Rate ───────────────────────────────────────────────────────────────
  Future<void> loadRate() async {
    try {
      rateLoading.value = true;
      rate.value = await _repo.getRate();
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Rate unavailable';
    } finally {
      rateLoading.value = false;
    }
  }

  // ── 2. Balance ────────────────────────────────────────────────────────────
  Future<void> loadBalance() async {
    try {
      balance.value = await _repo.getBalance();
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Balance unavailable';
    }
  }

  // ── 3. Transactions ───────────────────────────────────────────────────────
  Future<void> loadTransactions() async {
    try {
      transactions.value = await _repo.getTransactions();
    } on DioException catch (_) {}
  }

  // ── Helpers for UI ────────────────────────────────────────────────────────
  double get buyRate => rate.value?.buyRate ?? 175.0;
  double get sellRate => rate.value?.sellRate ?? 173.0;
  double get totalGrams => balance.value?.totalGrams ?? 0;

  double gramsForAmount(double amt) => amt / buyRate;
  double amountForGrams(double grams) => grams * buyRate;
  double gstFor(double amt) => amt * (rate.value?.gstPct ?? 3.0) / 100;
  double totalFor(double amt) => amt + gstFor(amt);
}
