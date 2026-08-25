import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/sip_repository.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _silver = Color(0xFF9E9E9E);
const _copper = Color(0xFFD97706);
const _success = Color(0xFF10B981);
const _danger = Color(0xFFEF4444);
const _purple = Color(0xFFA855F7);

class _T {
  final Color bg, card, primary, ink, inkMuted, border, subBg;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.border,
    required this.subBg,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF070B0E),
          card: Color(0xFF0F171E),
          primary: Color(0xFFD4A017),
          ink: Color(0xFFF1F5F9),
          inkMuted: Color(0xFF94A3B8),
          border: Color(0x1FFFFFFF),
          subBg: Color(0xFF16202B),
        )
      : const _T(
          bg: Color(0xFFF8FAFC),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF0F172A),
          inkMuted: Color(0xFF64748B),
          border: Color(0xFFE2E8F0),
          subBg: Color(0xFFF1F5F9),
        );
}

class SipJourneyView extends StatefulWidget {
  final String sipId;
  const SipJourneyView({super.key, required this.sipId});

  @override
  State<SipJourneyView> createState() => _SipJourneyViewState();
}

class _SipJourneyViewState extends State<SipJourneyView> {
  final _repo = SipRepository();
  bool _loading = true;
  String? _error;
  SipModel? _sip;
  List<SipMilestoneModel> _journey = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.getSipDetail(widget.sipId);
      setState(() {
        _sip = res['sip'] as SipModel;
        _journey = res['journey'] as List<SipMilestoneModel>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _payInstallment() async {
    if (_isProcessing || _sip == null) return;
    setState(() => _isProcessing = true);
    try {
      final updated = await _repo.payInstallment(_sip!.id);
      Get.snackbar(
        'Installment Paid!',
        'Successfully paid next SIP installment. Grams credited to your vault.',
        backgroundColor: _success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      if (Get.isRegistered<WalletController>()) { WalletController.to.loadWallet(); }
      _loadDetail();
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: _danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleStatus() async {
    if (_isProcessing || _sip == null) return;
    setState(() => _isProcessing = true);
    try {
      final updated = await _repo.toggleSipStatus(_sip!.id);
      Get.snackbar(
        'Status Updated',
        'SIP is now ${updated.status.toUpperCase()}',
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      _loadDetail();
    } catch (e) {
      Get.snackbar(
        'Action Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: _danger,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _confirmCancel() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel SIP?'),
        content: const Text(
          'Are you sure you want to cancel this SIP? Future installments will stop, but all your accumulated bullion grams will stay 100% safe in your vault.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep Active'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _danger),
            onPressed: () => Get.back(result: true),
            child: const Text('Cancel SIP', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);
      try {
        await _repo.cancelSip(_sip!.id);
        Get.snackbar(
          'SIP Cancelled',
          'SIP cancelled. Your vault balance remains secure.',
          backgroundColor: const Color(0xFF64748B),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        _loadDetail();
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: _danger,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.ink, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'SIP Journey & Timeline',
            style: TextStyle(
              color: t.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: t.inkMuted),
              onPressed: _loadDetail,
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: _danger, size: 48),
                          const SizedBox(height: 12),
                          Text(_error!, style: TextStyle(color: t.ink, fontSize: 14), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadDetail, child: const Text('Try Again')),
                        ],
                      ),
                    ),
                  )
                : _buildContent(t, dark),
      );
    });
  }

  Widget _buildContent(_T t, bool dark) {
    final s = _sip!;
    final metalColor = s.isSilver ? _silver : s.isCopper ? _copper : _gold;
    final metalLabel = s.isSilver ? '999 Fine Silver' : s.isCopper ? '999 Pure Copper' : '24K 99.9% Pure Gold';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero SIP Header Card ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        const Color(0xFF1E293B),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        const Color(0xFF0F291E),
                        const Color(0xFF0B1F17),
                      ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: metalColor.withOpacity(0.3), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: metalColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: metalColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            s.isSilver ? Icons.layers_rounded : s.isCopper ? Icons.inventory_2_rounded : Icons.monetization_on_rounded,
                            color: metalColor,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${s.metal.toUpperCase()} SIP',
                            style: TextStyle(color: metalColor, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.isActive
                            ? _success.withOpacity(0.18)
                            : s.isPaused
                                ? const Color(0xFFF59E0B).withOpacity(0.18)
                                : const Color(0xFF64748B).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.status.toUpperCase(),
                        style: TextStyle(
                          color: s.isActive
                              ? _success
                              : s.isPaused
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Current Portfolio Value',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${s.currentValuation.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (s.returnsAmt >= 0 ? _success : _danger).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${s.returnsAmt >= 0 ? '+' : ''}₹${s.returnsAmt.toStringAsFixed(0)} (${s.returnsPct >= 0 ? '+' : ''}${s.returnsPct.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: s.returnsAmt >= 0 ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Accumulated', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              '${s.totalGrams.toStringAsFixed(4)}g',
                              style: TextStyle(color: metalColor, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 26, color: Colors.white.withOpacity(0.12)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Invested', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              '₹${s.totalInvested.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 26, color: Colors.white.withOpacity(0.12)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Plan Frequency', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                            const SizedBox(height: 2),
                            Text(
                              '${s.frequency.capitalizeFirst}',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // ── Progress Bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress (${s.cyclesCompleted}/${s.totalCycles} Cycles)',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${s.progressPct.toStringAsFixed(0)}%',
                      style: TextStyle(color: metalColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: s.totalCycles > 0 ? (s.cyclesCompleted / s.totalCycles).clamp(0.0, 1.0) : 0.0,
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(metalColor),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Quick Controls (Pay / Pause / Cancel) ─────────────────────────
          if (s.isActive) ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: _isProcessing ? null : _payInstallment,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pay Cycle #${s.cyclesCompleted + 1} (₹${s.installmentAmount.toStringAsFixed(0)})',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _isProcessing ? null : _toggleStatus,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.border),
                    ),
                    child: Icon(Icons.pause_rounded, color: t.inkMuted, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else if (s.isPaused) ...[
            GestureDetector(
              onTap: _isProcessing ? null : _toggleStatus,
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text('Resume SIP Plan', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Section Title: Step-by-Step Journey ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: metalColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.route_rounded, color: metalColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SIP Investment Journey',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Started ${_fmtDate(s.startDate)}',
                  style: TextStyle(color: t.inkMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Timeline List ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _journey.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, idx) {
                final item = _journey[idx];
                final isLast = idx == _journey.length - 1;
                return _buildTimelineItem(item, isLast, t, metalColor);
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Danger Zone: Cancel SIP ──────────────────────────────────────
          if (!s.isCompleted && !s.isCancelled) ...[
            Center(
              child: TextButton.icon(
                onPressed: _isProcessing ? null : _confirmCancel,
                icon: const Icon(Icons.cancel_outlined, color: _danger, size: 16),
                label: const Text('Cancel this SIP plan', style: TextStyle(color: _danger, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(SipMilestoneModel item, bool isLast, _T t, Color metalColor) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Line & Node Icon
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? _success
                      : item.isUpcoming
                          ? const Color(0xFFF59E0B)
                          : t.subBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isCompleted
                        ? _success
                        : item.isUpcoming
                            ? const Color(0xFFF59E0B)
                            : t.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: item.isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                      : item.isUpcoming
                          ? const Icon(Icons.access_time_rounded, color: Colors.white, size: 14)
                          : Text(
                              '${item.cycleNo}',
                              style: TextStyle(color: t.inkMuted, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: item.isCompleted ? _success.withOpacity(0.5) : t.border,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // Right Content Box
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? t.subBg.withOpacity(0.5)
                      : item.isUpcoming
                          ? const Color(0xFFF59E0B).withOpacity(0.08)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: item.isUpcoming ? const Color(0xFFF59E0B).withOpacity(0.3) : t.border.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cycle #${item.cycleNo}',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (item.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('PAID', style: TextStyle(color: _success, fontSize: 10, fontWeight: FontWeight.w800)),
                          )
                        else if (item.isUpcoming)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('UPCOMING', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w800)),
                          )
                        else
                          Text('SCHEDULED', style: TextStyle(color: t.inkMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item.isCompleted) ...[
                      Text(
                        'Paid ₹${item.amount.toStringAsFixed(0)} • Credited +${item.grams.toStringAsFixed(4)}g',
                        style: TextStyle(color: metalColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Date: ${_fmtDate(item.date)} @ ₹${item.ratePerGram.toStringAsFixed(0)}/g',
                        style: TextStyle(color: t.inkMuted, fontSize: 11),
                      ),
                    ] else if (item.isUpcoming) ...[
                      Text(
                        'Due Amount: ₹${item.amount.toStringAsFixed(0)}',
                        style: TextStyle(color: t.ink, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Next Due: ${_fmtDate(item.dueDate)}',
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      Text(
                        'Installment: ₹${item.amount.toStringAsFixed(0)}',
                        style: TextStyle(color: t.inkMuted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
