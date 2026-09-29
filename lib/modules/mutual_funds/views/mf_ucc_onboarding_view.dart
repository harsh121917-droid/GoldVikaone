import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/mutual_funds_controller.dart';
import 'widgets/mf_groww_widgets.dart';

/// Modern Groww-style Paperless Investor KYC (UCC) Onboarding
/// 
/// 1. PAN Input -> Real-time Name Lookup ("Is this you?" confirmation)
/// 2. Only strictly mandated SEBI/NSE details (DOB, Gender, Marital, Occupation)
/// 3. Optional Nominee toggle
/// 4. ZERO bank details asked on this screen (auto-linked during AutoPay/UPI)
class MfUccOnboardingView extends StatefulWidget {
  const MfUccOnboardingView({Key? key}) : super(key: key);

  @override
  State<MfUccOnboardingView> createState() => _MfUccOnboardingViewState();
}

class _MfUccOnboardingViewState extends State<MfUccOnboardingView> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final MutualFundsController controller = Get.find<MutualFundsController>();

  final TextEditingController _panController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(text: '15/08/1995');
  final TextEditingController _nomineeNameController = TextEditingController();

  // PAN Verification State
  bool _isVerifyingPan = false;
  bool _isPanVerified = false;
  String _registeredName = '';
  bool _isNameConfirmed = false;
  String? _panErrorText;
  bool _isFreshInvestor = false;
  final TextEditingController _nameController = TextEditingController();

  // Personal Details
  String _gender = 'M'; // M, F, O
  String _maritalStatus = 'SINGLE'; // SINGLE, MARRIED
  String _occupationCode = '01'; // 01: Private Sector, 02: Public, 03: Business, 04: Professional, 05: Agriculture, 06: Retired, 07: Housewife, 08: Student, 09: Others

  // Nominee Details
  bool _addNominee = false;
  String _nomineeRelation = '20'; // 20: Spouse, 06: Father, 13: Mother, 18: Son, 04: Daughter, 03: Brother, 01: Other

  final List<Map<String, String>> _occupations = const [
    {'code': '01', 'label': 'Private Sector'},
    {'code': '02', 'label': 'Public Sector'},
    {'code': '03', 'label': 'Business / Self-Employed'},
    {'code': '04', 'label': 'Professional'},
    {'code': '08', 'label': 'Student'},
    {'code': '07', 'label': 'Housewife'},
    {'code': '06', 'label': 'Retired'},
    {'code': '09', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    // Prefill if controller already has prefill data from user profile
    final prefillPan = controller.uccPrefill['pan']?.toString() ?? '';
    const dummyPans = ['ABCDE1234F', 'AAAAA0000A', 'XXXXX0000X', 'TYJPS0689R', 'PHOTO_SUBMITTED'];
    if (prefillPan.isNotEmpty && !dummyPans.contains(prefillPan.toUpperCase())) {
      _panController.text = prefillPan.toUpperCase();
      _triggerPanVerification(_panController.text);
    }
  }

  @override
  void dispose() {
    _panController.dispose();
    _dobController.dispose();
    _nomineeNameController.dispose();
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _triggerPanVerification(String pan) async {
    final cleanPan = pan.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(cleanPan)) {
      setState(() {
        _isPanVerified = false;
        _isNameConfirmed = false;
        _registeredName = '';
        _panErrorText = 'Enter a valid 10-character PAN (e.g. ABCDE1234F)';
      });
      return;
    }

    setState(() {
      _isVerifyingPan = true;
      _panErrorText = null;
    });

    try {
      final res = await controller.verifyPan(cleanPan);
      if (res != null && (res['isValid'] == true || res['success'] == true)) {
        final data = res['data'] is Map ? res['data'] as Map<String, dynamic> : res;
        final name = (data['registeredName'] ?? '').toString().trim().toUpperCase();
        final isFresh = data['isFreshInvestor'] == true || data['nseKycStatus'] == 'NEW';

        setState(() {
          _isPanVerified = true;
          _isFreshInvestor = isFresh;
          _registeredName = name;
          _nameController.text = name;
          _isNameConfirmed = false;
          _isVerifyingPan = false;
          _panErrorText = null;
        });
      } else {
        setState(() {
          _isPanVerified = false;
          _registeredName = '';
          _nameController.clear();
          _isNameConfirmed = false;
          _panErrorText = res?['message']?.toString() ?? 'PAN verification failed. Please enter a valid registered PAN.';
          _isVerifyingPan = false;
        });
      }
    } catch (e) {
      setState(() {
        _isPanVerified = false;
        _registeredName = '';
        _isNameConfirmed = false;
        _panErrorText = 'Unable to verify PAN with exchange. Please try again.';
        _isVerifyingPan = false;
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = DateTime(1995, 8, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18, now.month, now.day), // Must be 18+
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: GrowwColors.mintTeal,
              onPrimary: Colors.black,
              surface: Color(0xFF131722),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF131722)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      setState(() {
        _dobController.text = '$day/$month/${picked.year}';
      });
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isPanVerified) {
      Get.snackbar(
        'Verify PAN',
        'Please enter a valid 10-character PAN to proceed.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_isNameConfirmed) {
      Get.snackbar(
        'Confirm Name',
        'Please tap "Yes, That\'s Me" to confirm your registered name.',
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          120,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
      return;
    }

    final res = await controller.registerUcc(
      pan: _panController.text.trim().toUpperCase(),
      fullName: _registeredName,
      dob: _dobController.text.trim(),
      gender: _gender,
      occupationCode: _occupationCode,
      nomineeName: _addNominee ? _nomineeNameController.text.trim() : '',
      nomineeRelation: _addNominee ? _nomineeRelation : '01',
    );

    if (res != null && res['success'] == true) {
      if (!mounted) return;
      _showNseSuccessSheet(res['clientCode']?.toString() ?? '', res['authUrl']?.toString());
    }
  }

  void _showNseSuccessSheet(String clientCode, String? authUrl) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF131722),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: GrowwColors.mintTeal, width: 1.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GrowwColors.mintTeal.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: GrowwColors.mintTeal, size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'NSE Investor Account Created! 🎉',
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Your official NSE Client Code is $clientCode\nNSE MFSS has registered your investor profile.',
                style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Exchange Notice Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GrowwColors.cardElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GrowwColors.goldAccent.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: GrowwColors.goldAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, color: GrowwColors.goldAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Official Exchange OTP Sent by NSE',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'NSE India (NSEINV) sends the official SMS with verification OTP and link to your Aadhaar/PAN linked mobile.',
                            style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (authUrl != null && authUrl.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final uri = Uri.parse(authUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GrowwColors.goldAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_browser_rounded, color: Colors.black, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Open NSE Official Authorization Portal',
                          style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // AutoPay Step 2 button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                    controller.initiateMandateSetup(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GrowwColors.mintTeal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Set Up AutoPay Mandate (Step 2) →',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Explore Mutual Funds',
                    style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowwColors.background,
      appBar: AppBar(
        backgroundColor: GrowwColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investor Account KYC',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2),
            Text(
              'Paperless setup • NSE MFSS & SEBI Verified',
              style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Step Progress Indicator ──
              _buildProgressHeader(),
              const SizedBox(height: 20),

              // ── 1. PAN Input Card ──
              _buildPanSection(),
              const SizedBox(height: 16),

              // ── Groww "Is this you?" Name Confirmation Card ──
              if (_isPanVerified && _registeredName.isNotEmpty) ...[
                _buildNameConfirmationCard(),
                const SizedBox(height: 20),
              ],

              // ── 2. Basic Personal Details (Mandated by SEBI) ──
              _buildPersonalDetailsSection(),
              const SizedBox(height: 20),

              // ── 3. Nominee Section (Optional Groww-Style Toggle) ──
              _buildNomineeSection(),
              const SizedBox(height: 24),

              // ── Trust Badge: Bank Auto-Link Notice (NO Bank Inputs Needed!) ──
              _buildBankNoticeCard(),
              const SizedBox(height: 28),

              // ── Submit Button ──
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step Progress Header ──
  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GrowwColors.mintTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: GrowwColors.mintTeal, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 1 of 2: Investor Profile',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'One-time SEBI registration. No bank details needed now.',
                  style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GrowwColors.mintTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '100% Digital',
              style: TextStyle(color: GrowwColors.mintTeal, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. PAN Input Section ──
  Widget _buildPanSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isPanVerified ? GrowwColors.mintTeal.withOpacity(0.4) : GrowwColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Permanent Account Number (PAN)',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              if (_isPanVerified)
                Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: GrowwColors.mintTeal, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(color: GrowwColors.mintTeal, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'We will fetch your official name from Income Tax records',
            style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // PAN TextField
          TextFormField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'ABCDE1234F',
              hintStyle: TextStyle(
                color: GrowwColors.textTertiary,
                fontSize: 15,
                letterSpacing: 1.5,
              ),
              filled: true,
              fillColor: GrowwColors.cardElevated,
              prefixIcon: const Icon(Icons.badge_outlined, color: GrowwColors.mintTeal, size: 20),
              suffixIcon: _isVerifyingPan
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: GrowwColors.mintTeal),
                      ),
                    )
                  : (_isPanVerified
                      ? const Icon(Icons.check_circle_rounded, color: GrowwColors.mintTeal, size: 22)
                      : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: GrowwColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: GrowwColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: GrowwColors.mintTeal, width: 1.5),
              ),
              errorText: _panErrorText,
            ),
            onChanged: (val) {
              if (val.length == 10) {
                _triggerPanVerification(val);
              } else {
                if (_isPanVerified) {
                  setState(() {
                    _isPanVerified = false;
                    _registeredName = '';
                    _isNameConfirmed = false;
                  });
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Groww Style: "Is this you?" Name Confirmation Card ──
  Widget _buildNameConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isFreshInvestor
              ? [const Color(0xFF162536), const Color(0xFF131722)]
              : [const Color(0xFF0F2621), const Color(0xFF131722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFreshInvestor
              ? Colors.lightBlueAccent.withOpacity(0.5)
              : GrowwColors.mintTeal.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isFreshInvestor ? Colors.lightBlueAccent : GrowwColors.mintTeal).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isFreshInvestor ? Colors.lightBlueAccent : GrowwColors.mintTeal,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFreshInvestor ? Icons.person_add_alt_1_rounded : Icons.check_rounded,
                  color: Colors.black,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isFreshInvestor ? "FIRST-TIME INVESTOR • CONFIRM LEGAL NAME" : "NAME FOUND IN PAN RECORDS (KRA VERIFIED)",
                style: TextStyle(
                  color: _isFreshInvestor ? Colors.lightBlueAccent : GrowwColors.mintTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isFreshInvestor) ...[
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "Enter Full Legal Name as per PAN",
                labelText: "Full Legal Name as per PAN Card",
                labelStyle: const TextStyle(color: Colors.lightBlueAccent, fontSize: 12),
                hintStyle: TextStyle(color: GrowwColors.textTertiary, fontSize: 14),
                filled: true,
                fillColor: GrowwColors.cardElevated,
                prefixIcon: const Icon(Icons.person_outline, color: Colors.lightBlueAccent, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 1.5),
                ),
              ),
              onChanged: (val) {
                _registeredName = val.trim().toUpperCase();
              },
            ),
          ] else ...[
            Text(
              _registeredName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            _isFreshInvestor
                ? "Please confirm your full legal name as per Income Tax records. Fresh investor KYC will be seamlessly processed on NSE."
                : "Confirm if this is your full legal name as per Income Tax records to register with NSE MFSS.",
            style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    if (_nameController.text.trim().isNotEmpty) {
                      _registeredName = _nameController.text.trim().toUpperCase();
                    }
                    if (_registeredName.isEmpty) {
                      Get.snackbar(
                        "Name Required",
                        "Please enter your full legal name as per your PAN card.",
                        backgroundColor: Colors.amber.shade800,
                        colorText: Colors.black,
                      );
                      return;
                    }
                    setState(() => _isNameConfirmed = true);
                    HapticFeedback.lightImpact();
                    Get.snackbar(
                      "Name Confirmed",
                      "Verified as " + _registeredName + ". Please verify details below.",
                      backgroundColor: const Color(0xFF00D09C),
                      colorText: Colors.black,
                      duration: const Duration(seconds: 2),
                      snackPosition: SnackPosition.TOP,
                    );
                    Future.delayed(const Duration(milliseconds: 250), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          260,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    });
                  },
                  icon: Icon(
                    _isNameConfirmed ? Icons.check_circle_rounded : Icons.check_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                  label: Text(
                    _isNameConfirmed
                        ? "Name Confirmed ✓"
                        : (_isFreshInvestor ? "Confirm Legal Name & Continue ✓" : "Yes, That's Me ✓"),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFreshInvestor ? Colors.lightBlueAccent : GrowwColors.mintTeal,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isPanVerified = false;
                    _registeredName = "";
                    _nameController.clear();
                    _isNameConfirmed = false;
                    _panController.clear();
                  });
                },
                child: const Text(
                  "Change PAN",
                  style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. Basic Personal Details (Mandated by SEBI/NSE) ──
  Widget _buildPersonalDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'SEBI mandates these basic details for all mutual fund investors',
            style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Date of Birth Field
          const Text('Date of Birth', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _selectDateOfBirth,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: GrowwColors.cardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GrowwColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: GrowwColors.mintTeal, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _dobController.text.isEmpty ? 'Select Date of Birth' : _dobController.text,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, color: GrowwColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Gender Selection Chips
          const Text('Gender', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChoiceChip(label: 'Male', selected: _gender == 'M', onTap: () => setState(() => _gender = 'M')),
              const SizedBox(width: 8),
              _buildChoiceChip(label: 'Female', selected: _gender == 'F', onTap: () => setState(() => _gender = 'F')),
              const SizedBox(width: 8),
              _buildChoiceChip(label: 'Other', selected: _gender == 'O', onTap: () => setState(() => _gender = 'O')),
            ],
          ),
          const SizedBox(height: 16),

          // Marital Status Chips
          const Text('Marital Status', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildChoiceChip(label: 'Single', selected: _maritalStatus == 'SINGLE', onTap: () => setState(() => _maritalStatus = 'SINGLE')),
              const SizedBox(width: 8),
              _buildChoiceChip(label: 'Married', selected: _maritalStatus == 'MARRIED', onTap: () => setState(() => _maritalStatus = 'MARRIED')),
            ],
          ),
          const SizedBox(height: 16),

          // Occupation Dropdown
          const Text('Occupation', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: GrowwColors.cardElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GrowwColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _occupationCode,
                isExpanded: true,
                dropdownColor: GrowwColors.cardElevated,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: GrowwColors.textSecondary),
                items: _occupations.map((occ) {
                  return DropdownMenuItem<String>(
                    value: occ['code'],
                    child: Text(
                      occ['label']!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _occupationCode = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Nominee Section (Optional Groww-Style Toggle) ──
  Widget _buildNomineeSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nominee Declaration',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Optional • Recommended by SEBI',
                    style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
              Switch(
                value: _addNominee,
                activeColor: GrowwColors.mintTeal,
                activeTrackColor: GrowwColors.mintTeal.withOpacity(0.3),
                inactiveThumbColor: GrowwColors.textSecondary,
                inactiveTrackColor: GrowwColors.cardElevated,
                onChanged: (val) => setState(() => _addNominee = val),
              ),
            ],
          ),
          if (!_addNominee) ...[
            const SizedBox(height: 8),
            const Text(
              'You can skip adding a nominee now and add or update your nominee anytime in account settings.',
              style: TextStyle(color: GrowwColors.textTertiary, fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _nomineeNameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nominee Full Name',
                hintStyle: TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
                filled: true,
                fillColor: GrowwColors.cardElevated,
                prefixIcon: const Icon(Icons.person_outline_rounded, color: GrowwColors.mintTeal, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GrowwColors.mintTeal)),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: GrowwColors.cardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GrowwColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _nomineeRelation,
                  isExpanded: true,
                  dropdownColor: GrowwColors.cardElevated,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: GrowwColors.textSecondary),
                  items: const [
                    DropdownMenuItem(value: '20', child: Text('Spouse', style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: '06', child: Text('Father', style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: '13', child: Text('Mother', style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: '18', child: Text('Son', style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: '04', child: Text('Daughter', style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: '03', child: Text('Brother', style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: '01', child: Text('Other', style: TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _nomineeRelation = val);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Reassuring Notice: NO Bank Details Needed Now ──
  Widget _buildBankNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: GrowwColors.mintTeal.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_outline_rounded, color: GrowwColors.mintTeal, size: 16),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Bank Details Required on this Screen',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Groww-style automated verification: Your bank will be linked seamlessly during Step 2 (AutoPay Mandate) or directly via instant UPI when investing.',
                  style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ──
  Widget _buildSubmitButton() {
    return Obx(() {
      final isLoading = controller.isUccLoading.value;
      final canSubmit = _isPanVerified && _isNameConfirmed && !isLoading;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: canSubmit ? _submitKyc : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: GrowwColors.mintTeal,
            disabledBackgroundColor: GrowwColors.mintTeal.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Activate NSE Investor Account',
                      style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                  ],
                ),
        ),
      );
    });
  }

  Widget _buildChoiceChip({required String label, required bool selected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? GrowwColors.mintTeal : GrowwColors.cardElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? GrowwColors.mintTeal : GrowwColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sleek Groww-Style 6-Digit In-App OTP Verification Modal
