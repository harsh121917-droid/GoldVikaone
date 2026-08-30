import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';

// ─── Live data from SilverController ──────────────────────────────────────────

// Dummy chart data (7 points for 1M view)
const _chart1M = [
  17200.0,
  17450.0,
  17300.0,
  17800.0,
  18100.0,
  18400.0,
  18756.0,
];
const _chart3M = [
  15800.0,
  16200.0,
  16800.0,
  17100.0,
  17500.0,
  18100.0,
  18756.0,
];
const _chart6M = [
  14500.0,
  15200.0,
  15900.0,
  16600.0,
  17200.0,
  17900.0,
  18756.0,
];
const _chart1Y = [
  12000.0,
  13500.0,
  14800.0,
  15600.0,
  16500.0,
  17700.0,
  18756.0,
];

class MySilverView extends StatefulWidget {
  const MySilverView({super.key});
  @override
  State<MySilverView> createState() => _MySilverViewState();
}

class _MySilverViewState extends State<MySilverView>
    with SingleTickerProviderStateMixin {
  int _tabIdx = 2; // Default to 1M
  bool _hideAmt = false;
  final _tabs = ['1D', '1W', '1M', '1Y', '3Y', '5Y'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: dark ? const Color(0xFF0E1626) : Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Silver',
                style: TextStyle(
                  color: tp,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Track your silver holdings and growth',
                style: TextStyle(color: ts, fontSize: 11),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: ts),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: ts),
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Hero balance ─────────────────────────────────────────────────
              Container(
                color: dark ? const Color(0xFF0E1626) : Colors.white,
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
                              Text(
                                'Total Silver',
                                style: TextStyle(color: ts, fontSize: 13),
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
                                  color: ts,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 3D grams
                          _hideAmt
                              ? Container(
                                  height: 38,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? const Color(0xFF1A2B45)
                                        : const Color(0xFFF0EDE4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(2, 3),
                                      child: Text(
                                        '${SilverController.to.totalGrams.toStringAsFixed(4)}g',
                                        style: TextStyle(
                                          color: Color(0x44D4A017),
                                          fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${SilverController.to.totalGrams.toStringAsFixed(4)}g',
                                      style: TextStyle(
                                        color: Color(0xFF8A95A5),
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Value  ₹${(SilverController.to.balance.value?.currentValue ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(color: ts, fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Builder(
                            builder: (_) {
                              final gain =
                                  SilverController.to.balance.value?.gainLoss ??
                                  0;
                              final gainPct =
                                  SilverController
                                      .to
                                      .balance
                                      .value
                                      ?.gainLossPct ??
                                  0;
                              final isUp = gain >= 0;
                              final c = isUp
                                  ? const Color(0xFF2ecc71)
                                  : const Color(0xFFe74c3c);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: c.withOpacity(0.10),
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
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${isUp ? '+' : ''}₹${gain.toStringAsFixed(2)} (${gainPct.toStringAsFixed(2)}%)',
                                      style: TextStyle(
                                        color: c,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'since last purchase',
                            style: TextStyle(color: ts, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    // Jar
                    SizedBox(
                      width: 110,
                      height: 120,
                      child: Image.asset(
                        'assets/images/jar_img.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Stats strip ──────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _Stat(
                      '${SilverController.to.totalGrams.toStringAsFixed(4)}g',
                      'Available Silver',
                      const Color(0xFF8A95A5),
                      dark,
                    ),
                    _VDivider(dark),
                    _Stat(
                      '₹${(SilverController.to.balance.value?.investedAmt ?? 0).toStringAsFixed(0)}',
                      'Invested Amount',
                      const Color(0xFF3B82F6),
                      dark,
                    ),
                    _VDivider(dark),
                    Builder(
                      builder: (_) {
                        final gain =
                            SilverController.to.balance.value?.gainLoss ?? 0;
                        final gainPct =
                            SilverController.to.balance.value?.gainLossPct ?? 0;
                        final isUp = gain >= 0;
                        return _Stat(
                          '${isUp ? '+' : ''}₹${gain.toStringAsFixed(2)}\n${gainPct.toStringAsFixed(2)}%',
                          'Gain / Loss',
                          isUp
                              ? const Color(0xFF2ecc71)
                              : const Color(0xFFe74c3c),
                          dark,
                        );
                      },
                    ),
                    // _VDivider(dark),
                    // _Stat(
                    //   '₹${(SilverController.to.balance.value?.avgBuyRate ?? 0)}/g',
                    //   'Avg. Buy Price',
                    //   const Color(0xFFAB47BC),
                    //   dark,
                    // ),
                  ],
                ),
              ),

              // ── Chart ────────────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
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
                        Text(
                          'Silver Value',
                          style: TextStyle(
                            color: tp,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.access_time_rounded, color: ts, size: 14),
                        const Spacer(),
                        // Time tabs
                        ..._tabs.asMap().entries.map(
                          (e) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _tabIdx = e.key);
                              SilverController.to.loadPriceHistory(_tabs[e.key].toLowerCase());
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _tabIdx == e.key
                                    ? const Color(0xFF8A95A5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: _tabIdx == e.key ? Colors.black : ts,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
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
                      final history = SilverController.to.priceHistory;
                      final isLoading = SilverController.to.historyLoading.value;
                      
                      double currentPrice = SilverController.to.buyRate;
                      double changeAmt = 0.0;
                      double changePct = 0.0;
                      bool priceIsUp = true;
                      
                      if (history.isNotEmpty) {
                        final lastItem = history.last;
                        currentPrice = (lastItem['price'] as num).toDouble();
                        final firstItem = history.first;
                        final firstPrice = (firstItem['price'] as num).toDouble();
                        changeAmt = currentPrice - firstPrice;
                        changePct = firstPrice > 0 ? (changeAmt / firstPrice) * 100 : 0.0;
                        priceIsUp = changeAmt >= 0;
                      }
                      
                      final chartGainColor = priceIsUp ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoading ? 'Loading...' : '₹${currentPrice.toStringAsFixed(2)}/g',
                            style: TextStyle(
                              color: tp,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
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
                                  size: 12,
                                ),
                                Text(
                                  ' ${priceIsUp ? "+" : ""}₹${changeAmt.abs().toStringAsFixed(2)} (${priceIsUp ? "+" : ""}${changePct.toStringAsFixed(2)}% hike in ${_tabs[_tabIdx]})',
                                  style: TextStyle(
                                    color: chartGainColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'as on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: TextStyle(color: ts, fontSize: 11),
                                ),
                              ],
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    // Chart
                    Obx(() => _SpotPriceChart(
                          history: SilverController.to.priceHistory,
                          isLoading: SilverController.to.historyLoading.value,
                          themeColor: const Color(0xFF8A95A5),
                          bgColor: bg,
                          inkColor: tp,
                          inkMutedColor: ts,
                        )),
                    const SizedBox(height: 8),
                    // X-axis labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _xLabels
                          .map(
                            (l) => Text(
                              l,
                              style: TextStyle(color: ts, fontSize: 9),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),

              // ── Holdings ─────────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Holdings',
                      style: TextStyle(
                        color: tp,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Holding row
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: dark
                              ? const Color(0xFF0A0F1E)
                              : const Color(0xFFF8F5EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            // Silver icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8A95A5),
                                    Color(0xFFD4D9DE),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8A95A5,
                                    ).withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Au',
                                  style: TextStyle(
                                    color: Color(0xFF2A2E33),
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
                                    '999 (${99.99}% Purity)',
                                    style: TextStyle(
                                      color: tp,
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
                                          color: const Color(
                                            0xFF8A95A5,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Primary',
                                          style: TextStyle(
                                            color: Color(0xFF8A95A5),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${SilverController.to.totalGrams}g  ·  ₹${(SilverController.to.balance.value?.currentValue ?? 0).toStringAsFixed(2)}',
                                    style: TextStyle(color: ts, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: ts,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // View transactions
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.transactions),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: dark
                              ? const Color(0xFF0A0F1E)
                              : const Color(0xFFF8F5EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.3),
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
                                'View Transaction History',
                                style: TextStyle(
                                  color: tp,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: ts,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Silver SIP Banner ───────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1200), Color(0xFF2A2E33)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A95A5).withOpacity(0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.savings_outlined,
                      color: Color(0xFF8A95A5),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Silver SIP is the smart way to grow wealth',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Invest small, grow big. Start a SIP now.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.silverSip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A95A5), Color(0xFFD4D9DE)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A95A5).withOpacity(0.45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Start SIP',
                          style: TextStyle(
                            color: Color(0xFF2A2E33),
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

        // ── Bottom action bar ─────────────────────────────────────────────────
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.paddingOf(context).bottom + 12,
          ),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0E1626) : Colors.white,
            border: Border(
              top: BorderSide(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.buySilver),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A95A5), Color(0xFFD4D9DE)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A95A5).withOpacity(0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Buy More Silver',
                        style: TextStyle(
                          color: Color(0xFF2A2E33),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.sellSilver),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF3B82F6,
                      ).withOpacity(dark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.4),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Sell Silver',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
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

  List<String> get _xLabels {
    final labels = ['1M', '3M', '6M', '1Y'];
    if (_tabIdx == 0)
      return [
        '17 Jun',
        '24 Jun',
        '01 Jul',
        '08 Jul',
        '11 Jul',
        '14 Jul',
        '17 Jul',
      ];
    if (_tabIdx == 1) return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    if (_tabIdx == 2) return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    return ['Jul 24', 'Oct 24', 'Jan 25', 'Apr 25', 'Jul 25'];
  }
}

// ─── Silver Line Chart Painter ──────────────────────────────────────────────────
class _SilverChartPainter extends CustomPainter {
  const _SilverChartPainter({required this.data, required this.dark});
  final List<double> data;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final minV = data.reduce(min);
    final maxV = data.reduce(max);
    final range = (maxV - minV).clamp(1.0, double.infinity);

    List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height * (1 - (data[i] - minV) / range);
      pts.add(Offset(x, y));
    }

    // Fill gradient
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    fillPath.lineTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      fillPath.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8A95A5).withOpacity(0.35),
            const Color(0xFF8A95A5).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      linePath.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF8A95A5)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dot at last point
    canvas.drawCircle(pts.last, 6, Paint()..color = Colors.white);
    canvas.drawCircle(
      pts.last,
      6,
      Paint()
        ..color = const Color(0xFF8A95A5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      pts.last,
      10,
      Paint()..color = const Color(0xFF8A95A5).withOpacity(0.2),
    );

    // Grid lines (horizontal)
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = (dark ? Colors.white : Colors.black).withOpacity(0.05)
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SilverChartPainter old) => old.data != data;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _Stat extends StatelessWidget {
  const _Stat(this.val, this.lbl, this.color, this.dark);
  final String val, lbl;
  final Color color;
  final bool dark;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          val,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lbl,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280),
            fontSize: 9,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}

class _VDivider extends StatelessWidget {
  const _VDivider(this.dark);
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36,
    color: dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8),
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
        height: 140,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF8A95A5))),
      );
    }

    if (history.isEmpty) {
      return SizedBox(
        height: 140,
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
    final priceRange = maxPrice - minPrice;

    final yMin = minPrice - (priceRange * 0.05);
    final yMax = maxPrice + (priceRange * 0.05);

    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), prices[i]));
    }

    return SizedBox(
      height: 140,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
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
                    final dt = DateTime.parse(dateStr);
                    final formattedDate = "${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                    return LineTooltipItem(
                      '₹${spot.y.toStringAsFixed(2)}\n$formattedDate',
                      TextStyle(
                        color: inkColor,
                        fontSize: 10,
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
                    themeColor.withOpacity(0.22),
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
