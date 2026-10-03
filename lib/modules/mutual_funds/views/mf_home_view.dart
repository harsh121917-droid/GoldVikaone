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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                                'assets/images/Mutual_Funds/mf_brand_logo_3d.jpg',
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
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
                            GestureDetector(
                              onTap: () {
                                if (controller.hasUcc.value) {
                                  Get.snackbar(
                                    'NSE Verified',
                                    'UCC: ${controller.userUcc.value?.clientCode ?? "Active"}',
                                    backgroundColor: GrowwColors.cardElevated,
                                    colorText: GrowwColors.textPrimary,
                                  );
                                } else {
                                  Get.to(() => const MfUccOnboardingView());
                                }
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
                  indicatorColor: GrowwColors.mintTeal,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: GrowwColors.textPrimary,
                  unselectedLabelColor: GrowwColors.textSecondary,
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
        return const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal));
      }

      final popular = controller.popularFunds;
      final recent = controller.recentlyViewed;
      final filtered = controller.filteredSchemes;

      return ListView(
        controller: _scrollController,
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
                          s.schemeName,
                          style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.cagr3Y != null ? '+${s.cagr3Y}%' : '—',
                              style: const TextStyle(color: GrowwColors.mintTeal, fontSize: 14, fontWeight: FontWeight.w900),
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
                  if (cur == '3Y') {
                    controller.selectedReturnPeriod.value = '1Y';
                  } else if (cur == '1Y') {
                    controller.selectedReturnPeriod.value = '5Y';
                  } else {
                    controller.selectedReturnPeriod.value = '3Y';
                  }
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
          if (filtered.isEmpty && !controller.isLoading.value)
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
        'action': () => _showCartModal(),
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
                    scheme.schemeName,
                    style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
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
                      Text(scheme.category, style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 4),
                      const Text('•', style: TextStyle(color: GrowwColors.textTertiary, fontSize: 10)),
                      const SizedBox(width: 4),
                      Text('${scheme.rating}', style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                      const SizedBox(width: 2),
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              final period = controller.selectedReturnPeriod.value;
              final returnVal = period == '1Y' ? scheme.cagr1Y : (period == '5Y' ? scheme.cagr5Y : scheme.cagr3Y);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    returnVal != null ? '${returnVal > 0 ? "+" : ""}${returnVal}%' : '—',
                    style: const TextStyle(color: GrowwColors.mintTeal, fontSize: 14, fontWeight: FontWeight.w900),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. DASHBOARD TAB
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDashboardTab() {
    return Obx(() {
      if (controller.isPortfolioLoading.value && controller.holdings.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal));
      }

      final summary = controller.portfolioSummary.value;
      final holdings = controller.holdings;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Portfolio Value Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF141D2B), Color(0xFF0F1722)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GrowwColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Portfolio Value', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '₹${summary?.currentValuation.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Invested', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${summary?.totalInvested.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Overall Return', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: GrowwColors.mintTeal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${summary?.totalProfitLoss.toStringAsFixed(2) ?? '0.00'} (+${summary?.totalProfitLossPct.toStringAsFixed(2) ?? '0.00'}%)',
                            style: const TextStyle(color: GrowwColors.mintTeal, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Holdings
          const Text(
            'Your Investments',
            style: TextStyle(color: GrowwColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (holdings.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: GrowwColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GrowwColors.border),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/Mutual_Funds/mf_empty_portfolio_3d.jpg',
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('No investments yet', style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Start investing in direct mutual funds with 0% brokerage', textAlign: TextAlign.center, style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GrowwColors.mintTeal,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Explore Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          else
            ...holdings.map((h) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GrowwColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: GrowwColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.schemeName, style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Invested', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                              Text('₹${h.investedAmount.toStringAsFixed(0)}', style: const TextStyle(color: GrowwColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Current Value', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11)),
                              Text('₹${h.currentValue.toStringAsFixed(0)}', style: const TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      );
    });
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
                    'assets/images/Mutual_Funds/mf_brand_logo_3d.jpg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
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

  void _showCartModal() {
    Get.snackbar(
      'Mutual Funds Cart',
      'No pending orders in cart.',
      backgroundColor: GrowwColors.cardElevated,
      colorText: GrowwColors.textPrimary,
      snackPosition: SnackPosition.BOTTOM,
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
