import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vika1/data/repositories/copper_repository.dart';
import 'package:vika1/modules/invoice/views/invoice_viewer_view.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class CopperTransactionDetailView extends StatefulWidget {
  const CopperTransactionDetailView({super.key, required this.txn});
  final CopperTxnModel txn;

  @override
  State<CopperTransactionDetailView> createState() =>
      _CopperTransactionDetailViewState();
}

class _CopperTransactionDetailViewState
    extends State<CopperTransactionDetailView> {
  final _repo = CopperRepository();
  bool _downloading = false;

  Future<void> _downloadInvoice() async {
    setState(() => _downloading = true);
    try {
      final bytes = await _repo.getTransactionInvoice(widget.txn.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice-copper-${widget.txn.id}.pdf');
      await file.writeAsBytes(bytes);
      Get.to(() => InvoiceViewerView(
            filePath: file.path,
            title: 'Copper Invoice',
          ));
    } catch (e) {
      Get.snackbar(
        'Failed',
        'Could not download copper invoice. Try again.',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.txn;
    final isBuy = t.isBuy;

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF0C0704) : const Color(0xFFFBF8F5);
      final cardBg = dark ? const Color(0xFF19100A) : Colors.white;
      final tp = dark ? const Color(0xFFFFF7ED) : const Color(0xFF2C1810);
      final ts = dark ? const Color(0xFFA8988B) : const Color(0xFF7A6A5E);
      final border = dark ? const Color(0x33D97706) : const Color(0xFFF0E4D8);
      const copperAccent = Color(0xFFEA580C);
      const copperPrimary = Color(0xFFC86D3B);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF24150D) : const Color(0xFFF5ECE4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Text(
            'Copper Transaction',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero card ────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isBuy
                        ? [const Color(0xFF3D1B0A), const Color(0xFF6B3210)]
                        : [const Color(0xFF1E140F), const Color(0xFF3A241B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: copperPrimary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isBuy
                                ? Icons.add_rounded
                                : Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBuy ? 'Copper Purchased' : 'Copper Sold',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                _fmtDate(t.createdAt),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: (t.isSuccess
                                    ? const Color(0xFF2ecc71)
                                    : const Color(0xFFF39C12))
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t.isSuccess ? 'Success' : t.status,
                            style: TextStyle(
                              color: t.isSuccess
                                  ? const Color(0xFF2ecc71)
                                  : const Color(0xFFF39C12),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Weight',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${t.grams.toStringAsFixed(4)} g',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Total Paid',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${(t.totalAmt > 0 ? t.totalAmt : t.copperValue).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFFFA07A),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Breakdown details ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Breakdown',
                      style: TextStyle(
                        color: tp,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _row('Invoice Number', t.displayInvoiceNo, tp, ts),
                    _div(border),
                    _row('Metal Type', '999 Pure Electrolytic Copper', tp, ts),
                    _div(border),
                    _row(
                      'Live Rate per Gram',
                      '₹${t.ratePerGram.toStringAsFixed(2)}/g',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      'Taxable Copper Value',
                      '₹${t.copperValue.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    if (isBuy && t.gstAmt > 0) ...[
                      _div(border),
                      _row(
                        'GST (18% - 9% CGST + 9% SGST)',
                        '₹${t.gstAmt.toStringAsFixed(2)}',
                        tp,
                        ts,
                      ),
                    ],
                    _div(border),
                    _row(
                      'Net Total Amount',
                      '₹${(t.totalAmt > 0 ? t.totalAmt : t.copperValue).toStringAsFixed(2)}',
                      copperAccent,
                      ts,
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Security assurance ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: copperPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: copperPrimary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: copperAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Physical 999 electrolytic copper insured & stored in secure vaults.',
                        style: TextStyle(color: ts, fontSize: 11.5, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Download Invoice Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _downloading ? null : _downloadInvoice,
                  icon: _downloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  label: Text(
                    _downloading ? 'Generating Invoice...' : 'Download Tax Invoice (PDF)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: copperPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _row(
    String label,
    String value,
    Color valColor,
    Color labelColor, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: labelColor, fontSize: 12.5)),
          Text(
            value,
            style: TextStyle(
              color: valColor,
              fontSize: 12.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _div(Color border) => Divider(color: border, height: 16);

  String _fmtDate(DateTime d) {
    const months = [
      '',
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
      'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}, ${_fmtTime(d)}';
  }

  String _fmtTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final am = d.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $am';
  }
}
