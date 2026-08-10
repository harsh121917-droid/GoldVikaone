import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/core/theme/controllers/theme_controller.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';

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
          primary: Color(0xFFD4A017),
          ink: Color(0xFFEDF0FF),
          inkMuted: Color(0xFF8A95B0),
          border: Color(0xFF1A2B45),
          subBg: Color(0xFF0A0F1E),
        )
      : const _T(
          bg: Color(0xFFF7F4EE),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          border: Color(0xFFE8DFC8),
          subBg: Color(0xFFF3F1EA),
        );
}

class CoinDetailView extends StatefulWidget {
  const CoinDetailView({super.key});

  @override
  State<CoinDetailView> createState() => _CoinDetailViewState();
}

class _CoinDetailViewState extends State<CoinDetailView> {
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _useDigitalBalance = true;

  late final Map<String, dynamic> coin;

  @override
  void initState() {
    super.initState();
    coin = Get.arguments as Map<String, dynamic>;
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _processRedeem() async {
    if (!_formKey.currentState!.validate()) return;

    final isGold = coin['metal'] == 'gold';
    final rate = (coin['ratePerGram'] as num).toDouble();
    final totalValue = (coin['totalValue'] as num).toDouble();
    final availableGrams = isGold ? GoldController.to.totalGrams : SilverController.to.totalGrams;
    final availableValue = availableGrams * rate;

    final discountAmount = _useDigitalBalance ? (availableValue > totalValue ? totalValue : availableValue) : 0.0;
    final netPayable = totalValue - discountAmount;

    // Validate Wallet Balance if netPayable > 0
    if (netPayable > 0) {
      if (!Get.isRegistered<WalletController>()) {
        Get.put(WalletController());
      }
      final walletBal = WalletController.to.wallet.value?.balance ?? 0.0;
      if (walletBal < netPayable) {
        Get.snackbar(
          'Insufficient Wallet Balance',
          'You need ₹${netPayable.toStringAsFixed(2)} to complete payment, but wallet has only ₹${walletBal.toStringAsFixed(2)}. Please add money to your wallet.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final success = await GoldController.to.redeemCoin(
      coinId: coin['id'],
      addressLine: _addressCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      redeemDigital: _useDigitalBalance,
    );

    setState(() => _isLoading = false);

    if (success) {
      HapticFeedback.heavyImpact();
      Get.back(); // Back to catalog
      
      // Refresh balances in controllers
      GoldController.to.loadAll();
      SilverController.to.loadAll();

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF2ECC71), size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Order Confirmed!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your redemption order for ${coin['name']} has been successfully placed. Certified coin will be delivered shortly.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3D2E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Great', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Get.snackbar(
        'Redemption Failed',
        'Could not complete transaction. Please check your internet connection.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final t = _T.of(dark);
    final isGold = coin['metal'] == 'gold';
    final coinColor = isGold ? const Color(0xFFD4A017) : const Color(0xFF8A95B0);

    final rate = (coin['ratePerGram'] as num).toDouble();
    final totalValue = (coin['totalValue'] as num).toDouble();
    final availableGrams = isGold ? GoldController.to.totalGrams : SilverController.to.totalGrams;
    final availableValue = availableGrams * rate;

    final discountAmount = _useDigitalBalance ? (availableValue > totalValue ? totalValue : availableValue) : 0.0;
    final netPayable = totalValue - discountAmount;
    final gramsToDeduct = discountAmount / rate;

    final walletBal = Get.isRegistered<WalletController>()
        ? (WalletController.to.wallet.value?.balance ?? 0.0)
        : 0.0;

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
          coin['name'],
          style: TextStyle(
            color: t.ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Premium Coin Showcase Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              decoration: BoxDecoration(
                color: t.card,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'coin-${coin['id']}',
                    child: Image.asset(
                      isGold ? 'assets/images/gold_coin.png' : 'assets/images/silver_coin.png',
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: coinColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isGold ? '24K CERTIFIED GOLD (99.99%)' : '999 FINE PURE SILVER (99.9%)',
                      style: TextStyle(
                        color: coinColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Price Breakdown & Valuation Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.border.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VALUATION BREAKDOWN',
                      style: TextStyle(
                        color: t.inkMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _breakdownRow('Coin Weight', '${coin['grams']} grams', t),
                    _breakdownRow('Base Metal Value', '₹${coin['value']}', t),
                    _breakdownRow('Making Charges (${coin['makingChargePct']}%)', '₹${coin['makingCharge']}', t),
                    _breakdownRow('Total Coin Price', '₹${coin['totalValue']}', t),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    // Digital Metal Balance Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGold ? 'Use Digital Gold Balance' : 'Use Digital Silver Balance',
                                style: TextStyle(
                                  color: t.ink,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Available: ${availableGrams.toStringAsFixed(4)}g (~₹${availableValue.toStringAsFixed(0)})',
                                style: TextStyle(
                                  color: t.inkMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _useDigitalBalance,
                          activeColor: const Color(0xFFD4A017),
                          onChanged: (val) {
                            setState(() {
                              _useDigitalBalance = val;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_useDigitalBalance) ...[
                      const SizedBox(height: 8),
                      _breakdownRow(
                        'Digital Metal Redeemed',
                        '-₹${discountAmount.toStringAsFixed(2)} (${gramsToDeduct.toStringAsFixed(4)}g)',
                        t,
                        valueColor: const Color(0xFFE74C3C),
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Payable (Cash)',
                          style: TextStyle(color: t.ink, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${netPayable.toStringAsFixed(2)}',
                          style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Redemption Delivery Form ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: t.border.withOpacity(0.5)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DELIVERY INFORMATION',
                        style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: t.ink),
                        decoration: _inputDecoration('Contact Mobile Number', Icons.phone, t),
                        validator: (v) => v!.isEmpty ? 'Please enter a contact number' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        style: TextStyle(color: t.ink),
                        decoration: _inputDecoration('Complete Delivery Address', Icons.home_work_rounded, t),
                        validator: (v) => v!.isEmpty ? 'Please enter delivery address' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pincodeCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: t.ink),
                        decoration: _inputDecoration('Area Pincode', Icons.pin_drop_rounded, t),
                        validator: (v) => v!.isEmpty ? 'Please enter pincode' : null,
                      ),
                      const SizedBox(height: 24),
                      if (netPayable > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Wallet Balance:',
                              style: TextStyle(color: t.inkMuted, fontSize: 12),
                            ),
                            Text(
                              '₹${walletBal.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: walletBal >= netPayable ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _processRedeem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: walletBal >= netPayable || netPayable <= 0
                                ? const Color(0xFF0B3D2E)
                                : const Color(0xFFE74C3C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  walletBal >= netPayable || netPayable <= 0
                                      ? 'Confirm Redemption'
                                      : 'Insufficient Wallet (Add ₹${(netPayable - walletBal).toStringAsFixed(0)})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _breakdownRow(String label, String value, _T t, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: t.inkMuted, fontSize: 12.5)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? t.ink,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, _T t) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: t.inkMuted, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFFD4A017), size: 16),
      filled: true,
      fillColor: t.subBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: t.border.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD4A017), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
