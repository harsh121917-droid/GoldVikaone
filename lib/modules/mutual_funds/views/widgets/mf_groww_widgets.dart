import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../data/models/mf_scheme_model.dart';

/// Design tokens inspired by Groww's signature dark UI
class GrowwColors {
  static const Color mintTeal = Color(0xFF00D09C);
  static const Color mintTealLight = Color(0xFF00E5AC);
  static const Color mintTealGlow = Color(0x3300D09C);
  static const Color background = Color(0xFF0B0E14);
  static const Color card = Color(0xFF131722);
  static const Color cardElevated = Color(0xFF181E2C);
  static const Color border = Color(0xFF222938);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color negativeRed = Color(0xFFEF4444);
  static const Color goldAccent = Color(0xFFF5A623);
}

/// Resolves real AMC logos from assets or renders authentic SVG/Vector monograms
class AmcBrandLogo extends StatelessWidget {
  final String amcName;
  final String? schemeName;
  final double size;
  final double borderRadius;

  const AmcBrandLogo({
    Key? key,
    required this.amcName,
    this.schemeName,
    this.size = 40,
    this.borderRadius = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lowerAmc = amcName.toLowerCase();
    final lowerScheme = (schemeName ?? '').toLowerCase();

    // Map known AMCs to local asset images
    String? assetPath;
    if (lowerAmc.contains('hdfc') || lowerScheme.contains('hdfc')) {
      assetPath = 'assets/images/Mutual_Funds/mf_amc_hdfc.jpg';
    } else if (lowerAmc.contains('nippon') || lowerScheme.contains('nippon')) {
      assetPath = 'assets/images/Mutual_Funds/mf_amc_nippon.jpg';
    } else if (lowerAmc.contains('parag') || lowerScheme.contains('parag') || lowerAmc.contains('ppfas')) {
      assetPath = 'assets/images/Mutual_Funds/mf_amc_parag_parikh.jpg';
    } else if (lowerAmc.contains('bandhan') || lowerScheme.contains('bandhan')) {
      assetPath = 'assets/images/Mutual_Funds/mf_amc_bandhan.jpg';
    } else if (lowerAmc.contains('sbi') || lowerScheme.contains('sbi')) {
      assetPath = 'assets/images/Mutual_Funds/sbi_mutual.jfif';
    } else if (lowerAmc.contains('icici') || lowerScheme.contains('icici')) {
      assetPath = 'assets/images/Mutual_Funds/icici_mutual.jpg';
    } else if (lowerAmc.contains('motilal') || lowerScheme.contains('motilal')) {
      assetPath = 'assets/images/Mutual_Funds/motilal_oswal_mutual.png';
    } else if (lowerAmc.contains('birla') || lowerAmc.contains('aditya') || lowerScheme.contains('birla')) {
      assetPath = 'assets/images/Mutual_Funds/adiya_bilra_mutual.png';
    } else if (lowerAmc.contains('uti') || lowerScheme.contains('uti')) {
      assetPath = 'assets/images/Mutual_Funds/uti_mutual.jpeg';
    } else if (lowerAmc.contains('dsp') || lowerScheme.contains('dsp')) {
      assetPath = 'assets/images/Mutual_Funds/dsp_mutual.png';
    } else if (lowerAmc.contains('edelweiss') || lowerScheme.contains('edelweiss')) {
      assetPath = 'assets/images/Mutual_Funds/edelweiss_mutual.png';
    }

    if (assetPath != null) {
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildVectorFallback(lowerAmc, lowerScheme),
        ),
      );
    }

    return _buildVectorFallback(lowerAmc, lowerScheme);
  }

  Widget _buildVectorFallback(String lowerAmc, String lowerScheme) {
    Color bg = const Color(0xFF1E293B);
    Color fg = Colors.white;
    Widget iconWidget;

    if (lowerAmc.contains('parag') || lowerScheme.contains('parag')) {
      // Parag Parikh turtle theme
      bg = Colors.white;
      iconWidget = const Text('🐢', style: TextStyle(fontSize: 20));
    } else if (lowerAmc.contains('hdfc') || lowerScheme.contains('hdfc')) {
      bg = const Color(0xFFD6182B);
      iconWidget = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF003D7A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('HDFC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
      );
    } else if (lowerAmc.contains('bandhan') || lowerScheme.contains('bandhan')) {
      bg = const Color(0xFFF97316);
      iconWidget = const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 22);
    } else if (lowerAmc.contains('nippon') || lowerScheme.contains('nippon')) {
      bg = const Color(0xFFDC2626);
      iconWidget = const Icon(Icons.change_history_rounded, color: Colors.white, size: 22);
    } else if (lowerAmc.contains('axis') || lowerScheme.contains('axis')) {
      bg = const Color(0xFF9E1B46);
      iconWidget = const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 20);
    } else if (lowerAmc.contains('quant') || lowerScheme.contains('quant')) {
      bg = const Color(0xFF2563EB);
      iconWidget = const Text('Q', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20));
    } else if (lowerAmc.contains('gold') || lowerScheme.contains('gold')) {
      bg = const Color(0xFFD4AF37);
      iconWidget = const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 22);
    } else {
      bg = const Color(0xFF334155);
      final initials = amcName.isNotEmpty ? amcName.substring(0, min(2, amcName.length)).toUpperCase() : 'MF';
      iconWidget = Text(
        initials,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: size * 0.35),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: iconWidget,
    );
  }
}

/// Interactive Groww-style SIP Wealth Calculator Modal
class MfSipCalculatorSheet extends StatefulWidget {
  const MfSipCalculatorSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MfSipCalculatorSheet(),
    );
  }

  @override
  State<MfSipCalculatorSheet> createState() => _MfSipCalculatorSheetState();
}

class _MfSipCalculatorSheetState extends State<MfSipCalculatorSheet> {
  double _monthlySip = 5000;
  double _expectedReturn = 14.0;
  double _years = 10;

  // SIP formula: M * [ (1 + i)^n - 1 ] / i * (1 + i)
  double get _totalInvested => _monthlySip * _years * 12;

  double get _futureValue {
    final i = (_expectedReturn / 100) / 12;
    final n = _years * 12;
    if (i == 0) return _totalInvested;
    return _monthlySip * ((pow(1 + i, n) - 1) / i) * (1 + i);
  }

  double get _estReturns => max(0, _futureValue - _totalInvested);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? GrowwColors.card : Colors.white;
    final textPrimary = dark ? GrowwColors.textPrimary : const Color(0xFF1E293B);
    final textSecondary = dark ? GrowwColors.textSecondary : const Color(0xFF64748B);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: GrowwColors.mintTeal.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calculate_rounded, color: GrowwColors.mintTeal, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SIP Calculator',
                      style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Monthly Investment Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Investment', style: TextStyle(color: textSecondary, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GrowwColors.mintTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '₹${_monthlySip.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: const TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _monthlySip,
                    min: 500,
                    max: 100000,
                    divisions: 199,
                    activeColor: GrowwColors.mintTeal,
                    inactiveColor: dark ? GrowwColors.border : Colors.grey[300],
                    onChanged: (v) => setState(() => _monthlySip = v),
                  ),
                  const SizedBox(height: 18),

                  // 2. Expected Return Rate Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Expected Return Rate (p.a.)', style: TextStyle(color: textSecondary, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GrowwColors.mintTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_expectedReturn.toStringAsFixed(1)}%',
                          style: const TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _expectedReturn,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: GrowwColors.mintTeal,
                    inactiveColor: dark ? GrowwColors.border : Colors.grey[300],
                    onChanged: (v) => setState(() => _expectedReturn = v),
                  ),
                  const SizedBox(height: 18),

                  // 3. Time Period Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time Period', style: TextStyle(color: textSecondary, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GrowwColors.mintTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_years.toInt()} Years',
                          style: const TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _years,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: GrowwColors.mintTeal,
                    inactiveColor: dark ? GrowwColors.border : Colors.grey[300],
                    onChanged: (v) => setState(() => _years = v),
                  ),
                  const SizedBox(height: 24),

                  // ── Wealth Summary Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: dark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: GrowwColors.mintTeal.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('Estimated Future Wealth', style: TextStyle(color: textSecondary, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          '₹${_futureValue.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF64748B), shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Invested Amount', style: TextStyle(color: textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${_totalInvested.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                  style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: GrowwColors.mintTeal, shape: BoxShape.circle)),
                                    const SizedBox(width: 6),
                                    Text('Est. Returns', style: TextStyle(color: textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+₹${_estReturns.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                  style: const TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GrowwColors.mintTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: const Text('Explore SIP Plans', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal for comparing 2 mutual funds
class MfCompareModal extends StatelessWidget {
  final List<MfSchemeModel> schemes;

  const MfCompareModal({Key? key, required this.schemes}) : super(key: key);

  static void show(BuildContext context, List<MfSchemeModel> schemes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MfCompareModal(schemes: schemes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? GrowwColors.card : Colors.white;
    final textPrimary = dark ? GrowwColors.textPrimary : const Color(0xFF1E293B);
    final textSecondary = dark ? GrowwColors.textSecondary : const Color(0xFF64748B);

    final f1 = schemes.isNotEmpty ? schemes[0] : null;
    final f2 = schemes.length > 1 ? schemes[1] : (schemes.isNotEmpty ? schemes[0] : null);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Compare Funds', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (f1 != null && f2 != null) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmcBrandLogo(amcName: f1.amcName, schemeName: f1.schemeName, size: 36),
                      const SizedBox(height: 8),
                      Text(f1.schemeName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
                    ],
                  ),
                ),
                Container(width: 1, height: 80, color: GrowwColors.border),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AmcBrandLogo(amcName: f2.amcName, schemeName: f2.schemeName, size: 36),
                      const SizedBox(height: 8),
                      Text(f2.schemeName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildRow('3Y Returns', '+${f1.cagr3Y}%', '+${f2.cagr3Y}%', textPrimary, textSecondary, isHighlight: true),
            _buildRow('1Y Returns', '+${f1.cagr1Y}%', '+${f2.cagr1Y}%', textPrimary, textSecondary),
            _buildRow('Min. SIP', '₹${f1.minSipAmount.toInt()}', '₹${f2.minSipAmount.toInt()}', textPrimary, textSecondary),
            _buildRow('Expense Ratio', '${f1.expenseRatio}%', '${f2.expenseRatio}%', textPrimary, textSecondary),
            _buildRow('Rating', '${f1.rating} ★', '${f2.rating} ★', textPrimary, textSecondary),
            _buildRow('Risk Level', f1.riskLevel, f2.riskLevel, textPrimary, textSecondary),
          ] else ...[
            Center(
              child: Text('Add funds to compare', style: TextStyle(color: textSecondary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String v1, String v2, Color textPrimary, Color textSecondary, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              v1,
              style: TextStyle(
                color: isHighlight ? GrowwColors.mintTeal : textPrimary,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          Text(label, style: TextStyle(color: textSecondary, fontSize: 12)),
          Expanded(
            child: Text(
              v2,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isHighlight ? GrowwColors.mintTeal : textPrimary,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// NFOs Modal
class MfNfoSheet extends StatelessWidget {
  const MfNfoSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const MfNfoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? GrowwColors.card : Colors.white;
    final textPrimary = dark ? GrowwColors.textPrimary : const Color(0xFF1E293B);
    final textSecondary = dark ? GrowwColors.textSecondary : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GrowwColors.mintTeal.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_rounded, color: GrowwColors.mintTeal, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text('New Fund Offers (NFOs)', style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNfoItem(
            'SBI Energy Opportunities Fund',
            'Equity Thematic · Closing in 4 days',
            '₹10.00 NAV',
            textPrimary,
            textSecondary,
          ),
          const SizedBox(height: 12),
          _buildNfoItem(
            'HDFC Defence Fund - Direct Plan',
            'Equity Thematic · Closing in 7 days',
            '₹10.00 NAV',
            textPrimary,
            textSecondary,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNfoItem(String title, String subtitle, String nav, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GrowwColors.cardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: GrowwColors.mintTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(nav, style: const TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
