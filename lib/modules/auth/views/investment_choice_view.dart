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
  static const Color _bgDark = Color(0xFF050B07);

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
      begin: const Offset(0, 0.08),
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
                  center: Alignment(0.0, -0.4),
                  radius: 1.3,
                  colors: [
                    Color(0x33D4A017),
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
                color: _gold.withValues(alpha: 0.05),
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
                color: _mint.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main Scrollable Interactive Content (prevents any screen overflow)
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Top Brand Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0C1710),
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.diamond_rounded,
                                color: _gold,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFFFFF4D0), _gold, Color(0xFFF7D070)],
                            ).createShader(bounds),
                            child: const Text(
                              'VIKAONE WEALTH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title & Subtitle
                      const Text(
                        'Choose Your Investment Focus',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Select where you want to start. You can seamlessly switch anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF9FBDB2).withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Choice 1: Digital Gold & Silver ──
                      _buildGatewayCard(
                        title: 'Digital Gold & Silver',
                        badgeText: '24K 99.9% PURE • BRINK\'S VAULT',
                        description:
                            'Invest in 24K pure gold & silver from ₹10. Stored in 100% insured vaults or delivered to your doorstep.',
                        features: const [
                          'Daily & Monthly Gold SIP',
                          'Live 24K Indian Market Rates',
                          'Doorstep Delivery of Gold Coins',
                        ],
                        primaryColor: _gold,
                        lightColor: _goldLight,
                        iconBgColor: const Color(0xFF261D09),
                        icon: Icons.monetization_on_rounded,
                        iconImage: 'assets/images/gold_coin.png',
                        buttonLabel: 'Enter Digital Gold',
                        onTap: _openDigitalGold,
                      ),

                      const SizedBox(height: 16),

                      // ── Choice 2: Mutual Funds (NSE MFSS) ──
                      _buildGatewayCard(
                        title: 'Mutual Funds',
                        badgeText: 'NSE MFSS • ZERO BROKERAGE',
                        description:
                            'Invest in 1,000+ top performing schemes from HDFC, SBI, Axis, ICICI & more with zero commission.',
                        features: const [
                          'Start SIPs from ₹100 / Month',
                          'Direct Exchange Allotment & NAV',
                          'SEBI Regulated & 100% Paperless',
                        ],
                        primaryColor: _mint,
                        lightColor: _mintLight,
                        iconBgColor: const Color(0xFF04261B),
                        icon: Icons.trending_up_rounded,
                        iconImage: 'assets/images/Mutual_Funds/NSE.png',
                        buttonLabel: 'Enter Mutual Funds',
                        onTap: _openMutualFunds,
                      ),

                      const SizedBox(height: 16),

                      // Trust Badges Footer with FittedBox to prevent any overflow
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
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
                              Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                              const SizedBox(width: 10),
                              Icon(Icons.account_balance_rounded, color: _gold.withValues(alpha: 0.9), size: 13),
                              const SizedBox(width: 5),
                              const Text(
                                'NSE MFSS Partner',
                                style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 10),
                              Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                              const SizedBox(width: 10),
                              Icon(Icons.lock_rounded, color: _gold.withValues(alpha: 0.9), size: 13),
                              const SizedBox(width: 5),
                              const Text(
                                '100% Insured',
                                style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayCard({
    required String title,
    required String badgeText,
    required String description,
    required List<String> features,
    required Color primaryColor,
    required Color lightColor,
    required Color iconBgColor,
    required IconData icon,
    String? iconImage,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF0A120E),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.45),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Subtle gradient background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withValues(alpha: 0.08),
                        Colors.transparent,
                        primaryColor.withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                ),
              ),

              // Ambient blur bubble in corner
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.15),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row: Badge + Icon
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pill badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              color: lightColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // 3D Visual Icon
                        Container(
                          width: 44,
                          height: 44,
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
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
                                    size: 22,
                                  ),
                                )
                              : Icon(
                                  icon,
                                  color: primaryColor,
                                  size: 22,
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Description
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF9FBDB2),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Feature Bullets
                    Row(
                      children: features.map((feat) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.15),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 11,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Action Button
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
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.35),
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
                              color: Color(0xFF0A120E),
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF0A120E),
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
    );
  }
}
