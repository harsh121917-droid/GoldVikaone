import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/mutual_funds_controller.dart';

/// In-App WebView for Official MFCentral CAS Consent
/// Allows investors to import and track all external mutual funds across CAMS & KFintech.
class MfCentralCasWebView extends StatefulWidget {
  final String authUrl;
  final String clientRefNo;
  final bool isMock;

  const MfCentralCasWebView({
    Key? key,
    required this.authUrl,
    required this.clientRefNo,
    this.isMock = false,
  }) : super(key: key);

  @override
  State<MfCentralCasWebView> createState() => _MfCentralCasWebViewState();
}

class _MfCentralCasWebViewState extends State<MfCentralCasWebView> {
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
    _currentUrl = widget.authUrl.trim();
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
            _checkCompletion(url);
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _currentUrl = url;
              });
            }
            _checkCompletion(url);
          },
          onWebResourceError: (error) {
            debugPrint('[MfCentralCasWebView] Error: ${error.description}');
            if (mounted && _isLoading && _loadingProgress < 0.2) {
              setState(() => _hasError = true);
            }
          },
          onNavigationRequest: (request) {
            final url = request.url;
            if (_checkCompletion(url)) {
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

  bool _checkCompletion(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('status=success') ||
        lower.contains('/cas/callback') && !lower.contains('status=error')) {
      _handleSuccess();
      return true;
    }
    return false;
  }

  void _handleSuccess() {
    _controller.fetchConsolidatedPortfolio();
    _controller.fetchPortfolio();

    Get.snackbar(
      'Portfolio Synced Successfully! 🎉',
      'All your external mutual funds have been imported from MFCentral.',
      backgroundColor: mintGreen,
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );

    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _simulateMockCompletion() async {
    setState(() => _isLoading = true);
    final success = await _controller.triggerMockCasSync(widget.clientRefNo);
    if (success && mounted && Navigator.canPop(context)) {
      Navigator.pop(context, true);
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MFCentral CAS Import',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: mintGreen, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                const Text(
                  'SEBI Regulated RTA Consent Gateway',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => _webCtrl.reload(),
          ),
        ],
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(
                  value: _loadingProgress > 0 ? _loadingProgress : null,
                  backgroundColor: borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(mintGreen),
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webCtrl),
          if (_hasError || widget.isMock)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: mintGreen.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: mintGreen, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'MFCentral Sandbox Simulator Ready',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'UAT credentials are in sandbox mode. Tap below to simulate instant OTP verification & import sample multi-AMC folios.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5, height: 1.3),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mintGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 18),
                        label: const Text(
                          'Simulate Successful Import',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: _simulateMockCompletion,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
