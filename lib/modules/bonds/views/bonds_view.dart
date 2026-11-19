import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BondsView extends StatefulWidget {
  final String? initialUrl;
  const BondsView({super.key, this.initialUrl});

  @override
  State<BondsView> createState() => _BondsViewState();
}

class _BondsViewState extends State<BondsView> {
  static const String _defaultBondUrl =
      'https://www.bondbazaar.com/open-trading-account/?param=UlZTMTM%3D';

  late final WebViewController _webViewController;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    final targetUrl = widget.initialUrl ??
        (Get.arguments is Map && Get.arguments['url'] != null
            ? Get.arguments['url'] as String
            : _defaultBondUrl);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
                if (progress >= 100) {
                  _isLoading = false;
                }
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                if (error.isForMainFrame ?? true) {
                  _hasError = true;
                  _errorMessage = error.description;
                }
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(targetUrl));
  }

  Future<void> _handleBackPress() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 19,
            ),
            tooltip: 'Back',
            onPressed: _handleBackPress,
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              // VikaOne Gold Circular Logo
              Container(
                width: 34,
                height: 34,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0B1E15),
                  border: Border.all(color: const Color(0xFFD4A017), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.candlestick_chart_rounded,
                    color: Color(0xFFD4A017),
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // VikaOne & BondBazaar Partner Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'VikaOne',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'BONDS',
                            style: TextStyle(
                              color: Color(0xFF0284C7),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'BondBazaar Trading Desk',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF0F172A),
                size: 21,
              ),
              tooltip: 'Reload',
              onPressed: () {
                HapticFeedback.selectionClick();
                _webViewController.reload();
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFF64748B),
                size: 22,
              ),
              tooltip: 'Close',
              onPressed: () => Get.back(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Slim linear progress indicator on page loading
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4A017)),
                minHeight: 2.5,
              ),

            // In-App WebView body
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),

                  // Initial loading overlay
                  if (_isLoading && _loadingProgress < 0.3)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0B1E15),
                                border: Border.all(color: const Color(0xFFD4A017), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4A017).withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.candlestick_chart_rounded,
                                  color: Color(0xFFD4A017),
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Opening VikaOne Bonds Desk...',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Connecting securely to BondBazaar onboarding',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A017)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Error fallback with retry button
                  if (_hasError)
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFEE2E2),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: const Icon(
                                Icons.wifi_off_rounded,
                                color: Color(0xFFDC2626),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to Load Bonds Desk',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : 'Please check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _hasError = false;
                                  _isLoading = true;
                                });
                                _webViewController.reload();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text(
                                'Retry Connection',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A017),
                                foregroundColor: const Color(0xFF0F172A),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
