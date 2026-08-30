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
          bg: Color(0xFF09090C),
          card: Color(0xFF13131A),
          cardInner: Color(0xFF1C1C26),
          ink: Color(0xFFF9FAFB),
          inkMuted: Color(0xFF9CA3AF),
          cardBorder: Color(0x33D4A017),
          subBg: Color(0xFF181822),
          accentGlow: Color(0x22D4A017),
        )
      : const _Palette(
          bg: Color(0xFFF7F8FA),
          card: Colors.white,
          cardInner: Color(0xFFF8FAFC),
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
    final controller = Get.put(NotificationInboxController());
    final dark = ThemeController.to.isDark.value;
    final p = _Palette.of(dark);

    return Scaffold(
      backgroundColor: p.bg,
      appBar: AppBar(
        backgroundColor: p.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.ink, size: 19),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notification Inbox',
              style: TextStyle(
                color: p.ink,
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'DM Serif Display',
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final count = controller.unreadCount;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count NEW',
                  style: const TextStyle(
                    color: Color(0xFF1F1600),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          Obx(() {
            if (controller.notifications.isEmpty) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: controller.markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 16, color: _gold),
              label: const Text(
                'Mark Read',
                style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Pills Row ──
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('all', 'All Alerts', Icons.inbox_rounded, controller, p),
                const SizedBox(width: 8),
                _filterChip('personal', 'Personal & Account', Icons.person_outline_rounded, controller, p),
                const SizedBox(width: 8),
                _filterChip('offers', 'Offers & Rewards', Icons.card_giftcard_rounded, controller, p),
                const SizedBox(width: 8),
                _filterChip('market', 'Rates & Bullion', Icons.trending_up_rounded, controller, p),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // ── Notifications List with Refresh Indicator ──
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return Center(
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
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
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

  Widget _filterChip(
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
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? const Color(0xFF1F1600) : p.inkMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF1F1600) : p.ink,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _gold.withValues(alpha: 0.3)),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 44,
                  color: _gold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'All Caught Up!',
                style: TextStyle(
                  color: p.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'DM Serif Display',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have any notifications right now.\nCheck back later for live gold rates, offers and personal account updates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.inkMuted, fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Single Notification Item Card with Swipe-to-Dismiss ──────────────────────
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
    final hasImage = notification.imageUrl != null && notification.imageUrl!.isNotEmpty;
    final isUnread = !notification.isRead;
    final isPersonal = notification.targetType == 'user';

    return Dismissible(
      key: Key('notif_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? _gold.withValues(alpha: 0.6) : p.cardBorder,
              width: isUnread ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? _gold.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Optional Full Banner Image ──
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 8,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            notification.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: p.cardInner,
                                child: const Center(
                                  child: CircularProgressIndicator(color: _gold, strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (ctx, err, stack) => Container(
                              color: p.cardInner,
                              child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 36),
                            ),
                          ),
                        ),
                        // Gradient Overlay on Image Bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Notification Text & Details ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Avatar with Category Tint
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: _getIconBg(notification.deepLink),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getIconColor(notification.deepLink).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        _getIcon(notification.deepLink),
                        size: 18,
                        color: _getIconColor(notification.deepLink),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title, Body, Timestamp & Deep Link
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
                                    fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isPersonal)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _emerald.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'PERSONAL',
                                    style: TextStyle(
                                      color: _emerald,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
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
                              color: p.inkMuted,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(notification.createdAt),
                                style: TextStyle(
                                  color: p.inkMuted.withValues(alpha: 0.75),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    _getActionText(notification.deepLink),
                                    style: const TextStyle(
                                      color: _gold,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_forward_rounded, size: 12, color: _gold),
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

  IconData _getIcon(String link) {
    switch (link.toLowerCase()) {
      case 'buy_gold':
        return Icons.monetization_on_outlined;
      case 'jewellery':
        return Icons.diamond_outlined;
      case 'schemes':
        return Icons.savings_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'rewards':
        return Icons.card_giftcard_outlined;
      case 'kyc':
        return Icons.verified_user_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getIconColor(String link) {
    switch (link.toLowerCase()) {
      case 'rewards':
        return Colors.purpleAccent;
      case 'wallet':
      case 'kyc':
        return _emerald;
      default:
        return _gold;
    }
  }

  Color _getIconBg(String link) {
    return _getIconColor(link).withValues(alpha: 0.12);
  }

  String _getActionText(String link) {
    switch (link.toLowerCase()) {
      case 'buy_gold':
        return 'Buy Gold';
      case 'jewellery':
        return 'View Catalogue';
      case 'schemes':
        return 'Explore Schemes';
      case 'wallet':
        return 'Open Wallet';
      case 'rewards':
        return 'Claim Reward';
      case 'kyc':
        return 'Verify KYC';
      default:
        return 'View Details';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[dt.month - 1];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $m, $h:$min $ampm';
  }
}
