import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/copper/controllers/copper_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

// ─── Design tokens (Copper Theme identity) ───────────────────────────────────
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
          bg: Color(0xFF060B16),
          card: Color(0xFF0E1626),
          primary: Color(0xFF8A95A5),
          ink: Color(0xFFEDF0FF),
          inkMuted: Color(0xFF8A95B0),
          cardBorder: Color(0xFF1A2B45),
          subBg: Color(0xFF0A0F1E),
        )
      : const _T(
          bg: Color(0xFFF9F9FB),
          card: Colors.white,
          primary: Color(0xFF1A2340),
          ink: Color(0xFF1A2340),
          inkMuted: Color(0xFF6B7280),
          cardBorder: Colors.transparent,
          subBg: Color(0xFFF8F5EE),
        );
}

class SellCopperView extends StatefulWidget {
  const SellCopperView({super.key});
  @override
  State<SellCopperView> createState() => _SellCopperViewState();
}

class _SellCopperViewState extends State<SellCopperView> {
  bool _byGrams = true;
  final _ctrl = TextEditingController(text: '1.0000');

  double get _sellRate =>
      CopperController.to.sellRate > 0 ? CopperController.to.sellRate : 173.0;
  double get _available =>
      CopperController.to.balance.value?.availableGrams ?? 0;

  double get _inputVal => double.tryParse(_ctrl.text) ?? 0;
  double get _gramsDisp => _byGrams ? _inputVal : _inputVal / _sellRate;
  double get _rupeesDisp => _byGrams ? _inputVal * _sellRate : _inputVal;
  bool get _valid => _gramsDisp > 0.0001 && _gramsDisp <= _available;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sell Copper',
                              style: TextStyle(
                                color: t.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Convert your copper to cash',
                              style: TextStyle(color: t.inkMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.inkMuted.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: t.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Help',
                            style: TextStyle(
                              color: t.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Live Copper Rate Banner ────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: 140,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/copper_banner.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black.withOpacity(0.2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Live Copper Price (999)',
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
                                    '₹ ${_sellRate.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
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
                                final chg =
                                    CopperController.to.rate.value?.change24h ??
                                    0;
                                final pct =
                                    CopperController.to.rate.value?.changePct ??
                                    0;
                                final isUp = chg >= 0;
                                final c = isUp
                                    ? const Color(0xFF2ecc71)
                                    : _danger;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUp
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
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
                                final rateVal = CopperController.to.rate.value;
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
                                      onTap: () =>
                                          CopperController.to.loadRate(),
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
                      const SizedBox(height: 16),

                      // ── Available Balance Card ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: t.inkMuted.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: t.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: t.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Available Copper Balance',
                                    style: TextStyle(
                                      color: t.inkMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_available.toStringAsFixed(4)} g',
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹ ${(_available * _sellRate).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: t.inkMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Enter Sell Amount Card ──────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _byGrams ? 'Enter Weight' : 'Enter Sell Amount',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_byGrams) {
                                  _byGrams = false;
                                  _ctrl.text = _rupeesDisp > 0
                                      ? _rupeesDisp.toStringAsFixed(0)
                                      : '1000';
                                } else {
                                  _byGrams = true;
                                  _ctrl.text = _gramsDisp > 0
                                      ? _gramsDisp.toStringAsFixed(4)
                                      : '5.0000';
                                }
                              });
                            },
                            child: Text(
                              _byGrams ? 'Or Enter Amount' : 'Or Enter Weight',
                              style: TextStyle(
                                color: t.primary,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: t.inkMuted.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _byGrams ? '' : '₹',
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: TextField(
                                    controller: _ctrl,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
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
                                if (_byGrams)
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
                                    setState(() {
                                      _byGrams = true;
                                      _ctrl.text = _available.toStringAsFixed(
                                        4,
                                      );
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.primary.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: t.primary.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      'Max',
                                      style: TextStyle(
                                        color: t.primary,
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
                              _byGrams
                                  ? '= ₹${_rupeesDisp.toStringAsFixed(2)}'
                                  : '= ${_gramsDisp.toStringAsFixed(4)} g',
                              style: TextStyle(
                                color: t.primary,
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
                        children: [
                          _chip(
                            _byGrams ? 10.0 : 500.0,
                            _byGrams ? '10g' : '₹500',
                            t,
                          ),
                          _chip(
                            _byGrams ? 20.0 : 1000.0,
                            _byGrams ? '20g' : '₹1000',
                            t,
                          ),
                          _chip(
                            _byGrams ? 50.0 : 2000.0,
                            _byGrams ? '50g' : '₹2000',
                            t,
                          ),
                          _chip(0.0, 'All Balance', t, isAll: true),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── You Will Receive Breakup Box (NO GST, NO making charges) ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: t.inkMuted.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You will receive (Breakup)',
                                        style: TextStyle(
                                          color: t.inkMuted,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${_rupeesDisp.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: t.primary,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2ecc71,
                                    ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF2ecc71,
                                      ).withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: Color(0xFF2ecc71),
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Best Price',
                                        style: TextStyle(
                                          color: Color(0xFF2ecc71),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '(${_gramsDisp.toStringAsFixed(4)} g × ₹${_sellRate.toStringAsFixed(2)}/g)',
                              style: TextStyle(color: t.inkMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Payment Method Message Card ──────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: t.primary.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                color: t.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Money will be added to Wallet',
                                    style: TextStyle(
                                      color: t.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Funds will credit to your App Wallet instantly. You can withdraw to your bank account at any time.',
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
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Bottom Fixed Payout Action ──────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border(
                    top: BorderSide(color: t.inkMuted.withOpacity(0.15)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _valid && !WalletController.to.isSelling.value
                          ? () async {
                              HapticFeedback.mediumImpact();
                              final ok = await WalletController.to.sellCopper(
                                _gramsDisp,
                              );
                              if (ok) {
                                _showSuccessDialog(_gramsDisp, _rupeesDisp);
                              }
                            }
                          : null,
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _valid
                              ? t.primary
                              : t.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: WalletController.to.isSelling.value
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        'Sell Copper Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${_rupeesDisp.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Trust indicators row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _trustBadge(
                          Icons.verified_outlined,
                          '100% Secure',
                          'Your copper is 100% safe',
                          t,
                        ),
                        _trustBadge(
                          Icons.bolt_outlined,
                          'Instant Payout',
                          'Get money instantly',
                          t,
                        ),
                        _trustBadge(
                          Icons.visibility_off_outlined,
                          'No Hidden Charges',
                          'Transparent process',
                          t,
                        ),
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

  Widget _chip(double val, String label, _T t, {bool isAll = false}) {
    final active = isAll
        ? (_gramsDisp - _available).abs() < 0.001
        : _byGrams
        ? (double.tryParse(_ctrl.text) == val)
        : (double.tryParse(_ctrl.text) == val);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: GestureDetector(
          onTap: () {
            setState(() {
              if (isAll) {
                _byGrams = true;
                _ctrl.text = _available.toStringAsFixed(4);
              } else {
                if (_byGrams) {
                  _ctrl.text = val.toStringAsFixed(4);
                } else {
                  _ctrl.text = val.toStringAsFixed(0);
                }
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? t.primary.withOpacity(0.08) : t.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? t.primary : t.inkMuted.withOpacity(0.15),
                width: active ? 1.5 : 1,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? t.primary : t.inkMuted,
                fontSize: 12,
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
          child: Icon(icon, color: t.primary, size: 14),
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
          style: TextStyle(color: t.inkMuted, fontSize: 8),
        ),
      ],
    ),
  );

  void _showSuccessDialog(double grams, double totalAmount) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scaleCurve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        final opacityCurve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOut,
        );

        final dark = ThemeController.to.isDark.value;
        final t = _T.of(dark);

        return FadeTransition(
          opacity: opacityCurve,
          child: ScaleTransition(
            scale: scaleCurve,
            child: AlertDialog(
              backgroundColor: t.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                        'assets/images/copper_coin.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.grey,
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
                    'Copper Sold Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The sale proceeds have been credited to your App Wallet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B7A72), fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F1EA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6B7A72).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _dialogRow('Asset Type', '999 Copper', t),
                        const SizedBox(height: 8),
                        _dialogRow(
                          'Weight Sold',
                          '${grams.toStringAsFixed(4)} g',
                          t,
                          isHighlight: true,
                        ),
                        const SizedBox(height: 8),
                        _dialogRow(
                          'Amount Received',
                          '₹${totalAmount.toStringAsFixed(2)}',
                          t,
                        ),
                        const SizedBox(height: 8),
                        _dialogRow('Credited To', 'Wallet Balance', t),
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
                        color: t.primary,
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

  Widget _dialogRow(
    String label,
    String val,
    _T t, {
    bool isHighlight = false,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: t.inkMuted, fontSize: 12)),
      Text(
        val,
        style: TextStyle(
          color: isHighlight ? t.primary : t.ink,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
