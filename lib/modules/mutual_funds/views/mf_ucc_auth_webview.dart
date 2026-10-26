import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/network/api_client.dart';
import '../controllers/mutual_funds_controller.dart';

/// In-App Verification Hub & WebView for NSE MFSS UCC 2FA Client Authorization
/// Provides step-by-step guidance for completing official exchange SMS & email authorization.
class MfUccAuthWebView extends StatefulWidget {
  final String? initialUrl;
  final String? clientCode;

  const MfUccAuthWebView({
    super.key,
    this.initialUrl,
    this.clientCode,
  });

  @override
  State<MfUccAuthWebView> createState() => _MfUccAuthWebViewState();
}

class _MfUccAuthWebViewState extends State<MfUccAuthWebView> {
  WebViewController? _webCtrl;
  final MutualFundsController _controller = Get.find<MutualFundsController>();
  final TextEditingController _pasteLinkCtrl = TextEditingController();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _showInstructions = true;
  String _currentUrl = '';

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);

  bool _isRealWebUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final clean = url.trim().toLowerCase();
    if (clean == 'https://www.nseinvest.com/mf' ||
        clean == 'https://www.nseinvest.com/mf/' ||
        clean == 'http://www.nseinvest.com/mf' ||
        clean == 'http://www.nseinvest.com/mf/' ||
        clean == 'https://www.nseinvest.com/' ||
        clean == 'https://www.nseinvest.com' ||
        clean.contains('nsenmf.com')) {
      return false;
    }
    return clean.startsWith('http://') || clean.startsWith('https://');
  }

  @override
  void initState() {
    super.initState();
    final rawUrl = (widget.initialUrl != null && widget.initialUrl!.trim().isNotEmpty)
        ? widget.initialUrl!.trim()
        : '';
    _currentUrl = _isRealWebUrl(rawUrl) ? rawUrl : '';

    if (_currentUrl.isNotEmpty) {
      _initWebView();
    }
  }

  @override
  void dispose() {
    _pasteLinkCtrl.dispose();
    super.dispose();
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

    _webCtrl = ctrl;
    _prepareAndLoad(ctrl);
  }

  Future<void> _prepareAndLoad(WebViewController ctrl) async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      await ctrl.clearCache();
      await ctrl.clearLocalStorage();
    } catch (_) {}

    if (_currentUrl.isNotEmpty) {
      final uri = Uri.tryParse(_currentUrl);
      if (uri != null) {
        await ctrl.loadRequest(uri);
      }
    }
  }

  Future<void> _clearSessionAndReload() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      await _webCtrl?.clearCache();
      await _webCtrl?.clearLocalStorage();
      Get.snackbar(
        'Session Reset',
        'Cookies & cache cleared for fresh NSE session. Reloading...',
        backgroundColor: cardBg,
        colorText: mintGreen,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      if (_currentUrl.isNotEmpty) {
        final uri = Uri.tryParse(_currentUrl);
        if (uri != null) {
          _webCtrl?.loadRequest(uri);
        }
      }
    } catch (e) {
      debugPrint('[UccAuthWebView] clearSession error: $e');
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
        final authUrl = res.data['data']?['authUrl']?.toString();
        if (_isRealWebUrl(authUrl)) {
          setState(() {
            _currentUrl = authUrl!;
          });
          _initWebView();
        }
        Get.snackbar(
          'SMS / Code Re-sent ✓',
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
    final clientCode = widget.clientCode ??
        _controller.userUcc.value?.clientCode ??
        _controller.onboardingData['clientCode']?.toString() ??
        '';

    final hasRealWeb = _isRealWebUrl(_currentUrl) && _webCtrl != null;

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
          if (hasRealWeb) ...[
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
                final uri = Uri.tryParse(_currentUrl);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            IconButton(
              tooltip: 'Clear Session & Reload',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
              onPressed: _clearSessionAndReload,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          if (hasRealWeb) ...[
            // Loading Progress Bar
            if (_isLoading)
              LinearProgressIndicator(
                value: _loadingProgress > 0 ? _loadingProgress : null,
                backgroundColor: darkBg,
                color: mintGreen,
                minHeight: 2.5,
              ),

            // Step by step banner
            if (_showInstructions) _buildInstructionBanner(),

            // In-app WebView
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webCtrl!),
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
          ] else ...[
            // Hub for direct SMS/Email 2FA authorization
            Expanded(
              child: _buildSmsActivationHub(clientCode),
            ),
          ],

          // Bottom Action Panel
          _buildBottomActionPanel(),
        ],
      ),
    );
  }

  Widget _buildSmsActivationHub(String clientCode) {
    final phone = _controller.uccPrefill['mobile']?.toString() ??
        _controller.uccPrefill['phone']?.toString() ??
        _controller.onboardingData['mobile']?.toString() ??
        'Registered Mobile';
    final email = _controller.uccPrefill['email']?.toString() ??
        _controller.onboardingData['email']?.toString() ??
        'Registered Email';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // Shield & Icon Badge
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: mintGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: mintGreen.withValues(alpha: 0.35), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.mark_email_read_rounded, color: mintGreen, size: 38),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Activation Link Dispatched by NSE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'As per SEBI regulations, NSE MFSS has sent an official one-time authentication link to verify your new investor account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Client Code Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.badge_rounded, color: mintGreen, size: 15),
                const SizedBox(width: 6),
                Text(
                  'Client Code (UCC): $clientCode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Contacts Delivery Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERY DETAILS',
                  style: TextStyle(
                    color: mintGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // Mobile Strip
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: darkBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.phone_android_rounded, color: mintGreen, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SMS Sent To', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(
                            phone.length > 4 ? '+91 ••••• ${phone.substring(phone.length - 4)}' : phone,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('sms:');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.sms_outlined, size: 14, color: mintGreen),
                      label: const Text('Open SMS', style: TextStyle(color: mintGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: mintGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: borderColor, height: 1),
                ),

                // Email Strip
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: darkBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.email_outlined, color: mintGreen, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Sent To', style: TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('mailto:');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.mail_outline_rounded, size: 14, color: mintGreen),
                      label: const Text('Open Mail', style: TextStyle(color: mintGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: mintGreen),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3 Steps Guide Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3 EASY STEPS TO COMPLETE',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 12),
                _buildStepItem('1', 'Open the SMS or Email from NSE', 'Sender is NSEINV or NSE MFSS referencing your code $clientCode.'),
                const SizedBox(height: 10),
                _buildStepItem('2', 'Tap the secure authorization link', 'Click the link in the message to open NSE\'s official 2FA authentication page.'),
                const SizedBox(height: 10),
                _buildStepItem('3', 'Enter OTP & Submit', 'Enter the OTP sent to your phone and submit. Then return here and tap Continue!'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Optional In-App Link Loader
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.link_rounded, color: mintGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Have the link from SMS/Email?',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pasteLinkCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Paste link here to complete in-app...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: darkBg,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: mintGreen)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final val = _pasteLinkCtrl.text.trim();
                        if (_isRealWebUrl(val)) {
                          setState(() {
                            _currentUrl = val;
                          });
                          _initWebView();
                        } else {
                          Get.snackbar(
                            'Invalid Link',
                            'Please paste a valid web link starting with https://',
                            backgroundColor: Colors.amber.shade900,
                            colorText: Colors.white,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Open', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepItem(String num, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: mintGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: mintGreen),
          ),
          child: Center(
            child: Text(num, style: const TextStyle(color: mintGreen, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mintGreen.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
                    color: Colors.white.withValues(alpha: 0.08),
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
          _buildStepRow('5', 'Done & Refresh', 'Tap "I Have Authorized • Done & Continue" below!'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.amber, size: 14),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tip: If NSE displays "Link already open", tap ↺ (top right) to reset session or ↗ to open in Chrome.',
                    style: TextStyle(color: Colors.amber, fontSize: 10.5),
                  ),
                ),
              ],
            ),
          ),
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
                if (_isRealWebUrl(_currentUrl))
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.tryParse(_currentUrl);
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
                  'I Have Authorized • Done & Continue',
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
