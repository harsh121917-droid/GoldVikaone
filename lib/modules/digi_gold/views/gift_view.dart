import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vika1/core/network/api_client.dart';
import 'package:vika1/core/theme/controllers/theme_controller.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';

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
          bg: Color(0xFF0A0A0C),
          card: Color(0xFF16161B),
          primary: Color(0xFFD4A017),
          ink: Color(0xFFF5F5F5),
          inkMuted: Color(0xFF8A8A93),
          border: Color(0x2ED4A017),
          subBg: Color(0xFF1C1C22),
        )
      : const _T(
          bg: Color(0xFFF7F4EE),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          border: Colors.transparent,
          subBg: Color(0xFFF3F1EA),
        );
}

class GiftView extends StatefulWidget {
  const GiftView({super.key});

  @override
  State<GiftView> createState() => _GiftViewState();
}

class _GiftViewState extends State<GiftView> {
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  String _selectedMetal = 'Gold'; // Gold or Silver
  bool _isGrams = false; // true = input is in grams, false = in rupees
  String _selectedTheme = 'Festive'; // Festive, Birthday, Anniversary, General
  bool _isLoading = false;

  final List<String> _themes = ['Festive', 'Birthday', 'Anniversary', 'General'];

  // Theme configuration for the card preview
  Map<String, dynamic> _getThemeStyle() {
    switch (_selectedTheme) {
      case 'Birthday':
        return {
          'colors': [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
          'title': 'Happy Birthday!',
          'icon': Icons.cake_rounded,
        };
      case 'Anniversary':
        return {
          'colors': [const Color(0xFF8B5CF6), const Color(0xFFD946EF)],
          'title': 'Happy Anniversary!',
          'icon': Icons.favorite_rounded,
        };
      case 'Festive':
        return {
          'colors': [const Color(0xFFD4A017), const Color(0xFF800020)],
          'title': 'Festive Blessings',
          'icon': Icons.wb_sunny_rounded,
        };
      default:
        return {
          'colors': [const Color(0xFF0F172A), const Color(0xFF1E293B)],
          'title': 'A Special Gift',
          'icon': Icons.card_giftcard_rounded,
        };
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  double _getCalculatedGrams() {
    final text = _amountCtrl.text.trim();
    if (text.isEmpty) return 0.0;
    final val = double.tryParse(text) ?? 0.0;
    if (_isGrams) return val;

    final rate = _selectedMetal == 'Gold'
        ? GoldController.to.buyRate
        : SilverController.to.buyRate;
    return val / rate;
  }

  double _getCalculatedRupees() {
    final text = _amountCtrl.text.trim();
    if (text.isEmpty) return 0.0;
    final val = double.tryParse(text) ?? 0.0;
    if (!_isGrams) return val;

    final rate = _selectedMetal == 'Gold'
        ? GoldController.to.buyRate
        : SilverController.to.buyRate;
    return val * rate;
  }

  void _sendGift() async {
    final phone = _phoneCtrl.text.trim();
    final amtText = _amountCtrl.text.trim();
    if (phone.isEmpty || amtText.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final grams = _getCalculatedGrams();
    if (grams <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount or weight',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // Check balance
    final available = _selectedMetal == 'Gold'
        ? GoldController.to.totalGrams
        : SilverController.to.totalGrams;

    if (available < grams) {
      Get.snackbar(
        'Insufficient Balance',
        'You only have ${available.toStringAsFixed(4)}g of $_selectedMetal available.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ApiClient.instance;
      final res = await dio.post('/gold/gift', data: {
        'recipientPhone': phone,
        'grams': grams,
        'metal': _selectedMetal,
        'note': _messageCtrl.text.trim().isNotEmpty
            ? _messageCtrl.text.trim()
            : 'Gifted $_selectedMetal',
      });

      if (res.data['success'] == true) {
        HapticFeedback.heavyImpact();
        
        // Refresh balances in controllers
        GoldController.to.loadAll();
        SilverController.to.loadAll();

        Get.back();
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2ECC71),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gift Sent Successfully!',
                    style: TextStyle(
                      color: Color(0xFF1A2B22),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${grams.toStringAsFixed(4)}g of $_selectedMetal has been successfully transferred to $phone.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B3D2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Gift transfer failed';
      Get.snackbar('Transfer Failed', msg,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final t = _T.of(dark);
    final themeStyle = _getThemeStyle();

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
              color: dark ? const Color(0xFF1E293B) : const Color(0xFFF0EDE4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_rounded, color: t.ink, size: 20),
          ),
        ),
        title: Text(
          'Gift digital metals',
          style: TextStyle(
            color: t.ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Live Greeting Card Preview ──
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeStyle['colors'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (themeStyle['colors'] as List<Color>).first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      themeStyle['icon'] as IconData,
                      size: 150,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          themeStyle['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _messageCtrl.text.isNotEmpty
                              ? '"${_messageCtrl.text}"'
                              : '"Wishing you health, wealth, and prosperity!"',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedMetal.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_getCalculatedGrams().toStringAsFixed(4)} grams',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '₹${_getCalculatedRupees().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
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
            const SizedBox(height: 24),

            // ── Metal Selection ──
            const Text(
              'Select Metal',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _segmentedPill('Gold', _selectedMetal == 'Gold', () {
                    setState(() => _selectedMetal = 'Gold');
                  }, t),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _segmentedPill('Silver', _selectedMetal == 'Silver', () {
                    setState(() => _selectedMetal = 'Silver');
                  }, t),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Recipient Phone Number ──
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: t.ink),
              decoration: _inputDecoration('Recipient Mobile Number', Icons.phone_android_rounded, t),
            ),
            const SizedBox(height: 20),

            // ── Amount / Weight Inputs ──
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(color: t.ink),
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      _isGrams ? 'Weight in Grams' : 'Amount in Rupees',
                      _isGrams ? Icons.fitness_center_rounded : Icons.currency_rupee_rounded,
                      t,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isGrams = !_isGrams;
                        _amountCtrl.clear();
                      });
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: t.subBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: t.border.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          _isGrams ? 'SWITCH TO ₹' : 'SWITCH TO Grams',
                          style: TextStyle(
                            color: t.primary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Theme Selection ──
            const Text(
              'Card Theme',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _themes.length,
                itemBuilder: (context, i) {
                  final themeName = _themes[i];
                  final isSelected = _selectedTheme == themeName;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTheme = themeName),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? t.primary : t.subBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : t.border.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          themeName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : t.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ── Message Input ──
            TextFormField(
              controller: _messageCtrl,
              maxLines: 3,
              style: TextStyle(color: t.ink),
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration('Personal Message (Optional)', Icons.chat_bubble_outline_rounded, t),
            ),
            const SizedBox(height: 36),

            // ── Submit Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendGift,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B3D2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send Gift',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentedPill(String title, bool isSelected, VoidCallback onTap, _T t) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? t.primary : t.subBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.transparent : t.border.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : t.ink,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, _T t) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: t.inkMuted, fontSize: 13.5),
      prefixIcon: Icon(icon, color: t.primary, size: 18),
      filled: true,
      fillColor: t.subBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.border.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: t.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
