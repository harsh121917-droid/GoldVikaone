import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF070B0A),
          card: Color(0xFF121815),
          primary: _gold,
          ink: Color(0xFFF5F5F5),
          inkMuted: Color(0xFF98A2B3),
          cardBorder: Color(0x1AD4A017),
        )
      : const _T(
          bg: Color(0xFFF8F9FA),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF101828),
          inkMuted: Color(0xFF667085),
          cardBorder: Color(0xFFEAECF0),
        );
}

class AppUpdateView extends StatelessWidget {
  final String newVersion;
  final List<String> changelog;
  final bool isForceUpdate;
  final VoidCallback onUpdatePressed;

  const AppUpdateView({
    super.key,
    required this.newVersion,
    required this.changelog,
    required this.isForceUpdate,
    required this.onUpdatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final t = _T.of(dark);

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          // ── Ambient Background Glows ──
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _gold.withValues(alpha: dark ? 0.12 : 0.08),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0B3D2E).withValues(alpha: dark ? 0.18 : 0.08),
                    blurRadius: 120,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // ── Main Content Scroll Area ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(),

                  // 🚀 Animated Visual Icon Badge
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 900),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: dark
                              ? [const Color(0xFF132F23), const Color(0xFF042116)]
                              : [const Color(0xFFE2EBE5), const Color(0xFFF4F7F4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _gold.withValues(alpha: dark ? 0.2 : 0.1),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.system_update_alt_rounded,
                          size: 48,
                          color: _gold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 🏷️ Version Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _gold.withValues(alpha: 0.25), width: 0.8),
                    ),
                    child: Text(
                      'Version $newVersion is here!',
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 📝 Main Titles
                  Text(
                    'Time to Upgrade!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      fontFamily: 'DM Serif Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Update to the latest version to enjoy brand new features and general security enhancements.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Changelog / What's New Card ──
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: t.cardBorder, width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: _gold, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "What's New",
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: changelog.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: _gold,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        changelog[index],
                                        style: TextStyle(
                                          color: t.ink.withValues(alpha: 0.9),
                                          fontSize: 12.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Buttons ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Update Now Action Button
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_gold, _goldLight],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            onUpdatePressed();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Update Now',
                            style: TextStyle(
                              color: dark ? const Color(0xFF3D2B00) : Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      if (!isForceUpdate) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Remind Me Later',
                            style: TextStyle(
                              color: t.inkMuted,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
