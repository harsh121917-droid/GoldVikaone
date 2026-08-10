import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DigioKycWebView extends StatefulWidget {
  final String kycId;
  final String token;
  final String customerIdentifier;
  final String environment;

  const DigioKycWebView({
    super.key,
    required this.kycId,
    required this.token,
    required this.customerIdentifier,
    required this.environment,
  });

  @override
  State<DigioKycWebView> createState() => _DigioKycWebViewState();
}

class _DigioKycWebViewState extends State<DigioKycWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isMock = false;

  // Mock DigiLocker states
  int _step = 1; // 1: Aadhaar Input, 2: OTP Input
  final _aadhaarCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _mockSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isMock = widget.kycId.startsWith('kid_mock_');

    if (!_isMock) {
      final domain = widget.environment == 'production' ? 'api.digio.in' : 'ext.digio.in';
      final gatewayUrl = 'https://$domain/#/gateway/login/${widget.kycId}/${widget.token}/${widget.customerIdentifier}?redirect_url=https://vikaone.com/kyc/callback';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                _isLoading = false;
              });
            },
            onNavigationRequest: (request) {
              final url = request.url;
              if (url.contains('vikaone.com/kyc/callback') || url.contains('status=success') || url.contains('status=completed')) {
                Navigator.of(context).pop(true);
                return NavigationDecision.prevent;
              }
              if (url.contains('status=cancel') || url.contains('status=failed')) {
                Navigator.of(context).pop(false);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(gatewayUrl));
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _aadhaarCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isMock ? const Color(0xFFF4F7F4) : Colors.white,
      appBar: AppBar(
        title: Text(
          _isMock ? 'DigiLocker Verification (Sandbox)' : 'DigiLocker Verification',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF042116),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: _isMock ? _buildMockInterface() : _buildWebView(),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4A017)),
          ),
      ],
    );
  }

  Widget _buildMockInterface() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // DigiLocker Header Logo Mockup
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_done_rounded, color: Colors.blue, size: 30),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'digilocker',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C3E50),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Your documents anytime, anywhere',
                      style: TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Main Interactive Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_step == 1) ...[
                  const Text(
                    'Link your Aadhaar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF042116),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter your 12-digit Aadhaar card number to retrieve digital identity documents.',
                    style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _aadhaarCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                    decoration: InputDecoration(
                      labelText: 'Aadhaar Number',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.credit_card_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF042116),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_aadhaarCtrl.text.length < 12) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar number')),
                          );
                          return;
                        }
                        setState(() {
                          _mockSubmitting = true;
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          setState(() {
                            _mockSubmitting = false;
                            _step = 2;
                          });
                        });
                      },
                      child: _mockSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Generate OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF042116),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A verification code has been sent to the mobile number registered with Aadhaar ending in XXXX.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 4),
                    decoration: InputDecoration(
                      labelText: '6-digit OTP',
                      counterText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock_open_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A017),
                        foregroundColor: const Color(0xFF042116),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_otpCtrl.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter the 6-digit OTP code')),
                          );
                          return;
                        }
                        setState(() {
                          _mockSubmitting = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.of(context).pop(_aadhaarCtrl.text);
                        });
                      },
                      child: _mockSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Color(0xFF042116), strokeWidth: 2),
                            )
                          : const Text('Verify & Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Verification OTP code resent successfully.')),
                          );
                        },
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Color(0xFFD4A017),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _step = 1;
                          });
                        },
                        child: const Text('Back to Aadhaar Entry', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Trust message
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.security, color: Colors.green, size: 14),
              SizedBox(width: 6),
              Text(
                'Secured via 256-bit encryption',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}
