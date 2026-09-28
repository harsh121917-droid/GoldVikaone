import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'mf_sip_investment_view.dart';
import 'widgets/mf_groww_widgets.dart';

/// Full Production-Ready Screen for Mutual Fund Comparison
/// Allows side-by-side comparison of 2 or 3 mutual funds across returns,
/// ratings, AUM, expense ratios, min SIP, manager, and investment actions.
class MfCompareFundsView extends StatefulWidget {
  final List<MfSchemeModel>? initialSchemes;

  const MfCompareFundsView({Key? key, this.initialSchemes}) : super(key: key);

  @override
  State<MfCompareFundsView> createState() => _MfCompareFundsViewState();
}

class _MfCompareFundsViewState extends State<MfCompareFundsView> {
  final List<MfSchemeModel> _selectedFunds = [];
  final MutualFundsController _controller = Get.find<MutualFundsController>();

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color cardHeaderBg = Color(0xFF1C273B);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);
  static const Color subtleText = Color(0xFF8E9BAE);

  @override
  void initState() {
    super.initState();
    if (widget.initialSchemes != null && widget.initialSchemes!.isNotEmpty) {
      _selectedFunds.addAll(widget.initialSchemes!.take(3));
    } else {
      // Auto-populate with top 2 funds from controller for immediate instant comparison
      final allPool = _getAllAvailableFunds();
      if (allPool.isNotEmpty) {
        _selectedFunds.add(allPool.first);
        if (allPool.length > 1) {
          _selectedFunds.add(allPool[1]);
        }
      }
    }
  }

  List<MfSchemeModel> _getAllAvailableFunds() {
    final Map<String, MfSchemeModel> map = {};
    for (final s in _controller.schemes) {
      map[s.schemeCode] = s;
    }
    for (final s in _controller.allSchemes) {
      map[s.schemeCode] = s;
    }
    for (final s in _controller.popularSchemesList) {
      map[s.schemeCode] = s;
    }
    return map.values.toList();
  }

  void _addOrReplaceFund(int index, MfSchemeModel scheme) {
    setState(() {
      if (index < _selectedFunds.length) {
        _selectedFunds[index] = scheme;
      } else {
        if (_selectedFunds.length < 3) {
          _selectedFunds.add(scheme);
        }
      }
    });
  }

  void _removeFund(int index) {
    if (_selectedFunds.length <= 1) {
      Get.snackbar(
        'Comparison Info',
        'At least one fund must be in comparison.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardBg,
        colorText: Colors.white,
      );
      return;
    }
    setState(() {
      _selectedFunds.removeAt(index);
    });
  }

  void _openFundPicker(int targetIndex) {
    final allFunds = _getAllAvailableFunds();
    final selectedCodes = _selectedFunds.map((s) => s.schemeCode).toSet();
    final candidateFunds = allFunds.where((s) => !selectedCodes.contains(s.schemeCode)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FundPickerSheet(
        candidateFunds: candidateFunds,
        onSelect: (scheme) {
          Navigator.pop(ctx);
          _addOrReplaceFund(targetIndex, scheme);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compare Mutual Funds',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'Side-by-side performance & fund parameters',
              style: TextStyle(color: subtleText, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_selectedFunds.length < 3)
            TextButton.icon(
              onPressed: () => _openFundPicker(_selectedFunds.length),
              icon: const Icon(Icons.add, size: 18, color: mintGreen),
              label: const Text(
                'Add Fund',
                style: TextStyle(color: mintGreen, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
        ],
      ),
      body: _selectedFunds.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Fund Header Cards Side-by-Side
                  _buildFundHeaderCards(),

                  const SizedBox(height: 20),
                  // Comparison Sections
                  _buildSectionHeader('Returns & Performance', Icons.trending_up_rounded),
                  _buildReturnsComparison(),

                  const SizedBox(height: 20),
                  _buildSectionHeader('Key Fund Details', Icons.pie_chart_outline_rounded),
                  _buildDetailsComparison(),

                  const SizedBox(height: 20),
                  _buildSectionHeader('Investment Parameters', Icons.account_balance_wallet_outlined),
                  _buildInvestmentComparison(),

                  const SizedBox(height: 24),
                  // Invest Direct CTA Bar
                  _buildInvestActionBar(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows_rounded, size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'No funds selected to compare',
            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select up to 3 mutual funds for instant comparison.',
            style: TextStyle(color: subtleText, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openFundPicker(0),
            icon: const Icon(Icons.add, color: Color(0xFF0F141E)),
            label: const Text(
              'Select Fund to Compare',
              style: TextStyle(color: Color(0xFF0F141E), fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: mintGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundHeaderCards() {
    final int count = _selectedFunds.length + (_selectedFunds.length < 3 ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(count, (index) {
          if (index < _selectedFunds.length) {
            final fund = _selectedFunds[index];
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: index < count - 1 ? 8 : 0,
                  left: index > 0 ? 8 : 0,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AmcBrandLogo(
                          amcName: fund.amcName,
                          schemeName: fund.schemeName,
                          size: 36,
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _openFundPicker(index),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.sync_rounded, color: mintGreen, size: 16),
                              ),
                            ),
                            if (_selectedFunds.length > 1) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _removeFund(index),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => Get.to(() => MfSchemeDetailView(scheme: fund)),
                      child: Text(
                        fund.schemeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFFB020), size: 14),
                        const SizedBox(width: 3),
                        Text(
                          '${fund.rating}★',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2A3E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            fund.category,
                            style: const TextStyle(color: mintGreen, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Add slot button card
            return Expanded(
              child: InkWell(
                onTap: () => _openFundPicker(_selectedFunds.length),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  height: 130,
                  decoration: BoxDecoration(
                    color: cardBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: mintGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, color: mintGreen, size: 24),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add Fund',
                        style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: mintGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnsComparison() {
    // Determine winner for 1Y, 3Y, 5Y
    double max1Y = -999;
    double max3Y = -999;
    double max5Y = -999;

    for (final f in _selectedFunds) {
      if (f.cagr1Y > max1Y) max1Y = f.cagr1Y;
      if (f.cagr3Y > max3Y) max3Y = f.cagr3Y;
      if (f.cagr5Y > max5Y) max5Y = f.cagr5Y;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildMetricRow(
            label: '1Y Annualized Return',
            values: _selectedFunds.map((f) => '${f.cagr1Y >= 0 ? '+' : ''}${f.cagr1Y.toStringAsFixed(2)}%').toList(),
            winners: _selectedFunds.map((f) => f.cagr1Y == max1Y && max1Y != -999).toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: '3Y Annualized Return',
            values: _selectedFunds.map((f) => '${f.cagr3Y >= 0 ? '+' : ''}${f.cagr3Y.toStringAsFixed(2)}%').toList(),
            winners: _selectedFunds.map((f) => f.cagr3Y == max3Y && max3Y != -999).toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: '5Y Annualized Return',
            values: _selectedFunds.map((f) => '${f.cagr5Y >= 0 ? '+' : ''}${f.cagr5Y.toStringAsFixed(2)}%').toList(),
            winners: _selectedFunds.map((f) => f.cagr5Y == max5Y && max5Y != -999).toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Current NAV',
            values: _selectedFunds.map((f) => '₹${f.nav.toStringAsFixed(2)}').toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsComparison() {
    double minExp = 999;
    for (final f in _selectedFunds) {
      if (f.expenseRatio < minExp && f.expenseRatio > 0) minExp = f.expenseRatio;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildMetricRow(
            label: 'Fund Rating',
            values: _selectedFunds.map((f) => '${f.rating} / 5 ★').toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Expense Ratio',
            values: _selectedFunds.map((f) => '${f.expenseRatio.toStringAsFixed(2)}%').toList(),
            winners: _selectedFunds.map((f) => f.expenseRatio == minExp && minExp != 999).toList(),
            winnerTag: 'Lowest',
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'AUM (Fund Size)',
            values: _selectedFunds.map((f) => '₹${f.aum.toStringAsFixed(0)} Cr').toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Risk Level',
            values: _selectedFunds.map((f) => f.riskLevel).toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Sub Category',
            values: _selectedFunds.map((f) => f.subCategory).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentComparison() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _buildMetricRow(
            label: 'Min Monthly SIP',
            values: _selectedFunds.map((f) => '₹${f.minSipAmount.toStringAsFixed(0)}').toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Min One-Time Lump Sum',
            values: _selectedFunds.map((f) => '₹${f.minPurchaseAmount.toStringAsFixed(0)}').toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Fund Manager',
            values: _selectedFunds.map((f) => f.fundManager.isNotEmpty ? f.fundManager : 'Fund Team').toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Lock-in Period',
            values: _selectedFunds.map((f) => f.category.toLowerCase().contains('elss') ? '3 Years' : 'Nil').toList(),
          ),
          const Divider(color: borderColor, height: 1),
          _buildMetricRow(
            label: 'Exit Load',
            values: _selectedFunds.map((f) => '1% if redeemed within 1 yr').toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required List<String> values,
    List<bool>? winners,
    String winnerTag = 'Best',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: subtleText, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(_selectedFunds.length, (idx) {
              final val = values.length > idx ? values[idx] : '-';
              final isWinner = (winners != null && winners.length > idx && winners[idx]);

              return Expanded(
                child: Row(
                  children: [
                    Text(
                      val,
                      style: TextStyle(
                        color: isWinner ? mintGreen : Colors.white,
                        fontSize: 13,
                        fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: mintGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          winnerTag,
                          style: const TextStyle(color: mintGreen, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to start your journey?',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_selectedFunds.length, (idx) {
              final fund = _selectedFunds[idx];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: idx < _selectedFunds.length - 1 ? 6 : 0,
                    left: idx > 0 ? 6 : 0,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => MfSipInvestmentView(scheme: fund, isSip: true));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mintGreen,
                      foregroundColor: const Color(0xFF0F141E),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Invest',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Bottom Sheet for Searching & Selecting a Mutual Fund for Comparison
class _FundPickerSheet extends StatefulWidget {
  final List<MfSchemeModel> candidateFunds;
  final ValueChanged<MfSchemeModel> onSelect;

  const _FundPickerSheet({
    Key? key,
    required this.candidateFunds,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<_FundPickerSheet> createState() => _FundPickerSheetState();
}

class _FundPickerSheetState extends State<_FundPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<MfSchemeModel> _filteredList = [];

  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);

  @override
  void initState() {
    super.initState();
    _filteredList = widget.candidateFunds;
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredList = widget.candidateFunds;
      } else {
        _filteredList = widget.candidateFunds.where((s) {
          return s.schemeName.toLowerCase().contains(q) ||
              s.amcName.toLowerCase().contains(q) ||
              s.category.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: const BoxDecoration(
        color: Color(0xFF101725),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Fund to Compare',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Input Field
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search by fund name, AMC, or category...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: mintGreen, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${_filteredList.length} Funds Available',
            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredList.isEmpty
                ? const Center(
                    child: Text('No matching funds found', style: TextStyle(color: Colors.white54)),
                  )
                : ListView.builder(
                    itemCount: _filteredList.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, idx) {
                      final scheme = _filteredList[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: AmcBrandLogo(
                            amcName: scheme.amcName,
                            schemeName: scheme.schemeName,
                            size: 40,
                          ),
                          title: Text(
                            scheme.schemeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Text(
                                  scheme.category,
                                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '3Y: ${scheme.cagr3Y >= 0 ? '+' : ''}${scheme.cagr3Y.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: mintGreen, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => widget.onSelect(scheme),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mintGreen.withOpacity(0.18),
                              foregroundColor: mintGreen,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: mintGreen, width: 0.8),
                              ),
                            ),
                            child: const Text('Compare', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
