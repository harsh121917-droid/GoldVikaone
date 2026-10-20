import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/network/api_client.dart';
import '../controllers/mutual_funds_controller.dart';

/// In-App WebView for NSE MFSS UCC 2FA Client Authorization
/// Opens official NSE Investor portal (https://www.nseinvest.com/mf/) with step-by-step guidance.
class MfUccAuthWebView extends StatefulWidget {
  final String? initialUrl;
  final String? clientCode;

  const MfUccAuthWebView({
    Key? key,
    this.initialUrl,
    this.clientCode,
  }) : super(key: key);

  @override
  State<MfUccAuthWebView> createState() => _MfUccAuthWebViewState();
}

class _MfUccAuthWebViewState extends State<MfUccAuthWebView> {
  late final WebViewController _webCtrl;
  final MutualFundsController _controller = Get.find<MutualFundsController>();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _showInstructions = true;
  String _currentUrl = '';

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);

  @override
  void initState() {
    super.initState();
    // Default to official NSE Investor portal: https://www.nseinvest.com/mf/
    final rawUrl = (widget.initialUrl != null && widget.initialUrl!.trim().isNotEmpty)
        ? widget.initialUrl!.trim()
        : 'https://www.nseinvest.com/mf/';
    _currentUrl = rawUrl.contains('nsenmf.com') ? 'https://www.nseinvest.com/mf/' : rawUrl;

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
            debugPrint('[UccAuthWebView] Error: ${error.description}');
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

  Future<void> _resendActivationLink() async {
    try {
      Get.snackbar(
        'Requesting Link',
        'Requesting fresh authorization link from NSE MFSS...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardBg,
        colorText: Colors.white,
      );

      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/ucc/resend-act');
      if (res.statusCode == 200 && res.data['success'] == true) {
        var authUrl = res.data['data']?['authUrl']?.toString();
        if (authUrl == null || authUrl.isEmpty || authUrl.contains('nsenmf.com')) {
          authUrl = 'https://www.nseinvest.com/mf/';
        }
        _webCtrl.loadRequest(Uri.parse(authUrl));
        Get.snackbar(
          'SMS / Code Re-sent',
          'NSE has dispatched your verification code via SMS to your registered mobile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: mintGreen,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Notice',
        'Check your SMS/Email for the confirmation code from NSE.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardBg,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleCompleteAndRefresh() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: mintGreen)),
      barrierDismissible: false,
    );

    await _controller.fetchOnboardingStatus();

    Get.back(); // close loading dialog
    Get.back(result: true); // close webview

    Get.snackbar(
      'Account Synchronized ✓',
      'NSE Investor activation status refreshed successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: mintGreen,
      colorText: Colors.black,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientCode = widget.clientCode ?? _controller.userUcc.value?.clientCode ?? _controller.onboardingData['clientCode']?.toString() ?? '';

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NSE 2FA Authorization',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              clientCode.isNotEmpty ? 'Client Code: $clientCode • NSE MFSS' : 'Official Exchange Verification',
              style: const TextStyle(color: mintGreen, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Instructions',
            icon: Icon(
              _showInstructions ? Icons.info_rounded : Icons.info_outline_rounded,
              color: _showInstructions ? mintGreen : Colors.white70,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _showInstructions = !_showInstructions;
              });
            },
          ),
          IconButton(
            tooltip: 'Open in Browser',
            icon: const Icon(Icons.open_in_browser_rounded, color: Colors.white70, size: 22),
            onPressed: () async {
              final uri = Uri.tryParse(_currentUrl.isNotEmpty ? _currentUrl : 'https://www.nseinvest.com/mf/');
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          IconButton(
            tooltip: 'Reload Page',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
            onPressed: () => _webCtrl.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Loading Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress : null,
              backgroundColor: darkBg,
              color: mintGreen,
              minHeight: 2.5,
            ),

          // ── STEP-BY-STEP INSTRUCTION BANNER (Collapsible) ──
          if (_showInstructions) _buildInstructionBanner(),

          // ── IN-APP WEBVIEW ──
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _webCtrl),
                if (_isLoading && _loadingProgress < 0.2)
                  Container(
                    color: darkBg,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: mintGreen),
                          SizedBox(height: 14),
                          Text(
                            'Connecting to NSE MFSS Gateway...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── BOTTOM ACTION BAR ──
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  Widget _buildInstructionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mintGreen.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, color: mintGreen, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Step-by-Step Authorization Steps',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showInstructions = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Text('Hide', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStepRow('1', 'Check SMS Code', 'NSE sends an SMS with your confirmation code.'),
          const SizedBox(height: 5),
          _buildStepRow('2', 'Enter on Portal', 'Enter your code or review details on the NSE portal below.'),
          const SizedBox(height: 5),
          _buildStepRow('3', 'Agree to Terms', 'Tick the checkbox: "I agree to Terms & Conditions".'),
          const SizedBox(height: 5),
          _buildStepRow('4', 'Verify OTP', 'Enter OTP and tap "Authorize".'),
          const SizedBox(height: 5),
          _buildStepRow('5', 'Done & Refresh', 'Tap "I Have Authorized • Done & Refresh" below!'),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: mintGreen,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, height: 1.3),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: desc,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resend SMS & Open in Chrome Row (clean single-tier, no second paste link option)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _resendActivationLink,
                  child: const Row(
                    children: [
                      Icon(Icons.sms_outlined, color: mintGreen, size: 14),
                      SizedBox(width: 5),
                      Text('Resend NSE SMS / Code', style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.tryParse(_currentUrl.isNotEmpty ? _currentUrl : 'https://www.nseinvest.com/mf/');
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new_rounded, color: Colors.white70, size: 13),
                      SizedBox(width: 4),
                      Text('Open in Chrome', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Primary Done & Refresh Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _handleCompleteAndRefresh,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.black, size: 18),
                label: const Text(
                  'I Have Authorized • Done & Refresh',
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
