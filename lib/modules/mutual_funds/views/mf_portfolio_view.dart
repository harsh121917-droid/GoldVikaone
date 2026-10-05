import 'mf_investment_checkout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/mutual_funds_controller.dart';

class MfPortfolioView extends StatefulWidget {
  const MfPortfolioView({Key? key}) : super(key: key);

  @override
  State<MfPortfolioView> createState() => _MfPortfolioViewState();
}

class _MfPortfolioViewState extends State<MfPortfolioView> with SingleTickerProviderStateMixin {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    controller.fetchPortfolio();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? DarkColors.background : AppColors.background;
    final surface = dark ? DarkColors.surface : AppColors.surface;
    final textPrimary = dark ? Colors.white : AppColors.textPrimary;
    final textSecondary = dark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: dark ? DarkColors.primary : AppColors.primary,
        title: const Text(
          'My Mutual Funds Portfolio',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isPortfolioLoading.value && controller.holdings.isEmpty && controller.activeSips.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        final summary = controller.portfolioSummary.value;

        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: controller.fetchPortfolio,
          child: Column(
            children: [
              // ── Summary Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: dark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [AppColors.primary, const Color(0xFF2A375F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Portfolio Value', style: TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '₹${summary?.currentValuation.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Invested', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(height: 3),
                            Text(
                              '₹${summary?.totalInvested.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Overall Returns', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (summary?.totalProfitLoss ?? 0) >= 0
                                    ? const Color(0xFF10B981).withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(summary?.totalProfitLoss ?? 0) >= 0 ? '+' : ''}₹${summary?.totalProfitLoss.toStringAsFixed(2) ?? '0.00'} (${summary?.totalProfitLossPct.toStringAsFixed(2) ?? '0.00'}%)',
                                style: TextStyle(
                                  color: (summary?.totalProfitLoss ?? 0) >= 0 ? const Color(0xFF10B981) : Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Tab Switcher ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.accent,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: [
                    Tab(text: 'Holdings (${controller.holdings.length})'),
                    Tab(text: 'Active SIPs (${controller.activeSips.length})'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Tab Views ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Holdings Tab
                    _buildHoldingsTab(surface, textPrimary, textSecondary),

                    // Active SIPs Tab
                    _buildSipsTab(surface, textPrimary, textSecondary),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHoldingsTab(Color surface, Color textPrimary, Color textSecondary) {
    if (controller.holdings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, color: textSecondary, size: 54),
            const SizedBox(height: 12),
            Text('No Mutual Fund Holdings Yet', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Start your investment journey in top Regular mutual funds', style: TextStyle(color: textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.holdings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = controller.holdings[index];
        final isGain = item.profitLoss >= 0;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.schemeName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Value', style: TextStyle(color: textSecondary, fontSize: 11)),
                      Text('₹${item.currentValue.toStringAsFixed(2)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Total Units', style: TextStyle(color: textSecondary, fontSize: 11)),
                      Text(item.totalUnits.toStringAsFixed(3), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Returns', style: TextStyle(color: textSecondary, fontSize: 11)),
                      Text(
                        '${isGain ? '+' : ''}₹${item.profitLoss.toStringAsFixed(2)} (${item.profitLossPct.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: isGain ? const Color(0xFF10B981) : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFF222938)),
              const SizedBox(height: 10),
              if (item.pendingRedemptionUnits > 0.0001) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        '${item.pendingRedemptionUnits.toStringAsFixed(3)} Units Pending AMC Payout',
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFF222938)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avail: ${item.availableUnits.toStringAsFixed(3)} Units',
                    style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00D09C),
                          side: const BorderSide(color: Color(0xFF00D09C)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 15),
                        label: const Text('Add Investment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () => _openAddInvestmentForHolding(context, item),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF59E0B),
                          side: const BorderSide(color: Color(0xFFF59E0B)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                        label: const Text('Redeem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: (item.availableUnits > 0.0001 || item.totalUnits > 0.0001)
                            ? () => _showRedemptionSheet(context, item, surface, textPrimary, textSecondary)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSipsTab(Color surface, Color textPrimary, Color textSecondary) {
    if (controller.activeSips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.autorenew_rounded, color: textSecondary, size: 54),
            const SizedBox(height: 12),
            Text('No Active SIPs', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Set up automated monthly wealth building', style: TextStyle(color: textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.activeSips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sip = controller.activeSips[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(sip.schemeName, style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Installment Amount', style: TextStyle(color: textSecondary, fontSize: 11)),
                      Text('₹${sip.installmentAmount.toInt()}/mo', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Installments Paid', style: TextStyle(color: textSecondary, fontSize: 11)),
                      Text('${sip.installmentsPaid} paid', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

    Future<void> _openAddInvestmentForHolding(BuildContext context, dynamic item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
    );

    final scheme = await controller.getSchemeByCode(item.schemeCode);
    if (context.mounted) Navigator.pop(context);

    if (scheme != null && context.mounted) {
      MfInvestmentCheckoutSheet.show(context, scheme, isSip: false);
    } else if (context.mounted) {
      Get.snackbar(
        'Notice',
        'Could not load scheme details for ${item.schemeName}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void _showRedemptionSheet(BuildContext context, dynamic item, Color surface, Color textPrimary, Color textSecondary) {
    final unitsCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String redeemMode = 'UNITS'; // 'UNITS' or 'AMOUNT'
    bool allUnits = false;
    double enteredUnits = 0.0;
    double enteredAmount = 0.0;
    bool isSubmitting = false;

    final double availableUnits = (item.availableUnits != null && item.availableUnits > 0)
        ? item.availableUnits
        : item.totalUnits;
    final double maxRedeemableAmount = availableUnits * item.currentNav;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final double estPayout = redeemMode == 'AMOUNT'
                ? enteredAmount
                : (enteredUnits * item.currentNav);
            final double estUnits = redeemMode == 'AMOUNT'
                ? (item.currentNav > 0 ? (enteredAmount / item.currentNav) : 0.0)
                : enteredUnits;

            final ucc = controller.userUcc.value;
            final String bankName = (ucc != null && ucc.bankName.isNotEmpty) ? ucc.bankName : 'Registered Bank';
            final String rawAcc = ucc?.accountNo ?? '';
            final String maskedAcc = rawAcc.length > 4 ? '•••• ${rawAcc.substring(rawAcc.length - 4)}' : rawAcc;

            final bool isValidInput = redeemMode == 'AMOUNT'
                ? (enteredAmount > 0 && enteredAmount <= maxRedeemableAmount)
                : (enteredUnits > 0 && enteredUnits <= availableUnits);

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF121620),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Color(0xFF222938))),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                        Text(
                          'Redeem Mutual Fund',
                          style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textSecondary, size: 20),
                          onPressed: () => Navigator.pop(modalCtx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.schemeName,
                      style: TextStyle(color: textSecondary, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),

                    // ── Summary Cards ──
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181E2C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF222938)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Available to Redeem', style: TextStyle(color: textSecondary, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${availableUnits.toStringAsFixed(3)} Units',
                                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Current NAV', style: TextStyle(color: textSecondary, fontSize: 11)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${item.currentNav.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Value: ₹${item.currentValue.toStringAsFixed(2)}',
                                style: TextStyle(color: textSecondary, fontSize: 11),
                              ),
                              Text(
                                'Invested: ₹${item.investedAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Redeem Mode Toggle (Amount vs Units) ──
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                redeemMode = 'UNITS';
                                allUnits = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: redeemMode == 'UNITS' ? const Color(0xFF00D09C).withOpacity(0.18) : const Color(0xFF181E2C),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: redeemMode == 'UNITS' ? const Color(0xFF00D09C) : const Color(0xFF222938),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Redeem by Units',
                                  style: TextStyle(
                                    color: redeemMode == 'UNITS' ? const Color(0xFF00D09C) : textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setModalState(() {
                                redeemMode = 'AMOUNT';
                                allUnits = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: redeemMode == 'AMOUNT' ? const Color(0xFF00D09C).withOpacity(0.18) : const Color(0xFF181E2C),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: redeemMode == 'AMOUNT' ? const Color(0xFF00D09C) : const Color(0xFF222938),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Redeem by Amount (₹)',
                                  style: TextStyle(
                                    color: redeemMode == 'AMOUNT' ? const Color(0xFF00D09C) : textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Input Field & Percentage Chips ──
                    if (redeemMode == 'UNITS') ...[
                      Text('Units to Redeem', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: unitsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: '0.000',
                          hintStyle: TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: const Color(0xFF181E2C),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF222938))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF222938))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00D09C))),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            allUnits = false;
                            enteredUnits = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildQuickChip('25%', () {
                            setModalState(() {
                              allUnits = false;
                              enteredUnits = availableUnits * 0.25;
                              unitsCtrl.text = enteredUnits.toStringAsFixed(3);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('50%', () {
                            setModalState(() {
                              allUnits = false;
                              enteredUnits = availableUnits * 0.50;
                              unitsCtrl.text = enteredUnits.toStringAsFixed(3);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('75%', () {
                            setModalState(() {
                              allUnits = false;
                              enteredUnits = availableUnits * 0.75;
                              unitsCtrl.text = enteredUnits.toStringAsFixed(3);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('ALL', () {
                            setModalState(() {
                              allUnits = true;
                              enteredUnits = availableUnits;
                              unitsCtrl.text = availableUnits.toStringAsFixed(3);
                            });
                          }, isAccent: true),
                        ],
                      ),
                    ] else ...[
                      Text('Redemption Amount (₹)', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: InputDecoration(
                          prefixText: '₹ ',
                          prefixStyle: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: textSecondary),
                          filled: true,
                          fillColor: const Color(0xFF181E2C),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF222938))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF222938))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF00D09C))),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            allUnits = false;
                            enteredAmount = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildQuickChip('25%', () {
                            setModalState(() {
                              allUnits = false;
                              enteredAmount = maxRedeemableAmount * 0.25;
                              amountCtrl.text = enteredAmount.toStringAsFixed(2);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('50%', () {
                            setModalState(() {
                              allUnits = false;
                              enteredAmount = maxRedeemableAmount * 0.50;
                              amountCtrl.text = enteredAmount.toStringAsFixed(2);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('75%', () {
                            setModalState(() {
                              allUnits = false;
                              enteredAmount = maxRedeemableAmount * 0.75;
                              amountCtrl.text = enteredAmount.toStringAsFixed(2);
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('MAX', () {
                            setModalState(() {
                              allUnits = true;
                              enteredAmount = maxRedeemableAmount;
                              amountCtrl.text = maxRedeemableAmount.toStringAsFixed(2);
                            });
                          }, isAccent: true),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),

                    // ── Estimated Calculation Banner ──
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09C).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.25)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated Payout', style: TextStyle(color: Color(0xFF00D09C), fontSize: 13, fontWeight: FontWeight.w600)),
                              Text('₹${estPayout.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00D09C), fontSize: 16, fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estimated Units to Sell', style: TextStyle(color: textSecondary, fontSize: 11)),
                              Text('${estUnits.toStringAsFixed(3)} Units', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Registered Bank Notice ──
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181E2C),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF222938)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_rounded, color: Color(0xFF00D09C), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Direct Payout Account', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(
                                  '$bankName ${maskedAcc.isNotEmpty ? "($maskedAcc)" : ""}',
                                  style: TextStyle(color: textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Estimated amount only. Final payout is calculated on the NAV of the applicable settlement cut-off date. Proceeds are credited directly to your bank account by AMC (T+2/T+3 days).',
                            style: TextStyle(color: textSecondary, fontSize: 10.5, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // ── Confirm Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: (!isValidInput || isSubmitting)
                            ? null
                            : () async {
                                setModalState(() {
                                  isSubmitting = true;
                                });

                                final result = await controller.redeemHolding(
                                  schemeCode: item.schemeCode,
                                  redeemMode: redeemMode,
                                  units: redeemMode == 'UNITS' ? enteredUnits : null,
                                  amount: redeemMode == 'AMOUNT' ? enteredAmount : null,
                                  allUnits: allUnits,
                                  folioNo: item.folioNo,
                                );

                                if (modalCtx.mounted) {
                                  Navigator.pop(modalCtx);
                                }

                                Get.snackbar(
                                  result['success'] == true ? 'Redemption Request Placed' : 'Redemption Error',
                                  result['message'] ?? '',
                                  backgroundColor: result['success'] == true ? const Color(0xFF00D09C) : Colors.redAccent,
                                  colorText: result['success'] == true ? Colors.black : Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 5),
                                );
                              },
                        child: isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : Text(
                                'Confirm Redemption (${redeemMode == "AMOUNT" ? "₹" + enteredAmount.toStringAsFixed(0) : enteredUnits.toStringAsFixed(3) + " Units"})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildQuickChip(String label, VoidCallback onTap, {bool isAccent = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isAccent ? const Color(0xFF00D09C) : const Color(0xFF1E2538),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isAccent ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
