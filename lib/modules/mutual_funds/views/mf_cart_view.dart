import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_cart_model.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_cart_checkout_view.dart';
import 'mf_sip_investment_view.dart';
import 'widgets/mf_groww_widgets.dart';
import 'widgets/mf_skeleton_widgets.dart';

/// Full Production-Ready Screen for Mutual Funds Cart
/// Allows reviewing, modifying, removing, selecting, and executing investments for saved funds.
class MfCartView extends StatefulWidget {
  const MfCartView({Key? key}) : super(key: key);

  @override
  State<MfCartView> createState() => _MfCartViewState();
}

class _MfCartViewState extends State<MfCartView> {
  late final MutualFundsController controller;
  final RxSet<String> selectedItemIds = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MutualFundsController>()
        ? Get.find<MutualFundsController>()
        : Get.put(MutualFundsController());
    controller.fetchCart().then((_) {
      // By default, select all cart items
      final items = controller.cartData.value.items;
      selectedItemIds.assignAll(items.map((e) => e.id));
    });
  }

  void _syncSelectedItems(List<MfCartItem> items) {
    if (selectedItemIds.isEmpty && items.isNotEmpty) {
      selectedItemIds.assignAll(items.map((e) => e.id));
    } else {
      // Keep only IDs that still exist in cart
      final currentIds = items.map((e) => e.id).toSet();
      selectedItemIds.removeWhere((id) => !currentIds.contains(id));
      if (selectedItemIds.isEmpty && items.isNotEmpty) {
        selectedItemIds.assignAll(items.map((e) => e.id));
      }
    }
  }

  String _cleanSchemeName(String name) {
    return name
        .replaceAll(RegExp(r'\s*-\s*Regular\s*Plan.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Direct\s*Plan.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*Growth.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*-\s*IDCW.*$', caseSensitive: false), '')
        .trim();
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161E2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Clear Cart?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Are you sure you want to remove all mutual funds from your cart?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              selectedItemIds.clear();
              controller.clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 36),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _investInCartItem(BuildContext context, MfCartItem item) {
    // Find cached scheme in controller or construct from cart item
    MfSchemeModel? scheme;
    try {
      scheme = controller.schemes.firstWhereOrNull((s) => s.schemeCode == item.schemeCode);
    } catch (_) {}

    final targetScheme = scheme ??
        MfSchemeModel(
          id: item.id.isNotEmpty ? item.id : item.schemeCode,
          schemeCode: item.schemeCode,
          schemeName: item.schemeName,
          amcCode: '',
          amcName: item.amcName,
          isin: '',
          category: item.category.isNotEmpty ? item.category : 'Equity',
          subCategory: '',
          riskLevel: 'Moderate',
          isPopular: false,
          isFeatured: false,
          planType: 'REGULAR',
          nav: 0.0,
          minPurchaseAmount: item.amount,
          minSipAmount: item.amount,
        );

    final isSip = item.investmentType.toUpperCase() == 'SIP';
    Get.to(() => MfSipInvestmentView(
          scheme: targetScheme,
          isSip: isSip,
        ));
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF0F141E);
    const cardBg = Color(0xFF161E2D);
    const mintGreen = Color(0xFF00D09C);
    const borderCol = Color(0xFF22304A);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() {
          final count = controller.cartCount;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mutual Funds Cart',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (count > 0)
                Text(
                  '$count ${count == 1 ? "fund" : "funds"} saved to invest',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
            ],
          );
        }),
        actions: [
          Obx(() {
            if (controller.cartCount == 0) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () => _showClearConfirmDialog(context),
              icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 18),
              label: const Text(
                'Clear',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isCartLoading.value && controller.cartData.value.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: MfListScreenSkeleton(itemCount: 4),
          );
        }

        final cart = controller.cartData.value;
        final items = cart.items;
        _syncSelectedItems(items);

        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchCart(),
            color: mintGreen,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: cardBg,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderCol, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 42,
                          color: Colors.white38,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your Cart is Empty',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Add mutual funds or NFOs to your cart while browsing, then review and invest in them here anytime.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13.5, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.explore_outlined, size: 18),
                          label: const Text('Explore Mutual Funds'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mintGreen,
                            foregroundColor: const Color(0xFF0F141E),
                            elevation: 0,
                            minimumSize: const Size(200, 46),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final selectedItems = items.where((i) => selectedItemIds.contains(i.id)).toList();
        final selectedTotal = selectedItems.fold<double>(0.0, (sum, i) => sum + i.amount);
        final isAllSelected = selectedItems.length == items.length && items.isNotEmpty;

        return RefreshIndicator(
          onRefresh: () => controller.fetchCart(),
          color: mintGreen,
          child: Column(
            children: [
              // Selection Header Bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D2D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E2E48)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isAllSelected,
                      activeColor: mintGreen,
                      checkColor: Colors.black,
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        if (val == true) {
                          selectedItemIds.assignAll(items.map((e) => e.id));
                        } else {
                          selectedItemIds.clear();
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Select All (${items.length} ${items.length == 1 ? "fund" : "funds"})',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: mintGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${selectedItems.length} selected',
                        style: const TextStyle(color: mintGreen, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSip = item.investmentType.toUpperCase() == 'SIP';
                    final isSelected = selectedItemIds.contains(item.id);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? mintGreen.withOpacity(0.55) : borderCol,
                          width: isSelected ? 1.4 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Checkbox to select/deselect
                              Checkbox(
                                value: isSelected,
                                activeColor: mintGreen,
                                checkColor: Colors.black,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) {
                                  if (val == true) {
                                    selectedItemIds.add(item.id);
                                  } else {
                                    selectedItemIds.remove(item.id);
                                  }
                                },
                              ),
                              const SizedBox(width: 4),
                              // Authentic AMC Brand Logo
                              AmcBrandLogo(
                                amcName: item.amcName,
                                schemeName: item.schemeName,
                                size: 40,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _cleanSchemeName(item.schemeName),
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        height: 1.25,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.amcName.isNotEmpty ? item.amcName : 'Mutual Fund',
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                onPressed: () {
                                  selectedItemIds.remove(item.id);
                                  controller.removeFromCart(item.id);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFF22304A), height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isSip
                                                ? mintGreen.withOpacity(0.15)
                                                : Colors.blue.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isSip ? 'SIP • ${item.sipDay}th of month' : 'One-time (Lumpsum)',
                                            style: TextStyle(
                                              color: isSip ? mintGreen : Colors.blueAccent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (item.category.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              item.category,
                                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '₹${item.amount.toInt()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Direct Invest button for this single item
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () => _investInCartItem(context, item),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mintGreen.withOpacity(0.15),
                                    foregroundColor: mintGreen,
                                    side: const BorderSide(color: mintGreen, width: 1.2),
                                    elevation: 0,
                                    minimumSize: const Size(68, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    'Invest',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom sticky checkout bar with selected funds total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: cardBg,
                  border: Border(top: BorderSide(color: borderCol, width: 1)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total (${selectedItems.length} ${selectedItems.length == 1 ? "fund" : "funds"})',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${selectedTotal.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: selectedItems.isNotEmpty
                                ? () async {
                                    await Get.to(() => MfCartCheckoutView(initialSelectedItems: selectedItems));
                                    controller.fetchCart();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedItems.isNotEmpty ? mintGreen : Colors.white24,
                              foregroundColor: const Color(0xFF0F141E),
                              elevation: 0,
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              selectedItems.isNotEmpty
                                  ? 'Proceed to Invest (${selectedItems.length})'
                                  : 'Select Funds to Invest',
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
