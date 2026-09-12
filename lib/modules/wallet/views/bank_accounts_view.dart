import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/routes/app_routes.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class BankAccountsView extends StatefulWidget {
  const BankAccountsView({super.key});
  @override
  State<BankAccountsView> createState() => _BankAccountsViewState();
}

class _BankAccountsViewState extends State<BankAccountsView> {
  final _ctrl = WalletController.to;
  bool _showCompanyBankDetails = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: dark ? const Color(0xFF0E1626) : Colors.white,
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
            'Bank Accounts',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Info strip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your bank account is used for gold sale payouts and wallet withdrawals.',
                      style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bank cards
            if (_ctrl.banks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No bank accounts added yet',
                    style: TextStyle(color: ts, fontSize: 13),
                  ),
                ),
              ),
            ..._ctrl.banks.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: b.isDefault
                          ? const Color(0xFFD4A017).withOpacity(0.5)
                          : border,
                      width: b.isDefault ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF3B82F6),
                              size: 24,
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
                                      b.bankName,
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (b.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4A017,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Default',
                                          style: TextStyle(
                                            color: Color(0xFFD4A017),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  b.accountHolder,
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // More options
                          PopupMenuButton<String>(
                            color: cardBg,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: ts,
                              size: 20,
                            ),
                            onSelected: (v) async {
                              if (v == 'default') {
                                await _ctrl.setDefaultBank(b.id);
                                Get.snackbar(
                                  'Default Updated',
                                  '${b.bankName} set as default',
                                  backgroundColor: const Color(0xFFD4A017),
                                  colorText: Colors.black,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else if (v == 'delete') {
                                await _ctrl.deleteBank(b.id);
                                Get.snackbar(
                                  'Removed',
                                  '${b.bankName} removed',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              if (!b.isDefault)
                                const PopupMenuItem(
                                  value: 'default',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_outline_rounded,
                                        size: 18,
                                        color: Color(0xFFD4A017),
                                      ),
                                      SizedBox(width: 10),
                                      Text('Set as Default'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Color(0xFFe74c3c),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: Color(0xFFe74c3c),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _BankDetail('A/c No.', b.maskedAcc, ts, tp),
                          _BankDetail('IFSC', b.ifsc, ts, tp),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Add new
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.addBankAccount),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.4),
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Color(0xFFD4A017),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add New Bank Account',
                        style: TextStyle(
                          color: Color(0xFFD4A017),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // QR Scan & Pay Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner_rounded,
                          color: Color(0xFFD4A017),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan & Pay (UPI)',
                              style: TextStyle(
                                color: tp,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tap the QR to view full details',
                              style: TextStyle(color: ts, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Get.dialog(
                        Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E1B1B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.account_balance, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          'IDFC FIRST Bank',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'SCAN & PAY',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black, width: 2),
                                    ),
                                    child: Image.asset(
                                      'assets/images/bank_qr.png',
                                      width: 180,
                                      height: 180,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'UPI ID: payvika@idfcbank',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => _copyToClipboard('payvika@idfcbank', 'UPI ID'),
                                        borderRadius: BorderRadius.circular(6),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF8E1B1B)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9F7F2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.account_balance, size: 15, color: Color(0xFF8E1B1B)),
                                            SizedBox(width: 6),
                                            Text(
                                              'Company Bank Account Details',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _dialogBankItem('Company', 'PAYVIKA INDIA TECHNOLOGY PRIVATE LIMITED', true),
                                        _dialogBankItem('Bank', 'IDFC FIRST', false),
                                        _dialogBankItem('A/C Number', '60000003300', true),
                                        _dialogBankItem('IFSC', 'IDFB0021424', true),
                                        _dialogBankItem('SWIFT', 'IDFBINBBMUM', true),
                                        _dialogBankItem('Branch', 'GHAZIABAD - INDIRAPURAM 2 BRANCH', false),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(color: Colors.black12, height: 1),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      _upiBrandLogo('GPay', Colors.blue),
                                      _upiBrandLogo('PhonePe', Colors.purple),
                                      _upiBrandLogo('Paytm', Colors.lightBlue),
                                      _upiBrandLogo('BHIM UPI', Colors.teal),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF03160E),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text('Close Scanner'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border.withOpacity(0.3)),
                      ),
                      child: Image.asset(
                        'assets/images/bank_qr.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'UPI ID: payvika@idfcbank',
                        style: TextStyle(
                          color: tp,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _copyToClipboard('payvika@idfcbank', 'UPI ID'),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFFD4A017)),
                        ),
                      ),
                    ],
                  ),
                  _buildCompanyBankDetails(
                    dark: dark,
                    tp: tp,
                    ts: ts,
                    border: border,
                    cardBg: cardBg,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFFF9800),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: Before making payment to this, please contact us at vikaone.com. Amount will be credited in your wallet within 24 hours.',
                            style: TextStyle(
                              color: dark ? Colors.white70 : const Color(0xFFE65100),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied to Clipboard',
      '$label copied successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF03160E),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFFD4A017), size: 20),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildCompanyBankDetails({
    required bool dark,
    required Color tp,
    required Color ts,
    required Color border,
    required Color cardBg,
  }) {
    final subCardBg = dark ? const Color(0xFF131F33) : const Color(0xFFF9F7F2);
    final highlightBorder = const Color(0xFFD4A017).withOpacity(0.35);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      decoration: BoxDecoration(
        color: subCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _showCompanyBankDetails ? highlightBorder : border),
      ),
      child: Column(
        children: [
          // Toggle Header Button
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _showCompanyBankDetails = !_showCompanyBankDetails;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFFD4A017),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Official Bank Account Details',
                          style: TextStyle(
                            color: tp,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _showCompanyBankDetails
                              ? 'Tap to hide bank transfer details'
                              : 'Tap to view IMPS / NEFT / RTGS details',
                          style: TextStyle(color: ts, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showCompanyBankDetails
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFFD4A017),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          // Collapsible Details
          if (_showCompanyBankDetails) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.25)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 13),
                        SizedBox(width: 5),
                        Text(
                          'OFFICIAL COMPANY CURRENT ACCOUNT',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _bankRow(
                    label: 'Company Name',
                    value: 'PAYVIKA INDIA TECHNOLOGY PRIVATE LIMITED',
                    tp: tp,
                    ts: ts,
                    onCopy: () => _copyToClipboard(
                      'PAYVIKA INDIA TECHNOLOGY PRIVATE LIMITED',
                      'Company Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _bankRow(
                    label: 'Bank Name',
                    value: 'IDFC FIRST',
                    tp: tp,
                    ts: ts,
                    onCopy: () => _copyToClipboard('IDFC FIRST', 'Bank Name'),
                  ),
                  const SizedBox(height: 10),
                  _bankRow(
                    label: 'Account Number',
                    value: '60000003300',
                    tp: tp,
                    ts: ts,
                    isHighlighted: true,
                    onCopy: () => _copyToClipboard('60000003300', 'Account Number'),
                  ),
                  const SizedBox(height: 10),
                  _bankRow(
                    label: 'IFSC Code',
                    value: 'IDFB0021424',
                    tp: tp,
                    ts: ts,
                    isHighlighted: true,
                    onCopy: () => _copyToClipboard('IDFB0021424', 'IFSC Code'),
                  ),
                  const SizedBox(height: 10),
                  _bankRow(
                    label: 'SWIFT Code',
                    value: 'IDFBINBBMUM',
                    tp: tp,
                    ts: ts,
                    onCopy: () => _copyToClipboard('IDFBINBBMUM', 'SWIFT Code'),
                  ),
                  const SizedBox(height: 10),
                  _bankRow(
                    label: 'Branch',
                    value: 'GHAZIABAD - INDIRAPURAM 2 BRANCH',
                    tp: tp,
                    ts: ts,
                    onCopy: () => _copyToClipboard(
                      'GHAZIABAD - INDIRAPURAM 2 BRANCH',
                      'Branch Name',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        const allDetails =
                            'Company: PAYVIKA INDIA TECHNOLOGY PRIVATE LIMITED\n'
                            'Bank: IDFC FIRST\n'
                            'Account Number: 60000003300\n'
                            'IFSC: IDFB0021424\n'
                            'SWIFT: IDFBINBBMUM\n'
                            'Branch: GHAZIABAD - INDIRAPURAM 2 BRANCH';
                        _copyToClipboard(allDetails, 'All Bank Details');
                      },
                      icon: const Icon(Icons.copy_all_rounded, size: 16),
                      label: const Text(
                        'Copy All Bank Details',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4A017),
                        side: const BorderSide(color: Color(0xFFD4A017)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bankRow({
    required String label,
    required String value,
    required Color tp,
    required Color ts,
    required VoidCallback onCopy,
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: ts, fontSize: 10, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isHighlighted ? const Color(0xFFD4A017) : tp,
                  fontSize: isHighlighted ? 13.5 : 12.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: isHighlighted ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 16),
          color: const Color(0xFFD4A017),
          splashRadius: 18,
          onPressed: onCopy,
          tooltip: 'Copy $label',
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _dialogBankItem(String label, String value, bool canCopy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 10.5, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
          if (canCopy)
            InkWell(
              onTap: () => _copyToClipboard(value, label),
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Icon(Icons.copy_rounded, size: 13, color: Color(0xFF8E1B1B)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _upiBrandLogo(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── Add Bank Sheet ───────────────────────────────────────────────────────────
class _BankDetail extends StatelessWidget {
  const _BankDetail(this.label, this.value, this.ts, this.tp);
  final String label, value;
  final Color ts, tp;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: ts, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: tp,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
