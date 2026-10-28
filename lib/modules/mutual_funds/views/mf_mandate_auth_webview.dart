import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/network/api_client.dart';
import '../controllers/mutual_funds_controller.dart';

/// In-App Verification Hub & WebView for Official NSE MFSS eNACH AutoPay Mandate Authorization
/// Opens bank authorization link directly inside the app with safe SSL navigation and return handling.
class MfMandateAuthWebView extends StatefulWidget {
  final String? initialUrl;
  final String? mandateId;
  final String? bankName;
  final String? accountNo;
  final String? clientCode;

  const MfMandateAuthWebView({
    super.key,
    this.initialUrl,
    this.mandateId,
    this.bankName,
    this.accountNo,
    this.clientCode,
  });

  @override
  State<MfMandateAuthWebView> createState() => _MfMandateAuthWebViewState();
}

class _MfMandateAuthWebViewState extends State<MfMandateAuthWebView> with WidgetsBindingObserver {
  WebViewController? _webCtrl;
  final MutualFundsController _controller = Get.find<MutualFundsController>();
  final TextEditingController _pasteLinkCtrl = TextEditingController();

  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _showInstructions = true;
  String _currentUrl = '';
  bool _isCheckingStatus = false;
  bool _isAutoFetching = false;
  int _fetchAttempts = 0;

  static const Color darkBg = Color(0xFF0F141E);
  static const Color cardBg = Color(0xFF161E2D);
  static const Color mintGreen = Color(0xFF00D09C);
  static const Color borderColor = Color(0xFF22304A);
  static const Color goldAccent = Color(0xFFEAB308);

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
    WidgetsBinding.instance.addObserver(this);
    final rawUrl = (widget.initialUrl != null && widget.initialUrl!.trim().isNotEmpty)
        ? widget.initialUrl!.trim()
        : '';
    _currentUrl = _isRealWebUrl(rawUrl) ? rawUrl : '';

    if (_currentUrl.isNotEmpty) {
      _initWebView();
    } else {
      final mId = widget.mandateId ??
          _controller.onboardingData['mandateId']?.toString() ??
          _controller.onboardingData['defaultMandateId']?.toString() ??
          '';
      if (mId.isNotEmpty) {
        _autoFetchAndLoadMandateUrl(mId);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pasteLinkCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_currentUrl.isEmpty) {
        _checkClipboardForMandateLink();
      }
    }
  }

  Future<void> _checkClipboardForMandateLink() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (_isRealWebUrl(text) && _currentUrl.isEmpty) {
        _pasteLinkCtrl.text = text;
        _loadPastedLink();
        Get.snackbar(
          'Mandate Link Detected',
          'Loaded authorization portal from clipboard.',
          backgroundColor: mintGreen,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {}
  }

  Future<void> _autoFetchAndLoadMandateUrl(String mId) async {
    if (!mounted || _isAutoFetching) return;
    setState(() {
      _isAutoFetching = true;
      _fetchAttempts++;
    });

    try {
      final url = await _controller.fetchMandateAuthUrl(mId);
      if (_isRealWebUrl(url)) {
        if (!mounted) return;
        setState(() {
          _currentUrl = url!;
          _isAutoFetching = false;
        });
        _initWebView();
        Get.snackbar(
          'Mandate Gateway Connected ✓',
          'Official bank authorization portal loaded directly.',
          backgroundColor: mintGreen,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // Retry setup without forceNew
      final dio = ApiClient.instance;
      final setupRes = await dio.post('/mutual-funds/mandates/setup', data: {'amount': 50000, 'forceNew': false});
      if (setupRes.statusCode == 200 && setupRes.data['success'] == true) {
        final setupUrl = setupRes.data['data']?['authUrl']?.toString();
        if (_isRealWebUrl(setupUrl)) {
          if (!mounted) return;
          setState(() {
            _currentUrl = setupUrl!;
            _isAutoFetching = false;
          });
          _initWebView();
          Get.snackbar(
            'Mandate Gateway Connected ✓',
            'Official bank authorization portal loaded directly.',
            backgroundColor: mintGreen,
            colorText: Colors.black,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('[MandateAuthWebView] autoFetch error: $e');
    }

    if (mounted && _fetchAttempts < 4 && _currentUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted && _currentUrl.isEmpty) {
        _autoFetchAndLoadMandateUrl(mId);
        return;
      }
    }

    if (mounted) {
      setState(() => _isAutoFetching = false);
    }
  }

  Future<void> _pasteFromClipboardAndLoad() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (_isRealWebUrl(text)) {
        _pasteLinkCtrl.text = text;
        _loadPastedLink();
      } else if (text.isNotEmpty) {
        _pasteLinkCtrl.text = text;
        Get.snackbar(
          'Link Pasted',
          'URL pasted into field. Tap "Open in App" to load.',
          backgroundColor: cardBg,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Clipboard Empty',
          'Copy the link received in the email or SMS from NSE first.',
          backgroundColor: cardBg,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {}
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
            debugPrint('[MandateAuthWebView] Resource error: ${error.description}');
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
        'Cookies & cache cleared for fresh eNACH session. Reloading...',
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
      debugPrint('[MandateAuthWebView] clearSession error: $e');
    }
  }

  Future<void> _requestNewMandateLink() async {
    try {
      Get.snackbar(
        'Requesting Link',
        'Generating fresh eNACH Mandate link from NSE MFSS...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardBg,
        colorText: Colors.white,
      );

      final dio = ApiClient.instance;
      final res = await dio.post('/mutual-funds/mandates/setup', data: {'amount': 50000, 'forceNew': true});
      if (res.statusCode == 200 && res.data['success'] == true) {
        final authUrl = res.data['data']?['authUrl']?.toString();
        if (_isRealWebUrl(authUrl)) {
          setState(() {
            _currentUrl = authUrl!;
          });
          _initWebView();
          Get.snackbar(
            'Mandate Link Ready ✓',
            'Fresh bank authorization portal loaded below.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: mintGreen,
            colorText: Colors.black,
          );
        } else {
          Get.snackbar(
            'Notification Sent',
            'NSE has dispatched the eNACH link to your registered email & mobile.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: cardBg,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Notice',
        'Check your email or SMS for the mandate link from NSE.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardBg,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _checkMandateStatus() async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: mintGreen)),
      barrierDismissible: false,
    );

    try {
      final mandateId = widget.mandateId ??
          _controller.onboardingData['mandateId']?.toString() ??
          _controller.onboardingData['defaultMandateId']?.toString() ??
          '';

      if (mandateId.isNotEmpty) {
        final dio = ApiClient.instance;
        final vRes = await dio.post('/mutual-funds/mandates/$mandateId/verify');
        if (vRes.statusCode == 200 && vRes.data['success'] == true) {
          final isApproved = vRes.data['data']?['status'] == 'APPROVED';
          await _controller.fetchOnboardingStatus();
          await _controller.fetchMfProfile();

          Get.back(); // close progress dialog

          if (isApproved) {
            Get.snackbar(
              'AutoPay Mandate Approved! 🎉',
              'Your bank mandate is active. You can now start monthly SIPs seamlessly.',
              backgroundColor: mintGreen,
              colorText: Colors.black,
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 4),
            );
            if (!mounted) return;
            if (!mounted) return;
        Navigator.pop(context, true);
            return;
          }
        }
      }

      await _controller.fetchOnboardingStatus();
      await _controller.fetchMfProfile();
      Get.back(); // close progress dialog

      final isApproved = _controller.onboardingStep.value >= 3 ||
          _controller.onboardingData['mandateStatus'] == 'APPROVED' ||
          _controller.onboardingData['step'] == 3 ||
          _controller.onboardingData['isSipReady'] == true;

      if (isApproved) {
        Get.snackbar(
          'AutoPay Mandate Approved! 🎉',
          'Your bank mandate is active. You can now start monthly SIPs seamlessly.',
          backgroundColor: mintGreen,
          colorText: Colors.black,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        Get.snackbar(
          'Mandate Pending with Bank',
          'Your bank is processing the eNACH authorization. This usually takes 5–15 minutes.',
          backgroundColor: goldAccent,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back(); // close progress dialog
      Get.snackbar(
        'Status Synchronized',
        'Refreshed mandate status from exchange.',
        backgroundColor: cardBg,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  void _loadPastedLink() {
    final text = _pasteLinkCtrl.text.trim();
    if (text.isEmpty) {
      Get.snackbar('Empty URL', 'Please paste the mandate link received in Email/SMS.', backgroundColor: cardBg, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!_isRealWebUrl(text)) {
      Get.snackbar('Invalid URL', 'Please enter a valid https:// web link.', backgroundColor: cardBg, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() {
      _currentUrl = text;
      _isLoading = true;
    });
    _initWebView();
  }

  @override
  Widget build(BuildContext context) {
    final mandateId = widget.mandateId ??
        _controller.onboardingData['mandateId']?.toString() ??
        '';
    final bank = widget.bankName ??
        _controller.onboardingData['bankName']?.toString() ??
        'Registered Bank';
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
              'NSE eNACH AutoPay Mandate',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              mandateId.isNotEmpty ? 'ID: $mandateId • $bank' : 'Bank SIP Authorization',
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
              tooltip: 'Clear Session & Reload',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
              onPressed: _clearSessionAndReload,
            ),
            IconButton(
              tooltip: 'Open in Chrome / Browser',
              icon: const Icon(Icons.open_in_browser_rounded, color: mintGreen, size: 22),
              onPressed: () async {
                final uri = Uri.tryParse(_currentUrl);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
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
                              'Connecting to Bank eNACH Gateway...',
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
            // Hub for direct Email/SMS Mandate authorization
            Expanded(
              child: _buildMandateHub(mandateId, bank, clientCode),
            ),
          ],

          // Bottom Action Panel
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
                    'Step-by-Step eNACH Bank Authorization',
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
          _buildStepRow('1', 'Verify Details', 'Review mandate limit (₹50,000/mo) and account number on your bank portal.'),
          const SizedBox(height: 5),
          _buildStepRow('2', 'Select Auth Method', 'Choose NetBanking or Debit Card to authenticate with your bank.'),
          const SizedBox(height: 5),
          _buildStepRow('3', 'Enter Bank OTP', 'Submit the OTP sent by your bank to authorize the eNACH mandate.'),
          const SizedBox(height: 5),
          _buildStepRow('4', 'Done & Return', 'After bank confirmation, tap "I Have Authorized • Check Mandate Status" below!'),
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
                    'Tip: If your bank requires external browser or app redirect, tap ↗ (top right) to open in Chrome.',
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

  Widget _buildMandateHub(String mandateId, String bank, String clientCode) {
    final phone = _controller.uccPrefill['mobile']?.toString() ??
        _controller.uccPrefill['phone']?.toString() ??
        _controller.onboardingData['mobile']?.toString() ??
        'Registered Mobile';
    final email = _controller.uccPrefill['email']?.toString() ??
        _controller.onboardingData['email']?.toString() ??
        'Registered Email';
    final acc = widget.accountNo ??
        _controller.onboardingData['accountNo']?.toString() ??
        '••••';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          if (_isAutoFetching) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: mintGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: mintGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: mintGreen),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opening Bank Portal in App...',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Syncing authorization link from NSE MFSS (Attempt $_fetchAttempts of 4)...',
                          style: const TextStyle(color: mintGreen, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              child: Icon(Icons.account_balance_wallet_rounded, color: mintGreen, size: 38),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'eNACH AutoPay Authorization',
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
            'NSE MFSS dispatches the secure eNACH mandate authentication link to your registered email & mobile to enable automated SIP debits.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Mandate Details Card
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
                  'MANDATE & BANK DETAILS',
                  style: TextStyle(
                    color: mintGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                _buildDetailRow('Linked Bank', bank, Icons.account_balance_rounded),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: borderColor, height: 1),
                ),
                _buildDetailRow('Account Number', acc.length > 4 ? '•••• ${acc.substring(acc.length - 4)}' : acc, Icons.tag_rounded),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: borderColor, height: 1),
                ),
                _buildDetailRow('Max Limit', '₹50,000 / month', Icons.trending_up_rounded),
                if (mandateId.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: borderColor, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.confirmation_number_outlined, color: Colors.white54, size: 16),
                          SizedBox(width: 8),
                          Text('Mandate ID', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: mandateId));
                          Get.snackbar('Copied', 'Mandate ID copied to clipboard.', backgroundColor: cardBg, colorText: mintGreen, snackPosition: SnackPosition.BOTTOM);
                        },
                        child: Row(
                          children: [
                            Text(mandateId, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, color: mintGreen, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Delivery Details Card
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
                      child: const Icon(Icons.mail_outline_rounded, color: mintGreen, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Official Email Sent To', style: TextStyle(color: Colors.white54, fontSize: 11)),
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
                      icon: const Icon(Icons.open_in_new_rounded, size: 14, color: mintGreen),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: borderColor, height: 1),
                ),

                // SMS Strip
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
                      'Have the link from Email/SMS?',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _pasteFromClipboardAndLoad,
                    icon: const Icon(Icons.content_paste_rounded, size: 15, color: mintGreen),
                    label: const Text(
                      'Paste Copied Link from Email & Open In-App',
                      style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: mintGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _pasteLinkCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Or paste https:// link here...',
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
                      onPressed: _loadPastedLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Open in App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomActionPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isCheckingStatus ? null : _checkMandateStatus,
                icon: const Icon(Icons.check_circle_rounded, color: Colors.black, size: 18),
                label: Text(
                  _isCheckingStatus ? 'Checking Mandate Status...' : 'I Have Authorized • Check Mandate Status',
                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _requestNewMandateLink,
                  icon: const Icon(Icons.refresh_rounded, size: 14, color: Colors.white70),
                  label: const Text('Re-generate Mandate Link', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ),
                const Text(' • ', style: TextStyle(color: Colors.white30)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
