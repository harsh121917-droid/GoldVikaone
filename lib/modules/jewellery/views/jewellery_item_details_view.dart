import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../digi_gold/controllers/digi_gold_controller.dart';
import '../../silver/controllers/silver_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../controllers/jewellery_controller.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD54F);
const _emerald = Color(0xFF10B981);

class _Palette {
  final Color bg, card, cardInner, primary, ink, inkMuted, cardBorder, subBg, chipBg, accentGlow;
  const _Palette({
    required this.bg,
    required this.card,
    required this.cardInner,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.chipBg,
    required this.accentGlow,
  });

  factory _Palette.of(bool dark) => dark
      ? const _Palette(
          bg: Color(0xFF09090C),
          card: Color(0xFF13131A),
          cardInner: Color(0xFF1B1B24),
          primary: _gold,
          ink: Color(0xFFF9FAFB),
          inkMuted: Color(0xFF9CA3AF),
          cardBorder: Color(0x33D4A017),
          subBg: Color(0xFF181822),
          chipBg: Color(0x1AD4A017),
          accentGlow: Color(0x29D4A017),
        )
      : const _Palette(
          bg: Color(0xFFF7F8FA),
          card: Colors.white,
          cardInner: Color(0xFFF8FAFC),
          primary: Color(0xFF0F3E2E),
          ink: Color(0xFF111827),
          inkMuted: Color(0xFF64748B),
          cardBorder: Color(0xFFE2E8F0),
          subBg: Color(0xFFF1F5F9),
          chipBg: Color(0xFFF0FDF4),
          accentGlow: Color(0x150F3E2E),
        );
}

class JewelleryItemDetailsView extends StatelessWidget {
  final Map<String, dynamic> item;

  const JewelleryItemDetailsView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = JewelleryController.to;
    final dark = ThemeController.to.isDark.value;
    final p = _Palette.of(dark);

    final metalType = (item['metalType'] ?? 'gold').toString().toLowerCase();
    final isGold = metalType == 'gold';
    final weightGrams = (item['weightGrams'] ?? 0.0) is num
        ? (item['weightGrams'] as num).toDouble()
        : double.tryParse(item['weightGrams'].toString()) ?? 0.0;
    final makingCharges = (item['makingCharges'] ?? 1500) is num
        ? (item['makingCharges'] as num).toDouble()
        : 1500.0;
    final gstPct = (item['gstPercentage'] ?? 3) is num
        ? (item['gstPercentage'] as num).toDouble()
        : 3.0;

    // Live metal rate and user's vault balance
    double liveRatePerGram = isGold ? 7500.0 : 90.0;
    double vaultGrams = 0.0;

    if (isGold) {
      if (Get.isRegistered<GoldController>()) {
        liveRatePerGram = GoldController.to.buyRate;
        vaultGrams = GoldController.to.totalGrams;
      }
    } else {
      if (Get.isRegistered<SilverController>()) {
        liveRatePerGram = SilverController.to.buyRate;
        vaultGrams = SilverController.to.totalGrams;
      }
    }

    final hasAnyVault = vaultGrams > 0.0001;

    // Observables
    final applyVault = (hasAnyVault).obs;
    final selectedPaymentMethod = 'razorpay'.obs;
    final isFavorite = false.obs;

    return Scaffold(
      backgroundColor: p.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 1. Luxury Collapsible Hero Sliver App Bar ──
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: p.bg,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ),
            actions: [
              // Wishlist Heart Icon
              Obx(() => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        isFavorite.value = !isFavorite.value;
                        Get.snackbar(
                          isFavorite.value ? 'Added to Wishlist ❤️' : 'Removed from Wishlist',
                          item['name'] ?? 'Jewellery item',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: p.card,
                          colorText: p.ink,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          isFavorite.value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite.value ? Colors.redAccent : Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  )),
              // Share Button
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Share Item',
                      'Sharing "${item['name']}"',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: p.card,
                      colorText: p.ink,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroGalleryShowcase(
                images: _extractImages(item),
                metalType: metalType,
                purity: (item['purity'] ?? (isGold ? '24K Gold (999)' : '999 Fine Silver')).toString(),
                p: p,
              ),
            ),
          ),

          // ── 2. Main Body Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Category Tag & Live Stock Status ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _gold.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isGold ? Icons.diamond_outlined : Icons.circle_outlined,
                              size: 13,
                              color: _gold,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              (item['category'] ?? 'Jewellery').toString().toUpperCase(),
                              style: const TextStyle(
                                color: _gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (item['inStock'] == false ? Colors.red : _emerald).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (item['inStock'] == false ? Colors.red : _emerald).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: item['inStock'] == false ? Colors.red : _emerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item['inStock'] == false ? 'Out of Stock' : 'In Stock • Ready to Dispatch',
                              style: TextStyle(
                                color: item['inStock'] == false ? Colors.red : _emerald,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Product Title & Live Rate Pill ──
                  Text(
                    (item['name'] ?? '').toString(),
                    style: TextStyle(
                      color: p.ink,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DM Serif Display',
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Live Rate Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.cardInner,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: p.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.show_chart_rounded, color: _gold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Live MCX ${metalType.toUpperCase()} Rate: ',
                          style: TextStyle(color: p.inkMuted, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${liveRatePerGram.toStringAsFixed(2)} / g',
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    (item['description'] ??
                            'Handcrafted certified hallmarked pure bullion with tamper-proof security packaging. Guaranteed 100% purity with lifetime buyback.')
                        .toString(),
                    style: TextStyle(color: p.inkMuted, fontSize: 13, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  // ── 3. Metal Specs & Certification Grid ──
                  _buildSpecsMatrix(item, isGold, weightGrams, p),

                  const SizedBox(height: 20),

                  // ── 4. Interactive Digital Vault Deduction Card ──
                  _buildVaultDeductionCard(
                    applyVault: applyVault,
                    hasAnyVault: hasAnyVault,
                    vaultGrams: vaultGrams,
                    weightGrams: weightGrams,
                    liveRate: liveRatePerGram,
                    metalType: metalType,
                    p: p,
                    dark: dark,
                  ),

                  const SizedBox(height: 20),

                  // ── 5. Transparent Live Price Breakdown Invoice ──
                  _buildPriceBreakdownCard(
                    applyVault: applyVault,
                    hasAnyVault: hasAnyVault,
                    weightGrams: weightGrams,
                    vaultGrams: vaultGrams,
                    liveRate: liveRatePerGram,
                    makingCharges: makingCharges,
                    gstPct: gstPct,
                    p: p,
                    dark: dark,
                  ),

                  const SizedBox(height: 20),

                  // ── 6. Purity, Insurance & Buyback Assurance Tiles ──
                  _buildAssuranceRow(p),

                  const SizedBox(height: 20),

                  // ── 7. Payment Gateway & Wallet Selector ──
                  _buildPaymentMethodSection(selectedPaymentMethod, p),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── 8. Luxury Floating Bottom Checkout Bar ──
      bottomNavigationBar: _buildBottomBar(
        controller: controller,
        item: item,
        applyVault: applyVault,
        hasAnyVault: hasAnyVault,
        weightGrams: weightGrams,
        vaultGrams: vaultGrams,
        liveRate: liveRatePerGram,
        makingCharges: makingCharges,
        gstPct: gstPct,
        selectedPaymentMethod: selectedPaymentMethod,
        p: p,
        dark: dark,
      ),
    );
  }

  // ── Spec Grid Builder ──
  Widget _buildSpecsMatrix(Map<String, dynamic> item, bool isGold, double weight, _Palette p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, color: _gold, size: 16),
              SizedBox(width: 6),
              Text(
                'Product Specifications',
                style: TextStyle(
                  color: _gold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _specTile(
                Icons.scale_rounded,
                'Net Weight',
                '${weight.toStringAsFixed(3)} g',
                p,
              ),
              const SizedBox(width: 8),
              _specTile(
                Icons.verified_rounded,
                'Purity',
                (item['purity'] ?? (isGold ? '22K Gold' : '999 Silver')).toString(),
                p,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _specTile(
                Icons.qr_code_2_rounded,
                'Item SKU',
                (item['sku'] ?? 'VIKA-JWL-${(item['_id'] ?? '001').toString().substring(max(0, (item['_id'] ?? '001').toString().length - 4)).toUpperCase()}').toString(),
                p,
              ),
              const SizedBox(width: 8),
              _specTile(
                Icons.shield_outlined,
                'Hallmark',
                'BIS 100% Certified',
                p,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specTile(IconData icon, String label, String value, _Palette p) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: p.cardInner,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _gold),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: p.inkMuted, fontSize: 10.5)),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: p.ink, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Digital Vault Deduction Card ──
  Widget _buildVaultDeductionCard({
    required RxBool applyVault,
    required bool hasAnyVault,
    required double vaultGrams,
    required double weightGrams,
    required double liveRate,
    required String metalType,
    required _Palette p,
    required bool dark,
  }) {
    return Obx(() {
      final isApplying = applyVault.value && hasAnyVault;
      final usedGrams = isApplying ? min(vaultGrams, weightGrams) : 0.0;
      final vaultDiscountVal = usedGrams * liveRate;
      final isFullCovered = usedGrams >= weightGrams;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isApplying
                ? (dark
                    ? [const Color(0xFF062316), const Color(0xFF0F3B27)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)])
                : (dark
                    ? [const Color(0xFF13131A), const Color(0xFF1A1A24)]
                    : [Colors.white, const Color(0xFFF8FAFC)]),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isApplying
                ? _emerald.withValues(alpha: 0.7)
                : p.cardBorder,
            width: isApplying ? 1.8 : 1.0,
          ),
          boxShadow: isApplying
              ? [
                  BoxShadow(
                    color: _emerald.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isApplying
                            ? _emerald.withValues(alpha: 0.2)
                            : _gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: isApplying ? _emerald : _gold,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My ${metalType.toUpperCase()} Vault Savings',
                          style: TextStyle(
                            color: p.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vaultGrams.toStringAsFixed(3)} g available (Worth ₹${(vaultGrams * liveRate).toStringAsFixed(0)})',
                          style: TextStyle(
                            color: isApplying ? _emerald : p.inkMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (hasAnyVault)
                  Switch.adaptive(
                    value: applyVault.value,
                    activeTrackColor: _emerald,
                    onChanged: (val) => applyVault.value = val,
                  ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            if (!hasAnyVault)
              Text(
                'You currently have 0.000g in your vault. You can purchase this item directly using UPI / Card / Wallet.',
                style: TextStyle(color: p.inkMuted, fontSize: 12, height: 1.35),
              )
            else if (isApplying)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: _emerald.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _emerald.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: _emerald, size: 17),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isFullCovered
                            ? '✨ 100% Pure Metal (${usedGrams.toStringAsFixed(3)}g) deducted from your vault! You only pay making charges & GST.'
                            : '✨ ${usedGrams.toStringAsFixed(3)}g deducted from vault (Saved ₹${vaultDiscountVal.toStringAsFixed(0)}!). Pay the remaining metal in cash.',
                        style: const TextStyle(
                          color: _emerald,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Text(
                '💡 Turn ON the switch above to deduct your ${vaultGrams.toStringAsFixed(3)}g vault gold and reduce your cash payment.',
                style: TextStyle(color: p.inkMuted, fontSize: 12, height: 1.35),
              ),
          ],
        ),
      );
    });
  }

  // ── Price Breakdown Card ──
  Widget _buildPriceBreakdownCard({
    required RxBool applyVault,
    required bool hasAnyVault,
    required double weightGrams,
    required double vaultGrams,
    required double liveRate,
    required double makingCharges,
    required double gstPct,
    required _Palette p,
    required bool dark,
  }) {
    return Obx(() {
      final isApplying = applyVault.value && hasAnyVault;
      final metalValue = weightGrams * liveRate;
      final usedGrams = isApplying ? min(vaultGrams, weightGrams) : 0.0;
      final vaultDiscountVal = usedGrams * liveRate;

      final remainingGrams = max(0.0, weightGrams - usedGrams);
      final remainingMetalValue = remainingGrams * liveRate;

      final taxableCash = remainingMetalValue + makingCharges;
      final gstAmount = (taxableCash * gstPct) / 100;
      final netCashPayable = taxableCash + gstAmount;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.3 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.receipt_long_rounded, size: 18, color: _gold),
                    SizedBox(width: 8),
                    Text(
                      'Price Breakdown',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'DM Serif Display',
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApplying ? _emerald.withValues(alpha: 0.15) : _gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isApplying ? 'Vault Applied' : 'Direct Buy',
                    style: TextStyle(
                      color: isApplying ? _emerald : _gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _rowItem('Total Item Metal Weight', '${weightGrams.toStringAsFixed(3)} g', p),
            _rowItem('Today Live Metal Rate', '₹${liveRate.toStringAsFixed(2)} / g', p),
            _rowItem('Gross Pure Metal Value', '₹${metalValue.toStringAsFixed(0)}', p),

            if (isApplying && usedGrams > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, size: 14, color: _emerald),
                        const SizedBox(width: 4),
                        Text(
                          'Minus Vault Gold (${usedGrams.toStringAsFixed(3)}g)',
                          style: const TextStyle(
                            color: _emerald,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-₹${vaultDiscountVal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _emerald,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (remainingGrams > 0)
                _rowItem(
                  'Remaining Metal to Pay in Cash (${remainingGrams.toStringAsFixed(3)}g)',
                  '₹${remainingMetalValue.toStringAsFixed(0)}',
                  p,
                  highlight: true,
                ),
            ],

            _rowItem('Making & Artistry Charges', '₹${makingCharges.toStringAsFixed(0)}', p),
            _rowItem('GST (${gstPct.toStringAsFixed(0)}% on Cash Amount)', '₹${gstAmount.toStringAsFixed(0)}', p),

            const SizedBox(height: 16),

            // Grand Total Highlight Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isApplying
                      ? [const Color(0xFF0F3B27), const Color(0xFF062316)]
                      : [const Color(0xFF241E0D), const Color(0xFF161205)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isApplying ? _emerald.withValues(alpha: 0.5) : _gold.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isApplying ? 'Net Cash Amount to Pay' : 'Total Amount to Pay',
                        style: TextStyle(
                          color: isApplying ? const Color(0xFFA7F3D0) : _goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isApplying
                            ? 'Deducts ${usedGrams.toStringAsFixed(3)}g from your vault'
                            : 'All metal, making & taxes included',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹${netCashPayable.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isApplying ? const Color(0xFFA7F3D0) : _goldLight,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'DM Serif Display',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _rowItem(String label, String value, _Palette p, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: p.inkMuted, fontSize: 12.5)),
          Text(
            value,
            style: TextStyle(
              color: highlight ? _gold : p.ink,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Assurance Icons Row ──
  Widget _buildAssuranceRow(_Palette p) {
    return Row(
      children: [
        _trustTile(Icons.verified_rounded, '100% BIS Hallmarked', p),
        const SizedBox(width: 8),
        _trustTile(Icons.local_shipping_rounded, 'Insured Express Delivery', p),
        const SizedBox(width: 8),
        _trustTile(Icons.published_with_changes_rounded, 'Lifetime 100% Buyback', p),
      ],
    );
  }

  Widget _trustTile(IconData icon, String title, _Palette p) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: p.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: _gold, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.inkMuted, fontSize: 10, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── Payment Method Selection ──
  Widget _buildPaymentMethodSection(RxString selectedPaymentMethod, _Palette p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Payment Option',
                style: TextStyle(
                  color: p.ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (Get.isRegistered<WalletController>())
                Obx(() {
                  final bal = WalletController.to.wallet.value?.balance ?? 0.0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Wallet: ₹${bal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
            ],
          ),
          const SizedBox(height: 12),

          // Razorpay (UPI, GPay, PhonePe, Cards, NetBanking)
          Obx(() {
            final isRzp = selectedPaymentMethod.value == 'razorpay';
            return GestureDetector(
              onTap: () => selectedPaymentMethod.value = 'razorpay',
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isRzp ? _gold.withValues(alpha: 0.12) : p.subBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isRzp ? _gold : p.cardBorder,
                    width: isRzp ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRzp ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isRzp ? _gold : p.inkMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPI / Cards / NetBanking (Razorpay)',
                            style: TextStyle(
                              color: p.ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'GPay, PhonePe, Paytm, Credit/Debit Card, NetBanking',
                            style: TextStyle(color: p.inkMuted, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.shield_outlined, size: 16, color: _gold),
                  ],
                ),
              ),
            );
          }),

          // Payvika In-App Wallet
          Obx(() {
            final isWallet = selectedPaymentMethod.value == 'wallet';
            return GestureDetector(
              onTap: () => selectedPaymentMethod.value = 'wallet',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWallet ? _gold.withValues(alpha: 0.12) : p.subBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isWallet ? _gold : p.cardBorder,
                    width: isWallet ? 1.6 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isWallet ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isWallet ? _gold : p.inkMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payvika In-App Wallet',
                            style: TextStyle(
                              color: p.ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Instant 1-tap checkout deducted from your wallet',
                            style: TextStyle(color: p.inkMuted, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.account_balance_wallet_outlined, size: 16, color: _gold),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Bottom Sticky Bar ──
  Widget _buildBottomBar({
    required JewelleryController controller,
    required Map<String, dynamic> item,
    required RxBool applyVault,
    required bool hasAnyVault,
    required double weightGrams,
    required double vaultGrams,
    required double liveRate,
    required double makingCharges,
    required double gstPct,
    required RxString selectedPaymentMethod,
    required _Palette p,
    required bool dark,
  }) {
    return Obx(() {
      final isApplying = applyVault.value && hasAnyVault;
      final usedGrams = isApplying ? min(vaultGrams, weightGrams) : 0.0;
      final remainingGrams = max(0.0, weightGrams - usedGrams);
      final remainingMetalValue = remainingGrams * liveRate;

      final taxableCash = remainingMetalValue + makingCharges;
      final gstAmount = (taxableCash * gstPct) / 100;
      final netCashPayable = taxableCash + gstAmount;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(color: p.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.45 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isApplying && usedGrams > 0 ? 'Cash to Pay' : 'Total Payable',
                    style: TextStyle(color: p.inkMuted, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${netCashPayable.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isApplying ? _emerald : _gold,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'DM Serif Display',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isApplying
                          ? [const Color(0xFF10B981), const Color(0xFF047857)]
                          : [const Color(0xFFE5B020), const Color(0xFFC48F0A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isApplying ? _emerald : _gold).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: controller.isRedeeming.value
                        ? null
                        : () {
                            controller.redeemItem(
                              item,
                              paymentMethod: selectedPaymentMethod.value,
                              useVault: isApplying,
                              vaultGramsToUse: usedGrams,
                              purchaseType: isApplying
                                  ? (usedGrams >= weightGrams ? 'vault_redeem' : 'hybrid')
                                  : 'direct_buy',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: controller.isRedeeming.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isApplying && usedGrams > 0
                                    ? 'Pay ₹${netCashPayable.toStringAsFixed(0)} & Order'
                                    : 'Buy Now • ₹${netCashPayable.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 17, color: Colors.white),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<String> _extractImages(Map<String, dynamic> item) {
    final List<String> list = [];
    final Set<String> seen = {};

    final primary = item['imageUrl']?.toString().trim() ?? '';
    if (primary.isNotEmpty && (primary.startsWith('http') || primary.startsWith('data:'))) {
      list.add(primary);
      seen.add(primary);
    }

    if (item['images'] is List && (item['images'] as List).isNotEmpty) {
      for (final img in item['images'] as List) {
        final s = img?.toString().trim();
        if (s != null && s.isNotEmpty && (s.startsWith('http') || s.startsWith('data:')) && !seen.contains(s)) {
          list.add(s);
          seen.add(s);
        }
      }
    }

    final fallbackImg = item['image']?.toString().trim() ?? '';
    if (fallbackImg.isNotEmpty && (fallbackImg.startsWith('http') || fallbackImg.startsWith('data:')) && !seen.contains(fallbackImg)) {
      list.add(fallbackImg);
      seen.add(fallbackImg);
    }

    return list;
  }
}

// ─── Luxury Hero Gallery with Smooth Carousel ────────────────────────────────
class _HeroGalleryShowcase extends StatefulWidget {
  final List<String> images;
  final String metalType;
  final String purity;
  final _Palette p;

  const _HeroGalleryShowcase({
    required this.images,
    required this.metalType,
    required this.purity,
    required this.p,
  });

  @override
  State<_HeroGalleryShowcase> createState() => _HeroGalleryShowcaseState();
}

class _HeroGalleryShowcaseState extends State<_HeroGalleryShowcase> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final images = widget.images;

    return Container(
      width: double.infinity,
      color: p.subBg,
      child: Stack(
        children: [
          // Background subtle radiant glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    _gold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Swiper / Image Viewer
          if (images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemBuilder: (ctx, idx) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(28, 48, 28, 40),
                  child: Center(
                    child: Hero(
                      tag: 'jewel_${images[idx]}',
                      child: Image.network(
                        images[idx],
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2.5,
                              color: _gold,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Icon(
                          widget.metalType == 'gold' ? Icons.diamond_outlined : Icons.circle_outlined,
                          size: 110,
                          color: _gold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Icon(
                widget.metalType == 'gold' ? Icons.diamond_outlined : Icons.circle_outlined,
                size: 110,
                color: _gold,
              ),
            ),

          // Purity Pill Top Left
          Positioned(
            top: 56,
            left: 56,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _gold.withValues(alpha: 0.6), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, size: 13, color: _gold),
                  const SizedBox(width: 5),
                  Text(
                    widget.purity,
                    style: const TextStyle(
                      color: _gold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Metal Pill Top Right
          Positioned(
            top: 56,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.metalType == 'silver'
                    ? Colors.blueGrey.withValues(alpha: 0.4)
                    : Colors.amber.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                widget.metalType.toUpperCase(),
                style: TextStyle(
                  color: widget.metalType == 'silver' ? Colors.white : Colors.amber,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Page Indicator & Dots (if multi-image)
          if (images.length > 1) ...[
            // Counter Pill
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '${_currentPage + 1} / ${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Dots
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (idx) {
                  final active = idx == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? _gold : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
