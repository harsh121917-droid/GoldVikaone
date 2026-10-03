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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      side: const BorderSide(color: Color(0xFFF59E0B)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                    label: const Text('Redeem / Withdraw', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => _showRedemptionSheet(context, item, surface, textPrimary, textSecondary),
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

  void _showRedemptionSheet(BuildContext context, dynamic item, Color surface, Color textPrimary, Color textSecondary) {
    final unitsCtrl = TextEditingController();
    bool allUnits = false;
    double enteredUnits = 0.0;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final double estPayout = enteredUnits * item.currentNav;

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
                        'Redeem Mutual Fund Units',
                        style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181E2C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222938)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available Balance', style: TextStyle(color: textSecondary, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('${item.totalUnits.toStringAsFixed(3)} Units', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Current NAV', style: TextStyle(color: textSecondary, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text('₹${item.currentNav.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Units to Redeem', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: allUnits ? const Color(0xFF00D09C) : const Color(0xFF1E2538),
                          foregroundColor: allUnits ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onPressed: () {
                          setModalState(() {
                            allUnits = true;
                            enteredUnits = item.totalUnits;
                            unitsCtrl.text = item.totalUnits.toStringAsFixed(3);
                          });
                        },
                        child: const Text('ALL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09C).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Payout', style: TextStyle(color: Color(0xFF00D09C), fontSize: 13, fontWeight: FontWeight.w600)),
                        Text('₹${estPayout.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00D09C), fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Colors.white54, size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Funds will be credited directly to your registered bank account by AMC in 2-3 business days (T+2/T+3).',
                          style: TextStyle(color: textSecondary, fontSize: 11, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                      onPressed: (enteredUnits <= 0 || enteredUnits > item.totalUnits || isSubmitting)
                          ? null
                          : () async {
                              setModalState(() {
                                isSubmitting = true;
                              });

                              final result = await controller.redeemUnits(
                                schemeCode: item.schemeCode,
                                units: enteredUnits,
                                allUnits: allUnits,
                              );

                              if (modalCtx.mounted) {
                                Navigator.pop(modalCtx);
                              }

                              Get.snackbar(
                                result['success'] == true ? 'Redemption Request Placed' : 'Redemption Error',
                                result['message'] ?? '',
                                backgroundColor: result['success'] == true ? const Color(0xFF00D09C) : Colors.red,
                                colorText: Colors.black,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 4),
                              );
                            },
                      child: isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Confirm Redemption (Sell Units)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}
