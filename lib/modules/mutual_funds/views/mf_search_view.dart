import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfSearchView extends StatefulWidget {
  final String? initialQuery;
  const MfSearchView({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<MfSearchView> createState() => _MfSearchViewState();
}

class _MfSearchViewState extends State<MfSearchView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  final List<String> trendingSearches = const [
    'UTI Healthcare',
    'Parag Parikh Flexi Cap',
    'Small Cap',
    'HDFC Mid Cap',
    'SBI Gold',
    'Index Fund',
    'Tax Saver ELSS',
    'ICICI Bluechip',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _onSearchChanged(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      controller.executeLiveSearch(query);
    });
    setState(() {});
  }

  void _applySearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: term.length));
    controller.addSearchHistory(term);
    controller.executeLiveSearch(term);
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    return Scaffold(
      backgroundColor: GrowwColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Search Header Bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              decoration: const BoxDecoration(
                color: GrowwColors.cardElevated,
                border: Border(bottom: BorderSide(color: GrowwColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: GrowwColors.textPrimary, size: 22),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
                        onChanged: _onSearchChanged,
                        onSubmitted: (term) {
                          if (term.trim().isNotEmpty) {
                            controller.addSearchHistory(term);
                          }
                        },
                        // High-contrast, pitch-dark charcoal text so it is 100% visible and sharp
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                        cursorColor: const Color(0xFF00D09C),
                        decoration: InputDecoration(
                          hintText: 'Search schemes, e.g. UTI health, Flexi cap...',
                          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00D09C), size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFF475569), size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.executeLiveSearch('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00D09C), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Body ──
            Expanded(
              child: query.isEmpty ? _buildHistoryAndTrending() : _buildSearchResults(query),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search History & Trending Chips ──
  Widget _buildHistoryAndTrending() {
    return Obx(() {
      final history = controller.searchHistory;

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // ── Search History Section ──
          if (history.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_rounded, color: GrowwColors.textSecondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Recent Searches',
                      style: TextStyle(
                        color: GrowwColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => controller.clearSearchHistory(),
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      color: GrowwColors.mintTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...history.map((term) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: GrowwColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GrowwColors.border.withOpacity(0.6)),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                    leading: const Icon(Icons.schedule_rounded, color: GrowwColors.textTertiary, size: 18),
                    title: Text(
                      term,
                      style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, color: GrowwColors.textSecondary, size: 16),
                      onPressed: () => controller.removeSearchHistory(term),
                    ),
                    onTap: () => _applySearch(term),
                  ),
                )),
            const SizedBox(height: 24),
          ],

          // ── Popular / Trending Searches ──
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: GrowwColors.mintTeal, size: 18),
              SizedBox(width: 8),
              Text(
                'Popular Searches',
                style: TextStyle(
                  color: GrowwColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: trendingSearches.map((tag) {
              return GestureDetector(
                onTap: () => _applySearch(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: GrowwColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GrowwColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_rounded, color: GrowwColors.mintTeal, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        tag,
                        style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // ── Quick Category Shortcuts ──
          const Text(
            'Explore Categories',
            style: TextStyle(
              color: GrowwColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCategoryShortcut('Equity', Icons.show_chart_rounded, const Color(0xFF00D09C)),
              const SizedBox(width: 10),
              _buildCategoryShortcut('Debt', Icons.account_balance_wallet_rounded, const Color(0xFF60A5FA)),
              const SizedBox(width: 10),
              _buildCategoryShortcut('Hybrid', Icons.pie_chart_outline_rounded, const Color(0xFFF59E0B)),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildCategoryShortcut(String name, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _applySearch(name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: GrowwColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GrowwColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                name,
                style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Live Search Results ──
  Widget _buildSearchResults(String query) {
    return Obx(() {
      if (controller.isSearchLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: GrowwColors.mintTeal),
        );
      }

      final results = controller.searchResults;

      if (results.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, color: GrowwColors.textSecondary, size: 54),
                const SizedBox(height: 16),
                Text(
                  'No results found for "$query"',
                  style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try searching by AMC name (e.g. UTI, HDFC, SBI) or category (e.g. Flexi Cap, Small Cap, Gold)',
                  style: TextStyle(color: GrowwColors.textTertiary, fontSize: 13, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(color: GrowwColors.border, height: 1),
        itemBuilder: (context, index) {
          final scheme = results[index];
          return _buildSchemeResultTile(scheme);
        },
      );
    });
  }

  Widget _buildSchemeResultTile(MfSchemeModel scheme) {
    return InkWell(
      onTap: () {
        controller.addSearchHistory(scheme.schemeName);
        controller.recordRecentlyViewed(scheme);
        Get.to(() => MfSchemeDetailView(scheme: scheme));
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AmcBrandLogo(
              amcName: scheme.amcName,
              schemeName: scheme.schemeName,
              size: 40,
              borderRadius: 8,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.schemeName,
                    style: const TextStyle(
                      color: GrowwColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: GrowwColors.cardElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GrowwColors.border),
                        ),
                        child: Text(
                          scheme.category,
                          style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (scheme.rating > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '${scheme.rating}.0',
                              style: const TextStyle(color: Color(0xFFF5A623), fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      Text(
                        scheme.riskLevel,
                        style: const TextStyle(color: GrowwColors.textTertiary, fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${scheme.cagr3Y}%',
                  style: const TextStyle(
                    color: GrowwColors.mintTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '3Y CAGR',
                  style: TextStyle(color: GrowwColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
