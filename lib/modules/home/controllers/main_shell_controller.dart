import 'package:vika1/services/notification_service.dart';
import 'package:vika1/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/modules/kyc/controllers/kyc_controller.dart';
import 'package:vika1/core/network/api_client.dart';


class MainShellController extends GetxController {
  final tabIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final refreshSchemesEvent = 0.obs;
  final refreshJewelleryEvent = 0.obs;
  final refreshRewardsEvent = 0.obs;

  @override
  void onReady() {
    super.onReady();
    // Check for app updates on startup
    _checkForUpdate();
    LocationService.to.checkAndPromptLocation();
    NotificationService.syncCurrentToken();
  }

  Future<void> _checkForUpdate() async {
    try {
      const currentVersion = '0.16.0';
      final dio = ApiClient.instance;
      final res = await dio.get('/app-version');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data;
        final latestVersion = data['latestVersion']?.toString() ?? '0.16.0';
        final forceUpdate = data['forceUpdate'] == true;
        final playStoreUrl = data['playStoreUrl']?.toString() ??
            'https://play.google.com/store/apps/details?id=com.vikaone.app';

        if (currentVersion != latestVersion) {
          // Delay slightly to ensure UI is fully rendered before showing bottom sheet
          Future.delayed(const Duration(seconds: 1), () {
            _showUpdateBottomSheet(
              newVersion: latestVersion,
              isForceUpdate: forceUpdate,
              playStoreUrl: playStoreUrl,
            );
          });
        }
      }
    } catch (_) {}
  }

  void _showUpdateBottomSheet({
    required String newVersion,
    required bool isForceUpdate,
    required String playStoreUrl,
  }) {
    const gold = Color(0xFFD4A017);
    const goldLight = Color(0xFFFFD700);
    const emerald = Color(0xFF10B981);

    Get.bottomSheet(
      _UpdateSheetWidget(
        newVersion: newVersion,
        isForceUpdate: isForceUpdate,
        playStoreUrl: playStoreUrl,
        gold: gold,
        goldLight: goldLight,
        emerald: emerald,
      ),
      isScrollControlled: true,
      isDismissible: !isForceUpdate,
      enableDrag: !isForceUpdate,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }


  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  void changeTab(int i) {
    if (tabIndex.value == i) return;
    tabIndex.value = i;
    // Defer data refresh to after layout — never triggers reentrant layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTab(i));
  }

  void _refreshTab(int i) {
    if (i == 0) {
      if (Get.isRegistered<GoldController>()) {
        GoldController.to.loadBalance();
        GoldController.to.loadTransactions();
      }
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadAll();
      }
    }
    if (i == 1) {
      refreshSchemesEvent.value++;
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadAll();
      }
    }
    if (i == 2) {
      refreshJewelleryEvent.value++;
    }
    if (i == 3) {
      refreshRewardsEvent.value++;
    }
    if (i == 4) {
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadWallet();
      }
      if (Get.isRegistered<KycController>()) {
        Get.find<KycController>().loadMyKyc();
      }
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Premium Animated Update Bottom Sheet Widget
// ══════════════════════════════════════════════════════════════════════════════
class _UpdateSheetWidget extends StatefulWidget {
  final String newVersion;
  final bool isForceUpdate;
  final String playStoreUrl;
  final Color gold;
  final Color goldLight;
  final Color emerald;

  const _UpdateSheetWidget({
    required this.newVersion,
    required this.isForceUpdate,
    required this.playStoreUrl,
    required this.gold,
    required this.goldLight,
    required this.emerald,
  });

  @override
  State<_UpdateSheetWidget> createState() => _UpdateSheetWidgetState();
}

class _UpdateSheetWidgetState extends State<_UpdateSheetWidget>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnim = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _openStore() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(widget.playStoreUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A017);
    const goldLight = Color(0xFFFFD700);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1713) : Colors.white;
    final cardBg = isDark ? const Color(0xFF16231D) : const Color(0xFFF3F7F5);
    final borderColor = isDark ? const Color(0x33D4A017) : const Color(0xFFE2EBE6);
    final titleColor = isDark ? Colors.white : const Color(0xFF0B1712);
    final descColor = isDark ? const Color(0xFF8FA79C) : const Color(0xFF6B7E75);

    return PopScope(
      canPop: !widget.isForceUpdate,
      child: AnimatedBuilder(
        animation: _entryCtrl,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _slideAnim.value),
          child: Opacity(opacity: _fadeAnim.value, child: child),
        ),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                blurRadius: 36,
                spreadRadius: 4,
                offset: const Offset(0, -6),
              ),
              BoxShadow(
                color: gold.withValues(alpha: isDark ? 0.10 : 0.05),
                blurRadius: 50,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag Handle & Optional Close ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      if (!widget.isForceUpdate)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Get.back();
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              border: Border.all(color: borderColor, width: 0.8),
                            ),
                            child: Icon(Icons.close_rounded, size: 14, color: descColor),
                          ),
                        )
                      else
                        const SizedBox(width: 24),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Compact Header: Modern Glowing Icon + Title & Version ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Modern 3D/Glowing Icon Squircle
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF223E30), Color(0xFF0E2218)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: gold.withValues(alpha: 0.75),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.32 * _pulseAnim.value),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: goldLight,
                                  size: 24,
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: goldLight,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 14),

                      // Title & Version Pill
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Update Available',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        gold.withValues(alpha: 0.20),
                                        goldLight.withValues(alpha: 0.10),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: gold.withValues(alpha: 0.5),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    'v${widget.newVersion}',
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.isForceUpdate
                                  ? 'Important update required to proceed.'
                                  : 'Faster speed, new schemes & enhanced security.',
                              style: TextStyle(
                                color: descColor,
                                fontSize: 11.5,
                                height: 1.25,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Modern Sleek Feature Chips (Single Row) ──
                  Row(
                    children: [
                      _CompactChip(
                        icon: Icons.bolt_rounded,
                        label: '2x Faster',
                        color: gold,
                        bg: cardBg,
                        border: borderColor,
                        text: titleColor,
                      ),
                      const SizedBox(width: 8),
                      _CompactChip(
                        icon: Icons.security_rounded,
                        label: 'Safe & Secure',
                        color: const Color(0xFF10B981),
                        bg: cardBg,
                        border: borderColor,
                        text: titleColor,
                      ),
                      const SizedBox(width: 8),
                      _CompactChip(
                        icon: Icons.diamond_outlined,
                        label: 'New Features',
                        color: goldLight,
                        bg: cardBg,
                        border: borderColor,
                        text: titleColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Action Buttons Row ──
                  if (!widget.isForceUpdate)
                    Row(
                      children: [
                        // Later Button
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 44,
                            child: TextButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Get.back();
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: cardBg,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                  side: BorderSide(color: borderColor, width: 1),
                                ),
                              ),
                              child: Text(
                                'Later',
                                style: TextStyle(
                                  color: descColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Update Now Button
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [gold, goldLight],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: gold.withValues(alpha: 0.38),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _openStore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.rocket_launch_rounded,
                                      color: Color(0xFF1B1300),
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Update Now',
                                      style: TextStyle(
                                        color: Color(0xFF1B1300),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    // Mandatory Force Update CTA
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [gold, goldLight],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _openStore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.system_update_alt_rounded,
                                  color: Color(0xFF1B1300), size: 17),
                              SizedBox(width: 8),
                              Text(
                                'Update to Continue',
                                style: TextStyle(
                                  color: Color(0xFF1B1300),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final Color border;
  final Color text;

  const _CompactChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.border,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12.5, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: text,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




