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
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _purpleLight = Color(0xFFC084FC);
  static const Color _emerald = Color(0xFF00D09C);
  static const Color _emeraldLight = Color(0xFF5FF3C7);
  static const Color _cyan = Color(0xFF0284C7);
  static const Color _cyanLight = Color(0xFF38BDF8);
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
      begin: const Offset(0, 0.05),
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

  // ── 1. Digital Gold Navigation ───────────────────────────────
  void _openGold() {
    HapticFeedback.mediumImpact();
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();

    if (!auth.isLoggedIn) {
      Get.toNamed(AppRoutes.login, arguments: {
        'destination': AppRoutes.home,
        'initialMetalIndex': 0,
      });
    } else if (lock.pinActive.value) {
      Get.toNamed(AppRoutes.lockScreen, arguments: {
        'destination': AppRoutes.home,
        'initialMetalIndex': 0,
      });
    } else {
      HomeBinding().dependencies();
      Get.offAllNamed(AppRoutes.home, arguments: {'initialMetalIndex': 0});
    }
  }

  // ── 2. Mutual Funds (MF) Navigation ──────────────────────────
  void _openMutualFunds() {
    HapticFeedback.mediumImpact();
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();

    if (!auth.isLoggedIn) {
      Get.toNamed(AppRoutes.login, arguments: {
        'destination': AppRoutes.mutualFunds,
      });
    } else if (lock.pinActive.value) {
      Get.toNamed(AppRoutes.lockScreen, arguments: {
        'destination': AppRoutes.mutualFunds,
      });
    } else {
      HomeBinding().dependencies();
      Get.offAllNamed(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(AppRoutes.mutualFunds);
      });
    }
  }

  // ── 3. Fixed Deposits (FD) Navigation ────────────────────────
  void _openFixedDeposits() {
    HapticFeedback.mediumImpact();
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();

    if (!auth.isLoggedIn) {
      Get.toNamed(AppRoutes.login, arguments: {
        'destination': AppRoutes.fixedDeposits,
      });
    } else if (lock.pinActive.value) {
      Get.toNamed(AppRoutes.lockScreen, arguments: {
        'destination': AppRoutes.fixedDeposits,
      });
    } else {
      HomeBinding().dependencies();
      Get.offAllNamed(AppRoutes.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.toNamed(AppRoutes.fixedDeposits);
      });
    }
  }

  // ── 4. Bonds Navigation (In-App WebView with VikaOne Header) ──
  void _openBonds() {
    HapticFeedback.mediumImpact();
    Get.toNamed(AppRoutes.bonds);
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
                  radius: 1.4,
                  colors: [
                    Color(0x33D4A017),
                    Color(0x1F0B3D2E),
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
                color: _emerald.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Main Responsive Scrollable Screen
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 14),

                      // ── 1. Big Centered Luxury Brand Logo ──
                      _buildBrandHeader(),
                      const SizedBox(height: 12),

                      // ── 2. Screen Title & Subtitle ──
                      _buildTitleSection(),
                      const SizedBox(height: 18),

                      // ── 3. Four Gateway Cards in a 2x2 Grid ──
                      // Row 1: Gold & Mutual Funds
                      Row(
                        children: [
                          Expanded(child: _buildGoldCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildMutualFundsCard()),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 2: Fixed Deposits & Bonds
                      Row(
                        children: [
                          Expanded(child: _buildFixedDepositsCard()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildBondsCard()),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ── 4. Compact Trust Badges Footer ──
                      _buildTrustFooter(),
                      const SizedBox(height: 16),
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

  // ── Brand Header ──
  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0B1E15),
            border: Border.all(
              color: _gold,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.45),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.diamond_rounded,
              color: _gold,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFF6D8), _gold, Color(0xFFFFD56B)],
          ).createShader(bounds),
          child: const Text(
            'VIKAONE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
            ),
          ),
        ),
      ],
    );
  }

  // ── Title Section ──
  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          'Choose Your Investment Gateway',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select an asset class to begin. Switch anytime from the app menu.',
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

  // ── Card 1: Digi Gold Digi Silver ──
  Widget _buildGoldCard() {
    return _buildGatewayCard(
      title: 'Digi Gold Digi Silver',
      badgeText: '24K & 99.9%',
      tagline: 'From ₹10 • Gold & Silver',
      features: const [
        '24K Gold & 99.9% Silver',
        'Daily & Monthly SIP',
        'Doorstep Bullion Delivery',
      ],
      primaryColor: _gold,
      lightColor: _goldLight,
      iconBgColor: const Color(0xFF261D09),
      icon: Icons.monetization_on_rounded,
      iconImage: 'assets/images/gold_coin.png',
      buttonLabel: 'Enter Gold & Silver',
      onTap: _openGold,
    );
  }

  // ── Card 2: NSE MF (Mutual Funds) ──
  Widget _buildMutualFundsCard() {
    return _buildGatewayCard(
      title: 'NSE MF',
      badgeText: 'NSE Direct',
      tagline: 'Top AMCs • SIP from ₹500',
      features: const [
        '1,000+ Top Rated Funds',
        'Direct SIP & Lumpsum',
        'Zero Commission Plans',
      ],
      primaryColor: _purple,
      lightColor: _purpleLight,
      iconBgColor: Colors.white,
      icon: Icons.auto_graph_rounded,
      iconImage: 'assets/images/Mutual_Funds/NSE.png',
      buttonLabel: 'Explore NSE MF',
      onTap: _openMutualFunds,
    );
  }

  // ── Card 3: Fixed Deposits (FD) ──
  Widget _buildFixedDepositsCard() {
    return _buildGatewayCard(
      title: 'Fixed Deposits',
      badgeText: 'Up to 9.40%',
      tagline: 'CRISIL AAA • IRIS Form',
      features: const [
        'Bajaj, Shriram & Mahindra',
        '3 Active IRIS Partners',
        'Compounded Returns',
      ],
      primaryColor: _emerald,
      lightColor: _emeraldLight,
      iconBgColor: const Color(0xFF04261B),
      icon: Icons.account_balance_rounded,
      buttonLabel: 'Explore FDs',
      onTap: _openFixedDeposits,
    );
  }

  // ── Card 4: Bonds (BondBazaar Integration) ──
  Widget _buildBondsCard() {
    return _buildGatewayCard(
      title: 'Bonds',
      badgeText: 'BondBazaar',
      tagline: 'High Yield Trading',
      features: const [
        'Sovereign & Corp Bonds',
        'Higher Returns than FD',
        'Demat Direct Account',
      ],
      primaryColor: _cyan,
      lightColor: _cyanLight,
      iconBgColor: const Color(0xFF092238),
      icon: Icons.candlestick_chart_rounded,
      buttonLabel: 'Trade Bonds',
      onTap: _openBonds,
    );
  }

  // ── Universal Gateway Card Component ──
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08140E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.45),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: primaryColor.withValues(alpha: 0.2),
            highlightColor: primaryColor.withValues(alpha: 0.1),
            child: Stack(
              children: [
                // Inner gradient aura
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

                // Corner glow circle
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),

                // Interactive content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Icon + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.28),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                color: lightColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
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
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Tagline
                      Text(
                        tagline,
                        style: TextStyle(
                          color: lightColor.withValues(alpha: 0.9),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // Features bullet list
                      ...features.map((feat) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 11.5,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: const TextStyle(
                                      color: Color(0xFFD3E7DE),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 12),

                      // Action Button
                      Container(
                        width: double.infinity,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              lightColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
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
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF09130E),
                              size: 14,
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

  // ── Trust Footer ──
  Widget _buildTrustFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF081711).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
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
            Icon(Icons.verified_user_rounded, color: _emerald.withValues(alpha: 0.9), size: 13),
            const SizedBox(width: 5),
            const Text(
              'SEBI & AMFI Registered',
              style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.25))),
            const SizedBox(width: 10),
            Icon(Icons.account_balance_rounded, color: _gold.withValues(alpha: 0.9), size: 13),
            const SizedBox(width: 5),
            const Text(
              'IRIS & BondBazaar Partner',
              style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 10),
            Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.25))),
            const SizedBox(width: 10),
            Icon(Icons.lock_rounded, color: _goldLight.withValues(alpha: 0.9), size: 13),
            const SizedBox(width: 5),
            const Text(
              '100% Insured Assets',
              style: TextStyle(color: Color(0xFF9FBDB2), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
