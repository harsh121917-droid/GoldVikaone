import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/sip_repository.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../gold_sip/views/sip_journey_view.dart';

// ─── Design Tokens ──────────────────────────────────────────────────────────
const _silver = Color(0xFF9E9E9E);
const _success = Color(0xFF10B981);
const _danger = Color(0xFFEF4444);

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
          bg: Color(0xFF060B14),
          card: Color(0xFF0E1626),
          primary: Color(0xFF94A3B8),
          ink: Color(0xFFEDF0FF),
          inkMuted: Color(0xFF8A95B0),
          border: Color(0xFF1E293B),
          subBg: Color(0xFF0F172A),
        )
      : const _T(
          bg: Color(0xFFF8FAFC),
          card: Colors.white,
          primary: Color(0xFF1E293B),
          ink: Color(0xFF0F172A),
          inkMuted: Color(0xFF64748B),
          border: Color(0xFFE2E8F0),
          subBg: Color(0xFFF1F5F9),
        );
}

class SilverSipView extends StatefulWidget {
  const SilverSipView({super.key});
  @override
  State<SilverSipView> createState() => _SilverSipViewState();
}

class _SilverSipViewState extends State<SilverSipView> {
  final _sipRepo = SipRepository();
  int _activeTab = 0; // 0 = Create SIP, 1 = My Active SIPs & Journey


  // ── Goal-Based Silver SIP State ──
  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'baby',
      'title': "Baby's Silver Wealth",
      'subtitle': "Child's 18th milestone silver accumulation",
      'icon': Icons.child_care_rounded,
      'badge': "Top Choice for Parents",
      'color': Color(0xFF38BDF8),
      'suggestedAmount': '1500',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'travel',
      'title': "Dream Vacation Fund",
      'subtitle': "Fund family travel with 999 fine silver bullion",
      'icon': Icons.flight_takeoff_rounded,
      'badge': "1-Year Goal",
      'color': Color(0xFFF472B6),
      'suggestedAmount': '2000',
      'suggestedDurationIdx': 1, // 1 Year
    },
    {
      'id': 'wedding',
      'title': "Wedding Utensils & Silverware",
      'subtitle': "Accumulate 999 pure silver for auspicious occasions",
      'icon': Icons.diamond_outlined,
      'badge': "Most Popular",
      'color': Color(0xFF94A3B8),
      'suggestedAmount': '3000',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'festival',
      'title': "Festivals & Silver Coins",
      'subtitle': "Dhanteras & Diwali silver coins ready in advance",
      'icon': Icons.celebration_rounded,
      'badge': "Auspicious Savings",
      'color': Color(0xFFFB923C),
      'suggestedAmount': '1000',
      'suggestedDurationIdx': 1, // 1 Year
    },
    {
      'id': 'home',
      'title': "Dream House Silver Security",
      'subtitle': "Substantial bullion backup for real estate",
      'icon': Icons.cottage_rounded,
      'badge': "High Growth",
      'color': Color(0xFF34D399),
      'suggestedAmount': '5000',
      'suggestedDurationIdx': 4, // 5 Years
    },
    {
      'id': 'education',
      'title': "Higher Education Fund",
      'subtitle': "College tuition & degree fund",
      'icon': Icons.school_rounded,
      'badge': "Education First",
      'color': Color(0xFFA78BFA),
      'suggestedAmount': '2500',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'wealth',
      'title': "Silver Wealth & Reserve",
      'subtitle': "Heavy weight physical silver vault reserve",
      'icon': Icons.account_balance_rounded,
      'badge': "Compounding Wealth",
      'color': Color(0xFFCBD5E1),
      'suggestedAmount': '3000',
      'suggestedDurationIdx': 4, // 5 Years
    },
  ];
  int _selectedGoalIdx = 0;

  // ── Create SIP State ──
  bool _isStartingSip = false;
  String _selectedFreq = 'Monthly';
  final List<String> _frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
  ];

  final _amountCtrl = TextEditingController(text: '1000');
  double get _amount => double.tryParse(_amountCtrl.text) ?? 0.0;

  final List<Map<String, dynamic>> _durations = [
    {'label': '6 Months', 'months': 6},
    {'label': '1 Year', 'months': 12},
    {'label': '2 Years', 'months': 24},
    {'label': '3 Years', 'months': 36},
    {'label': '5 Years', 'months': 60},
  ];
  int _selectedDurationIdx = 1; // 1 Year default

  double get _buyRate => Get.isRegistered<SilverController>() && SilverController.to.buyRate > 0 ? SilverController.to.buyRate : 85.0;

  int get _months => _durations[_selectedDurationIdx]['months'] as int;

  int get _cyclesCount {
    final m = _months;
    if (_selectedFreq == 'Daily') return m * 30;
    if (_selectedFreq == 'Weekly') return m * 4;
    if (_selectedFreq == 'Monthly') return m;
    if (_selectedFreq == 'Quarterly') return (m / 3).ceil();
    return (m / 12).ceil();
  }

  double get _totalInvested => _amount * _cyclesCount;
  double get _gramsPerCycle => (_amount / 1.03) / _buyRate;
  double get _totalGrams => _gramsPerCycle * _cyclesCount;
  
  // ── My SIPs State ──
  bool _loadingMySips = false;
  SipPortfolioSummary _portfolioSummary = const SipPortfolioSummary();
  List<SipModel> _mySips = [];

  @override
  void initState() {
    super.initState();
    _loadMySips();
  }

  Future<void> _loadMySips() async {
    setState(() => _loadingMySips = true);
    try {
      final res = await _sipRepo.getMySips();
      setState(() {
        _portfolioSummary = res['portfolio'] as SipPortfolioSummary;
        final all = res['sips'] as List<SipModel>;
        _mySips = all.where((s) => s.isSilver).toList();
        _loadingMySips = false;
      });
    } catch (_) {
      setState(() => _loadingMySips = false);
    }
  }

  Future<void> _handleStartSip() async {
    if (_amount < 100) {
      Get.snackbar(
        'Minimum Amount',
        'Minimum SIP installment is ₹100',
        backgroundColor: _danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final walletBal = Get.isRegistered<WalletController>() ? (WalletController.to.wallet.value?.availableBalance ?? WalletController.to.wallet.value?.balance ?? 0.0) : 0.0;
    if (walletBal < _amount) {
      Get.snackbar(
        'Low Wallet Balance',
        'You need ₹${_amount.toStringAsFixed(0)} in your wallet to start this SIP. Current balance: ₹${walletBal.toStringAsFixed(0)}',
        backgroundColor: _danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isStartingSip = true);
    try {
      final selectedGoal = _goals[_selectedGoalIdx];
      final created = await _sipRepo.createSip(
        metal: 'silver',
        frequency: _selectedFreq.toLowerCase(),
        installmentAmount: _amount,
        durationMonths: _months,
        goalCategory: selectedGoal['id'] as String,
        goalTitle: selectedGoal['title'] as String,
        paymentMethod: 'wallet',
      );

      if (Get.isRegistered<WalletController>()) { WalletController.to.loadWallet(); }
      _loadMySips();

      Get.snackbar(
        'Silver SIP Started!',
        'Your first installment of ₹${_amount.toStringAsFixed(0)} is paid and silver is credited to your vault.',
        backgroundColor: _success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Switch to My SIPs tab
      setState(() => _activeTab = 1);
      Get.to(() => SipJourneyView(sipId: created.id));
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: _danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isStartingSip = false);
    }
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
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
              // ── Header ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: t.ink, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Digi Silver SIP',
                                style: TextStyle(color: t.ink, fontSize: 17, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '999 Pure Silver',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Systematic Fine Silver Accumulation',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Segmented Pill Controller ─────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: t.subBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _activeTab = 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == 0
                                  ? (dark ? const Color(0xFF334155) : const Color(0xFF1E293B))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calculate_rounded,
                                    size: 15,
                                    color: _activeTab == 0 ? Colors.white : t.inkMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Create Silver SIP',
                                    style: TextStyle(
                                      color: _activeTab == 0 ? Colors.white : t.inkMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _activeTab = 1);
                            _loadMySips();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == 1
                                  ? (dark ? const Color(0xFF334155) : const Color(0xFF1E293B))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    size: 15,
                                    color: _activeTab == 1 ? Colors.white : t.inkMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'My SIPs & Journey',
                                    style: TextStyle(
                                      color: _activeTab == 1 ? Colors.white : t.inkMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_mySips.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: _activeTab == 1 ? Colors.white.withOpacity(0.25) : Colors.blueGrey.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_mySips.length}',
                                        style: TextStyle(
                                          color: _activeTab == 1 ? Colors.white : const Color(0xFF94A3B8),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Tab Content ───────────────────────────────────────────
              Expanded(
                child: _activeTab == 0
                    ? _buildCreateSipTab(t, dark)
                    : _buildMySipsTab(t, dark),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 1: CREATE NEW SILVER SIP
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildCreateSipTab(_T t, bool dark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Live Rate & Banner ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.bolt_rounded, color: Color(0xFF94A3B8), size: 14),
                        SizedBox(width: 4),
                        Text('LIVE 999 SILVER RATE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_buyRate.toStringAsFixed(2)} / gram',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text('100% Pure', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Frequency Selector ────────────────────────────────────────
          Text('Select SIP Frequency', style: TextStyle(color: t.ink, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _frequencies.map((f) {
                final isSel = _selectedFreq == f;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFreq = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF334155) : t.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? const Color(0xFF64748B) : t.border),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: isSel ? Colors.white : t.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Amount Input Card ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Installment Amount (₹)', style: TextStyle(color: t.inkMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Per $_selectedFreq', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(color: t.ink, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Text('₹', style: TextStyle(color: t.ink, fontSize: 24, fontWeight: FontWeight.w900)),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    filled: true,
                    fillColor: t.subBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [100.0, 500.0, 1000.0, 2500.0, 5000.0].map((val) {
                    final active = _amount == val;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _amountCtrl.text = val.toInt().toString()),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF334155) : t.subBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: active ? const Color(0xFF64748B) : Colors.transparent),
                          ),
                          child: Center(
                            child: Text(
                              '₹${val.toInt()}',
                              style: TextStyle(color: active ? Colors.white : t.inkMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Duration Selector ─────────────────────────────────────────
          Text('Investment Duration', style: TextStyle(color: t.ink, fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _durations.asMap().entries.map((e) {
                final idx = e.key;
                final dur = e.value;
                final isSel = _selectedDurationIdx == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDurationIdx = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF334155) : t.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? const Color(0xFF64748B) : t.border),
                    ),
                    child: Text(
                      dur['label'] as String,
                      style: TextStyle(
                        color: isSel ? Colors.white : t.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // ── Projected Growth & Simulation ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Projected Summary', style: TextStyle(color: t.ink, fontSize: 13, fontWeight: FontWeight.w800)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Est. +16.0% Growth', style: TextStyle(color: _success, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Est. Silver Grams', style: TextStyle(color: t.inkMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '${_totalGrams.toStringAsFixed(2)}g',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Investment', style: TextStyle(color: t.inkMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_totalInvested.toStringAsFixed(0)}',
                            style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Cycles', style: TextStyle(color: t.inkMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '$_cyclesCount $_selectedFreq',
                            style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Start Silver SIP CTA ──────────────────────────────────────
          GestureDetector(
            onTap: _isStartingSip ? null : _handleStartSip,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isStartingSip
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Start Silver SIP (Pay ₹${_amount.toStringAsFixed(0)})',
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TAB 2: MY ACTIVE SILVER SIPS & JOURNEY
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildMySipsTab(_T t, bool dark) {
    if (_loadingMySips) {
      return const Center(child: CircularProgressIndicator(color: _silver));
    }

    if (_mySips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings_outlined, color: Color(0xFF94A3B8), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Silver SIPs',
                style: TextStyle(color: t.ink, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Start your first Silver SIP to accumulate pure 999 fine silver grams systematically.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.inkMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF334155),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => setState(() => _activeTab = 0),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Start New Silver SIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Silver Portfolio Summary Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Silver SIP Portfolio Valuation', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                const SizedBox(height: 4),
                Text(
                  '₹${_portfolioSummary.totalCurrentValue.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Accumulated Silver', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                          Text('${_portfolioSummary.totalGramsSilver.toStringAsFixed(2)}g', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Invested', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                          Text('₹${_portfolioSummary.totalInvested.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Plans', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                          Text('${_portfolioSummary.activeSipsCount}', style: const TextStyle(color: _success, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text('Your Active Silver SIP Plans', style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),

          // ── SIP Cards List ──
          ..._mySips.map((sip) => _buildSipCard(sip, t, dark)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSipCard(SipModel sip, _T t, bool dark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.layers_rounded, color: Color(0xFF94A3B8), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹${sip.installmentAmount.toStringAsFixed(0)} / ${sip.frequency}',
                        style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      Row(
                        children: [
                          Text(
                            sip.goalTitle.isNotEmpty ? sip.goalTitle : '${sip.durationMonths} Months Plan',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sip.isActive ? _success.withOpacity(0.15) : const Color(0xFF64748B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sip.status.toUpperCase(),
                  style: TextStyle(
                    color: sip.isActive ? _success : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Silver Accumulated', style: TextStyle(color: t.inkMuted, fontSize: 10)),
                  Text('${sip.totalGrams.toStringAsFixed(2)}g', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Value', style: TextStyle(color: t.inkMuted, fontSize: 10)),
                  Text('₹${sip.currentValuation.toStringAsFixed(0)}', style: TextStyle(color: t.ink, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Next Due', style: TextStyle(color: t.inkMuted, fontSize: 10)),
                  Text(_fmtDate(sip.nextDueDate), style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: sip.totalCycles > 0 ? (sip.cyclesCompleted / sip.totalCycles).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              backgroundColor: t.subBg,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${sip.cyclesCompleted} of ${sip.totalCycles} cycles completed', style: TextStyle(color: t.inkMuted, fontSize: 10)),
              Text('${sip.progressPct.toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 12),

          // Action Button: View Full Journey
          GestureDetector(
            onTap: () async {
              await Get.to(() => SipJourneyView(sipId: sip.id));
              _loadMySips();
            },
            child: Container(
              height: 42,
              width: double.infinity,
              decoration: BoxDecoration(
                color: t.subBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.border),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.route_rounded, size: 16, color: t.ink),
                    const SizedBox(width: 6),
                    Text('View Full SIP Journey & Timeline', style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 16, color: t.inkMuted),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
