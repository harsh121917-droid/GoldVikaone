import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'mf_filter_view.dart';
import 'mf_search_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfAllMutualFundsView extends StatefulWidget {
  final String? initialCategory;
  final String? initialSort;

  const MfAllMutualFundsView({
    Key? key,
    this.initialCategory,
    this.initialSort,
  }) : super(key: key);

  @override
  State<MfAllMutualFundsView> createState() => _MfAllMutualFundsViewState();
}

class _MfAllMutualFundsViewState extends State<MfAllMutualFundsView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory != 'All') {
      controller.allMfCategories.clear();
      controller.allMfCategories.add(widget.initialCategory!);
    }
    if (widget.initialSort != null) {
      controller.allMfSort.value = widget.initialSort!;
    }
    controller.fetchAllSchemes(isRefresh: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreAllSchemes();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowwColors.background,
      appBar: AppBar(
        backgroundColor: GrowwColors.cardElevated,
        elevation: 0,
        title: const Text(
          'All Mutual Funds',
          style: TextStyle(
            color: GrowwColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GrowwColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: GrowwColors.textPrimary, size: 22),
            onPressed: () => Get.to(() => const MfSearchView()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Filter Bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color: GrowwColors.cardElevated,
                border: Border(bottom: BorderSide(color: GrowwColors.border)),
              ),
              child: Row(
                children: [
                  // Filter Button with active count badge (navigates to dedicated MfFilterView)
                  Obx(() {
                    final filterCount = controller.activeFiltersCount;
                    return GestureDetector(
                      onTap: () => Get.to(() => const MfFilterView()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: filterCount > 0
                              ? const Color(0xFF00D09C).withOpacity(0.15)
                              : GrowwColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: filterCount > 0
                                ? GrowwColors.mintTeal
                                : GrowwColors.border,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 16,
                              color: filterCount > 0 ? GrowwColors.mintTeal : GrowwColors.textPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Filters',
                              style: TextStyle(
                                color: filterCount > 0 ? GrowwColors.mintTeal : GrowwColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (filterCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: const BoxDecoration(
                                  color: GrowwColors.mintTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$filterCount',
                                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),

                  const Spacer(),

                  // Return Period Switcher (1Y / 3Y / 5Y)
                  Obx(() => Row(
                        children: ['1Y', '3Y', '5Y'].map((p) {
                          final isSel = controller.allMfReturnPeriod.value == p;
                          return GestureDetector(
                            onTap: () => controller.allMfReturnPeriod.value = p,
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? GrowwColors.mintTeal : GrowwColors.card,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isSel ? GrowwColors.mintTeal : GrowwColors.border),
                              ),
                              child: Text(
                                p,
                                style: TextStyle(
                                  color: isSel ? Colors.black : GrowwColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),

            // ── Sub-header: Count indicator & active tags ──
            Obx(() {
              final total = controller.allSchemesTotalCount.value;
              final list = controller.allSchemes;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: GrowwColors.background,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      total > 0 ? '$total funds available' : '${list.length} funds available',
                      style: const TextStyle(color: GrowwColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    if (controller.activeFiltersCount > 0)
                      GestureDetector(
                        onTap: () {
                          controller.resetAllFilters();
                          controller.fetchAllSchemes(isRefresh: true);
                        },
                        child: const Text(
                          'Reset all',
                          style: TextStyle(color: GrowwColors.mintTeal, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            }),

            // ── Schemes List ──
            Expanded(
              child: Obx(() {
                if (controller.isAllSchemesLoading.value && controller.allSchemes.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal));
                }

                final list = controller.allSchemes;

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.filter_alt_off_rounded, color: GrowwColors.textSecondary, size: 54),
                          const SizedBox(height: 16),
                          const Text(
                            'No mutual funds match your filters',
                            style: TextStyle(color: GrowwColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try clearing some filters or changing your selection',
                            style: TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GrowwColors.mintTeal,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              controller.resetAllFilters();
                              controller.fetchAllSchemes(isRefresh: true);
                            },
                            child: const Text('Clear All Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: GrowwColors.mintTeal,
                  backgroundColor: GrowwColors.cardElevated,
                  onRefresh: () => controller.fetchAllSchemes(isRefresh: true),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length + (controller.allSchemesHasMore.value ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(color: GrowwColors.border, height: 1),
                    itemBuilder: (context, index) {
                      if (index == list.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: GrowwColors.mintTeal),
                            ),
                          ),
                        );
                      }

                      final s = list[index];
                      return _buildSchemeTile(s);
                    },
                  ),
                );
              }),
            ),
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

  Widget _buildSchemeTile(MfSchemeModel s) {
    return Obx(() {
      final period = controller.allMfReturnPeriod.value;
      double? returnVal = s.cagr3Y;
      if (period == '1Y') returnVal = s.cagr1Y;
      if (period == '5Y') returnVal = s.cagr5Y;

      final cleanName = _cleanSchemeName(s.schemeName);
      final hasRet = returnVal != null && returnVal != 0;
      final retStr = hasRet ? '${returnVal >= 0 ? '+' : ''}${returnVal.toStringAsFixed(2)}%' : '—';
      final retColor = (returnVal ?? 0.0) < 0 ? const Color(0xFFEF4444) : GrowwColors.mintTeal;

      return InkWell(
        onTap: () {
          controller.recordRecentlyViewed(s);
          Get.to(() => MfSchemeDetailView(scheme: s));
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AmcBrandLogo(amcName: s.amcName, schemeName: s.schemeName, size: 40, borderRadius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanName,
                      style: const TextStyle(
                        color: GrowwColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${s.category} • ${s.subCategory.isNotEmpty ? s.subCategory : "Growth"}',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (s.rating != null && s.rating! > 0) ...[
                          const Text(' • ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                          Text(
                            '${s.rating}',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star_rounded, color: Color(0xFF94A3B8), size: 13),
                        ],
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
                    retStr,
                    style: TextStyle(
                      color: retColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$period Return',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
