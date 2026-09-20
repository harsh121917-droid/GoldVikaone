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
            Text('Start investing with as little as ₹500/month', style: TextStyle(color: textSecondary, fontSize: 13)),
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
}
