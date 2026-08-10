import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../core/theme/app_colors.dart';

class PolicyView extends StatelessWidget {
  const PolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments ?? {
      'title': 'Policy',
      'content': '',
    };
    final String title = args['title'] ?? 'Policy';
    final String content = args['content'] ?? '';

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF03160E) : const Color(0xFFF4F7F4);
      final textPrimary = dark ? Colors.white : const Color(0xFF03160E);
      final textSecondary = dark ? Colors.white70 : const Color(0xFF4A554F);
      final cardColor = dark ? const Color(0xFF0C2017) : Colors.white;
      final borderSideColor = dark ? const Color(0xFF1E352B) : const Color(0xFFE2EBE5);
      const gold = Color(0xFFD4A017);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: gold, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderSideColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                content,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 13.5,
                  height: 1.7,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
