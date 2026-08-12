import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/repositories/otp_repository.dart';
import '../controllers/auth_controller.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _danger = Color(0xFFE05A47);

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder, subBg, ctaText;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.ctaText,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF0A0A0C),
          card: Color(0xFF16161B),
          primary: _gold,
          ink: Color(0xFFF5F5F5),
          inkMuted: Color(0xFF8A8A93),
          cardBorder: Color(0x2ED4A017),
          subBg: Color(0xFF1C1C22),
          ctaText: Color(0xFF3D2B00),
        )
      : const _T(
          bg: Color(0xFFF7F4EE),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Colors.transparent,
          subBg: Color(0xFFF3F1EA),
          ctaText: Colors.white,
        );
}

/// Full login flow: email-or-phone + password → OTP always sent to the
/// registered phone (even if the identifier typed was an email) → M-PIN.
class LoginOtpFlowView extends StatefulWidget {
  const LoginOtpFlowView(
      {super.key, this.initialIdentifier, this.initialPassword});
  final String? initialIdentifier;
  final String? initialPassword;
  @override
  State<LoginOtpFlowView> createState() => _LoginOtpFlowViewState();
}

enum _Step { credentials, otp }

class _LoginOtpFlowViewState extends State<LoginOtpFlowView> {
  final _repo = OtpRepository();
  final _idCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _obscure = true;

  _Step _step = _Step.credentials;
  String? _phone; // resolved registered phone, filled after credentials check
  bool _busy = false;
  String? _error;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.initialIdentifier != null)
      _idCtrl.text = widget.initialIdentifier!;
    if (widget.initialPassword != null) _pwCtrl.text = widget.initialPassword!;
    if ((widget.initialIdentifier ?? '').isNotEmpty &&
        (widget.initialPassword ?? '').isNotEmpty) {
      // Auto-continue since the user already filled the form on the previous screen.
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkCredentials());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _checkCredentials() async {
    if (_idCtrl.text.trim().isEmpty || _pwCtrl.text.isEmpty) {
      setState(() => _error = 'Enter your email/phone and password');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final phone = await _repo.verifyCredentials(
        identifier: _idCtrl.text.trim(),
        password: _pwCtrl.text,
      );
      await _repo.sendOtp(phone: phone, purpose: 'login');
      setState(() {
        _phone = phone;
        _step = _Step.otp;
      });
      _startCooldown();
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_phone == null) return;
    _otpCtrl.clear();
    setState(() => _busy = true);
    try {
      await _repo.sendOtp(phone: _phone!, purpose: 'login');
      _startCooldown();
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _verifyAndLogin() async {
    if (_otpCtrl.text.trim().length != 6 || _phone == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final otpRecordId = await _repo.verifyOtp(
        phone: _phone!,
        purpose: 'login',
        code: _otpCtrl.text.trim(),
      );
      final auth = Get.find<AuthController>();
      final ok =
          await auth.loginWithOtp(phone: _phone!, otpRecordId: otpRecordId, email: _idCtrl.text.trim());
      if (!ok) {
        setState(() => _error = auth.errorMsg.value.isNotEmpty
            ? auth.errorMsg.value
            : 'Login failed');
      }
      // On success, AuthController._afterAuth() already navigates to M-PIN.
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return "Connection timeout. Please check your internet connection.";
      }
      return "Network connection issue. Please try again.";
    }

    final s = e.toString();
    final match = RegExp(r'"message":"([^"]+)"').firstMatch(s);
    return match?.group(1) ?? s.replaceAll('Exception:', '').replaceAll('DioException', '').trim();
  }

  String _maskedPhone(String p) =>
      p.length >= 4 ? '••••••${p.substring(p.length - 4)}' : p;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_step == _Step.otp) {
                      setState(() {
                        _step = _Step.credentials;
                        _otpCtrl.clear();
                        _error = null;
                      });
                    } else {
                      Get.back();
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: t.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: t.cardBorder)),
                    child: Icon(Icons.chevron_left_rounded,
                        color: t.ink, size: 24),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _step == _Step.credentials
                      ? 'Welcome Back'
                      : 'Verify It\'s You',
                  style: TextStyle(
                      color: t.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  _step == _Step.credentials
                      ? 'Login with your email or phone number'
                      : 'Enter the 6-digit code sent to ${_maskedPhone(_phone ?? '')}',
                  style:
                      TextStyle(color: t.inkMuted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 32),
                if (_step == _Step.credentials) ...[
                  Text('Email or Phone',
                      style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _InputBox(
                    t: t,
                    child: TextField(
                      controller: _idCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          color: t.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                          border: InputBorder.none, isDense: true),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Password',
                      style: TextStyle(
                          color: t.inkMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _InputBox(
                    t: t,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pwCtrl,
                            obscureText: _obscure,
                            style: TextStyle(
                                color: t.ink,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(
                                border: InputBorder.none, isDense: true),
                            onChanged: (_) => setState(() => _error = null),
                            onSubmitted: (_) => _checkCredentials(),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: t.inkMuted,
                              size: 20),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(_error!,
                        style: const TextStyle(color: _danger, fontSize: 12)),
                  ],
                  const SizedBox(height: 26),
                  _PrimaryButton(
                      label: 'Continue',
                      loading: _busy,
                      enabled: true,
                      onTap: _checkCredentials),
                ] else ...[
                  Center(
                    child: Pinput(
                      length: 6,
                      controller: _otpCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      onCompleted: (_) => _verifyAndLogin(),
                      onChanged: (_) => setState(() => _error = null),
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: TextStyle(
                            color: t.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                        decoration: BoxDecoration(
                            color: t.subBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: t.cardBorder)),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: TextStyle(
                            color: t.ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                        decoration: BoxDecoration(
                          color: t.subBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _gold, width: 1.6),
                          boxShadow: [
                            BoxShadow(
                                color: _gold.withOpacity(0.25), blurRadius: 10)
                          ],
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: TextStyle(
                            color: t.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                        decoration: BoxDecoration(
                            color: _gold.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _gold)),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Center(
                        child: Text(_error!,
                            style:
                                const TextStyle(color: _danger, fontSize: 12),
                            textAlign: TextAlign.center)),
                  ],
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Verify & Login',
                    loading: _busy,
                    enabled: _otpCtrl.text.trim().length == 6,
                    onTap: _verifyAndLogin,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _cooldown > 0
                        ? Text('Resend code in ${_cooldown}s',
                            style: TextStyle(color: t.inkMuted, fontSize: 12))
                        : GestureDetector(
                            onTap: _resend,
                            child: const Text('Resend OTP',
                                style: TextStyle(
                                    color: _gold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _InputBox extends StatelessWidget {
  const _InputBox({required this.t, required this.child});
  final _T t;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
            color: t.subBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.cardBorder)),
        child: child,
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton(
      {required this.label,
      required this.loading,
      required this.enabled,
      required this.onTap});
  final String label;
  final bool loading, enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient:
              active ? const LinearGradient(colors: [_gold, _goldLight]) : null,
          color: active ? null : _gold.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: _gold.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5))
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(label,
                  style: TextStyle(
                      color: active ? const Color(0xFF3D2B00) : Colors.white38,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}
