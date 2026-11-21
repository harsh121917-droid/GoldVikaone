import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
  late final TextEditingController _amountController;
  final TextEditingController _vpaController = TextEditingController();
  String _selectedPaymentMode = 'UPI'; // 'UPI' or 'NSE_GATEWAY'
  final List<String> _upiHandles = ['@okaxis', '@okhdfcbank', '@ybl', '@paytm', '@ibl'];

  @override
  void initState() {
    super.initState();
    final defaultAmount = widget.scheme.minPurchaseAmount ?? widget.scheme.minSipAmount ?? 500.0;
    _amountController = TextEditingController(
      text: defaultAmount.toInt().toString(),
    );
    try {
      final savedVpa = GetStorage().read('mf_saved_vpa')?.toString();
      if (savedVpa != null && savedVpa.isNotEmpty) {
        _vpaController.text = savedVpa;
      }
    } catch (_) {}
  }

  void _onHandleChipTap(String handle) {
    final current = _vpaController.text.trim();
    if (current.isEmpty) {
      _vpaController.text = handle;
    } else if (current.contains('@')) {
      final prefix = current.split('@')[0];
      _vpaController.text = '$prefix$handle';
    } else {
      _vpaController.text = '$current$handle';
    }
    _vpaController.selection = TextSelection.fromPosition(
      TextPosition(offset: _vpaController.text.length),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vpaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const surface = Color(0xFF131722);
    const cardBg = Color(0xFF0F141E);
    const border = Color(0xFF222938);
    const textPrimary = Colors.white;
    const textSecondary = Color(0xFF94A3B8);
    const mintTeal = Color(0xFF00D09C);

    final double minAmount = widget.scheme.minPurchaseAmount ?? widget.scheme.minSipAmount ?? 500.0;

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

            // ── One-Time Investment Banner ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF10241E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mintTeal.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: mintTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bolt_rounded, color: mintTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'One-Time (Lumpsum) Investment',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Instant UPI / NetBanking • Zero Mandate Required',
                          style: TextStyle(color: mintTeal, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
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

            // ── Payment Method (Option 1: Direct UPI Collect, Option 2: Official NSE Gateway) ──
            const Text(
              'Payment Method',
              style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            // Option 1: Direct UPI Collect (Without NSE Portal)
            InkWell(
              onTap: () => setState(() => _selectedPaymentMode = 'UPI'),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedPaymentMode == 'UPI' ? mintTeal : border,
                    width: _selectedPaymentMode == 'UPI' ? 1.6 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _selectedPaymentMode == 'UPI'
                                ? mintTeal.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: _selectedPaymentMode == 'UPI' ? mintTeal : textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'UPI (Google Pay, PhonePe, Paytm)',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: mintTeal.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'FASTEST',
                                      style: TextStyle(
                                        color: mintTeal,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Instant 1-tap payment via UPI apps (GPay, PhonePe, Paytm, QR)',
                                style: TextStyle(color: textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _selectedPaymentMode == 'UPI'
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: _selectedPaymentMode == 'UPI' ? mintTeal : textSecondary.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      ],
                    ),

                    if (_selectedPaymentMode == 'UPI') ...[
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ENTER UPI ID FOR COLLECT REQUEST',
                            style: TextStyle(color: textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          if (_vpaController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _vpaController.clear();
                                setState(() {});
                              },
                              child: const Text('Clear', style: TextStyle(color: mintTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _vpaController.text.isNotEmpty ? mintTeal.withValues(alpha: 0.5) : border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alternate_email_rounded, color: mintTeal, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _vpaController,
                                style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 9876543210@paytm or user@okaxis',
                                  hintStyle: const TextStyle(color: textSecondary, fontSize: 12),
                                  border: InputBorder.none,
                                  isDense: true,
                                  suffixIcon: _vpaController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, color: textSecondary, size: 16),
                                          onPressed: () {
                                            _vpaController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Quick handle chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _upiHandles.map((h) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () => _onHandleChipTap(h),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: border),
                                  ),
                                  child: Text(
                                    h,
                                    style: const TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.touch_app_rounded, color: mintTeal.withValues(alpha: 0.8), size: 13),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Text(
                              'NSE will send a payment notification to this UPI ID. You can approve it from any phone or device.',
                              style: TextStyle(color: textSecondary, fontSize: 10.5, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Option 2: Official NSE Gateway (As-is)
            InkWell(
              onTap: () => setState(() => _selectedPaymentMode = 'NSE_GATEWAY'),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedPaymentMode == 'NSE_GATEWAY' ? mintTeal : border,
                    width: _selectedPaymentMode == 'NSE_GATEWAY' ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedPaymentMode == 'NSE_GATEWAY'
                            ? mintTeal.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: _selectedPaymentMode == 'NSE_GATEWAY' ? mintTeal : textSecondary,
                        size: 20,
                      ),
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
                                style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
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
                            'NetBanking, NEFT, and portal payment via official NSE link',
                            style: TextStyle(color: textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _selectedPaymentMode == 'NSE_GATEWAY'
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: _selectedPaymentMode == 'NSE_GATEWAY' ? mintTeal : textSecondary.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
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

                              final isUpi = _selectedPaymentMode == 'UPI';
                              final vpa = _vpaController.text.trim();
                              if (isUpi) {
                                if (vpa.isEmpty || !vpa.contains('@') || vpa.length < 4) {
                                  Get.snackbar(
                                    'UPI ID Required',
                                    'Please enter your UPI ID (e.g. mobile@okhdfcbank or yourname@okaxis) to receive the payment collect request.',
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }
                                try {
                                  GetStorage().write('mf_saved_vpa', vpa);
                                } catch (_) {}
                              }

                              final success = await controller.createPurchaseOrder(
                                schemeCode: widget.scheme.schemeCode,
                                schemeName: widget.scheme.schemeName,
                                orderAmount: amount,
                                paymentMode: isUpi ? 'UPI' : 'NSE_GATEWAY',
                                vpa: isUpi ? vpa : null,
                              );
                              if (success) {
                                Get.back();
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
                              'Invest ₹${_amountController.text} Now',
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
