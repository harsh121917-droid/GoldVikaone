import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';
import 'order_details_view.dart';

class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final isDark = ThemeController.to.isDark.value;

    final bg = isDark ? const Color(0xFF0A0D14) : const Color(0xFFF6F8FB);
    final cardBg = isDark ? const Color(0xFF141923) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF262F40) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Orders & Tracking',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            onPressed: () => controller.fetchOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // -- Filter Chips Bar ------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: cardBg,
            child: Obx(
              () => Row(
                children: [
                  _filterChip(
                    context: context,
                    label: 'All Orders',
                    value: 'all',
                    selected: controller.selectedFilter.value == 'all',
                    onTap: () => controller.selectedFilter.value = 'all',
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    context: context,
                    label: 'In Transit',
                    value: 'in_transit',
                    selected: controller.selectedFilter.value == 'in_transit',
                    onTap: () => controller.selectedFilter.value = 'in_transit',
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    context: context,
                    label: 'Delivered',
                    value: 'delivered',
                    selected: controller.selectedFilter.value == 'delivered',
                    onTap: () => controller.selectedFilter.value = 'delivered',
                  ),
                ],
              ),
            ),
          ),

          // -- Orders List ------------------------------------------------
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              if (controller.errorMsg.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMsg.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchOrders(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Try Again',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final ordersList = controller.filteredOrders;
              if (ordersList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 64, color: textSecondary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text(
                        'No orders found',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your placed jewellery or coin orders will appear here.',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchOrders(),
                color: AppColors.accent,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ordersList.length,
                  itemBuilder: (context, index) {
                    final order = ordersList[index];
                    return _buildOrderCard(context, order, cardBg, border,
                        textPrimary, textSecondary);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required BuildContext context,
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final statusBadge = _getDeliveryStatusBadge(order.deliveryStatus);
    final dateStr =
        '${order.createdAt.day} ${_monthName(order.createdAt.month)} ${order.createdAt.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Get.to(() => OrderDetailsView(orderId: order.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Metal Tag & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.metalType == 'gold'
                          ? const Color(0xFFFFF7D6)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: order.metalType == 'gold'
                              ? const Color(0xFFD4A017)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.metalType.toUpperCase(),
                          style: TextStyle(
                            color: order.metalType == 'gold'
                                ? const Color(0xFF8C6B00)
                                : const Color(0xFF334155),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  statusBadge,
                ],
              ),
              const SizedBox(height: 14),

              // Product Info Row
              Row(
                children: [
                  // Image
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: order.imageUrl != null && order.imageUrl!.isNotEmpty
                        ? Image.network(
                            order.imageUrl!,
                            fit: BoxFit.contain, alignment: Alignment.center,
                            errorBuilder: (ctx, err, stack) => Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.workspace_premium,
                                color: AppColors.accent,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => const Icon(
                              Icons.workspace_premium,
                              color: AppColors.accent,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Specs
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.jewelleryName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.weightGrams.toStringAsFixed(2)}g  •  ${order.purity ?? 'Certified Pure'}',
                          style: TextStyle(color: textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered on $dateStr',
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(color: border, height: 1),
              const SizedBox(height: 12),

              // Footer: Paid Amount & Details Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL PAID',
                          style: TextStyle(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                      const SizedBox(height: 2),
                      Text(
                        '?${order.totalPaid.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        'Track & Details',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.accent, size: 18),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDeliveryStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'processing':
        bg = const Color(0xFFE0F2FE);
        text = const Color(0xFF0284C7);
        label = '?? Processing';
        break;
      case 'out_of_warehouse':
        bg = const Color(0xFFF3E8FF);
        text = const Color(0xFF7E22CE);
        label = '?? Out of Warehouse';
        break;
      case 'shipped':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = '?? Shipped';
        break;
      case 'out_for_delivery':
        bg = const Color(0xFFFEF9C3);
        text = const Color(0xFFA16207);
        label = '?? Out for Delivery';
        break;
      case 'delivered':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF15803D);
        label = '? Delivered';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFB91C1C);
        label = '? Cancelled';
        break;
      case 'placed':
      default:
        bg = const Color(0xFFE2E8F0);
        text = const Color(0xFF475569);
        label = '?? Order Placed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }
}
