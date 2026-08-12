import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/scheme_repository.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/profile/utils/policy_texts.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'scheme_detail_view.dart';
import 'all_schemes_view.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _success = Color(0xFF2ECC71);
const _danger = Color(0xFFE05A47);

class _T {
  final Color bg,
      card,
      primary,
      ink,
      inkMuted,
      cardBorder,
      subBg,
      ctaText,
      neutralBox;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.ctaText,
    required this.neutralBox,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF0A0A0C),
          card: Color(0xFF16161B),
          primary: _gold,
          ink: Color(0xFFF5F5F5),
          inkMuted: Color(0xFF8A8A93),
          cardBorder: Color(0x2ED4A017),
          subBg: Color(0xFF1C1C22),
          ctaText: Color(0xFF3D2B00),
          neutralBox: Color(0xFF1C1C22),
        )
      : const _T(
          bg: Color(0xFFF8F9FA),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Color(0xFFE5E7EB),
          subBg: Color(0xFFF3F4F6),
          ctaText: Colors.white,
          neutralBox: Color(0xFF0B3D2E),
        );
}

class GoldSchemesView extends StatefulWidget {
  const GoldSchemesView({super.key});
  @override
  State<GoldSchemesView> createState() => _GoldSchemesViewState();
}

class _GoldSchemesViewState extends State<GoldSchemesView> {
  final _repo = SchemeRepository();
  List<GoldSchemeModel>? _schemes;
  List<SchemeEnrollmentModel>? _my;
  bool _loading = true;
  String? _error;
  bool _isBalanceVisible = true;

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
      final results = await Future.wait([
        _repo.getSchemes(),
        _repo.getMyEnrollments(),
      ]);
      setState(() {
        _schemes = results[0] as List<GoldSchemeModel>;
        _my = results[1] as List<SchemeEnrollmentModel>;
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
      final t = _T.of(dark);

      // Compute calculations for the green banner
      final totalValue = (_my ?? []).fold<double>(0.0, (sum, e) {
        final rate = e.metal == 'silver'
            ? (GoldController.to.silverRate)
            : (GoldController.to.buyRate);
        return sum + (e.totalGoldGrams * rate);
      });

      final maturedValue = (_my ?? [])
          .where((e) => e.status == 'completed')
          .fold<double>(0.0, (sum, e) => sum + (e.installmentsPaid * e.monthlyAmount));

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.card,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: t.ink, size: 20),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Gold Schemes',
                style: TextStyle(
                  color: t.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Save today, own gold tomorrow ✨',
                style: TextStyle(
                  color: t.inkMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Scheme History',
                  'Passbook and statement launching soon!',
                  backgroundColor: t.primary,
                  colorText: Colors.white,
                );
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.description_outlined, color: t.ink, size: 18),
              ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : _error != null
                ? _ErrorState(error: _error!, t: t, onRetry: _load)
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
                          const SizedBox(height: 16),

                          // ── Green Schemes Value Banner ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              height: 165,
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                image: const DecorationImage(
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
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Total Schemes Value',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Icon(
                                                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                                                    color: Colors.white70,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _isBalanceVisible
                                                  ? '₹ ${totalValue.toStringAsFixed(2)}'
                                                  : '₹ ••••••',
                                              style: const TextStyle(
                                                color: Color(0xFFFFD573),
                                                fontSize: 26,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Total Schemes',
                                                  style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${(_my ?? []).length.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 40),
                                            Container(
                                              width: 1,
                                              height: 30,
                                              color: Colors.white24,
                                            ),
                                            const SizedBox(width: 40),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Matured Value',
                                                  style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹ ${maturedValue.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Start a New Gold Scheme Action Bar ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: t.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: t.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0B3D2E).withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0B3D2E), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start a new Gold Scheme',
                                          style: TextStyle(
                                            color: t.ink,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Begin your gold saving journey today',
                                          style: TextStyle(
                                            color: t.inkMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => Get.to(() => AllSchemesView(onEnrolled: _load)),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF072E20),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Start a Scheme',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── My Enrolled Schemes Header ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Enrolled Schemes',
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: t.card,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: t.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.filter_list_rounded, color: t.ink, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Filter',
                                        style: TextStyle(color: t.ink, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: t.ink, size: 14),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── My Schemes List ──
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: (_my ?? []).isEmpty
                                ? _EmptyMySchemes(t: t)
                                : Column(
                                    children: _my!
                                        .map(
                                          (e) => _EnrollmentCard(
                                            e: e,
                                            t: t,
                                            dark: dark,
                                            onChanged: _load,
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // ── Why Invest Info Grid ──
                          _WhyInvestSection(t: t),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
      );
    });
  }
}

// ─── Why Invest Bottom Banner ────────────────────────────────────────────────
class _WhyInvestSection extends StatelessWidget {
  const _WhyInvestSection({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF042116),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why invest in Gold Schemes?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeature(Icons.verified_user_outlined, '100% Secure', 'Your gold is safe & insured'),
              _buildFeature(Icons.savings_outlined, 'Small Savings', 'Start with as low as ₹100'),
              _buildFeature(Icons.trending_up_rounded, 'Wealth Growth', 'Build wealth for your future'),
              _buildFeature(Icons.lock_open_rounded, 'Flexible Tenure', 'Choose tenure that suits you'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String desc) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: _gold, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 7.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyMySchemes extends StatelessWidget {
  const _EmptyMySchemes({required this.t});
  final _T t;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
    decoration: BoxDecoration(
      color: t.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: t.cardBorder),
    ),
    child: Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.savings_outlined, color: _gold, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          "You haven't joined any scheme yet",
          style: TextStyle(
            color: t.ink,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick one below to get started',
          style: TextStyle(color: t.inkMuted, fontSize: 11),
        ),
      ],
    ),
  );
}

// ─── My Scheme enrollment card ────────────────────────────────────────────────
class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({
    required this.e,
    required this.t,
    required this.dark,
    required this.onChanged,
  });
  final SchemeEnrollmentModel e;
  final _T t;
  final bool dark;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isActive = e.status == 'active';
    final isSilver = e.metal == 'silver';
    final metalColor = isSilver ? const Color(0xFF8A95B0) : _gold;
    final pct = (e.progressPct / 100).clamp(0.0, 1.0);

    // Calculate dates / maturities dynamically
    final installText = isSilver ? 'Weekly Scheme' : 'Monthly Scheme';
    final maturesOnText = '20 May 2026'; // Mocked maturation
    final nextInstallmentDateText = '20 May 2025';

    return GestureDetector(
      onTap: () async {
        await Get.to(() => SchemeDetailView(enrollmentId: e.id));
        onChanged();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Image, Title, Status
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF042116),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Image.asset(
                            isSilver ? 'assets/images/silver_coin.png' : 'assets/images/gold_coin.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.schemeName,
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              installText,
                              style: TextStyle(
                                color: t.inkMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e.status.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, color: t.inkMuted, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Row 2: Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Monthly Investment', '₹ ${e.monthlyAmount.toStringAsFixed(0)}', t, false),
                      _buildStatColumn('Total Invested', '₹ ${(e.installmentsPaid * e.monthlyAmount).toStringAsFixed(0)}', t, false),
                      _buildStatColumn('Gold Accumulated', '${e.totalGoldGrams.toStringAsFixed(3)} g', t, true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 3: Progress text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${e.installmentsPaid} of ${e.durationMonths} months completed',
                        style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Matures on $maturesOnText',
                        style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Thin linear progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: t.subBg,
                      valueColor: AlwaysStoppedAnimation<Color>(metalColor),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action strip
            if (isActive)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.card_giftcard_rounded, color: Color(0xFFD4A017), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Next EMI on $nextInstallmentDateText',
                          style: const TextStyle(
                            color: Color(0xFF7A5C00),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '₹ ${e.monthlyAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            await Get.to(() => SchemeDetailView(enrollmentId: e.id));
                            onChanged();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF042116),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: const Text(
                              'Pay Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          e.status == 'completed' ? 'Scheme matured successfully!' : 'Scheme cancelled',
                          style: TextStyle(
                            color: e.status == 'completed' ? Colors.green[800] : Colors.red[800],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Get.to(() => SchemeDetailView(enrollmentId: e.id));
                        onChanged();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, _T t, bool highlight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: t.inkMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFD4A017) : t.ink,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.t,
    required this.onRetry,
  });
  final String error;
  final _T t;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(error, style: TextStyle(color: t.inkMuted)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry', style: TextStyle(color: _gold)),
        ),
      ],
    ),
  );
}

// ─── Enroll Bottom Sheet (needed by all_schemes_view.dart) ───────────────────
class EnrollSchemeSheet extends StatefulWidget {
  const EnrollSchemeSheet({
    super.key,
    required this.scheme,
    required this.dark,
    required this.onEnrolled,
  });
  final GoldSchemeModel scheme;
  final bool dark;
  final VoidCallback onEnrolled;

  @override
  State<EnrollSchemeSheet> createState() => _EnrollSchemeSheetState();
}

class _EnrollSchemeSheetState extends State<EnrollSchemeSheet> {
  final _repo = SchemeRepository();
  late final TextEditingController _ctrl;
  bool _submitting = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.scheme.minAmount.toStringAsFixed(0),
    );
  }

  double get _amount => double.tryParse(_ctrl.text) ?? 0;
  bool get _valid =>
      _amount >= widget.scheme.minAmount &&
      (widget.scheme.maxAmount == 0 || _amount <= widget.scheme.maxAmount);

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await WalletController.to.loadWallet();
      final bal = WalletController.to.wallet.value?.availableBalance ?? 0;
      if (bal < _amount) {
        final shortfall = _amount - bal;
        final success = await WalletController.to.addMoney(shortfall);
        if (!success) {
          Get.snackbar(
            'Complete Payment',
            'Wallet top-up failed or cancelled. Please complete payment to pay the first installment.',
            backgroundColor: const Color(0xFFe74c3c),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
      await _repo.enroll(schemeId: widget.scheme.id, monthlyAmount: _amount);
      await WalletController.to.loadWallet();
      Get.back();
      widget.onEnrolled();
      Get.snackbar(
        'Enrolled! 🥇',
        'First installment paid. Scheme is now active.',
        backgroundColor: _gold,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _T.of(widget.dark);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: t.inkMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.scheme.name,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pay ${widget.scheme.durationMonths} monthly installments, get ${widget.scheme.bonusMonths} month(s) worth of gold free.',
                  style: TextStyle(color: t.inkMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Text(
                  'Monthly Amount',
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: t.subBg,
                    border: Border.all(color: t.cardBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹',
                        style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_valid)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      widget.scheme.maxAmount > 0
                          ? 'Amount must be ₹${widget.scheme.minAmount.toStringAsFixed(0)} – ₹${widget.scheme.maxAmount.toStringAsFixed(0)}'
                          : 'Minimum ₹${widget.scheme.minAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: _danger, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Total over scheme: ₹${(_amount * widget.scheme.durationMonths).toStringAsFixed(0)}  →  '
                  '+₹${(_amount * widget.scheme.bonusMonths).toStringAsFixed(0)} free gold at maturity',
                  style: const TextStyle(color: _gold, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF3B82F6),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The first installment is paid now from your wallet (top up via Razorpay if needed). Remaining installments you pay manually each month from "My Schemes".',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // ── Terms & Conditions Checkbox ──────────────────────────
                GestureDetector(
                  onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _agreedToTerms ? _gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: _agreedToTerms
                                  ? _gold
                                  : const Color(0xFF8A8A93).withOpacity(0.6),
                              width: 1.5,
                            ),
                          ),
                          child: _agreedToTerms
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: t.inkMuted,
                                fontSize: 12,
                              ),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    onTap: () => Get.toNamed(
                                      '/policy',
                                      arguments: {
                                        'title': 'Terms & Conditions',
                                        'content': PolicyTexts.terms,
                                      },
                                    ),
                                    child: const Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                        color: _gold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: _gold,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: ' for this scheme'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _valid && _agreedToTerms && !_submitting ? _submit : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: (_valid && _agreedToTerms)
                          ? const LinearGradient(colors: [_gold, _goldLight])
                          : null,
                      color: (_valid && _agreedToTerms) ? null : _gold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Obx(() {
                              final bal =
                                  WalletController
                                      .to
                                      .wallet
                                      .value
                                      ?.availableBalance ??
                                  0;
                              final short = _amount - bal;
                              return Text(
                                short > 0
                                    ? 'Add ₹${short.toStringAsFixed(0)} & Pay — ₹${_amount.toStringAsFixed(0)}'
                                    : 'Pay First Installment — ₹${_amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: _valid
                                      ? const Color(0xFF3D2B00)
                                      : Colors.white38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              );
                            }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
