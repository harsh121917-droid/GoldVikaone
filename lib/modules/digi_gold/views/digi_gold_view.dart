import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/routes/app_routes.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../modules/auth/controllers/auth_controller.dart';
import '../../home/controllers/main_shell_controller.dart';
import '../../jewellery/controllers/jewellery_controller.dart';
import 'package:vika1/data/repositories/gold_repository.dart';
import 'package:vika1/data/repositories/silver_repository.dart';
import 'package:vika1/modules/silver_sip/views/silver_transaction_detail_view.dart';
import 'transaction_detail_view.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _silver = Color(0xFF9AA3AD);
const _silverLight = Color(0xFFD4D9DE);
const _success = Color(0xFF2ecc71);
const _danger = Color(0xFFE05A47);

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder, subBg, ctaText;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.ctaText,
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
        );
}

class DigiGoldView extends StatefulWidget {
  const DigiGoldView({super.key});
  @override
  State<DigiGoldView> createState() => _DigiGoldViewState();
}

class _DigiGoldViewState extends State<DigiGoldView>
    with WidgetsBindingObserver {
  final _heroCtrl = PageController();
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshAll();
  }

  void _refreshAll() async {
    await Future.wait([
      Get.find<GoldController>().loadAll(),
      Get.find<SilverController>().loadAll(),
      Get.find<WalletController>().loadAll(),
    ]);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);
      return Scaffold(
        backgroundColor: t.bg,
        body: RefreshIndicator(
          onRefresh: () async => _refreshAll(),
          color: t.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                _TopBar(t: t, greeting: _greeting()),
                const SizedBox(height: 6),
                SizedBox(
                  height: 275,
                  child: PageView(
                    controller: _heroCtrl,
                    onPageChanged: (i) => setState(() => _heroIndex = i),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _GoldHeroCard(t: t),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SilverHeroCard(t: t),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _heroIndex ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _heroIndex
                            ? (i == 0 ? _gold : _silver)
                            : t.inkMuted.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _QuickActions(t: t),
                const SizedBox(height: 20),
                _LiveRates(t: t),
                const SizedBox(height: 20),
                _PromoBanner(t: t),
                const SizedBox(height: 20),
                _SipPromoCard(t: t),
                const SizedBox(height: 20),
                _DeliveryBanner(
                  t: t,
                  onTap: () {
                    Get.find<MainShellController>().changeTab(2);
                    if (Get.isRegistered<JewelleryController>()) {
                      JewelleryController.to.selectCategory('Coins');
                    }
                  },
                ),
                const SizedBox(height: 20),
                _RecentTransactionsSection(t: t),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.t, required this.greeting});
  final _T t;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() {
                  final user = Get.find<AuthController>().user.value;
                  return Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Welcome Back${user != null ? ', ${user.name.split(' ')[0]}' : ''}!',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('👋', style: TextStyle(fontSize: 16)),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.card,
                shape: BoxShape.circle,
                border: Border.all(color: t.cardBorder),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: t.ink,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.find<MainShellController>().changeTab(4),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: t.card,
                shape: BoxShape.circle,
                border: Border.all(color: t.cardBorder),
              ),
              child: Icon(Icons.person_outline_rounded, color: t.ink, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gold hero card ───────────────────────────────────────────────────────────
class _GoldHeroCard extends StatelessWidget {
  const _GoldHeroCard({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final grams = GoldController.to.totalGrams;
      final value = GoldController.to.balance.value?.currentValue ?? 0;
      return Container(
        // clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/gold banner.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_gold, _goldLight]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFF3D2B00),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'GOLD BALANCE',
                    style: TextStyle(
                      color: _gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.myGold),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF0B3D2E)),
                        color: const Color(0xFF0B3D2E),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${grams.toStringAsFixed(3)} g',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                '24K (99.9%)',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.white24),
              const SizedBox(height: 10),
              Text(
                '₹ ${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Current Value',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _pill(
                    Icons.add,
                    'Buy Gold',
                    Colors.black.withOpacity(0.35),
                    _gold,
                    () => Get.toNamed(AppRoutes.buyGold),
                    outline: true,
                    borderColor: _gold,
                  ),
                  const SizedBox(width: 10),
                  _pill(
                    Icons.north_east_rounded,
                    'Sell Gold',
                    Colors.black.withOpacity(0.35),
                    _gold,
                    () => Get.toNamed(AppRoutes.sellGold),
                    outline: true,
                    borderColor: _gold,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.myGold),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Chart',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.bar_chart_rounded, color: _gold, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _pill(
    IconData icon,
    String label,
    Color bg,
    Color fg,
    VoidCallback onTap, {
    bool outline = false,
    Color? borderColor,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: outline
            ? Border.all(color: borderColor ?? Colors.white24)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Silver hero card ─────────────────────────────────────────────────────────
class _SilverHeroCard extends StatelessWidget {
  const _SilverHeroCard({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final grams = SilverController.to.totalGrams;
      final value = SilverController.to.balance.value?.currentValue ?? 0;
      const darkInk = Color(0xFF1A2B22);
      const darkMuted = Color(0xFF6B7A72);
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/silver banner.png'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [_silver, _silverLight]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.circle_outlined,
                      color: Color(0xFF2A2E33),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SILVER BALANCE',
                    style: TextStyle(
                      color: darkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.mySilver),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: darkMuted.withOpacity(0.5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Details',
                            style: TextStyle(
                              color: darkInk,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: darkInk,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${grams.toStringAsFixed(3)} g',
                style: const TextStyle(
                  color: darkInk,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                '999 Fine Silver',
                style: TextStyle(color: darkMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: Colors.black12),
              const SizedBox(height: 10),
              Text(
                '₹ ${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: darkInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Current Value',
                style: TextStyle(color: darkMuted, fontSize: 11),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _pill(
                    Icons.add,
                    'Buy Silver',
                    const Color(0xFF0B3D2E),
                    Colors.white,
                    () => Get.toNamed(AppRoutes.buySilver),
                  ),
                  const SizedBox(width: 10),
                  _pill(
                    Icons.north_east_rounded,
                    'Sell Silver',
                    Colors.white.withOpacity(0.5),
                    darkInk,
                    () => Get.toNamed(AppRoutes.sellSilver),
                    outline: true,
                    borderColor: darkMuted.withOpacity(0.5),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.mySilver),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Chart',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.bar_chart_rounded, color: _gold, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _pill(
    IconData icon,
    String label,
    Color bg,
    Color fg,
    VoidCallback onTap, {
    bool outline = false,
    Color? borderColor,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: outline
            ? Border.all(color: borderColor ?? Colors.black26)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatefulWidget {
  const _QuickActions({required this.t});
  final _T t;

  @override
  State<_QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<_QuickActions> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;

    final row1 = [
      (
        Icons.shopping_bag_outlined,
        'Buy Gold',
        const Color(0xFFD4A017),
        () => Get.toNamed(AppRoutes.buyGold),
      ),
      (
        Icons.shopping_bag_outlined,
        'Buy Silver',
        const Color(0xFF9AA3AD),
        () => Get.toNamed(AppRoutes.buySilver),
      ),
      (
        Icons.history_rounded,
        'Transactions',
        Colors.blue,
        () => Get.toNamed(AppRoutes.transactions),
      ),
      (
        Icons.calendar_month_outlined,
        'SIP Plan',
        Colors.purple,
        () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start Savings Plan (SIP)',
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(Icons.diamond_outlined, color: _gold),
                    title: Text('Gold SIP', style: TextStyle(color: t.ink)),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.digiGoldSavings);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.hexagon_outlined, color: _silver),
                    title: Text('Silver SIP', style: TextStyle(color: t.ink)),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.silverSip);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      (
        Icons.redeem_outlined,
        'Gift',
        Colors.orange,
        () {
          Get.snackbar(
            'Coming Soon',
            'Gift feature is launching soon!',
            backgroundColor: t.primary,
            colorText: Colors.white,
          );
        },
      ),
    ];

    final row2 = [
      (
        Icons.wallet_outlined,
        'Add Money',
        const Color(0xFFD4A017),
        () => Get.toNamed(AppRoutes.wallet),
      ),
      (
        Icons.swap_horizontal_circle_outlined,
        'Sell',
        const Color(0xFF2ecc71),
        () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sell Assets',
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    leading: const Icon(Icons.diamond_outlined, color: _gold),
                    title: Text('Sell Gold', style: TextStyle(color: t.ink)),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.sellGold);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.hexagon_outlined, color: _silver),
                    title: Text('Sell Silver', style: TextStyle(color: t.ink)),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.sellSilver);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      (
        Icons.trending_up_rounded,
        'Price Chart',
        const Color(0xFFD4A017),
        () => Get.toNamed(AppRoutes.myGold),
      ),
      (
        Icons.menu_book_outlined,
        'Passbook',
        Colors.brown,
        () {
          Get.snackbar(
            'Coming Soon',
            'Passbook is launching soon!',
            backgroundColor: t.primary,
            colorText: Colors.white,
          );
        },
      ),
      (
        Icons.share_outlined,
        'Refer & Earn',
        Colors.indigo,
        () {
          Get.snackbar(
            'Coming Soon',
            'Refer & Earn is launching soon!',
            backgroundColor: t.primary,
            colorText: Colors.white,
          );
        },
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row1
                .map((it) => _buildItem(it.$1, it.$2, it.$3, it.$4))
                .toList(),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row2
                  .map((it) => _buildItem(it.$1, it.$2, it.$3, it.$4))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: t.inkMuted.withOpacity(0.1), height: 1),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isExpanded ? 'Show Less' : 'Show More',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: t.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: widget.t.ink,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Live Market Rates ────────────────────────────────────────────────────────
class _LiveRates extends StatefulWidget {
  const _LiveRates({required this.t});
  final _T t;

  @override
  State<_LiveRates> createState() => _LiveRatesState();
}

class _LiveRatesState extends State<_LiveRates> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        // Each card is 150 width + 10 padding = 160 step
        var targetScroll = currentScroll + 160.0;
        if (targetScroll >= maxScroll + 20.0) {
          targetScroll = 0.0;
        }
        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Market Rates',
                style: TextStyle(
                  color: widget.t.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.find<GoldController>().loadRate();
                  Get.find<SilverController>().loadRate();
                },
                child: Obx(() {
                  final updated = GoldController.to.rate.value?.updatedAt;
                  return Row(
                    children: [
                      Text(
                        updated != null
                            ? 'Updated ${updated.day}/${updated.month}, ${updated.hour}:${updated.minute.toString().padLeft(2, '0')}'
                            : 'Tap to refresh',
                        style: TextStyle(
                          color: widget.t.inkMuted,
                          fontSize: 10.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.refresh_rounded,
                        color: widget.t.inkMuted,
                        size: 14,
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(
                  width: 150,
                  child: _rateCard(
                    'Gold (24K)',
                    () => GoldController.to.buyRate,
                    () => GoldController.to.goldPct,
                    _gold,
                    Icons.workspace_premium_rounded,
                    widget.t,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _rateCard(
                    'Silver (999)',
                    () => GoldController.to.silverRate,
                    () => GoldController.to.silverPct,
                    _silver,
                    Icons.circle_outlined,
                    widget.t,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _rateCard(
                    'Platinum (950)',
                    () => GoldController.to.platinumRate,
                    () => GoldController.to.platinumPct,
                    const Color(0xFFE5E8EB),
                    Icons.stars_rounded,
                    widget.t,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _rateCard(
                    'Palladium',
                    () => GoldController.to.palladiumRate,
                    () => GoldController.to.palladiumPct,
                    const Color(0xFF8A95A5),
                    Icons.blur_on_rounded,
                    widget.t,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  child: _rateCard(
                    'Copper',
                    () => GoldController.to.copperRate,
                    () => GoldController.to.copperPct,
                    const Color(0xFFD35400),
                    Icons.radio_button_checked_rounded,
                    widget.t,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rateCard(
    String label,
    double Function() rate,
    double Function() pct,
    Color accent,
    IconData icon,
    _T t,
  ) => Obx(() {
    final p = pct();
    final isUp = p >= 0;
    final c = isUp ? _success : _danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: c,
                size: 13,
              ),
            ],
          ),
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '₹${rate().toStringAsFixed(2)}/g',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${isUp ? '+' : ''}${p.abs().toStringAsFixed(2)}%',
                style: TextStyle(
                  color: c,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

// ─── Promo banner ─────────────────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bannerBg = dark ? const Color(0xFF072E20) : const Color(0xFF0A4D34);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: bannerBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Introducing Gold & Silver',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'by vikaOne',
              style: TextStyle(
                color: _gold,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Buy real Gold & Silver directly at exchange prices. Get doorstep delivery of pure gold at home.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.goldSchemes),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_gold, _goldLight],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Invest Now',
                          style: TextStyle(
                            color: Color(0xFF3D2B00),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF3D2B00),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified_user_rounded, color: _gold, size: 13),
                      SizedBox(width: 6),
                      Text(
                        '999 Certified Purity',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SIP Promo Card ───────────────────────────────────────────────────────────
class _SipPromoCard extends StatelessWidget {
  const _SipPromoCard({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: t.cardBorder == Colors.transparent
                ? Colors.black12
                : t.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Set up SIP in ',
                          style: TextStyle(color: t.ink),
                        ),
                        const TextSpan(
                          text: 'Gold',
                          style: TextStyle(color: _gold),
                        ),
                        TextSpan(
                          text: ' or ',
                          style: TextStyle(color: t.ink),
                        ),
                        const TextSpan(
                          text: 'Silver',
                          style: TextStyle(color: _silver),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build wealth regularly with small investments.',
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _featureItem(Icons.tune_rounded, 'Flexible Amount'),
                      _featureItem(
                        Icons.verified_user_outlined,
                        'Secure Investment',
                      ),
                      _featureItem(Icons.show_chart_rounded, 'Wealth Growth'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Choose SIP Asset',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ListTile(
                          leading: const Icon(
                            Icons.workspace_premium_rounded,
                            color: _gold,
                          ),
                          title: Text(
                            'Gold SIP',
                            style: TextStyle(color: t.ink),
                          ),
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoutes.digiGoldSavings);
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.circle_outlined,
                            color: _silver,
                          ),
                          title: Text(
                            'Silver SIP',
                            style: TextStyle(color: t.ink),
                          ),
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoutes.silverSip);
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3D2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Start SIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: _gold,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: t.inkMuted, size: 14),
        const SizedBox(height: 4),
        Text(
          label.replaceAll(' ', '\n'),
          style: TextStyle(
            color: t.inkMuted,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Recent Transactions Section ─────────────────────────────────────────────
class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection({required this.t});
  final _T t;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final goldTxns = GoldController.to.transactions;
      final silverTxns = SilverController.to.transactions;

      // Combine real transactions
      final List<dynamic> combined = [...goldTxns, ...silverTxns];
      combined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final recent = combined.take(3).toList();

      // Fallback mock data matching the screenshot
      final List<dynamic> displayTxns = recent.isNotEmpty
          ? recent
          : [
              // Mock gold buy
              GoldTxnModel(
                id: 'mock1',
                type: 'buy',
                status: 'success',
                grams: 0.256,
                ratePerGram: 7123.00,
                goldValue: 1824.45,
                gstAmt: 0.0,
                totalAmt: 1824.45,
                createdAt: DateTime.now().subtract(const Duration(hours: 2)),
              ),
              // Mock silver buy
              SilverTxnModel(
                id: 'mock2',
                type: 'buy',
                status: 'success',
                grams: 10.000,
                ratePerGram: 73.40,
                silverValue: 734.00,
                gstAmt: 0.0,
                totalAmt: 734.00,
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
              ),
              // Mock gold sell
              GoldTxnModel(
                id: 'mock3',
                type: 'sell',
                status: 'success',
                grams: 0.150,
                ratePerGram: 7102.00,
                goldValue: 1065.30,
                gstAmt: 0.0,
                totalAmt: 1065.30,
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
              ),
            ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.transactions),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, color: _gold, size: 13),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayTxns.length,
              separatorBuilder: (_, __) =>
                  Divider(color: t.inkMuted.withOpacity(0.12), height: 1),
              itemBuilder: (context, index) {
                final txn = displayTxns[index];
                final isGold = txn is GoldTxnModel;
                final isBuy = txn.type == 'buy';

                final title = isGold
                    ? (isBuy ? 'Gold Purchased' : 'Gold Sold')
                    : (isBuy ? 'Silver Purchased' : 'Silver Sold');

                final dateStr =
                    '${txn.createdAt.day} ${_monthName(txn.createdAt.month)} ${txn.createdAt.year}, ${_formatTime(txn.createdAt)}';
                final subtitle =
                    '${txn.grams.toStringAsFixed(3)} g  ·  $dateStr';

                final gramsPrefix = isBuy ? '+' : '-';
                final gramsColor = isBuy ? _success : _danger;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isGold ? _gold : _silver).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBuy
                          ? Icons.shopping_cart_outlined
                          : Icons.north_east_rounded,
                      color: isGold ? _gold : _silver,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 13.5,
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
                          color: gramsColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isBuy ? 'Buy' : 'Sell',
                          style: TextStyle(
                            color: gramsColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    subtitle,
                    style: TextStyle(color: t.inkMuted, fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$gramsPrefix${txn.grams.toStringAsFixed(3)} g',
                            style: TextStyle(
                              color: gramsColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹ ${txn.totalAmt.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: t.inkMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: t.inkMuted,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to appropriate detail screen
                    if (isGold) {
                      Get.to(() => TransactionDetailView(txn: txn));
                    } else {
                      Get.to(() => SilverTransactionDetailView(txn: txn));
                    }
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }
}

class _DeliveryBanner extends StatelessWidget {
  const _DeliveryBanner({required this.t, required this.onTap});
  final _T t;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bgColors = dark
        ? [const Color(0xFF0C1D15), const Color(0xFF050E0A)]
        : [const Color(0xFFEAE6DC), const Color(0xFFF7F4EE)];
    final textColor = dark ? Colors.white : const Color(0xFF1A2B22);
    final textSubColor = dark ? Colors.white70 : const Color(0xFF6B7A72);
    final bannerBorder = dark
        ? Border.all(color: const Color(0xFF1E3D30))
        : Border.all(color: const Color(0xFFD4C8B3));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: bannerBorder,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(
                    0xFFD4A017,
                  ).withOpacity(dark ? 0.06 : 0.03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A017).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD4A017).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.local_shipping_outlined,
                                color: Color(0xFFD4A017),
                                size: 13,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'PHYSICAL DELIVERY',
                                style: TextStyle(
                                  color: Color(0xFFD4A017),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Doorstep Gold Delivery',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Convert your digital savings into 999.9 pure certified physical coins safely delivered to your home.',
                          style: TextStyle(
                            color: textSubColor,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4A017), Color(0xFFF3C343)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD4A017,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Get Delivery',
                                  style: TextStyle(
                                    color: Color(0xFF3D2B00),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFF3D2B00),
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFD4A017,
                      ).withOpacity(dark ? 0.08 : 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(
                          0xFFD4A017,
                        ).withOpacity(dark ? 0.15 : 0.08),
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.all_inbox_rounded,
                            color: const Color(0xFFD4A017).withOpacity(0.3),
                            size: 40,
                          ),
                          const Icon(
                            Icons.local_shipping_rounded,
                            color: Color(0xFFD4A017),
                            size: 26,
                          ),
                        ],
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
