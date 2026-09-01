import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/sip_repository.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'sip_journey_view.dart';

// ─── Design Tokens ──────────────────────────────────────────────────────────
const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
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
          bg: Color(0xFF060B08),
          card: Color(0xFF0D1812),
          primary: Color(0xFF10B981),
          ink: Color(0xFFEDF3EF),
          inkMuted: Color(0xFF7C9689),
          border: Color(0x2210B981),
          subBg: Color(0xFF12221A),
        )
      : const _T(
          bg: Color(0xFFF9FAFB),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF0F172A),
          inkMuted: Color(0xFF64748B),
          border: Color(0xFFE2E8F0),
          subBg: Color(0xFFF1F5F9),
        );
}

class DigiGoldSavingsView extends StatefulWidget {
  const DigiGoldSavingsView({super.key});
  @override
  State<DigiGoldSavingsView> createState() => _DigiGoldSavingsViewState();
}

class _DigiGoldSavingsViewState extends State<DigiGoldSavingsView> {
  late Razorpay _razorpay;
  String _paymentMode = 'autopay'; // 'autopay' or 'wallet'
  Map<String, dynamic>? _pendingAutoPayData;
  final _sipRepo = SipRepository();
  int _activeTab = 0; // 0 = Create SIP, 1 = My Active SIPs & Journey

  // ── Goal-Based SIP State ──
  final List<Map<String, dynamic>> _goals = [
    {
      'id': 'soldier',
      'title': "Veer Jawan / Soldier Goal",
      'subtitle': "Armed Forces & Police special bullion reserve",
      'icon': Icons.military_tech_rounded,
      'badge': "🎖️ 15% OFF Hero Offer",
      'discountTag': "SPECIAL 15% OFF",
      'color': const Color(0xFF10B981),
      'suggestedAmount': '2500',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'car',
      'title': "New Car & Vehicle",
      'subtitle': "Gold-backed fund for your dream vehicle downpayment",
      'icon': Icons.directions_car_rounded,
      'badge': "Luxury Asset",
      'discountTag': "Top Goal",
      'color': const Color(0xFFF59E0B),
      'suggestedAmount': '5000',
      'suggestedDurationIdx': 2, // 2 Years
    },
    {
      'id': 'education',
      'title': "Higher Education Fund",
      'subtitle': "College tuition & university degree security",
      'icon': Icons.school_rounded,
      'badge': "Education First",
      'discountTag': "Zero Fee",
      'color': const Color(0xFFA78BFA),
      'suggestedAmount': '4000',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'phone',
      'title': "New Phone & Gadgets",
      'subtitle': "Smart bullion plan for the latest flagships",
      'icon': Icons.phone_iphone_rounded,
      'badge': "Tech Milestone",
      'discountTag': "Short Term",
      'color': const Color(0xFF38BDF8),
      'suggestedAmount': '1500',
      'suggestedDurationIdx': 0, // 6 Months
    },
    {
      'id': 'wedding',
      'title': "Wedding & Bridal Jewellery",
      'subtitle': "Accumulate 24K pure gold for wedding ornaments",
      'icon': Icons.diamond_outlined,
      'badge': "Most Popular",
      'discountTag': "Best Value",
      'color': const Color(0xFFD4A017),
      'suggestedAmount': '5000',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'baby',
      'title': "Baby's Golden Future",
      'subtitle': "Child's 18th milestone & education reserve",
      'icon': Icons.child_care_rounded,
      'badge': "Top Choice for Parents",
      'discountTag': "High Growth",
      'color': const Color(0xFF06B6D4),
      'suggestedAmount': '2500',
      'suggestedDurationIdx': 3, // 3 Years
    },
    {
      'id': 'home',
      'title': "Dream Home & Property",
      'subtitle': "Substantial gold security for downpayment",
      'icon': Icons.cottage_rounded,
      'badge': "High Growth",
      'discountTag': "Wealth Builder",
      'color': const Color(0xFF34D399),
      'suggestedAmount': '10000',
      'suggestedDurationIdx': 4, // 5 Years
    },
    {
      'id': 'travel',
      'title': "Dream Vacation & Travel",
      'subtitle': "Hedge world tours with rising gold bullion",
      'icon': Icons.flight_takeoff_rounded,
      'badge': "1-Year Goal",
      'discountTag': "1-Year Plan",
      'color': const Color(0xFFF472B6),
      'suggestedAmount': '3000',
      'suggestedDurationIdx': 1, // 1 Year
    },
    {
      'id': 'festival',
      'title': "Festivals & Auspicious Days",
      'subtitle': "Diwali, Dhanteras & Akshaya Tritiya ready",
      'icon': Icons.celebration_rounded,
      'badge': "Auspicious Savings",
      'discountTag': "Festive",
      'color': const Color(0xFFFB923C),
      'suggestedAmount': '2000',
      'suggestedDurationIdx': 1, // 1 Year
    },
    {
      'id': 'wealth',
      'title': "Wealth & Retirement",
      'subtitle': "Sovereign digital gold long-term reserve",
      'icon': Icons.account_balance_rounded,
      'badge': "Compounding Wealth",
      'discountTag': "Long Term",
      'color': const Color(0xFFFFD700),
      'suggestedAmount': '5000',
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

  double get _buyRate =>
      Get.isRegistered<GoldController>() && GoldController.to.buyRate > 0
      ? GoldController.to.buyRate
      : 7350.0;

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
  double get _expectedReturns => _totalInvested * 0.175;

  // ── My SIPs State ──
  bool _loadingMySips = false;
  SipPortfolioSummary _portfolioSummary = const SipPortfolioSummary();
  List<SipModel> _mySips = [];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRzpSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRzpError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRzpExternal);

    _selectedGoalIdx = 0;
    final args = Get.arguments;
    if (args is Map) {
      if (args['goalCategory'] != null || args['selectedGoalId'] != null) {
        final goalId = (args['goalCategory'] ?? args['selectedGoalId']).toString().toLowerCase();
        final foundIdx = _goals.indexWhere((g) => g['id'].toString().toLowerCase() == goalId);
        if (foundIdx != -1) {
          _selectedGoalIdx = foundIdx;
        }
      } else if (args['goalIndex'] != null && args['goalIndex'] is int) {
        final gIdx = args['goalIndex'] as int;
        if (gIdx >= 0 && gIdx < _goals.length) {
          _selectedGoalIdx = gIdx;
        }
      }
    }

    _amountCtrl.text = _goals[_selectedGoalIdx]['suggestedAmount'] as String;
    _selectedDurationIdx = _goals[_selectedGoalIdx]['suggestedDurationIdx'] as int;
    _loadMySips();
  }

    void _handleRzpSuccess(PaymentSuccessResponse response) async {
    if (_pendingAutoPayData == null) return;
    setState(() => _isStartingSip = true);
    try {
      final selectedGoal = _goals[_selectedGoalIdx];
      final paymentId = response.paymentId ?? response.data?['razorpay_payment_id']?.toString() ?? '';
      final orderId = response.orderId ?? response.data?['razorpay_order_id']?.toString() ?? _pendingAutoPayData?['orderId']?.toString() ?? '';
      final subscriptionId = response.data?['razorpay_subscription_id']?.toString() ?? _pendingAutoPayData?['subscriptionId']?.toString() ?? '';
      final signature = response.signature ?? response.data?['razorpay_signature']?.toString() ?? '';

      final created = await _sipRepo.verifyAutoPaySip(
        razorpayPaymentId: paymentId,
        razorpaySubscriptionId: subscriptionId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
        metal: 'gold',
        frequency: _selectedFreq.toLowerCase(),
        installmentAmount: _amount,
        durationMonths: _months,
        goalCategory: selectedGoal['id'] as String,
        goalTitle: selectedGoal['title'] as String,
      );

      setState(() => _isStartingSip = false);
      _loadMySips();

      Get.snackbar(
        '🎉 Gold SIP Active!',
        'Your Gold SIP is activated and first installment is credited to your vault.',
        backgroundColor: _success,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );

      setState(() => _activeTab = 1);
      Get.to(() => SipJourneyView(sipId: created.id));
    } catch (e) {
      setState(() => _isStartingSip = false);
      Get.snackbar(
        'Verification Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: _danger,
        colorText: Colors.white,
      );
    }
  }

  void _handleRzpError(PaymentFailureResponse response) {
    setState(() => _isStartingSip = false);
    Get.snackbar(
      'AutoPay Setup Cancelled',
      response.message ?? 'Payment/e-Mandate was not completed',
      backgroundColor: _danger,
      colorText: Colors.white,
    );
  }

  void _handleRzpExternal(ExternalWalletResponse response) {}

  Future<void> _loadMySips() async {
    setState(() => _loadingMySips = true);
    try {
      final res = await _sipRepo.getMySips();
      setState(() {
        _portfolioSummary = res['portfolio'] as SipPortfolioSummary;
        final all = res['sips'] as List<SipModel>;
        _mySips = all.where((s) => s.isGold).toList();
        _loadingMySips = false;
      });
    } catch (_) {
      setState(() => _loadingMySips = false);
    }
  }

  Future<void> _handleStartSip() async {
    if (_amount < 1) {
      Get.snackbar(
        'Minimum Amount',
        'Minimum SIP installment is ₹1',
        backgroundColor: _danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final selectedGoal = _goals[_selectedGoalIdx];

    // ── Mode 1: Razorpay AutoPay (UPI / NetBanking e-Mandate) ─────────────
    if (_paymentMode == 'autopay') {
      setState(() => _isStartingSip = true);
      try {
        final data = await _sipRepo.createAutoPaySip(
          metal: 'gold',
          frequency: _selectedFreq.toLowerCase(),
          installmentAmount: _amount,
          durationMonths: _months,
          goalCategory: selectedGoal['id'] as String,
          goalTitle: selectedGoal['title'] as String,
        );

        _pendingAutoPayData = data;

        final options = <String, dynamic>{
          'key': data['keyId'] ?? '',
          'name': 'Payvika India Technology Pvt Ltd',
          'description': '${selectedGoal['title']} (₹${_amount.toStringAsFixed(0)}/$_selectedFreq)',
          'theme': {'color': '#D4A017'},
        };

        if (data['subscriptionId'] != null && (data['subscriptionId'] as String).isNotEmpty) {
          options['subscription_id'] = data['subscriptionId'];
        } else if (data['orderId'] != null && (data['orderId'] as String).isNotEmpty) {
          options['order_id'] = data['orderId'];
          options['amount'] = ((data['amount'] as num) * 100).round();
        }

        _razorpay.open(options);
      } catch (e) {
        setState(() => _isStartingSip = false);
        Get.snackbar(
          'AutoPay Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: _danger,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    // ── Mode 2: In-App Wallet Balance ─────────────────────────────────────
    final walletBal = Get.isRegistered<WalletController>()
        ? (WalletController.to.wallet.value?.availableBalance ??
              WalletController.to.wallet.value?.balance ??
              0.0)
        : 0.0;
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
      final created = await _sipRepo.createSip(
        metal: 'gold',
        frequency: _selectedFreq.toLowerCase(),
        installmentAmount: _amount,
        durationMonths: _months,
        goalCategory: selectedGoal['id'] as String,
        goalTitle: selectedGoal['title'] as String,
        paymentMethod: 'wallet',
      );

      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadWallet();
      }
      _loadMySips();

      Get.snackbar(
        'Gold SIP Started!',
        'Your first installment of ₹${_amount.toStringAsFixed(0)} is paid and gold is credited to your vault.',
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
      if (mounted) setState(() => _isStartingSip = false);
    }
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  void dispose() {
    _razorpay.clear();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: t.ink,
                          size: 18,
                        ),
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
                                'Digi Gold SIP',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '24K 99.9%',
                                  style: TextStyle(
                                    color: _gold,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Systematic Wealth Accumulation',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
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
                                  ? (dark
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF0B3D2E))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calculate_rounded,
                                    size: 15,
                                    color: _activeTab == 0
                                        ? Colors.white
                                        : t.inkMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Create SIP',
                                    style: TextStyle(
                                      color: _activeTab == 0
                                          ? Colors.white
                                          : t.inkMuted,
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
                                  ? (dark
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF0B3D2E))
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _activeTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.route_rounded,
                                    size: 15,
                                    color: _activeTab == 1
                                        ? Colors.white
                                        : t.inkMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'My SIPs & Journey',
                                    style: TextStyle(
                                      color: _activeTab == 1
                                          ? Colors.white
                                          : t.inkMuted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (_mySips.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _activeTab == 1
                                            ? Colors.white.withOpacity(0.25)
                                            : _gold.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_mySips.length}',
                                        style: TextStyle(
                                          color: _activeTab == 1
                                              ? Colors.white
                                              : _gold,
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
  // TAB 1: CREATE NEW SIP
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
                    : [const Color(0xFF0B3D2E), const Color(0xFF07241B)],
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
                        Icon(Icons.bolt_rounded, color: _gold, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'LIVE 24K GOLD RATE',
                          style: TextStyle(
                            color: _gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_buyRate.toStringAsFixed(0)} / gram',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.shield_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '100% Insured',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Goal-Based Bullion Savings Selector ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.track_changes_rounded, color: _gold, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Select Goal',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_gold.withOpacity(0.2), _gold.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _gold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getGoalIcon(_goals[_selectedGoalIdx]['id'] as String),
                        size: 12,
                        color: _gold,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          _goals[_selectedGoalIdx]['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _goals.length,
              separatorBuilder: (ctx, idx) => const SizedBox(width: 14),
              itemBuilder: (ctx, idx) {
                final g = _goals[idx];
                final isSelected = _selectedGoalIdx == idx;
                final Color gColor = g['color'] as Color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedGoalIdx = idx;
                      _amountCtrl.text = g['suggestedAmount'] as String;
                      _selectedDurationIdx = g['suggestedDurationIdx'] as int;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: 200,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isSelected
                            ? (dark
                                  ? [
                                      const Color(0xFF1B3326),
                                      const Color(0xFF0F1E16),
                                    ]
                                  : [
                                      const Color(0xFFE8F5E9),
                                      const Color(0xFFC8E6C9),
                                    ])
                            : (dark
                                  ? [
                                      const Color(0xFF131D18),
                                      const Color(0xFF0D1410),
                                    ]
                                  : [Colors.white, const Color(0xFFF8FAFC)]),
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? _gold : t.border,
                        width: isSelected ? 2.2 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _gold.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  dark ? 0.2 : 0.04,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: gColor.withOpacity(0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: gColor.withOpacity(0.3),
                                ),
                              ),
                              child: Icon(
                                g['icon'] as IconData,
                                size: 20,
                                color: gColor,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _gold,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 12,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'SELECTED',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: t.subBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  g['badge'] as String,
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${g['suggestedAmount']}/mo',
                                  style: TextStyle(
                                    color: isSelected ? _gold : t.ink,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _gold.withOpacity(0.2)
                                        : t.subBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _durations[g['suggestedDurationIdx']
                                            as int]['label']
                                        as String,
                                    style: TextStyle(
                                      color: isSelected ? _gold : t.inkMuted,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
// ── Special Soldier / Hero Benefit Banner ──
          if (_goals[_selectedGoalIdx]['id'] == 'soldier')
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.25),
                    const Color(0xFF059669).withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎖️ VEER JAWAN PRIVILEGE: 15% OFF',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Special 15% discount on coin & jewellery making charges + 0% platform management fee.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // ── Frequency Selector ────────────────────────────────────────
          Text(
            'Select SIP Frequency',
            style: TextStyle(
              color: t.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSel ? _gold : t.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? _gold : t.border),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: isSel ? Colors.black : t.ink,
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
                    Text(
                      'Installment Amount (₹)',
                      style: TextStyle(
                        color: t.inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Per $_selectedFreq',
                      style: TextStyle(
                        color: _gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Text(
                        '₹',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    filled: true,
                    fillColor: t.subBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [1.0, 100.0, 500.0, 1000.0, 2500.0].map((val) {
                    final active = _amount == val;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _amountCtrl.text = val.toInt().toString(),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? _gold.withOpacity(0.2) : t.subBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active ? _gold : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '₹${val.toInt()}',
                              style: TextStyle(
                                color: active ? _gold : t.inkMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
          Text(
            'Investment Duration',
            style: TextStyle(
              color: t.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSel ? _gold : t.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? _gold : t.border),
                    ),
                    child: Text(
                      dur['label'] as String,
                      style: TextStyle(
                        color: isSel ? Colors.black : t.ink,
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
                    Text(
                      'Projected Summary',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Est. +17.5% Growth',
                        style: TextStyle(
                          color: _success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                          Text(
                            'Est. Gold Grams',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_totalGrams.toStringAsFixed(4)}g',
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Investment',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_totalInvested.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Cycles',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_cyclesCount $_selectedFreq',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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

          const SizedBox(height: 16),

          // ── Payment & Auto-Debit Method Selector ──────────────────────
          Text(
            'Select Payment & Auto-Debit Method',
            style: TextStyle(
              color: t.ink,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          // Option 1: Razorpay AutoPay
          GestureDetector(
            onTap: () => setState(() => _paymentMode = 'autopay'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _paymentMode == 'autopay'
                    ? (dark ? const Color(0xFF1B3326) : const Color(0xFFE8F5E9))
                    : t.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _paymentMode == 'autopay' ? _gold : t.border,
                  width: _paymentMode == 'autopay' ? 2.0 : 1.0,
                ),
                boxShadow: _paymentMode == 'autopay'
                    ? [
                        BoxShadow(
                          color: _gold.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: _gold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Razorpay AutoPay (UPI / e-Mandate)',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Authorize once with UPI or NetBanking. Next installments auto-debited on schedule.',
                          style: TextStyle(color: t.inkMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _paymentMode == 'autopay'
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _paymentMode == 'autopay' ? _gold : t.inkMuted,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: In-App Wallet
          GestureDetector(
            onTap: () => setState(() => _paymentMode = 'wallet'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _paymentMode == 'wallet'
                    ? (dark ? const Color(0xFF1B3326) : const Color(0xFFE8F5E9))
                    : t.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _paymentMode == 'wallet' ? _gold : t.border,
                  width: _paymentMode == 'wallet' ? 2.0 : 1.0,
                ),
                boxShadow: _paymentMode == 'wallet'
                    ? [
                        BoxShadow(
                          color: _gold.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.blue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'In-App Wallet Balance',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Deduct each installment manually from your Payvika wallet.',
                          style: TextStyle(color: t.inkMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _paymentMode == 'wallet'
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: _paymentMode == 'wallet' ? _gold : t.inkMuted,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Start Gold SIP CTA ────────────────────────────────────────
          GestureDetector(
            onTap: _isStartingSip ? null : _handleStartSip,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isStartingSip
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isStartingSip
                                ? 'Connecting Razorpay AutoPay...'
                                : _paymentMode == 'autopay'
                                ? 'Enable AutoPay & Start Gold SIP ⚡'
                                : 'Start Gold SIP from Wallet (₹${_amount.toStringAsFixed(0)})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
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
  // TAB 2: MY ACTIVE SIPS & JOURNEY
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildMySipsTab(_T t, bool dark) {
    if (_loadingMySips) {
      return const Center(child: CircularProgressIndicator(color: _gold));
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
                  color: _gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: _gold,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Gold SIPs',
                style: TextStyle(
                  color: t.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start your first Gold SIP to accumulate pure 24K bullion grams systematically with market growth.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.inkMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => setState(() => _activeTab = 0),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Start New Gold SIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          // ── Portfolio Summary Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF0F291E), const Color(0xFF071B13)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _gold.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total SIP Portfolio Valuation',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_portfolioSummary.totalCurrentValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accumulated Gold',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${_portfolioSummary.totalGramsGold.toStringAsFixed(4)}g',
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Invested',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '₹${_portfolioSummary.totalInvested.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Plans',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${_portfolioSummary.activeSipsCount}',
                            style: const TextStyle(
                              color: _success,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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

          const SizedBox(height: 16),
          Text(
            'Your Active SIP Plans',
            style: TextStyle(
              color: t.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          // ── SIP Cards List ──
          ..._mySips.map((sip) => _buildSipCard(sip, t, dark)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSipCard(SipModel sip, _T t, bool dark) {
    final goalIcon = _getGoalIcon(sip.goalCategory);
    final goalName = sip.goalTitle.isNotEmpty
        ? sip.goalTitle
        : 'Gold Savings Goal';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Goal Banner Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dark
                      ? [const Color(0xFF1E3A2B), const Color(0xFF13231B)]
                      : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                ),
                border: Border(
                  bottom: BorderSide(color: _gold.withOpacity(0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(goalIcon, color: _gold, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        goalName,
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: sip.isActive
                          ? _success.withOpacity(0.18)
                          : const Color(0xFF64748B).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sip.status.toUpperCase(),
                      style: TextStyle(
                        color: sip.isActive
                            ? _success
                            : const Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Card Main Content ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Installment',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${sip.installmentAmount.toStringAsFixed(0)} / ${sip.frequency}',
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Accumulated Gold',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sip.totalGrams.toStringAsFixed(4)}g',
                            style: const TextStyle(
                              color: _gold,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Valuation & Next Due Row ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: t.subBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Valuation',
                              style: TextStyle(color: t.inkMuted, fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${sip.currentValuation.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Next Due Date',
                              style: TextStyle(color: t.inkMuted, fontSize: 10),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmtDate(sip.nextDueDate),
                              style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Progress Bar ──
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: sip.totalCycles > 0
                          ? (sip.cyclesCompleted / sip.totalCycles).clamp(
                              0.0,
                              1.0,
                            )
                          : 0.0,
                      backgroundColor: t.subBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${sip.cyclesCompleted} of ${sip.totalCycles} cycles completed',
                        style: TextStyle(color: t.inkMuted, fontSize: 11),
                      ),
                      Text(
                        '${sip.progressPct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Action Button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFF0B3D2E),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        await Get.to(() => SipJourneyView(sipId: sip.id));
                        _loadMySips();
                      },
                      icon: const Icon(
                        Icons.route_rounded,
                        size: 16,
                        color: _gold,
                      ),
                      label: const Text(
                        'Track Goal Milestone Journey',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
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

IconData _getGoalIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'baby':
      return Icons.child_care_rounded;
    case 'travel':
      return Icons.flight_takeoff_rounded;
    case 'wedding':
      return Icons.diamond_outlined;
    case 'festival':
      return Icons.celebration_rounded;
    case 'home':
      return Icons.cottage_rounded;
    case 'education':
      return Icons.school_rounded;
    case 'wealth':
    default:
      return Icons.account_balance_rounded;
  }
}
