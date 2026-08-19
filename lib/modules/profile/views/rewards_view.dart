import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vika1/modules/home/controllers/main_shell_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';

import '../../../core/network/api_client.dart';

// ─── Theme styling ───────────────────────────────────────────────────────────
class _T {
  final Color bg, card, primary, ink, inkMuted, border, subBg;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.subBg,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF060B16),
          card: Color(0xFF0E1626),
          primary: Color(0xFF3B82F6),
          ink: Color(0xFFEDF0FF),
          inkMuted: Color(0xFF8A95B0),
          border: Color(0xFF1A2B45),
          subBg: Color(0xFF0A0F1E),
        )
      : const _T(
          bg: Color(0xFFF0F4FF),
          card: Colors.white,
          primary: Color(0xFF1A2340),
          ink: Color(0xFF1A2340),
          inkMuted: Color(0xFF6B7280),
          border: Color(0xFFE8DFC8),
          subBg: Color(0xFFF3F5F9),
        );
}

// ─── Points Transaction Model ────────────────────────────────────────────────
class PointTransaction {
  final String title;
  final int amount;
  final String date;
  final String type; // 'gain' or 'redeem'
  PointTransaction(this.title, this.amount, this.date, this.type);
}

// ─── Persistent GetX Points Controller ───────────────────────────────────────
class PointsController extends GetxController {
  static PointsController get to => Get.find<PointsController>();

  final _dio = ApiClient.instance;

  var points = 0.obs;
  var spinsLeft = 3.obs;
  var pointTransactions = <PointTransaction>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<MainShellController>().refreshRewardsEvent, (_) {
      loadAll();
    });
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadBalance(), loadHistory()]);
    isLoading.value = false;
  }

  Future<void> loadBalance() async {
    try {
      final res = await _dio.get('/rewards/balance');
      if (res.data['success'] == true) {
        points.value = (res.data['data']['rewardPoints'] as num).toInt();
        final serverSpins = res.data['data']['spinsLeft'] as int?;
        final canSpin = res.data['data']['canSpin'] as bool;
        spinsLeft.value = serverSpins ?? (canSpin ? 3 : 0);
      }
    } catch (_) {}
  }

  Future<void> loadHistory() async {
    try {
      final res = await _dio.get('/rewards/history');
      if (res.data['success'] == true) {
        final list = res.data['data'] as List;
        pointTransactions.value = list.map((item) {
          final typeStr = item['type'] as String;
          final pts = (item['points'] as num).toInt();
          final isGain = pts >= 0;
          
          DateTime dt;
          if (item['createdAt'] != null) {
            dt = DateTime.parse(item['createdAt'] as String).toLocal();
          } else {
            dt = DateTime.now();
          }
          final dateStr = '${dt.day.toString().padLeft(2, '0')} ${_getMonthName(dt.month)} ${dt.year}';
          
          return PointTransaction(
            item['description'] ?? 'Points transaction',
            pts.abs(),
            dateStr,
            isGain ? 'gain' : 'redeem',
          );
        }).toList();
      }
    } catch (_) {}
  }

  String _getMonthName(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  void addPoints(int val, String source) async {
    try {
      await _dio.post('/rewards/spin', data: {'pointsWinner': val});
      loadAll();
    } catch (_) {
      points.value += val;
      pointTransactions.insert(
        0,
        PointTransaction(source, val, _getCurrentDate(), 'gain'),
      );
    }
  }

  bool redeemPoints(int val, String item) {
    return false;
  }

  void decrementSpin() {
    if (spinsLeft.value > 0) {
      spinsLeft.value--;
    }
  }

  void resetSpins() {
    spinsLeft.value = 3;
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} ${_getMonthName(now.month)} ${now.year}';
  }
}

// ─── Main View ───────────────────────────────────────────────────────────────
class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late Animation<double> _spinAnim;

  // Segment configuration
  final List<Map<String, dynamic>> _segments = [
    {'label': '10 pts', 'value': 10, 'color': const Color(0xFFF39C12)},
    {'label': '50 pts', 'value': 50, 'color': const Color(0xFF2ECC71)},
    {'label': '500 Jackpot!', 'value': 500, 'color': const Color(0xFFE74C3C)},
    {'label': 'Try Again', 'value': 0, 'color': const Color(0xFF95A5A6)},
    {'label': '25 pts', 'value': 25, 'color': const Color(0xFF3498DB)},
    {'label': '100 pts', 'value': 100, 'color': const Color(0xFF9B59B6)},
    {'label': '5 pts', 'value': 5, 'color': const Color(0xFFE67E22)},
    {'label': '250 pts', 'value': 250, 'color': const Color(0xFF1ABC9C)},
  ];

  bool _isSpinning = false;
  double _currentAngle = 0.0;
  int _lastTickWedge = -1;
  int _winningWedgeIndex = 0;

  @override
  void initState() {
    super.initState();
    // Ensure points controller is registered
    if (!Get.isRegistered<PointsController>()) {
      Get.put(PointsController());
    }
    // Trigger initial load on creation since tab just loaded
    PointsController.to.loadAll();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _spinAnim = CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutCubic);

    _spinCtrl.addListener(() {
      final totalAngle = _spinAnim.value;
      // Precision haptic pin tick calculation as segments pass
      final currentTickSegment =
          ((_currentAngle + totalAngle) * _segments.length / (2 * pi)).floor();
      if (currentTickSegment != _lastTickWedge) {
        HapticFeedback.lightImpact();
        _lastTickWedge = currentTickSegment;
      }
    });

    _spinCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning || PointsController.to.spinsLeft.value <= 0) return;

    setState(() {
      _isSpinning = true;
    });

    PointsController.to.decrementSpin();
    HapticFeedback.mediumImpact();

    // Random destination wedge with 20% probability for the 500 Jackpot (index 2)
    int targetWedge;
    if (Random().nextDouble() < 0.20) {
      targetWedge = 2; // Index 2 is "500 Jackpot!"
    } else {
      final nonJackpotWedges = [0, 1, 3, 4, 5, 6, 7];
      targetWedge = nonJackpotWedges[Random().nextInt(nonJackpotWedges.length)];
    }
    _winningWedgeIndex = targetWedge;

    // Standard polar coordinates pointer is at 270 degrees (1.5 * pi)
    // localAngle = (1.5 * pi - targetAngle) % (2 * pi)
    // To land on targetWedge, we want targetAngle to make localAngle hit targetWedge * (2*pi/Segments) + half_wedge (for centering)
    final wedgeAngle = 2 * pi / _segments.length;
    final centerWedgeAngle = targetWedge * wedgeAngle + (wedgeAngle / 2);
    final targetAngle = (1.5 * pi - centerWedgeAngle) % (2 * pi);

    // Dynamic spin counts (5 to 8 full spins) + target angle offset
    final fullSpins = 5 + Random().nextInt(4);
    final finalRotation = (fullSpins * 2 * pi) + targetAngle;

    _spinAnim = Tween<double>(
      begin: _currentAngle,
      end: finalRotation,
    ).animate(CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOutCubic));

    _spinCtrl.reset();
    _spinCtrl.forward().then((_) {
      _currentAngle = finalRotation % (2 * pi);
    });
  }

  void _onSpinComplete() {
    final win = _segments[_winningWedgeIndex];
    final pointsWon = win['value'] as int;

    if (pointsWon > 0) {
      PointsController.to.addPoints(pointsWon, 'Spun the Wheel');
    }

    setState(() {
      _isSpinning = false;
    });

    _showRewardDialog(win);
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final t = _T.of(dark);
    final pc = PointsController.to;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        title: Text(
          'Rewards Club',
          style: TextStyle(
            color: t.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Points Balance Dashboard Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [const Color(0xFF2C3E50), const Color(0xFF1E2B38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Points Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Obx(
                        () => Text(
                          '${pc.points.value} pts',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFFFD700),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // ── Spin To Win Game Label ──
            Text(
              'SPIN TO WIN',
              style: TextStyle(
                color: t.ink,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Spin the wheel to earn points instantly!',
              style: TextStyle(color: t.inkMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // ── Wheel Stack Layout ──
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer border shadow base
                Container(
                  width: 290,
                  height: 290,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.08),
                  ),
                ),
                // Outer Wheel Ring rim
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.card,
                    border: Border.all(color: t.border, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFFFFD700,
                        ).withOpacity(dark ? 0.15 : 0.08),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),

                // Animated Rotating Custom Wheel
                AnimatedBuilder(
                  animation: _spinAnim,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinAnim.value,
                      child: SizedBox(
                        width: 260,
                        height: 260,
                        child: CustomPaint(
                          painter: _WheelPainter(
                            segments: _segments,
                            dark: dark,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Top needle pointer indicator
                Positioned(
                  top: 0,
                  child: Transform.rotate(
                    angle: pi,
                    child: CustomPaint(
                      size: const Size(20, 28),
                      painter: _NeedlePainter(dark),
                    ),
                  ),
                ),

                // Center hub spin button
                Obx(() => GestureDetector(
                    onTap: _isSpinning || pc.spinsLeft.value <= 0
                        ? null
                        : _startSpin,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C3E50), Color(0xFF0F172A)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isSpinning
                              ? 'SPIN'
                              : pc.spinsLeft.value <= 0
                              ? 'EMPTY'
                              : 'SPIN',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ── Spins left counter status pill ──
            Obx(() =>
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: t.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty_rounded,
                          color: pc.spinsLeft.value > 0
                              ? const Color(0xFF2ECC71)
                              : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pc.spinsLeft.value > 0
                              ? 'Spins Left Today: ${pc.spinsLeft.value}/3'
                              : 'No spins left! Come back tomorrow.',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Refer & Earn Section ──
            Builder(
              builder: (context) {
                final user = Get.find<AuthController>().user.value;
                final refCode = user?.referralCode ?? 'VIKA100';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: t.card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: t.border.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people_outline_rounded,
                              color: Color(0xFFFFD700),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Refer & Earn Points',
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Invite friends to get referral bonus points',
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: t.subBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.border.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'YOUR REFERRAL CODE',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    refCode,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: refCode));
                                HapticFeedback.mediumImpact();
                                Get.snackbar(
                                  'Code Copied! 📋',
                                  'Referral code copied to clipboard',
                                  backgroundColor: const Color(0xFF2ECC71),
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(15),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: t.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'COPY CODE',
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
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => _shareReferral(refCode),
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: const Text(
                            'SHARE BANNER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // ── Redemption Catalog ──
            _buildRedemptionCatalog(context, t, pc),
            const SizedBox(height: 30),

            // ── Points History ──
            _buildPointsHistory(context, t, pc),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _shareReferral(String refCode) async {
    try {
      HapticFeedback.mediumImpact();
      final byteData = await rootBundle.load('assets/images/jar_img.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/vikaone_referral.png');
      await file.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Join Vikaone using my referral code: $refCode and get free gold reward points! 🎁💰 Download here: https://play.google.com/store/apps/details?id=com.payvika.vikaone&pcampaignid=web_share',
      );
    } catch (e) {
      await Share.share(
        'Join Vikaone using my referral code: $refCode and get free gold reward points! 🎁💰 Download here: https://play.google.com/store/apps/details?id=com.payvika.vikaone&pcampaignid=web_share',
      );
    }
  }

  Widget _buildRedemptionCatalog(
    BuildContext context,
    _T t,
    PointsController pc,
  ) {
    final catalog = [
      {
        'name': '₹1 Gold Voucher',
        'points': 100,
        'icon': Icons.diamond_outlined,
        'color': const Color(0xFFD4A017),
      },
      {
        'name': '₹5 Gold Voucher',
        'points': 500,
        'icon': Icons.hexagon_outlined,
        'color': const Color(0xFF9AA3AD),
      },
      {
        'name': '₹10 Gold Voucher',
        'points': 1000,
        'icon': Icons.local_shipping_outlined,
        'color': Colors.blue,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeem Points Catalog',
            style: TextStyle(
              color: t.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: catalog.map((item) {
              final cost = item['points'] as int;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.subBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.border.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (item['color'] as Color).withOpacity(
                        0.12,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$cost points required',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => SizedBox(
                      width: 80,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pc.points.value >= cost
                                ? const Color(0xFF2ECC71)
                                : Colors.grey.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onPressed: pc.points.value >= cost
                              ? () {
                                  final success = pc.redeemPoints(
                                    cost,
                                    item['name'] as String,
                                  );
                                  if (success) {
                                    Get.snackbar(
                                      'Redeemed! 🎉',
                                      'Successfully redeemed ${item['name']}',
                                      backgroundColor: const Color(0xFF2ECC71),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      margin: const EdgeInsets.all(15),
                                    );
                                  }
                                }
                              : null,
                          child: const Text(
                            'Redeem',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsHistory(BuildContext context, _T t, PointsController pc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Points History (Gains & Redemptions)',
            style: TextStyle(
              color: t.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => pc.pointTransactions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No point history found',
                      style: TextStyle(color: t.inkMuted, fontSize: 12),
                    ),
                  ),
                )
              : Column(
                  children: pc.pointTransactions.map((tx) {
                    final isGain = tx.type == 'gain';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isGain
                                ? Icons.add_circle_outline_rounded
                                : Icons.remove_circle_outline_rounded,
                            color: isGain
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.title,
                                  style: TextStyle(
                                    color: t.ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  tx.date,
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isGain ? '+' : '-'}${tx.amount} pts',
                            style: TextStyle(
                              color: isGain
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFE74C3C),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          )
        ],
      ),
    );
  }

  // ─── Celebration Reward Overlay Dialog ────────────────────────────────────
  void _showRewardDialog(Map<String, dynamic> win) {
    final pointsWon = win['value'] as int;
    final isJackpot = pointsWon == 500;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scaleCurve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutBack,
        );
        final opacityCurve = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOut,
        );

        final dark = ThemeController.to.isDark.value;
        final t = _T.of(dark);

        return FadeTransition(
          opacity: opacityCurve,
          child: ScaleTransition(
            scale: scaleCurve,
            child: AlertDialog(
              backgroundColor: t.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vector celebration stars stack
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color:
                              (pointsWon > 0
                                      ? const Color(0xFFFFD700)
                                      : const Color(0xFF95A5A6))
                                  .withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(
                        pointsWon > 0
                            ? Icons.emoji_events_rounded
                            : Icons.sentiment_dissatisfied_rounded,
                        color: pointsWon > 0
                            ? const Color(0xFFFFD700)
                            : const Color(0xFF95A5A6),
                        size: 54,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    pointsWon > 0
                        ? isJackpot
                              ? '🚨 JACKPOT WON! 🚨'
                              : 'Congratulations!'
                        : 'Aww! Try Again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: pointsWon > 0
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFE74C3C),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pointsWon > 0
                        ? 'You spun the wheel and successfully earned $pointsWon points!'
                        : 'No luck this time, spin again to unlock points!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: t.inkMuted, fontSize: 12),
                  ),
                  if (pointsWon > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFFFFD700),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+$pointsWon Reward Points Added',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: pointsWon > 0
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Custom Wheel Wedge Painter ───────────────────────────────────────────────
class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;
  final bool dark;
  _WheelPainter({required this.segments, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final wedgeAngle = 2 * pi / segments.length;

    for (int i = 0; i < segments.length; i++) {
      final startAngle = i * wedgeAngle;
      final paint = Paint()
        ..color = (segments[i]['color'] as Color).withOpacity(
          dark ? 0.85 : 0.95,
        )
        ..style = PaintingStyle.fill;

      // Draw segment slice
      canvas.drawArc(rect, startAngle, wedgeAngle, true, paint);

      // Draw segment separator lines
      final borderPaint = Paint()
        ..color = dark ? const Color(0x33FFFFFF) : const Color(0x33000000)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, startAngle, wedgeAngle, true, borderPaint);

      // Draw text label inside wedge
      canvas.save();
      final labelAngle = startAngle + wedgeAngle / 2;
      canvas.translate(center.dx, center.dy);
      canvas.rotate(labelAngle);

      final textSpan = TextSpan(
        text: segments[i]['label'] as String,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 1)),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // Position text along the middle of the segment radius
      textPainter.paint(canvas, Offset(radius * 0.45, -textPainter.height / 2));

      canvas.restore();
    }

    // Draw circular silver/gold pins around the rim
    final pinPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < segments.length; i++) {
      final angle = i * wedgeAngle;
      final px = center.dx + (radius - 8) * cos(angle);
      final py = center.dy + (radius - 8) * sin(angle);
      canvas.drawCircle(Offset(px, py), 4, pinPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Custom Needle Pointer Painter ───────────────────────────────────────────
class _NeedlePainter extends CustomPainter {
  final bool dark;
  _NeedlePainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
