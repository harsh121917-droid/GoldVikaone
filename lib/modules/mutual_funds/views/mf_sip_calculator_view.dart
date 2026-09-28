import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'mf_all_mutual_funds_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfSipCalculatorView extends StatefulWidget {
  final double? initialAmount;
  final double? initialRate;
  final int? initialYears;
  final bool initialIsSip;

  const MfSipCalculatorView({
    Key? key,
    this.initialAmount,
    this.initialRate,
    this.initialYears,
    this.initialIsSip = true,
  }) : super(key: key);

  @override
  State<MfSipCalculatorView> createState() => _MfSipCalculatorViewState();
}

class _MfSipCalculatorViewState extends State<MfSipCalculatorView> {
  late bool _isSip;
  late double _amount;
  late double _returnRate;
  late double _years;

  @override
  void initState() {
    super.initState();
    _isSip = widget.initialIsSip;
    _amount = widget.initialAmount ?? (_isSip ? 5000.0 : 25000.0);
    _returnRate = widget.initialRate ?? 15.0;
    _years = (widget.initialYears ?? 10).toDouble();
  }

  // ── Calculation Formulas ──
  double get _investedAmount {
    if (_isSip) {
      return _amount * (_years * 12);
    } else {
      return _amount;
    }
  }

  double get _totalValue {
    final r = _returnRate / 100;
    if (_isSip) {
      final i = r / 12;
      final n = _years * 12;
      if (i == 0) return _amount * n;
      return _amount * ((pow(1 + i, n) - 1) / i) * (1 + i);
    } else {
      return _amount * pow(1 + r, _years);
    }
  }

  double get _estReturns => max(0, _totalValue - _investedAmount);

  String _formatCurrency(double val) {
    if (val >= 10000000) {
      return '₹${(val / 10000000).toStringAsFixed(2)} Cr';
    } else if (val >= 100000) {
      return '₹${(val / 100000).toStringAsFixed(2)} Lakh';
    }
    return '₹${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String _formatExactNumber(double val) {
    final rounded = val.round();
    final s = rounded.toString();
    if (s.length <= 3) return '₹$s';
    final last3 = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final withCommas = rest.replaceAllMapped(RegExp(r'(\d{1,2})(?=(\d{2})+(?!\d))'), (m) => '${m[1]},');
    return '₹$withCommas,$last3';
  }

  @override
  Widget build(BuildContext context) {
    const bg = GrowwColors.background;
    const cardBg = GrowwColors.cardElevated;
    const border = GrowwColors.border;
    const mintGreen = GrowwColors.mintTeal;
    const textPrimary = GrowwColors.textPrimary;
    const textSecondary = GrowwColors.textSecondary;
    const investedColor = Color(0xFF3B82F6); // Blue

    final invested = _investedAmount;
    final returns = _estReturns;
    final total = _totalValue;
    final returnPct = invested > 0 ? (returns / total) * 100 : 0.0;
    final investedPct = invested > 0 ? (invested / total) * 100 : 0.0;
    final multiplier = invested > 0 ? (total / invested) : 1.0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SIP Calculator',
          style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: textSecondary),
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                _amount = _isSip ? 5000.0 : 25000.0;
                _returnRate = 15.0;
                _years = 10.0;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SIP / One-time Toggle ──
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!_isSip) {
                          setState(() {
                            _isSip = true;
                            _amount = 5000;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSip ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: _isSip ? Border.all(color: mintGreen.withOpacity(0.5)) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Monthly SIP',
                          style: TextStyle(
                            color: _isSip ? Colors.white : textSecondary,
                            fontWeight: _isSip ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_isSip) {
                          setState(() {
                            _isSip = false;
                            _amount = 25000;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isSip ? const Color(0xFF1E293B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: !_isSip ? Border.all(color: mintGreen.withOpacity(0.5)) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'One-Time (Lumpsum)',
                          style: TextStyle(
                            color: !_isSip ? Colors.white : textSecondary,
                            fontWeight: !_isSip ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Slider 1: Investment Amount ──
            _buildSliderCard(
              title: _isSip ? 'Monthly investment' : 'Total investment',
              valueText: _formatExactNumber(_amount),
              min: _isSip ? 500 : 5000,
              max: _isSip ? 100000 : 1000000,
              divisions: _isSip ? 199 : 199,
              currentValue: _amount.clamp(_isSip ? 500 : 5000, _isSip ? 100000 : 1000000),
              onChanged: (v) => setState(() => _amount = (v / 500).round() * 500.0),
              quickChips: _isSip
                  ? [
                      {'label': '+₹1,000', 'add': 1000.0},
                      {'label': '+₹5,000', 'add': 5000.0},
                      {'label': '+₹10,000', 'add': 10000.0},
                    ]
                  : [
                      {'label': '+₹10,000', 'add': 10000.0},
                      {'label': '+₹50,000', 'add': 50000.0},
                      {'label': '+₹1,00,000', 'add': 100000.0},
                    ],
              onChipTap: (add) => setState(() {
                final maxV = _isSip ? 100000.0 : 1000000.0;
                _amount = min(maxV, _amount + add);
              }),
            ),
            const SizedBox(height: 16),

            // ── Slider 2: Expected Return Rate ──
            _buildSliderCard(
              title: 'Expected annual return rate',
              valueText: '${_returnRate.toStringAsFixed(1)}% p.a.',
              min: 1.0,
              max: 30.0,
              divisions: 58,
              currentValue: _returnRate.clamp(1.0, 30.0),
              onChanged: (v) => setState(() => _returnRate = ((v * 2).round() / 2)),
              quickChips: [
                {'label': '12% (Nifty 50)', 'set': 12.0},
                {'label': '15% (Midcap)', 'set': 15.0},
                {'label': '18% (Smallcap)', 'set': 18.0},
              ],
              onChipTap: (val) => setState(() => _returnRate = val),
              isSetAction: true,
            ),
            const SizedBox(height: 16),

            // ── Slider 3: Time Period ──
            _buildSliderCard(
              title: 'Time period',
              valueText: '${_years.toInt()} ${_years == 1 ? "Year" : "Years"}',
              min: 1.0,
              max: 30.0,
              divisions: 29,
              currentValue: _years.clamp(1.0, 30.0),
              onChanged: (v) => setState(() => _years = v.roundToDouble()),
              quickChips: [
                {'label': '3 Yrs', 'set': 3.0},
                {'label': '5 Yrs', 'set': 5.0},
                {'label': '10 Yrs', 'set': 10.0},
                {'label': '15 Yrs', 'set': 15.0},
              ],
              onChipTap: (val) => setState(() => _years = val),
              isSetAction: true,
            ),
            const SizedBox(height: 24),

            // ── Visual Donut/Pie Chart & Results Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Growth Multiplier Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: mintGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: mintGreen.withOpacity(0.3)),
                    ),
                    child: Text(
                      '✨ Your money grows ${multiplier.toStringAsFixed(1)}x in ${_years.toInt()} years!',
                      style: const TextStyle(color: mintGreen, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Donut Pie Chart ──
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(190, 190),
                          painter: _DonutChartPainter(
                            investedPct: investedPct / 100,
                            returnsPct: returnPct / 100,
                            investedColor: investedColor,
                            returnsColor: mintGreen,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Total Value',
                              style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(total),
                              style: const TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Legend Breakdown ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Invested amount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: investedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Invested amount', style: TextStyle(color: textSecondary, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatExactNumber(invested),
                            style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(${investedPct.toStringAsFixed(1)}%)',
                            style: const TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                      // Est. Returns
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: mintGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('Est. returns', style: TextStyle(color: textSecondary, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _formatExactNumber(returns),
                            style: const TextStyle(color: mintGreen, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(${returnPct.toStringAsFixed(1)}%)',
                            style: const TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Explore Funds CTA ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const MfAllMutualFundsView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintGreen,
                  foregroundColor: const Color(0xFF0F141E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Explore Top Mutual Funds',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueText,
    required double min,
    required double max,
    required int divisions,
    required double currentValue,
    required ValueChanged<double> onChanged,
    required List<Map<String, dynamic>> quickChips,
    required ValueChanged<double> onChipTap,
    bool isSetAction = false,
  }) {
    const cardBg = GrowwColors.cardElevated;
    const border = GrowwColors.border;
    const mintGreen = GrowwColors.mintTeal;
    const textPrimary = GrowwColors.textPrimary;
    const textSecondary = GrowwColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2533),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Text(
                  valueText,
                  style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: mintGreen,
              inactiveTrackColor: const Color(0xFF1E2533),
              thumbColor: mintGreen,
              overlayColor: mintGreen.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: currentValue,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: quickChips.map((c) {
              final label = c['label']?.toString() ?? '';
              final val = (isSetAction ? c['set'] : c['add']) as double;
              return GestureDetector(
                onTap: () => onChipTap(val),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E2E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF243046)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Custom Donut Chart Painter ──
class _DonutChartPainter extends CustomPainter {
  final double investedPct;
  final double returnsPct;
  final Color investedColor;
  final Color returnsColor;

  _DonutChartPainter({
    required this.investedPct,
    required this.returnsPct,
    required this.investedColor,
    required this.returnsColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;

    final paintBg = Paint()
      ..color = const Color(0xFF1E2533)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, paintBg);

    if (investedPct <= 0 && returnsPct <= 0) return;

    // Start from top (-pi / 2)
    double startAngle = -pi / 2;

    // Invested Arc
    if (investedPct > 0) {
      final sweepAngle = 2 * pi * investedPct;
      final investedPaint = Paint()
        ..color = investedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        investedPaint,
      );
      startAngle += sweepAngle;
    }

    // Returns Arc
    if (returnsPct > 0) {
      final sweepAngle = 2 * pi * returnsPct;
      final returnsPaint = Paint()
        ..color = returnsColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        returnsPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.investedPct != investedPct ||
        oldDelegate.returnsPct != returnsPct ||
        oldDelegate.investedColor != investedColor ||
        oldDelegate.returnsColor != returnsColor;
  }
}
