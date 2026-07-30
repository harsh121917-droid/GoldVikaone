import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/scheme_repository.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'scheme_detail_view.dart';
import 'all_schemes_view.dart';

// ─── Design tokens (shared identity with home / buy gold) ────────────────────
const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _success = Color(0xFF2ecc71);
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
          bg: Color(0xFFF7F4EE),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Colors.transparent,
          subBg: Color(0xFFF3F1EA),
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
  int? _openFaq;

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

  // ── Generic content — same for every user ────────────────────────────────
  static const _benefits = [
    (
      Icons.diamond_outlined,
      '24K Purity',
      '99.9% pure gold, same as buying digitally',
    ),
    (
      Icons.receipt_long_outlined,
      'No Hidden Fees',
      'Only 3% GST — no making charges ever',
    ),
    (
      Icons.card_giftcard_rounded,
      'Free Bonus Gold',
      'An extra installment\'s worth, on us',
    ),
    (
      Icons.event_available_outlined,
      'Pay On Your Time',
      'No auto-debit — pay monthly, whenever ready',
    ),
    (
      Icons.cancel_schedule_send_outlined,
      'Exit Anytime',
      'Cancel freely — your gold stays yours',
    ),
    (
      Icons.verified_user_outlined,
      'Insured Storage',
      'Vault-secured and fully insured',
    ),
  ];

  static const _steps = [
    (
      Icons.tune_rounded,
      'Pick a scheme & amount',
      'Choose your monthly installment, pay the first one to activate',
    ),
    (
      Icons.bolt_rounded,
      'Gold, credited instantly',
      'Every payment buys 24K gold at that day\'s live rate',
    ),
    (
      Icons.repeat_rounded,
      'Repeat monthly',
      'Pay each installment yourself — no card, no auto-debit',
    ),
    (
      Icons.redeem_rounded,
      'Collect your bonus',
      'Finish the term and free bonus gold lands automatically',
    ),
  ];

  static const _faqs = [
    _Faq(
      'How does a gold scheme work?',
      'You pick a scheme and a monthly amount, then pay that amount every '
          'month for the scheme\'s duration. Each payment buys real 24K gold '
          'at that day\'s live rate, credited to your account instantly. '
          'After your last installment, you get extra bonus gold free — '
          'that\'s the "+1" part of an "11+1" style scheme.',
    ),
    _Faq(
      'What happens to the gold I\'ve already bought?',
      'Every installment credits real gold to your account immediately — '
          'it\'s yours from day one, visible in "My Gold". You can sell it '
          'anytime, scheme or no scheme.',
    ),
    _Faq(
      'Can I miss a month or pay late?',
      'Yes. There\'s no auto-debit and no penalty for paying late — you pay '
          'each installment manually whenever ready. Your scheme just stays '
          '"Active" until all installments are paid.',
    ),
    _Faq(
      'Can I cancel a scheme?',
      'Yes, anytime, from "My Schemes" below. Cancelling stops future '
          'installments, but you keep all the gold already credited. You '
          'won\'t get the bonus gold since that only credits on full maturity.',
    ),
    _Faq(
      'Is there GST on installments?',
      '3% GST applies on each installment — same as any digital gold '
          'purchase — included in the total shown before you pay.',
    ),
    _Faq(
      'How do I pay each installment?',
      'From your wallet balance. If your wallet doesn\'t have enough, '
          'Razorpay opens right there so you can top up and pay in one go.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
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
                    children: [
                      _Hero(t: t, dark: dark),
                      _SectionHeader(
                        eyebrow: 'YOUR ACTIVITY',
                        title: 'My Schemes',
                        t: t,
                      ),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        child: GestureDetector(
                          onTap: () =>
                              Get.to(() => AllSchemesView(onEnrolled: _load)),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_gold, _goldLight],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _gold.withOpacity(0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: Color(0xFF3D2B00),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Start a New Scheme',
                                    style: TextStyle(
                                      color: Color(0xFF3D2B00),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      _SectionHeader(
                        eyebrow: 'WHY JOIN',
                        title: 'Built For Trust',
                        t: t,
                      ),
                      _BenefitsGrid(benefits: _benefits, t: t),
                      _SectionHeader(
                        eyebrow: 'CHOOSE YOUR PLAN',
                        title: 'Available Schemes',
                        t: t,
                      ),
                      if ((_schemes ?? []).isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'No schemes available right now',
                            style: TextStyle(color: t.inkMuted),
                          ),
                        )
                      else
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                            itemCount: _schemes!.length,
                            itemBuilder: (_, i) => _SchemeCard(
                              scheme: _schemes![i],
                              t: t,
                              dark: dark,
                              isFeatured: i == 0,
                              onEnrolled: _load,
                            ),
                          ),
                        ),
                      _SectionHeader(
                        eyebrow: 'THE PROCESS',
                        title: 'How It Works',
                        t: t,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            for (int i = 0; i < _steps.length; i++)
                              _StepCard(
                                icon: _steps[i].$1,
                                title: _steps[i].$2,
                                subtitle: _steps[i].$3,
                                isLast: i == _steps.length - 1,
                                t: t,
                              ),
                          ],
                        ),
                      ),
                      _SectionHeader(
                        eyebrow: 'GOOD TO KNOW',
                        title: 'Frequently Asked Questions',
                        t: t,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _faqs
                              .asMap()
                              .entries
                              .map(
                                (e) => _FaqTile(
                                  faq: e.value,
                                  isOpen: _openFaq == e.key,
                                  t: t,
                                  onTap: () => setState(
                                    () => _openFaq = _openFaq == e.key
                                        ? null
                                        : e.key,
                                  ),
                                ),
                              )
                              .toList(),
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
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero({required this.t, required this.dark});
  final _T t;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 14,
        20,
        28,
      ),
      decoration: BoxDecoration(
        gradient: dark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0B3D2E), Color(0xFF14563F)],
              ),
        color: dark ? t.card : null,
        border: dark ? Border(bottom: BorderSide(color: t.cardBorder)) : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -20, right: -20, child: _CoinStack()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dark ? t.neutralBox : Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dark
                          ? t.cardBorder
                          : Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'GOLD SAVINGS SCHEMES',
                style: TextStyle(
                  color: _gold.withOpacity(0.95),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Save monthly.\nEarn bonus gold.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: Text(
                  'A digital take on the classic jeweller scheme — pay small, collect real 24K gold, get a free installment at the end.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TrustPill(icon: Icons.shield_outlined, label: 'Insured'),
                  _TrustPill(icon: Icons.bolt_rounded, label: 'Live Rate'),
                  _TrustPill(
                    icon: Icons.workspace_premium_outlined,
                    label: '24K Pure',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinStack extends StatelessWidget {
  const _CoinStack();
  @override
  Widget build(BuildContext context) {
    Widget coin(double size, double opacity, double top, double right) =>
        Positioned(
          top: top,
          right: right,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _goldLight.withOpacity(opacity),
                  _gold.withOpacity(opacity * 0.7),
                ],
              ),
              border: Border.all(
                color: _goldLight.withOpacity(opacity * 0.5),
                width: 1.5,
              ),
            ),
          ),
        );
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        children: [
          coin(84, 0.10, 8, 8),
          coin(64, 0.16, 26, 36),
          coin(48, 0.24, 50, 58),
        ],
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _goldLight, size: 12),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.t,
  });
  final String eyebrow, title;
  final _T t;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: _gold,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: t.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_gold.withOpacity(0.35), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─── Benefits grid ────────────────────────────────────────────────────────────
class _BenefitsGrid extends StatelessWidget {
  const _BenefitsGrid({required this.benefits, required this.t});
  final List<(IconData, String, String)> benefits;
  final _T t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: benefits
            .map(
              (b) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(b.$1, color: _gold, size: 18),
                    ),
                    const Spacer(),
                    Text(
                      b.$2,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      b.$3,
                      style: TextStyle(
                        color: t.inkMuted,
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─── How It Works step card ───────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLast,
    required this.t,
  });
  final IconData icon;
  final String title, subtitle;
  final bool isLast;
  final _T t;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold, _goldLight]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _gold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF3D2B00), size: 19),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 1.5,
                  color: t.inkMuted.withOpacity(0.2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 2),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: t.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── FAQ ──────────────────────────────────────────────────────────────────────
class _Faq {
  final String q, a;
  const _Faq(this.q, this.a);
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({
    required this.faq,
    required this.isOpen,
    required this.t,
    required this.onTap,
  });
  final _Faq faq;
  final bool isOpen;
  final _T t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen ? _gold.withOpacity(0.45) : t.cardBorder,
          width: isOpen ? 1.3 : 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isOpen ? _gold : t.inkMuted.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      faq.q,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isOpen ? _gold : t.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isOpen
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 14, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  faq.a,
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ─── Scheme card (horizontal scroller) ───────────────────────────────────────
class _SchemeCard extends StatelessWidget {
  const _SchemeCard({
    required this.scheme,
    required this.t,
    required this.dark,
    required this.onEnrolled,
    this.isFeatured = false,
  });
  final GoldSchemeModel scheme;
  final _T t;
  final bool dark, isFeatured;
  final VoidCallback onEnrolled;

  @override
  Widget build(BuildContext context) {
    final isSilver = scheme.isSilver;
    final accent = isSilver ? const Color(0xFF9AA3AD) : _gold;

    return GestureDetector(
      onTap: () => Get.bottomSheet(
        EnrollSchemeSheet(scheme: scheme, dark: dark, onEnrolled: onEnrolled),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      ),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isFeatured ? accent.withOpacity(0.6) : t.cardBorder,
            width: isFeatured ? 1.4 : 1,
          ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: accent, size: 7),
                    const SizedBox(width: 4),
                    Text(
                      isSilver ? 'SILVER' : 'GOLD',
                      style: TextStyle(
                        color: accent,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isFeatured)
              Positioned(
                top: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    color: accent,
                    child: Text(
                      'POPULAR',
                      style: TextStyle(
                        color: isSilver
                            ? Colors.white
                            : const Color(0xFF3D2B00),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 44, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${scheme.durationMonths}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 2,
                        ),
                        child: Icon(Icons.add_rounded, color: accent, size: 15),
                      ),
                      Text(
                        '${scheme.bonusMonths}',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'months + free',
                    style: TextStyle(color: t.inkMuted, fontSize: 10),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    scheme.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: t.inkMuted.withOpacity(0.15)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'From',
                          style: TextStyle(color: t.inkMuted, fontSize: 10),
                        ),
                        Text(
                          '₹${scheme.minAmount.toStringAsFixed(0)}/mo',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSilver
                            ? [const Color(0xFF9AA3AD), const Color(0xFFD4D9DE)]
                            : [_gold, _goldLight],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Start Scheme',
                        style: TextStyle(
                          color: isSilver
                              ? const Color(0xFF2A2E33)
                              : const Color(0xFF3D2B00),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
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
}

// ─── Enroll Bottom Sheet (preserved — imported by all_schemes_view.dart) ─────
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
        await WalletController.to.addMoney(shortfall);
        await Future.delayed(const Duration(seconds: 2));
        await WalletController.to.loadWallet();
        final newBal = WalletController.to.wallet.value?.availableBalance ?? 0;
        if (newBal < _amount) {
          Get.snackbar(
            'Complete Payment',
            'Finish adding money in the Razorpay window, then tap "Pay First Installment" again.',
            backgroundColor: const Color(0xFF3B82F6),
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
                GestureDetector(
                  onTap: _valid && !_submitting ? _submit : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _valid
                          ? const LinearGradient(colors: [_gold, _goldLight])
                          : null,
                      color: _valid ? null : _gold.withOpacity(0.3),
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
    final metalAccent = isSilver ? const Color(0xFF9AA3AD) : _gold;
    final statusColor = e.status == 'completed'
        ? _success
        : e.status == 'cancelled'
        ? _danger
        : _gold;
    final statusIcon = e.status == 'completed'
        ? Icons.celebration_rounded
        : e.status == 'cancelled'
        ? Icons.cancel_rounded
        : Icons.autorenew_rounded;
    final pct = (e.progressPct / 100).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () async {
        await Get.to(() => SchemeDetailView(enrollmentId: e.id));
        onChanged();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? metalAccent.withOpacity(0.3) : t.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSilver
                            ? [const Color(0xFF9AA3AD), const Color(0xFFD4D9DE)]
                            : [_gold, _goldLight],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: metalAccent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: isSilver
                          ? const Color(0xFF2A2E33)
                          : const Color(0xFF3D2B00),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.schemeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${e.monthlyAmount.toStringAsFixed(0)}/mo · ${e.durationMonths} months',
                          style: TextStyle(color: t.inkMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 11),
                        const SizedBox(width: 4),
                        Text(
                          e.status[0].toUpperCase() + e.status.substring(1),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 10,
                        child: Stack(
                          children: [
                            Container(color: t.inkMuted.withOpacity(0.15)),
                            FractionallySizedBox(
                              widthFactor: pct,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isSilver
                                        ? [
                                            const Color(0xFF9AA3AD),
                                            const Color(0xFFD4D9DE),
                                          ]
                                        : [_gold, _goldLight],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: metalAccent.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${e.progressPct.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: metalAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.receipt_long_rounded,
                      label: 'Installments',
                      value: '${e.installmentsPaid}/${e.durationMonths}',
                      t: t,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.monetization_on_rounded,
                      label: 'Gold Earned',
                      value: '${e.totalGoldGrams.toStringAsFixed(3)}g',
                      t: t,
                      valueColor: metalAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: metalAccent.withOpacity(dark ? 0.10 : 0.06),
                border: Border(
                  top: BorderSide(color: t.inkMuted.withOpacity(0.12)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isActive
                        ? 'View & pay next installment'
                        : 'View installment history',
                    style: TextStyle(
                      color: metalAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: metalAccent,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.t,
    this.valueColor,
  });
  final IconData icon;
  final String label, value;
  final _T t;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: t.subBg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: valueColor ?? t.inkMuted, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? t.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(label, style: TextStyle(color: t.inkMuted, fontSize: 9)),
            ],
          ),
        ),
      ],
    ),
  );
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
