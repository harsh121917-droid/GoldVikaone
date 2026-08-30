import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/app_notification_model.dart';
import '../controllers/notification_inbox_controller.dart';

const _gold = Color(0xFFD4A017);
const _emerald = Color(0xFF10B981);

class _Palette {
  final Color bg, card, cardInner, ink, inkMuted, cardBorder, subBg, accentGlow;
  const _Palette({
    required this.bg,
    required this.card,
    required this.cardInner,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.accentGlow,
  });

  factory _Palette.of(bool dark) => dark
      ? const _Palette(
          bg: Color(0xFF070B09),
          card: Color(0xFF0E1612),
          cardInner: Color(0xFF15221B),
          ink: Color(0xFFEDF3EF),
          inkMuted: Color(0xFF88A093),
          cardBorder: Color(0x2AD4A017),
          subBg: Color(0xFF0A120E),
          accentGlow: Color(0x22D4A017),
        )
      : const _Palette(
          bg: Color(0xFFF8F9FA),
          card: Colors.white,
          cardInner: Color(0xFFF9FBFA),
          ink: Color(0xFF111827),
          inkMuted: Color(0xFF64748B),
          cardBorder: Color(0xFFE2E8F0),
          subBg: Color(0xFFF1F5F9),
          accentGlow: Color(0x150F3E2E),
        );
}

class NotificationHistoryView extends StatelessWidget {
  const NotificationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationInboxController.to;
    final dark = ThemeController.to.isDark.value;
    final p = _Palette.of(dark);

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.ink, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: p.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox.shrink();
            final unread = controller.unreadCount;
            return TextButton.icon(
              onPressed: () {
                controller.markAllAsRead();
                Get.snackbar(
                  'Marked as Read',
                  'All notifications marked as read',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: _emerald,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              icon: Icon(
                unread > 0 ? Icons.done_all_rounded : Icons.check_rounded,
                size: 16,
                color: _gold,
              ),
              label: Text(
                unread > 0 ? 'Read all ($unread)' : 'All read',
                style: const TextStyle(
                  color: _gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Category Filters (Without Personal) ──
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _filterPill('all', 'All Alerts', Icons.notifications_active_outlined, controller, p),
                const SizedBox(width: 8),
                _filterPill('rates', 'Rates & Market', Icons.trending_up_rounded, controller, p),
                const SizedBox(width: 8),
                _filterPill('offers', 'Offers & Rewards', Icons.card_giftcard_rounded, controller, p),
                const SizedBox(width: 8),
                _filterPill('orders', 'SIP & Orders', Icons.shopping_bag_outlined, controller, p),
              ],
            ),
          ),

          // ── Notification List ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: _gold, strokeWidth: 2.5),
                );
              }

              final list = controller.filteredNotifications;

              if (list.isEmpty) {
                return _buildEmptyState(p);
              }

              return RefreshIndicator(
                color: _gold,
                backgroundColor: p.card,
                onRefresh: controller.fetchNotifications,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  itemCount: list.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) {
                    final notif = list[idx];
                    return _NotificationCard(
                      notification: notif,
                      p: p,
                      onTap: () => controller.handleNotificationTap(notif),
                      onDismissed: () => controller.removeNotification(notif.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterPill(
    String key,
    String label,
    IconData icon,
    NotificationInboxController controller,
    _Palette p,
  ) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == key;
      return GestureDetector(
        onTap: () => controller.selectedFilter.value = key,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _gold : p.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _gold : p.cardBorder,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? const Color(0xFF1A1200) : p.inkMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1A1200) : p.ink,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(_Palette p) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _gold.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: _gold,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "You're All Caught Up!",
              style: TextStyle(
                color: p.ink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No new notifications right now. Check back later for live bullion rate alerts, offers, and SIP updates.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.inkMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationModel notification;
  final _Palette p;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _NotificationCard({
    required this.notification,
    required this.p,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final hasImage = notification.imageUrl != null && notification.imageUrl!.isNotEmpty;

    return Dismissible(
      key: Key('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isUnread ? p.card : p.card.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? _gold.withValues(alpha: 0.4) : p.cardBorder,
              width: isUnread ? 1.4 : 1.0,
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    notification.imageUrl!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Icon Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _getIconBg(notification.deepLink),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getIconColor(notification.deepLink).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _getIcon(notification.deepLink),
                        color: _getIconColor(notification.deepLink),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    color: p.ink,
                                    fontSize: 14,
                                    fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: _gold,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: TextStyle(
                              color: isUnread ? p.ink.withValues(alpha: 0.85) : p.inkMuted,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(notification.createdAt),
                                style: TextStyle(
                                  color: p.inkMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (notification.deepLink.isNotEmpty)
                                Row(
                                  children: [
                                    Text(
                                      _getActionText(notification.deepLink),
                                      style: const TextStyle(
                                        color: _gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: _gold,
                                      size: 14,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String deepLink) {
    switch (deepLink.toLowerCase()) {
      case 'buy_gold':
      case 'silver':
      case 'copper':
        return Icons.trending_up_rounded;
      case 'rewards':
      case 'schemes':
        return Icons.card_giftcard_rounded;
      case 'sip':
        return Icons.event_repeat_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'kyc':
        return Icons.verified_user_rounded;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getIconBg(String deepLink) {
    switch (deepLink.toLowerCase()) {
      case 'buy_gold':
      case 'sip':
        return _gold.withValues(alpha: 0.15);
      case 'rewards':
        return _emerald.withValues(alpha: 0.15);
      case 'wallet':
        return const Color(0xFF3B82F6).withValues(alpha: 0.15);
      default:
        return _gold.withValues(alpha: 0.12);
    }
  }

  Color _getIconColor(String deepLink) {
    switch (deepLink.toLowerCase()) {
      case 'buy_gold':
      case 'sip':
        return _gold;
      case 'rewards':
        return _emerald;
      case 'wallet':
        return const Color(0xFF3B82F6);
      default:
        return _gold;
    }
  }

  String _getActionText(String deepLink) {
    switch (deepLink.toLowerCase()) {
      case 'buy_gold':
        return 'View Bullion';
      case 'rewards':
        return 'Claim Reward';
      case 'schemes':
        return 'View Scheme';
      case 'sip':
        return 'Manage SIP';
      case 'wallet':
        return 'Check Wallet';
      case 'kyc':
        return 'Complete KYC';
      default:
        return 'View Details';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
