import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../controllers/orders_controller.dart';
import '../models/order_model.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final controller = OrdersController.to;
    final order = controller.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => controller.orders.first,
    );

    final isDark = ThemeController.to.isDark.value;
    final bg = isDark ? const Color(0xFF0A0D14) : const Color(0xFFF6F8FB);
    final cardBg = isDark ? const Color(0xFF141923) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF262F40) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textPrimary, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Order & Tracking Details',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- Hero Delivery Tracking Banner ----------------------------
            _buildDeliveryBanner(context, order, cardBg, border, textPrimary, textSecondary),
            const SizedBox(height: 16),

            // -- Visual Step-by-Step Delivery Progress Tracker ------------
            _buildVisualTracker(context, order, cardBg, border, textPrimary, textSecondary),
            const SizedBox(height: 16),

            // -- Tracking Logs & Status History ----------------------------
            if (order.statusHistory.isNotEmpty) ...[
              _buildStatusHistoryCard(context, order, cardBg, border, textPrimary, textSecondary),
              const SizedBox(height: 16),
            ],

            // -- Order Item Details Card ----------------------------------
            _buildProductCard(context, order, cardBg, border, textPrimary, textSecondary),
            const SizedBox(height: 16),

            // -- Payment Breakdown Card ------------------------------------
            _buildPaymentCard(context, order, cardBg, border, textPrimary, textSecondary),
            const SizedBox(height: 16),

            // -- Shipping Address Card ------------------------------------
            if (order.shippingAddress.isNotEmpty) ...[
              _buildAddressCard(context, order, cardBg, border, textPrimary, textSecondary),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -- Delivery Banner ---------------------------------------------------
  Widget _buildDeliveryBanner(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final isDelivered = order.deliveryStatus == 'delivered';
    final isCancelled = order.deliveryStatus == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDelivered
              ? [const Color(0xFF064E3B), const Color(0xFF047857)]
              : isCancelled
                  ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)]
                  : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
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
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isDelivered
                      ? 'DELIVERED'
                      : isCancelled
                          ? 'CANCELLED'
                          : 'IN TRANSIT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (order.estimatedDeliveryDate.isNotEmpty && !isDelivered)
                Text(
                  'ETA: ${order.estimatedDeliveryDate}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _getDeliveryHeaderTitle(order.deliveryStatus),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.statusNote.isNotEmpty
                ? order.statusNote
                : _getDeliveryHeaderSub(order.deliveryStatus),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (order.trackingId.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.courierName.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tracking: ${order.trackingId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy_rounded,
                          color: Colors.white, size: 18),
                      tooltip: 'Copy Tracking ID',
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: order.trackingId));
                        Get.snackbar(
                          'Copied!',
                          'Tracking ID copied to clipboard',
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                    ),
                    if (order.trackingUrl.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded,
                            color: AppColors.accent, size: 18),
                        tooltip: 'Track Package',
                        onPressed: () async {
                          final uri = Uri.parse(order.trackingUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // -- Step Progress Tracker ----------------------------------------------
  Widget _buildVisualTracker(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    final stages = [
      {'key': 'placed', 'title': 'Order Placed', 'icon': Icons.shopping_bag_outlined},
      {'key': 'processing', 'title': 'Processing & Quality Check', 'icon': Icons.build_circle_outlined},
      {'key': 'out_of_warehouse', 'title': 'Out of Warehouse', 'icon': Icons.storefront_outlined},
      {'key': 'out_for_delivery', 'title': 'Out for Delivery Today', 'icon': Icons.local_shipping_outlined},
      {'key': 'delivered', 'title': 'Delivered Successfully', 'icon': Icons.check_circle_outline},
    ];

    final currentStageIndex = _getStageIndex(order.deliveryStatus);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHIPMENT PROGRESS',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isCompleted = index <= currentStageIndex;
            final isCurrent = index == currentStageIndex;
            final isLast = index == stages.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator Icon & Vertical Connecting Line
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? (isCurrent ? AppColors.accent : AppColors.primary)
                            : border,
                      ),
                      child: Icon(
                        isCompleted
                            ? (isCurrent ? (stage['icon'] as IconData) : Icons.check)
                            : (stage['icon'] as IconData),
                        size: 16,
                        color: isCompleted
                            ? (isCurrent ? Colors.black : Colors.white)
                            : textSecondary,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 32,
                        color: index < currentStageIndex
                            ? AppColors.primary
                            : border,
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Step Description
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stage['title'] as String,
                          style: TextStyle(
                            color: isCompleted ? textPrimary : textSecondary,
                            fontSize: 14,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : (isCompleted
                                    ? FontWeight.w600
                                    : FontWeight.w400),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(height: 2),
                          Text(
                            _getStageSubtext(order.deliveryStatus),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // -- Status History Log Card -------------------------------------------
  Widget _buildStatusHistoryCard(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRACKING LOG & UPDATES',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          ...order.statusHistory.reversed.map((item) {
            final dateStr =
                '${item.date.day}/${item.date.month}/${item.date.year} ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: AppColors.accent, size: 8),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.isNotEmpty ? item.title : item.status,
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style:
                                TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style:
                              TextStyle(color: textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // -- Product Details Card -----------------------------------------------
  Widget _buildProductCard(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ITEM DETAILS',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
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
                        ),
                      )
                    : Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.jewelleryName,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.weightGrams.toStringAsFixed(2)}g  •  ${order.purity ?? 'Certified Pure'}',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -- Payment Breakdown Card ---------------------------------------------
  Widget _buildPaymentCard(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT SUMMARY',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Making Charges', '?${order.makingCharges.toStringAsFixed(2)}', textSecondary, textPrimary),
          const SizedBox(height: 8),
          _summaryRow('GST (3%)', '?${order.gstAmount.toStringAsFixed(2)}', textSecondary, textPrimary),
          const SizedBox(height: 8),
          _summaryRow('Payment Method', order.paymentMethod.toUpperCase(), textSecondary, textPrimary),
          const SizedBox(height: 12),
          Divider(color: border),
          const SizedBox(height: 8),
          _summaryRow(
            'Total Paid',
            '?${order.totalPaid.toStringAsFixed(2)}',
            textPrimary,
            AppColors.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  // -- Address Card -------------------------------------------------------
  Widget _buildAddressCard(
    BuildContext context,
    OrderModel order,
    Color cardBg,
    Color border,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY ADDRESS',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.shippingAddress,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String val,
    Color labelColor,
    Color valColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            color: valColor,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _getStageIndex(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 1;
      case 'out_of_warehouse':
        return 2;
      case 'shipped':
      case 'out_for_delivery':
        return 3;
      case 'delivered':
        return 4;
      case 'placed':
      default:
        return 0;
    }
  }

  String _getDeliveryHeaderTitle(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Item Being Processed';
      case 'out_of_warehouse':
        return 'Out of Warehouse';
      case 'shipped':
        return 'Shipped & En Route';
      case 'out_for_delivery':
        return 'Out for Delivery Today!';
      case 'delivered':
        return 'Delivered Successfully';
      case 'cancelled':
        return 'Order Cancelled';
      case 'placed':
      default:
        return 'Order Placed & Confirmed';
    }
  }

  String _getDeliveryHeaderSub(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Your item is being handcrafted, hallmarked & quality checked.';
      case 'out_of_warehouse':
        return 'Your package has departed our central logistics warehouse.';
      case 'shipped':
        return 'Package handed over to our secure courier partner.';
      case 'out_for_delivery':
        return 'Our courier delivery agent is on the way to your address today.';
      case 'delivered':
        return 'Your jewellery order has been delivered and verified.';
      case 'cancelled':
        return 'This order has been cancelled.';
      case 'placed':
      default:
        return 'Your order has been placed and verified successfully.';
    }
  }

  String _getStageSubtext(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return 'Crafting & Quality Check in progress';
      case 'out_of_warehouse':
        return 'Departed from central warehouse hub';
      case 'shipped':
        return 'In transit with courier partner';
      case 'out_for_delivery':
        return 'Agent is on the way to your doorstep';
      case 'delivered':
        return 'Safely received by customer';
      case 'placed':
      default:
        return 'Confirmed by merchant';
    }
  }

  Color bg(BuildContext context) {
    return ThemeController.to.isDark.value
        ? const Color(0xFF0F141D)
        : const Color(0xFFF1F5F9);
  }
}
