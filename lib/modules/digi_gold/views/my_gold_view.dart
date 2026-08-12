import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vika1/routes/app_routes.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _success = Color(0xFF2ecc71);
const _danger = Color(0xFFE05A47);
const _purple = Color(0xFFAB47BC);

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

class MyGoldView extends StatefulWidget {
  const MyGoldView({super.key});
  @override
  State<MyGoldView> createState() => _MyGoldViewState();
}

class _MyGoldViewState extends State<MyGoldView> {
  int _periodIdx = 2; // Default to 1M
  static const _periods = ['1D', '1W', '1M', '1Y', '3Y', '5Y'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);
      final bal = GoldController.to.balance.value;
      final gain = bal?.gainLoss ?? 0;
      final isUp = gain >= 0;
      final gainColor = isUp ? _success : _danger;

      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────
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
                            'My Gold',
                            style: TextStyle(
                              color: t.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Track your gold holdings and growth',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.cardBorder),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: t.ink,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: t.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.cardBorder),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: t.ink,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Hero card ─────────────────────────────────────────
                Container(
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: t.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.15 : 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total Gold',
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.visibility_outlined,
                                  color: t.inkMuted.withOpacity(0.7),
                                  size: 14,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  GoldController.to.totalGrams.toStringAsFixed(
                                    4,
                                  ),
                                  style: TextStyle(
                                    color: t.primary,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    'g',
                                    style: TextStyle(
                                      color: _gold,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Current Value  ₹${(bal?.currentValue ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(color: t.inkMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: gainColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isUp
                                        ? Icons.trending_up_rounded
                                        : Icons.trending_down_rounded,
                                    color: gainColor,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '₹${gain.abs().toStringAsFixed(2)} (${(bal?.gainLossPct ?? 0).abs().toStringAsFixed(2)}%)',
                                    style: TextStyle(
                                      color: gainColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'since last purchase',
                              style: TextStyle(color: t.inkMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Image.asset(
                          'assets/images/jar_img.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Stats row ─────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: t.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.12 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _stat(
                        '${GoldController.to.totalGrams.toStringAsFixed(4)}g',
                        'Available Gold',
                        _gold,
                        Icons.savings_outlined,
                        t,
                      ),
                      _vd(t),
                      _stat(
                        '₹${(bal?.investedAmt ?? 0).toStringAsFixed(0)}',
                        'Invested Amount',
                        _success,
                        Icons.account_balance_wallet_outlined,
                        t,
                      ),
                      _vd(t),
                      _stat(
                        '${isUp ? '+' : '-'}₹${gain.abs().toStringAsFixed(0)}\n${(bal?.gainLossPct ?? 0).toStringAsFixed(2)}%',
                        'Gain / Loss',
                        gainColor,
                        isUp
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        t,
                      ),
                      _vd(t),
                      _stat(
                        '₹${(bal?.avgBuyRate ?? 0).toStringAsFixed(0)}/g',
                        'Avg Buy Price',
                        _purple,
                        Icons.sell_outlined,
                        t,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Gold Value chart ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: t.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.12 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Gold Value',
                                style: TextStyle(
                                  color: t.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.info_outline_rounded,
                                color: t.inkMuted,
                                size: 14,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: t.subBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: List.generate(_periods.length, (i) {
                                final active = i == _periodIdx;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _periodIdx = i);
                                    GoldController.to.loadPriceHistory(_periods[i].toLowerCase());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? _gold.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _periods[i],
                                      style: TextStyle(
                                        color: active ? _gold : t.inkMuted,
                                        fontSize: 10,
                                        fontWeight: active
                                            ? FontWeight.w800
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        final history = GoldController.to.priceHistory;
                        final isLoading = GoldController.to.historyLoading.value;
                        
                        double currentPrice = GoldController.to.rate.value?.buyRate ?? 0.0;
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
                        
                        final chartGainColor = priceIsUp ? _success : _danger;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoading ? 'Loading...' : '₹${currentPrice.toStringAsFixed(2)}/g',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 24,
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
                                    ' ${priceIsUp ? "+" : ""}₹${changeAmt.abs().toStringAsFixed(2)} (${priceIsUp ? "+" : ""}${changePct.toStringAsFixed(2)}% hike in ${_periods[_periodIdx]})',
                                    style: TextStyle(
                                      color: chartGainColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'as on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                    style: TextStyle(color: t.inkMuted, fontSize: 10),
                                  ),
                                ],
                              ),
                          ],
                        );
                      }),
                      const SizedBox(height: 12),
                      Obx(() => _SpotPriceChart(
                            history: GoldController.to.priceHistory,
                            isLoading: GoldController.to.historyLoading.value,
                            themeColor: _gold,
                            t: t,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Your Holdings ──────────────────────────────────────
                Text(
                  'Your Holdings',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _gold,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Center(
                          child: Text(
                            'Au',
                            style: TextStyle(
                              color: Color(0xFF3D2B00),
                              fontSize: 14,
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
                            Row(
                              children: [
                                Text(
                                  '24K (99.99% Purity)',
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Primary',
                                    style: TextStyle(
                                      color: _success,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${GoldController.to.totalGrams.toStringAsFixed(6)}g · ₹${(bal?.currentValue ?? 0).toStringAsFixed(2)}',
                              style: TextStyle(color: t.inkMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: t.inkMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.transactions),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: t.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: t.subBg,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            color: t.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'View Transaction History',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: t.inkMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── SIP promo ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(dark ? 0.10 : 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _gold.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.show_chart_rounded,
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
                              'Gold SIP is the smart way to grow wealth',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Invest small, grow big. Start a SIP now.',
                              style: TextStyle(
                                color: t.inkMuted,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.digiGoldSavings),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: t.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Start SIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Bottom actions ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.buyGold),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_gold, _goldLight],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_rounded,
                                  color: Color(0xFF3D2B00),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Buy More Gold',
                                  style: TextStyle(
                                    color: Color(0xFF3D2B00),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.sellGold),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: t.primary, width: 1.5),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  color: t.primary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Sell Gold',
                                  style: TextStyle(
                                    color: t.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _stat(String value, String label, Color color, IconData icon, _T t) =>
      Expanded(
        child: Column(
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkMuted, fontSize: 9),
            ),
            const SizedBox(height: 6),
            Icon(icon, color: color.withOpacity(0.6), size: 14),
          ],
        ),
      );

  Widget _vd(_T t) =>
      Container(width: 1, height: 46, color: t.inkMuted.withOpacity(0.15));
}

// ─── Growth chart — plotted from REAL transaction history, never fabricated ──
class _GrowthChart extends StatelessWidget {
  const _GrowthChart({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    final txns = GoldController.to.transactions.reversed
        .toList(); // oldest → newest
    if (txns.length < 2) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.subBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Buy gold a couple more times to see your growth chart',
          textAlign: TextAlign.center,
          style: TextStyle(color: t.inkMuted, fontSize: 12),
        ),
      );
    }

    // Real cumulative-grams-at-each-purchase-rate, not a fabricated trend line.
    double cumulative = 0;
    final points = <double>[];
    for (final tx in txns) {
      cumulative += tx.isBuy ? tx.grams : -tx.grams;
      points.add(cumulative * tx.ratePerGram);
    }

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(points: points, color: _gold),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter({required this.points, required this.color});
  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final path = Path();
    final fillPath = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y =
          size.height -
          ((points[i] - minV) / range) * size.height * 0.85 -
          size.height * 0.05;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.25), color.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    final lastX = size.width;
    final lastY =
        size.height -
        ((points.last - minV) / range) * size.height * 0.85 -
        size.height * 0.05;
    canvas.drawCircle(Offset(lastX, lastY), 5, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(lastX, lastY),
      5,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.points != points;
}

class _SpotPriceChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final bool isLoading;
  final Color themeColor;
  final _T t;

  const _SpotPriceChart({
    required this.history,
    required this.isLoading,
    required this.themeColor,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }

    if (history.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No price data available.',
            style: TextStyle(color: t.inkMuted, fontSize: 12),
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
              getTooltipColor: (spot) => t.bg.withOpacity(0.95),
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
                        color: t.ink,
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
