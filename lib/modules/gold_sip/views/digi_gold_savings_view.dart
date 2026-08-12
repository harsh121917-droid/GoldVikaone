import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';

// ─── Design Tokens (Gold Theme identity) ───────────────────────────────────
const _gold = Color(0xFFD4A017);
const _danger = Color(0xFFE53E3E);

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
          bg: Color(0xFF050B07),
          card: Color(0xFF0C1710),
          primary: Color(0xFF1FAE7A),
          ink: Color(0xFFEDF3EF),
          inkMuted: Color(0xFF7C9689),
          border: Color(0x2A1FAE7A),
          subBg: Color(0xFF0A140D),
        )
      : const _T(
          bg: Color(0xFFF9F9FB),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          border: Color(0xFFE8EBF2),
          subBg: Color(0xFFF3F1EA),
        );
}

class DigiGoldSavingsView extends StatefulWidget {
  const DigiGoldSavingsView({super.key});
  @override
  State<DigiGoldSavingsView> createState() => _DigiGoldSavingsViewState();
}

class _DigiGoldSavingsViewState extends State<DigiGoldSavingsView> {
  String _paymentMethod = 'wallet';
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
      GoldController.to.buyRate > 0 ? GoldController.to.buyRate : 7309.0;

  int get _months => _durations[_selectedDurationIdx]['months'] as int;

  // Compute number of installment cycles based on duration and frequency
  int get _cyclesCount {
    final m = _months;
    if (_selectedFreq == 'Daily') return m * 30;
    if (_selectedFreq == 'Weekly') return m * 4;
    if (_selectedFreq == 'Monthly') return m;
    if (_selectedFreq == 'Quarterly') return (m / 3).ceil();
    return (m / 12).ceil();
  }

  double get _totalInvested => _amount * _cyclesCount;
  double get _gramsPerCycle => _amount / _buyRate;
  double get _totalGrams => _gramsPerCycle * _cyclesCount;
  double get _expectedReturns =>
      _totalInvested * 0.175; // 17.5% expected growth simulation

  DateTime get _startDate => DateTime.now();
  DateTime get _endDate => DateTime.now().add(Duration(days: _months * 30));

  String _fmtDate(DateTime dt) {
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
              // ── Premium Custom App Bar ───────────────────────────────────
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
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: t.ink,
                          size: 24,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Gold SIP',
                            style: TextStyle(
                              color: Color(0xFF0B3D2E),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Save regularly, shine in future ✨',
                            style: TextStyle(color: t.inkMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.transactions),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: t.inkMuted.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.history_rounded,
                              color: Color(0xFF0B3D2E),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'SIP History',
                              style: TextStyle(
                                color: Color(0xFF0B3D2E),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero Banner Card ───────────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: 160,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/gold banner.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.black.withOpacity(0.25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _gold.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _gold.withOpacity(0.5),
                                  ),
                                ),
                                child: const Text(
                                  'Build Wealth with SIP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Small Savings Today,',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Text(
                                'Big Security Tomorrow',
                                style: TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _bannerLabel(
                                    Icons.savings_outlined,
                                    'Start with just ₹100',
                                  ),
                                  _bannerLabel(
                                    Icons.verified_outlined,
                                    '24K 99.99% Pure',
                                  ),
                                  _bannerLabel(
                                    Icons.lock_outline_rounded,
                                    'Secure & Insured',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Choose SIP Plan ────────────────────────────────────────
                      Text(
                        'Choose SIP Plan',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _frequencies.map((freq) {
                          final active = _selectedFreq == freq;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedFreq = freq),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? const Color(0xFF0B3D2E)
                                        : t.card,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: active
                                          ? Colors.transparent
                                          : t.inkMuted.withOpacity(0.15),
                                    ),
                                  ),
                                  child: Text(
                                    freq,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: active ? Colors.white : t.inkMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // ── Choose Investment Dropdown + Quick Add Chips ───────────
                      Text(
                        '$_selectedFreq Investment',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '₹',
                                  style: TextStyle(
                                    color: Color(0xFF0B3D2E),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _amountCtrl,
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                DropdownButton<double>(
                                  underline: const SizedBox.shrink(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: t.inkMuted,
                                  ),
                                  items: [100.0, 500.0, 1000.0, 2000.0, 5000.0]
                                      .map((val) {
                                        return DropdownMenuItem<double>(
                                          value: val,
                                          child: Text(
                                            '₹ ${val.toInt()}',
                                            style: TextStyle(
                                              color: t.ink,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _amountCtrl.text = val.toStringAsFixed(
                                          0,
                                        );
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _quickAddChip(100),
                                _quickAddChip(500),
                                _quickAddChip(1000),
                                _quickAddChip(2000),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'You will get ~ ${_gramsPerCycle.toStringAsFixed(4)} g of gold every ${_selectedFreq.toLowerCase() == 'daily'
                                  ? 'day'
                                  : _selectedFreq.toLowerCase() == 'weekly'
                                  ? 'week'
                                  : _selectedFreq.toLowerCase() == 'yearly'
                                  ? 'year'
                                  : 'month'}',
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── SIP Duration Selector ──────────────────────────────────
                      Text(
                        'SIP Duration',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Choose how long you want to continue',
                        style: TextStyle(color: t.inkMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _durations.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final dur = entry.value;
                          final active = _selectedDurationIdx == idx;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDurationIdx = idx),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.card,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: active
                                              ? const Color(0xFF0B3D2E)
                                              : t.inkMuted.withOpacity(0.15),
                                          width: active ? 2 : 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              dur['label'].split(' ')[0],
                                              style: TextStyle(
                                                color: t.ink,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            Text(
                                              dur['label'].split(' ')[1],
                                              style: TextStyle(
                                                color: t.inkMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (active)
                                      Positioned(
                                        top: -6,
                                        right: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF0B3D2E),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // ── Start / End Dates Bar ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: t.subBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: t.inkMuted.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Color(0xFF0B3D2E),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SIP Start Date',
                                        style: TextStyle(
                                          color: t.inkMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        _fmtDate(_startDate),
                                        style: TextStyle(
                                          color: t.ink,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 26,
                              color: t.inkMuted.withOpacity(0.2),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date',
                                      style: TextStyle(
                                        color: t.inkMuted,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      _fmtDate(_endDate),
                                      style: TextStyle(
                                        color: t.ink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── SIP Summary Card ───────────────────────────────────────
                      Text(
                        'SIP Summary',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: t.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  _summaryRow(
                                    'Monthly Investment',
                                    '₹${_amount.toStringAsFixed(0)}',
                                    t,
                                  ),
                                  const SizedBox(height: 8),
                                  _summaryRow(
                                    'Total Investment (Est.)',
                                    '₹${_totalInvested.toStringAsFixed(0)}',
                                    t,
                                  ),
                                  const SizedBox(height: 8),
                                  _summaryRow(
                                    'Wealth in Gold (Est.)',
                                    '~ ${_totalGrams.toStringAsFixed(4)} g',
                                    t,
                                    highlightColor: _gold,
                                  ),
                                  const SizedBox(height: 8),
                                  _summaryRow(
                                    'Expected Profit',
                                    '₹${_expectedReturns.toStringAsFixed(0)} (17.5%)',
                                    t,
                                    highlightColor: const Color(0xFF2ecc71),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: Container(
                                height: 110,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: t.bg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Wealth grows\nwith time',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      height: 60,
                                      child: CustomPaint(
                                        size: Size.infinite,
                                        painter: _ChartPainter(dark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Select Payment Method ──────────────────────────────────
                      Text(
                        'Select Payment Method',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _paymentMethod = 'wallet'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _paymentMethod == 'wallet'
                                      ? const Color(
                                          0xFF0B3D2E,
                                        ).withOpacity(0.08)
                                      : t.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _paymentMethod == 'wallet'
                                        ? const Color(0xFF0B3D2E)
                                        : t.inkMuted.withOpacity(0.15),
                                    width: _paymentMethod == 'wallet' ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: _paymentMethod == 'wallet'
                                          ? const Color(0xFF0B3D2E)
                                          : t.inkMuted,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Wallet',
                                            style: TextStyle(
                                              color: t.ink,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Obx(() {
                                            final bal =
                                                WalletController
                                                    .to
                                                    .wallet
                                                    .value
                                                    ?.balance ??
                                                0.0;
                                            return Text(
                                              'Bal: ₹${bal.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                color: t.inkMuted,
                                                fontSize: 10,
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _paymentMethod = 'razorpay'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _paymentMethod == 'razorpay'
                                      ? const Color(
                                          0xFF0B3D2E,
                                        ).withOpacity(0.08)
                                      : t.card,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _paymentMethod == 'razorpay'
                                        ? const Color(0xFF0B3D2E)
                                        : t.inkMuted.withOpacity(0.15),
                                    width: _paymentMethod == 'razorpay'
                                        ? 1.5
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.payment_rounded,
                                      color: _paymentMethod == 'razorpay'
                                          ? const Color(0xFF0B3D2E)
                                          : t.inkMuted,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Direct Pay',
                                            style: TextStyle(
                                              color: t.ink,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'UPI / Cards',
                                            style: TextStyle(
                                              color: t.inkMuted,
                                              fontSize: 10,
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Why Choose Gold SIP ────────────────────────────────────
                      Text(
                        'Why Choose Gold SIP?',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _trustFeature(
                            Icons.trending_up_rounded,
                            'Hedge Against\nInflation',
                            'Protects wealth',
                            t,
                          ),
                          _trustFeature(
                            Icons.track_changes_rounded,
                            'Disciplined\nSaving',
                            'Small steps',
                            t,
                          ),
                          _trustFeature(
                            Icons.verified_user_outlined,
                            '24K Pure\nGold',
                            '99.99% purity',
                            t,
                          ),
                          _trustFeature(
                            Icons.shield_outlined,
                            'Secure &\nTrusted',
                            'Insured & safe',
                            t,
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ── Fixed Bottom Start Bar ────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  color: t.card,
                  border: Border(
                    top: BorderSide(color: t.inkMuted.withOpacity(0.15)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B3D2E).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF0B3D2E),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You will invest ₹${_amount.toStringAsFixed(0)} / Month',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  text: 'Starting from ',
                                  style: TextStyle(
                                    color: t.inkMuted,
                                    fontSize: 10,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _fmtDate(_startDate),
                                      style: const TextStyle(
                                        color: Color(0xFF2ecc71),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: (_amount >= 100 && !_isStartingSip)
                              ? () async {
                                  HapticFeedback.mediumImpact();
                                  setState(() {
                                    _isStartingSip = true;
                                  });
                                  try {
                                    if (_paymentMethod == 'wallet') {
                                      final bal =
                                          WalletController
                                              .to
                                              .wallet
                                              .value
                                              ?.balance ??
                                          0.0;
                                      if (bal < _amount) {
                                        Get.snackbar(
                                          'Insufficient Balance',
                                          'Please use Direct Pay or load money to your wallet.',
                                          backgroundColor: _danger,
                                          colorText: Colors.white,
                                          snackPosition: SnackPosition.BOTTOM,
                                        );
                                        return;
                                      }
                                      final ok = await WalletController.to
                                          .buyGold(amount: _amount);
                                      if (ok) {
                                        _showSuccessDialog();
                                      }
                                    } else {
                                      // Direct pay: First load the exact amount into the wallet via Razorpay
                                      final okAdd = await WalletController.to
                                          .addMoney(_amount);
                                      if (okAdd) {
                                        // Once added successfully, proceed to buy gold
                                        final okBuy = await WalletController.to
                                            .buyGold(amount: _amount);
                                        if (okBuy) {
                                          _showSuccessDialog();
                                        }
                                      }
                                    }
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error',
                                      'Failed to initiate transaction. Please try again.',
                                      backgroundColor: _danger,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } finally {
                                    setState(() {
                                      _isStartingSip = false;
                                    });
                                  }
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: _amount >= 100 && !_isStartingSip
                                  ? const Color(0xFF0B3D2E)
                                  : const Color(0xFF0B3D2E).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _isStartingSip
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Start Gold SIP',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.grey,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '100% Secure Transaction',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ─── Banner labels ─────────────────────────────────────────────────────────
  Widget _bannerLabel(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: Colors.white70, size: 12),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 9)),
    ],
  );

  // ─── Quick modifier chips ──────────────────────────────────────────────────
  Widget _quickAddChip(double val) {
    final active = _amount == val;
    return GestureDetector(
      onTap: () => setState(() {
        _amountCtrl.text = val.toStringAsFixed(0);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0B3D2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? Colors.transparent : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          '+${val.toInt()}',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── Summary dynamic row ───────────────────────────────────────────────────
  Widget _summaryRow(String l, String v, _T t, {Color? highlightColor}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: TextStyle(color: t.inkMuted, fontSize: 11)),
      Text(
        v,
        style: TextStyle(
          color: highlightColor ?? t.ink,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );

  // ─── Trust Feature Grid item ───────────────────────────────────────────────
  Widget _trustFeature(IconData icon, String label, String sub, _T t) =>
      Expanded(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0B3D2E).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0B3D2E), size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t.ink,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkMuted, fontSize: 9),
            ),
          ],
        ),
      );

  // ─── Success Dialog Modal ─────────────────────────────────────────────────
  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ecc71).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Image.asset(
                        'assets/images/gold_coin.png',
                        width: 50,
                        height: 50,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.monetization_on_rounded,
                          color: _gold,
                          size: 50,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2ecc71),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SIP Started Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0B3D2E),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your $_selectedFreq Gold SIP setup is active. Next payment will be processed automatically.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7A72),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F1EA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6B7A72).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _dialogRow('SIP Frequency', _selectedFreq, t),
                        const SizedBox(height: 8),
                        _dialogRow(
                          'Installment Amt',
                          '₹${_amount.toStringAsFixed(0)}',
                          t,
                          isHighlight: true,
                        ),
                        const SizedBox(height: 8),
                        _dialogRow(
                          'Duration',
                          _durations[_selectedDurationIdx]['label'] as String,
                          t,
                        ),
                        const SizedBox(height: 8),
                        _dialogRow('Start Date', _fmtDate(_startDate), t),
                        const SizedBox(height: 8),
                        _dialogRow('End Date', _fmtDate(_endDate), t),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Get.back();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B3D2E),
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

  Widget _dialogRow(
    String label,
    String val,
    _T t, {
    bool isHighlight = false,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: t.inkMuted, fontSize: 12)),
      Text(
        val,
        style: TextStyle(
          color: isHighlight ? const Color(0xFF0B3D2E) : t.ink,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

// ─── Custom Bezier Curve Painter for dynamic trend illustration ──────────
class _ChartPainter extends CustomPainter {
  final bool dark;
  _ChartPainter(this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = const Color(0xFF2ecc71)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintBg = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2ecc71).withOpacity(0.25),
          const Color(0xFF2ecc71).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.9)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.85,
        size.width * 0.5,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.35,
      )
      ..lineTo(size.width, size.height * 0.1);

    final bgPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(bgPath, paintBg);
    canvas.drawPath(path, paintLine);

    // Draw growth coins indicator circles at the end
    final paintCircle = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width, size.height * 0.1), 4, paintCircle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
