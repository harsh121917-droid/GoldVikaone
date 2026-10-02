import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../core/localization/localization_service.dart';

const _gold = Color(0xFFD4A017);
const _emerald = Color(0xFF10B981);

class LanguageSettingsView extends StatefulWidget {
  const LanguageSettingsView({super.key});

  @override
  State<LanguageSettingsView> createState() => _LanguageSettingsViewState();
}

class _LanguageSettingsViewState extends State<LanguageSettingsView> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = LocalizationService.to.currentLangCode.value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      LocalizationService.to.currentLangCode.value;
      final dark = ThemeController.to.isDark.value;

      final bg = dark ? const Color(0xFF03160E) : const Color(0xFFF4F7F4);
      final textPrimary = dark ? Colors.white : const Color(0xFF03160E);
      final textSecondary = dark ? Colors.white70 : const Color(0xFF4A554F);
      final cardColor = dark ? const Color(0xFF0C2017) : Colors.white;
      final borderSideColor = dark ? const Color(0xFF1E352B) : const Color(0xFFE2EBE5);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderSideColor),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _gold,
                size: 16,
              ),
            ),
          ),
          title: Text(
            'language_settings'.tr,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: borderSideColor,
              height: 1,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero Banner ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: dark
                                ? [const Color(0xFF082B1D), const Color(0xFF041910)]
                                : [const Color(0xFFE8F5E9), const Color(0xFFF1F8F4)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _emerald.withValues(alpha: dark ? 0.3 : 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [_gold, Color(0xFFF59E0B)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.translate_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'choose_app_language'.tr,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'language_subtitle'.tr,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Section Title ──
                      Text(
                        'select_language'.tr,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Language Card: English ──
                      _buildLanguageTile(
                        code: 'en',
                        title: 'English',
                        subtitle: 'Default (English - IN)',
                        badgeText: null,
                        dark: dark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        borderSideColor: borderSideColor,
                      ),
                      const SizedBox(height: 12),

                      // ── Language Card: Marathi ──
                      _buildLanguageTile(
                        code: 'mr',
                        title: 'मराठी',
                        subtitle: 'Marathi (महाराष्ट्र)',
                        badgeText: 'popular_badge'.tr,
                        dark: dark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        borderSideColor: borderSideColor,
                      ),
                      const SizedBox(height: 12),

                      // ── Language Card: Hindi ──
                      _buildLanguageTile(
                        code: 'hi',
                        title: 'हिन्दी',
                        subtitle: 'Hindi (भारत)',
                        badgeText: 'popular_badge'.tr,
                        dark: dark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        borderSideColor: borderSideColor,
                      ),
                      const SizedBox(height: 12),

                      // ── Language Card: Kannada ──
                      _buildLanguageTile(
                        code: 'kn',
                        title: 'ಕನ್ನಡ',
                        subtitle: 'Kannada (ಕರ್ನಾಟಕ)',
                        badgeText: 'popular_badge'.tr,
                        dark: dark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        borderSideColor: borderSideColor,
                      ),
                      const SizedBox(height: 12),

                      // ── Language Card: Gujarati ──
                      _buildLanguageTile(
                        code: 'gu',
                        title: 'ગુજરાતી',
                        subtitle: 'Gujarati (ગુજરાત)',
                        badgeText: 'popular_badge'.tr,
                        dark: dark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardColor: cardColor,
                        borderSideColor: borderSideColor,
                      ),
                      const SizedBox(height: 24),

                      // ── Live Preview Box ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderSideColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.visibility_rounded,
                                  color: _gold,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'preview_label'.tr,
                                  style: const TextStyle(
                                    color: _gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: dark
                                    ? const Color(0xFF132F23)
                                    : const Color(0xFFFCF7EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedCode == 'mr'
                                        ? 'सोन्याची शिल्लक'
                                        : (_selectedCode == 'hi'
                                            ? 'सोने की शेष राशि'
                                            : (_selectedCode == 'kn'
                                                ? 'ಚಿನ್ನದ ಬ್ಯಾಲೆನ್ಸ್'
                                                : (_selectedCode == 'gu'
                                                    ? 'સોનાનું બેલેન્સ'
                                                    : 'Gold Balance'))),
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '1.250 g',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: dark
                                    ? const Color(0xFF132F23)
                                    : const Color(0xFFFCF7EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedCode == 'mr'
                                        ? 'लाइव्ह बाजार दर'
                                        : (_selectedCode == 'hi'
                                            ? 'लाइव बाजार दर'
                                            : (_selectedCode == 'kn'
                                                ? 'ಲೈವ್ ಮಾರುಕಟ್ಟೆ ದರ'
                                                : (_selectedCode == 'gu'
                                                    ? 'લાઈવ બજાર ભાવ'
                                                    : 'Live Market Rate'))),
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '₹8,920/g',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
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

              // ── Sticky Bottom Apply Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await LocalizationService.to.changeLocale(_selectedCode);
                      Get.back();
                      Get.snackbar(
                        'Success ✓',
                        _selectedCode == 'mr'
                            ? 'भाषा मराठीमध्ये बदलली'
                            : (_selectedCode == 'hi'
                                ? 'भाषा हिन्दी में बदल दी गई'
                                : (_selectedCode == 'kn'
                                    ? 'ಭಾಷೆಯನ್ನು ಕನ್ನಡಕ್ಕೆ ಬದಲಾಯಿಸಲಾಗಿದೆ'
                                    : (_selectedCode == 'gu'
                                        ? 'ભાષા ગુજરાતીમાં બદલાઈ ગઈ'
                                        : 'Language changed to English'))),
                        backgroundColor: const Color(0xFF10B981),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: _gold.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'apply_language'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
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

  Widget _buildLanguageTile({
    required String code,
    required String title,
    required String subtitle,
    required String? badgeText,
    required bool dark,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardColor,
    required Color borderSideColor,
  }) {
    final isSelected = _selectedCode == code;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCode = code;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _gold.withValues(alpha: dark ? 0.14 : 0.08)
              : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _gold : borderSideColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _gold.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Radio circle indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _gold : textSecondary.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: isSelected ? _gold : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Color(0xFF2ECC71),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'active_badge'.tr,
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
