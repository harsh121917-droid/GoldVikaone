import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_ucc_onboarding_view.dart';

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
  double _stepUpAmount = 500;
  String _paymentMode = 'UPI';

  final List<int> _allowedDates = const [1, 5, 10, 15, 20, 25];

  @override
  void initState() {
    super.initState();
    _isSip = widget.initialIsSip;
    final defaultAmount = _isSip ? widget.scheme.minSipAmount : widget.scheme.minPurchaseAmount;
    _amountController = TextEditingController(text: defaultAmount.toInt().toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? DarkColors.surface : AppColors.surface;
    final textPrimary = dark ? Colors.white : AppColors.textPrimary;
    final textSecondary = dark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Scheme Title ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.scheme.category,
                    style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.scheme.schemeName,
                    style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Type Switcher (SIP vs One-Time) ──
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSip = true;
                          _amountController.text = widget.scheme.minSipAmount.toInt().toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isSip ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Monthly SIP',
                          style: TextStyle(
                            color: _isSip ? Colors.white : textSecondary,
                            fontWeight: FontWeight.bold,
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
                          _amountController.text = widget.scheme.minPurchaseAmount.toInt().toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isSip ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'One-Time (Lumpsum)',
                          style: TextStyle(
                            color: !_isSip ? Colors.white : textSecondary,
                            fontWeight: FontWeight.bold,
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

            // ── Amount Input ──
            Text('Investment Amount', style: TextStyle(color: textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),

            // ── Quick Amount Chips ──
            Wrap(
              spacing: 8,
              children: [500, 1000, 2500, 5000, 10000].map((amt) {
                return ActionChip(
                  label: Text('+₹$amt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  backgroundColor: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onPressed: () {
                    final curr = double.tryParse(_amountController.text) ?? 0;
                    _amountController.text = (curr + amt).toInt().toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── SIP Specific Options ──
            if (_isSip) ...[
              Text('Monthly Debit Date', style: TextStyle(color: textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _allowedDates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final day = _allowedDates[index];
                    final isSel = _selectedDay == day;
                    return ChoiceChip(
                      label: Text('${day}th of month'),
                      selected: isSel,
                      selectedColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (sel) {
                        if (sel) setState(() => _selectedDay = day);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Step-up option
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Annual Step-up SIP', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Increase SIP by ₹500 every year to beat inflation', style: TextStyle(color: textSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _stepUp,
                      activeColor: AppColors.accent,
                      onChanged: (val) => setState(() => _stepUp = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Payment Mode ──
            Text('Payment Method', style: TextStyle(color: textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPayModeChip('UPI', Icons.qr_code_rounded),
                const SizedBox(width: 10),
                _buildPayModeChip('NETBANKING', Icons.account_balance_rounded),
                const SizedBox(width: 10),
                _buildPayModeChip('MANDATE', Icons.autorenew_rounded),
              ],
            ),
            const SizedBox(height: 24),

            // ── UCC Check & CTA Button ──
            Obx(() {
              if (!controller.hasUcc.value) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 22),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'One-time NSE investor activation required before purchasing mutual funds.',
                              style: TextStyle(color: Color(0xFF92400E), fontSize: 12),
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
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Complete 1-Minute NSE Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.science_outlined, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sandbox Mode: Orders are immediately allotted & visible in your portfolio.',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
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
                              installmentAmount: amount,
                              frequency: 'MONTHLY',
                              startDate: startDate.isAfter(now) ? startDate : DateTime(now.year, now.month + 1, _selectedDay),
                              stepUpRequired: _stepUp,
                              stepUpAmount: _stepUp ? _stepUpAmount : 0,
                            );
                            if (success) Get.back();
                          } else {
                            final success = await controller.createPurchaseOrder(
                              schemeCode: widget.scheme.schemeCode,
                              orderAmount: amount,
                              paymentMode: _paymentMode,
                            );
                            if (success) Get.back();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  child: controller.isSubmittingOrder.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isSip ? 'Start Monthly SIP of ₹${_amountController.text}' : 'Invest ₹${_amountController.text} Now',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildPayModeChip(String mode, IconData icon) {
    final isSel = _paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: isSel ? AppColors.accent : Colors.grey.withOpacity(0.3), width: isSel ? 1.5 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSel ? AppColors.accent : Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                mode,
                style: TextStyle(
                  color: isSel ? AppColors.accent : Colors.grey,
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
