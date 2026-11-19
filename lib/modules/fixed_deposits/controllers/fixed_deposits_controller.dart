import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/fd_models.dart';
import '../../../data/repositories/fd_repository.dart';

class FixedDepositsController extends GetxController {
  final FdRepository _repository = FdRepository();

  // ── States ──────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<FdCompanyModel> companies = <FdCompanyModel>[].obs;
  final Rx<FdCompanyModel?> selectedCompany = Rx<FdCompanyModel?>(null);
  final RxMap<String, dynamic> prefillData = <String, dynamic>{}.obs;

  // ── Calculator & Scheme Selection ───────────────────────────
  final RxDouble depositAmount = 50000.0.obs;
  final RxInt selectedTenureMonths = 36.obs;
  final RxString depositType = 'CUMULATIVE'.obs; // CUMULATIVE or NON_CUMULATIVE
  final RxString payoutFrequency = 'CUMULATIVE'.obs; // CUMULATIVE, MONTHLY, QUARTERLY, HALF_YEARLY, ANNUALLY
  final RxBool isSeniorCitizen = false.obs;
  final RxBool isWomenInvestor = false.obs;
  final RxBool autoRenewal = false.obs;

  // ── Multi-Step Application Form ─────────────────────────────
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 5;

  // Step 1: Personal & KYC
  final fullNameController = TextEditingController();
  final panController = TextEditingController();
  final dobController = TextEditingController();
  final RxString gender = 'M'.obs;
  final RxString maritalStatus = 'MARRIED'.obs;
  final fatherOrSpouseNameController = TextEditingController();
  final motherMaidenNameController = TextEditingController();
  final RxString occupation = 'SALARIED'.obs;
  final RxString annualIncome = '5_TO_10_LAKH'.obs;
  final RxBool isPep = false.obs;

  // Step 2: Contact & Address
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Step 3: Bank Account
  final accountHolderController = TextEditingController();
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final RxString accountType = 'SAVINGS'.obs;

  // Step 4: Nominee & Declarations
  final RxBool hasNominee = true.obs;
  final nomineeNameController = TextEditingController();
  final nomineeRelationController = TextEditingController();
  final nomineeDobController = TextEditingController();
  final nomineeAddressController = TextEditingController();
  final RxBool nomineeIsMinor = false.obs;
  final guardianNameController = TextEditingController();
  final guardianPanController = TextEditingController();
  final RxBool submitForm15g15h = false.obs;
  final RxString form15Type = '15G'.obs; // 15G or 15H
  final RxBool termsAccepted = false.obs;

  // ── My Applications ─────────────────────────────────────────
  final RxList<FdApplicationModel> myApplications = <FdApplicationModel>[].obs;
  final RxBool isLoadingMyApps = false.obs;

  // ── Default Master Companies (Offline / Instant Fallback) ──
  static final List<FdCompanyModel> defaultMasterCompanies = [
    FdCompanyModel(
      code: 'BAJAJ',
      name: 'Bajaj Finance Limited',
      shortName: 'Bajaj Finance',
      tagline: 'Highest safety rating with attractive stable returns',
      creditRating: 'AAA',
      ratingAgency: 'CRISIL & ICRA',
      minAmount: 15000,
      maxAmount: 50000000,
      maxRate: 8.85,
      seniorCitizenBonus: 0.25,
      womenInvestorBonus: 0.0,
      tenuresMonths: [12, 24, 36, 48, 60],
      payoutOptions: ['CUMULATIVE', 'MONTHLY', 'QUARTERLY', 'HALF_YEARLY', 'ANNUALLY'],
      highlights: [
        'Highest CRISIL AAA and ICRA AAA safety ratings with zero default track record.',
        'Over 50 Lakh+ active fixed deposit customer base across India.',
        'Instant loan against FD available up to 75% of deposit value.',
      ],
      schemes: [
        FdSchemeModel(tenureMonths: 12, generalRate: 7.40, seniorCitizenRate: 7.65, womenRate: 7.40, label: '12 Months'),
        FdSchemeModel(tenureMonths: 24, generalRate: 7.80, seniorCitizenRate: 8.05, womenRate: 7.80, label: '24 Months'),
        FdSchemeModel(tenureMonths: 36, generalRate: 8.10, seniorCitizenRate: 8.35, womenRate: 8.10, label: '36 Months', tag: 'POPULAR'),
        FdSchemeModel(tenureMonths: 48, generalRate: 8.40, seniorCitizenRate: 8.65, womenRate: 8.40, label: '48 Months'),
        FdSchemeModel(tenureMonths: 60, generalRate: 8.60, seniorCitizenRate: 8.85, womenRate: 8.60, label: '60 Months', tag: 'BEST VALUE'),
      ],
    ),
    FdCompanyModel(
      code: 'SHRIRAM',
      name: 'Shriram Finance Limited',
      shortName: 'Shriram Finance',
      tagline: 'India’s largest retail NBFC offering industry-best interest yields',
      creditRating: 'AA+',
      ratingAgency: 'CRISIL & India Ratings',
      minAmount: 5000,
      maxAmount: 50000000,
      maxRate: 8.80,
      seniorCitizenBonus: 0.50,
      womenInvestorBonus: 0.10,
      tenuresMonths: [12, 24, 36, 48, 60],
      payoutOptions: ['CUMULATIVE', 'MONTHLY', 'QUARTERLY', 'HALF_YEARLY', 'ANNUALLY'],
      highlights: [
        'Special extra 0.50% p.a. for senior citizens and 0.10% p.a. for women depositors.',
        'Low minimum investment starting from just ₹5,000.',
        'Over 45+ years of trusted track record in Indian financial services.',
      ],
      schemes: [
        FdSchemeModel(tenureMonths: 12, generalRate: 7.60, seniorCitizenRate: 8.10, womenRate: 7.70, label: '12 Months'),
        FdSchemeModel(tenureMonths: 24, generalRate: 7.95, seniorCitizenRate: 8.45, womenRate: 8.05, label: '24 Months'),
        FdSchemeModel(tenureMonths: 36, generalRate: 8.15, seniorCitizenRate: 8.65, womenRate: 8.25, label: '36 Months', tag: 'RECOMMENDED'),
        FdSchemeModel(tenureMonths: 48, generalRate: 8.20, seniorCitizenRate: 8.70, womenRate: 8.30, label: '48 Months'),
        FdSchemeModel(tenureMonths: 60, generalRate: 8.20, seniorCitizenRate: 8.80, womenRate: 8.30, label: '60 Months'),
      ],
    ),
    FdCompanyModel(
      code: 'MAHINDRA',
      name: 'Mahindra & Mahindra Financial Services',
      shortName: 'Mahindra Finance',
      tagline: 'Backed by the legendary trust and stability of the Mahindra Group',
      creditRating: 'AAA',
      ratingAgency: 'CRISIL & India Ratings',
      minAmount: 5000,
      maxAmount: 50000000,
      maxRate: 8.05,
      seniorCitizenBonus: 0.25,
      womenInvestorBonus: 0.0,
      tenuresMonths: [12, 24, 36, 48, 60],
      payoutOptions: ['CUMULATIVE', 'MONTHLY', 'QUARTERLY', 'HALF_YEARLY', 'ANNUALLY'],
      highlights: [
        'Backed by Mahindra & Mahindra Group conglomerate.',
        'CRISIL AAA and India Ratings AAA highest investment-grade safety.',
        'Convenient interest credit directly via ECS / NEFT.',
      ],
      schemes: [
        FdSchemeModel(tenureMonths: 12, generalRate: 7.45, seniorCitizenRate: 7.70, womenRate: 7.45, label: '12 Months'),
        FdSchemeModel(tenureMonths: 24, generalRate: 7.65, seniorCitizenRate: 7.90, womenRate: 7.65, label: '24 Months'),
        FdSchemeModel(tenureMonths: 36, generalRate: 7.75, seniorCitizenRate: 8.00, womenRate: 7.75, label: '36 Months', tag: 'SAFE RETURN'),
        FdSchemeModel(tenureMonths: 48, generalRate: 7.75, seniorCitizenRate: 8.00, womenRate: 7.75, label: '48 Months'),
        FdSchemeModel(tenureMonths: 60, generalRate: 7.75, seniorCitizenRate: 8.05, womenRate: 7.75, label: '60 Months'),
      ],
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Pre-populate with default companies immediately so selectedCompany is NEVER null
    companies.assignAll(defaultMasterCompanies);
    selectedCompany.value = defaultMasterCompanies.first;
    loadCompanies();
    loadMyApplications();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    panController.dispose();
    dobController.dispose();
    fatherOrSpouseNameController.dispose();
    motherMaidenNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    accountHolderController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();
    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    nomineeDobController.dispose();
    nomineeAddressController.dispose();
    guardianNameController.dispose();
    guardianPanController.dispose();
    super.onClose();
  }

  // ── 1. Load Companies & Initialize ──────────────────────────
  Future<void> loadCompanies() async {
    try {
      isLoading.value = true;
      final res = await _repository.getCompanies();
      final list = res['companies'] as List<FdCompanyModel>;
      if (list.isNotEmpty) {
        companies.assignAll(list);
      }
      prefillData.assignAll(res['prefill'] as Map<String, dynamic>? ?? {});

      if (selectedCompany.value == null && companies.isNotEmpty) {
        selectedCompany.value = companies.first;
      }
      if (selectedCompany.value != null && selectedCompany.value!.tenuresMonths.isNotEmpty) {
        if (!selectedCompany.value!.tenuresMonths.contains(selectedTenureMonths.value)) {
          selectedTenureMonths.value = selectedCompany.value!.tenuresMonths.contains(36)
              ? 36
              : selectedCompany.value!.tenuresMonths.first;
        }
      }

      applyPrefillData();
    } catch (_) {
      // Default master companies remain safely active
    } finally {
      isLoading.value = false;
    }
  }

  void selectCompany(FdCompanyModel company) {
    selectedCompany.value = company;
    if (!company.tenuresMonths.contains(selectedTenureMonths.value)) {
      selectedTenureMonths.value = company.tenuresMonths.first;
    }
    if (depositAmount.value < company.minAmount) {
      depositAmount.value = company.minAmount;
    }
  }

  // ── 2. Dynamic Return & Maturity Calculations ────────────────
  double get currentInterestRate {
    final company = selectedCompany.value;
    if (company == null) return 8.0;

    // Find scheme matching current tenure
    final matchedScheme = company.schemes.firstWhereOrNull(
      (s) => s.tenureMonths == selectedTenureMonths.value,
    );

    double rate = matchedScheme?.generalRate ?? company.maxRate;

    if (isSeniorCitizen.value) {
      rate += company.seniorCitizenBonus;
    } else if (isWomenInvestor.value && company.womenInvestorBonus > 0) {
      rate += company.womenInvestorBonus;
    }

    return double.parse(rate.toStringAsFixed(2));
  }

  FdCalculationResult get calculationResult {
    final P = depositAmount.value;
    final r = currentInterestRate / 100.0;
    final tYears = selectedTenureMonths.value / 12.0;

    if (depositType.value == 'CUMULATIVE') {
      // Compounded quarterly: A = P * (1 + r/4)^(4 * t)
      final n = 4.0;
      final maturity = P * pow((1 + (r / n)), (n * tYears));
      final totalInterest = maturity - P;
      return FdCalculationResult(
        depositAmount: P,
        tenureMonths: selectedTenureMonths.value,
        interestRate: currentInterestRate,
        depositType: 'CUMULATIVE',
        payoutFrequency: 'CUMULATIVE',
        maturityAmount: double.parse(maturity.toStringAsFixed(2)),
        periodicPayoutAmount: 0.0,
        totalInterestEarned: double.parse(totalInterest.toStringAsFixed(2)),
      );
    } else {
      // Non-cumulative periodic interest
      double periodsPerYear = 1.0;
      if (payoutFrequency.value == 'MONTHLY') periodsPerYear = 12.0;
      if (payoutFrequency.value == 'QUARTERLY') periodsPerYear = 4.0;
      if (payoutFrequency.value == 'HALF_YEARLY') periodsPerYear = 2.0;
      if (payoutFrequency.value == 'ANNUALLY') periodsPerYear = 1.0;

      final periodicPayout = (P * r) / periodsPerYear;
      final totalPeriods = periodsPerYear * tYears;
      final totalInterest = periodicPayout * totalPeriods;
      final maturity = P;

      return FdCalculationResult(
        depositAmount: P,
        tenureMonths: selectedTenureMonths.value,
        interestRate: currentInterestRate,
        depositType: 'NON_CUMULATIVE',
        payoutFrequency: payoutFrequency.value,
        maturityAmount: double.parse(maturity.toStringAsFixed(2)),
        periodicPayoutAmount: double.parse(periodicPayout.toStringAsFixed(2)),
        totalInterestEarned: double.parse(totalInterest.toStringAsFixed(2)),
      );
    }
  }

  // ── 3. Prefill Form from KYC & User Profile ─────────────────
  void applyPrefillData() {
    if (prefillData.isEmpty) return;

    final user = prefillData['user'] as Map<String, dynamic>? ?? {};
    final kyc = prefillData['kyc'] as Map<String, dynamic>? ?? {};
    final addr = kyc['address'] as Map<String, dynamic>? ?? {};
    final bank = kyc['bankDetails'] as Map<String, dynamic>? ?? {};

    if (fullNameController.text.isEmpty) {
      fullNameController.text = (kyc['fullName'] ?? user['name'] ?? '').toString();
    }
    if (panController.text.isEmpty) {
      panController.text = (kyc['panNumber'] ?? '').toString().toUpperCase();
    }
    if (dobController.text.isEmpty && kyc['dob'] != null) {
      final raw = kyc['dob'].toString().split('T').first;
      final parts = raw.split('-');
      if (parts.length == 3 && parts[0].length == 4) {
        dobController.text = '${parts[2]}-${parts[1]}-${parts[0]}';
      } else {
        dobController.text = raw;
      }
      checkSeniorCitizenFromDob(raw);
    }
    if (mobileController.text.isEmpty) {
      mobileController.text = (user['phone'] ?? '').toString().replaceAll('+91', '');
    }
    if (emailController.text.isEmpty) {
      emailController.text = (user['email'] ?? '').toString();
    }
    if (addressLine1Controller.text.isEmpty) {
      addressLine1Controller.text = (addr['line1'] ?? '').toString();
    }
    if (cityController.text.isEmpty) {
      cityController.text = (addr['city'] ?? '').toString();
    }
    if (stateController.text.isEmpty) {
      stateController.text = (addr['state'] ?? '').toString();
    }
    if (pincodeController.text.isEmpty) {
      pincodeController.text = (addr['pincode'] ?? '').toString();
    }
    if (accountHolderController.text.isEmpty) {
      accountHolderController.text = (bank['accountHolderName'] ?? kyc['fullName'] ?? user['name'] ?? '').toString();
    }
    if (bankNameController.text.isEmpty) {
      bankNameController.text = (bank['bankName'] ?? '').toString();
    }
    if (accountNumberController.text.isEmpty) {
      final acc = (bank['accountNumber'] ?? '').toString();
      accountNumberController.text = acc;
      confirmAccountNumberController.text = acc;
    }
    if (ifscController.text.isEmpty) {
      ifscController.text = (bank['ifscCode'] ?? '').toString().toUpperCase();
    }
  }

  // ── 4. Form Wizard Validation & Navigation ──────────────────
  String normalizeDob(String val) {
    final clean = val.trim().replaceAll('/', '-');
    final parts = clean.split('-');
    if (parts.length == 3) {
      if (parts[0].length <= 2 && parts[2].length == 4) {
        // DD-MM-YYYY -> YYYY-MM-DD
        final d = parts[0].padLeft(2, '0');
        final m = parts[1].padLeft(2, '0');
        final y = parts[2];
        return '$y-$m-$d';
      } else if (parts[0].length == 4 && parts[2].length <= 2) {
        // YYYY-MM-DD
        final y = parts[0];
        final m = parts[1].padLeft(2, '0');
        final d = parts[2].padLeft(2, '0');
        return '$y-$m-$d';
      }
    }
    return clean;
  }

  void checkSeniorCitizenFromDob(String dobStr) {
    try {
      final norm = normalizeDob(dobStr);
      final dt = DateTime.parse(norm);
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      if (age >= 60) {
        isSeniorCitizen.value = true;
      }
    } catch (_) {}
  }

  void checkNomineeMinorFromDob(String dobStr) {
    try {
      final norm = normalizeDob(dobStr);
      final dt = DateTime.parse(norm);
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      nomineeIsMinor.value = (age < 18);
    } catch (_) {}
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        // Deposit Details
        if (selectedCompany.value == null && companies.isNotEmpty) {
          selectedCompany.value = companies.first;
        }
        if (selectedCompany.value == null) {
          Get.snackbar('Select Company', 'Please select a Fixed Deposit issuing company.');
          return false;
        }
        if (depositAmount.value < selectedCompany.value!.minAmount) {
          depositAmount.value = selectedCompany.value!.minAmount;
        }
        return true;

      case 1:
        // Personal & KYC
        if (fullNameController.text.trim().isEmpty) {
          Get.snackbar('Required', 'Please enter your Full Name as per PAN.');
          return false;
        }
        final pan = panController.text.trim().toUpperCase();
        if (pan.length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(pan)) {
          Get.snackbar('Invalid PAN', 'Please enter a valid 10-character PAN number (e.g. ABCDE1234F).');
          return false;
        }
        final dobStr = dobController.text.trim();
        if (dobStr.isEmpty) {
          Get.snackbar('Required', 'Please enter your Date of Birth.');
          return false;
        }
        final normalizedDob = normalizeDob(dobStr);
        if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normalizedDob)) {
          Get.snackbar('Invalid Date', 'Please enter Date of Birth in DD-MM-YYYY or YYYY-MM-DD format.');
          return false;
        }
        dobController.text = normalizedDob;
        checkSeniorCitizenFromDob(normalizedDob);
        if (fatherOrSpouseNameController.text.trim().isEmpty) {
          Get.snackbar('Required', "Please enter Father's or Spouse's Name.");
          return false;
        }
        return true;

      case 2:
        // Contact & Address
        final mob = mobileController.text.trim();
        if (mob.length < 10) {
          Get.snackbar('Invalid Mobile', 'Please enter a valid 10-digit mobile number.');
          return false;
        }
        final email = emailController.text.trim();
        if (email.isEmpty || !GetUtils.isEmail(email)) {
          Get.snackbar('Invalid Email', 'Please enter a valid email address for FD certificate delivery.');
          return false;
        }
        if (addressLine1Controller.text.trim().isEmpty) {
          Get.snackbar('Required', 'Please enter Address Line 1.');
          return false;
        }
        if (cityController.text.trim().isEmpty) {
          Get.snackbar('Required', 'Please enter your City.');
          return false;
        }
        if (stateController.text.trim().isEmpty) {
          Get.snackbar('Required', 'Please enter your State.');
          return false;
        }
        final pin = pincodeController.text.trim();
        if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
          Get.snackbar('Invalid PIN', 'Please enter a valid 6-digit Pincode.');
          return false;
        }
        return true;

      case 3:
        // Bank Details
        if (accountHolderController.text.trim().isEmpty) {
          Get.snackbar('Required', 'Please enter Bank Account Holder Name.');
          return false;
        }
        if (accountNumberController.text.trim().isEmpty) {
          Get.snackbar('Required', 'Please enter Bank Account Number.');
          return false;
        }
        if (accountNumberController.text.trim() != confirmAccountNumberController.text.trim()) {
          Get.snackbar('Mismatch', 'Bank Account Number does not match confirmation.');
          return false;
        }
        final ifsc = ifscController.text.trim().toUpperCase();
        if (ifsc.length != 11 || !RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
          Get.snackbar('Invalid IFSC', 'Please enter a valid 11-character IFSC Code (e.g. HDFC0001234).');
          return false;
        }
        return true;

      case 4:
        // Nominee & Terms
        if (hasNominee.value) {
          if (nomineeNameController.text.trim().isEmpty) {
            Get.snackbar('Required', 'Please enter Nominee Name.');
            return false;
          }
          if (nomineeRelationController.text.trim().isEmpty) {
            Get.snackbar('Required', 'Please enter Relationship with Nominee.');
            return false;
          }
          final nDob = nomineeDobController.text.trim();
          if (nDob.isEmpty) {
            Get.snackbar('Required', 'Please enter Nominee Date of Birth.');
            return false;
          }
          final normNomDob = normalizeDob(nDob);
          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(normNomDob)) {
            Get.snackbar('Invalid Date', 'Please enter Nominee Date of Birth in DD-MM-YYYY or YYYY-MM-DD format.');
            return false;
          }
          nomineeDobController.text = normNomDob;
          checkNomineeMinorFromDob(normNomDob);
        }
        if (!termsAccepted.value) {
          Get.snackbar('Declaration', 'Please agree to the FD application terms and declarations.');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  void nextStep() {
    if (validateStep(currentStep.value)) {
      if (currentStep.value < totalSteps - 1) {
        currentStep.value++;
      } else {
        submitApplication();
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // ── 5. Submit FD Application ─────────────────────────────────
  Future<void> submitApplication() async {
    if (!validateStep(currentStep.value)) return;

    try {
      isSubmitting.value = true;
      final calc = calculationResult;

      final payload = {
        'company': selectedCompany.value!.code,
        'depositDetails': {
          'depositType': depositType.value,
          'payoutFrequency': depositType.value == 'CUMULATIVE' ? 'CUMULATIVE' : payoutFrequency.value,
          'amount': depositAmount.value,
          'tenureMonths': selectedTenureMonths.value,
          'interestRate': currentInterestRate,
          'seniorCitizen': isSeniorCitizen.value,
          'womenInvestor': isWomenInvestor.value,
          'autoRenewal': autoRenewal.value,
          'maturityAmount': calc.maturityAmount,
          'periodicPayoutAmount': calc.periodicPayoutAmount,
        },
        'personalDetails': {
          'fullName': fullNameController.text.trim(),
          'panNumber': panController.text.trim().toUpperCase(),
          'dob': normalizeDob(dobController.text),
          'gender': gender.value,
          'maritalStatus': maritalStatus.value,
          'fatherOrSpouseName': fatherOrSpouseNameController.text.trim(),
          'motherMaidenName': motherMaidenNameController.text.trim(),
          'occupation': occupation.value,
          'annualIncome': annualIncome.value,
          'isPep': isPep.value,
          'residentStatus': 'RESIDENT_INDIVIDUAL',
        },
        'contactDetails': {
          'mobileNumber': mobileController.text.trim(),
          'email': emailController.text.trim().toLowerCase(),
          'addressLine1': addressLine1Controller.text.trim(),
          'addressLine2': addressLine2Controller.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
          'country': 'India',
        },
        'bankDetails': {
          'accountHolderName': accountHolderController.text.trim(),
          'bankName': bankNameController.text.trim(),
          'accountNumber': accountNumberController.text.trim(),
          'ifscCode': ifscController.text.trim().toUpperCase(),
          'accountType': accountType.value,
        },
        'nomineeDetails': {
          'hasNominee': hasNominee.value,
          'nomineeName': hasNominee.value ? nomineeNameController.text.trim() : null,
          'relationship': hasNominee.value ? nomineeRelationController.text.trim() : null,
          'nomineeDob': hasNominee.value ? normalizeDob(nomineeDobController.text) : null,
          'nomineeAddress': hasNominee.value ? nomineeAddressController.text.trim() : null,
          'isMinor': nomineeIsMinor.value,
          'guardianName': nomineeIsMinor.value ? guardianNameController.text.trim() : null,
          'guardianPan': nomineeIsMinor.value ? guardianPanController.text.trim().toUpperCase() : null,
        },
        'declarations': {
          'form15G15H': submitForm15g15h.value,
          'formType': submitForm15g15h.value ? form15Type.value : null,
          'termsAccepted': termsAccepted.value,
        },
      };

      final response = await _repository.submitApplication(payload);
      final newApp = response['data'] as Map<String, dynamic>?;
      final appId = newApp?['applicationId'] ?? 'FD-SUBMITTED';

      // Reload applications list
      await loadMyApplications();

      // Show Success Dialog
      _showSuccessDialog(appId);

    } catch (e) {
      Get.snackbar(
        'Submission Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccessDialog(String appId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFECFDF5),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 38),
              ),
              const SizedBox(height: 18),
              const Text(
                'FD Application Submitted!',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  'Application ID: $appId',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Our wealth operations desk is punching your application into the IRIS platform. You will receive real-time updates and your official Fixed Deposit Receipt (FDR) directly.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.back(); // return to FD home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A017),
                    foregroundColor: const Color(0xFF1A2340),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ── 6. Load Customer's Submitted Applications ────────────────
  Future<void> loadMyApplications() async {
    try {
      isLoadingMyApps.value = true;
      final list = await _repository.getMyApplications();
      myApplications.assignAll(list);
    } catch (_) {
    } finally {
      isLoadingMyApps.value = false;
    }
  }
}
