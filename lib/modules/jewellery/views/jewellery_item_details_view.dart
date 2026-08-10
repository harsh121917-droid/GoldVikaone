import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../digi_gold/controllers/digi_gold_controller.dart';
import '../../silver/controllers/silver_controller.dart';
import '../controllers/jewellery_controller.dart';

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

class JewelleryItemDetailsView extends StatelessWidget {
  final Map<String, dynamic> item;

  const JewelleryItemDetailsView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = JewelleryController.to;
    final dark = ThemeController.to.isDark.value;
    final t = _T.of(dark);

    final metalType = (item['metalType'] ?? 'gold').toString().toLowerCase();
    final weightGrams = (item['weightGrams'] ?? 0.0) is num
        ? (item['weightGrams'] as num).toDouble()
        : double.tryParse(item['weightGrams'].toString()) ?? 0.0;
    final makingCharges = (item['makingCharges'] ?? 1500) is num
        ? (item['makingCharges'] as num).toDouble()
        : 1500.0;
    final gstPct = (item['gstPercentage'] ?? 3) is num
        ? (item['gstPercentage'] as num).toDouble()
        : 3.0;

    double liveRatePerGram = 7500.0;
    double vaultGrams = 0.0;

    if (metalType == 'gold') {
      if (Get.isRegistered<GoldController>()) {
        liveRatePerGram = GoldController.to.buyRate;
        vaultGrams = GoldController.to.totalGrams;
      }
    } else {
      if (Get.isRegistered<SilverController>()) {
        liveRatePerGram = SilverController.to.buyRate;
        vaultGrams = SilverController.to.totalGrams;
      } else {
        liveRatePerGram = 236.0;
      }
    }

    final metalValue = weightGrams * liveRatePerGram;
    final gstAmount = (makingCharges * gstPct) / 100;
    final totalProductPrice = metalValue + makingCharges + gstAmount;
    final totalPayableNow = makingCharges + gstAmount;

    final selectedMethod = 'razorpay'.obs;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.ink, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Item Details',
          style: TextStyle(
            color: t.ink,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'DM Serif Display',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: t.ink, size: 20),
            onPressed: () {
              Get.snackbar(
                'Share Item',
                'Sharing "${item['name']}"',
                backgroundColor: t.subBg,
                colorText: t.ink,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image Showcase Box ──
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: t.subBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: t.cardBorder),
              ),
              child: Stack(
                children: [
                  Center(
                    child:
                        item['imageUrl'] != null &&
                            item['imageUrl'].toString().startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              item['imageUrl'],
                              width: double.infinity,
                              height: 300,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                                progress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      color: _gold,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    metalType == 'gold'
                                        ? Icons.diamond_outlined
                                        : Icons.circle_outlined,
                                    size: 90,
                                    color: _gold,
                                  ),
                            ),
                          )
                        : Icon(
                            metalType == 'gold'
                                ? Icons.diamond_outlined
                                : Icons.circle_outlined,
                            size: 90,
                            color: _gold,
                          ),
                  ),

                  // Purity Badge Top Left
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _gold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        (item['purity'] ?? '22K Gold').toString(),
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Metal Badge Top Right
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: metalType == 'silver'
                            ? Colors.grey.withValues(alpha: 0.25)
                            : Colors.amber.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        metalType.toUpperCase(),
                        style: TextStyle(
                          color: metalType == 'silver'
                              ? Colors.white70
                              : Colors.amber,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Item Title & Category Tag ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: t.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (item['category'] ?? 'Jewellery').toString(),
                    style: TextStyle(
                      color: t.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  item['inStock'] == false ? 'Out of Stock' : 'In Stock ✓',
                  style: TextStyle(
                    color: item['inStock'] == false ? Colors.red : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              (item['name'] ?? '').toString(),
              style: TextStyle(
                color: t.ink,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'DM Serif Display',
              ),
            ),

            const SizedBox(height: 6),

            Text(
              (item['description'] ??
                      'Certified hallmarked pure metal item handcrafted by master artisans. Certified for authenticity and purity.')
                  .toString(),
              style: TextStyle(color: t.inkMuted, fontSize: 12.5, height: 1.4),
            ),

            const SizedBox(height: 16),

            // ── Live Price Calculation Breakdown Card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: t.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Price Calculation',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: ₹${totalProductPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: t.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  _row('Pure Weight', '$weightGrams grams', t),
                  _row(
                    'Today Live Metal Rate',
                    '₹${liveRatePerGram.toStringAsFixed(2)} / g',
                    t,
                  ),
                  _row(
                    'Metal Value (Deducted from Vault)',
                    '₹${metalValue.toStringAsFixed(0)}',
                    t,
                  ),
                  _row(
                    'Making Charges',
                    '₹${makingCharges.toStringAsFixed(0)}',
                    t,
                  ),
                  _row(
                    'GST ($gstPct% on Making)',
                    '₹${gstAmount.toStringAsFixed(0)}',
                    t,
                  ),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _gold.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Payable Now for Redeem',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Making Charges + GST',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '₹${totalPayableNow.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: _gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Trust & Quality Badges ──
            Row(
              children: [
                _badgeTile(Icons.verified_outlined, '100% BIS\nHallmarked', t),
                const SizedBox(width: 8),
                _badgeTile(
                  Icons.local_shipping_outlined,
                  'Insured Express\nDelivery',
                  t,
                ),
                const SizedBox(width: 8),
                _badgeTile(
                  Icons.published_with_changes_rounded,
                  'Lifetime\nBuyback Policy',
                  t,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Vault Balance Check & Redeem Card ──
            Obx(() {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: _gold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vault Balance Check',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your $metalType vault balance: ${vaultGrams.toStringAsFixed(3)} g | Required: ${weightGrams.toStringAsFixed(3)} g',
                      style: TextStyle(color: t.inkMuted, fontSize: 11.5),
                    ),

                    const SizedBox(height: 14),

                    // Payment Method Option Selection
                    Text(
                      'Choose Payment Option for Making Charges',
                      style: TextStyle(
                        color: t.ink,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Razorpay Option (Default)
                    GestureDetector(
                      onTap: () => selectedMethod.value = 'razorpay',
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedMethod.value == 'razorpay'
                              ? _gold.withValues(alpha: 0.12)
                              : t.subBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedMethod.value == 'razorpay'
                                ? _gold
                                : t.cardBorder,
                            width: selectedMethod.value == 'razorpay'
                                ? 1.5
                                : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedMethod.value == 'razorpay'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selectedMethod.value == 'razorpay'
                                  ? _gold
                                  : t.inkMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pay via Razorpay (UPI / Card / NetBanking)',
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Direct payment — does not cut from Payvika Wallet',
                                    style: TextStyle(
                                      color: t.inkMuted,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Payvika Wallet Option
                    GestureDetector(
                      onTap: () => selectedMethod.value = 'wallet',
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedMethod.value == 'wallet'
                              ? _gold.withValues(alpha: 0.12)
                              : t.subBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedMethod.value == 'wallet'
                                ? _gold
                                : t.cardBorder,
                            width: selectedMethod.value == 'wallet' ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selectedMethod.value == 'wallet'
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: selectedMethod.value == 'wallet'
                                  ? _gold
                                  : t.inkMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pay via Payvika Wallet',
                                    style: TextStyle(
                                      color: t.ink,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Deduct ₹${totalPayableNow.toStringAsFixed(0)} from wallet balance',
                                    style: TextStyle(
                                      color: t.inkMuted,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Big Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isRedeeming.value
                            ? null
                            : () {
                                controller.redeemItem(
                                  item,
                                  paymentMethod: selectedMethod.value,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: t.primary,
                          foregroundColor: t.ctaText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: controller.isRedeeming.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                selectedMethod.value == 'razorpay'
                                    ? 'Pay ₹${totalPayableNow.toStringAsFixed(0)} via Razorpay & Redeem'
                                    : 'Pay ₹${totalPayableNow.toStringAsFixed(0)} from Wallet & Redeem',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String val, _T t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: t.inkMuted, fontSize: 12)),
          Text(
            val,
            style: TextStyle(
              color: t.ink,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(IconData icon, String text, _T t) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: _gold, size: 20),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: t.inkMuted, fontSize: 9.5, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
