import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vika1/core/theme/controllers/theme_controller.dart';

class InvoiceViewerView extends StatefulWidget {
  final String filePath;
  final String title;

  const InvoiceViewerView({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<InvoiceViewerView> createState() => _InvoiceViewerViewState();
}

class _InvoiceViewerViewState extends State<InvoiceViewerView> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Text(
            widget.title,
            style: TextStyle(
              color: tp,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                if (await File(widget.filePath).exists()) {
                  await Share.shareXFiles([
                    XFile(widget.filePath, mimeType: 'application/pdf'),
                  ], text: widget.title);
                } else {
                  Get.snackbar(
                    'Error',
                    'Invoice file not found.',
                    backgroundColor: const Color(0xFFe74c3c),
                    colorText: Colors.white,
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF1A2B45)
                      : const Color(0xFFF0EDE4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.share_outlined, color: tp, size: 18),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            if (errorMessage.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PDFView(
                      filePath: widget.filePath,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
                      defaultPage: currentPage!,
                      fitPolicy: FitPolicy.BOTH,
                      onRender: (_pages) {
                        setState(() {
                          pages = _pages;
                          isReady = true;
                        });
                      },
                      onError: (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                      },
                      onPageError: (page, error) {
                        setState(() {
                          errorMessage = '$page: ${error.toString()}';
                        });
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                      onPageChanged: (int? page, int? total) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFe74c3c),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to render PDF',
                      style: TextStyle(
                        color: tp,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ts, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (!isReady && errorMessage.isEmpty)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A017)),
                ),
              ),
            if (isReady && pages != null && pages! > 1)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2340).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(currentPage ?? 0) + 1} / $pages',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
