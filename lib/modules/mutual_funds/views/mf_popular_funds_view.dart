import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'mf_search_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfPopularFundsView extends StatefulWidget {
  const MfPopularFundsView({Key? key}) : super(key: key);

  @override
  State<MfPopularFundsView> createState() => _MfPopularFundsViewState();
}

class _MfPopularFundsViewState extends State<MfPopularFundsView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  String _selectedPeriod = '3Y';

  @override
  void initState() {
    super.initState();
    if (controller.popularSchemesList.isEmpty) {
      controller.fetchPopularSchemes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowwColors.background,
      appBar: AppBar(
        backgroundColor: GrowwColors.cardElevated,
        elevation: 0,
        title: const Text(
          'Popular Funds',
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
        child: Obx(() {
          if (controller.isPopularLoading.value && controller.popularSchemesList.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: GrowwColors.mintTeal));
          }

          final list = controller.popularSchemesList.isNotEmpty
              ? controller.popularSchemesList
              : controller.popularFunds;

          return RefreshIndicator(
            color: GrowwColors.mintTeal,
            backgroundColor: GrowwColors.cardElevated,
            onRefresh: () => controller.fetchPopularSchemes(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // ── Info Header Card ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D09C).withOpacity(0.12),
                        const Color(0xFF131722),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending on VikaOne',
                              style: TextStyle(
                                color: GrowwColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Most invested Regular schemes curated across top fund houses',
                              style: TextStyle(
                                color: GrowwColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Sub-header: Count & Return Period Selector ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${list.length} Popular Funds',
                      style: const TextStyle(
                        color: GrowwColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: ['1Y', '3Y', '5Y'].map((p) {
                        final isSel = _selectedPeriod == p;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPeriod = p),
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSel ? GrowwColors.mintTeal : GrowwColors.cardElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? GrowwColors.mintTeal : GrowwColors.border),
                            ),
                            child: Text(
                              p,
                              style: TextStyle(
                                color: isSel ? Colors.black : GrowwColors.textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Scheme Items ──
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(color: GrowwColors.border, height: 1),
                  itemBuilder: (context, index) {
                    final s = list[index];
                    return _buildPopularItem(s, index + 1);
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPopularItem(MfSchemeModel s, int rank) {
    double? returnVal = s.cagr3Y;
    if (_selectedPeriod == '1Y') returnVal = s.cagr1Y;
    if (_selectedPeriod == '5Y') returnVal = s.cagr5Y;

    return InkWell(
      onTap: () {
        controller.recordRecentlyViewed(s);
        Get.to(() => MfSchemeDetailView(scheme: s));
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 22,
              alignment: Alignment.center,
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: GrowwColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),

            AmcBrandLogo(amcName: s.amcName, schemeName: s.schemeName, size: 40, borderRadius: 8),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.schemeName,
                    style: const TextStyle(
                      color: GrowwColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: GrowwColors.cardElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GrowwColors.border),
                        ),
                        child: Text(
                          s.category,
                          style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (s.rating != null && s.rating! > 0) ...[
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '${s.rating}.0',
                              style: const TextStyle(color: Color(0xFFF5A623), fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        s.minSipAmount != null ? 'Min ₹${s.minSipAmount!.toInt()}' : 'Min ₹—',
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
                  returnVal != null ? '${returnVal >= 0 ? "+" : ""}${returnVal.toStringAsFixed(1)}%' : '—',
                  style: const TextStyle(
                    color: GrowwColors.mintTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_selectedPeriod Return',
                  style: const TextStyle(color: GrowwColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
