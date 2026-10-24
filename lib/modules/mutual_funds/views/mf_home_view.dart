import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'mf_search_view.dart';
import 'mf_popular_funds_view.dart';
import 'mf_all_mutual_funds_view.dart';
import 'mf_collection_list_view.dart';
import 'mf_ucc_onboarding_view.dart';
import 'widgets/mf_groww_widgets.dart';
import 'mf_nfo_view.dart';
import 'mf_sip_calculator_view.dart';
import 'mf_compare_funds_view.dart';
import 'mf_profile_view.dart';
import 'widgets/mf_skeleton_widgets.dart';
import 'mf_cart_view.dart';
import '../../../data/models/mf_portfolio_model.dart';
import 'mf_portfolio_view.dart';
import 'mf_investment_checkout_sheet.dart';

class MfHomeView extends StatefulWidget {
  const MfHomeView({Key? key}) : super(key: key);

  @override
  State<MfHomeView> createState() => _MfHomeViewState();
}

class _MfHomeViewState extends State<MfHomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MutualFundsController controller = Get.put(MutualFundsController());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchOpen = false;
  final RxBool _hideBalance = false.obs;
  final RxString _selectedSortCriteria = 'Current (High to Low)'.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        controller.fetchPortfolio();
        controller.fetchMyOrders();
      }
    });
    // Explicit "View more funds" button used instead of auto-scroll
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowwColors.background,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // ── Top Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: GrowwColors.mintTeal.withOpacity(0.4), width: 1.5),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Mutual Funds',
                              style: TextStyle(
                                color: GrowwColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.search_rounded,
                                color: GrowwColors.textPrimary,
                                size: 24,
                              ),
                              onPressed: () {
                                Get.to(() => const MfSearchView());
                              },
                            ),
                            Obx(() {
                              final count = controller.cartCount;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: GrowwColors.textPrimary,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      Get.to(() => const MfCartView());
                                    },
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: GrowwColors.mintTeal,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                        child: Text(
                                          '$count',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const MfProfileView());
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: GrowwColors.cardElevated,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: GrowwColors.border, width: 1.5),
                                    ),
                                    child: const Icon(Icons.person_rounded, color: GrowwColors.textSecondary, size: 18),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: GrowwColors.mintTeal,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: GrowwColors.background, width: 1.5),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '₹',
                                        style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Animated in-place Search Bar
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: _isSearchOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      firstChild: const SizedBox(height: 0),
                      secondChild: Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => Get.to(() => const MfSearchView()),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search_rounded, color: Color(0xFF00D09C), size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Search schemes, fund houses, ELSS...',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Groww Top Tabs ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _GrowwTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: GrowwColors.mintTeal,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: GrowwColors.textPrimary,
                  unselectedLabelColor: GrowwColors.textSecondary,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  tabs: const [
                    Tab(text: 'Explore'),
                    Tab(text: 'Dashboard'),
                    Tab(text: 'SIPs'),
                    Tab(text: 'Watchlist'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildExploreTab(),
              _buildDashboardTab(),
              _buildSipsTab(),
              _buildWatchlistTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. EXPLORE TAB (Matches Screenshots 1, 2, 3, 4)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildExploreTab() {
    return Obx(() {
      if (controller.isLoading.value && controller.schemes.isEmpty) {
        return const MfExploreSkeletonView();
      }

      final popular = controller.popularFunds;
      final recent = controller.recentlyViewed;
      final filtered = controller.filteredSchemes;
      return RefreshIndicator(
        color: GrowwColors.mintTeal,
        backgroundColor: GrowwColors.card,
        onRefresh: () async {
          await controller.fetchOnboardingStatus();
        },
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Onboarding / SIP Readiness Suggestion Card ──
          _buildOnboardingReadinessCard(),
          const SizedBox(height: 14),

          // ── A. Hero SIP Banner Card ──
          _buildHeroSipBanner(),
          const SizedBox(height: 24),

          // ── B. Recently Viewed ──
          if (recent.isNotEmpty) ...[
            const Text(
              'Recently viewed',
              style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final s = recent[index];
                  return GestureDetector(
                    onTap: () {
                      controller.recordRecentlyViewed(s);
                      Get.to(() => MfSchemeDetailView(scheme: s));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: GrowwColors.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GrowwColors.border),
                      ),
                      child: Row(
                        children: [
                          AmcBrandLogo(amcName: s.amcName, schemeName: s.schemeName, size: 26, borderRadius: 6),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 160),
                            child: Text(
                              s.schemeName,
                              style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── C. Popular Funds Carousel ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Funds',
                style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(() => const MfPopularFundsView());
                },
                child: const Row(
                  children: [
                    Text('View all', style: TextStyle(color: GrowwColors.mintTeal, fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: GrowwColors.mintTeal, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 172,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popular.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final s = popular[index];
                return GestureDetector(
                  onTap: () {
                    controller.recordRecentlyViewed(s);
                    Get.to(() => MfSchemeDetailView(scheme: s));
                  },
                  child: Container(
                    width: 168,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GrowwColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GrowwColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AmcBrandLogo(amcName: s.amcName, schemeName: s.schemeName, size: 36, borderRadius: 8),
                        if (s.isRecommended) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09C).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.35)),
                            ),
                            child: const Text('⭐ Recommended', style: TextStyle(color: Color(0xFF00D09C), fontSize: 8.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _cleanSchemeName(s.schemeName),
                          style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.cagr3Y != null ? '${s.cagr3Y! >= 0 ? "+" : ""}${s.cagr3Y!.toStringAsFixed(2)}%' : '—',
                              style: TextStyle(
                                color: s.cagr3Y == null
                                    ? GrowwColors.textTertiary
                                    : (s.cagr3Y! < 0 ? const Color(0xFFEF4444) : GrowwColors.mintTeal),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text('3Y', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // ── D. Collections 3D Grid ──
          const Text(
            'Collections',
            style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _buildCollectionsGrid(),
          const SizedBox(height: 28),

          // ── E. Products & Tools ──
          const Text(
            'Products & tools',
            style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          _buildProductsAndTools(),
          const SizedBox(height: 28),

          // ── F. All Mutual Funds Header & Filter Chips ──
          const Text(
            'All Mutual Funds',
            style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFilterChipsRow(),
          const SizedBox(height: 12),

          // Sub-header: Count and Sort toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.totalSchemesCount.value > 0 ? '${controller.totalSchemesCount.value} funds' : '${filtered.length} funds',
                style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  final cur = controller.selectedReturnPeriod.value;
                  final next = cur == '3Y' ? '1Y' : (cur == '1Y' ? '5Y' : '3Y');
                  controller.selectedReturnPeriod.value = next;
                  controller.selectedSort.value = '$next Returns';
                  controller.fetchSchemes(page: 1, isRefresh: true);
                },
                child: Obx(() => Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded, color: GrowwColors.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.selectedReturnPeriod.value} Returns',
                          style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // List of Funds
          if (filtered.isEmpty && controller.isLoading.value)
            const MfFundListSkeleton(itemCount: 4)
          else if (filtered.isEmpty && !controller.isLoading.value)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, color: GrowwColors.textSecondary, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'No mutual funds found',
                    style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Try searching with another scheme name or fund house',
                    style: TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      controller.clearSearch();
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: GrowwColors.mintTeal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Clear Search', style: TextStyle(color: GrowwColors.mintTeal)),
                  ),
                ],
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: GrowwColors.border, height: 1),
              itemBuilder: (context, index) {
                final scheme = filtered[index];
                return _buildSchemeListItem(scheme);
              },
            ),

            // "View more" underlined text link with > arrow -> navigates directly to All Mutual Funds screen
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: InkWell(
                  onTap: () => Get.to(() => const MfAllMutualFundsView()),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          'View more',
                          style: TextStyle(
                            color: GrowwColors.mintTeal,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: GrowwColors.mintTeal,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: GrowwColors.mintTeal, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  });
}


  // ── Onboarding & SIP Readiness Suggestion Card (NSE UCC & AutoPay Mandate) ──
  Widget _buildOnboardingReadinessCard() {
    return Obx(() {
      final step = controller.onboardingStep.value;
      final clientCode = controller.onboardingData['clientCode']?.toString() ?? controller.userUcc.value?.clientCode ?? 'VK143005';
      final isLoading = controller.isOnboardingLoading.value;

      // ── Step 3: Fully Verified / SIP Ready (Compact Reassurance Badge) ──
      if (step == 3) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E1B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GrowwColors.mintTeal.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: GrowwColors.mintTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: GrowwColors.mintTeal, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'SIP & Lump Sum Ready',
                          style: TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: GrowwColors.mintTeal.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'NSE: $clientCode',
                            style: const TextStyle(color: GrowwColors.mintTeal, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'UCC approved • Bank AutoPay active for automated debits',
                      style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 16, color: GrowwColors.textSecondary),
                tooltip: 'Check Status',
                onPressed: () => controller.fetchOnboardingStatus(),
              ),
            ],
          ),
        );
      }

      // ── Step 2: UCC Approved, Bank AutoPay Mandate Pending (USER CURRENT STATE) ──
      if (step == 2) {
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2224), Color(0xFF131722)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GrowwColors.mintTeal.withOpacity(0.5), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: GrowwColors.mintTeal.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Icon + Title + Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GrowwColors.mintTeal.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: GrowwColors.mintTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Set Up Bank AutoPay (Step 2 of 2)',
                          style: TextStyle(
                            color: GrowwColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 10),
                                  const SizedBox(width: 3),
                                  Text(
                                    'UCC: $clientCode',
                                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'AutoPay Mandate Required',
                                style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: GrowwColors.mintTeal),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18, color: GrowwColors.textSecondary),
                    tooltip: 'Refresh Status',
                    onPressed: () => controller.fetchOnboardingStatus(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Clarifying Explanation
              const Text(
                'Exchange Rule: Monthly recurring SIPs require an authorized eNACH mandate to debit installments. Set up AutoPay once to prevent exchange rejections, or invest via One-Time Lump Sum instantly.',
                style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Dual Action Buttons Row
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.initiateMandateSetup(context),
                      icon: const Icon(Icons.flash_on_rounded, size: 16, color: Colors.black),
                      label: const Text(
                        'Authorize AutoPay',
                        style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GrowwColors.mintTeal,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLumpSumInstantTipDialog(context),
                      icon: const Icon(Icons.bolt_rounded, size: 15, color: GrowwColors.mintTeal),
                      label: const Text(
                        'Lump Sum (UPI)',
                        style: TextStyle(color: GrowwColors.mintTeal, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: GrowwColors.mintTeal.withOpacity(0.6)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => controller.openUccAuthWebView(context, clientCode: clientCode),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.security_rounded, size: 14, color: GrowwColors.mintTeal),
                      const SizedBox(width: 5),
                      Text(
                        'NSE 2FA Client Authorization (e-Sign/OTP)',
                        style: TextStyle(
                          color: GrowwColors.mintTeal.withOpacity(0.9),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
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

      // ── Step 1: Investor UCC Profile Needed (New User) ──
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF231D12), Color(0xFF131722)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GrowwColors.goldAccent.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: GrowwColors.goldAccent.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GrowwColors.goldAccent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: GrowwColors.goldAccent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete Investor Setup (Step 1 of 2)',
                        style: TextStyle(color: GrowwColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: GrowwColors.goldAccent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NSE MFSS Mandatory',
                          style: TextStyle(color: GrowwColors.goldAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'SEBI regulations require a one-time paperless Investor Profile (PAN, Bank Account & Nominee) before investing on NSE MFSS.',
              style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const MfUccOnboardingView()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GrowwColors.goldAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Start Quick Profile (2 Mins)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
            if (controller.userUcc.value != null || controller.onboardingData['clientCode'] != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => controller.openUccAuthWebView(context, clientCode: clientCode),
                  icon: const Icon(Icons.security_rounded, size: 16, color: GrowwColors.mintTeal),
                  label: const Text('Authorize UCC on NSE (OTP / e-Sign)', style: TextStyle(color: GrowwColors.mintTeal, fontSize: 13, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: GrowwColors.mintTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showLumpSumInstantTipDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Color(0xFF131722),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF222938))),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GrowwColors.mintTeal.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt_rounded, color: GrowwColors.mintTeal, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invest Instantly via Lump Sum',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'No Bank Mandate authorization needed',
                          style: TextStyle(color: GrowwColors.mintTeal, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF181E2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GrowwColors.border),
                ),
                child: Column(
                  children: [
                    _buildInstantBenefitRow(
                      icon: Icons.flash_on_rounded,
                      title: 'Instant UPI / NetBanking Payment',
                      desc: 'One-time investments are paid directly without waiting for bank mandate verification.',
                    ),
                    const Divider(color: GrowwColors.border, height: 20),
                    _buildInstantBenefitRow(
                      icon: Icons.timelapse_rounded,
                      title: 'Same Day NAV Allocation',
                      desc: 'Orders placed before cutoff receive same-day NAV on NSE MFSS.',
                    ),
                    const Divider(color: GrowwColors.border, height: 20),
                    _buildInstantBenefitRow(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Your UCC Profile is Already Active',
                      desc: 'Investor account VK143005 is ready for one-time orders right away.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        controller.initiateMandateSetup(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: GrowwColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Setup AutoPay', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.to(() => const MfPopularFundsView());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GrowwColors.mintTeal,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Explore Funds Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildInstantBenefitRow({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GrowwColors.mintTeal, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Hero SIP Banner ──
  Widget _buildHeroSipBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invest every month and\ngrow your wealth with SIP',
                  style: TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => Get.to(() => const MfSipCalculatorView()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GrowwColors.mintTeal,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(110, 38),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Start a SIP',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/Mutual_Funds/sip_calendar_3d.jpg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month_rounded, color: GrowwColors.mintTeal, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Collections 2x3 Grid ──
  Widget _buildCollectionsGrid() {
    final items = [
      {
        'id': 'high_return',
        'title': 'High return',
        'filter': 'High Return',
        'img': 'assets/images/Mutual_Funds/mf_icon_high_return.jpg',
      },
      {
        'id': 'sip_100',
        'title': 'SIP with ₹100',
        'filter': 'SIP with ₹100',
        'img': 'assets/images/Mutual_Funds/mf_wallet_sip_3d.jpg',
      },
      {
        'id': 'gold_silver',
        'title': 'Gold & Silver Funds',
        'filter': 'Gold & Silver',
        'img': 'assets/images/Mutual_Funds/mf_gold_silver_3d.jpg',
      },
      {
        'id': 'large_cap',
        'title': 'Large Cap',
        'filter': 'Large Cap',
        'img': 'assets/images/Mutual_Funds/mf_icon_large_cap.jpg',
      },
      {
        'id': 'mid_cap',
        'title': 'Mid Cap',
        'filter': 'Mid Cap',
        'img': 'assets/images/Mutual_Funds/mf_icon_mid_cap.jpg',
      },
      {
        'id': 'small_cap',
        'title': 'Small Cap',
        'filter': 'Small Cap',
        'img': 'assets/images/Mutual_Funds/mf_icon_small_cap.jpg',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.95,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final img = item['img']?.toString();
        final title = item['title']?.toString() ?? '';

        return GestureDetector(
          onTap: () {
            Get.to(() => MfCollectionListView(
                  collectionId: item['id']?.toString() ?? 'high_return',
                  title: title,
                  iconAsset: img,
                ));
          },
          child: Container(
            decoration: BoxDecoration(
              color: GrowwColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrowwColors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (img != null && img.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      img,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.wallet_rounded, color: GrowwColors.mintTeal, size: 28),
                    ),
                  )
                else
                  const Icon(Icons.trending_up_rounded, color: GrowwColors.mintTeal, size: 28),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Products & Tools Row ──
  Widget _buildProductsAndTools() {
    final tools = [
      {
        'title': 'Import\nfunds',
        'img': 'assets/images/Mutual_Funds/mf_tool_import.jpg',
        'action': () => _showImportModal(),
      },
      {
        'title': 'NFOs',
        'img': 'assets/images/Mutual_Funds/mf_tool_nfo.jpg',
        'badge': '2',
        'action': () => Get.to(() => const MfNfoView()),
      },
      {
        'title': 'SIP\ncalculator',
        'img': 'assets/images/Mutual_Funds/mf_tool_calculator.jpg',
        'action': () => Get.to(() => const MfSipCalculatorView()),
      },
      {
        'title': 'Compare\nfunds',
        'img': 'assets/images/Mutual_Funds/mf_tool_compare.jpg',
        'action': () => Get.to(() => const MfCompareFundsView()),
      },
      {
        'title': 'Cart',
        'img': 'assets/images/Mutual_Funds/mf_tool_cart.jpg',
        'action': () => Get.to(() => const MfCartView()),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tools.map((t) {
        final badge = t['badge']?.toString();
        final img = t['img']?.toString();
        final title = t['title']?.toString() ?? '';
        final action = t['action'] as VoidCallback?;

        return GestureDetector(
          onTap: action,
          child: SizedBox(
            width: 60,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GrowwColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: GrowwColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: img != null && img.isNotEmpty
                          ? Image.asset(
                              img,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.apps_rounded, color: GrowwColors.mintTeal, size: 24),
                            )
                          : const Icon(Icons.apps_rounded, color: GrowwColors.mintTeal, size: 24),
                    ),
                    if (badge != null && badge.isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: GrowwColors.mintTeal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500, height: 1.1),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Filter Chips Row ──
  Widget _buildFilterChipsRow() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Filter Icon Button
          GestureDetector(
            onTap: () => _showSortModal(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: GrowwColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GrowwColors.border),
              ),
              child: const Icon(Icons.tune_rounded, color: GrowwColors.mintTeal, size: 18),
            ),
          ),
          // Sort by Chip
          GestureDetector(
            onTap: () => _showSortModal(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: GrowwColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GrowwColors.border),
              ),
              child: Row(
                children: [
                  Obx(() => Text(
                        controller.selectedSort.value,
                        style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: GrowwColors.textSecondary, size: 18),
                ],
              ),
            ),
          ),
          // Filter Chips
          ...controller.filterChips.map((chip) {
            return Obx(() {
              final isSelected = controller.selectedFilterChip.value == chip;
              return GestureDetector(
                onTap: () => controller.onFilterChipSelected(chip),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? GrowwColors.mintTeal.withOpacity(0.15) : GrowwColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? GrowwColors.mintTeal : GrowwColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chip,
                    style: TextStyle(
                      color: isSelected ? GrowwColors.mintTeal : GrowwColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ],
      ),
    );
  }

  // ── Scheme List Item (Matching Screenshot 3) ──
  Widget _buildSchemeListItem(MfSchemeModel scheme) {
    return InkWell(
      onTap: () {
        controller.recordRecentlyViewed(scheme);
        Get.to(() => MfSchemeDetailView(scheme: scheme));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            AmcBrandLogo(amcName: scheme.amcName, schemeName: scheme.schemeName, size: 40, borderRadius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _cleanSchemeName(scheme.schemeName),
                    style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, height: 1.25),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (scheme.isRecommended) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D09C).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.35)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⭐ ', style: TextStyle(fontSize: 8)),
                              Text('Recommended', style: TextStyle(color: Color(0xFF00D09C), fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          '${scheme.category}${scheme.subCategory.isNotEmpty ? " • ${scheme.subCategory}" : ""}',
                          style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (scheme.rating != null && scheme.rating! > 0) ...[
                        const SizedBox(width: 4),
                        const Text('•', style: TextStyle(color: GrowwColors.textTertiary, fontSize: 10)),
                        const SizedBox(width: 4),
                        Text('${scheme.rating}', style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                        const SizedBox(width: 2),
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Obx(() {
              final period = controller.selectedReturnPeriod.value;
              final returnVal = period == '1Y' ? scheme.cagr1Y : (period == '5Y' ? scheme.cagr5Y : scheme.cagr3Y);
              final bool hasReturn = returnVal != null && returnVal != 0;
              final String retStr = hasReturn
                  ? '${returnVal >= 0 ? "+" : ""}${returnVal.toStringAsFixed(2)}%'
                  : '—';
              final Color retColor = !hasReturn
                  ? GrowwColors.textTertiary
                  : (returnVal < 0 ? const Color(0xFFEF4444) : GrowwColors.mintTeal);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    retStr,
                    style: TextStyle(color: retColor, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(period, style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _cleanSchemeName(String name) {
    var s = name
        .replaceAll(RegExp(r'\s*-\s*Regular\s+Plan\s*-\s*Growth(\s+Option)?', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Regular\s+Plan\s*-\s*Regular\s+Growth', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Regular\s+Plan\s*-\s*GROWTH\s*OPTION', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Regular\s+Plan\s*-\s*GROWTH', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Regular\s+Plan', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Direct\s+Plan\s*-\s*Growth(\s+Option)?', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Direct\s+Plan', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Growth\s+Option', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Growth', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*\(Erstwhile[^\)]*\)', caseSensitive: false), '')
        .trim();

    if (s.startsWith('BANDHAN ')) {
      s = 'Bandhan ${s.substring(8)}';
    } else if (s.startsWith('BANK OF INDIA ')) {
      s = 'Bank of India ${s.substring(14)}';
    } else if (s.startsWith('QUANTUM ')) {
      s = 'Quantum ${s.substring(8)}';
    } else if (s.startsWith('TRUSTMF ')) {
      s = 'Trust ${s.substring(8)}';
    } else if (s.startsWith('SBI SMALL CAP FUND')) {
      s = 'SBI Small Cap Fund';
    }
    return s;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. DASHBOARD TAB (Groww Dashboard: Hero Card, Sort, Holdings & Actions)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    return Obx(() {
      final holdings = controller.holdings;
      final inProgress = controller.inProgressOrders;
      final summary = controller.portfolioSummary.value;

      if (controller.isPortfolioLoading.value && holdings.isEmpty && inProgress.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal));
      }

      if (holdings.isEmpty) {
        if (inProgress.isNotEmpty) {
          return RefreshIndicator(
            color: GrowwColors.mintTeal,
            backgroundColor: GrowwColors.card,
            onRefresh: () async {
              await Future.wait([
                controller.fetchPortfolio(),
                controller.fetchMyOrders(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Orders in progress (${inProgress.length})',
                          style: const TextStyle(
                            color: GrowwColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showAllOrdersSheet(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All Orders',
                        style: TextStyle(color: GrowwColors.mintTeal, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...inProgress.map((order) => _buildInProgressOrderCard(order)),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                        const Text(
                          'Orders Awaiting Allotment',
                          style: TextStyle(color: GrowwColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your mutual fund purchases have been submitted to NSE MFSS. Units will appear here once allotted by the AMC.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: GrowwColors.mintTeal,
          backgroundColor: GrowwColors.card,
          onRefresh: () async {
            await Future.wait([
              controller.fetchPortfolio(),
              controller.fetchMyOrders(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: GrowwColors.mintTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pie_chart_outline_rounded, color: GrowwColors.mintTeal, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'No Mutual Fund Holdings Yet',
                  style: TextStyle(color: GrowwColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Start systematic wealth accumulation in top Regular mutual funds with live NSE execution.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13, height: 1.4),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GrowwColors.mintTeal,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.trending_up_rounded, size: 18),
                  label: const Text('Explore Mutual Funds', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  onPressed: () => _tabController.animateTo(0),
                ),
              ),
            ],
          ),
        );
      }

      final sorted = _sortedHoldings;

      return RefreshIndicator(
        color: GrowwColors.mintTeal,
        backgroundColor: GrowwColors.card,
        onRefresh: () async {
          await Future.wait([
            controller.fetchPortfolio(),
            controller.fetchMyOrders(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            // In-progress orders banner if any
            if (inProgress.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Orders in progress (${inProgress.length})',
                          style: const TextStyle(
                            color: GrowwColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showAllOrdersSheet(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All Orders',
                        style: TextStyle(color: GrowwColors.mintTeal, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildInProgressOrderCard(inProgress.first),
              ),
              const SizedBox(height: 10),
            ],

            // 1. Groww Hero Card (HOLDINGS X, Eye Toggle, 1D & Total Returns in RED/GREEN, Invested, XIRR)
            _buildGrowwHeroCard(summary),

            // 2. Sort & Filter Row (< > Current (Invested))
            _buildFilterSortRow(),

            // 3. Holdings List (Scheme Name, Logo, Current Value, Invested, Loss in RED with -, Profit in GREEN with +)
            ...sorted.map((item) => _buildGrowwHoldingItem(item)),

            // 4. Promotional SIP Banner
            _buildSipPromotionBanner(),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Groww Hero Summary Card
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildGrowwHeroCard(dynamic summary) {
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
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GrowwColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
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
                    style: const TextStyle(
                      color: GrowwColors.textSecondary,
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
                        color: GrowwColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showPortfolioAnalyticsModal(context),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.insights_rounded,
                    size: 18,
                    color: GrowwColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Big Current Valuation
          _hideBalance.value
              ? const Text(
                  '••••••••',
                  style: TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : Text(
                  '₹${_formatCurrency(valuation, showDecimals: true)}',
                  style: const TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
          const SizedBox(height: 14),

          // Divider
          Container(
            height: 1,
            color: GrowwColors.border,
          ),
          const SizedBox(height: 12),

          // Row 1: 1D returns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1D returns',
                style: TextStyle(
                  color: GrowwColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _hideBalance.value
                  ? const Text('••••', style: TextStyle(fontWeight: FontWeight.bold, color: GrowwColors.textPrimary))
                  : _buildReturnBadge(day1Amount, day1Pct, isLarge: true),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Container(
            height: 1,
            color: GrowwColors.border,
          ),
          const SizedBox(height: 10),

          // Row 2: Total returns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total returns',
                style: TextStyle(
                  color: GrowwColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _hideBalance.value
                  ? const Text('••••', style: TextStyle(fontWeight: FontWeight.bold, color: GrowwColors.textPrimary))
                  : _buildReturnBadge(pnl, pnlPct, isLarge: true),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Container(
            height: 1,
            color: GrowwColors.border,
          ),
          const SizedBox(height: 10),

          // Row 3: Invested
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invested',
                style: TextStyle(
                  color: GrowwColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _hideBalance.value
                  ? const Text('••••', style: TextStyle(fontWeight: FontWeight.bold, color: GrowwColors.textPrimary))
                  : Text(
                      '₹${_formatCurrency(invested, showDecimals: true)}',
                      style: const TextStyle(
                        color: GrowwColors.textPrimary,
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
              color: GrowwColors.border,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'XIRR',
                      style: TextStyle(
                        color: GrowwColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: GrowwColors.textTertiary,
                    ),
                  ],
                ),
                Text(
                  '${xirr.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: xirr >= 0 ? GrowwColors.mintTeal : GrowwColors.negativeRed,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Sort & Filter Row (< > Current (Invested))
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterSortRow() {
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
                color: GrowwColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GrowwColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.unfold_more_rounded,
                    size: 15,
                    color: GrowwColors.mintTeal,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _selectedSortCriteria.value.startsWith('Current')
                        ? 'Current (Invested)'
                        : 'Invested (Current)',
                    style: const TextStyle(
                      color: GrowwColors.textPrimary,
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
            onTap: () => _showSortOptionsBottomSheet(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GrowwColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GrowwColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 15,
                    color: GrowwColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      color: GrowwColors.textSecondary,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Groww Holding Card Item (Tap opens action sheet)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildGrowwHoldingItem(MfHolding item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrowwColors.border, width: 1),
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
                        style: const TextStyle(
                          color: GrowwColors.textPrimary,
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
                              style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                            )
                          else
                            Text(
                              item.category ?? 'REGULAR PLAN',
                              style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
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
                        ? const Text('••••', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700))
                        : Text(
                            '₹${_formatCurrency(item.currentValue, showDecimals: true)}',
                            style: const TextStyle(
                              color: GrowwColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    const SizedBox(height: 2),

                    // Invested Amount
                    _hideBalance.value
                        ? const Text('••••', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11))
                        : Text(
                            '(Invested ₹${_formatCurrency(item.investedAmount, showDecimals: false)})',
                            style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                          ),
                    const SizedBox(height: 3),

                    // Profit / Loss (STRICT: Negative in RED with - sign, Positive in GREEN with + sign)
                    _hideBalance.value
                        ? const Text('••••', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: GrowwColors.textPrimary))
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Promotional SIP Banner Card
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSipPromotionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GrowwColors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invest every month and grow your wealth with SIP',
                  style: TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Automate your investments with zero manual intervention.',
                  style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11.5, height: 1.3),
                ),
                const SizedBox(height: 12),
                Material(
                  color: GrowwColors.mintTeal,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: () => _tabController.animateTo(0),
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
              color: GrowwColors.mintTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrowwColors.mintTeal.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: GrowwColors.mintTeal,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Holding Action Bottom Sheet (Screenshot 2: Redeem, Details, One Time, Start SIP)
  // ═══════════════════════════════════════════════════════════════════════════
  void _showHoldingActionSheet(BuildContext context, MfHolding item) {
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
          decoration: const BoxDecoration(
            color: GrowwColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.white24,
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
                              style: const TextStyle(
                                color: GrowwColors.textPrimary,
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
                              style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: GrowwColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: GrowwColors.border),

              // Current Value & Returns Sub-Card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: GrowwColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GrowwColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Current Value', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              '₹${_formatCurrency(item.currentValue, showDecimals: true)}',
                              style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '(Invested ₹${_formatCurrency(item.investedAmount, showDecimals: false)})',
                              style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 40, width: 1, color: GrowwColors.border),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Total Returns', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                            const SizedBox(height: 4),
                            _buildReturnBadge(pnl, pnlPct),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('1D: ', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
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
                title: const Text('Redeem', style: TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Withdraw units or amount directly to bank', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: GrowwColors.textSecondary),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showRedemptionSheet(context, item);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: GrowwColors.mintTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long_outlined, color: GrowwColors.mintTeal, size: 18),
                ),
                title: const Text('Investment details', style: TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Holding summary, NAV history, tax splits, & bank info', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: GrowwColors.textSecondary),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showInvestmentDetailsView(context, item);
                },
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: GrowwColors.border),

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
                          side: const BorderSide(color: GrowwColors.border, width: 1.2),
                          foregroundColor: GrowwColors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'One Time',
                          style: TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
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
                          backgroundColor: GrowwColors.mintTeal,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Dedicated Investment Details View (Screenshot 3)
  // ═══════════════════════════════════════════════════════════════════════════
  void _showInvestmentDetailsView(BuildContext context, MfHolding item) {
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
          decoration: const BoxDecoration(
            color: GrowwColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: GrowwColors.textPrimary),
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
                                style: const TextStyle(
                                  color: GrowwColors.textPrimary,
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
                                style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: GrowwColors.border),

              // Scrollable Details
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    // Card 1: CURRENT (Screenshot 3)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: GrowwColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GrowwColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT',
                            style: TextStyle(
                              color: GrowwColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${_formatCurrency(item.currentValue, showDecimals: true)}',
                            style: const TextStyle(
                              color: GrowwColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('1D returns', _buildReturnBadge(day1Amount, day1Pct), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Total returns', _buildReturnBadge(pnl, pnlPct), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Invested', Text('₹${_formatCurrency(item.investedAmount, showDecimals: true)}', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('XIRR', const Text('14.2%', style: TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Long-term', Text('₹${_formatCurrency(item.currentValue, showDecimals: true)}', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Short-term', const Text('₹0.00', style: TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: HOLDING DETAILS (Screenshot 3)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: GrowwColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GrowwColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HOLDING DETAILS',
                            style: TextStyle(
                              color: GrowwColors.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow('Current NAV', Text('₹${_formatCurrency(item.currentNav, showDecimals: true)}', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Total Units', Text(item.totalUnits.toStringAsFixed(3), style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Available Units', Text(item.availableUnits.toStringAsFixed(3), style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Average NAV', Text(item.averageNav != null ? '₹${_formatCurrency(item.averageNav!, showDecimals: true)}' : '—', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Folio Number', Text(item.folioNo != null && item.folioNo!.isNotEmpty ? item.folioNo! : '—', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Registered Bank', Text('$bankName $maskedAcc', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                          const Divider(height: 20, color: GrowwColors.border),
                          _buildDetailRow('Nominee', const Text('Registered', style: TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13.5)), GrowwColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Bottom Buttons (Screenshot 3)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  color: GrowwColors.card,
                  border: Border(top: BorderSide(color: GrowwColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (item.availableUnits > 0.0001 || item.totalUnits > 0.0001)
                            ? () {
                                Navigator.pop(modalCtx);
                                _showRedemptionSheet(context, item);
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
                          backgroundColor: GrowwColors.mintTeal,
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Authoritative Redemption Bottom Sheet
  // ═══════════════════════════════════════════════════════════════════════════
  void _showRedemptionSheet(BuildContext context, dynamic item) {
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
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFF59E0B), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Redeem ${item.schemeName}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Available Units: ${availableUnits.toStringAsFixed(3)} (Max: ₹${maxRedeemableAmount.toStringAsFixed(2)})',
                                style: const TextStyle(color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Toggle: By Units vs By Amount
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                redeemMode = 'UNITS';
                                allUnits = false;
                                unitsCtrl.clear();
                                enteredUnits = 0.0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: redeemMode == 'UNITS' ? const Color(0xFF00D09C) : const Color(0xFF1E2538),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Redeem by Units',
                                  style: TextStyle(
                                    color: redeemMode == 'UNITS' ? Colors.black : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                redeemMode = 'AMOUNT';
                                allUnits = false;
                                amountCtrl.clear();
                                enteredAmount = 0.0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: redeemMode == 'AMOUNT' ? const Color(0xFF00D09C) : const Color(0xFF1E2538),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Redeem by Amount (₹)',
                                  style: TextStyle(
                                    color: redeemMode == 'AMOUNT' ? Colors.black : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (redeemMode == 'UNITS') ...[
                      TextField(
                        controller: unitsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Enter Units to Redeem',
                          labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                          suffixText: 'Units',
                          suffixStyle: const TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: const Color(0xFF1A2133),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00D09C))),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            enteredUnits = double.tryParse(val.trim()) ?? 0.0;
                            allUnits = (enteredUnits >= availableUnits - 0.0001);
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildQuickChip('25%', () {
                            final u = double.parse((availableUnits * 0.25).toStringAsFixed(3));
                            unitsCtrl.text = u.toString();
                            setModalState(() {
                              enteredUnits = u;
                              allUnits = false;
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('50%', () {
                            final u = double.parse((availableUnits * 0.50).toStringAsFixed(3));
                            unitsCtrl.text = u.toString();
                            setModalState(() {
                              enteredUnits = u;
                              allUnits = false;
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('All Units (${availableUnits.toStringAsFixed(3)})', () {
                            unitsCtrl.text = availableUnits.toStringAsFixed(3);
                            setModalState(() {
                              enteredUnits = availableUnits;
                              allUnits = true;
                            });
                          }, isAccent: true),
                        ],
                      ),
                    ] else ...[
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Enter Payout Amount',
                          labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 16),
                          filled: true,
                          fillColor: const Color(0xFF1A2133),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00D09C))),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            enteredAmount = double.tryParse(val.trim()) ?? 0.0;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildQuickChip('₹500', () {
                            amountCtrl.text = '500';
                            setModalState(() => enteredAmount = 500.0);
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('₹1,000', () {
                            amountCtrl.text = '1000';
                            setModalState(() => enteredAmount = 1000.0);
                          }),
                          const SizedBox(width: 8),
                          _buildQuickChip('Max (₹${maxRedeemableAmount.toInt()})', () {
                            final amt = maxRedeemableAmount.floorToDouble();
                            amountCtrl.text = amt.toInt().toString();
                            setModalState(() {
                              enteredAmount = amt;
                              allUnits = true;
                            });
                          }, isAccent: true),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181F30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Estimated Payout', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '₹${estPayout.toStringAsFixed(2)}',
                                style: const TextStyle(color: Color(0xFF00D09C), fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Units to Deduct', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '${estUnits.toStringAsFixed(3)} Units',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Crediting Bank', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              Text(
                                '$bankName $maskedAcc',
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Add Investment Helper (One Time vs Start SIP)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _openAddInvestmentForHolding(BuildContext context, dynamic item, {bool isSip = false}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal)),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Sort Options Bottom Sheet
  // ═══════════════════════════════════════════════════════════════════════════
  void _showSortOptionsBottomSheet(BuildContext context) {
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
          decoration: const BoxDecoration(
            color: GrowwColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sort Holdings By',
                style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
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
                      color: isSelected ? GrowwColors.mintTeal : GrowwColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: GrowwColors.mintTeal, size: 18)
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Portfolio Analytics Breakdown Modal
  // ═══════════════════════════════════════════════════════════════════════════
  void _showPortfolioAnalyticsModal(BuildContext context) {
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
          decoration: const BoxDecoration(
            color: GrowwColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.pie_chart_rounded, color: GrowwColors.mintTeal, size: 20),
                  SizedBox(width: 8),
                  Text('Portfolio Breakdown', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 16),
              if (totalVal <= 0)
                const Text('No active holdings to analyze.', style: TextStyle(color: GrowwColors.textSecondary))
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
                            Text(e.key, style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('₹${_formatCurrency(e.value, showDecimals: true)} (${pct.toStringAsFixed(1)}%)', style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            backgroundColor: GrowwColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(GrowwColors.mintTeal),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // Financial Format Helpers
  // ═══════════════════════════════════════════════════════════════════════════
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

  static Widget _buildDetailRow(String label, Widget valueWidget, Color labelColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 13, fontWeight: FontWeight.w500)),
        valueWidget,
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SIPS TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSipsTab() {
    return Obx(() {
      final sips = controller.activeSips;

      if (sips.isEmpty) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildOnboardingReadinessCard(),
            const SizedBox(height: 24),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/Mutual_Funds/mf_wallet_sip_3d.jpg',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.autorenew_rounded, color: GrowwColors.mintTeal, size: 50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('No Active SIPs', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Automate your wealth building. Start an instant SIP starting at ₹100.', textAlign: TextAlign.center, style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _tabController.animateTo(0),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GrowwColors.mintTeal,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Start a SIP', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sip = sips[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrowwColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrowwColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(sip.schemeName, style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GrowwColors.mintTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: GrowwColors.mintTeal, fontSize: 11, fontWeight: FontWeight.bold)),
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
                        const Text('Installment Amount', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                        Text('₹${sip.installmentAmount.toInt()}/mo', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Installments Paid', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                        Text('${sip.installmentsPaid} paid', style: const TextStyle(color: GrowwColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. WATCHLIST TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWatchlistTab() {
    return Obx(() {
      final list = controller.watchlistSchemes;

      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: GrowwColors.mintTeal.withOpacity(0.4), width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Your Watchlist is empty', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Bookmark funds to track their live returns and NAV changes in one place.', textAlign: TextAlign.center, style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GrowwColors.mintTeal,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Explore Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(color: GrowwColors.border, height: 1),
        itemBuilder: (context, index) {
          final s = list[index];
          return _buildSchemeListItem(s);
        },
      );
    });
  }

  // ── Helper Dialogs / Sheets ──
  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GrowwColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final options = ['3Y Returns', '1Y Returns', 'Rating', 'Min. SIP (Low to High)'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sort Funds By', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                ...options.map((opt) {
                  return Obx(() {
                    final isSelected = controller.selectedSort.value == opt;
                    return ListTile(
                      title: Text(
                        opt,
                        style: TextStyle(
                          color: isSelected ? GrowwColors.mintTeal : GrowwColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_rounded, color: GrowwColors.mintTeal) : null,
                      onTap: () {
                        controller.selectedSort.value = opt;
                        Navigator.pop(ctx);
                      },
                    );
                  });
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImportModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: GrowwColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.download_rounded, color: GrowwColors.mintTeal, size: 28),
                SizedBox(width: 10),
                Text('Import Mutual Funds', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Track external mutual funds invested through other platforms (Zerodha, Paytm, Banks). Generate your free CAS from CAMS/KFintech and import here.',
              style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GrowwColors.mintTeal,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Fetch via OTP (Coming Soon)', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── In-Progress Order Tracking (Groww / Fisdom Style) ──

  Widget _buildInProgressOrderCard(MfOrderModel order) {
    final bool isAllotted = order.allotmentStatus == 'ALLOTTED';
    final Color badgeColor = isAllotted ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final String dateStr = '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';

    return GestureDetector(
      onTap: () => _showOrderDetailSheet(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GrowwColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: badgeColor.withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isAllotted ? Icons.check_circle_rounded : Icons.sync_rounded,
                    color: badgeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.schemeName,
                        style: const TextStyle(
                          color: GrowwColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.typeLabel} • ₹${order.orderAmount.toStringAsFixed(0)} • Placed on $dateStr',
                        style: const TextStyle(
                          color: GrowwColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        order.badgeLabel.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle Status Banner: Clean highlight for Allotment Pending
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2638),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2B364D), width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(
                    isAllotted ? Icons.check_circle_outline_rounded : Icons.hourglass_top_rounded,
                    color: badgeColor,
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.subStatusLabel,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: GrowwColors.border),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: GrowwColors.textSecondary, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Expected Allotment: ${order.expectedAllotmentDate}',
                      style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'Track Order',
                      style: TextStyle(
                        color: GrowwColors.mintTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: GrowwColors.mintTeal, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailSheet(MfOrderModel order) {
    final bool isAllotted = order.allotmentStatus == 'ALLOTTED';
    final Color badgeColor = isAllotted ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final String dateStr = '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';
    final String timeStr = '${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF121B27),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: GrowwColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: GrowwColors.border, height: 1),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header Status Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GrowwColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GrowwColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.typeLabel.toUpperCase(),
                                style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
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
                          const SizedBox(height: 8),
                          Text(
                            order.schemeName,
                            style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.subStatusLabel,
                            style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Amount Paid', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 3),
                                  Text(
                                    '₹${order.orderAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              if (order.nseTrxnOrderId != null && order.nseTrxnOrderId!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('NSE Order ID', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '#${order.nseTrxnOrderId}',
                                      style: const TextStyle(color: GrowwColors.mintTeal, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order Progress / Timeline Stepper
                    const Text(
                      'Order Progress',
                      style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    _buildTimelineStep(
                      stepNumber: 1,
                      title: 'Order Placed & Registered',
                      subtitle: 'Order registered on NSE MFSS on $dateStr at $timeStr',
                      isCompleted: true,
                      isCurrent: false,
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      stepNumber: 2,
                      title: 'Payment Successful',
                      subtitle: '₹${order.orderAmount.toStringAsFixed(0)} verified via NSE Gateway / Mandate',
                      isCompleted: order.isPaymentDone,
                      isCurrent: !order.isPaymentDone,
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      stepNumber: 3,
                      title: 'Sent to AMC / Fund House',
                      subtitle: 'Order approved by exchange and submitted to the Mutual Fund house',
                      isCompleted: order.orderStatus == 'PROCESSING' || isAllotted,
                      isCurrent: order.orderStatus == 'PROCESSING' && !isAllotted,
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      stepNumber: 4,
                      title: 'NAV Calculation',
                      subtitle: isAllotted
                          ? 'Allotted at NAV ₹${order.allottedNav?.toStringAsFixed(2) ?? 'closing NAV'}'
                          : 'Units will be allotted at today\'s market close NAV (calculated between 9 PM - 11 PM)',
                      isCompleted: isAllotted,
                      isCurrent: !isAllotted && (order.orderStatus == 'PROCESSING' || order.isPaymentDone),
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      stepNumber: 5,
                      title: 'Unit Allotment & Demat/Folio Credit',
                      subtitle: isAllotted
                          ? '${order.allottedUnits.toStringAsFixed(3)} units credited to your holdings'
                          : 'Expected by ${order.expectedAllotmentDate} (T+1 business day)',
                      isCompleted: isAllotted,
                      isCurrent: false,
                      isLast: true,
                    ),

                    const SizedBox(height: 24),

                    // Informational Box (Groww / Fisdom style)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GrowwColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GrowwColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: GrowwColors.mintTeal, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'How Mutual Fund Allotment Works',
                                  style: TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unlike stocks, mutual fund NAV is declared by AMCs at the end of each business day. RTAs (CAMS/KFintech) allot units on T+1 working day. Your portfolio value and units will automatically update as soon as the AMC confirms allotment.',
                                  style: TextStyle(color: GrowwColors.textSecondary.withOpacity(0.9), fontSize: 12, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GrowwColors.mintTeal,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Got It', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildTimelineStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final Color color = isCompleted
        ? const Color(0xFF00D09C)
        : isCurrent
            ? const Color(0xFFF59E0B)
            : Colors.white24;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.5),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Color(0xFF00D09C), size: 15)
                    : isCurrent
                        ? const Icon(Icons.hourglass_top_rounded, color: Color(0xFFF59E0B), size: 13)
                        : Text(
                            '$stepNumber',
                            style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isCompleted ? const Color(0xFF00D09C).withOpacity(0.6) : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted || isCurrent ? GrowwColors.textPrimary : GrowwColors.textSecondary,
                    fontSize: 14,
                    fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isCurrent ? const Color(0xFFF59E0B) : GrowwColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAllOrdersSheet(BuildContext context) {
    controller.fetchMyOrders();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF121B27),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Mutual Fund Orders',
                      style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: GrowwColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: GrowwColors.border, height: 1),
              Expanded(
                child: Obx(() {
                  if (controller.isOrdersLoading.value && controller.myOrders.isEmpty && controller.inProgressOrders.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal));
                  }

                  final orders = controller.myOrders.isNotEmpty ? controller.myOrders : controller.inProgressOrders;

                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, color: GrowwColors.textSecondary.withOpacity(0.5), size: 54),
                          const SizedBox(height: 12),
                          const Text('No Orders Found', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Your purchase and redemption orders will appear here', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildInProgressOrderCard(order);
                    },
                  );
                }),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Get.to(() => const MfPortfolioView());
                      },
                      icon: const Icon(Icons.pie_chart_rounded, size: 18, color: GrowwColors.mintTeal),
                      label: const Text('Go to Full Portfolio', style: TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: GrowwColors.mintTeal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GrowwTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _GrowwTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: GrowwColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_GrowwTabBarDelegate oldDelegate) => false;
}
