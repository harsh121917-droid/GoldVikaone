import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_cart_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'widgets/mf_groww_widgets.dart';

/// Dedicated Multi-Fund Checkout Screen
/// Allows reviewing selected funds, adjusting amounts, selecting payment mode,
/// and executing simultaneous NSE orders for all selected mutual funds.
class MfCartCheckoutView extends StatefulWidget {
  final List<MfCartItem> initialSelectedItems;

  const MfCartCheckoutView({
    Key? key,
    required this.initialSelectedItems,
  }) : super(key: key);

  @override
  State<MfCartCheckoutView> createState() => _MfCartCheckoutViewState();
}

class _MfCartCheckoutViewState extends State<MfCartCheckoutView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();

  // Set of selected item IDs
  late final RxSet<String> selectedIds;
  // Map of custom amounts for each item ID
  late final RxMap<String, double> itemAmounts;

  String _paymentMode = 'NSE_PAYMENT_LINK'; // 'NSE_PAYMENT_LINK' or 'UPI'
  final TextEditingController _vpaController = TextEditingController();
  bool _isSubmitting = false;

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);

  @override
  void initState() {
    super.initState();
    selectedIds = widget.initialSelectedItems.map((e) => e.id).toSet().obs;
    itemAmounts = <String, double>{
      for (final item in widget.initialSelectedItems) item.id: item.amount,
    }.obs;

    // Prefill user UPI / Phone if available
    final userPhone = controller.userUcc.value?.accountNo ?? '';
    if (userPhone.isNotEmpty && userPhone.length == 10) {
      _vpaController.text = '$userPhone@upi';
    }
  }

  @override
  void dispose() {
    _vpaController.dispose();
    super.dispose();
  }

  String _cleanSchemeName(String name) {
    return name
        .replaceAll(RegExp(r'\s*-\s*Regular\s*Plan.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Direct\s*Plan.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Growth.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*IDCW.*$', caseSensitive: false), '')
        .trim();
  }

  double get _totalSelectedAmount {
    double total = 0.0;
    for (final item in widget.initialSelectedItems) {
      if (selectedIds.contains(item.id)) {
        total += itemAmounts[item.id] ?? item.amount;
      }
    }
    return total;
  }

  int get _selectedCount => selectedIds.length;

  void _showEditAmountDialog(MfCartItem item) {
    final currentAmount = itemAmounts[item.id] ?? item.amount;
    final textCtrl = TextEditingController(text: currentAmount.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161E2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Amount for ${_cleanSchemeName(item.schemeName)}',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter investment amount (Min ₹100):',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: mintGreen, fontSize: 18, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFF0F141E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmt = double.tryParse(textCtrl.text.trim()) ?? 0.0;
              if (newAmt < 100) {
                Get.snackbar('Invalid Amount', 'Minimum investment amount is ₹100',
                    backgroundColor: Colors.redAccent, colorText: Colors.white);
                return;
              }
              itemAmounts[item.id] = newAmt;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mintGreen,
              foregroundColor: Colors.black,
              minimumSize: const Size(80, 36),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleProceedToPayment() async {
    if (selectedIds.isEmpty) {
      Get.snackbar('No Funds Selected', 'Please select at least one fund to proceed with investment.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (_paymentMode == 'UPI') {
      final vpa = _vpaController.text.trim();
      if (!vpa.contains('@') || vpa.length < 4) {
        Get.snackbar('Invalid UPI ID', 'Please enter a valid UPI ID (e.g. mobile@okhdfcbank or yourname@paytm).',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // Build custom items array with updated amounts
      final List<Map<String, dynamic>> customItems = [];
      for (final item in widget.initialSelectedItems) {
        if (selectedIds.contains(item.id)) {
          customItems.add({
            'cartItemId': item.id,
            'schemeCode': item.schemeCode,
            'amount': itemAmounts[item.id] ?? item.amount,
            'investmentType': item.investmentType,
            'frequency': item.frequency,
            'sipDay': item.sipDay,
            'folioNo': item.folioNo,
          });
        }
      }

      final result = await controller.checkoutCart(
        selectedItemIds: selectedIds.toList(),
        customItems: customItems,
        paymentMode: _paymentMode,
        vpa: _paymentMode == 'UPI' ? _vpaController.text.trim() : null,
      );

      if (result != null && mounted) {
        // Payment gateway or UPI approval has completed
        final totalFunds = result['totalFunds'] ?? selectedIds.length;
        Navigator.pop(context, true); // Return to cart with success
        Get.snackbar(
          'Investment Initiated',
          'Orders placed for $totalFunds mutual funds with NSE MFSS.',
          backgroundColor: mintGreen,
          colorText: const Color(0xFF0F141E),
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ucc = controller.userUcc.value;
    final clientCode = ucc?.clientCode ?? 'NSE INVESTOR';
    final bankName = ucc?.bankName ?? 'Linked Bank';
    final accountNo = ucc?.accountNo ?? '';
    final maskedBank = accountNo.length > 4 ? '•••• ${accountNo.substring(accountNo.length - 4)}' : accountNo;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review & Invest',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  '$_selectedCount of ${widget.initialSelectedItems.length} funds selected',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                )),
          ],
        ),
        actions: [
          Obx(() {
            final allSelected = selectedIds.length == widget.initialSelectedItems.length;
            return TextButton(
              onPressed: () {
                if (allSelected) {
                  selectedIds.clear();
                } else {
                  selectedIds.assignAll(widget.initialSelectedItems.map((e) => e.id));
                }
              },
              child: Text(
                allSelected ? 'Deselect All' : 'Select All',
                style: const TextStyle(color: mintGreen, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // ── Section 1: Selected Funds List ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SELECTED MUTUAL FUNDS',
                      style: TextStyle(color: Colors.white54, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                    ),
                    Obx(() => Text(
                          '${selectedIds.length} funds',
                          style: const TextStyle(color: mintGreen, fontSize: 11.5, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
                const SizedBox(height: 8),

                ...widget.initialSelectedItems.map((item) {
                  return Obx(() {
                    final isChecked = selectedIds.contains(item.id);
                    final isSip = item.investmentType.toUpperCase() == 'SIP';
                    final amount = itemAmounts[item.id] ?? item.amount;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isChecked ? mintGreen.withOpacity(0.5) : borderColor,
                          width: isChecked ? 1.4 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox
                              Checkbox(
                                value: isChecked,
                                activeColor: mintGreen,
                                checkColor: Colors.black,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  if (val == true) {
                                    selectedIds.add(item.id);
                                  } else {
                                    selectedIds.remove(item.id);
                                  }
                                },
                              ),
                              const SizedBox(width: 4),
                              // Authentic AMC Logo
                              AmcBrandLogo(
                                amcName: item.amcName,
                                schemeName: item.schemeName,
                                size: 36,
                                borderRadius: 8,
                              ),
                              const SizedBox(width: 10),
                              // Scheme Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _cleanSchemeName(item.schemeName),
                                      style: TextStyle(
                                        color: isChecked ? Colors.white : Colors.white54,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSip ? mintGreen.withOpacity(0.12) : Colors.blue.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isSip ? 'SIP • Day ${item.sipDay}' : 'One-Time Lumpsum',
                                            style: TextStyle(
                                              color: isSip ? mintGreen : Colors.blueAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (item.category.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              item.category,
                                              style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(color: borderColor, height: 1),
                          const SizedBox(height: 8),

                          // Amount row with inline edit
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Amount: ₹${amount.toInt()}',
                                    style: TextStyle(
                                      color: isChecked ? Colors.white : Colors.white54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _showEditAmountDialog(item),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit_outlined, size: 12, color: mintGreen),
                                          SizedBox(width: 2),
                                          Text('Edit', style: TextStyle(color: mintGreen, fontSize: 10.5, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                isChecked ? 'Will Proceed' : 'Excluded',
                                style: TextStyle(
                                  color: isChecked ? mintGreen : Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
                }),

                const SizedBox(height: 16),

                // ── Section 2: Payment Method Selection ──
                const Text(
                  'PAYMENT METHOD',
                  style: TextStyle(color: Colors.white54, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                ),
                const SizedBox(height: 8),

                // Option 1: NSE Gateway (Recommended)
                GestureDetector(
                  onTap: () => setState(() => _paymentMode = 'NSE_PAYMENT_LINK'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _paymentMode == 'NSE_PAYMENT_LINK' ? mintGreen : borderColor,
                        width: _paymentMode == 'NSE_PAYMENT_LINK' ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _paymentMode == 'NSE_PAYMENT_LINK' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                          color: _paymentMode == 'NSE_PAYMENT_LINK' ? mintGreen : Colors.white38,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'NSE Exchange Gateway',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: mintGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'RECOMMENDED',
                                      style: TextStyle(color: mintGreen, fontSize: 9.5, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Official NSE portal with UPI (GPay/PhonePe/Paytm), NetBanking, and Debit Cards directly to NSE Clearing Ltd.',
                                style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11.5, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Option 2: UPI Direct Collect
                GestureDetector(
                  onTap: () => setState(() => _paymentMode = 'UPI'),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _paymentMode == 'UPI' ? mintGreen : borderColor,
                        width: _paymentMode == 'UPI' ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _paymentMode == 'UPI' ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: _paymentMode == 'UPI' ? mintGreen : Colors.white38,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'UPI Direct Collect Request',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'NSE will dispatch a combined UPI collect request directly to your UPI app.',
                                    style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11.5, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_paymentMode == 'UPI') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _vpaController,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Enter UPI ID (e.g. mobile@okaxis)',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                              filled: true,
                              fillColor: const Color(0xFF0F141E),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              prefixIcon: const Icon(Icons.payment_rounded, color: mintGreen, size: 18),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Section 3: Investor & Bank Account ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D2D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1E2E48)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: mintGreen.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: mintGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$bankName $maskedBank',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NSE Client: $clientCode • SEBI Verified',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified_rounded, color: mintGreen, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Sticky Pay Bar ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: cardBg,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Obx(() {
                    final total = _totalSelectedAmount;
                    final count = _selectedCount;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total ($count ${count == 1 ? "fund" : "funds"})',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${total.toInt()}',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Obx(() {
                      final hasSelection = _selectedCount > 0;
                      final total = _totalSelectedAmount;

                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (hasSelection && !_isSubmitting) ? _handleProceedToPayment : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: hasSelection ? mintGreen : Colors.white24,
                            foregroundColor: const Color(0xFF0F141E),
                            elevation: 0,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0F141E)),
                                )
                              : Text(
                                  'Proceed to Pay ₹${total.toInt()}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
