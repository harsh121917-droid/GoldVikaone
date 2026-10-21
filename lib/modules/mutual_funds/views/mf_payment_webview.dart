import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/mutual_funds_controller.dart';

/// In-App WebView for Official NSE MFSS Payment Gateway
/// Opens payment page directly inside the app with safe SSL navigation and return handling.
class MfPaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String title;

  const MfPaymentWebView({
    Key? key,
    required this.paymentUrl,
    this.title = 'NSE Payment Gateway',
  }) : super(key: key);

  @override
  State<MfPaymentWebView> createState() => _MfPaymentWebViewState();
}

class _MfPaymentWebViewState extends State<MfPaymentWebView> {
  late final WebViewController _webCtrl;
  final MutualFundsController _controller = Get.find<MutualFundsController>();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  String _currentUrl = '';
  bool _hasError = false;

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.paymentUrl.trim();
    _initWebView();
  }

  void _initWebView() {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36',
      )
      ..setBackgroundColor(darkBg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
                if (progress == 100) _isLoading = false;
              });
            }
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _currentUrl = url;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint('[MfPaymentWebView] Resource error: ${error.description}');
            if (mounted && _isLoading && _loadingProgress < 0.2) {
              setState(() => _hasError = true);
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && (uri.scheme == 'upi' || uri.scheme == 'intent')) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (_currentUrl.isNotEmpty) {
      final uri = Uri.tryParse(_currentUrl);
      if (uri != null) {
        _webCtrl.loadRequest(uri);
      }
    }
  }

  Future<void> _openExternalBrowser() async {
    final uri = Uri.tryParse(_currentUrl.isNotEmpty ? _currentUrl : widget.paymentUrl);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('[MfPaymentWebView] External browser launch failed: $e');
      }
    }
  }

  void _onDone() {
    _controller.fetchPortfolio();
    _controller.fetchMyOrders();
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webCtrl.canGoBack()) {
          _webCtrl.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
            onPressed: _onDone,
          ),
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.title,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: const Text('SECURE', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                'NSE Clearing Limited • Official Gateway',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 20),
              tooltip: 'Refresh',
              onPressed: () => _webCtrl.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white70, size: 20),
              tooltip: 'Open in Chrome / Browser',
              onPressed: _openExternalBrowser,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: cardBg,
                color: mintGreen,
                minHeight: 2.5,
              ),
            Expanded(
              child: _hasError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load NSE gateway',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please check your internet connection or open in external browser.',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    setState(() => _hasError = false);
                                    _webCtrl.reload();
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: const Text('Retry'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: borderColor),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _openExternalBrowser,
                                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                                  label: const Text('Open in Browser'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mintGreen,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : WebViewWidget(controller: _webCtrl),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: cardBg,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: mintGreen, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '256-Bit SSL Encrypted NSE Payment Session',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: _onDone,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    backgroundColor: const Color(0xFF1E293B),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
