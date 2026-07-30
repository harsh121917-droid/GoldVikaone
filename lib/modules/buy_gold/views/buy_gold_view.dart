import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

// ─── Design tokens (same identity as home) ───────────────────────────────────
const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _success = Color(0xFF2ecc71);
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
          bg: Color(0xFFF7F4EE),
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
  final _ctrl = TextEditingController(text: '1000');
  static const double _GST_PCT = 3.0;

  double get _total => _byAmount
      ? (double.tryParse(_ctrl.text) ?? 0)
      : (double.tryParse(_ctrl.text) ?? 0) *
            GoldController.to.buyRate *
            (1 + _GST_PCT / 100);

  double get _amount => _total / (1 + _GST_PCT / 100); // gold value (pre-GST)
  double get _grams => _amount / GoldController.to.buyRate;
  double get _gst => _total - _amount;
  double get _walletBal =>
      WalletController.to.wallet.value?.availableBalance ?? 0;
  bool get _hasEnoughBalance => _walletBal >= _total;
  bool get _valid => _amount >= 100.0 && _hasEnoughBalance;

  void _setAmt(double amt) => setState(() {
    _byAmount = true;
    _ctrl.text = amt.toStringAsFixed(0);
  });

  void _setGrams(double grams) => setState(() {
    _byAmount = false;
    _ctrl.text = grams.toStringAsFixed(3);
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.cardBorder),
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: t.ink,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buy Gold',
                            style: TextStyle(
                              color: t.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '24K · 99.99% Pure',
                            style: TextStyle(color: t.inkMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _gold.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            color: _gold,
                            size: 15,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Price Alert',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Current rate ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: t.subBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: t.primary,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.show_chart_rounded,
                          color: _gold,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Gold Rate (24K)',
                              style: TextStyle(color: t.inkMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Obx(() {
                              final loaded =
                                  GoldController.to.rate.value != null;
                              if (!loaded &&
                                  GoldController.to.rateLoading.value) {
                                return Row(
                                  children: [
                                    SizedBox(
                                      width: 11,
                                      height: 11,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: t.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: t.inkMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (!loaded) {
                                return GestureDetector(
                                  onTap: () => GoldController.to.loadRate(),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 13,
                                        color: _danger,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tap to retry',
                                        style: TextStyle(
                                          color: _danger,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Text(
                                '₹${GoldController.to.buyRate.toStringAsFixed(2)}/g',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Obx(() {
                        final chg =
                            GoldController.to.rate.value?.change24h ?? 0;
                        final pct =
                            GoldController.to.rate.value?.changePct ?? 0;
                        final isUp = chg >= 0;
                        final c = isUp ? _success : _danger;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUp
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: c,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${isUp ? '+' : ''}₹${chg.toStringAsFixed(2)} (${pct.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: c,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  height: 46,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: t.subBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _ToggleBtn(
                        'By Amount',
                        _byAmount,
                        t,
                        () => setState(() {
                          _byAmount = true;
                          _ctrl.text = '1000';
                        }),
                      ),
                      _ToggleBtn(
                        'By Weight',
                        !_byAmount,
                        t,
                        () => setState(() {
                          _byAmount = false;
                          _ctrl.text = '0.100';
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: t.subBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _byAmount ? '₹' : 'g',
                        style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children:
                      (_byAmount ? [500, 1000, 2000, 5000] : [1, 2, 5, 10]).map(
                        (v) {
                          final active = _byAmount
                              ? _ctrl.text == '$v'
                              : double.tryParse(_ctrl.text) == v.toDouble();
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap: () => _byAmount
                                    ? _setAmt(v.toDouble())
                                    : _setGrams(v.toDouble()),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? _gold.withOpacity(0.12)
                                        : t.card,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: active ? _gold : t.cardBorder,
                                      width: active ? 1.4 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    _byAmount ? '+ ₹$v' : '+ ${v}g',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: active ? _gold : t.ink,
                                      fontSize: 13,
                                      fontWeight: active
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: t.subBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Image.asset(
                              'assets/images/jar_img.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You will get',
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _grams.toStringAsFixed(4),
                                      style: TextStyle(
                                        color: t.primary,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        'g',
                                        style: TextStyle(
                                          color: t.primary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '(24K Gold · 99.99% Pure)',
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  color: _success,
                                  size: 16,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '100% Safe\n& Secure',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _success,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: t.inkMuted.withOpacity(0.15), height: 1),
                      const SizedBox(height: 14),
                      _row('Gold Value', '₹${_amount.toStringAsFixed(2)}', t),
                      const SizedBox(height: 10),
                      _row(
                        'GST (${_GST_PCT.toInt()}%)',
                        '₹${_gst.toStringAsFixed(2)}',
                        t,
                      ),
                      const SizedBox(height: 12),
                      Divider(color: t.inkMuted.withOpacity(0.15), height: 1),
                      const SizedBox(height: 12),
                      _row(
                        'Total Amount',
                        '₹${_total.toStringAsFixed(2)}',
                        t,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Paying From',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _hasEnoughBalance
                        ? _success.withOpacity(dark ? 0.10 : 0.06)
                        : _danger.withOpacity(dark ? 0.10 : 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_hasEnoughBalance ? _success : _danger)
                          .withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Wallet',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Available Balance: ₹${_walletBal.toStringAsFixed(2)}',
                              style: TextStyle(color: t.inkMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _hasEnoughBalance
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: _hasEnoughBalance ? _success : _danger,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                if (!_hasEnoughBalance) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed('/wallet'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _gold.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: _gold,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add Money to Wallet',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _success.withOpacity(dark ? 0.08 : 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: _success,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your gold is 100% insured and stored in secure vaults.',
                          style: TextStyle(color: _success, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Payable',
                          style: TextStyle(color: t.inkMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_total.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '(Incl. taxes)',
                          style: TextStyle(color: t.inkMuted, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _valid && !WalletController.to.isBuying.value
                            ? () async {
                                HapticFeedback.mediumImpact();
                                final ok = await WalletController.to.buyGold(
                                  amount: _amount,
                                );
                                if (ok) Get.back();
                              }
                            : null,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: _valid
                                ? const LinearGradient(
                                    colors: [_gold, _goldLight],
                                  )
                                : null,
                            color: _valid ? null : _gold.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _valid
                                ? [
                                    BoxShadow(
                                      color: _gold.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: WalletController.to.isBuying.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock_outline_rounded,
                                            color: _valid
                                                ? const Color(0xFF3D2B00)
                                                : Colors.white38,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _valid
                                                ? 'Buy Gold Securely'
                                                : (_amount >= 100.0
                                                      ? 'Insufficient Balance'
                                                      : 'Min ₹100'),
                                            style: TextStyle(
                                              color: _valid
                                                  ? const Color(0xFF3D2B00)
                                                  : Colors.white38,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Wallet Balance: ₹${_walletBal.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color:
                                              (_valid
                                                      ? const Color(0xFF3D2B00)
                                                      : Colors.white38)
                                                  .withOpacity(0.7),
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _trust(Icons.verified_user_outlined, 'Safe', t),
                    _trust(Icons.gpp_good_outlined, 'Secure', t),
                    _trust(Icons.groups_outlined, 'Trusted by 1M+ users', t),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _row(String label, String value, _T t, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: bold ? t.ink : t.inkMuted,
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: bold ? t.primary : t.ink,
          fontSize: bold ? 17 : 13,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _trust(IconData icon, String label, _T t) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: t.primary, size: 14),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: t.inkMuted, fontSize: 11)),
    ],
  );
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn(this.label, this.active, this.t, this.onTap);
  final String label;
  final bool active;
  final _T t;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        decoration: BoxDecoration(
          color: active ? _gold : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF3D2B00) : t.inkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
