import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/mutual_funds_controller.dart';

class MfUccOnboardingView extends StatefulWidget {
  const MfUccOnboardingView({Key? key}) : super(key: key);

  @override
  State<MfUccOnboardingView> createState() => _MfUccOnboardingViewState();
}

class _MfUccOnboardingViewState extends State<MfUccOnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final MutualFundsController controller = Get.find<MutualFundsController>();

  late final TextEditingController _panController;
  late final TextEditingController _accountNoController;
  late final TextEditingController _ifscController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _nomineeNameController;
  late final TextEditingController _dobController;

  String _nomineeRelation = '01';
  String _gender = 'M';

  @override
  void initState() {
    super.initState();
    final prefill = controller.uccPrefill;
    final bank = prefill['bankAccount'] as Map<String, dynamic>?;

    _panController = TextEditingController(text: prefill['pan']?.toString() ?? '');
    _accountNoController = TextEditingController(text: bank?['accountNo']?.toString() ?? '');
    _ifscController = TextEditingController(text: bank?['ifsc']?.toString() ?? '');
    _bankNameController = TextEditingController(text: bank?['bankName']?.toString() ?? '');
    _nomineeNameController = TextEditingController();
    _dobController = TextEditingController(text: '15/08/1995');
  }

  @override
  void dispose() {
    _panController.dispose();
    _accountNoController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _nomineeNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _fillTestData() {
    setState(() {
      _panController.text = 'TESTP1234K';
      _dobController.text = '15/08/1992';
      _gender = 'M';
      _accountNoController.text = '918273645012';
      _ifscController.text = 'HDFC0000123';
      _bankNameController.text = 'HDFC Bank (Sandbox)';
      _nomineeNameController.text = 'Vikaone Test Nominee';
      _nomineeRelation = '20';
    });

    Get.snackbar(
      'Test Credentials Loaded',
      'NSE Sandbox test investor details auto-filled. Tap activate to proceed!',
      backgroundColor: const Color(0xFF00D09C),
      colorText: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? DarkColors.background : AppColors.background;
    final surface = dark ? DarkColors.surface : AppColors.surface;
    final textPrimary = dark ? Colors.white : AppColors.textPrimary;
    final textSecondary = dark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: dark ? DarkColors.primary : AppColors.primary,
        title: const Text(
          'NSE Investor Activation (UCC)',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E3A8A).withOpacity(0.15),
                      const Color(0xFFD4A017).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'National Stock Exchange of India',
                            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'One-time setup creates your Unique Client Code (UCC) on NSE MFSS for direct mutual fund investments.',
                            style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Sandbox Test Mode Auto-Fill Card ──
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SANDBOX TEST MODE',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.flash_on_rounded, color: Color(0xFF10B981), size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Testing without NSE IP whitelisting? Auto-fill valid mock investor credentials with one tap.',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _fillTestData,
                        icon: const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 18),
                        label: const Text(
                          '⚡ Auto-Fill Test Investor Data',
                          style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text('Personal & KYC Details', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _panController,
                label: 'PAN Card Number',
                hint: 'e.g. ABCDE1234F',
                icon: Icons.credit_card_rounded,
                textPrimary: textPrimary,
                surface: surface,
                validator: (v) => (v == null || v.trim().length != 10) ? 'Enter valid 10-digit PAN' : null,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _dobController,
                      label: 'Date of Birth',
                      hint: 'DD/MM/YYYY',
                      icon: Icons.calendar_today_rounded,
                      textPrimary: textPrimary,
                      surface: surface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        filled: true,
                        fillColor: surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('Male')),
                        DropdownMenuItem(value: 'F', child: Text('Female')),
                        DropdownMenuItem(value: 'O', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'M'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('Linked Bank Account', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _accountNoController,
                label: 'Bank Account Number',
                hint: 'e.g. 1234567890',
                icon: Icons.account_balance_rounded,
                textPrimary: textPrimary,
                surface: surface,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Account number required' : null,
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _ifscController,
                label: 'Bank IFSC Code',
                hint: 'e.g. HDFC0000123',
                icon: Icons.numbers_rounded,
                textPrimary: textPrimary,
                surface: surface,
                validator: (v) => (v == null || v.trim().length != 11) ? 'Enter 11-digit IFSC' : null,
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _bankNameController,
                label: 'Bank Name (Optional)',
                hint: 'e.g. HDFC Bank Ltd',
                icon: Icons.store_rounded,
                textPrimary: textPrimary,
                surface: surface,
              ),
              const SizedBox(height: 24),

              Text('Nominee Details (Optional)', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildTextField(
                controller: _nomineeNameController,
                label: 'Nominee Name',
                hint: 'e.g. Rakesh Sharma',
                icon: Icons.person_outline_rounded,
                textPrimary: textPrimary,
                surface: surface,
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _nomineeRelation,
                decoration: InputDecoration(
                  labelText: 'Nominee Relationship',
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: '20', child: Text('Spouse')),
                  DropdownMenuItem(value: '06', child: Text('Father')),
                  DropdownMenuItem(value: '13', child: Text('Mother')),
                  DropdownMenuItem(value: '18', child: Text('Son')),
                  DropdownMenuItem(value: '04', child: Text('Daughter')),
                  DropdownMenuItem(value: '03', child: Text('Brother')),
                  DropdownMenuItem(value: '01', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _nomineeRelation = v ?? '20'),
              ),
              const SizedBox(height: 32),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isUccLoading.value
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() == true) {
                              final success = await controller.registerUcc(
                                pan: _panController.text,
                                accountNo: _accountNoController.text,
                                ifsc: _ifscController.text,
                                bankName: _bankNameController.text,
                                nomineeName: _nomineeNameController.text,
                                nomineeRelation: _nomineeRelation,
                                dob: _dobController.text,
                                gender: _gender,
                              );
                              if (success) {
                                Get.back(result: true);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: controller.isUccLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Activate NSE Account & Continue',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color textPrimary,
    required Color surface,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: surface,
        prefixIcon: Icon(icon, color: AppColors.accent, size: 22),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.inputBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      ),
    );
  }
}
