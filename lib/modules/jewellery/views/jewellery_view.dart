import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../digi_gold/controllers/digi_gold_controller.dart';
import '../../silver/controllers/silver_controller.dart';
import '../controllers/jewellery_controller.dart';
import 'jewellery_item_details_view.dart';

const _gold = Color(0xFFD4A017);

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder, subBg, ctaText;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.ctaText,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF0A0A0C),
          card: Color(0xFF16161B),
          primary: _gold,
          ink: Color(0xFFF5F5F5),
          inkMuted: Color(0xFF8A8A93),
          cardBorder: Color(0x2ED4A017),
          subBg: Color(0xFF1C1C22),
          ctaText: Color(0xFF3D2B00),
        )
      : const _T(
          bg: Color(0xFFF8F9FA),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Color(0xFFE5E7EB),
          subBg: Color(0xFFF3F4F6),
          ctaText: Colors.white,
        );
}

class JewelleryView extends StatelessWidget {
  const JewelleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = JewelleryController.to;

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      final goldGrams = Get.isRegistered<GoldController>()
          ? GoldController.to.totalGrams
          : 0.0;
      final silverGrams = Get.isRegistered<SilverController>()
          ? SilverController.to.totalGrams
          : 0.0;

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.bg,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Payvika Jewellery',
            style: TextStyle(
              color: t.ink,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Serif Display',
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: t.ink),
              onPressed: () => controller.loadAll(),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Metal Vault Balance Banner ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dark
                      ? [const Color(0xFF042116), const Color(0xFF132F23)]
                      : [const Color(0xFFF4F7F4), const Color(0xFFE2EBE5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.cardBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.savings_outlined, color: _gold, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'My Metal Savings',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${goldGrams.toStringAsFixed(3)} g Gold',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '|',
                              style: TextStyle(color: t.inkMuted),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${silverGrams.toStringAsFixed(2)} g Silver',
                              style: TextStyle(
                                color: t.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Redeem your accumulated gold & silver into certified hallmarked jewellery.',
                          style: TextStyle(
                            color: t.inkMuted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha:0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_outlined, color: _gold, size: 24),
                  ),
                ],
              ),
            ),

            // ── Search & Filter Controls ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        onChanged: (val) => controller.setSearch(val),
                        style: TextStyle(color: t.ink, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search jewellery...',
                          hintStyle: TextStyle(color: t.inkMuted, fontSize: 12.5),
                          prefixIcon: Icon(Icons.search, color: t.inkMuted, size: 18),
                          filled: true,
                          fillColor: t.card,
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: t.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _gold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Metal Filter Dropdown
                  PopupMenuButton<String>(
                    initialValue: controller.selectedMetal.value,
                    onSelected: (val) => controller.selectMetal(val),
                    color: t.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded, color: t.ink, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            controller.selectedMetal.value.toUpperCase(),
                            style: TextStyle(color: t.ink, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'all', child: Text('All Metals')),
                      const PopupMenuItem(value: 'gold', child: Text('Gold Only')),
                      const PopupMenuItem(value: 'silver', child: Text('Silver Only')),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // Sort Menu
                  PopupMenuButton<String>(
                    initialValue: controller.selectedSort.value,
                    onSelected: (val) => controller.setSort(val),
                    color: t.card,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: t.cardBorder),
                      ),
                      child: Icon(Icons.sort_rounded, color: t.ink, size: 18),
                    ),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'popular', child: Text('Most Popular')),
                      const PopupMenuItem(value: 'price_low_high', child: Text('Price: Low to High')),
                      const PopupMenuItem(value: 'price_high_low', child: Text('Price: High to Low')),
                      const PopupMenuItem(value: 'weight_low_high', child: Text('Weight: Low to High')),
                      const PopupMenuItem(value: 'weight_high_low', child: Text('Weight: High to Low')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Categories Horizontal Bar ──
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.categories.length + 1,
                itemBuilder: (context, index) {
                  final catName = index == 0
                      ? 'All'
                      : (controller.categories[index - 1]['name'] ?? 'All').toString();
                  final isSelected = controller.selectedCategory.value == catName;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.selectCategory(catName);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? t.primary : t.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? t.primary : t.cardBorder,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          catName,
                          style: TextStyle(
                            color: isSelected ? t.ctaText : t.ink,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Product Grid ──
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator(color: _gold))
                  : controller.products.isEmpty
                      ? Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(color: t.inkMuted),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) {
                            final p = controller.products[index];
                            final price = controller.calculateProductPrice(p);
                            final purity = (p['purity'] ?? '22K Gold').toString();
                            final weight = '${p['weightGrams'] ?? 0} g';
                            final making = (p['makingCharges'] ?? 1500).toString();
                            final isGold = (p['metalType'] ?? 'gold').toString().toLowerCase() == 'gold';

                            // Resolve Main / Primary Image with full fallback hierarchy
                            String imageUrl = (p['imageUrl']?.toString() ?? '').trim();
                            if (imageUrl.isEmpty && p['images'] is List && (p['images'] as List).isNotEmpty) {
                              for (final img in p['images'] as List) {
                                final s = img?.toString().trim() ?? '';
                                if (s.isNotEmpty) {
                                  imageUrl = s;
                                  break;
                                }
                              }
                            }
                            if (imageUrl.isEmpty) {
                              imageUrl = (p['image']?.toString() ?? '').trim();
                            }

                            return GestureDetector(
                              onTap: () => Get.to(() => JewelleryItemDetailsView(item: p)),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: t.card,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: t.cardBorder, width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:dark ? 0.2 : 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image / Icon Box — Center-aligned, original aspect ratio (never stretched/cropped)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: t.subBg,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: imageUrl.isNotEmpty && (imageUrl.startsWith('http') || imageUrl.startsWith('data:'))
                                                      ? ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.contain,
                                                            alignment: Alignment.center,
                                                            loadingBuilder: (context, child, progress) {
                                                              if (progress == null) return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value: progress.expectedTotalBytes != null
                                                                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                                                      : null,
                                                                  strokeWidth: 2,
                                                                  color: _gold,
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder: (context, error, stackTrace) => Icon(
                                                              isGold ? Icons.diamond_outlined : Icons.circle_outlined,
                                                              size: 42,
                                                              color: _gold,
                                                            ),
                                                          ),
                                                        )
                                                      : Icon(
                                                          isGold ? Icons.diamond_outlined : Icons.circle_outlined,
                                                          size: 42,
                                                          color: _gold,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 6,
                                              left: 6,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _gold.withValues(alpha:0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: _gold.withValues(alpha:0.5), width: 0.5),
                                                ),
                                                child: Text(
                                                  purity,
                                                  style: const TextStyle(
                                                    color: _gold,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Item Info
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (p['name'] ?? '').toString(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: t.ink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                weight,
                                                style: TextStyle(
                                                  color: t.inkMuted,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                'Making: ₹$making',
                                                style: TextStyle(
                                                  color: t.inkMuted,
                                                  fontSize: 9.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '₹${price.toStringAsFixed(0)}',
                                                style: TextStyle(
                                                  color: t.ink,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13.5,
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Get.to(() => JewelleryItemDetailsView(item: p)),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: t.primary,
                                                  foregroundColor: t.ctaText,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Redeem',
                                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      );
    });
  }
}
