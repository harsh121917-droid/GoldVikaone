import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../core/network/api_client.dart';

class AddBankAccountView extends StatefulWidget {
  const AddBankAccountView({super.key});
  @override
  State<AddBankAccountView> createState() => _AddBankAccountViewState();
}

class _AddBankAccountViewState extends State<AddBankAccountView> {
  final _holderCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _confirmAccCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();

  String _accType = 'savings';
  String _branchName = '';
  bool _fetchingIfsc = false;
  String? _ifscError;
  bool _saving = false;

  bool get _accMatch =>
      _confirmAccCtrl.text.trim().isEmpty || _accCtrl.text.trim() == _confirmAccCtrl.text.trim();

  bool get _valid =>
      _holderCtrl.text.trim().length > 2 &&
      _accCtrl.text.trim().length >= 9 &&
      _confirmAccCtrl.text.trim() == _accCtrl.text.trim() &&
      _ifscCtrl.text.trim().length == 11 &&
      _bankCtrl.text.trim().isNotEmpty &&
      _ifscError == null;

  @override
  void dispose() {
    _holderCtrl.dispose();
    _accCtrl.dispose();
    _confirmAccCtrl.dispose();
    _ifscCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupIfsc(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length != 11) {
      setState(() {
        _branchName = '';
        _ifscError = null;
      });
      return;
    }

    setState(() {
      _fetchingIfsc = true;
      _ifscError = null;
    });

    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/bank/ifsc/$cleanCode');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>;
        setState(() {
          _bankCtrl.text = data['bank']?.toString() ?? 'Bank';
          _branchName = data['branch']?.toString() ?? '';
          _ifscError = null;
          _fetchingIfsc = false;
        });
      } else {
        setState(() {
          _ifscError = 'Invalid IFSC code. Please verify from your chequebook.';
          _branchName = '';
          _fetchingIfsc = false;
        });
      }
    } catch (_) {
      setState(() {
        _ifscError = 'IFSC not found in RBI directory. Please check details.';
        _branchName = '';
        _fetchingIfsc = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

      return Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Text(
            'Add Bank Account',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Groww Security Notice
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09C).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, color: Color(0xFF00D09C), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instant Bank Verification',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'We verify details with RBI & your bank. As per SEBI regulations, investments must originate from your own account.',
                              style: TextStyle(color: ts, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 1. IFSC Code (with Live RBI Lookup)
                _Field(
                  'IFSC Code',
                  _ifscCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'e.g. SBIN0001234',
                  suffix: _fetchingIfsc
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D09C)),
                          ),
                        )
                      : (_bankCtrl.text.isNotEmpty && _ifscError == null
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00D09C), size: 20)
                          : null),
                  onChanged: (v) {
                    final upper = v.toUpperCase();
                    if (_ifscCtrl.text != upper) {
                      _ifscCtrl.value = _ifscCtrl.value.copyWith(
                        text: upper,
                        selection: TextSelection.collapsed(offset: upper.length),
                      );
                    }
                    if (upper.length == 11) {
                      _lookupIfsc(upper);
                    } else {
                      if (_branchName.isNotEmpty || _ifscError != null) {
                        setState(() {
                          _branchName = '';
                          _ifscError = null;
                        });
                      }
                    }
                  },
                ),

                if (_ifscError != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12, left: 4),
                    child: Text(
                      _ifscError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ] else if (_bankCtrl.text.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09C).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, color: Color(0xFF00D09C), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_bankCtrl.text} • ${_branchName.isNotEmpty ? _branchName : "Branch Verified"}',
                            style: const TextStyle(color: Color(0xFF00D09C), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                ],

                // 2. Account Number
                _Field(
                  'Account Number',
                  _accCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'Enter bank account number',
                  type: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // 3. Confirm Account Number (Typo Prevention)
                _Field(
                  'Re-enter Account Number',
                  _confirmAccCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'Confirm bank account number',
                  type: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
                if (!_accMatch && _confirmAccCtrl.text.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 10, left: 4),
                    child: Text(
                      'Account numbers do not match. Please re-check.',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                ],

                // 4. Account Holder Name
                _Field(
                  'Account Holder Name (as per Bank)',
                  _holderCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'As per bank records / PAN card',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),

                // Account type
                Text(
                  'Account Type',
                  style: TextStyle(
                    color: ts,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['savings', 'current'].map((t) {
                    final active = _accType == t;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _accType = t);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF00D09C),
                                        Color(0xFF00B080),
                                      ],
                                    )
                                  : null,
                              color: active
                                  ? null
                                  : (dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5F0)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active ? Colors.transparent : border,
                              ),
                            ),
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: active ? Colors.black : ts,
                                fontSize: 13,
                                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Save button with Penny Drop verification
                GestureDetector(
                  onTap: _valid && !_saving
                      ? () async {
                          setState(() => _saving = true);
                          HapticFeedback.lightImpact();

                          final ok = await WalletController.to.addBank(
                            accountHolder: _holderCtrl.text.trim().toUpperCase(),
                            accountNumber: _accCtrl.text.trim(),
                            ifsc: _ifscCtrl.text.trim().toUpperCase(),
                            bankName: _bankCtrl.text.trim().isNotEmpty ? _bankCtrl.text.trim() : 'Primary Bank',
                            accountType: _accType,
                          );
                          setState(() => _saving = false);
                          if (ok) {
                            Get.back();
                            Get.snackbar(
                              'Bank Verified & Added! 🏦',
                              'Account verified successfully under ${_holderCtrl.text.trim().toUpperCase()}',
                              backgroundColor: const Color(0xFF00D09C),
                              colorText: Colors.black,
                              duration: const Duration(seconds: 3),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _valid
                          ? const LinearGradient(
                              colors: [Color(0xFF00D09C), Color(0xFF00B080)],
                            )
                          : null,
                      color: _valid ? null : const Color(0xFF00D09C).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _valid
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D09C).withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: _saving
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Verifying Bank with RBI...',
                                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : Text(
                              _valid ? 'Verify & Link Bank Account (₹1 Deposit)' : 'Enter Valid Bank & IFSC Details',
                              style: TextStyle(
                                color: _valid ? Colors.black : ts,
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
    });
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final Color tp;
  final Color ts;
  final Color border;
  final bool dark;
  final String? hint;
  final TextInputType? type;
  final Widget? suffix;
  final void Function(String)? onChanged;

  const _Field(
    this.label,
    this.ctrl,
    this.tp,
    this.ts,
    this.border,
    this.dark, {
    this.hint,
    this.type,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ts,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5F0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: type,
            style: TextStyle(
              color: tp,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: ts.withOpacity(0.5), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              suffixIcon: suffix,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
