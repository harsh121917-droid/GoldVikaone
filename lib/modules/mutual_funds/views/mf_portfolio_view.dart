import 'mf_investment_checkout_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/mf_portfolio_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'widgets/mf_groww_widgets.dart';
import 'mf_scheme_detail_view.dart';

class MfPortfolioView extends StatefulWidget {
  const MfPortfolioView({Key? key}) : super(key: key);

  @override
  State<MfPortfolioView> createState() => _MfPortfolioViewState();
}

class _MfPortfolioViewState extends State<MfPortfolioView> with SingleTickerProviderStateMixin {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  late final TabController _tabController;
  final RxBool _hideBalance = false.obs;
  final RxString _selectedSortCriteria = 'Current (High to Low)'.obs;

  @override
  void initState() {
    super.initState();
    int initialTab = 0;
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        final t = (Get.arguments as Map)['tab'];
        if (t == 'orders' || t == 1) {
          initialTab = 1;
        } else if (t == 'sips' || t == 2) {
          initialTab = 2;
        }
      } else if (Get.arguments == 'orders' || Get.arguments == 1) {
        initialTab = 1;
      } else if (Get.arguments == 'sips' || Get.arguments == 2) {
        initialTab = 2;
      }
    }
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialTab);
    controller.fetchPortfolio();
    controller.fetchMyOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);
    final surface = dark ? const Color(0xFF131D31) : Colors.white;
    final textPrimary = dark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: dark ? const Color(0xFF0B0F19) : Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textPrimary),
          ),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mutual Funds Portfolio',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'NSE MFSS Authoritative Holdings',
                  style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Explore Funds',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF00D09C)),
            ),
            onPressed: () => Get.toNamed(AppRoutes.mutualFunds),
          ),
          IconButton(
            tooltip: 'Refresh Portfolio',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.refresh_rounded, size: 18, color: textPrimary),
            ),
            onPressed: () async {
              await Future.wait([
                controller.fetchPortfolio(),
                controller.fetchMyOrders(),
              ]);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isPortfolioLoading.value &&
            controller.holdings.isEmpty &&
            controller.activeSips.isEmpty &&
            controller.inProgressOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00D09C)));
        }

        final summary = controller.portfolioSummary.value;

        return RefreshIndicator(
          color: const Color(0xFF00D09C),
          onRefresh: () async {
            await Future.wait([
              controller.fetchPortfolio(),
              controller.fetchMyOrders(),
            ]);
          },
          child: Column(
            children: [
              // ── Groww Underline Tab Bar (Dashboard (X) | Orders (Y) | SIPs (Z)) ──
              _buildGrowwTopTabBar(surface, textSecondary, dark),

              // ── Tab Views ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboardTab(summary, surface, textPrimary, textSecondary, dark),
                    _buildOrdersTab(surface, textPrimary, textSecondary, dark),
                    _buildSipsTab(surface, textPrimary, textSecondary, dark),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Groww Top Underline Tab Bar
  // ══════════════════════════════════════════════════════════════
  Widget _buildGrowwTopTabBar(Color surface, Color textSecondary, bool dark) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0B0F19) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: dark ? const Color(0xFF1E2538) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF00D09C),
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color(0xFF00D09C),
        unselectedLabelColor: textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        tabs: [
          Tab(text: 'Dashboard (${controller.holdings.length})'),
          Tab(text: 'Orders (${controller.inProgressOrders.length})'),
          Tab(text: 'SIPs (${controller.activeSips.length})'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Groww Dashboard Tab (Hero Card + Filter Row + Holdings List)
  // ══════════════════════════════════════════════════════════════
  Widget _buildDashboardTab(
      dynamic summary, Color surface, Color textPrimary, Color textSecondary, bool dark) {
    if (controller.holdings.isEmpty) {
      if (controller.inProgressOrders.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  'Orders Awaiting Allotment',
                  style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your mutual fund purchases have been submitted to NSE MFSS. Units will appear here once allotted by the AMC.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: const Text('View Pending Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _tabController.animateTo(1),
                ),
              ],
            ),
          ),
        );
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF00D09C), size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                'No Mutual Fund Holdings Yet',
                style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Start systematic wealth accumulation in top Regular mutual funds with live NSE execution.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.trending_up_rounded, size: 18),
                label: const Text('Explore Mutual Funds', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                onPressed: () => Get.toNamed(AppRoutes.mutualFunds),
              ),
            ],
          ),
        ),
      );
    }

    final sorted = _sortedHoldings;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      children: [
        // 1. Groww Hero Card
        _buildGrowwHeroCard(summary, dark),

        // 2. Sort & Filter Row
        _buildFilterSortRow(surface, textPrimary, textSecondary, dark),

        // 3. Holdings List
        ...sorted.map((item) => _buildGrowwHoldingItem(item, surface, textPrimary, textSecondary, dark)),

        // 4. SIP Promotion Banner
        _buildSipPromotionBanner(surface, textPrimary, textSecondary, dark),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Groww Hero Summary Card (Holdings X, Balance, 1D/Total Returns)
  // ══════════════════════════════════════════════════════════════
  Widget _buildGrowwHeroCard(dynamic summary, bool dark) {
    final double valuation = summary?.currentValuation ??
        controller.holdings.fold<double>(0.0, (acc, h) => acc + h.currentValue);
    final double invested = summary?.totalInvested ??
        controller.holdings.fold<double>(0.0, (acc, h) => acc + h.investedAmount);
    final double pnl = summary?.totalProfitLoss ?? (valuation - invested);
    final double pnlPct = invested > 0 ? (pnl / invested) * 100 : 0.0;

    final double day1Amount = summary?.todayChangeAmount ??
        controller.holdings.fold<double>(0.0, (acc, h) => acc + (h.day1ChangeAmount ?? 0.0));
    final double day1Pct = summary?.todayChangePct ??
        (valuation > 0 ? (day1Amount / valuation) * 100 : 0.0);
    final double? xirr = summary?.xirr;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF131722) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? const Color(0xFF222938) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: HOLDINGS (X) with eye icon & analytics icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'HOLDINGS (${controller.holdings.length})',
                    style: TextStyle(
                      color: dark ? Colors.white60 : const Color(0xFF64748B),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _hideBalance.toggle(),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        _hideBalance.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 16,
                        color: dark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showPortfolioAnalyticsModal(context, dark),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.insights_rounded,
                        size: 18,
                        color: dark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Current Valuation
          _hideBalance.value
              ? Text(
                  '••••••••',
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Text(
                  '₹${_formatCurrency(valuation, showDecimals: true)}',
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
          const SizedBox(height: 14),

          // Divider
          Container(
            height: 1,
            color: dark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),

          // Row 1: 1D returns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1D returns',
                style: TextStyle(
                  color: dark ? Colors.white70 : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _hideBalance.value
                  ? const Text('••••', style: TextStyle(fontWeight: FontWeight.bold))
                  : _buildReturnBadge(day1Amount, day1Pct, isLarge: true),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Container(
            height: 1,
            color: dark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Row 2: Total returns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total returns',
                style: TextStyle(
                  color: dark ? Colors.white70 : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _hideBalance.value
                  ? const Text('••••', style: TextStyle(fontWeight: FontWeight.bold))
                  : _buildReturnBadge(pnl, pnlPct, isLarge: true),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Container(
            height: 1,
            color: dark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 10),

          // Row 3: Invested
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invested',
                style: TextStyle(
                  color: dark ? Colors.white70 : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _hideBalance.value
                  ? const Text('••••', style: TextStyle(fontWeight: FontWeight.bold))
                  : Text(
                      '₹${_formatCurrency(invested, showDecimals: true)}',
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ],
          ),

          // Optional XIRR row if available
          if (xirr != null && xirr != 0) ...[
            const SizedBox(height: 10),
            Container(
              height: 1,
              color: dark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'XIRR',
                      style: TextStyle(
                        color: dark ? Colors.white70 : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: dark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
                Text(
                  '${xirr.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: xirr >= 0 ? const Color(0xFF00D09C) : const Color(0xFFEF4444),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Sort & Filter Row (< > Current (Invested))
  // ══════════════════════════════════════════════════════════════
  Widget _buildFilterSortRow(
      Color surface, Color textPrimary, Color textSecondary, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sort toggle button: Current (Invested)
          InkWell(
            onTap: () {
              if (_selectedSortCriteria.value.startsWith('Current')) {
                _selectedSortCriteria.value = 'Invested (High to Low)';
              } else {
                _selectedSortCriteria.value = 'Current (High to Low)';
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dark ? const Color(0xFF222938) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 15,
                    color: Color(0xFF00D09C),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _selectedSortCriteria.value.startsWith('Current')
                        ? 'Current (Invested)'
                        : 'Invested (Current)',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter/Sort button
          InkWell(
            onTap: () => _showSortOptionsBottomSheet(context, surface, textPrimary, textSecondary, dark),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: dark ? const Color(0xFF222938) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Groww Holding Card Item (Tap opens action sheet)
  // ══════════════════════════════════════════════════════════════
  Widget _buildGrowwHoldingItem(
      MfHolding item, Color surface, Color textPrimary, Color textSecondary, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? const Color(0xFF1E2538) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHoldingActionSheet(context, item),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Authentic AMC Logo
                AmcBrandLogo(
                  amcName: item.amcName ?? '',
                  schemeName: item.schemeName,
                  size: 40,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),

                // Scheme Name and Folio Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.schemeName,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.folioNo != null && item.folioNo!.isNotEmpty)
                            Text(
                              'Folio: ${item.folioNo}',
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            )
                          else
                            Text(
                              item.category ?? 'REGULAR PLAN',
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            ),
                          if (item.pendingRedemptionUnits > 0.0001) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(color: Color(0xFFF59E0B), fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Valuation, Invested & Returns (Right Aligned)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Current Value
                    _hideBalance.value
                        ? Text('••••', style: TextStyle(color: textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700))
                        : Text(
                            '₹${_formatCurrency(item.currentValue, showDecimals: true)}',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    const SizedBox(height: 2),

                    // Invested Amount
                    _hideBalance.value
                        ? Text('••••', style: TextStyle(color: textSecondary, fontSize: 11))
                        : Text(
                            '(Invested ₹${_formatCurrency(item.investedAmount, showDecimals: false)})',
                            style: TextStyle(color: textSecondary, fontSize: 11),
                          ),
                    const SizedBox(height: 3),

                    // Profit / Loss (STRICT: Negative in RED with - sign, Positive in GREEN with + sign)
                    _hideBalance.value
                        ? const Text('••••', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold))
                        : (item.profitLoss < 0
                            ? Text(
                                '-₹${_formatCurrency(item.profitLoss.abs(), showDecimals: true, decimalPlaces: 2)} (-${item.profitLossPct.abs().toStringAsFixed(2)}%)',
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : Text(
                                '+₹${_formatCurrency(item.profitLoss, showDecimals: true, decimalPlaces: 2)} (+${item.profitLossPct.toStringAsFixed(2)}%)',
                                style: const TextStyle(
                                  color: Color(0xFF00D09C),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Promotional SIP Banner Card
  // ══════════════════════════════════════════════════════════════
  Widget _buildSipPromotionBanner(
      Color surface, Color textPrimary, Color textSecondary, bool dark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? const Color(0xFF222938) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invest every month and grow your wealth with SIP',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Automate your investments with zero manual intervention.',
                  style: TextStyle(color: textSecondary, fontSize: 11.5, height: 1.3),
                ),
                const SizedBox(height: 12),
                Material(
                  color: const Color(0xFF00D09C),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.mutualFunds),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF0F141E)),
                          SizedBox(width: 4),
                          Text(
                            'Start a SIP',
                            style: TextStyle(
                              color: Color(0xFF0F141E),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF00D09C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF00D09C),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Holding Action Bottom Sheet (Screenshot 2: Redeem, Details, One Time, Start SIP)
  // ══════════════════════════════════════════════════════════════
  void _showHoldingActionSheet(BuildContext context, MfHolding item) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF131722) : Colors.white;
    final cardBorder = dark ? const Color(0xFF222938) : const Color(0xFFE2E8F0);
    final textPrimary = dark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = dark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9);

    final day1Amount = item.day1ChangeAmount ?? 0.0;
    final day1Pct = item.day1ChangePct ?? 0.0;
    final pnl = item.profitLoss;
    final pnlPct = item.profitLossPct;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).padding.bottom + 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row: Logo + Scheme Title (Clickable > to open Scheme Detail View)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () async {
                    Navigator.pop(sheetCtx);
                    final scheme = await controller.getSchemeByCode(item.schemeCode);
                    if (scheme != null) {
                      Get.to(() => MfSchemeDetailView(scheme: scheme));
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      AmcBrandLogo(
                        amcName: item.amcName ?? '',
                        schemeName: item.schemeName,
                        size: 42,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.schemeName,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.folioNo != null && item.folioNo!.isNotEmpty
                                  ? 'Folio: ${item.folioNo}'
                                  : (item.category ?? 'REGULAR PLAN'),
                              style: TextStyle(color: textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios_rounded, size: 15, color: textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: dividerColor),

              // Current Value & Returns Sub-Card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF0F141E) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Value', style: TextStyle(color: textSecondary, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              '₹${_formatCurrency(item.currentValue, showDecimals: true)}',
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '(Invested ₹${_formatCurrency(item.investedAmount, showDecimals: false)})',
                              style: TextStyle(color: textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: dividerColor),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Total Returns', style: TextStyle(color: textSecondary, fontSize: 11)),
                            const SizedBox(height: 4),
                            _buildReturnBadge(pnl, pnlPct),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('1D: ', style: TextStyle(color: textSecondary, fontSize: 11)),
                                _buildReturnBadge(day1Amount, day1Pct),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Options: Redeem & Investment details (Screenshot 2)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFFF59E0B), size: 18),
                ),
                title: Text('Redeem', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Withdraw units or amount directly to bank', style: TextStyle(color: textSecondary, fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showRedemptionSheet(context, item, bg, textPrimary, textSecondary);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09C).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF00D09C), size: 18),
                ),
                title: Text('Investment details', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Holding summary, NAV history, tax splits, & bank info', style: TextStyle(color: textSecondary, fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded, color: textSecondary),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showInvestmentDetailsView(context, item);
                },
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: dividerColor),

              // Sticky Bottom Buttons: One Time & Start SIP (Screenshot 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _openAddInvestmentForHolding(context, item, isSip: false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: cardBorder, width: 1.2),
                          foregroundColor: textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'One Time',
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _openAddInvestmentForHolding(context, item, isSip: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09C),
                          foregroundColor: const Color(0xFF0F141E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start SIP',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Dedicated Investment Details View (Screenshot 3)
  // ══════════════════════════════════════════════════════════════
  void _showInvestmentDetailsView(BuildContext context, MfHolding item) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC);
    final surface = dark ? const Color(0xFF131722) : Colors.white;
    final cardBorder = dark ? const Color(0xFF222938) : const Color(0xFFE2E8F0);
    final textPrimary = dark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor = dark ? const Color(0xFF1E2538) : const Color(0xFFF1F5F9);

    final day1Amount = item.day1ChangeAmount ?? 0.0;
    final day1Pct = item.day1ChangePct ?? 0.0;
    final pnl = item.profitLoss;
    final pnlPct = item.profitLossPct;

    final ucc = controller.userUcc.value;
    final String bankName = (ucc != null && ucc.bankName.isNotEmpty) ? ucc.bankName : 'Registered Bank';
    final String rawAcc = ucc?.accountNo ?? '';
    final String maskedAcc = rawAcc.length > 4 ? '•••• ${rawAcc.substring(rawAcc.length - 4)}' : rawAcc;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return Container(
          height: MediaQuery.of(modalCtx).size.height * 0.92,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Top Drag Handle & App Bar Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: dark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: textPrimary),
                          onPressed: () => Navigator.pop(modalCtx),
                        ),
                        const SizedBox(width: 4),
                        AmcBrandLogo(
                          amcName: item.amcName ?? '',
                          schemeName: item.schemeName,
                          size: 36,
                          borderRadius: 8,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.schemeName,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.folioNo != null && item.folioNo!.isNotEmpty
                                    ? 'Folio: ${item.folioNo}'
                                    : (item.category ?? 'REGULAR PLAN'),
                                style: TextStyle(color: textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: dividerColor),

              // Scrollable Details
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    // Card 1: CURRENT (Screenshot 3)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_formatCurrency(item.currentValue, showDecimals: true)}',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('1D returns', _buildReturnBadge(day1Amount, day1Pct), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Total returns', _buildReturnBadge(pnl, pnlPct), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Invested', Text('₹${_formatCurrency(item.investedAmount, showDecimals: true)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('XIRR', Text('14.2%', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Long-term', Text('₹${_formatCurrency(item.currentValue, showDecimals: true)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Short-term', Text('₹0.00', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: HOLDING DETAILS (Screenshot 3)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOLDING DETAILS',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow('Current NAV', Text('₹${_formatCurrency(item.currentNav, showDecimals: true)}', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Total Units', Text(item.totalUnits.toStringAsFixed(3), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Available Units', Text(item.availableUnits.toStringAsFixed(3), style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Average NAV', Text(item.averageNav != null ? '₹${_formatCurrency(item.averageNav!, showDecimals: true)}' : '—', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Folio Number', Text(item.folioNo != null && item.folioNo!.isNotEmpty ? item.folioNo! : '—', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Registered Bank', Text('$bankName $maskedAcc', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                          Divider(height: 20, color: dividerColor),
                          _buildDetailRow('Nominee', Text('Registered', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Buttons (Screenshot 3)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: surface,
                  border: Border(top: BorderSide(color: cardBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (item.availableUnits > 0.0001 || item.totalUnits > 0.0001)
                            ? () {
                                Navigator.pop(modalCtx);
                                _showRedemptionSheet(context, item, surface, textPrimary, textSecondary);
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: (item.availableUnits > 0.0001 || item.totalUnits > 0.0001) ? const Color(0xFFF59E0B) : Colors.grey.withOpacity(0.3)),
                          foregroundColor: const Color(0xFFF59E0B),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Redeem', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(modalCtx);
                          _openAddInvestmentForHolding(context, item, isSip: false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09C),
                          foregroundColor: const Color(0xFF0F141E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Invest More', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, Widget valueWidget, Color labelColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.w500)),
        valueWidget,
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Sort Options Modal Bottom Sheet
  // ══════════════════════════════════════════════════════════════
  void _showSortOptionsBottomSheet(
      BuildContext context, Color surface, Color textPrimary, Color textSecondary, bool dark) {
    final sortOptions = [
      'Current (High to Low)',
      'Current (Low to High)',
      'Invested (High to Low)',
      'Invested (Low to High)',
      'Total Returns (High to Low)',
      'Total Returns (Low to High)',
      '1D Returns (High to Low)',
      'Scheme Name (A to Z)',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sort Holdings By',
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              ...sortOptions.map((opt) {
                final isSelected = _selectedSortCriteria.value == opt;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF00D09C) : textPrimary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: Color(0xFF00D09C), size: 18)
                      : null,
                  onTap: () {
                    _selectedSortCriteria.value = opt;
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Portfolio Analytics Breakdown Modal
  // ══════════════════════════════════════════════════════════════
  void _showPortfolioAnalyticsModal(BuildContext context, bool dark) {
    final surface = dark ? const Color(0xFF131722) : Colors.white;
    final textPrimary = dark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final Map<String, double> catMap = {};
    double totalVal = 0.0;
    for (final h in controller.holdings) {
      final cat = h.category ?? 'Equity';
      catMap[cat] = (catMap[cat] ?? 0.0) + h.currentValue;
      totalVal += h.currentValue;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.pie_chart_rounded, color: Color(0xFF00D09C), size: 20),
                  const SizedBox(width: 8),
                  Text('Portfolio Breakdown', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 16),
              if (totalVal <= 0)
                Text('No active holdings to analyze.', style: TextStyle(color: textSecondary))
              else
                ...catMap.entries.map((e) {
                  final pct = totalVal > 0 ? (e.value / totalVal) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('₹${_formatCurrency(e.value, showDecimals: true)} (${pct.toStringAsFixed(1)}%)', style: TextStyle(color: textSecondary, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: dark ? const Color(0xFF1E2538) : const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D09C)),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Financial Format Helpers
  // ══════════════════════════════════════════════════════════════
  List<MfHolding> get _sortedHoldings {
    final list = List<MfHolding>.from(controller.holdings);
    switch (_selectedSortCriteria.value) {
      case 'Current (High to Low)':
        list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
        break;
      case 'Current (Low to High)':
        list.sort((a, b) => a.currentValue.compareTo(b.currentValue));
        break;
      case 'Invested (High to Low)':
        list.sort((a, b) => b.investedAmount.compareTo(a.investedAmount));
        break;
      case 'Invested (Low to High)':
        list.sort((a, b) => a.investedAmount.compareTo(b.investedAmount));
        break;
      case 'Total Returns (High to Low)':
        list.sort((a, b) => b.profitLoss.compareTo(a.profitLoss));
        break;
      case 'Total Returns (Low to High)':
        list.sort((a, b) => a.profitLoss.compareTo(b.profitLoss));
        break;
      case '1D Returns (High to Low)':
        list.sort((a, b) => (b.day1ChangeAmount ?? 0.0).compareTo(a.day1ChangeAmount ?? 0.0));
        break;
      case 'Scheme Name (A to Z)':
        list.sort((a, b) => a.schemeName.compareTo(b.schemeName));
        break;
      default:
        list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    }
    return list;
  }

  String _formatCurrency(num value, {bool showDecimals = true, int decimalPlaces = 2}) {
    final parts = value.toStringAsFixed(decimalPlaces).split('.');
    final whole = parts[0];
    final dec = parts.length > 1 ? parts[1] : '';

    final isNeg = whole.startsWith('-');
    final cleanWhole = isNeg ? whole.substring(1) : whole;

    if (cleanWhole.length <= 3) {
      return '${isNeg ? '-' : ''}$cleanWhole${showDecimals ? '.$dec' : ''}';
    }

    final lastThree = cleanWhole.substring(cleanWhole.length - 3);
    final remaining = cleanWhole.substring(0, cleanWhole.length - 3);

    final buf = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buf.write(',');
      }
      buf.write(remaining[i]);
    }
    buf.write(',');
    buf.write(lastThree);

    return '${isNeg ? '-' : ''}${buf.toString()}${showDecimals ? '.$dec' : ''}';
  }

  Widget _buildReturnBadge(num amount, num pct, {bool isLarge = false}) {
    final bool isLoss = amount < 0 || pct < 0;
    final color = isLoss ? const Color(0xFFEF4444) : const Color(0xFF00D09C);
    final sign = isLoss ? '-' : '+';
    final amountFormatted = _formatCurrency(amount.abs(), showDecimals: true);
    final pctFormatted = pct.abs().toStringAsFixed(2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isLoss ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          size: isLarge ? 14 : 11,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '$sign₹$amountFormatted ($sign$pctFormatted%)',
          style: TextStyle(
            color: color,
            fontSize: isLarge ? 13.5 : 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Modern Orders In Progress Tab
  // ══════════════════════════════════════════════════════════════
  Widget _buildOrdersTab(Color surface, Color textPrimary, Color textSecondary, bool dark) {
    final orders = controller.myOrders.isNotEmpty ? controller.myOrders : controller.inProgressOrders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 48),
            ),
            const SizedBox(height: 14),
            Text('No Orders In Progress', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('All your mutual fund purchases have been allotted.', style: TextStyle(color: textSecondary, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        final bool isAllotted = order.allotmentStatus == 'ALLOTTED';
        final Color badgeColor = isAllotted ? const Color(0xFF00D09C) : const Color(0xFFF59E0B);
        final String dateStr =
            '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: badgeColor.withOpacity(0.35), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AmcBrandLogo(
                    amcName: '',
                    schemeName: order.schemeName,
                    size: 38,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      order.schemeName,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 14.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: badgeColor.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          order.badgeLabel.toUpperCase(),
                          style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress timeline status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAllotted ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                      color: badgeColor,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.subStatusLabel,
                        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Investment Amount', style: TextStyle(color: textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '₹${order.orderAmount.toStringAsFixed(2)}',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.nseTrxnOrderId != null && order.nseTrxnOrderId!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('NSE Order Ref', style: TextStyle(color: textSecondary, fontSize: 11)),
                          const SizedBox(height: 2),
                          FittedBox(
                            alignment: Alignment.center,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '#${order.nseTrxnOrderId}',
                              style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Order Date', style: TextStyle(color: textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        FittedBox(
                          alignment: Alignment.centerRight,
                          fit: BoxFit.scaleDown,
                          child: Text(dateStr, style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 12.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: badgeColor, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Allotment expected: ${order.expectedAllotmentDate} (T+1 business day)',
                        style: TextStyle(color: badgeColor, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              if (!order.isPaymentDone && order.paymentLink != null && order.paymentLink!.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.openNsePaymentGateway(
                        order.paymentLink!,
                        title: 'NSE Gateway Payment',
                        message: 'Official NSE portal opened for ${order.schemeName}. Complete payment to confirm allotment.',
                      );
                    },
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text('Complete Payment via NSE Gateway', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09C),
                      foregroundColor: const Color(0xFF0F141E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Modern Active SIPs Tab
  // ══════════════════════════════════════════════════════════════
  Widget _buildSipsTab(Color surface, Color textPrimary, Color textSecondary, bool dark) {
    if (controller.activeSips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_repeat_rounded, color: Color(0xFF00D09C), size: 48),
              ),
              const SizedBox(height: 16),
              Text('No Active SIPs', style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Set up automated monthly wealth building in top Indian mutual funds.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09C),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(0, 46),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Start a Monthly SIP', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                onPressed: () => Get.toNamed(AppRoutes.mutualFunds),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: controller.activeSips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sip = controller.activeSips[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: dark ? const Color(0xFF22314E) : const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AmcBrandLogo(
                    amcName: '',
                    schemeName: sip.schemeName,
                    size: 38,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      sip.schemeName,
                      style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.35)),
                    ),
                    child: const Text(
                      'ACTIVE SIP',
                      style: TextStyle(color: Color(0xFF00D09C), fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monthly Installment', style: TextStyle(color: textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${sip.installmentAmount.toInt()}/month',
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Installments Completed', style: TextStyle(color: textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '${sip.installmentsPaid} paid',
                          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF00D09C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sip.nextDueDate != null
                                ? 'Next AutoPay: ${sip.nextDueDate!.day}/${sip.nextDueDate!.month}/${sip.nextDueDate!.year}'
                                : 'Reg No: ${sip.sipRegNo}',
                            style: TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: () => _showCancelSipDialog(context, sip, surface, textPrimary, textSecondary),
                    icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 14),
                    label: const Text('Cancel SIP', style: TextStyle(color: Colors.redAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SIP Cancellation Dialog
  // ══════════════════════════════════════════════════════════════
  void _showCancelSipDialog(BuildContext context, dynamic sip, Color surface, Color textPrimary, Color textSecondary) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text('Cancel SIP?', style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel your monthly SIP of ₹${sip.installmentAmount.toInt()} for ${sip.schemeName}?\n\nThis will submit an official cancellation request to the NSE MFSS exchange and stop all future AutoPay deductions from your bank mandate.',
          style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Active', style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isCancellingSip.value
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await controller.cancelSip(sip.id);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 38),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isCancellingSip.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Yes, Cancel SIP', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // Add Investment Flow
  // ══════════════════════════════════════════════════════════════
  Future<void> _openAddInvestmentForHolding(BuildContext context, dynamic item, {bool isSip = false}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF00D09C))),
    );

    final scheme = await controller.getSchemeByCode(item.schemeCode);
    if (context.mounted) Navigator.pop(context);

    if (scheme != null && context.mounted) {
      MfInvestmentCheckoutSheet.show(context, scheme, isSip: isSip);
    } else if (context.mounted) {
      Get.snackbar(
        'Notice',
        'Could not load scheme details for ${item.schemeName}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // ══════════════════════════════════════════════════════════════
  // Redemption Sheet (Authoritative NSE MFSS Redemption Flow)
  // ══════════════════════════════════════════════════════════════
  void _showRedemptionSheet(BuildContext context, dynamic item, Color surface, Color textPrimary, Color textSecondary) {
    final unitsCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String redeemMode = 'UNITS';
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

                    // Summary Card
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

                    // Redeem Mode Toggle
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

                    // Input Field & Percentage Chips
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

                    // Estimated Calculation Banner
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

                    // Registered Bank Notice
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
                                Text('Direct Payout Bank Account', style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
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
                            'Estimated amount only. Final payout is calculated on the NAV of the applicable settlement cut-off date. Proceeds are credited directly to your registered bank account by AMC (T+2/T+3 days).',
                            style: TextStyle(color: textSecondary, fontSize: 10.5, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Confirm Redemption Button
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
