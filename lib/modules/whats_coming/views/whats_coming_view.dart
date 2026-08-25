import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder, subBg;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF040A07),
          card: Color(0xFF0C1710),
          primary: Color(0xFF1FAE7A),
          ink: Color(0xFFEDF3EF),
          inkMuted: Color(0xFF7C9689),
          cardBorder: Color(0x2A1FAE7A),
          subBg: Color(0xFF0A140D),
        )
      : const _T(
          bg: Color(0xFFF9F9FB),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Color(0xFFE8ECE9),
          subBg: Color(0xFFF3F1EA),
        );
}

class WhatsComingView extends StatefulWidget {
  const WhatsComingView({super.key});

  @override
  State<WhatsComingView> createState() => _WhatsComingViewState();
}

class _WhatsComingViewState extends State<WhatsComingView> {
  bool _isNotified = false;

  static const _gold = Color(0xFFD4A017);
  static const _goldLight = Color(0xFFF59E0B);

  // Exact Mutual Funds that have authentic image assets in assets/images/Mutual_Funds
  final List<String> _amcImages = [
    'assets/images/Mutual_Funds/sbi_mutual.jfif',
    'assets/images/Mutual_Funds/icici_mutual.jpg',
    'assets/images/Mutual_Funds/dsp_mutual.png',
    'assets/images/Mutual_Funds/uti_mutual.jpeg',
    'assets/images/Mutual_Funds/motilal_oswal_mutual.png',
    'assets/images/Mutual_Funds/adiya_bilra_mutual.png',
    'assets/images/Mutual_Funds/edelweiss_mutual.png',
    'assets/images/Mutual_Funds/BSE.gif',
  ];

  void _onNotifyPressed() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isNotified = true;
    });

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0B1E17),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: _gold,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "You're on the Priority List!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We will send you a priority alert the moment Mutual Funds, Fixed Deposits & SIP integrations go live on VIKA ONE.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: const Color(0xFF261800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Great, Got It!",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top App Bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: t.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: t.ink,
                          size: 24,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "What's Coming to VIKA ONE",
                          style: TextStyle(
                            color: Color(0xFF0B3D2E),
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.snackbar(
                          "Share Payvika",
                          "Spread the word with friends and family!",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF0B3D2E),
                          colorText: Colors.white,
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: t.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.cardBorder),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          color: t.ink,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ───────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Top AMC Card ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF031913),
                              Color(0xFF07271E),
                              Color(0xFF031610),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(
                              0xFF1FAE7A,
                            ).withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0B3D2E,
                              ).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header + Shield Badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Empowered with ",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            "Top AMCs",
                                            style: TextStyle(
                                              color: _goldLight,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "All over India's leading fund houses & household names in one app.",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.5,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Shield Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [_gold, Color(0xFFB58910)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gold.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "45+",
                                        style: TextStyle(
                                          color: Color(0xFF261800),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          height: 1,
                                        ),
                                      ),
                                      Text(
                                        "AMCs",
                                        style: TextStyle(
                                          color: Color(0xFF261800),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // AMC Grid with Logo Images Only
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _amcImages.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 1.45,
                                  ),
                              itemBuilder: (context, index) {
                                final imgPath = _amcImages[index];
                                return Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      imgPath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(
                                            Icons.account_balance,
                                            size: 23,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 2. Coming Features Section ────────────────────────
                      Text(
                        "Coming Features",
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildFeatureTile(
                        icon: Icons.account_balance_rounded,
                        iconColor: const Color(0xFFD97706),
                        iconBg: const Color(0xFFFEF3C7),
                        title: "Mutual Funds",
                        badge: "NEW",
                        subtitle:
                            "Invest in 1400+ funds across Equity, Debt, Hybrid, ELSS & more.",
                        t: t,
                      ),
                      const SizedBox(height: 10),

                      _buildFeatureTile(
                        icon: Icons.credit_card_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFE0F2FE),
                        title: "Fixed Deposits",
                        badge: "NEW",
                        subtitle:
                            "High return guaranteed lock-ins with leading NBFCs and SFBs.",
                        t: t,
                      ),
                      const SizedBox(height: 10),

                      _buildFeatureTile(
                        icon: Icons.event_repeat_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFFD1FAE5),
                        title: "SIP & Lumpsum",
                        badge: "NEW",
                        subtitle:
                            "Start SIP with just ₹100 or invest lumpsum anytime.",
                        t: t,
                      ),
                      const SizedBox(height: 10),

                      _buildFeatureTile(
                        icon: Icons.pie_chart_outline_rounded,
                        iconColor: const Color(0xFF7C3AED),
                        iconBg: const Color(0xFFEDE9FE),
                        title: "Track & Redeem",
                        badge: "NEW",
                        subtitle:
                            "Fast performance tracking, switch funds, and instant withdrawals.",
                        t: t,
                      ),
                      const SizedBox(height: 20),

                      // ── 3. Start Wealth Journey Promo Banner ───────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF031610), Color(0xFF0B3326)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFF1FAE7A,
                            ).withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Start your wealth journey with VIKA ONE",
                                    style: TextStyle(
                                      color: _goldLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Simple. Secure. Smart.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "All your investments in one unified app.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _gold.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.savings_rounded,
                                color: _gold,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 4. Trust & Security ───────────────────────────────
                      Text(
                        "Trust & Security",
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: _securityPillWithImage(
                              imagePath:
                                  'assets/images/Mutual_Funds/AMFI_mutual.png',
                              title: "AMFI Registered",
                              sub: "ARN Partner",
                              t: t,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _securityPillWithImage(
                              imagePath:
                                  'assets/images/Mutual_Funds/SEBI_securities.png',
                              title: "Regulated by SEBI",
                              sub: "Compliance",
                              t: t,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _securityPillWithImage(
                              imagePath: 'assets/images/Mutual_Funds/ISO.jfif',
                              title: "ISO Certified",
                              sub: "Bank Grade",
                              t: t,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Regulatory Disclaimer Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 15,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Mutual Fund investments are subject to market risks, read all scheme related documents carefully.",
                                style: TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 10.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ── Bottom Sticky Button ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border(top: BorderSide(color: t.cardBorder)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _onNotifyPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNotified
                          ? const Color(0xFF0B3D2E)
                          : _gold,
                      foregroundColor: _isNotified
                          ? Colors.white
                          : const Color(0xFF261800),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isNotified
                              ? "You're On The Priority List ✓"
                              : "Notify Me When It's Live",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _isNotified
                              ? Icons.check_circle_rounded
                              : Icons.notifications_active_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String badge,
    required String subtitle,
    required _T t,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: t.inkMuted, size: 18),
        ],
      ),
    );
  }

  Widget _securityPillWithImage({
    required String imagePath,
    required String title,
    required String sub,
    required _T t,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.cardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 24,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF0B3D2E),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.ink,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(color: t.inkMuted, fontSize: 8.5),
          ),
        ],
      ),
    );
  }
}
