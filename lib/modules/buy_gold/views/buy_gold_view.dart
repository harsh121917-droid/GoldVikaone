import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/routes/app_routes.dart';
import 'package:vika1/modules/profile/utils/policy_texts.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'package:vika1/core/services/auth_service.dart';
import 'package:vika1/modules/kyc/controllers/kyc_controller.dart';

import 'package:vika1/modules/profile/views/rewards_view.dart';

// Alias for quick reference
const _termsContent = PolicyTexts.terms;


// ─── Design tokens (same identity as home) ───────────────────────────────────
const _gold = Color(0xFFD4A017);
const _danger = Color(0xFFE05A47);

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder, subBg;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF050B07),
          card: Color(0xFF0C1710),
          primary: Color(0xFF1FAE7A),
          ink: Color(0xFFEDF3EF),
          inkMuted: Color(0xFF7C9689),
          cardBorder: Color(0x2A1FAE7A),
          subBg: Color(0xFF0A140D),
        )
      : const _T(
          bg: Color(0xFFF9F9FB),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Colors.transparent,
          subBg: Color(0xFFF3F1EA),
        );
}

class BuyGoldView extends StatefulWidget {
  const BuyGoldView({super.key});
  @override
  State<BuyGoldView> createState() => _BuyGoldViewState();
}

class _BuyGoldViewState extends State<BuyGoldView> {
  bool _byAmount = true;
  bool _showBreakup = true;
  bool _agreedToTerms = false;
  bool _redeemReferral = false;
  int _redeemedPoints = 0;
  final _ctrl = TextEditingController(text: '1000');
  static const double _GST_PCT = 3.0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PointsController>()) {
      Get.put(PointsController());
    }
  }

  double get _total => _byAmount
      ? (double.tryParse(_ctrl.text) ?? 0)
      : (double.tryParse(_ctrl.text) ?? 0) *
            GoldController.to.buyRate *
            (1 + _GST_PCT / 100);

  double get _redeemVal => _redeemedPoints * 0.01;

  double get _payableTotal => _total;

  double get _amount => _total / (1 + _GST_PCT / 100); // gold value (pre-GST)
  double get _extraGrams => _redeemVal / GoldController.to.buyRate;
  double get _referralExtraGrams => _redeemReferral ? (50.0 / GoldController.to.buyRate) : 0.0;
  double get _grams => (_amount / GoldController.to.buyRate) + _extraGrams + _referralExtraGrams;
  double get _gst => _total - _amount;
  double get _walletBal =>
      WalletController.to.wallet.value?.availableBalance ?? 0;
  bool get _hasEnoughBalance => _walletBal >= _payableTotal;
  bool get _valid => _total > 0;

  void _setAmt(double amt) => setState(() {
    _byAmount = true;
    _ctrl.text = amt.toStringAsFixed(0);
  });

  void _setGrams(double grams) => setState(() {
    _byAmount = false;
    _ctrl.text = grams.toStringAsFixed(4);
  });

  String _fmtUpdated(DateTime? dt) {
    if (dt == null) return 'Rate unavailable';
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final time = '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
    return sameDay
        ? 'Last Updated: today, $time'
        : 'Last Updated: ${dt.day}/${dt.month}, $time';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Premium App Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: t.card,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: t.ink,
                          size: 24,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Buy Gold',
                          style: TextStyle(
                            color: Color(0xFF0B3D2E),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.inkMuted.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.show_chart_rounded,
                            color: Color(0xFF0B3D2E),
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Live Rate',
                            style: TextStyle(
                              color: Color(0xFF0B3D2E),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: t.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.inkMuted.withOpacity(0.2)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: Color(0xFF0B3D2E),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Live Gold Rate Banner ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: 140,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/gold banner.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black.withOpacity(0.2), // gentle overlay
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Live Gold Price (24K)',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '₹ ${GoldController.to.buyRate.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700), // bright gold
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    ' /g',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Obx(() {
                                final chg = GoldController.to.rate.value?.change24h ?? 0;
                                final pct = GoldController.to.rate.value?.changePct ?? 0;
                                final isUp = chg >= 0;
                                final c = isUp ? const Color(0xFF2ecc71) : _danger;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                      color: c,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${pct.abs().toStringAsFixed(2)}% (Today)',
                                      style: TextStyle(
                                        color: c,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              const Spacer(),
                              Obx(() {
                                final rateVal = GoldController.to.rate.value;
                                return Row(
                                  children: [
                                    Text(
                                      _fmtUpdated(rateVal?.updatedAt),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.65),
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => GoldController.to.loadRate(),
                                      child: Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white.withOpacity(0.65),
                                        size: 11,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── "You are buying" Switch ───────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/gold_coin.png',
                                width: 22,
                                height: 22,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.monetization_on_outlined,
                                  color: _gold,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'You are buying',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: t.subBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3D2E),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/gold_coin.png',
                                        width: 14,
                                        height: 14,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.circle, color: _gold, size: 10),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Gold',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.offNamed(AppRoutes.buySilver),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: const BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/silver_coin.png',
                                          width: 14,
                                          height: 14,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.circle, color: Colors.grey, size: 10),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Silver',
                                          style: TextStyle(
                                            color: t.inkMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ── Enter Amount Card ──────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _byAmount ? 'Enter Amount' : 'Enter Weight',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_byAmount) {
                                  _byAmount = false;
                                  _ctrl.text = _grams > 0 ? _grams.toStringAsFixed(4) : '0.1405';
                                } else {
                                  _byAmount = true;
                                  _ctrl.text = _total > 0 ? _total.toStringAsFixed(0) : '1000';
                                }
                              });
                            },
                            child: Text(
                              _byAmount ? 'Or Enter Weight' : 'Or Enter Amount',
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.inkMuted.withOpacity(0.15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _byAmount ? '₹' : '',
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: TextField(
                                    controller: _ctrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (!_byAmount)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      'g',
                                      style: TextStyle(
                                        color: t.ink,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () {
                                    // Max sets a reasonable ceiling, e.g. wallet balance or 10,000
                                    setState(() {
                                      if (_byAmount) {
                                        _ctrl.text = _walletBal > 0 ? _walletBal.toStringAsFixed(0) : '10000';
                                      } else {
                                        final maxGrams = (_walletBal > 0 ? _walletBal : 10000) / GoldController.to.buyRate;
                                        _ctrl.text = maxGrams.toStringAsFixed(4);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9E6),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: _gold.withOpacity(0.5)),
                                    ),
                                    child: const Text(
                                      'Max',
                                      style: TextStyle(
                                        color: _gold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _byAmount
                                  ? '= ${_grams.toStringAsFixed(4)} g'
                                  : '= ₹${_total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Preset chips row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: (_byAmount ? [500.0, 1000.0, 2000.0, 5000.0] : [0.1, 0.5, 1.0, 2.0]).map((v) {
                          final label = _byAmount ? '₹${v.toInt()}' : '${v}g';
                          final active = _byAmount
                              ? (double.tryParse(_ctrl.text) == v)
                              : (double.tryParse(_ctrl.text) == v);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: GestureDetector(
                                onTap: () => _byAmount ? _setAmt(v) : _setGrams(v),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: active ? const Color(0xFFFFF9E6) : t.card,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: active ? _gold : t.inkMuted.withOpacity(0.15),
                                      width: active ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: active ? _gold : t.inkMuted,
                                      fontSize: 12,
                                      fontWeight: active ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // ── Payment Method Section ───────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6), // yellow/cream tint
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _gold, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B3D2E).withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Color(0xFF0B3D2E),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Wallet Balance',
                                        style: TextStyle(
                                          color: t.ink,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Available: ₹${_walletBal.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: t.inkMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _gold, width: 2),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0B3D2E),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_hasEnoughBalance) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () => Get.toNamed('/wallet'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _danger.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _danger.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_circle_outline_rounded,
                                      color: _danger,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Insufficient Balance. Add Money (Need ₹${(_payableTotal - _walletBal).toStringAsFixed(2)})',
                                      style: const TextStyle(
                                        color: _danger,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Reward Points Redemption Section ──────────────────────
                      Obx(() {
                        final pc = PointsController.to;
                        final availPoints = pc.points.value;
                        if (availPoints <= 0) return const SizedBox.shrink();

                        final List<int> pointOptions = [0];
                        for (int val in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000]) {
                          if (val <= availPoints) {
                            pointOptions.add(val);
                          }
                        }
                        if (availPoints > 0 && !pointOptions.contains(availPoints)) {
                          pointOptions.add(availPoints);
                        }
                        pointOptions.sort();

                        final List<DropdownMenuItem<int>> dropdownItems = pointOptions.map((pts) {
                          if (pts == 0) {
                            return const DropdownMenuItem<int>(
                              value: 0,
                              child: Text(
                                "Do not redeem points",
                                style: TextStyle(fontSize: 13),
                              ),
                            );
                          }
                          final extraVal = pts * 0.1;
                          final extraWt = extraVal / GoldController.to.buyRate;
                          return DropdownMenuItem<int>(
                            value: pts,
                            child: Text(
                              "Redeem $pts pts (Adds +${extraWt.toStringAsFixed(4)}g)",
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList();

                        if (_redeemedPoints > availPoints) {
                          _redeemedPoints = 0;
                        }

                        final userModel = Get.find<AuthService>().currentUser;
                        final referralBal = userModel?.referralBalance ?? 0.0;
                        
                        // Automatically uncheck if amount drops below 1000
                        if (_total < 1000.0 && _redeemReferral) {
                          _redeemReferral = false;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Referral Bonus Card ──
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: t.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _redeemReferral
                                      ? _gold
                                      : t.inkMuted.withOpacity(0.15),
                                  width: _redeemReferral ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _gold.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.card_giftcard_rounded,
                                          color: _gold,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Referral Reward Balance',
                                              style: TextStyle(
                                                color: t.ink,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Available Reward: ₹${referralBal.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: t.inkMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (referralBal >= 50.0) ...[
                                    const SizedBox(height: 12),
                                    if (_total >= 1000.0) ...[
                                      SwitchListTile.adaptive(
                                        contentPadding: EdgeInsets.zero,
                                        title: const Text(
                                          'Redeem ₹50 Reward',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Pay ₹${_total.toStringAsFixed(0)}, get ₹${(_total + 50.0).toStringAsFixed(0)} worth of gold!',
                                          style: TextStyle(
                                            color: _gold,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        value: _redeemReferral,
                                        activeColor: _gold,
                                        onChanged: (val) {
                                          setState(() {
                                            _redeemReferral = val;
                                          });
                                        },
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(top: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Minimum purchase of ₹1000 required to redeem your ₹50 reward.',
                                                style: TextStyle(
                                                  color: t.ink.withValues(alpha: 0.9),
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ] else ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Invite friends using your referral code to earn reward cash!',
                                      style: TextStyle(
                                        color: t.inkMuted,
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ── Points Card ──
                            Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: t.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _redeemedPoints > 0
                                  ? _gold.withOpacity(0.5)
                                  : t.inkMuted.withOpacity(0.15),
                              width: _redeemedPoints > 0 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _gold.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.emoji_events_outlined,
                                      color: _gold,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Redeem Reward Points',
                                          style: TextStyle(
                                            color: t.ink,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Available: $availPoints pts (₹${(availPoints * 0.01).toStringAsFixed(2)})',
                                          style: TextStyle(
                                            color: t.inkMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: t.card,
                                ),
                                child: DropdownButtonFormField<int>(
                                  value: _redeemedPoints,
                                  items: dropdownItems,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: t.inkMuted.withOpacity(0.2),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: t.inkMuted.withOpacity(0.2),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: _gold,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: t.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _redeemedPoints = val ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                      // ── You Will Pay Breakdown Card ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.inkMuted.withOpacity(0.15)),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _showBreakup = !_showBreakup),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'You will pay',
                                          style: TextStyle(
                                            color: t.inkMuted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '₹${_payableTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF0B3D2E),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _showBreakup ? 'Hide Breakup' : 'View Breakup',
                                        style: const TextStyle(
                                          color: Color(0xFF0B3D2E),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        _showBreakup
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: const Color(0xFF0B3D2E),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (_showBreakup) ...[
                              const SizedBox(height: 12),
                              Divider(color: t.inkMuted.withOpacity(0.12), height: 1),
                              const SizedBox(height: 12),
                              _breakupRow('Gold Price (24K)', '₹${GoldController.to.buyRate.toStringAsFixed(2)} /g', t),
                              const SizedBox(height: 8),
                              _breakupRow('Weight', '${_grams.toStringAsFixed(4)} g', t),
                              if (_redeemedPoints > 0 || _redeemReferral) ...[
                                const SizedBox(height: 8),
                                _breakupRow('  ↳ Base Weight', '${(_amount / GoldController.to.buyRate).toStringAsFixed(4)} g', t),
                                if (_redeemedPoints > 0) ...[
                                  const SizedBox(height: 8),
                                  _breakupRow('  ↳ Points Added', '+${_extraGrams.toStringAsFixed(4)} g', t, isGreen: true),
                                ],
                                if (_redeemReferral) ...[
                                  const SizedBox(height: 8),
                                  _breakupRow('  ↳ Referral Reward', '+${_referralExtraGrams.toStringAsFixed(4)} g (Adds ₹50)', t, isGreen: true),
                                ],
                              ],
                              const SizedBox(height: 8),
                              _breakupRow('Making Charges', 'FREE', t, isGreen: true),
                              const SizedBox(height: 8),
                              _breakupRow('GST (3%)', '₹${_gst.toStringAsFixed(2)}', t),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Secure Gold Strip ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.inkMuted.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A017).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Color(0xFFD4A017),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '100% Secure Gold',
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Your gold is stored in secure vaults and 100% insured.',
                                    style: TextStyle(
                                      color: t.inkMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: t.inkMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Fixed Bottom Actions ─────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border(
                    top: BorderSide(
                      color: t.inkMuted.withOpacity(0.15),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Terms & Conditions Checkbox ──────────────────────────
                    GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _agreedToTerms
                                    ? const Color(0xFF0B3D2E)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _agreedToTerms
                                      ? const Color(0xFF0B3D2E)
                                      : t.inkMuted.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 11.5,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () => Get.toNamed(
                                          '/policy',
                                          arguments: {
                                            'title': 'Terms & Conditions',
                                            'content': _termsContent,
                                          },
                                        ),
                                        child: const Text(
                                          'Terms & Conditions',
                                          style: TextStyle(
                                            color: Color(0xFF0B3D2E),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' of this purchase'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _valid && _agreedToTerms && !WalletController.to.isBuying.value
                          ? () async {
                              HapticFeedback.mediumImpact();

                              if (_total < 50.0) {
                                Get.snackbar(
                                  "Invalid Amount",
                                  "Minimum purchase is ₹50",
                                  backgroundColor: const Color(0xFFE05A47),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              if (!_hasEnoughBalance) {
                                Get.snackbar(
                                  "Insufficient Balance",
                                  "Wallet has ₹${_walletBal.toStringAsFixed(2)}, need ₹${_total.toStringAsFixed(2)}.",
                                  backgroundColor: const Color(0xFFE05A47),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              
                              final kycCtrl = Get.isRegistered<KycController>()
                                  ? Get.find<KycController>()
                                  : Get.put(KycController());
                              if (kycCtrl.kycStatus.value != "approved") {
                                Get.snackbar(
                                  "KYC Required",
                                  "Please complete your KYC to buy gold.",
                                  backgroundColor: const Color(0xFFE05A47),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              final pointsToRedeem = _redeemedPoints;
                              final ok = await WalletController.to.buyGold(
                                amount: _amount,
                                pointsRedeemed: pointsToRedeem > 0 ? pointsToRedeem : null,
                                redeemReferral: _redeemReferral,
                              );
                              if (ok) {
                                if (pointsToRedeem > 0) {
                                  PointsController.to.redeemPoints(pointsToRedeem, 'Gold Purchase');
                                }
                                _showSuccessDialog(_grams, _payableTotal);
                              }
                            }
                          : null,
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                           color: (_valid && _agreedToTerms) ? const Color(0xFF0B3D2E) : const Color(0xFF0B3D2E).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: WalletController.to.isBuying.value
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.lock_outline_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Buy Gold Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${_payableTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700), // gold text
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Trust elements row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _trustBadge(Icons.verified_outlined, '24K 99.99% Purity', '100% Hallmarked', t),
                        _trustBadge(Icons.lock_outline, 'Secure Vault', 'Insured & Safe', t),
                        _trustBadge(Icons.swap_horiz_rounded, 'Easy Buy & Sell', 'Anytime, Anywhere', t),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _breakupRow(String label, String value, _T t, {bool isGreen = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: t.inkMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: isGreen ? const Color(0xFF2ecc71) : t.ink,
          fontSize: 12,
          fontWeight: isGreen ? FontWeight.w800 : FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _trustBadge(IconData icon, String title, String sub, _T t) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: t.inkMuted.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0B3D2E), size: 14),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: t.ink,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: t.inkMuted,
            fontSize: 8,
          ),
        ),
      ],
    ),
  );

  void _showSuccessDialog(double grams, double totalPaid) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scaleCurve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        final opacityCurve = CurvedAnimation(parent: anim1, curve: Curves.easeOut);
        
        final dark = ThemeController.to.isDark.value;
        final t = _T.of(dark);

        return FadeTransition(
          opacity: opacityCurve,
          child: ScaleTransition(
            scale: scaleCurve,
            child: AlertDialog(
              backgroundColor: t.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ecc71).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Image.asset(
                        'assets/images/gold_coin.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.monetization_on_rounded,
                          color: _gold,
                          size: 50,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2ecc71),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gold Purchased Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0B3D2E),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your digital gold will credit to your account shortly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.subBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.inkMuted.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _dialogRow('Asset Type', '24K Gold', t),
                        const SizedBox(height: 8),
                        _dialogRow('Weight Credited', '${grams.toStringAsFixed(4)} g', t, isHighlight: true),
                        const SizedBox(height: 8),
                        _dialogRow('Total Amount', '₹${totalPaid.toStringAsFixed(2)}', t),
                        const SizedBox(height: 8),
                        _dialogRow('Paid Via', 'Wallet Balance', t),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.back();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3D2E),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dialogRow(String label, String val, _T t, {bool isHighlight = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: t.inkMuted,
          fontSize: 12,
        ),
      ),
      Text(
        val,
        style: TextStyle(
          color: isHighlight ? const Color(0xFF0B3D2E) : t.ink,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
