import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/fd_models.dart';
import '../controllers/fixed_deposits_controller.dart';

class MyFdApplicationsView extends StatelessWidget {
  const MyFdApplicationsView({super.key});

  // ── Modern Clean Theme Colors ───────────────────────────────
  static const Color _bgLight = Color(0xFFF8F9FE);
  static const Color _cardBg = Colors.white;
  static const Color _cardBorder = Color(0xFFE2E8F0);
  static const Color _accentGold = Color(0xFFD4A017);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FixedDepositsController>();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Fixed Deposits',
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _accentGold),
            onPressed: () {
              HapticFeedback.selectionClick();
              controller.loadMyApplications();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingMyApps.value) {
          return const Center(child: CircularProgressIndicator(color: _accentGold));
        }

        final list = controller.myApplications;
        if (list.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: _textMuted, size: 38),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No FD Applications Found',
                    style: TextStyle(color: _textDark, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'You haven’t submitted any Fixed Deposit applications yet. Start investing with top CRISIL AAA-rated companies today.',
                    style: TextStyle(color: _textMuted, fontSize: 13, height: 1.45),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentGold,
                      foregroundColor: const Color(0xFF1A2340),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                    ),
                    child: const Text('Explore Fixed Deposits', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final app = list[index];
            return _buildApplicationCard(app);
          },
        );
      }),
    );
  }

  Widget _buildApplicationCard(FdApplicationModel app) {
    Color statusBg;
    Color statusColor;
    String statusLabel;

    switch (app.status) {
      case 'APPROVED':
        statusBg = const Color(0xFFECFDF5);
        statusColor = const Color(0xFF059669);
        statusLabel = 'Approved / FDR Issued';
        break;
      case 'APPLIED_ON_IRIS':
        statusBg = const Color(0xFFF0F9FF);
        statusColor = const Color(0xFF0284C7);
        statusLabel = 'Applied on IRIS';
        break;
      case 'PAYMENT_PENDING':
        statusBg = const Color(0xFFFFFBEB);
        statusColor = const Color(0xFFB45309);
        statusLabel = 'Payment Pending';
        break;
      case 'REJECTED':
        statusBg = const Color(0xFFFFF1F2);
        statusColor = const Color(0xFFE11D48);
        statusLabel = 'Rejected';
        break;
      case 'SUBMITTED':
      default:
        statusBg = const Color(0xFFFFFBEB);
        statusColor = const Color(0xFFB45309);
        statusLabel = 'Submitted (Pending IRIS)';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Company + Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Icon(Icons.account_balance, color: _accentGold, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    app.company,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Application ID & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'App ID: ${app.applicationId}',
                style: const TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                '${app.createdAt.day}/${app.createdAt.month}/${app.createdAt.year}',
                style: const TextStyle(color: _textMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(color: _cardBorder, height: 20),

          // Financial Specs Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricTile('Deposit Amount', '₹${app.amount.toStringAsFixed(0)}', isHighlight: true),
              _metricTile('Tenure & Rate', '${app.tenureMonths}M @ ${app.interestRate}%'),
              _metricTile('Payout Type', app.payoutFrequency.replaceAll('_', ' ')),
            ],
          ),
          const SizedBox(height: 12),

          // Maturity / Payout Metric
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Maturity Approx:', style: TextStyle(color: _textMuted, fontSize: 12)),
                Text(
                  '₹${app.maturityAmount.toStringAsFixed(0)}',
                  style: const TextStyle(color: _accentGold, fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),

          // IRIS Punching / Certificate Reference
          if (app.irisFDRNo != null && app.irisFDRNo!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Color(0xFF059669), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'FDR No: ${app.irisFDRNo}',
                    style: const TextStyle(color: Color(0xFF059669), fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textMuted, fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? _textDark : const Color(0xFF334155),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
