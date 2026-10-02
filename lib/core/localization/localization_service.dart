import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_colors.dart';
import '../theme/controllers/theme_controller.dart';

class LocalizationService extends GetxService {
  static LocalizationService get to => Get.find<LocalizationService>();

  static const String _storageKey = 'app_locale_lang';

  static const Locale englishLocale = Locale('en', 'US');
  static const Locale marathiLocale = Locale('mr', 'IN');
  static const Locale hindiLocale = Locale('hi', 'IN');
  static const Locale kannadaLocale = Locale('kn', 'IN');
  static const Locale gujaratiLocale = Locale('gu', 'IN');

  static const List<Locale> supportedLocales = [
    englishLocale,
    marathiLocale,
    hindiLocale,
    kannadaLocale,
    gujaratiLocale,
  ];

  static const Locale defaultLocale = englishLocale;
  static const Locale fallbackLocale = englishLocale;

  final Rx<Locale> _currentLocale = defaultLocale.obs;
  Locale get currentLocale => _currentLocale.value;

  final RxString currentLangCode = 'en'.obs;
  bool get isMarathi => currentLangCode.value == 'mr';
  bool get isHindi => currentLangCode.value == 'hi';
  bool get isKannada => currentLangCode.value == 'kn';
  bool get isGujarati => currentLangCode.value == 'gu';

  static Locale get initialLocale {
    final box = GetStorage();
    final savedLang = box.read<String>(_storageKey);
    if (savedLang == 'mr') {
      return marathiLocale;
    }
    if (savedLang == 'hi') {
      return hindiLocale;
    }
    if (savedLang == 'kn') {
      return kannadaLocale;
    }
    if (savedLang == 'gu') {
      return gujaratiLocale;
    }
    return englishLocale;
  }

  @override
  void onInit() {
    super.onInit();
    final savedLang = GetStorage().read<String>(_storageKey);
    if (savedLang == 'mr') {
      _currentLocale.value = marathiLocale;
      currentLangCode.value = 'mr';
    } else if (savedLang == 'hi') {
      _currentLocale.value = hindiLocale;
      currentLangCode.value = 'hi';
    } else if (savedLang == 'kn') {
      _currentLocale.value = kannadaLocale;
      currentLangCode.value = 'kn';
    } else if (savedLang == 'gu') {
      _currentLocale.value = gujaratiLocale;
      currentLangCode.value = 'gu';
    } else {
      _currentLocale.value = englishLocale;
      currentLangCode.value = 'en';
    }
  }

  Future<void> changeLocale(String langCode) async {
    final newLocale = langCode == 'mr'
        ? marathiLocale
        : (langCode == 'hi'
            ? hindiLocale
            : (langCode == 'kn'
                ? kannadaLocale
                : (langCode == 'gu' ? gujaratiLocale : englishLocale)));
    currentLangCode.value = langCode;
    _currentLocale.value = newLocale;

    await GetStorage().write(_storageKey, langCode);
    await Get.updateLocale(newLocale);
  }

  Future<void> changeLanguage(String langCode) => changeLocale(langCode);

  Future<void> toggleLanguage() async {
    HapticFeedback.mediumImpact();
    if (isMarathi) {
      await changeLocale('en');
    } else {
      await changeLocale('mr');
    }
  }

  void showLanguageBottomSheet(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF16161B) : Colors.white;
    final ink = dark ? Colors.white : const Color(0xFF1A2B22);
    final inkMuted = dark ? const Color(0xFF8A8A93) : const Color(0xFF6B7A72);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: inkMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'select_language'.tr,
                      style: TextStyle(
                        color: ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'choose_preferred_language'.tr,
                      style: TextStyle(
                        color: inkMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              final activeLang = currentLangCode.value;
              return Column(
                children: [
                  _languageOption(
                    title: 'English',
                    subtitle: 'Default language',
                    nativeScript: 'EN',
                    isSelected: activeLang == 'en',
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      changeLocale('en');
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  _languageOption(
                    title: 'मराठी',
                    subtitle: 'Marathi',
                    nativeScript: 'म',
                    isSelected: activeLang == 'mr',
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      changeLocale('mr');
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  _languageOption(
                    title: 'हिन्दी',
                    subtitle: 'Hindi',
                    nativeScript: 'हि',
                    isSelected: activeLang == 'hi',
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      changeLocale('hi');
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  _languageOption(
                    title: 'ಕನ್ನಡ',
                    subtitle: 'Kannada',
                    nativeScript: 'ಕ',
                    isSelected: activeLang == 'kn',
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      changeLocale('kn');
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),
                  _languageOption(
                    title: 'ગુજરાતી',
                    subtitle: 'Gujarati',
                    nativeScript: 'ગુ',
                    isSelected: activeLang == 'gu',
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      changeLocale('gu');
                      Get.back();
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _languageOption({
    required String title,
    required String subtitle,
    required String nativeScript,
    required bool isSelected,
    required bool dark,
    required VoidCallback onTap,
  }) {
    final border = isSelected
        ? Border.all(color: AppColors.accent, width: 1.5)
        : Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
            width: 1,
          );

    final bg = isSelected
        ? AppColors.accent.withValues(alpha: dark ? 0.15 : 0.08)
        : (dark ? const Color(0xFF1E1E24) : const Color(0xFFF7F8FA));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : (dark ? Colors.white10 : Colors.black12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  nativeScript,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF3D2B00)
                        : (dark ? Colors.white : Colors.black87),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: dark ? Colors.white : const Color(0xFF1A2B22),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: dark ? Colors.white60 : const Color(0xFF6B7A72),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF3D2B00),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
