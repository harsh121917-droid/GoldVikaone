import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/scheme_repository.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'gold_schemes_view.dart' show EnrollSchemeSheet;

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);

class SchemeMetadata {
  final String subtitle;
  final String tenureLabel;
  final String benefitLabel;
  final List<String> badges;
  final String image;
  final bool isPopular;
  const SchemeMetadata({
    required this.subtitle,
    required this.tenureLabel,
    required this.benefitLabel,
    required this.badges,
    required this.image,
    this.isPopular = false,
  });
}

SchemeMetadata getMetadata(String name, bool isSilver) {
  final lower = name.toLowerCase();
  final defaultImg = isSilver
      ? 'assets/images/silver_coin.png'
      : 'assets/images/gold_coin.png';

  if (lower.contains('wealth') || lower.contains('builder')) {
    return SchemeMetadata(
      subtitle: 'Save monthly, shine for a lifetime',
      tenureLabel: '12 / 24 / 36\nMonths',
      benefitLabel: 'Extra 1%\nGold Bonus',
      badges: const ['Flexible Tenure', 'Easy Payments', 'No Making Charges*'],
      image: defaultImg,
      isPopular: true,
    );
  } else if (lower.contains('shubh')) {
    return SchemeMetadata(
      subtitle: 'Small savings, big happiness',
      tenureLabel: '20 / 40 / 60\nWeeks',
      benefitLabel: 'Rate Locked\non joining',
      badges: const ['Weekly Savings', 'Rate Protection', 'Easy to Manage'],
      image: defaultImg,
    );
  } else if (lower.contains('festive') ||
      lower.contains('special') ||
      lower.contains('saver')) {
    return SchemeMetadata(
      subtitle: 'Celebrate every occasion with pure gold',
      tenureLabel: '11 Months\nTenure',
      benefitLabel: 'Get 1 Month\nInstallment Free',
      badges: const ['Festival Ready', 'Reward on Maturity', 'Limited Period'],
      image: defaultImg,
    );
  } else {
    return SchemeMetadata(
      subtitle: 'Save on your own terms',
      tenureLabel: 'No Fixed Tenure\nBuy Anytime',
      benefitLabel: 'Assured Purity\n& Safe Storage',
      badges: const [
        'Save Anytime',
        'Withdraw Anytime Real Gold',
        '30Day Lock-in',
      ],
      image: defaultImg,
    );
  }
}

class AllSchemesView extends StatefulWidget {
  const AllSchemesView({super.key, this.onEnrolled});
  final VoidCallback? onEnrolled;

  @override
  State<AllSchemesView> createState() => _AllSchemesViewState();
}

class _AllSchemesViewState extends State<AllSchemesView> {
  final _repo = SchemeRepository();
  List<GoldSchemeModel>? _schemes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final schemes = await _repo.getSchemes();
      setState(() {
        _schemes = schemes;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load schemes';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8F9FA);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2B22);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7A72);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE5E7EB);

      return Scaffold(
        backgroundColor: bg,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: TextStyle(color: ts)),
                    const SizedBox(height: 10),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                color: _gold,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Custom Header Banner ──
                      Container(
                        height: 165,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/gold banner.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              color: const Color(0xFF072E20).withOpacity(0.4),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                MediaQuery.paddingOf(context).top + 6,
                                16,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.back(),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Start a Scheme',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Choose a plan that fits your goals ✨',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Feature Badges Ribbon Card ──
                      Transform.translate(
                        offset: const Offset(0, -16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _featurePill(
                                  Icons.shield_outlined,
                                  '100% Secured',
                                  'Vault Storage',
                                  ts,
                                  tp,
                                ),
                                _featurePill(
                                  Icons.verified_user_outlined,
                                  'BIS Purity',
                                  '24K Pure Gold',
                                  ts,
                                  tp,
                                ),
                                _featurePill(
                                  Icons.card_giftcard_rounded,
                                  'Flexible Plans',
                                  'For Every Goal',
                                  ts,
                                  tp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Available Gold Schemes Header ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available Schemes',
                              style: TextStyle(
                                color: tp,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Row(
                              children: [
                                _filterChip('Popular First', border, tp),
                                const SizedBox(width: 8),
                                // _filterChip('Filter', border, tp, icon: Icons.filter_list_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Schemes Vertical List ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _schemes!.length,
                          itemBuilder: (context, i) {
                            final s = _schemes![i];
                            final isSilver = s.isSilver;
                            final meta = getMetadata(s.name, isSilver);
                            final themeColor = isSilver
                                ? const Color(0xFF8A95B0)
                                : _gold;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: meta.isPopular
                                      ? themeColor.withOpacity(0.5)
                                      : border,
                                  width: meta.isPopular ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withOpacity(
                                      meta.isPopular ? 0.08 : 0.02,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Left Image representation
                                        Container(
                                          width: 76,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF042116),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              meta.image,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),

                                        // Right Metadata Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (meta.isPopular)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFE29A10,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: const [
                                                          Icon(
                                                            Icons.star_rounded,
                                                            color: Colors.white,
                                                            size: 9,
                                                          ),
                                                          SizedBox(width: 3),
                                                          Text(
                                                            'Most Popular',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 8.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  else
                                                    const SizedBox.shrink(),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE8F5E9,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      isSilver
                                                          ? 'Weekly'
                                                          : 'Monthly',
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF2E7D32,
                                                        ),
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                s.name,
                                                style: TextStyle(
                                                  color: tp,
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                meta.subtitle,
                                                style: TextStyle(
                                                  color: ts,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Divider(height: 1),
                                  ),

                                  // Three Column Stats Row
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _statBox(
                                          'Min. Installment',
                                          '₹ ${s.minAmount.toStringAsFixed(0)}',
                                          isSilver ? 'per week' : 'per month',
                                          ts,
                                          tp,
                                        ),
                                        _statBox(
                                          'Tenure',
                                          meta.tenureLabel,
                                          '',
                                          ts,
                                          tp,
                                        ),
                                        _statBox(
                                          'Benefits',
                                          meta.benefitLabel,
                                          '',
                                          ts,
                                          themeColor,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Badges Row
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: meta.badges
                                          .map((b) => _badgeItem(b, ts))
                                          .toList(),
                                    ),
                                  ),

                                  // Bottom CTA button
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      0,
                                      16,
                                      16,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => Get.bottomSheet(
                                        EnrollSchemeSheet(
                                          scheme: s,
                                          dark: dark,
                                          onEnrolled: () {
                                            _load();
                                            widget.onEnrolled?.call();
                                          },
                                        ),
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: Container(
                                        height: 46,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: meta.isPopular
                                              ? const Color(0xFF042116)
                                              : Colors.transparent,
                                          border: meta.isPopular
                                              ? null
                                              : Border.all(color: border),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                meta.isPopular
                                                    ? 'Start This Scheme'
                                                    : 'View Details',
                                                style: TextStyle(
                                                  color: meta.isPopular
                                                      ? Colors.white
                                                      : tp,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: meta.isPopular
                                                    ? Colors.white
                                                    : tp,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget _featurePill(
    IconData icon,
    String title,
    String subtitle,
    Color ts,
    Color tp,
  ) {
    return Column(
      children: [
        Icon(icon, color: _gold, size: 18),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: tp,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: ts, fontSize: 8)),
      ],
    );
  }

  Widget _filterChip(String label, Color border, Color tp, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: tp, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: tp,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.keyboard_arrow_down_rounded, color: tp, size: 12),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, String unit, Color ts, Color tp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: ts, fontSize: 9.5)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: tp,
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(unit, style: TextStyle(color: ts, fontSize: 8.5)),
        ],
      ],
    );
  }

  Widget _badgeItem(String label, Color ts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ts.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, color: Color(0xFF2E7D32), size: 10),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: ts,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
