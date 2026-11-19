import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/fixed_deposits_controller.dart';

class FdApplicationFormView extends StatelessWidget {
  const FdApplicationFormView({super.key});

  // ── Modern Clean Theme Colors ───────────────────────────────
  static const Color _bgLight = Color(0xFFF8F9FE);
  static const Color _cardBg = Colors.white;
  static const Color _cardBorder = Color(0xFFE2E8F0);
  static const Color _accentGold = Color(0xFFD4A017);
  static const Color _accentGreen = Color(0xFF059669);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FixedDepositsController>();

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () {
            if (controller.currentStep.value > 0) {
              controller.previousStep();
            } else {
              Get.back();
            }
          },
        ),
        title: Obx(() {
          final comp = controller.selectedCompany.value?.shortName ?? 'FD';
          return Text(
            'IRIS Application • $comp',
            style: const TextStyle(
              color: _textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          );
        }),
      ),
      body: Obx(() {
        final step = controller.currentStep.value;

        return Column(
          children: [
            // Step Progress Bar & Indicators
            _buildStepIndicator(step),

            // Form Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: _buildCurrentStep(context, controller, step),
              ),
            ),

            // Bottom Navigation Actions
            _buildBottomBar(controller, step),
          ],
        );
      }),
    );
  }

  // ── Step Progress Indicator ──────────────────────────────────
  Widget _buildStepIndicator(int currentStep) {
    final stepTitles = ['Scheme', 'Personal', 'Address', 'Bank', 'Nominee'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isDone = index < currentStep;
              final isCurrent = index == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? _accentGreen
                            : (isCurrent ? _accentGold : const Color(0xFFF1F5F9)),
                        border: Border.all(
                          color: isCurrent
                              ? _accentGold
                              : (isDone ? _accentGreen : const Color(0xFFCBD5E1)),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? Colors.white : _textMuted,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                    ),
                    if (index < 4)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? _accentGreen : const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final isCurrent = index == currentStep;
              return Expanded(
                child: Text(
                  stepTitles[index],
                  textAlign: index == 0
                      ? TextAlign.left
                      : (index == 4 ? TextAlign.right : TextAlign.center),
                  style: TextStyle(
                    color: isCurrent ? _accentGold : _textMuted,
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Step Content Switcher ────────────────────────────────────
  Widget _buildCurrentStep(BuildContext context, FixedDepositsController controller, int step) {
    switch (step) {
      case 0:
        return _buildStep0Scheme(controller);
      case 1:
        return _buildStep1Personal(context, controller);
      case 2:
        return _buildStep2Address(controller);
      case 3:
        return _buildStep3Bank(controller);
      case 4:
        return _buildStep4Nominee(context, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0: Deposit & Scheme Setup ───────────────────────────
  Widget _buildStep0Scheme(FixedDepositsController controller) {
    final calc = controller.calculationResult;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Step 1 of 5', 'Select Issuer & Scheme',
            'Choose your Fixed Deposit issuing company and review your tenure, interest rate, and payout type.'),
        const SizedBox(height: 18),

        // 1. Company Selection Cards
        const Text(
          'Select FD Issuing Company *',
          style: TextStyle(
            color: _textDark,
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),

        ...controller.companies.map((comp) {
          final isSelected = controller.selectedCompany.value?.code == comp.code;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.selectCompany(comp);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFFDF5) : _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _accentGold : _cardBorder,
                  width: isSelected ? 1.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? const Color(0x1AD4A017) : const Color(0x06000000),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? _accentGold : const Color(0xFF94A3B8),
                    size: 22,
                  ),
                  const SizedBox(width: 12),

                  // Company Logo Avatar
                  Container(
                    width: 42,
                    height: 42,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        comp.logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFFFFBEB),
                          child: const Icon(Icons.account_balance_rounded, color: _accentGold, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                comp.name,
                                style: const TextStyle(
                                  color: _textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Text(
                                '${comp.ratingAgency} ${comp.creditRating}',
                                style: const TextStyle(
                                  color: _accentGreen,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Min Deposit: ₹${comp.minAmount.toStringAsFixed(0)} • Up to ${comp.maxRate}% p.a.',
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // 2. Investment Metrics Table
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              _summaryRow('Selected Issuer', controller.selectedCompany.value?.name ?? 'Not Selected', valueColor: _accentGold, isBold: true),
              _summaryRow('Deposit Amount', '₹${calc.depositAmount.toStringAsFixed(0)}'),
              _summaryRow('Tenure', '${calc.tenureMonths} Months (${(calc.tenureMonths / 12).toStringAsFixed(1)} Yrs)'),
              _summaryRow('Interest Rate', '${calc.interestRate}% p.a.', valueColor: _accentGold),
              _summaryRow('Payout Frequency', calc.payoutFrequency.replaceAll('_', ' ')),
              _summaryRow('Auto-Renewal on Maturity', controller.autoRenewal.value ? 'YES' : 'NO'),
              const Divider(color: _cardBorder, height: 22),
              _summaryRow(
                controller.depositType.value == 'CUMULATIVE' ? 'Maturity Value' : 'Periodic Payout',
                controller.depositType.value == 'CUMULATIVE'
                    ? '₹${calc.maturityAmount.toStringAsFixed(0)}'
                    : '₹${calc.periodicPayoutAmount.toStringAsFixed(0)} / ${calc.payoutFrequency.toLowerCase()}',
                valueColor: _accentGreen,
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Auto Renewal Checkbox
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: CheckboxListTile(
            value: controller.autoRenewal.value,
            onChanged: (val) => controller.autoRenewal.value = val ?? false,
            activeColor: _accentGold,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            title: const Text(
              'Auto-renew principal and interest on maturity',
              style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Renew automatically under prevailing interest rate at time of maturity.',
              style: TextStyle(color: _textMuted, fontSize: 11.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 1: Personal & KYC Details ───────────────────────────
  Widget _buildStep1Personal(BuildContext context, FixedDepositsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Step 2 of 5', 'Personal & KYC Details',
            'Enter personal information exactly as registered on your Income Tax PAN record.'),
        const SizedBox(height: 16),

        _inputField(
          label: 'Full Name (as on PAN card) *',
          controller: controller.fullNameController,
          hint: 'e.g. Rohan Suresh Kumar',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'PAN Number *',
          controller: controller.panController,
          hint: 'e.g. ABCDE1234F',
          icon: Icons.badge_outlined,
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
        ),
        const SizedBox(height: 14),

        _buildDobField(
          context: context,
          label: 'Date of Birth (DD-MM-YYYY) *',
          controller: controller.dobController,
          hint: 'DD-MM-YYYY',
          isApplicant: true,
          fdController: controller,
        ),
        const SizedBox(height: 16),

        // Gender Selector
        const Text('Gender *', style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(
          children: [
            _chipOption('Male', 'M', controller.gender),
            const SizedBox(width: 8),
            _chipOption('Female', 'F', controller.gender),
            const SizedBox(width: 8),
            _chipOption('Other', 'O', controller.gender),
          ],
        ),
        const SizedBox(height: 16),

        // Marital Status Selector
        const Text('Marital Status *', style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(
          children: [
            _chipOption('Married', 'MARRIED', controller.maritalStatus),
            const SizedBox(width: 8),
            _chipOption('Single', 'SINGLE', controller.maritalStatus),
            const SizedBox(width: 8),
            _chipOption('Other', 'OTHER', controller.maritalStatus),
          ],
        ),
        const SizedBox(height: 14),

        _inputField(
          label: "Father's or Spouse's Name *",
          controller: controller.fatherOrSpouseNameController,
          hint: "Father's or Spouse's full name",
          icon: Icons.people_outline_rounded,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: "Mother's Maiden Name (Optional)",
          controller: controller.motherMaidenNameController,
          hint: "Mother's name prior to marriage",
          icon: Icons.face_3_outlined,
        ),
        const SizedBox(height: 16),

        // Occupation Dropdown
        const Text('Occupation *', style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.occupation.value,
              dropdownColor: Colors.white,
              isExpanded: true,
              style: const TextStyle(color: _textDark, fontSize: 13.5, fontWeight: FontWeight.w700),
              items: const [
                DropdownMenuItem(value: 'SALARIED', child: Text('Salaried Employee')),
                DropdownMenuItem(value: 'BUSINESS', child: Text('Business / Self Employed')),
                DropdownMenuItem(value: 'PROFESSIONAL', child: Text('Professional (CA/Doctor/Lawyer)')),
                DropdownMenuItem(value: 'RETIRED', child: Text('Retired Senior Citizen')),
                DropdownMenuItem(value: 'HOUSEWIFE', child: Text('Homemaker')),
                DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) controller.occupation.value = val;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Annual Income Dropdown
        const Text('Gross Annual Income Bracket *', style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.annualIncome.value,
              dropdownColor: Colors.white,
              isExpanded: true,
              style: const TextStyle(color: _textDark, fontSize: 13.5, fontWeight: FontWeight.w700),
              items: const [
                DropdownMenuItem(value: 'BELOW_1_LAKH', child: Text('Below ₹1 Lakh')),
                DropdownMenuItem(value: '1_TO_5_LAKH', child: Text('₹1 Lakh – ₹5 Lakhs')),
                DropdownMenuItem(value: '5_TO_10_LAKH', child: Text('₹5 Lakhs – ₹10 Lakhs')),
                DropdownMenuItem(value: '10_TO_25_LAKH', child: Text('₹10 Lakhs – ₹25 Lakhs')),
                DropdownMenuItem(value: 'ABOVE_25_LAKH', child: Text('Above ₹25 Lakhs')),
              ],
              onChanged: (val) {
                if (val != null) controller.annualIncome.value = val;
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Politically Exposed Person (PEP)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: CheckboxListTile(
            value: controller.isPep.value,
            onChanged: (val) => controller.isPep.value = val ?? false,
            activeColor: _accentGold,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            title: const Text(
              'I am a Politically Exposed Person (PEP) or related to one',
              style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Contact & Address ────────────────────────────────
  Widget _buildStep2Address(FixedDepositsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Step 3 of 5', 'Contact & Address Details',
            'Physical address for official certificate dispatch and KYC communication.'),
        const SizedBox(height: 16),

        _inputField(
          label: 'Mobile Number *',
          controller: controller.mobileController,
          hint: '10-digit mobile number',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Email Address *',
          controller: controller.emailController,
          hint: 'name@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Address Line 1 (Flat, House No, Building) *',
          controller: controller.addressLine1Controller,
          hint: 'Flat/House No, Building Name',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Address Line 2 (Street, Landmark, Area)',
          controller: controller.addressLine2Controller,
          hint: 'Road, Area, Landmark',
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _inputField(
                label: 'City *',
                controller: controller.cityController,
                hint: 'e.g. Mumbai',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _inputField(
                label: 'State *',
                controller: controller.stateController,
                hint: 'e.g. Maharashtra',
                icon: Icons.map_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Pincode *',
          controller: controller.pincodeController,
          hint: '6-digit pincode',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
      ],
    );
  }

  // ── Step 3: Bank Account ─────────────────────────────────────
  Widget _buildStep3Bank(FixedDepositsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Step 4 of 5', 'Bank Account for Payouts',
            'Interest payouts and principal maturity funds will be credited directly to this verified bank account.'),
        const SizedBox(height: 16),

        _inputField(
          label: 'Account Holder Name (as per Bank) *',
          controller: controller.accountHolderController,
          hint: 'Name as registered with bank',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Bank Name *',
          controller: controller.bankNameController,
          hint: 'e.g. HDFC Bank, ICICI Bank, SBI',
          icon: Icons.account_balance_rounded,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Account Number *',
          controller: controller.accountNumberController,
          hint: 'Enter bank account number',
          icon: Icons.credit_card_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'Confirm Account Number *',
          controller: controller.confirmAccountNumberController,
          hint: 'Re-enter bank account number',
          icon: Icons.check_circle_outline_rounded,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),

        _inputField(
          label: 'IFSC Code *',
          controller: controller.ifscController,
          hint: 'e.g. HDFC0001234',
          icon: Icons.domain_rounded,
          textCapitalization: TextCapitalization.characters,
          maxLength: 11,
        ),
        const SizedBox(height: 16),

        // Account Type Selector
        const Text('Account Type *', style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(
          children: [
            _chipOption('Savings Account', 'SAVINGS', controller.accountType),
            const SizedBox(width: 12),
            _chipOption('Current Account', 'CURRENT', controller.accountType),
          ],
        ),
      ],
    );
  }

  // ── Step 4: Nominee & Tax Declarations ────────────────────────
  Widget _buildStep4Nominee(BuildContext context, FixedDepositsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeader('Step 5 of 5', 'Nominee & Declarations',
            'Add a nominee to ensure seamless transmission of your deposit, and declare tax exemption if applicable.'),
        const SizedBox(height: 16),

        // Nominee Toggle
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
          ),
          child: SwitchListTile(
            value: controller.hasNominee.value,
            onChanged: (val) => controller.hasNominee.value = val,
            activeColor: _accentGold,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            title: const Text('Add Nominee for this Deposit',
                style: TextStyle(color: _textDark, fontSize: 13.5, fontWeight: FontWeight.w800)),
            subtitle: const Text('Highly recommended for asset safety and legal compliance.',
                style: TextStyle(color: _textMuted, fontSize: 11.5)),
          ),
        ),
        const SizedBox(height: 14),

        if (controller.hasNominee.value) ...[
          _inputField(
            label: 'Nominee Full Name *',
            controller: controller.nomineeNameController,
            hint: 'Nominee legal name',
            icon: Icons.person_pin_rounded,
          ),
          const SizedBox(height: 14),

          _inputField(
            label: 'Relationship with Applicant *',
            controller: controller.nomineeRelationController,
            hint: 'e.g. Spouse, Son, Daughter, Mother, Father',
            icon: Icons.family_restroom_rounded,
          ),
          const SizedBox(height: 14),

          _buildDobField(
            context: context,
            label: 'Nominee Date of Birth (DD-MM-YYYY) *',
            controller: controller.nomineeDobController,
            hint: 'DD-MM-YYYY',
            isApplicant: false,
            fdController: controller,
          ),
          const SizedBox(height: 14),

          _inputField(
            label: 'Nominee Address (Optional if same as applicant)',
            controller: controller.nomineeAddressController,
            hint: 'Leave blank if address is same as applicant',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder),
            ),
            child: CheckboxListTile(
              value: controller.nomineeIsMinor.value,
              onChanged: (val) => controller.nomineeIsMinor.value = val ?? false,
              activeColor: _accentGold,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              title: const Text('Nominee is a minor (under 18 years)',
                  style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
          ),

          if (controller.nomineeIsMinor.value) ...[
            const SizedBox(height: 12),
            _inputField(
              label: 'Guardian Full Name *',
              controller: controller.guardianNameController,
              hint: 'Guardian legal name',
              icon: Icons.supervisor_account_rounded,
            ),
            const SizedBox(height: 14),
            _inputField(
              label: 'Guardian PAN Number *',
              controller: controller.guardianPanController,
              hint: 'Guardian PAN',
              icon: Icons.badge_outlined,
              textCapitalization: TextCapitalization.characters,
              maxLength: 10,
            ),
          ],
          const SizedBox(height: 18),
        ],

        // Form 15G / 15H Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tax Deduction at Source (TDS) & Form 15G/15H',
                style: TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'If your estimated total taxable income is below basic exemption limit, you can declare Form 15G/15H for zero TDS deduction on interest.',
                style: TextStyle(color: _textMuted, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 10),

              SwitchListTile(
                value: controller.submitForm15g15h.value,
                onChanged: (val) => controller.submitForm15g15h.value = val,
                activeColor: _accentGold,
                contentPadding: EdgeInsets.zero,
                title: const Text('Submit Form 15G / 15H Declaration',
                    style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w800)),
              ),

              if (controller.submitForm15g15h.value) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    _chipOption('Form 15G (Below 60 yrs)', '15G', controller.form15Type),
                    const SizedBox(width: 10),
                    _chipOption('Form 15H (Senior 60+ yrs)', '15H', controller.form15Type),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Final Terms Acceptance
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
          ),
          child: CheckboxListTile(
            value: controller.termsAccepted.value,
            onChanged: (val) => controller.termsAccepted.value = val ?? false,
            activeColor: _accentGold,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            title: const Text(
              'I accept the Terms & Conditions and authorize VikaOne to submit my application on the IRIS platform on my behalf.',
              style: TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'I certify that all details furnished above are accurate, and match my official PAN and Bank records.',
              style: TextStyle(color: _textMuted, fontSize: 11.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────
  Widget _buildBottomBar(FixedDepositsController controller, int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _cardBorder)),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.previousStep();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textDark,
                  side: const BorderSide(color: _cardBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      controller.nextStep();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGold,
                foregroundColor: const Color(0xFF1A2340),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A2340)),
                    )
                  : Text(
                      currentStep == 4 ? 'Submit IRIS Application' : 'Save & Continue',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────
  Widget _stepHeader(String stepBadge, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            stepBadge.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFB45309),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: _textMuted, fontSize: 12.5, height: 1.4),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maxLength: maxLength,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _accentGold, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chipOption(String label, String value, RxString target) {
    return Obx(() {
      final isCur = target.value == value;
      return Expanded(
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            target.value = value;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isCur ? const Color(0xFFFFFBEB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCur ? _accentGold : _cardBorder,
                width: isCur ? 1.5 : 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isCur ? const Color(0xFFB45309) : _textDark,
                fontSize: 11.5,
                fontWeight: isCur ? FontWeight.w900 : FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    });
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: _textMuted, fontSize: 12.5)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? _textDark,
              fontSize: isBold ? 14.5 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate({
    required BuildContext context,
    required TextEditingController controller,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    void Function(DateTime)? onDateSelected,
  }) async {
    DateTime parsedInitial = initialDate;
    if (controller.text.isNotEmpty) {
      try {
        final clean = controller.text.trim().replaceAll('/', '-');
        final parts = clean.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            parsedInitial = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else if (parts[2].length == 4) {
            parsedInitial = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      } catch (_) {}
    }
    if (parsedInitial.isBefore(firstDate)) parsedInitial = firstDate;
    if (parsedInitial.isAfter(lastDate)) parsedInitial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: parsedInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _accentGold,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textDark,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = '$d-$m-$y';
      if (onDateSelected != null) {
        onDateSelected(picked);
      }
    }
  }

  Widget _buildDobField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    String hint = 'DD-MM-YYYY',
    bool isApplicant = false,
    FixedDepositsController? fdController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _textDark, fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _cardBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 10,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\/\-]')),
              DateAutoFormatter(),
            ],
            onChanged: (val) {
              if (fdController != null) {
                if (isApplicant) {
                  fdController.checkSeniorCitizenFromDob(val);
                } else {
                  fdController.checkNomineeMinorFromDob(val);
                }
              }
            },
            style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.cake_outlined, color: _accentGold, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: _accentGold, size: 22),
                tooltip: 'Select date from calendar',
                onPressed: () {
                  final now = DateTime.now();
                  if (isApplicant) {
                    _selectDate(
                      context: context,
                      controller: controller,
                      initialDate: DateTime(now.year - 30, now.month, now.day),
                      firstDate: DateTime(1920, 1, 1),
                      lastDate: now,
                      onDateSelected: (dt) {
                        if (fdController != null) {
                          fdController.checkSeniorCitizenFromDob('${dt.year}-${dt.month}-${dt.day}');
                        }
                      },
                    );
                  } else {
                    _selectDate(
                      context: context,
                      controller: controller,
                      initialDate: DateTime(now.year - 20, now.month, now.day),
                      firstDate: DateTime(1920, 1, 1),
                      lastDate: now,
                      onDateSelected: (dt) {
                        if (fdController != null) {
                          fdController.checkNomineeMinorFromDob('${dt.year}-${dt.month}-${dt.day}');
                        }
                      },
                    );
                  }
                },
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
      ],
    );
  }
}

class DateAutoFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if ((i == 1 || i == 3) && i != digits.length - 1) {
        buffer.write('-');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
