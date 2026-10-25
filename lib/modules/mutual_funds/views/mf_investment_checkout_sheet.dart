import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_ucc_onboarding_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfInvestmentCheckoutSheet extends StatefulWidget {
  final MfSchemeModel scheme;
  final bool initialIsSip;

  const MfInvestmentCheckoutSheet({
    Key? key,
    required this.scheme,
    this.initialIsSip = true,
  }) : super(key: key);

  static Future<void> show(BuildContext context, MfSchemeModel scheme, {bool isSip = true}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MfInvestmentCheckoutSheet(scheme: scheme, initialIsSip: isSip),
    );
  }

  @override
  State<MfInvestmentCheckoutSheet> createState() => _MfInvestmentCheckoutSheetState();
}

class _MfInvestmentCheckoutSheetState extends State<MfInvestmentCheckoutSheet> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  late bool _isSip;
  late final TextEditingController _amountController;

  int _selectedDay = 10; // Default 10th of every month
  bool _stepUp = false;
  final double _stepUpAmount = 500;
  final String _paymentMode = 'NSE_GATEWAY';

  final List<int> _allowedDates = const [1, 5, 10, 15, 20, 25];

  @override
  void initState() {
    super.initState();
    _isSip = widget.initialIsSip;
    final defaultAmount = _isSip ? widget.scheme.minSipAmount : widget.scheme.minPurchaseAmount;
    _amountController = TextEditingController(
      text: defaultAmount != null ? defaultAmount.toInt().toString() : (_isSip ? '100' : '500'),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _getDaySuffix(int day) {
    if (day == 1) return 'st';
    if (day == 2) return 'nd';
    if (day == 3) return 'rd';
    return 'th';
  }

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFF131722);
    const cardBg = Color(0xFF0F141E);
    const border = Color(0xFF222938);
    const textPrimary = Colors.white;
    const textSecondary = Color(0xFF94A3B8);
    const mintTeal = Color(0xFF00D09C);

    final double minAmount = _isSip
        ? (widget.scheme.minSipAmount ?? 100)
        : (widget.scheme.minPurchaseAmount ?? 500);

    return Container(
      padding: EdgeInsets.only(
        top: 14,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: border, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag Handle ──
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

            // ── Scheme Header Row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AmcBrandLogo(
                  amcName: widget.scheme.amcName,
                  schemeName: widget.scheme.schemeName,
                  size: 42,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scheme.schemeName,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: mintTeal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: mintTeal.withOpacity(0.3)),
                            ),
                            child: Text(
                              widget.scheme.category.toUpperCase(),
                              style: const TextStyle(
                                color: mintTeal,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (widget.scheme.nav != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'NAV: ₹${widget.scheme.nav!.toStringAsFixed(2)}',
                              style: const TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E2538),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // ── Type Switcher (Monthly SIP vs One-Time) ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSip = true;
                          _amountController.text = widget.scheme.minSipAmount != null
                              ? widget.scheme.minSipAmount!.toInt().toString()
                              : '100';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSip ? mintTeal : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Monthly SIP',
                          style: TextStyle(
                            color: _isSip ? const Color(0xFF0F141E) : Colors.white70,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSip = false;
                          _amountController.text = widget.scheme.minPurchaseAmount != null
                              ? widget.scheme.minPurchaseAmount!.toInt().toString()
                              : '500';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isSip ? mintTeal : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'One-Time (Lumpsum)',
                          style: TextStyle(
                            color: !_isSip ? const Color(0xFF0F141E) : Colors.white70,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Amount Input Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Investment Amount',
                  style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Min: ₹${minAmount.toInt()}',
                  style: const TextStyle(color: mintTeal, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Row(
                children: [
                  const Text(
                    '₹ ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.black38),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                  if (_amountController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.black45, size: 18),
                      onPressed: () {
                        _amountController.clear();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Quick Increment Chips ──
            Row(
              children: [500, 1000, 2500, 5000].map((amt) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () {
                        final curr = double.tryParse(_amountController.text) ?? 0;
                        _amountController.text = (curr + amt).toInt().toString();
                        setState(() {});
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2538),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF2A364F)),
                        ),
                        child: Center(
                          child: Text(
                            '+₹$amt',
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── SIP Specific Options ──
            if (_isSip) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monthly Debit Date',
                    style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '$_selectedDay${_getDaySuffix(_selectedDay)} of every month',
                    style: const TextStyle(color: mintTeal, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: _allowedDates.map((day) {
                  final isSel = _selectedDay == day;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: InkWell(
                        onTap: () => setState(() => _selectedDay = day),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? mintTeal : const Color(0xFF1E2538),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel ? mintTeal : const Color(0xFF26324D),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$day${_getDaySuffix(day)}',
                              style: TextStyle(
                                color: isSel ? const Color(0xFF0F141E) : textPrimary,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Step-up option
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Annual Step-up SIP (Optional)',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Increase SIP by ₹500 every year to beat inflation',
                            style: TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _stepUp,
                      activeColor: mintTeal,
                      onChanged: (val) => setState(() => _stepUp = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Payment Mode (Strictly Official NSE Gateway) ──
            const Text(
              'Payment Method',
              style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mintTeal.withOpacity(0.35), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: mintTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance_rounded, color: mintTeal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Official NSE Gateway',
                              style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                              ),
                              child: const Text(
                                'NSE MFSS',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Direct payment via UPI (GPay/PhonePe), NetBanking & NEFT',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: mintTeal, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── UCC Check & CTA Button ──
            Obx(() {
              if (!controller.hasUcc.value) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF291E0A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'One-time NSE investor activation required before purchasing mutual funds.',
                              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const MfUccOnboardingView()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintTeal,
                          foregroundColor: const Color(0xFF0F141E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Complete 1-Minute NSE Setup',
                          style: TextStyle(color: Color(0xFF0F141E), fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final bank = controller.rxBankDetails.value;
              final bool isBankVerified = controller.isBankVerified;
              final String bankStatus = (bank?['status']?.toString() ?? (isBankVerified ? 'VERIFIED' : 'PENDING')).toUpperCase();
              final String bankName = bank?['bankName']?.toString() ?? controller.userUcc.value?.bankName ?? 'Linked Bank';
              final String accNo = bank?['accountNumber']?.toString() ?? controller.userUcc.value?.accountNo ?? '';
              final String maskedAcc = bank?['maskedAccountNumber']?.toString() ??
                  (accNo.length > 4 ? '•••• ${accNo.substring(accNo.length - 4)}' : accNo);

              if (!isBankVerified) {
                final isFailed = bankStatus == 'FAILED';
                final statusColor = isFailed ? const Color(0xFFEF4444) : const Color(0xFFF59E0B);
                final statusBg = isFailed ? const Color(0xFF2D1515) : const Color(0xFF291E0A);

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isFailed ? Icons.error_outline_rounded : Icons.pending_actions_rounded,
                            color: statusColor,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFailed ? 'Bank Verification Failed' : 'Bank Account Verification Required',
                                  style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFailed
                                      ? 'Penny Drop verification failed for your bank account. Please verify bank details to proceed with investment.'
                                      : 'SEBI and NSE regulations require an authorized Penny Drop verified bank account before placing mutual fund orders.',
                                  style: TextStyle(color: isFailed ? const Color(0xFFFCA5A5) : const Color(0xFFFDE68A), fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const MfUccOnboardingView()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintTeal,
                          foregroundColor: const Color(0xFF0F141E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          isFailed ? 'Retry Bank Verification' : 'Verify Bank Account (₹1 Penny Drop)',
                          style: const TextStyle(color: Color(0xFF0F141E), fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  // ── Mapped Verified Bank Card ──
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mintTeal.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: mintTeal.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_rounded, color: mintTeal, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$bankName $maskedAcc',
                                style: const TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Mapped to NSE MFSS Orders & Mandate',
                                style: TextStyle(color: textSecondary, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: mintTeal.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: mintTeal.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, color: mintTeal, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(color: mintTeal, fontSize: 10.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: mintTeal.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mintTeal.withOpacity(0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, color: mintTeal, size: 17),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'NSE MFSS Exchange Verified • Direct AMC Routing via Member 1031616',
                            style: TextStyle(color: mintTeal, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isSubmittingOrder.value
                          ? null
                          : () async {
                              if (!controller.isBankVerified) {
                                Get.snackbar(
                                  'Bank Verification Required',
                                  'Please verify your bank account before completing this investment.',
                                  backgroundColor: Colors.amber.shade900,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                Get.to(() => const MfUccOnboardingView());
                                return;
                              }

                              final amount = double.tryParse(_amountController.text) ?? 0;
                              if (amount <= 0) {
                                Get.snackbar('Invalid Amount', 'Enter valid investment amount', backgroundColor: Colors.red, colorText: Colors.white);
                                return;
                              }

                              if (_isSip) {
                                final now = DateTime.now();
                                final startDate = DateTime(now.year, now.month, _selectedDay);
                                final success = await controller.registerSipOrder(
                                  schemeCode: widget.scheme.schemeCode,
                                  schemeName: widget.scheme.schemeName,
                                  installmentAmount: amount,
                                  frequency: 'MONTHLY',
                                  startDate: startDate.isAfter(now) ? startDate : DateTime(now.year, now.month + 1, _selectedDay),
                                  stepUpRequired: _stepUp,
                                  stepUpAmount: _stepUp ? _stepUpAmount : 0,
                                  paymentMode: _paymentMode,
                                );
                                if (success) Get.back();
                              } else {
                                final success = await controller.createPurchaseOrder(
                                  schemeCode: widget.scheme.schemeCode,
                                  schemeName: widget.scheme.schemeName,
                                  orderAmount: amount,
                                  paymentMode: _paymentMode,
                                );
                                if (success) Get.back();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintTeal,
                        foregroundColor: const Color(0xFF0F141E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: controller.isSubmittingOrder.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0F141E)),
                            )
                          : Text(
                              _isSip ? 'Start Monthly SIP of ₹${_amountController.text}' : 'Invest ₹${_amountController.text} Now',
                              style: const TextStyle(color: Color(0xFF0F141E), fontSize: 15.5, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
