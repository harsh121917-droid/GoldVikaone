import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/core/theme/app_colors.dart';
import 'package:vika1/data/repositories/gold_repository.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';

class GoldController extends GetxController {
  static GoldController get to => Get.find();

  final _repo = GoldRepository();

  // ── Observables ──────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isBuying = false.obs;
  final isSelling = false.obs;
  final rateLoading = false.obs;

  final rate = Rxn<GoldRateModel>();
  final rawRates = <String, dynamic>{}.obs;
  final balance = Rxn<GoldBalanceModel>();
  final transactions = <GoldTxnModel>[].obs;
  final errorMsg = ''.obs;

  final priceHistory = <Map<String, dynamic>>[].obs;
  final historyLoading = false.obs;

  final coins = <Map<String, dynamic>>[].obs;
  final coinsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([
      loadRate(),
      loadBalance(),
      loadTransactions(),
      loadPriceHistory('1m'),
      loadCoins(),
    ]);
    isLoading.value = false;
  }

  Future<void> loadCoins() async {
    try {
      coinsLoading.value = true;
      coins.value = await _repo.getCoins();
    } catch (_) {} finally {
      coinsLoading.value = false;
    }
  }

  Future<bool> redeemCoin({
    required String coinId,
    required String addressLine,
    required String pincode,
    required String phone,
    bool redeemDigital = false,
  }) async {
    try {
      final res = await _repo.redeemCoin(
        coinId: coinId,
        addressLine: addressLine,
        pincode: pincode,
        phone: phone,
        redeemDigital: redeemDigital,
      );
      if (res['success'] == true) {
        // Refresh balance & coins list
        loadAll();
        if (Get.isRegistered<WalletController>()) {
          WalletController.to.loadAll();
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadPriceHistory(String period) async {
    try {
      historyLoading.value = true;
      priceHistory.value = await _repo.getPriceHistory('XAU', period);
    } catch (_) {} finally {
      historyLoading.value = false;
    }
  }

  // ── 1. Rate ───────────────────────────────────────────────────────────────
  Future<void> loadRate() async {
    try {
      rateLoading.value = true;
      final data = await _repo.getRawRates();
      rawRates.value = data;
      final gold = (data['gold'] ?? {}) as Map<String, dynamic>;
      rate.value = GoldRateModel.fromJson({
        ...gold,
        'updatedAt': data['updatedAt'],
        'source': data['source'],
      });
    } on DioException catch (e) {
      // Use static fallback if API fails
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

  // ── 3. Buy Gold (called from BuyGoldView) ─────────────────────────────────
  // Returns the initiate result so the view can open Razorpay
  Future<GoldBuyInitiateResult?> initiateBuy({
    double? amount,
    double? grams,
  }) async {
    try {
      isBuying.value = true;
      errorMsg.value = '';
      return await _repo.initiateBuy(amountInRupees: amount, grams: grams);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to create order';
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: AppColors.error,
        colorText: const Color(0xFFFFFFFF),
      );
      return null;
    } finally {
      isBuying.value = false;
    }
  }

  Future<bool> verifyBuy({
    required String orderId,
    required String paymentId,
    required String signature,
    required String transactionId,
  }) async {
    try {
      final ok = await _repo.verifyBuy(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
        transactionId: transactionId,
      );
      if (ok) {
        HapticFeedback.mediumImpact();
        await Future.wait([loadBalance(), loadTransactions()]);
        Get.snackbar(
          'Gold Credited! 🥇',
          'Your gold has been added to your account',
          backgroundColor: const Color(0xFFD4A017),
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return ok;
    } on DioException catch (_) {
      Get.snackbar(
        'Verification Failed',
        'Contact support with your payment ID',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    }
  }

  // ── 4. Sell Gold ──────────────────────────────────────────────────────────
  Future<bool> sellGold({
    required double grams,
    String bankAccountId = 'default',
  }) async {
    try {
      isSelling.value = true;
      await _repo.sellGold(grams: grams, bankAccountId: bankAccountId);
      await Future.wait([loadBalance(), loadTransactions()]);
      Get.snackbar(
        'Sell Order Placed! 💰',
        'Amount will be credited in 1-2 working hours',
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on DioException catch (e) {
      Get.snackbar(
        'Sell Failed',
        e.response?.data?['message'] ?? 'Failed to sell',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSelling.value = false;
    }
  }

  // ── 5. Transactions ───────────────────────────────────────────────────────
  Future<void> loadTransactions() async {
    try {
      transactions.value = await _repo.getTransactions();
    } on DioException catch (_) {}
  }

  // ── Helpers for UI ────────────────────────────────────────────────────────
  double get buyRate => rate.value?.buyRate ?? 7309.0;
  double get sellRate => rate.value?.sellRate ?? 7256.0;
  double get totalGrams => balance.value?.totalGrams ?? 0;

  double get goldPct => rate.value?.changePct ?? 0.0;

  double get silverRate => (rawRates['silver']?['buyRate'] ?? 177.17) * 1.0;
  double get silverPct => (rawRates['silver']?['changePct'] ?? 0.0) * 1.0;

  double get platinumRate => (rawRates['platinum']?['buyRate'] ?? 5079.50) * 1.0;
  double get platinumPct => (rawRates['platinum']?['changePct'] ?? 0.0) * 1.0;

  double get palladiumRate => (rawRates['palladium']?['buyRate'] ?? 3980.07) * 1.0;
  double get palladiumPct => (rawRates['palladium']?['changePct'] ?? 0.0) * 1.0;

  double get copperRate => (rawRates['copper']?['buyRate'] ?? 1.32) * 1.0;
  double get copperPct => (rawRates['copper']?['changePct'] ?? 0.0) * 1.0;

  double gramsForAmount(double amt) => amt / buyRate;
  double amountForGrams(double grams) => grams * buyRate;
  double gstFor(double amt) => amt * (rate.value?.gstPct ?? 3.0) / 100;
  double totalFor(double amt) => amt + gstFor(amt);
}
