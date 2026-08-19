import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/lock_service.dart';
import '../../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _floatAnim;

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
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.2, 0.85, curve: Curves.easeIn),
    );

    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animCtrl.repeat(reverse: true);
    _animCtrl.forward();

    Timer(const Duration(milliseconds: 3000), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();

    final String nextRoute = !auth.isLoggedIn
        ? AppRoutes.login
        : (lock.pinActive.value ? AppRoutes.lockScreen : AppRoutes.home);

    Get.offAllNamed(nextRoute);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050B07),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.2),
                  radius: 1.2,
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
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4A017).withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1FAE7A).withValues(alpha: 0.05),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  AnimatedBuilder(
                    animation: _animCtrl,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 146,
                                height: 146,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFD4A017,
                                      ).withValues(alpha: 0.35),
                                      blurRadius: 42,
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFF1FAE7A,
                                      ).withValues(alpha: 0.2),
                                      blurRadius: 62,
                                      spreadRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 130,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0C1710),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withValues(alpha: 0.6),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, stack) =>
                                        Image.asset(
                                          'assets/images/jar_img.png',
                                          fit: BoxFit.contain,
                                        ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD4A017,
                                        ).withValues(alpha: 0.4),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/gold_coin.png',
                                    errorBuilder: (ctx, err, stack) =>
                                        const Icon(
                                          Icons.monetization_on_rounded,
                                          color: Color(0xFFD4A017),
                                          size: 28,
                                        ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/silver_coin.png',
                                    errorBuilder: (ctx, err, stack) =>
                                        const Icon(
                                          Icons.circle_rounded,
                                          color: Colors.grey,
                                          size: 26,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFFFFF4D0),
                        Color(0xFFD4A017),
                        Color(0xFFF7D070),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      'Vikaone',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C1710),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFD4A017,
                          ).withValues(alpha: 0.12),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFD4A017),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'GOLD  •  SILVER  •  JEWELLERY',
                          style: TextStyle(
                            color: Color(0xFFEDF3EF),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '24K Gold  •  99.9% Pure Silver  •  Certified Jewellery',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7C9689),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: 140,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: Color(0xFF14291D),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFD4A017),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Secured & Certified',
                          style: TextStyle(
                            color: const Color(
                              0xFF7C9689,
                            ).withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
