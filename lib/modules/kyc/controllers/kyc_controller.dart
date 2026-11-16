import '../../../core/services/auth_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/kyc_model.dart';
import '../../../data/repositories/kyc_repository.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../views/digio_kyc_webview.dart';

class KycController extends GetxController {
  final KycRepository _repo = Get.isRegistered<KycRepository>()
      ? Get.find<KycRepository>()
      : Get.put(KycRepository());
  final _picker = ImagePicker();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMsg = ''.obs;

  final existingKyc = Rx<KycModel?>(null);
  final kycStatus =
      'not_submitted'.obs; // not_submitted | pending | approved | rejected

  // Form fields
  final fullNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final bankAccountCtrl = TextEditingController();
  final confirmBankAccountCtrl = TextEditingController();
  final bankIfscCtrl = TextEditingController();
  final bankBankNameCtrl = TextEditingController();
  final bankAccountType = 'savings'.obs;
  final isFetchingIfsc = false.obs;
  final ifscBranchName = ''.obs;
  final ifscError = ''.obs;

  // KYC Mode: 'digital' (Instant) or 'manual' (Document Photo Upload)
  final kycMode = 'digital'.obs;

  // Digital verification variables
  final cashfreeAadhaarCtrl = TextEditingController();
  final cashfreeOtpCtrl = TextEditingController();
  final isCashfreeOtpSent = false.obs;
  final isAadhaarVerified = false.obs;
  final verifiedAadhaarName = ''.obs;
  final cashfreeRefId = ''.obs;

  final cashfreePanCtrl = TextEditingController();
  final cashfreePanNameCtrl = TextEditingController();
  final isPanVerified = false.obs;
  final verifiedPanName = ''.obs;

  final isBankVerified = false.obs;
  final verifiedBankHolder = ''.obs;
  final verifiedBankName = ''.obs;
  final isVerifyingBank = false.obs;

  final panImage = Rx<File?>(null);
  final aadhaarFrontImage = Rx<File?>(null);
  final aadhaarBackImage = Rx<File?>(null);

  // Soldier / Armed Forces verification state
  final soldierIdCtrl = TextEditingController();
  final selectedServiceBranch = 'Indian Army'.obs;
  final soldierIdCardImage = Rx<File?>(null);
  final isSubmittingSoldier = false.obs;
  final isSoldierVerified = false.obs;
  final soldierStatus = 'not_submitted'.obs; // not_submitted | pending | approved | rejected
  final soldierRejectionReason = ''.obs;
  final soldierIdCardUrl = ''.obs;

  final selectedDob = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final user = AuthService().currentUser;
      final cached = user?.kycStatus;
      if (cached != null && cached.isNotEmpty && cached != 'not_submitted') {
        kycStatus.value = cached;
      }
      if (user != null) {
        isSoldierVerified.value = user.isSoldierVerified;
        soldierStatus.value = user.soldierKycStatus;
        if (bankNameCtrl.text.trim().isEmpty && user.name.isNotEmpty) {
          bankNameCtrl.text = user.name;
        }
      }
    } catch (_) {}
    loadMyKyc();
  }

  Future<void> lookupIfsc(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length != 11) {
      ifscBranchName.value = '';
      ifscError.value = '';
      return;
    }

    try {
      isFetchingIfsc.value = true;
      ifscError.value = '';
      final res = await ApiClient.instance.get('/bank/ifsc/$cleanCode');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as Map<String, dynamic>;
        bankBankNameCtrl.text = data['bank']?.toString() ?? 'Bank';
        ifscBranchName.value = data['branch']?.toString() ?? '';
        ifscError.value = '';
      } else {
        ifscError.value = 'Invalid IFSC code. Please verify.';
      }
    } catch (_) {
      ifscError.value = 'IFSC not found in RBI directory.';
    } finally {
      isFetchingIfsc.value = false;
    }
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    panCtrl.dispose();
    aadhaarCtrl.dispose();
    bankNameCtrl.dispose();
    bankAccountCtrl.dispose();
    confirmBankAccountCtrl.dispose();
    bankIfscCtrl.dispose();
    bankBankNameCtrl.dispose();
    cashfreeAadhaarCtrl.dispose();
    cashfreeOtpCtrl.dispose();
    cashfreePanCtrl.dispose();
    cashfreePanNameCtrl.dispose();
    soldierIdCtrl.dispose();
    super.onClose();
  }

  Future<void> loadMyKyc() async {
    try {
      isLoading.value = true;
      final kyc = await _repo.getMyKyc();
      existingKyc.value = kyc;
      kycStatus.value = kyc?.status ?? 'not_submitted';

      if (kyc != null) {
        fullNameCtrl.text = kyc.fullName;
        dobCtrl.text = kyc.dob.split('T').first;
        addressCtrl.text = kyc.addressLine1;
        cityCtrl.text = kyc.city;
        stateCtrl.text = kyc.state;
        pincodeCtrl.text = kyc.pincode;
        panCtrl.text = kyc.panNumber;
        bankNameCtrl.text = kyc.bankAccountHolderName ?? '';
        bankAccountCtrl.text = kyc.bankAccountNumber ?? '';
        bankIfscCtrl.text = kyc.bankIfscCode ?? '';
        bankBankNameCtrl.text = kyc.bankName ?? '';

        if (kyc.panNumber.isNotEmpty && kyc.panNumber != 'PHOTO_SUBMITTED') {
          cashfreePanCtrl.text = kyc.panNumber;
          isPanVerified.value = true;
          verifiedPanName.value = kyc.fullName;
        }
        if (kyc.aadhaarNumber != null && kyc.aadhaarNumber!.isNotEmpty && kyc.aadhaarNumber != 'PHOTO_SUBMITTED') {
          cashfreeAadhaarCtrl.text = kyc.aadhaarNumber!;
          isAadhaarVerified.value = true;
          verifiedAadhaarName.value = kyc.fullName;
        }
        if (kyc.bankAccountNumber != null && kyc.bankAccountNumber!.isNotEmpty) {
          isBankVerified.value = true;
          verifiedBankHolder.value = kyc.bankAccountHolderName ?? kyc.fullName;
          verifiedBankName.value = kyc.bankName ?? '';
        }

        if (kyc.isSoldier) {
          soldierIdCtrl.text = kyc.soldierIdNumber ?? '';
          if (kyc.serviceBranch != null && kyc.serviceBranch!.isNotEmpty) {
            selectedServiceBranch.value = kyc.serviceBranch!;
          }
          soldierStatus.value = kyc.soldierStatus;
          isSoldierVerified.value = kyc.isSoldierApproved;
          soldierRejectionReason.value = kyc.soldierRejectionReason ?? '';
          soldierIdCardUrl.value = kyc.soldierIdCardUrl ?? '';
        }
      }
    } on DioException catch (_) {
      // 404 / no kyc yet is fine — stays not_submitted
    } catch (e) {
      errorMsg.value = 'Failed to load KYC status';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(Rx<File?> target) async {
    Get.bottomSheet(
      Container(
        color: Get.isDarkMode ? const Color(0xFF0E1626) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: Get.isDarkMode ? Colors.white : Colors.black),
              title: Text('Take Photo', style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black)),
              onTap: () async {
                Get.back();
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1400,
                  maxHeight: 1400,
                  imageQuality: 70,
                );
                if (picked != null) target.value = File(picked.path);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: Get.isDarkMode ? Colors.white : Colors.black),
              title: Text('Choose from Gallery', style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black)),
              onTap: () async {
                Get.back();
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1400,
                  maxHeight: 1400,
                  imageQuality: 70,
                );
                if (picked != null) target.value = File(picked.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  // UPDATE setDob
  void setDob(DateTime date) {
    selectedDob.value =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    dobCtrl.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> submit() async {
    if (kycStatus.value == 'pending') {
      Get.snackbar(
        'KYC in Review',
        'Your KYC documents are already under review by our admin team',
        backgroundColor: const Color(0xFFF39C12),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (fullNameCtrl.text.trim().isEmpty ||
        dobCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty ||
        cityCtrl.text.trim().isEmpty ||
        stateCtrl.text.trim().isEmpty ||
        pincodeCtrl.text.trim().isEmpty ||
        panCtrl.text.trim().isEmpty ||
        aadhaarCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing fields', 'Please fill all required fields');
      return;
    }

    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(panCtrl.text.trim().toUpperCase())) {
      Get.snackbar('Invalid PAN', 'Format should be like ABCDE1234F');
      return;
    }
    if (!RegExp(r'^\d{12}$').hasMatch(aadhaarCtrl.text.trim())) {
      Get.snackbar('Invalid Aadhaar', 'Must be exactly 12 digits');
      return;
    }
    if (panImage.value == null ||
        aadhaarFrontImage.value == null ||
        aadhaarBackImage.value == null) {
      Get.snackbar(
        'Missing documents',
        'Please upload PAN, Aadhaar front and back images',
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final res = await _repo.submitKyc(
        fullName: fullNameCtrl.text.trim(),
        dob: dobCtrl.text.trim(),
        addressLine1: addressCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        pincode: pincodeCtrl.text.trim(),
        panNumber: panCtrl.text.trim().toUpperCase(),
        aadhaarNumber: aadhaarCtrl.text.trim(),
        bankAccountHolderName: bankNameCtrl.text.trim(),
        bankAccountNumber: bankAccountCtrl.text.trim(),
        bankIfscCode: bankIfscCtrl.text.trim().toUpperCase(),
        bankName: bankBankNameCtrl.text.trim(),
        panImagePath: panImage.value!.path,
        aadhaarFrontPath: aadhaarFrontImage.value!.path,
        aadhaarBackPath: aadhaarBackImage.value!.path,
      );

      if (res['success'] == true) {
        kycStatus.value = 'pending';

        // Hit API 2: Add Standalone Bank Account into user's wallet bank accounts
        if (bankAccountCtrl.text.trim().isNotEmpty && bankIfscCtrl.text.trim().isNotEmpty) {
          try {
            await ApiClient.instance.post(
              '/bank',
              data: {
                'accountHolder': bankNameCtrl.text.trim().toUpperCase(),
                'accountNumber': bankAccountCtrl.text.trim(),
                'ifsc': bankIfscCtrl.text.trim().toUpperCase(),
                'bankName': bankBankNameCtrl.text.trim().isNotEmpty ? bankBankNameCtrl.text.trim() : 'Bank',
                'accountType': bankAccountType.value,
              },
            );
            if (Get.isRegistered<WalletController>()) {
              await WalletController.to.loadBanks();
            }
          } catch (_) {}
        }

        Get.snackbar(
          'Submitted ✓',
          'Your KYC and Bank details are under review',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Failed',
          res['message'] ?? 'Submission failed',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } on DioException catch (e) {
      String msg = e.response?.data?['message'] ?? 'Submission failed';
      if (e.response?.statusCode == 413) {
        msg = 'Upload payload too large (413). Images have been compressed, please re-select and try again.';
      }
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection error. Please try again.',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitPhotoOnly() async {
    if (kycStatus.value == 'pending') {
      Get.snackbar(
        'KYC in Review',
        'Your KYC documents are already under review by our admin team',
        backgroundColor: const Color(0xFFF39C12),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (panImage.value == null && aadhaarFrontImage.value == null) {
      Get.snackbar(
        'Upload Required',
        'Please upload at least your PAN Card or Aadhaar ID photo',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    // ── Validate Bank Information ──
    final holderName = bankNameCtrl.text.trim();
    final accNum = bankAccountCtrl.text.trim();
    final confirmAcc = confirmBankAccountCtrl.text.trim();
    final ifsc = bankIfscCtrl.text.trim().toUpperCase();
    final bName = bankBankNameCtrl.text.trim();

    if (holderName.isEmpty) {
      Get.snackbar(
        'Account Holder Name Required',
        'Please enter your bank account holder name (must match your PAN & Aadhaar)',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (accNum.isEmpty || accNum.length < 9) {
      Get.snackbar(
        'Invalid Account Number',
        'Please enter a valid bank account number (at least 9 digits)',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (confirmAcc.isNotEmpty && confirmAcc != accNum) {
      Get.snackbar(
        'Account Numbers Do Not Match',
        'Please re-check your account number confirmation',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (ifsc.length != 11) {
      Get.snackbar(
        'Invalid IFSC Code',
        'Please enter an 11-character IFSC code (e.g. SBIN0001234)',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final userName = holderName.isNotEmpty
          ? holderName
          : (fullNameCtrl.text.trim().isNotEmpty
              ? fullNameCtrl.text.trim()
              : (AuthService().currentUser?.name ?? 'Account Holder'));

      // ── API 1: Submit KYC Documents & Details ──
      final res = await _repo.submitPhotoOnlyKyc(
        fullName: userName,
        panImagePath: panImage.value?.path ?? (aadhaarFrontImage.value?.path ?? ''),
        aadhaarFrontPath: aadhaarFrontImage.value?.path,
        aadhaarBackPath: aadhaarBackImage.value?.path,
        bankAccountHolderName: holderName.toUpperCase(),
        bankAccountNumber: accNum,
        bankIfscCode: ifsc,
        bankName: bName.isNotEmpty ? bName : 'Bank',
      );

      // ── API 2: Add to User Standalone Bank Accounts ──
      try {
        await ApiClient.instance.post(
          '/bank',
          data: {
            'accountHolder': holderName.toUpperCase(),
            'accountNumber': accNum,
            'ifsc': ifsc,
            'bankName': bName.isNotEmpty ? bName : 'Bank',
            'accountType': bankAccountType.value,
          },
        );
        if (Get.isRegistered<WalletController>()) {
          await WalletController.to.loadBanks();
        }
      } catch (bankErr) {
        // Backend handles already added accounts gracefully
      }

      if (res['success'] == true) {
        kycStatus.value = 'pending';
        Get.snackbar(
          'KYC & Bank Details Submitted! ✓',
          'Your documents and bank account are uploaded and under review by our admin team',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Failed',
          res['message'] ?? 'Submission failed',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } on DioException catch (e) {
      String msg = e.response?.data?['message'] ?? 'Submission failed';
      if (e.response?.statusCode == 413) {
        msg = 'Upload payload too large (413). Images have been compressed, please re-select and try again.';
      }
      Get.snackbar(
        'Error',
        msg,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection error. Please try again.',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitSoldierVerification() async {
    if (soldierIdCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing Field', 'Please enter your Soldier / Service ID Number',
          backgroundColor: const Color(0xFFE53E3E), colorText: Colors.white);
      return;
    }
    if (soldierIdCardImage.value == null && soldierIdCardUrl.value.isEmpty) {
      Get.snackbar('Missing Document', 'Please upload a photo of your Soldier ID card',
          backgroundColor: const Color(0xFFE53E3E), colorText: Colors.white);
      return;
    }

    try {
      isSubmittingSoldier.value = true;
      final res = await _repo.submitSoldierId(
        serviceBranch: selectedServiceBranch.value,
        soldierIdNumber: soldierIdCtrl.text.trim().toUpperCase(),
        idCardPath: soldierIdCardImage.value?.path ?? '',
      );

      if (res['success'] == true) {
        soldierStatus.value = 'pending';
        isSoldierVerified.value = false;
        Get.snackbar(
          '🎖️ Submitted for Review',
          'Your Soldier ID verification has been submitted to Admin. You will unlock the 5% extra return once approved.',
          backgroundColor: const Color(0xFF059669),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar('Submission Failed', res['message'] ?? 'Could not submit Soldier ID',
            backgroundColor: const Color(0xFFE53E3E), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit Soldier ID: $e',
          backgroundColor: const Color(0xFFE53E3E), colorText: Colors.white);
    } finally {
      isSubmittingSoldier.value = false;
    }
  }

  Future<void> startDigioKycFlow(dynamic context) async {
    try {
      isSubmitting.value = true;
      final res = await _repo.initiateDigio();
      if (res['success'] == true) {
        final kycId = res['kycId'] as String;
        final token = res['token'] as String;
        final identifier = res['customer_identifier'] as String;
        final env = res['environment'] as String;

        isSubmitting.value = false;

        final dynamic result = await Get.to(
          () => DigioKycWebView(
            kycId: kycId,
            token: token,
            customerIdentifier: identifier,
            environment: env,
          ),
        );

        if (result != null) {
          isSubmitting.value = true;
          final String? aadhaarNum = result is String ? result : null;
          final verifyRes = await _repo.verifyDigio(
            kycId,
            panNumber: cashfreePanCtrl.text.trim().toUpperCase(),
            aadhaarNumber: aadhaarNum,
          );
          isSubmitting.value = false;

          if (verifyRes['success'] == true) {
            kycStatus.value = 'approved';
            Get.snackbar(
              'KYC Verified! 🥇',
              'Your Aadhaar details are verified successfully.',
              backgroundColor: const Color(0xFF2ECC71),
              colorText: const Color(0xFFFFFFFF),
            );
            loadMyKyc();
          } else {
            Get.snackbar(
              'Verification Failed',
              verifyRes['message'] ?? 'Could not verify status',
              backgroundColor: const Color(0xFFE53E3E),
              colorText: const Color(0xFFFFFFFF),
            );
          }
        } else {
          Get.snackbar(
            'Cancelled',
            'DigiLocker verification was cancelled.',
            backgroundColor: const Color(0xFFE53E3E),
            colorText: const Color(0xFFFFFFFF),
          );
        }
      } else {
        isSubmitting.value = false;
        Get.snackbar('Failed', 'Could not initiate Digio session');
      }
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar('Error', 'Failed to complete Digio KYC: $e');
    }
  }

  void resetAadhaarOtp() {
    isCashfreeOtpSent.value = false;
    cashfreeOtpCtrl.clear();
  }

  Future<void> sendCashfreeOtp() async {
    final aadhaarNum = cashfreeAadhaarCtrl.text.trim();
    if (aadhaarNum.length != 12 || int.tryParse(aadhaarNum) == null) {
      Get.snackbar(
        'Invalid Aadhaar',
        'Please enter a valid 12-digit Aadhaar number',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final res = await _repo.initiateCashfreeOtp(aadhaarNum);
      if (res['success'] == true) {
        cashfreeRefId.value = res['refId'] as String;
        isCashfreeOtpSent.value = true;
        Get.snackbar(
          'OTP Sent 📩',
          res['message'] ??
              'OTP has been sent to your Aadhaar-registered mobile number.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Failed',
          res['message'] ?? 'Failed to send OTP. Please try again.',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to send OTP: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      }
      Get.snackbar(
        'Failed to Send OTP',
        errorMessage,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 6),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> verifyCashfreeOtp() async {
    final otpVal = cashfreeOtpCtrl.text.trim();
    if (otpVal.length != 6 || int.tryParse(otpVal) == null) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter a valid 6-digit OTP',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final res = await _repo.verifyCashfreeOtp(
        otp: otpVal,
        refId: cashfreeRefId.value,
        aadhaarNumber: cashfreeAadhaarCtrl.text.trim(),
        panNumber: cashfreePanCtrl.text.trim().toUpperCase(),
      );

      if (res['success'] == true) {
        isAadhaarVerified.value = true;
        isCashfreeOtpSent.value = false;
        final aadhaarName = res['name'] ?? res['fullName'] ?? '';
        if (aadhaarName.toString().isNotEmpty) {
          verifiedAadhaarName.value = aadhaarName.toString();
          fullNameCtrl.text = aadhaarName.toString();
          if (cashfreePanNameCtrl.text.trim().isEmpty) {
            cashfreePanNameCtrl.text = aadhaarName.toString();
          }
          if (bankNameCtrl.text.trim().isEmpty) {
            bankNameCtrl.text = aadhaarName.toString();
          }
        }
        aadhaarCtrl.text = cashfreeAadhaarCtrl.text.trim();

        // Auto-fetch DOB & Address from Aadhaar OKYC
        final dobVal = (res['dob'] ?? (res['data'] is Map ? (res['data'] as Map)['dob'] : null))?.toString() ?? '';
        if (dobVal.isNotEmpty) {
          final cleanDob = dobVal.contains('T') ? dobVal.split('T').first : dobVal;
          dobCtrl.text = cleanDob;
          selectedDob.value = cleanDob;
        }

        Map? addrMap;
        if (res['address'] is Map) {
          addrMap = res['address'] as Map;
        } else if (res['data'] is Map && (res['data'] as Map)['address'] is Map) {
          addrMap = (res['data'] as Map)['address'] as Map;
        }

        if (addrMap != null) {
          if (addrMap['line1'] != null && addrMap['line1'].toString().isNotEmpty) {
            addressCtrl.text = addrMap['line1'].toString();
          }
          if (addrMap['city'] != null && addrMap['city'].toString().isNotEmpty) {
            cityCtrl.text = addrMap['city'].toString();
          }
          if (addrMap['state'] != null && addrMap['state'].toString().isNotEmpty) {
            stateCtrl.text = addrMap['state'].toString();
          }
          if (addrMap['pincode'] != null && addrMap['pincode'].toString().isNotEmpty) {
            pincodeCtrl.text = addrMap['pincode'].toString();
          }
        }

        Get.snackbar(
          'Aadhaar Verified! 🥇',
          'Aadhaar verified & details fetched. Now verify your PAN.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          res['message'] ?? 'Could not verify Aadhaar OTP',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to complete verification: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      }
      Get.snackbar(
        'Verification Failed',
        errorMessage,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 6),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> verifyPanFlow() async {
    final panVal = cashfreePanCtrl.text.trim().toUpperCase();
    final nameVal = cashfreePanNameCtrl.text.trim();

    if (panVal.length != 10) {
      Get.snackbar(
        'Invalid PAN',
        'Please enter a valid 10-character PAN number',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (nameVal.isEmpty) {
      Get.snackbar(
        'Name Required',
        'Please enter your name as per PAN card',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final res = await _repo.verifyCashfreePan(pan: panVal, name: nameVal);

      if (res['success'] == true && res['valid'] == true) {
        isPanVerified.value = true;
        verifiedPanName.value = (res['registeredName'] ?? nameVal).toString();

        fullNameCtrl.text = verifiedPanName.value;
        panCtrl.text = panVal;
        if (bankNameCtrl.text.trim().isEmpty) {
          bankNameCtrl.text = verifiedPanName.value;
        }

        Get.snackbar(
          'PAN Verified! 🥈',
          res['message'] ?? 'PAN verified successfully. Now verify your bank account.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );

        await loadMyKyc();
      } else {
        Get.snackbar(
          'Verification Failed',
          res['message'] ?? 'Could not verify PAN details',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      String errorMessage = 'Failed to complete PAN verification: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      }
      Get.snackbar(
        'Verification Failed',
        errorMessage,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 6),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> verifyBankFlow() async {
    final acc = bankAccountCtrl.text.trim();
    final confirmAcc = confirmBankAccountCtrl.text.trim();
    final ifsc = bankIfscCtrl.text.trim().toUpperCase();
    final holder = fullNameCtrl.text.trim().isNotEmpty
        ? fullNameCtrl.text.trim()
        : (verifiedPanName.value.isNotEmpty ? verifiedPanName.value : verifiedAadhaarName.value);

    if (acc.length < 9) {
      Get.snackbar(
        'Invalid Account',
        'Please enter a valid bank account number (9-18 digits)',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (confirmAcc.isNotEmpty && acc != confirmAcc) {
      Get.snackbar(
        'Account Mismatch',
        'Bank account numbers do not match',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (ifsc.length != 11) {
      Get.snackbar(
        'Invalid IFSC',
        'Please enter a valid 11-character IFSC code',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      isVerifyingBank.value = true;
      final res = await _repo.verifyBankAccount(
        accountNumber: acc,
        ifsc: ifsc,
        accountHolder: holder,
      );

      if (res['success'] == true && res['isVerified'] == true) {
        isBankVerified.value = true;
        final data = res['data'] as Map<String, dynamic>?;
        final returnedHolder = (data?['accountHolder'] ?? holder).toString();
        verifiedBankHolder.value = returnedHolder;
        bankNameCtrl.text = returnedHolder;
        if (data?['bankName'] != null) {
          bankBankNameCtrl.text = data!['bankName'].toString();
          verifiedBankName.value = data['bankName'].toString();
        }

        kycStatus.value = 'approved';

        Get.snackbar(
          'Bank Verified! 🏦',
          res['message'] ?? 'Bank account verified successfully.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );

        await loadMyKyc();
      } else {
        Get.snackbar(
          'Verification Failed',
          res['message'] ?? 'Bank account verification failed. Please check account details.',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 6),
        );
      }
    } catch (e) {
      String errorMessage = 'Bank verification failed: $e';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          errorMessage = data['message'].toString();
        }
      }
      Get.snackbar(
        'Verification Failed',
        errorMessage,
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 6),
      );
    } finally {
      isVerifyingBank.value = false;
    }
  }
}
