import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'mf_ucc_onboarding_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfHomeView extends StatefulWidget {
  const MfHomeView({Key? key}) : super(key: key);

  @override
  State<MfHomeView> createState() => _MfHomeViewState();
}

class _MfHomeViewState extends State<MfHomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MutualFundsController controller = Get.put(MutualFundsController());
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
                              icon: Icon(
                                _isSearchOpen ? Icons.close_rounded : Icons.search_rounded,
                                color: GrowwColors.textPrimary,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isSearchOpen = !_isSearchOpen;
                                  if (!_isSearchOpen) {
                                    _searchController.clear();
                                    controller.onSearchChanged('');
                                  }
                                });
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
                        child: TextField(
                          controller: _searchController,
                          onChanged: controller.onSearchChanged,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search schemes, fund houses, ELSS...',
                            hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
                            prefixIcon: const Icon(Icons.search_rounded, color: GrowwColors.mintTeal, size: 20),
                            filled: true,
                            fillColor: GrowwColors.card,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal)),
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
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
                  controller.selectedFilterChip.value = 'High Return';
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
                        const SizedBox(height: 10),
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
                              '+${s.cagr3Y}%',
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
                '${filtered.length} funds',
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
        ],
      );
    });
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
                    onPressed: () => MfSipCalculatorSheet.show(context),
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
        'title': 'High return',
        'filter': 'High Return',
        'img': 'assets/images/Mutual_Funds/mf_icon_high_return.jpg',
      },
      {
        'title': 'SIP with ₹100',
        'filter': 'Small Cap',
        'img': 'assets/images/Mutual_Funds/mf_wallet_sip_3d.jpg',
      },
      {
        'title': 'Gold & Silver Funds',
        'filter': 'Gold & Silver',
        'img': 'assets/images/Mutual_Funds/mf_gold_silver_3d.jpg',
      },
      {
        'title': 'Large Cap',
        'filter': 'Large Cap',
        'img': 'assets/images/Mutual_Funds/mf_icon_large_cap.jpg',
      },
      {
        'title': 'Mid Cap',
        'filter': 'Mid Cap',
        'img': 'assets/images/Mutual_Funds/mf_icon_mid_cap.jpg',
      },
      {
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
        final filter = item['filter']?.toString() ?? 'All';

        return GestureDetector(
          onTap: () {
            controller.selectedFilterChip.value = filter;
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
        'action': () => MfNfoSheet.show(context),
      },
      {
        'title': 'SIP\ncalculator',
        'img': 'assets/images/Mutual_Funds/mf_tool_calculator.jpg',
        'action': () => MfSipCalculatorSheet.show(context),
      },
      {
        'title': 'Compare\nfunds',
        'img': 'assets/images/Mutual_Funds/mf_tool_compare.jpg',
        'action': () => MfCompareModal.show(context, controller.schemes),
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
                onTap: () => controller.selectedFilterChip.value = chip,
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
                    '+${returnVal}%',
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/Mutual_Funds/mf_wallet_sip_3d.jpg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.autorenew_rounded, color: GrowwColors.mintTeal, size: 54),
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
