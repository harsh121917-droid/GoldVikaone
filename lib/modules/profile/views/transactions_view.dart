import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/data/repositories/gold_repository.dart';
import 'package:vika1/data/repositories/silver_repository.dart';
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

  var isLoadingGold = true.obs;
  var isLoadingSilver = true.obs;

  var goldTxns = <GoldTxnModel>[].obs;
  var silverTxns = <SilverTxnModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void loadAll() {
    loadGoldTxns();
    loadSilverTxns();
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
    _tabCtrl = TabController(length: 2, vsync: this);
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
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildGoldTab(t),
            _buildSilverTab(t),
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

  // Helper Widget for Gold & Silver list cards
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
