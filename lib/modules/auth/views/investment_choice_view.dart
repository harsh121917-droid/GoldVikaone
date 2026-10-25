import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/lock_service.dart';
import '../../../routes/app_routes.dart';
import '../../home/bindings/home_binding.dart';

class InvestmentChoiceView extends StatefulWidget {
  const InvestmentChoiceView({super.key});

  @override
  State<InvestmentChoiceView> createState() => _InvestmentChoiceViewState();
}

class _InvestmentChoiceViewState extends State<InvestmentChoiceView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const Color _gold = Color(0xFFD4A017);
  static const Color _goldLight = Color(0xFFFFD56B);
  static const Color _mint = Color(0xFF00D09C);
  static const Color _mintLight = Color(0xFF5FF3C7);
  static const Color _bgDark = Color(0xFF040A07);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _openDigitalGold() {
    HapticFeedback.mediumImpact();
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();

    if (!auth.isLoggedIn) {
      Get.toNamed(AppRoutes.login, arguments: {'destination': AppRoutes.home});
    } else if (lock.pinActive.value) {
      Get.toNamed(AppRoutes.lockScreen, arguments: {'destination': AppRoutes.home});
    } else {
      HomeBinding().dependencies();
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void _openMutualFunds() {
    HapticFeedback.mediumImpact();
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();

    if (!auth.isLoggedIn) {
      Get.toNamed(AppRoutes.login, arguments: {'destination': AppRoutes.mutualFunds});
    } else if (lock.pinActive.value) {
      Get.toNamed(AppRoutes.lockScreen, arguments: {'destination': AppRoutes.mutualFunds});
    } else {
      // 1. Ensure Home, DigiGold & Wallet dependencies are registered permanently
      HomeBinding().dependencies();

      // 2. Safely navigate to Home, and then open Mutual Funds after frame renders
      Get.offAllNamed(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(AppRoutes.mutualFunds);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Background Ambience Gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.45),
                  radius: 1.35,
                  colors: [
                    Color(0x38D4A017),
                    Color(0x220B3D2E),
                    Color(0xFF040A07),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -size.width * 0.25,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _gold.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.85,
              height: size.width * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _mint.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Main Responsive Full-Screen Layout
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxHeight < 640;

                    final content = Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          // ── 1. Big Centered Logo & Luxury Branding ──
                          _buildBrandHeader(),
                          const SizedBox(height: 14),

                          // ── 2. Screen Title & Subtitle ──
                          _buildTitleSection(),
                          const SizedBox(height: 14),

                          // ── 3. Dual Gateway Cards (Side by Side 1 | 2 - Full Height) ──
                          if (isCompact)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildGoldCard(isCompact: true)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildMutualFundsCard(isCompact: true)),
                              ],
                            )
                          else
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _buildGoldCard(isCompact: false)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildMutualFundsCard(isCompact: false)),
                                ],
                              ),
                            ),

                          const SizedBox(height: 30),

                          // ── 4. Compact Trust Badges Footer ──
                          _buildTrustFooter(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );

                    if (isCompact) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: content,
                      );
                    }

                    return content;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Big Centered Logo Badge ──
  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 115,
          height: 115,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0B1E15),
            border: Border.all(
              color: _gold,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.diamond_rounded,
              color: _gold,
              size: 44,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFF6D8), _gold, Color(0xFFFFD56B)],
          ).createShader(bounds),
          child: const Text(
            'VIKAONE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.2,
            ),
          ),
        ),
      ],
    );
  }

  // ── Header Title & Subtitle ──
  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          'Choose Your Investment Gateway',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select where you want to start. Seamlessly switch anytime.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF9FBDB2).withValues(alpha: 0.9),
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // ── Choice 1: Digital Gold & Silver ──
  Widget _buildGoldCard({required bool isCompact}) {
    return _buildGatewayCard(
      title: 'Digital Gold\n& Silver',
      badgeText: '24K 99.9%',
      tagline: 'Start from ₹10',
      features: const [
        '24K Pure Bullion',
        'Live Market Rates',
        'Daily & SIP Plans',
        '100% Insured Vaults',
        'Doorstep Delivery',
      ],
      primaryColor: _gold,
      lightColor: _goldLight,
      iconBgColor: const Color(0xFF261D09),
      icon: Icons.monetization_on_rounded,
      iconImage: 'assets/images/gold_coin.png',
      buttonLabel: 'Enter Gold',
      onTap: _openDigitalGold,
      isCompact: isCompact,
    );
  }

  // ── Choice 2: Mutual Funds ──
  Widget _buildMutualFundsCard({required bool isCompact}) {
    return _buildGatewayCard(
      title: 'Mutual\nFunds',
      badgeText: 'NSE MFSS',
      tagline: 'SIP from ₹100',
      features: const [
        '1,000+ Schemes',
        'Direct NAV Growth',
        'Zero Commission',
        'SEBI Regulated',
        'Instant Switches',
      ],
      primaryColor: _mint,
      lightColor: _mintLight,
      iconBgColor: const Color(0xFF04261B),
      icon: Icons.trending_up_rounded,
      iconImage: 'assets/images/Mutual_Funds/NSE.png',
      buttonLabel: 'Enter Funds',
      onTap: _openMutualFunds,
      isCompact: isCompact,
    );
  }

  // ── Full-Height Gateway Card Builder ──
  Widget _buildGatewayCard({
    required String title,
    required String badgeText,
    required String tagline,
    required List<String> features,
    required Color primaryColor,
    required Color lightColor,
    required Color iconBgColor,
    required IconData icon,
    String? iconImage,
    required String buttonLabel,
    required VoidCallback onTap,
    required bool isCompact,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08140E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: primaryColor.withValues(alpha: 0.15),
            highlightColor: primaryColor.withValues(alpha: 0.08),
            child: Stack(
              children: [
                // Inner subtle gradient aura
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withValues(alpha: 0.14),
                          const Color(0xFF07120D),
                          primaryColor.withValues(alpha: 0.05),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top corner radial glow
                Positioned(
                  top: -24,
                  right: -24,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.16),
                    ),
                  ),
                ),

                // Card interactive content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
                    children: [
                      // Top Row: 3D Icon + Pill Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 3D Visual Icon Container
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.5),
                                width: 1.3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: iconImage != null
                                ? Image.asset(
                                    iconImage,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      icon,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  )
                                : Icon(
                                    icon,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                          ),
                          // Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.45),
                                width: 0.9,
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: lightColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                          height: 1.18,
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 6),

                      // Tagline Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          tagline,
                          style: TextStyle(
                            color: lightColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Features Bullet List
                      ...features.map((feat) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: const TextStyle(
                                      color: Color(0xFFD3E7DE),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),

                      // Dynamic spacer to push action button to the bottom on full-screen
                      if (!isCompact) const Spacer(),
                      if (isCompact) const SizedBox(height: 14),

                      // Action Button (Pinned to Bottom)
                      Container(
                        width: double.infinity,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              lightColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.38),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              buttonLabel,
                              style: const TextStyle(
                                color: Color(0xFF09130E),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF09130E),
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Compact Trust Badges Footer ──
  Widget _buildTrustFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF081711).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user_rounded, color: _mint.withValues(alpha: 0.9), size: 13),
            const SizedBox(width: 5),
            const Text(
              'SEBI Regulated',
              style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.25))),
            const SizedBox(width: 10),
            Icon(Icons.account_balance_rounded, color: _gold.withValues(alpha: 0.9), size: 13),
            const SizedBox(width: 5),
            const Text(
              'NSE MFSS Partner',
              style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.25))),
            const SizedBox(width: 10),
            Icon(Icons.lock_rounded, color: _goldLight.withValues(alpha: 0.9), size: 13),
            const SizedBox(width: 5),
            const Text(
              '100% Insured',
              style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
