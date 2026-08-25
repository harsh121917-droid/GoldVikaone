import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/gold_repository.dart';
import 'package:vika1/data/repositories/silver_repository.dart';
import 'package:vika1/data/repositories/copper_repository.dart';
import 'package:vika1/modules/digi_gold/views/transaction_detail_view.dart';
import 'package:vika1/modules/silver_sip/views/silver_transaction_detail_view.dart';
import '../../../core/theme/controllers/theme_controller.dart';

// ─── Local theme helper ──────────────────────────────────────────────────────
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
          bg: Color(0xFF060B16),
          card: Color(0xFF0E1626),
          primary: Color(0xFF8A95B0),
          ink: Color(0xFFEDF0FF),
          inkMuted: Color(0xFF8A95B0),
          border: Color(0xFF1A2B45),
          subBg: Color(0xFF0A0F1E),
        )
      : const _T(
          bg: Color(0xFFF4F6FA),
          card: Colors.white,
          primary: Color(0xFF1A2340),
          ink: Color(0xFF1A2340),
          inkMuted: Color(0xFF6B7280),
          border: Color(0xFFE8EBF2),
          subBg: Color(0xFFF3F5F9),
        );
}

// ─── GetX State Controller ──────────────────────────────────────────────────
class TransactionsController extends GetxController {
  final _goldRepo = GoldRepository();
  final _silverRepo = SilverRepository();
  final _copperRepo = CopperRepository();

  var isLoadingGold = true.obs;
  var isLoadingSilver = true.obs;
  var isLoadingCopper = true.obs;

  var goldTxns = <GoldTxnModel>[].obs;
  var silverTxns = <SilverTxnModel>[].obs;
  var copperTxns = <CopperTxnModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    loadGoldTxns();
    loadSilverTxns();
    loadCopperTxns();
  }

  Future<void> loadGoldTxns() async {
    try {
      isLoadingGold(true);
      final list = await _goldRepo.getTransactions();
      goldTxns.value = list;
    } catch (e) {
      // Silently catch network failures
    } finally {
      isLoadingGold(false);
    }
  }

  Future<void> loadSilverTxns() async {
    try {
      isLoadingSilver(true);
      final list = await _silverRepo.getTransactions();
      silverTxns.value = list;
    } catch (e) {
      // Silently catch network failures
    } finally {
      isLoadingSilver(false);
    }
  }

  Future<void> loadCopperTxns() async {
    try {
      isLoadingCopper(true);
      final list = await _copperRepo.getTransactions();
      copperTxns.value = list;
    } catch (e) {
      // Silently catch network failures
    } finally {
      isLoadingCopper(false);
    }
  }
}

// ─── View Screen Widget ─────────────────────────────────────────────────────
class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _ctrl = Get.put(TransactionsController());

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.card,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: t.ink, size: 20),
            ),
          ),
          title: Text(
            'Transaction History',
            style: TextStyle(
              color: t.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          bottom: TabBar(
            controller: _tabCtrl,
            labelColor: t.primary,
            unselectedLabelColor: t.inkMuted,
            indicatorColor: t.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Gold'),
              Tab(text: 'Silver'),
              Tab(text: 'Copper'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildGoldTab(t),
            _buildSilverTab(t),
            _buildCopperTab(t),
          ],
        ),
      );
    });
  }

  // ─── Gold Tab ───────────────────────────────────────────────────────────────
  Widget _buildGoldTab(_T t) {
    return Obx(() {
      if (_ctrl.isLoadingGold.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_ctrl.goldTxns.isEmpty) {
        return _buildEmptyState('No gold transactions yet', t);
      }
      return RefreshIndicator(
        onRefresh: () => _ctrl.loadGoldTxns(),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: _ctrl.goldTxns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final txn = _ctrl.goldTxns[i];
            return _buildMetalCard(
              title: txn.typeLabel,
              grams: txn.grams,
              rate: txn.ratePerGram,
              amount: txn.totalAmt,
              status: txn.status,
              date: txn.createdAt,
              t: t,
              onTap: () => Get.to(() => TransactionDetailView(txn: txn)),
            );
          },
        ),
      );
    });
  }

  // ─── Silver Tab ─────────────────────────────────────────────────────────────
  Widget _buildSilverTab(_T t) {
    return Obx(() {
      if (_ctrl.isLoadingSilver.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_ctrl.silverTxns.isEmpty) {
        return _buildEmptyState('No silver transactions yet', t);
      }
      return RefreshIndicator(
        onRefresh: () => _ctrl.loadSilverTxns(),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: _ctrl.silverTxns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final txn = _ctrl.silverTxns[i];
            return _buildMetalCard(
              title: txn.typeLabel,
              grams: txn.grams,
              rate: txn.ratePerGram,
              amount: txn.totalAmt,
              status: txn.status,
              date: txn.createdAt,
              t: t,
              onTap: () => Get.to(() => SilverTransactionDetailView(txn: txn)),
            );
          },
        ),
      );
    });
  }

  // ─── Copper Tab ─────────────────────────────────────────────────────────────
  Widget _buildCopperTab(_T t) {
    return Obx(() {
      if (_ctrl.isLoadingCopper.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_ctrl.copperTxns.isEmpty) {
        return _buildEmptyState('No copper transactions yet', t);
      }
      return RefreshIndicator(
        onRefresh: () => _ctrl.loadCopperTxns(),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(16),
          itemCount: _ctrl.copperTxns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final txn = _ctrl.copperTxns[i];
            return _buildMetalCard(
              title: txn.typeLabel,
              grams: txn.grams,
              rate: txn.ratePerGram,
              amount: txn.totalAmt > 0 ? txn.totalAmt : txn.copperValue,
              status: txn.status,
              date: txn.createdAt,
              t: t,
              onTap: () {
                // Show clean bottom sheet details for Copper
                _showCopperTxnModal(context, txn, t);
              },
            );
          },
        ),
      );
    });
  }

  void _showCopperTxnModal(BuildContext context, CopperTxnModel txn, _T t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.inkMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    txn.typeLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: t.ink,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: txn.isSuccess
                          ? const Color(0xFF2ECC71).withOpacity(0.12)
                          : const Color(0xFFF39C12).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      txn.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: txn.isSuccess ? const Color(0xFF2ECC71) : const Color(0xFFF39C12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _modalRow('Invoice No.', txn.displayInvoiceNo, t),
              _modalRow('Quantity', '${txn.grams.toStringAsFixed(4)} grams', t),
              _modalRow('Locked Rate', '₹${txn.ratePerGram.toStringAsFixed(2)} / g', t),
              if (txn.isBuy && txn.gstAmt > 0)
                _modalRow('GST (18%)', '₹${txn.gstAmt.toStringAsFixed(2)}', t),
              _modalRow('Total Amount', '₹${(txn.totalAmt > 0 ? txn.totalAmt : txn.copperValue).toStringAsFixed(2)}', t, isHighlight: true),
              _modalRow('Date & Time', '${txn.createdAt.day}/${txn.createdAt.month}/${txn.createdAt.year} ${txn.createdAt.hour.toString().padLeft(2, '0')}:${txn.createdAt.minute.toString().padLeft(2, '0')}', t),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _modalRow(String label, String value, _T t, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: t.inkMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? const Color(0xFFD4A017) : t.ink,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600,
              fontSize: isHighlight ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Gold & Silver & Copper list cards
  Widget _buildMetalCard({
    required String title,
    required double grams,
    required double rate,
    required double amount,
    required String status,
    required DateTime date,
    required _T t,
    required VoidCallback onTap,
  }) {
    final isSuccess = status == 'success';
    final statusColor = isSuccess ? const Color(0xFF2ecc71) : const Color(0xFFF39C12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSuccess ? Icons.offline_pin_rounded : Icons.schedule_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: t.ink,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${grams.toStringAsFixed(4)}g @ ₹${rate.toStringAsFixed(2)}/g',
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty state helper ─────────────────────────────────────────────────────
  Widget _buildEmptyState(String msg, _T t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: t.card,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: t.inkMuted.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            msg,
            style: TextStyle(
              color: t.inkMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
