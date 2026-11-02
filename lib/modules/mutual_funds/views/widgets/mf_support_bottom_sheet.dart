import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/mutual_funds_controller.dart';
import 'mf_groww_widgets.dart';

class MfSupportBottomSheet extends StatefulWidget {
  final String? initialCategory;

  const MfSupportBottomSheet({super.key, this.initialCategory});

  static void show(BuildContext context, {String? initialCategory}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MfSupportBottomSheet(initialCategory: initialCategory),
    );
  }

  @override
  State<MfSupportBottomSheet> createState() => _MfSupportBottomSheetState();
}

class _MfSupportBottomSheetState extends State<MfSupportBottomSheet> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  late String _selectedCategory;
  late TextEditingController _subjectController;
  late TextEditingController _messageController;
  bool _isSubmitting = false;

  final Map<String, String> _categories = {
    'FIRST_SIP_NOT_CUT': 'First SIP Amount Not Deducted Today',
    'UCC_NOT_DONE': 'UCC Registration / Activation Pending',
    'MANDATE_NOT_ACCEPTED': 'Bank AutoPay Mandate Not Accepted',
    'PAYMENT_ISSUE': 'Payment Deducted but Units Pending',
    'OTHER': 'Other Mutual Fund Query',
  };

  final Map<String, String> _defaultSubjects = {
    'FIRST_SIP_NOT_CUT': 'Query regarding first SIP deduction date',
    'UCC_NOT_DONE': 'Assistance required for NSE UCC activation',
    'MANDATE_NOT_ACCEPTED': 'Bank mandate setup rejected or pending',
    'PAYMENT_ISSUE': 'Payment completed on NSE gateway but order pending',
    'OTHER': '',
  };

  final Map<String, String> _instantTips = {
    'FIRST_SIP_NOT_CUT':
        'Mandate debits require a 7-day bank setup clearance per exchange rules. No money is cut on Day 1; your first debit starts on the scheduled date.',
    'UCC_NOT_DONE':
        'NSE dispatches an official OTP link via SMS & Email. Check your mobile messages and spam inbox for the one-time authentication link.',
    'MANDATE_NOT_ACCEPTED':
        'Ensure your bank account has netbanking or debit card enabled. Some cooperative banks do not support e-NACH AutoPay.',
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'FIRST_SIP_NOT_CUT';
    _subjectController = TextEditingController(text: _defaultSubjects[_selectedCategory] ?? '');
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? newCat) {
    if (newCat == null) return;
    setState(() {
      _selectedCategory = newCat;
      if (newCat != 'OTHER') {
        _subjectController.text = _defaultSubjects[newCat] ?? '';
      } else {
        _subjectController.clear();
      }
    });
  }

  Future<void> _submit() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) {
      Get.snackbar(
        'Details Required',
        'Please write a few words describing your issue.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await controller.submitMfSupport(
      category: _selectedCategory,
      subject: _subjectController.text.trim(),
      message: msg,
    );
    setState(() => _isSubmitting = false);

    if (success) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uccCode = controller.userUcc.value?.clientCode ?? '';
    final hasUcc = uccCode.isNotEmpty && uccCode != 'NOT_REGISTERED';
    final tip = _instantTips[_selectedCategory];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: GrowwColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF00D09C), width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GrowwColors.mintTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.headset_mic_rounded, color: GrowwColors.mintTeal, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mutual Fund Help & Support',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasUcc ? 'UCC: $uccCode • Direct NSE Operations' : 'Direct Assistance for MF & NSE Orders',
                            style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Select Issue Category',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: GrowwColors.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GrowwColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      dropdownColor: GrowwColors.cardElevated,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: GrowwColors.mintTeal),
                      items: _categories.entries.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(
                            e.value,
                            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: _onCategoryChanged,
                    ),
                  ),
                ),
                if (tip != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF38BDF8), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Subject',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _subjectController,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Brief summary of issue...',
                    hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
                    filled: true,
                    fillColor: GrowwColors.cardElevated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Describe Your Issue',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Please provide details like fund name, amount, or error message...',
                    hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
                    filled: true,
                    fillColor: GrowwColors.cardElevated,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GrowwColors.mintTeal,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text(
                            'Submit Support Request',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
