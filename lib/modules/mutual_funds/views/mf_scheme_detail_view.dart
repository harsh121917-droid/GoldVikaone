import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_sip_investment_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfSchemeDetailView extends StatefulWidget {
  final MfSchemeModel scheme;

  const MfSchemeDetailView({Key? key, required this.scheme}) : super(key: key);

  @override
  State<MfSchemeDetailView> createState() => _MfSchemeDetailViewState();
}

class _MfSchemeDetailViewState extends State<MfSchemeDetailView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();

  // Period selector: '1M', '6M', '1Y', '3Y', '5Y', 'All'
  String _selectedPeriod = '3Y';
  bool _isBookmarked = false;
  bool _isAnnualised = true;

  // Calculator states (Screenshot 3)
  bool _isCalculatorSip = false; // default 'One-time' as in screenshot
  double _calculatorAmount = 20000;
  String _calculatorPeriod = '3Y'; // '6M', '1Y', '3Y', '5Y'

  // Accordion expansion states
  bool _isReturnsExpanded = true;
  bool _isHoldingsExpanded = true;
  bool _isCalculatorExpanded = true;
  bool _isSimilarFundsExpanded = true;
  bool _isProsConsExpanded = true; // Screenshot 4
  bool _isExpenseRatioExpanded = true; // Screenshot 2
  bool _isFundManagementExpanded = true; // Screenshot 3
  bool _isFundHouseExpanded = true; // Screenshot 3

  // Expanded manager cards inside Fund Management
  final Set<String> _expandedManagers = {};

  @override
  void initState() {
    super.initState();
    _isBookmarked = controller.watchlistSchemeCodes.contains(widget.scheme.schemeCode);

    // Track in recently viewed
    if (!controller.recentlyViewed.any((s) => s.schemeCode == widget.scheme.schemeCode)) {
      controller.recentlyViewed.insert(0, widget.scheme);
    }
  }

  double get _currentReturn {
    switch (_selectedPeriod) {
      case '1M':
        return 2.15;
      case '6M':
        return 12.80;
      case '1Y':
        return widget.scheme.cagr1Y;
      case '3Y':
        return widget.scheme.cagr3Y;
      case '5Y':
        return widget.scheme.cagr5Y;
      case 'All':
        return 30.40;
      default:
        return widget.scheme.cagr3Y;
    }
  }

  String _formatIndianCurrency(num value) {
    int n = value.toInt();
    if (n < 1000) return n.toString();
    String s = n.toString();
    String lastThree = s.substring(s.length - 3);
    String otherNumbers = s.substring(0, s.length - 3);
    if (otherNumbers.isNotEmpty) {
      otherNumbers = otherNumbers.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$otherNumbers,$lastThree';
    }
    return lastThree;
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      if (_isBookmarked) {
        if (!controller.watchlistSchemeCodes.contains(widget.scheme.schemeCode)) {
          controller.watchlistSchemeCodes.add(widget.scheme.schemeCode);
        }
      } else {
        controller.watchlistSchemeCodes.remove(widget.scheme.schemeCode);
      }
    });

    Get.snackbar(
      _isBookmarked ? 'Added to Watchlist' : 'Removed from Watchlist',
      widget.scheme.schemeName,
      backgroundColor: const Color(0xFF00D09C),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A0D14);
    const surface = Color(0xFF121620);
    const border = Color(0xFF1E2533);
    const textPrimary = Color(0xFFF1F5F9);
    const textSecondary = Color(0xFF8B949E);
    const mintGreen = Color(0xFF00D09C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.scheme.schemeName,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${_currentReturn >= 0 ? "+" : ""}${_currentReturn.toStringAsFixed(2)}%',
                  style: const TextStyle(color: mintGreen, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' • $_selectedPeriod',
                  style: const TextStyle(color: textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? mintGreen : Colors.white,
              size: 22,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Scheme Info & Hero Return (Screenshot 4) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AmcBrandLogo(
                    amcName: widget.scheme.amcName,
                    schemeName: widget.scheme.schemeName,
                    size: 46,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.scheme.schemeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.scheme.riskLevel} • ${widget.scheme.category} • ${widget.scheme.subCategory.isNotEmpty ? widget.scheme.subCategory : "Direct Growth"}',
                    style: const TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),

                  // Big Return Display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_currentReturn.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: mintGreen,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_selectedPeriod annualised',
                        style: const TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.arrow_drop_up_rounded, color: mintGreen, size: 18),
                      Text(
                        '+1.08% 1D',
                        style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Interactive NAV Historical Graph (Screenshot 4) ──
            SizedBox(
              height: 170,
              width: double.infinity,
              child: CustomPaint(
                painter: _NavChartPainter(period: _selectedPeriod),
              ),
            ),

            // Timeframe Selector Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['1M', '6M', '1Y', '3Y', '5Y', 'All'].map((p) {
                  final isSel = _selectedPeriod == p;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? mintGreen.withOpacity(0.18) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSel ? mintGreen.withOpacity(0.5) : Colors.transparent),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          color: isSel ? mintGreen : textSecondary,
                          fontSize: 13,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // ── 2x2 Fund Metrics Grid (Screenshot 4) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMetricItem('NAV: 18 Sep \'26', '₹${widget.scheme.nav.toStringAsFixed(2)}', textSecondary, textPrimary)),
                      Expanded(child: _buildMetricItem('Rating', '${widget.scheme.rating} ★', textSecondary, textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _buildMetricItem('Min. SIP amount', '₹${widget.scheme.minSipAmount.toInt()}', textSecondary, textPrimary)),
                      Expanded(child: _buildMetricItem('Fund size', '₹${widget.scheme.aum.toInt()} Cr', textSecondary, textPrimary)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(color: border, height: 1),

            // ── Top Action Links (Screenshot 1) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isHoldingsExpanded = true),
                    child: const Text(
                      'See all holdings',
                      style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isHoldingsExpanded = true),
                    child: const Row(
                      children: [
                        Text(
                          'Holdings analysis',
                          style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.pie_chart_outline_rounded, color: mintGreen, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: border, height: 1),

            // ── ACCORDION 1: Returns & rankings (Screenshot 1) ──
            _buildAccordionHeader(
              title: 'Returns & rankings',
              isExpanded: _isReturnsExpanded,
              onTap: () => setState(() => _isReturnsExpanded = !_isReturnsExpanded),
            ),
            if (_isReturnsExpanded) _buildReturnsAndRankingsSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── ACCORDION 2: Holdings (Screenshot 2) ──
            _buildAccordionHeader(
              title: 'Holdings (264)',
              isExpanded: _isHoldingsExpanded,
              onTap: () => setState(() => _isHoldingsExpanded = !_isHoldingsExpanded),
            ),
            if (_isHoldingsExpanded) _buildHoldingsSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── ACCORDION 3: Return calculator (Screenshot 3) ──
            _buildAccordionHeader(
              title: 'Return calculator',
              isExpanded: _isCalculatorExpanded,
              onTap: () => setState(() => _isCalculatorExpanded = !_isCalculatorExpanded),
            ),
            if (_isCalculatorExpanded) _buildReturnCalculatorSection(mintGreen, textSecondary, textPrimary, surface, border),
            const Divider(color: border, height: 1),

            // ── ACCORDION 4: Similar funds (Screenshot 5) ──
            _buildAccordionHeader(
              title: 'Similar funds',
              isExpanded: _isSimilarFundsExpanded,
              onTap: () => setState(() => _isSimilarFundsExpanded = !_isSimilarFundsExpanded),
            ),
            if (_isSimilarFundsExpanded) _buildSimilarFundsSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── ACCORDION 5: Expense ratio, exit load & tax (Screenshot 2) ──
            _buildAccordionHeader(
              title: 'Expense ratio, exit load & tax',
              isExpanded: _isExpenseRatioExpanded,
              onTap: () => setState(() => _isExpenseRatioExpanded = !_isExpenseRatioExpanded),
            ),
            if (_isExpenseRatioExpanded) _buildExpenseRatioSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── ACCORDION 6: Fund management (Screenshot 3) ──
            _buildAccordionHeader(
              title: 'Fund management',
              isExpanded: _isFundManagementExpanded,
              onTap: () => setState(() => _isFundManagementExpanded = !_isFundManagementExpanded),
            ),
            if (_isFundManagementExpanded) _buildFundManagementSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── ACCORDION 7: Fund house & investment objective (Screenshot 3) ──
            _buildAccordionHeader(
              title: 'Fund house & investment objective',
              isExpanded: _isFundHouseExpanded,
              onTap: () => setState(() => _isFundHouseExpanded = !_isFundHouseExpanded),
            ),
            if (_isFundHouseExpanded) _buildFundHouseSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── ACCORDION 8: Pros and cons (Screenshot 4) ──
            _buildAccordionHeader(
              title: 'Pros and cons',
              isExpanded: _isProsConsExpanded,
              onTap: () => setState(() => _isProsConsExpanded = !_isProsConsExpanded),
            ),
            if (_isProsConsExpanded) _buildProsConsSection(mintGreen, textSecondary, textPrimary),
            const Divider(color: border, height: 1),

            // ── Recently Viewed Section (Screenshot 5) ──
            _buildRecentlyViewedSection(mintGreen, textSecondary, textPrimary),

            const SizedBox(height: 120), // Spacing for sticky bottom bar
          ],
        ),
      ),

      // ── Fixed Sticky Bottom Bar (Screenshots 1 - 5) ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: const Border(top: BorderSide(color: border, width: 1)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Get.to(() => MfSipInvestmentView(scheme: widget.scheme, isSip: false)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFF13221E),
                      side: const BorderSide(color: Color(0xFF1C3A30), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'One-time',
                      style: TextStyle(color: mintGreen, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => MfSipInvestmentView(scheme: widget.scheme, isSip: true)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mintGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Start SIP',
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color textSecondary, Color textPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAccordionHeader({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: Colors.white70,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ── SECTION 1: Returns & rankings (Screenshot 1) ──
  Widget _buildReturnsAndRankingsSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category: ${widget.scheme.category} ${widget.scheme.subCategory}',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              GestureDetector(
                onTap: () => setState(() => _isAnnualised = !_isAnnualised),
                child: Row(
                  children: [
                    Text(
                      _isAnnualised ? 'Annualised' : 'Absolute',
                      style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.unfold_more_rounded, color: mintGreen, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(flex: 3, child: SizedBox()),
              _buildTableHeaderCell('1Y', textSecondary),
              _buildTableHeaderCell('3Y', textSecondary),
              _buildTableHeaderCell('5Y', textSecondary),
              _buildTableHeaderCell('ALL', textSecondary),
            ],
          ),
          const SizedBox(height: 12),

          _buildTableRow(
            'Fund returns (%)',
            ['${widget.scheme.cagr1Y.toStringAsFixed(1)}', '${widget.scheme.cagr3Y.toStringAsFixed(1)}', '${widget.scheme.cagr5Y.toStringAsFixed(1)}', '30.4'],
            textPrimary,
            textPrimary,
          ),
          const SizedBox(height: 12),

          _buildTableRow(
            'Category Avg. (%)',
            ['-6.2', '19.6', '22.6', '-'],
            textSecondary,
            textSecondary,
          ),
          const SizedBox(height: 12),

          _buildTableRow(
            'Rank in category',
            ['21', '2', '4', '-'],
            textSecondary,
            textSecondary,
          ),
          const SizedBox(height: 18),

          GestureDetector(
            onTap: () {
              Get.defaultDialog(
                title: 'Understanding Returns',
                titleStyle: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                backgroundColor: const Color(0xFF161B22),
                content: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Annualised returns (CAGR) show the average yearly growth rate of an investment over multiple years. Absolute returns show total gain without annual compounding.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                  ),
                ),
                confirm: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Got it', style: TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold)),
                ),
              );
            },
            child: Row(
              children: [
                Text('Understand returns', style: TextStyle(color: textSecondary, fontSize: 12)),
                const SizedBox(width: 4),
                Icon(Icons.info_outline_rounded, color: textSecondary, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, Color color) {
    return Expanded(
      flex: 1,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTableRow(String label, List<String> values, Color labelColor, Color valColor) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        ...values.map((v) => Expanded(
              flex: 1,
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: TextStyle(color: valColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            )),
      ],
    );
  }

  // ── SECTION 2: Holdings (Screenshot 2) ──
  Widget _buildHoldingsSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    final holdings = [
      {'name': 'Reverse Repo', 'weight': '13.10%', 'hasArrow': false},
      {'name': 'REC Ltd', 'weight': '2.42%', 'hasArrow': true},
      {'name': 'Sobha Ltd', 'weight': '2.40%', 'hasArrow': true},
      {'name': 'LT Foods Ltd', 'weight': '2.10%', 'hasArrow': true},
      {'name': 'State Bank of India', 'weight': '1.88%', 'hasArrow': true},
      {'name': 'Cyient Ltd', 'weight': '1.66%', 'hasArrow': true},
      {'name': 'Cholamandalam Financial Holdings Ltd', 'weight': '1.63%', 'hasArrow': true},
      {'name': 'Arvind Ltd', 'weight': '1.56%', 'hasArrow': true},
      {'name': 'The South Indian Bank Ltd', 'weight': '1.48%', 'hasArrow': true},
      {'name': 'Federal Bank Ltd', 'weight': '1.35%', 'hasArrow': true},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top 10 Holdings', style: TextStyle(color: textSecondary, fontSize: 13)),
              Row(
                children: [
                  Text('Assets', style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 2),
                  Icon(Icons.unfold_more_rounded, color: mintGreen, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: holdings.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E2533), height: 20),
            itemBuilder: (_, idx) {
              final h = holdings[idx];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        h['name'] as String,
                        style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      if (h['hasArrow'] == true) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: textSecondary, size: 16),
                      ],
                    ],
                  ),
                  Text(
                    h['weight'] as String,
                    style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── SECTION 3: Return calculator (Screenshot 3) ──
  Widget _buildReturnCalculatorSection(Color mintGreen, Color textSecondary, Color textPrimary, Color surface, Color border) {
    double rate = widget.scheme.cagr3Y;
    double years = 3;
    if (_calculatorPeriod == '6M') {
      rate = 12.8;
      years = 0.5;
    } else if (_calculatorPeriod == '1Y') {
      rate = widget.scheme.cagr1Y;
      years = 1;
    } else if (_calculatorPeriod == '3Y') {
      rate = widget.scheme.cagr3Y;
      years = 3;
    } else if (_calculatorPeriod == '5Y') {
      rate = widget.scheme.cagr5Y;
      years = 5;
    }

    double totalInvested = _calculatorAmount;
    double wouldHaveBecome = 0;

    if (_isCalculatorSip) {
      final months = (years * 12).toInt();
      totalInvested = _calculatorAmount * months;
      final i = (rate / 100) / 12;
      wouldHaveBecome = _calculatorAmount * ((pow(1 + i, months) - 1) / i) * (1 + i);
    } else {
      totalInvested = _calculatorAmount;
      wouldHaveBecome = _calculatorAmount * pow(1 + (rate / 100), years);
    }

    final double returnsPct = totalInvested > 0 ? ((wouldHaveBecome - totalInvested) / totalInvested) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F141E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2230),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isCalculatorSip = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isCalculatorSip ? const Color(0xFF273549) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: _isCalculatorSip ? Border.all(color: Colors.white24) : null,
                      ),
                      child: Text(
                        'Monthly SIP',
                        style: TextStyle(
                          color: _isCalculatorSip ? Colors.white : textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isCalculatorSip = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isCalculatorSip ? const Color(0xFF273549) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: !_isCalculatorSip ? Border.all(color: Colors.white24) : null,
                      ),
                      child: Text(
                        'One-time',
                        style: TextStyle(
                          color: !_isCalculatorSip ? Colors.white : textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              _isCalculatorSip ? 'Monthly Investment' : 'Total Investment',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              '₹ ${_formatIndianCurrency(_calculatorAmount)}',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: mintGreen,
                inactiveTrackColor: const Color(0xFF263244),
                thumbColor: mintGreen,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayColor: mintGreen.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: _calculatorAmount,
                min: 1000,
                max: 100000,
                divisions: 99,
                onChanged: (v) => setState(() => _calculatorAmount = v),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 150,
              child: _buildComparisonBars(rate, _calculatorAmount, _isCalculatorSip),
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1E2533), height: 1),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF253347), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Total Investment', style: TextStyle(color: textSecondary, fontSize: 13)),
                  ],
                ),
                Text('₹${_formatIndianCurrency(totalInvested)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF7C82F6), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Would\'ve Become', style: TextStyle(color: textSecondary, fontSize: 13)),
                  ],
                ),
                Text('₹${_formatIndianCurrency(wouldHaveBecome)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_calculatorPeriod returns', style: TextStyle(color: textSecondary, fontSize: 13)),
                Text(
                  '+${returnsPct.toStringAsFixed(2)}%',
                  style: TextStyle(color: mintGreen, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonBars(double rate, double amount, bool isSip) {
    final periods = [
      {'label': '6M', 'years': 0.5, 'rate': 12.8},
      {'label': '1Y', 'years': 1.0, 'rate': widget.scheme.cagr1Y},
      {'label': '3Y', 'years': 3.0, 'rate': widget.scheme.cagr3Y},
      {'label': '5Y', 'years': 5.0, 'rate': widget.scheme.cagr5Y},
    ];

    double maxVal = 1;
    for (var p in periods) {
      double y = p['years'] as double;
      double r = p['rate'] as double;
      double growth = isSip ? amount * (y * 12) * (1 + (r / 100)) : amount * pow(1 + (r / 100), y);
      if (growth > maxVal) maxVal = growth;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: periods.map((p) {
        final label = p['label'] as String;
        final y = p['years'] as double;
        final r = p['rate'] as double;
        final isSel = _calculatorPeriod == label;

        final double invested = isSip ? amount * (y * 12) : amount;
        final double growth = isSip ? amount * (y * 12) * (1 + (r / 100)) : amount * pow(1 + (r / 100), y);

        final double h1 = (invested / maxVal) * 90;
        final double h2 = (growth / maxVal) * 90;

        return GestureDetector(
          onTap: () => setState(() => _calculatorPeriod = label),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 14,
                    height: max(10, h1),
                    decoration: const BoxDecoration(
                      color: Color(0xFF253347),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    width: 14,
                    height: max(15, h2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C82F6),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isSel ? Border.all(color: Colors.white, width: 1.5) : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSel ? Colors.white : const Color(0xFF8B949E),
                    fontSize: 11,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── SECTION 4: Similar funds (Screenshot 5) ──
  Widget _buildSimilarFundsSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    final similarFunds = [
      {'name': 'ITI Small Cap Fund', 'returns': '25.20%'},
      {'name': widget.scheme.schemeName, 'returns': '${widget.scheme.cagr3Y.toStringAsFixed(2)}%', 'isCurrent': true},
      {'name': 'Invesco India Small Cap Fund', 'returns': '23.20%'},
      {'name': 'Sundaram Small Cap Fund', 'returns': '17.30%'},
      {'name': 'Nippon India Small Cap Fund', 'returns': '15.40%'},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.scheme.category}, ${widget.scheme.subCategory} funds',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              Row(
                children: [
                  Text('3Y Returns', style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 2),
                  Icon(Icons.unfold_more_rounded, color: mintGreen, size: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: similarFunds.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E2533), height: 20),
            itemBuilder: (_, idx) {
              final f = similarFunds[idx];
              final isCurrent = f['isCurrent'] == true;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      f['name'] as String,
                      style: TextStyle(
                        color: isCurrent ? Colors.white : const Color(0xFFE2E8F0),
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f['returns'] as String,
                    style: TextStyle(
                      color: isCurrent ? Colors.white : const Color(0xFFE2E8F0),
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── SECTION 5: Expense ratio, exit load & tax (Screenshot 2) ──
  Widget _buildExpenseRatioSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletItem(
            title: 'Expense ratio: ${widget.scheme.expenseRatio}%',
            subtitle: 'Exclusive of GST & statutory charges',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 16),
          _buildBulletItem(
            title: 'Exit load',
            subtitle: 'Exit load of 1%, if redeemed within 1 year.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 16),
          _buildBulletItem(
            title: 'Stamp duty on investment',
            subtitle: '0.005% (from July 1st, 2020)',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 16),
          _buildBulletItem(
            title: 'Tax implications',
            subtitle: 'If you redeem within one year, returns are taxed at 20%. If you redeem after one year, returns exceeding Rs 1.25 lakh in a financial year are taxed at 12.5%.',
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Understand terms', style: TextStyle(color: textSecondary, fontSize: 12)),
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline_rounded, color: textSecondary, size: 14),
                ],
              ),
              Text(
                'Check past data',
                style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem({
    required String title,
    required String subtitle,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 10),
          child: Text('•', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(subtitle, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  // ── SECTION 6: Fund management (Screenshot 3) ──
  Widget _buildFundManagementSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    final managers = [
      {'name': 'Manish Gunwani', 'tenure': 'Jan 2023 - Present', 'edu': 'B.Tech from IIT Madras, PGDM from IIM Bangalore', 'funds': '4 active equity funds'},
      {'name': 'Ritika Behera', 'tenure': 'Oct 2023 - Present', 'edu': 'Chartered Accountant (ICAI), CFA Charterholder', 'funds': '3 active equity funds'},
      {'name': 'Gaurav Satra', 'tenure': 'Jun 2024 - Present', 'edu': 'MMS Finance, University of Mumbai', 'funds': '2 equity & hybrid funds'},
      {'name': 'Kirthi Jain', 'tenure': 'Jun 2023 - Present', 'edu': 'CFA Charterholder, B.Com Honors', 'funds': '3 small-cap portfolios'},
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: managers.length,
        separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E2533), height: 24),
        itemBuilder: (_, idx) {
          final m = managers[idx];
          final name = m['name'] as String;
          final tenure = m['tenure'] as String;
          final isExpanded = _expandedManagers.contains(name);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(tenure, style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedManagers.remove(name);
                        } else {
                          _expandedManagers.add(name);
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Text('View details', style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 2),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: mintGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10141E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E2533)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Education: ${m['edu']}', style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3)),
                      const SizedBox(height: 4),
                      Text('Manages: ${m['funds']}', style: TextStyle(color: textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── SECTION 7: Fund house & investment objective (Screenshot 3) ──
  Widget _buildFundHouseSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AmcBrandLogo(
                    amcName: widget.scheme.amcName,
                    schemeName: widget.scheme.schemeName,
                    size: 38,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.scheme.amcName,
                    style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                'More Details',
                style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rank (total assets)', style: TextStyle(color: textSecondary, fontSize: 13)),
              Text('#9 in India', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total assets under management', style: TextStyle(color: textSecondary, fontSize: 13)),
              Text('₹ 2,20,143 Crores', style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── SECTION 8: Pros and cons (Screenshot 4) ──
  Widget _buildProsConsSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category: ${widget.scheme.category} ${widget.scheme.subCategory}',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Pros
          Row(
            children: const [
              Text('👍', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('Pros', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Lower expense ratio: ${widget.scheme.expenseRatio}%',
            style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Divider(color: Color(0xFF1E2533), height: 24),
          Text(
            'Consistently higher annualised returns than category average for the past 1Y and 3Y',
            style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500, height: 1.35),
          ),
          const Divider(color: Color(0xFF1E2533), height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Higher alpha: 10.31',
                style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'The fund has generated returns higher than benchmark - BSE 250 SmallCap Total Return Index - in the last 3Y',
                style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cons
          Row(
            children: const [
              Text('👎', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('Cons', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '5Y annualised returns lower than category average by 3.04%',
            style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Text('Disclaimer: Source of data - Value research', style: TextStyle(color: textSecondary, fontSize: 11)),
              const SizedBox(width: 4),
              Icon(Icons.info_outline_rounded, color: textSecondary, size: 13),
            ],
          ),
        ],
      ),
    );
  }

  // ── SECTION 9: Recently viewed (Screenshot 5) ──
  Widget _buildRecentlyViewedSection(Color mintGreen, Color textSecondary, Color textPrimary) {
    // Collect peer funds or history
    final list = [
      {
        'name': 'Parag Parikh Flexi Cap Fund',
        'sub': 'Equity Flexi Cap • 4★',
        'returns': '13.56%',
        'amc': 'PPFAS Mutual Fund',
      },
      {
        'name': 'Axis Silver FoF Direct-Growth',
        'sub': 'Commodities Silver',
        'returns': '46.63%',
        'amc': 'Axis Mutual Fund',
      },
      {
        'name': 'SBI Gold Direct Plan-Growth',
        'sub': 'Commodities Gold • 4★',
        'returns': '37.89%',
        'amc': 'SBI Mutual Fund',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recently viewed',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fund name', style: TextStyle(color: textSecondary, fontSize: 12)),
              Row(
                children: [
                  Icon(Icons.unfold_more_rounded, color: textSecondary, size: 14),
                  const SizedBox(width: 2),
                  Text('3Y Returns', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(color: Color(0xFF1E2533), height: 24),
            itemBuilder: (_, idx) {
              final f = list[idx];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      AmcBrandLogo(
                        amcName: f['amc'] as String,
                        schemeName: f['name'] as String,
                        size: 34,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 190,
                            child: Text(
                              f['name'] as String,
                              style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            f['sub'] as String,
                            style: TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    f['returns'] as String,
                    style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Custom Painter for Smooth NAV Historical Wave (Screenshot 4) ──
class _NavChartPainter extends CustomPainter {
  final String period;

  _NavChartPainter({required this.period});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D09C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00D09C).withOpacity(0.25),
          const Color(0xFF00D09C).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final List<double> normalizedPoints = _getCurvePoints(period);
    final double stepX = size.width / (normalizedPoints.length - 1);

    path.moveTo(0, size.height * (1 - normalizedPoints[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1 - normalizedPoints[0]));

    for (int i = 0; i < normalizedPoints.length - 1; i++) {
      final p0x = i * stepX;
      final p0y = size.height * (1 - normalizedPoints[i]);
      final p1x = (i + 1) * stepX;
      final p1y = size.height * (1 - normalizedPoints[i + 1]);

      final midX = (p0x + p1x) / 2;
      path.cubicTo(midX, p0y, midX, p1y, p1x, p1y);
      fillPath.cubicTo(midX, p0y, midX, p1y, p1x, p1y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  List<double> _getCurvePoints(String period) {
    switch (period) {
      case '1M':
        return [0.45, 0.48, 0.44, 0.50, 0.53, 0.49, 0.58, 0.62];
      case '6M':
        return [0.35, 0.38, 0.32, 0.44, 0.40, 0.52, 0.60, 0.72];
      case '1Y':
        return [0.25, 0.30, 0.28, 0.42, 0.38, 0.55, 0.68, 0.82];
      case '3Y':
        return [0.15, 0.28, 0.35, 0.32, 0.50, 0.45, 0.65, 0.75, 0.70, 0.88, 0.94];
      case '5Y':
        return [0.10, 0.20, 0.18, 0.32, 0.42, 0.38, 0.60, 0.72, 0.85, 0.95];
      case 'All':
        return [0.08, 0.15, 0.22, 0.35, 0.30, 0.48, 0.62, 0.78, 0.88, 0.98];
      default:
        return [0.20, 0.35, 0.45, 0.40, 0.60, 0.55, 0.75, 0.85, 0.80, 0.95];
    }
  }

  @override
  bool shouldRepaint(covariant _NavChartPainter oldDelegate) => oldDelegate.period != period;
}
