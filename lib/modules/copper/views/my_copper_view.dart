import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vika1/modules/copper/controllers/copper_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';

// ─── Design Tokens for Copper ────────────────────────────────────────────────
const _copperPrimary = Color(0xFFC86D3B);
const _copperAccent = Color(0xFFEA580C);
const _copperLight = Color(0xFFFFA07A);
const _copperDark = Color(0xFF8C3E14);

class _CopperTheme {
  final Color bg, card, cardBorder, tp, ts, subBg, statBg;
  const _CopperTheme({
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.tp,
    required this.ts,
    required this.subBg,
    required this.statBg,
  });

  factory _CopperTheme.of(bool dark) => dark
      ? const _CopperTheme(
          bg: Color(0xFF0C0704),
          card: Color(0xFF19100A),
          cardBorder: Color(0x33D97706),
          tp: Color(0xFFFFF7ED),
          ts: Color(0xFFA8988B),
          subBg: Color(0xFF140C07),
          statBg: Color(0xFF22150D),
        )
      : const _CopperTheme(
          bg: Color(0xFFFBF8F5),
          card: Colors.white,
          cardBorder: Color(0xFFF0E4D8),
          tp: Color(0xFF2C1810),
          ts: Color(0xFF7A6A5E),
          subBg: Color(0xFFF5ECE4),
          statBg: Color(0xFFFAF2EB),
        );
}

class MyCopperView extends StatefulWidget {
  const MyCopperView({super.key});
  @override
  State<MyCopperView> createState() => _MyCopperViewState();
}

class _MyCopperViewState extends State<MyCopperView> {
  int _tabIdx = 2; // Default to 1M
  bool _hideAmt = false;
  final _tabs = ['1D', '1W', '1M', '1Y', '3Y', '5Y'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _CopperTheme.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.card,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.subBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.cardBorder),
              ),
              child: Icon(Icons.arrow_back_rounded, color: t.tp, size: 20),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Copper',
                style: TextStyle(
                  color: t.tp,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Track your 999 electrolytic copper holdings',
                style: TextStyle(color: t.ts, fontSize: 11),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: t.ts),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: t.ts),
              onPressed: () => Get.toNamed(AppRoutes.notifications),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Hero balance card ────────────────────────────────────────────
              Container(
                color: t.card,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_copperAccent, _copperPrimary],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '999 PURE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total Copper Holdings',
                                style: TextStyle(
                                  color: t.ts,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _hideAmt = !_hideAmt);
                                },
                                child: Icon(
                                  _hideAmt
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: t.ts,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // 3D Copper grams
                          _hideAmt
                              ? Container(
                                  height: 38,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: t.subBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [_copperAccent, _copperLight, _copperPrimary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Text(
                                    '${CopperController.to.totalGrams.toStringAsFixed(4)}g',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Value  ₹${(CopperController.to.balance.value?.currentValue ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: t.ts,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (_) {
                              final gain =
                                  CopperController.to.balance.value?.gainLoss ?? 0;
                              final gainPct =
                                  CopperController.to.balance.value?.gainLossPct ?? 0;
                              final isUp = gain >= 0;
                              final c = isUp
                                  ? const Color(0xFF2ecc71)
                                  : const Color(0xFFe74c3c);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: c.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: c.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUp
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      color: c,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${isUp ? '+' : ''}₹${gain.toStringAsFixed(2)} (${gainPct.toStringAsFixed(2)}%)',
                                      style: TextStyle(
                                        color: c,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'overall returns on invested capital',
                            style: TextStyle(color: t.ts, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    // Copper Ingot Badge (Cu Atomic 29)
                    Container(
                      width: 90,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD97706), Color(0xFFEA580C), Color(0xFF7C2D12)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _copperAccent.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                '29',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Cu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'COPPER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats Strip ──────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _Stat(
                      '${CopperController.to.totalGrams.toStringAsFixed(4)}g',
                      'Available Copper',
                      _copperPrimary,
                      t,
                    ),
                    _VDivider(t),
                    _Stat(
                      '₹${(CopperController.to.balance.value?.investedAmt ?? 0).toStringAsFixed(0)}',
                      'Invested Amount',
                      const Color(0xFF3B82F6),
                      t,
                    ),
                    _VDivider(t),
                    Builder(
                      builder: (_) {
                        final gain =
                            CopperController.to.balance.value?.gainLoss ?? 0;
                        final gainPct =
                            CopperController.to.balance.value?.gainLossPct ?? 0;
                        final isUp = gain >= 0;
                        return _Stat(
                          '${isUp ? '+' : ''}₹${gain.toStringAsFixed(2)} (${gainPct.toStringAsFixed(2)}%)',
                          'Gain / Loss',
                          isUp ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c),
                          t,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Chart Container ──────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.show_chart_rounded,
                          color: _copperAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Live Copper Price Chart',
                          style: TextStyle(
                            color: t.tp,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        // Time tabs
                        ..._tabs.asMap().entries.map(
                          (e) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _tabIdx = e.key);
                              CopperController.to.loadPriceHistory(
                                _tabs[e.key].toLowerCase(),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: _tabIdx == e.key
                                    ? const LinearGradient(
                                        colors: [_copperAccent, _copperPrimary],
                                      )
                                    : null,
                                color: _tabIdx == e.key ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: _tabIdx == e.key ? Colors.white : t.ts,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Value + change
                    Obx(() {
                      final history = CopperController.to.priceHistory;
                      final isLoading =
                          CopperController.to.historyLoading.value;

                      double currentPrice = CopperController.to.buyRate;
                      double changeAmt = 0.0;
                      double changePct = 0.0;
                      bool priceIsUp = true;

                      if (history.isNotEmpty) {
                        final lastItem = history.last;
                        currentPrice = (lastItem['price'] as num).toDouble();
                        final firstItem = history.first;
                        final firstPrice = (firstItem['price'] as num).toDouble();
                        changeAmt = currentPrice - firstPrice;
                        changePct = firstPrice > 0
                            ? (changeAmt / firstPrice) * 100
                            : 0.0;
                        priceIsUp = changeAmt >= 0;
                      }

                      final chartGainColor = priceIsUp
                          ? const Color(0xFF2ecc71)
                          : const Color(0xFFe74c3c);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                isLoading
                                    ? 'Loading...'
                                    : '₹${currentPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: t.tp,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                ' /gram',
                                style: TextStyle(
                                  color: t.ts,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (!isLoading && history.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  priceIsUp
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: chartGainColor,
                                  size: 13,
                                ),
                                Text(
                                  ' ${priceIsUp ? "+" : ""}₹${changeAmt.abs().toStringAsFixed(2)} (${priceIsUp ? "+" : ""}${changePct.toStringAsFixed(2)}% in ${_tabs[_tabIdx]})',
                                  style: TextStyle(
                                    color: chartGainColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '· Live API Setu Market',
                                  style: TextStyle(color: t.ts, fontSize: 10),
                                ),
                              ],
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    // Chart
                    Obx(
                      () => _SpotPriceChart(
                        history: CopperController.to.priceHistory,
                        isLoading: CopperController.to.historyLoading.value,
                        themeColor: _copperAccent,
                        bgColor: t.card,
                        inkColor: t.tp,
                        inkMutedColor: t.ts,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Holdings Card ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Holdings Breakdown',
                      style: TextStyle(
                        color: t.tp,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Holding row
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: t.subBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_copperAccent, _copperDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _copperAccent.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Cu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '999 Pure Electrolytic Copper',
                                  style: TextStyle(
                                    color: t.tp,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _copperAccent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Insured Vault',
                                        style: TextStyle(
                                          color: _copperAccent,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${CopperController.to.totalGrams.toStringAsFixed(4)}g  ·  ₹${(CopperController.to.balance.value?.currentValue ?? 0).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: t.ts,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: t.ts,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // View transactions
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.transactions),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.subBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: Color(0xFF3B82F6),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'View Copper Orders & Invoices',
                                style: TextStyle(
                                  color: t.tp,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: t.ts,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Copper SIP Banner ────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1305), Color(0xFF4A200B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _copperAccent.withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.savings_outlined,
                      color: _copperLight,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Copper SIP is the smart way to grow wealth',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Automate daily or monthly copper purchases.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.buyCopper),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_copperAccent, _copperPrimary],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _copperAccent.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Buy Copper',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),

        // ── Bottom Action Bar ──────────────────────────────────────────────────
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.paddingOf(context).bottom + 12,
          ),
          decoration: BoxDecoration(
            color: t.card,
            border: Border(top: BorderSide(color: t.cardBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.buyCopper),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_copperAccent, _copperPrimary],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _copperAccent.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Buy Copper',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.sellCopper),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: _copperAccent.withOpacity(dark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _copperAccent.withOpacity(0.4),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Sell Copper',
                        style: TextStyle(
                          color: _copperAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  const _Stat(this.val, this.lbl, this.color, this.t);
  final String val, lbl;
  final Color color;
  final _CopperTheme t;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lbl,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: t.ts,
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}

class _VDivider extends StatelessWidget {
  const _VDivider(this.t);
  final _CopperTheme t;
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36,
    color: t.cardBorder,
  );
}

class _SpotPriceChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final bool isLoading;
  final Color themeColor;
  final Color bgColor;
  final Color inkColor;
  final Color inkMutedColor;

  const _SpotPriceChart({
    required this.history,
    required this.isLoading,
    required this.themeColor,
    required this.bgColor,
    required this.inkColor,
    required this.inkMutedColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(color: _copperAccent),
        ),
      );
    }

    if (history.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No price data available.',
            style: TextStyle(color: inkMutedColor, fontSize: 12),
          ),
        ),
      );
    }

    final prices = history.map((e) => (e['price'] as num).toDouble()).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final priceRange = (maxPrice - minPrice).clamp(0.01, double.infinity);

    final yMin = minPrice - (priceRange * 0.05);
    final yMax = maxPrice + (priceRange * 0.05);

    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i]));
    }

    return SizedBox(
      height: 150,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: priceRange / 3,
            getDrawingHorizontalLine: (value) => FlLine(
              color: inkMutedColor.withOpacity(0.1),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (history.length - 1).toDouble(),
          minY: yMin,
          maxY: yMax,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => bgColor.withOpacity(0.95),
              tooltipBorder: BorderSide(color: themeColor.withOpacity(0.5)),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < history.length) {
                    final dateStr = history[index]['date'] as String;
                    final dt = DateTime.tryParse(dateStr) ?? DateTime.now();
                    final formattedDate =
                        "${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                    return LineTooltipItem(
                      '₹${spot.y.toStringAsFixed(2)}/g\n$formattedDate',
                      TextStyle(
                        color: inkColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: themeColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    themeColor.withOpacity(0.28),
                    themeColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
