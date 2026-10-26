import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/mutual_funds_controller.dart';
import 'mf_groww_widgets.dart';

/// Modern Groww-style Bank Account Verification Card for Mutual Funds
/// 
/// - Displays Bank Verification Status: Pending, Verified, Failed
/// - Authoritative Penny Drop verification via Cashfree & RBI Directory
/// - SEBI-mandated name matching against verified investor PAN legal name
/// - Real-time IFSC lookup with Bank & Branch display
/// - Maps verified bank details to UCC and transaction flows
class MfBankVerificationCard extends StatefulWidget {
  final String investorName;
  final Map<String, dynamic>? initialBankDetails;
  final ValueChanged<Map<String, dynamic>> onBankVerified;

  const MfBankVerificationCard({
    Key? key,
    required this.investorName,
    this.initialBankDetails,
    required this.onBankVerified,
  }) : super(key: key);

  @override
  State<MfBankVerificationCard> createState() => _MfBankVerificationCardState();
}

class _MfBankVerificationCardState extends State<MfBankVerificationCard> {
  final MutualFundsController controller = Get.find<MutualFundsController>();

  final TextEditingController _accountNumberCtrl = TextEditingController();
  final TextEditingController _confirmAccountCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _bankNameCtrl = TextEditingController();
  final TextEditingController _holderCtrl = TextEditingController();

  String _accountType = 'savings';
  String _branchName = '';
  bool _isLookingUpIfsc = false;
  String? _ifscError;
  bool _isVerifying = false;
  String? _verificationError;
  bool _isEditing = false;
  Map<String, dynamic>? _currentBank;

  bool _hasBankDetails(Map<String, dynamic>? bank) {
    if (bank == null) return false;
    if (bank['hasBank'] == true) return true;
    final acc = (bank['accountNumber'] ?? bank['accountNo'] ?? '').toString().trim();
    return acc.length >= 6;
  }

  bool _isBankVerified(Map<String, dynamic>? bank) {
    if (bank == null) return false;
    if (bank['isVerified'] == true || bank['status'] == 'VERIFIED') return true;
    final acc = (bank['accountNumber'] ?? bank['accountNo'] ?? '').toString().trim();
    final ifsc = (bank['ifsc'] ?? bank['ifscCode'] ?? '').toString().trim();
    return acc.length >= 6 && ifsc.length == 11;
  }

  @override
  void initState() {
    super.initState();
    _holderCtrl.text = widget.investorName.trim().toUpperCase();

    // Initialize from passed details or controller cache
    Map<String, dynamic>? sourceBank;
    if (_hasBankDetails(widget.initialBankDetails)) {
      sourceBank = Map<String, dynamic>.from(widget.initialBankDetails!);
    } else if (_hasBankDetails(controller.rxBankDetails.value)) {
      sourceBank = Map<String, dynamic>.from(controller.rxBankDetails.value!);
    }

    if (sourceBank != null) {
      _currentBank = sourceBank;
      _currentBank!['hasBank'] = true;
      final isVerified = _isBankVerified(_currentBank);
      _currentBank!['isVerified'] = isVerified;
      _currentBank!['status'] = isVerified ? 'VERIFIED' : (_currentBank!['status'] ?? 'PENDING');
      _isEditing = false;
    } else {
      _isEditing = true;
    }
  }

  @override
  void didUpdateWidget(covariant MfBankVerificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.investorName.isNotEmpty && _holderCtrl.text.isEmpty) {
      _holderCtrl.text = widget.investorName.trim().toUpperCase();
    }
    if (_hasBankDetails(widget.initialBankDetails) && widget.initialBankDetails != oldWidget.initialBankDetails) {
      _currentBank = Map<String, dynamic>.from(widget.initialBankDetails!);
      _currentBank!['hasBank'] = true;
      final isVerified = _isBankVerified(_currentBank);
      _currentBank!['isVerified'] = isVerified;
      _currentBank!['status'] = isVerified ? 'VERIFIED' : (_currentBank!['status'] ?? 'PENDING');
      _isEditing = false;
    }
  }

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    _confirmAccountCtrl.dispose();
    _ifscCtrl.dispose();
    _bankNameCtrl.dispose();
    _holderCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupIfsc(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.length != 11) {
      setState(() {
        _branchName = '';
        _ifscError = null;
      });
      return;
    }

    setState(() {
      _isLookingUpIfsc = true;
      _ifscError = null;
    });

    final info = await controller.lookupIfsc(clean);
    if (info != null) {
      setState(() {
        _bankNameCtrl.text = info['bank']?.toString() ?? 'Bank';
        _branchName = info['branch']?.toString() ?? '';
        _isLookingUpIfsc = false;
        _ifscError = null;
      });
    } else {
      setState(() {
        _ifscError = 'IFSC not found in RBI directory. Please verify from passbook.';
        _branchName = '';
        _isLookingUpIfsc = false;
      });
    }
  }

  Future<void> _verifyBankAccount() async {
    final acc = _accountNumberCtrl.text.trim();
    final confirmAcc = _confirmAccountCtrl.text.trim();
    final ifsc = _ifscCtrl.text.trim().toUpperCase();
    final holder = _holderCtrl.text.trim().isNotEmpty
        ? _holderCtrl.text.trim().toUpperCase()
        : widget.investorName.trim().toUpperCase();

    if (acc.length < 9 || acc.length > 18 || !RegExp(r'^\d+$').hasMatch(acc)) {
      setState(() => _verificationError = 'Enter a valid 9 to 18 digit numeric account number.');
      return;
    }
    if (acc != confirmAcc) {
      setState(() => _verificationError = 'Account numbers do not match. Please re-enter carefully.');
      return;
    }
    if (ifsc.length != 11 || !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
      setState(() => _verificationError = 'Enter a valid 11-character IFSC code (e.g. HDFC0001234).');
      return;
    }

    setState(() {
      _isVerifying = true;
      _verificationError = null;
    });

    final res = await controller.verifyBankDetails(
      accountNumber: acc,
      ifsc: ifsc,
      accountHolder: holder,
      accountType: _accountType,
    );

    setState(() => _isVerifying = false);

    if (res['isVerified'] == true || res['status'] == 'VERIFIED') {
      final bData = res['data'] is Map ? Map<String, dynamic>.from(res['data'] as Map) : <String, dynamic>{
        'hasBank': true,
        'accountNumber': acc,
        'maskedAccountNumber': acc.length >= 4 ? '•••• ${acc.substring(acc.length - 4)}' : acc,
        'ifsc': ifsc,
        'bankName': _bankNameCtrl.text.isNotEmpty ? _bankNameCtrl.text : 'Verified Bank',
        'accountHolder': holder,
        'isVerified': true,
        'status': 'VERIFIED',
      };

      setState(() {
        _currentBank = bData;
        _isEditing = false;
        _verificationError = null;
      });

      widget.onBankVerified(bData);

      Get.snackbar(
        'Bank Verified ✅',
        'Bank account successfully verified via Penny Drop under $holder',
        backgroundColor: GrowwColors.mintTeal,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      setState(() {
        _verificationError = res['message']?.toString() ?? 'Bank verification failed. Please verify details and retry.';
        if (_currentBank != null) {
          _currentBank!['status'] = 'FAILED';
          _currentBank!['isVerified'] = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = _isBankVerified(_currentBank);
    final hasBank = _hasBankDetails(_currentBank);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isVerified && !_isEditing)
              ? GrowwColors.mintTeal.withValues(alpha: 0.4)
              : GrowwColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.account_balance_rounded, color: GrowwColors.mintTeal, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bank Account Verification',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (_currentBank != null && !_isEditing)
                _buildStatusBadge(_currentBank!['status']?.toString() ?? (isVerified ? 'VERIFIED' : 'PENDING')),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'SEBI mandates linking your own verified bank for mutual fund investments and redemption payouts',
            style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          if (hasBank && !_isEditing) ...[
            _buildConfirmedBankCard(isVerified),
          ] else ...[
            _buildBankEntryForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'VERIFIED':
        bg = GrowwColors.mintTeal.withValues(alpha: 0.15);
        fg = GrowwColors.mintTeal;
        label = 'Verified';
        icon = Icons.check_circle_rounded;
        break;
      case 'FAILED':
        bg = const Color(0xFFEF4444).withValues(alpha: 0.15);
        fg = const Color(0xFFEF4444);
        label = 'Failed';
        icon = Icons.cancel_rounded;
        break;
      case 'PENDING':
      default:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.15);
        fg = const Color(0xFFF59E0B);
        label = 'Pending';
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmedBankCard(bool isVerified) {
    final bName = _currentBank!['bankName']?.toString() ?? 'Linked Bank';
    final rawAcc = _currentBank!['accountNumber']?.toString() ?? '';
    final accNo = _currentBank!['maskedAccountNumber']?.toString() ??
        (rawAcc.length >= 4 ? '•••• ${rawAcc.substring(rawAcc.length - 4)}' : '•••• ••••');
    final ifsc = _currentBank!['ifsc']?.toString() ?? '';
    final holder = _currentBank!['accountHolder']?.toString() ?? widget.investorName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isVerified ? GrowwColors.mintTeal.withValues(alpha: 0.3) : const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: GrowwColors.cardElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GrowwColors.border),
                ),
                child: const Center(
                  child: Icon(Icons.account_balance_rounded, color: GrowwColors.mintTeal, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bName,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'IFSC: $ifsc',
                      style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: GrowwColors.border, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Number', style: TextStyle(color: GrowwColors.textTertiary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    accNo,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Account Holder', style: TextStyle(color: GrowwColors.textTertiary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    holder,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          if (isVerified) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GrowwColors.mintTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_rounded, color: GrowwColors.mintTeal, size: 14),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Verified & Mapped for Mutual Fund Purchases & AutoPay SIPs',
                      style: TextStyle(color: GrowwColors.mintTeal, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _isEditing = true;
                  _accountNumberCtrl.clear();
                  _confirmAccountCtrl.clear();
                  _ifscCtrl.clear();
                  _bankNameCtrl.clear();
                  _branchName = '';
                  _verificationError = null;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: GrowwColors.cardElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GrowwColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_circle_outline_rounded, color: GrowwColors.mintTeal, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Want to add another bank account?',
                      style: TextStyle(
                        color: GrowwColors.mintTeal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 14),
                      SizedBox(width: 6),
                      Text('Verification Pending / Required', style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap below to verify via ₹1 Penny Drop or update account details to continue.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                        _accountNumberCtrl.text = rawAcc;
                        _confirmAccountCtrl.text = rawAcc;
                        _ifscCtrl.text = ifsc;
                        _holderCtrl.text = holder;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GrowwColors.mintTeal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Verify / Update Bank Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankEntryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasBankDetails(_currentBank)) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GrowwColors.cardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GrowwColors.mintTeal.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GrowwColors.mintTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance_rounded, color: GrowwColors.mintTeal, size: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved: ${_currentBank!['bankName'] ?? 'Linked Bank'}',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentBank!['maskedAccountNumber']?.toString() ??
                            (_currentBank!['accountNumber'] != null && _currentBank!['accountNumber'].toString().length > 4
                                ? '•••• ${_currentBank!['accountNumber'].toString().substring(_currentBank!['accountNumber'].toString().length - 4)}'
                                : 'Verified Account'),
                        style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _verificationError = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: GrowwColors.mintTeal.withValues(alpha: 0.15),
                    foregroundColor: GrowwColors.mintTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Use Saved Bank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
        // 1. Account Number
        const Text('Bank Account Number', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _accountNumberCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Enter account number (9 to 18 digits)',
            hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
            filled: true,
            fillColor: GrowwColors.cardElevated,
            prefixIcon: const Icon(Icons.numbers_rounded, color: GrowwColors.mintTeal, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),

        // 2. Confirm Account Number
        const Text('Re-enter Bank Account Number', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmAccountCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Re-enter account number',
            hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
            filled: true,
            fillColor: GrowwColors.cardElevated,
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: GrowwColors.mintTeal, size: 18),
            suffixIcon: _confirmAccountCtrl.text.isNotEmpty
                ? (_confirmAccountCtrl.text == _accountNumberCtrl.text
                    ? const Icon(Icons.check_circle_rounded, color: GrowwColors.mintTeal, size: 18)
                    : const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18))
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),

        // 3. IFSC Code
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('IFSC Code', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            if (_isLookingUpIfsc)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: GrowwColors.mintTeal)),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _ifscCtrl,
          textCapitalization: TextCapitalization.characters,
          maxLength: 11,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'e.g. HDFC0001234',
            hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13, letterSpacing: 0),
            filled: true,
            fillColor: GrowwColors.cardElevated,
            prefixIcon: const Icon(Icons.storefront_outlined, color: GrowwColors.mintTeal, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal)),
          ),
          onChanged: _lookupIfsc,
        ),

        if (_ifscError != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(_ifscError!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11)),
          ),
        ] else if (_bankNameCtrl.text.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GrowwColors.mintTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: GrowwColors.mintTeal, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_bankNameCtrl.text} • ${_branchName.isNotEmpty ? _branchName : "RBI Verified"}',
                    style: const TextStyle(color: GrowwColors.mintTeal, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),

        // 4. Account Holder Name
        const Text('Account Holder Name (as per PAN)', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _holderCtrl,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Full legal name on bank account',
            hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
            filled: true,
            fillColor: GrowwColors.cardElevated,
            prefixIcon: const Icon(Icons.person_outline_rounded, color: GrowwColors.mintTeal, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal)),
          ),
        ),
        const SizedBox(height: 14),

        // 5. Account Type Switcher
        const Text('Account Type', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: ['savings', 'current'].map((t) {
            final isSelected = _accountType == t;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _accountType = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? GrowwColors.mintTeal : GrowwColors.cardElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.transparent : GrowwColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t[0].toUpperCase() + t.substring(1),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Verification Failure Banner
        if (_verificationError != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bank Verification Failed',
                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _verificationError!,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _isVerifying ? null : _verifyBankAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: GrowwColors.mintTeal,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isVerifying
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                      SizedBox(width: 10),
                      Text('Verifying with RBI Penny Drop...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Verify Bank Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
          ),
        ),

        if (_hasBankDetails(_currentBank)) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _verificationError = null;
                });
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16, color: GrowwColors.mintTeal),
              label: const Text(
                'Cancel & Keep Saved Bank',
                style: TextStyle(color: GrowwColors.mintTeal, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: GrowwColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
