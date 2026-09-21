import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_ucc_onboarding_view.dart';

class MfSipInvestmentView extends StatefulWidget {
  final MfSchemeModel scheme;
  final bool isSip;

  const MfSipInvestmentView({
    Key? key,
    required this.scheme,
    this.isSip = true,
  }) : super(key: key);

  @override
  State<MfSipInvestmentView> createState() => _MfSipInvestmentViewState();
}

class _MfSipInvestmentViewState extends State<MfSipInvestmentView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();

  String _amountStr = '1000';
  int _selectedDay = 25; // Default 25th of every month as shown in screenshot
  String _paymentMethod = 'RAZORPAY';

  final List<int> _allowedDates = const [1, 5, 10, 15, 20, 25, 28];

  @override
  void initState() {
    super.initState();
    final minAmount = widget.isSip ? widget.scheme.minSipAmount : widget.scheme.minPurchaseAmount;
    _amountStr = minAmount.toInt().toString();
  }

  double get _amount => double.tryParse(_amountStr) ?? 0.0;

  String _formatCurrency(String s) {
    if (s.isEmpty) return '0';
    int? n = int.tryParse(s.replaceAll(',', ''));
    if (n == null) return s;
    if (n < 1000) return n.toString();
    String str = n.toString();
    String lastThree = str.substring(str.length - 3);
    String otherNumbers = str.substring(0, str.length - 3);
    if (otherNumbers.isNotEmpty) {
      otherNumbers = otherNumbers.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$otherNumbers,$lastThree';
    }
    return lastThree;
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == '⌫') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      } else if (value == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr = _amountStr.isEmpty ? '0.' : '$_amountStr.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = value;
        } else if (_amountStr.length < 9) {
          _amountStr = '$_amountStr$value';
        }
      }
    });
  }

  void _addIncrement(int inc) {
    setState(() {
      int curr = int.tryParse(_amountStr.replaceAll(',', '')) ?? 0;
      curr += inc;
      _amountStr = curr.toString();
    });
  }

  void _clearAmount() {
    setState(() {
      _amountStr = '';
    });
  }

  void _openDatePickerSheet(Color bg, Color surface, Color textPrimary, Color mintGreen) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Monthly SIP Debit Date',
              style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your investment will be deducted automatically on this date every month.',
              style: TextStyle(color: Color(0xFF8B949E), fontSize: 12),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _allowedDates.map((d) {
                final isSel = _selectedDay == d;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = d);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? mintGreen : const Color(0xFF1E2533),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${d}th of month',
                      style: TextStyle(
                        color: isSel ? Colors.black : Colors.white,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openBankSelector(Color surface, Color textPrimary, Color mintGreen) {
    final ucc = controller.userUcc.value;
    final bName = (ucc != null && ucc.bankName.isNotEmpty) ? ucc.bankName : 'Verified Bank';
    final accNo = (ucc != null && ucc.accountNo.isNotEmpty)
        ? (ucc.accountNo.length > 4 ? ucc.accountNo.substring(ucc.accountNo.length - 4) : ucc.accountNo)
        : '••••';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Method', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mintGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.bolt_rounded, color: mintGreen, size: 22),
              ),
              title: const Text('Razorpay MF Gateway (Instant UPI / NetBanking / Cards)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text('Fast & 100% Secure via Razorpay Mutual Funds', style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.w500)),
              trailing: _paymentMethod == 'RAZORPAY' ? Icon(Icons.check_circle_rounded, color: mintGreen) : null,
              onTap: () {
                setState(() => _paymentMethod = 'RAZORPAY');
                Navigator.pop(context);
              },
            ),
            const Divider(color: Color(0xFF1E2638)),
            ListTile(
              leading: const Icon(Icons.account_balance_rounded, color: Color(0xFF94A3B8)),
              title: Text('$bName (Auto-Debit)', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: Text('A/C ••••$accNo • e-NACH Mandate for Auto-Debit', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              trailing: _paymentMethod == 'MANDATE' ? Icon(Icons.check_circle_rounded, color: mintGreen) : null,
              onTap: () {
                setState(() => _paymentMethod = 'MANDATE');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!controller.hasUcc.value) {
      final res = await Get.to(() => const MfUccOnboardingView());
      if (res != true) return;
    }

    final double minAmount = widget.isSip ? widget.scheme.minSipAmount : widget.scheme.minPurchaseAmount;
    if (_amount < minAmount) {
      Get.snackbar(
        'Minimum Amount Required',
        'Minimum ${widget.isSip ? "SIP" : "investment"} amount for this fund is ₹${minAmount.toInt()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (widget.isSip) {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, _selectedDay);
      final success = await controller.registerSipOrder(
        schemeCode: widget.scheme.schemeCode,
        schemeName: widget.scheme.schemeName,
        installmentAmount: _amount,
        frequency: 'MONTHLY',
        startDate: startDate.isAfter(now) ? startDate : DateTime(now.year, now.month + 1, _selectedDay),
      );
      if (success) {
        Navigator.pop(context);
      }
    } else {
      final success = await controller.createPurchaseOrder(
        schemeCode: widget.scheme.schemeCode,
        schemeName: widget.scheme.schemeName,
        orderAmount: _amount,
        paymentMode: _paymentMethod,
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A0D14);
    const surface = Color(0xFF121620);
    const textPrimary = Color(0xFFF1F5F9);
    const textSecondary = Color(0xFF8B949E);
    const mintGreen = Color(0xFF00D09C);

    final double minAmount = widget.isSip ? widget.scheme.minSipAmount : widget.scheme.minPurchaseAmount;
    final bool isValidAmount = _amount >= minAmount;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isSip ? 'SIP' : 'One-time Investment',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              widget.scheme.schemeName,
              style: const TextStyle(color: textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Investment amount',
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Large Amount Display with Clear (x) Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹${_formatCurrency(_amountStr)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (_amountStr.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _clearAmount,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF222838),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 18),

                // Quick Increment Chips (+ ₹1,000, + ₹2,000, + ₹5,000)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIncrementChip('+ ₹1,000', () => _addIncrement(1000)),
                    const SizedBox(width: 10),
                    _buildIncrementChip('+ ₹2,000', () => _addIncrement(2000)),
                    const SizedBox(width: 10),
                    _buildIncrementChip('+ ₹5,000', () => _addIncrement(5000)),
                  ],
                ),
                const SizedBox(height: 20),

                // Monthly on 25th Dropdown Pill
                if (widget.isSip)
                  GestureDetector(
                    onTap: () => _openDatePickerSheet(bg, surface, textPrimary, mintGreen),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131824),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF222B3D)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Monthly on ${_selectedDay}th',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Payment Method Row (Above Keypad) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF0F131D),
              border: Border(top: BorderSide(color: Color(0xFF1A2230), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2535),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            _paymentMethod == 'RAZORPAY' ? 'Razorpay MF Gateway' : 'Bank Mandate',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: mintGreen.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('FAST & SECURE', style: TextStyle(color: mintGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _paymentMethod == 'RAZORPAY' ? 'UPI, NetBanking & Cards supported' : 'Monthly Auto-Debit via e-NACH',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _openBankSelector(surface, textPrimary, mintGreen),
                  child: const Row(
                    children: [
                      Text(
                        'Select bank',
                        style: TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, color: mintGreen, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Custom In-App Numeric Keypad ──
          Container(
            color: const Color(0xFF090C12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildKeypadKey('1'),
                    _buildKeypadKey('2'),
                    _buildKeypadKey('3'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadKey('4'),
                    _buildKeypadKey('5'),
                    _buildKeypadKey('6'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadKey('7'),
                    _buildKeypadKey('8'),
                    _buildKeypadKey('9'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadKey('.'),
                    _buildKeypadKey('0'),
                    _buildKeypadKey('⌫'),
                  ],
                ),
              ],
            ),
          ),

          // ── Bottom Action Buttons (Add to cart & Start SIP) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: bg,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.snackbar('Added to Cart', '${widget.scheme.schemeName} saved to cart.', backgroundColor: const Color(0xFF1E2535), colorText: Colors.white);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF121622),
                          side: const BorderSide(color: Color(0xFF1E2638)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Add to cart', style: TextStyle(color: Color(0xFF8B949E), fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (isValidAmount && !controller.isSubmittingOrder.value) ? _submitOrder : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isValidAmount ? mintGreen : const Color(0xFF1A2A24),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: controller.isSubmittingOrder.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : Text(
                                widget.isSip ? 'Start SIP' : 'Invest Now',
                                style: TextStyle(
                                  color: isValidAmount ? Colors.black : const Color(0xFF3B564C),
                                  fontSize: 15,
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
        ],
      ),
    );
  }

  Widget _buildIncrementChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF101520),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF222B3D)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildKeypadKey(String text) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeypadTap(text),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: text == '⌫'
              ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 20)
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
