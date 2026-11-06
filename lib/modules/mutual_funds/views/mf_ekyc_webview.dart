import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../controllers/mutual_funds_controller.dart';

/// In-App WebView screen for official NSE MFSS / CAMS Paperless eKYC
class MfEkycWebView extends StatefulWidget {
  final String ekycUrl;
  final String pan;

  const MfEkycWebView({
    super.key,
    required this.ekycUrl,
    required this.pan,
  });

  @override
  State<MfEkycWebView> createState() => _MfEkycWebViewState();
}

class _MfEkycWebViewState extends State<MfEkycWebView> {
  WebViewController? _webCtrl;
  final MutualFundsController _controller = Get.find<MutualFundsController>();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _isCheckingStatus = false;

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final ctrl = WebViewController()
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
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint('[EkycWebView] Web error: ${error.description}');
          },
        ),
      );

    _webCtrl = ctrl;
    ctrl.loadRequest(Uri.parse(widget.ekycUrl));
  }

  Future<void> _handleCheckStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final res = await _controller.checkEkycStatus(pan: widget.pan);
      final isVerified = res != null && res['isVerified'] == true;

      if (isVerified) {
        Get.snackbar(
          'eKYC Verified',
          'Your Mutual Fund KYC is verified on NSE KRA. You can now proceed to UCC registration.',
          backgroundColor: mintGreen,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Verification in Progress',
          'RTA / CAMS is still processing your documents. If you have completed OTP verification, it typically reflects in a few moments.',
          backgroundColor: Colors.amber.shade800,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (_) {
      Get.snackbar(
        'Status Check Failed',
        'Could not refresh status from exchange. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        title: const Text('Exit eKYC Verification?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'If you have not finished Aadhaar OTP or document upload, you can resume later from the link sent to your email.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay', style: TextStyle(color: mintGreen)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Exit', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Get.back(result: false);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Paperless Investor eKYC',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'NSE MFSS • CAMS eKYC Gateway',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              tooltip: 'Reload Page',
              onPressed: () => _webCtrl?.reload(),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_browser, color: Colors.white70),
              tooltip: 'Open in Browser',
              onPressed: () async {
                final uri = Uri.parse(widget.ekycUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
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
        body: Column(
          children: [
            Expanded(
              child: _webCtrl == null
                  ? const Center(child: CircularProgressIndicator(color: mintGreen))
                  : WebViewWidget(controller: _webCtrl!),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isCheckingStatus ? null : _handleCheckStatus,
                          icon: _isCheckingStatus
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline, color: Colors.black),
                          label: Text(
                            _isCheckingStatus ? 'Checking Status...' : 'I Have Completed Verification',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mintGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
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
    );
  }
}
