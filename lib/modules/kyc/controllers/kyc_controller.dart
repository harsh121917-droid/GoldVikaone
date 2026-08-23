import '../../../core/services/auth_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart' ;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/kyc_model.dart';
import '../../../data/repositories/kyc_repository.dart';
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
  final bankIfscCtrl = TextEditingController();
  final bankBankNameCtrl = TextEditingController();

  // Cashfree variables
  final cashfreeAadhaarCtrl = TextEditingController();
  final cashfreeOtpCtrl = TextEditingController();
  final isCashfreeOtpSent = false.obs;
  final cashfreeRefId = ''.obs;

  final cashfreePanCtrl = TextEditingController();
  final cashfreePanNameCtrl = TextEditingController();
  final isPanVerified = false.obs;
  final verifiedPanName = ''.obs;

  final panImage = Rx<File?>(null);
  final aadhaarFrontImage = Rx<File?>(null);
  final aadhaarBackImage = Rx<File?>(null);

  final selectedDob = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final cached = AuthService().currentUser?.kycStatus;
      if (cached != null && cached.isNotEmpty && cached != 'not_submitted') {
        kycStatus.value = cached;
      }
    } catch (_) {}
    loadMyKyc();
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
    bankIfscCtrl.dispose();
    bankBankNameCtrl.dispose();
    cashfreeAadhaarCtrl.dispose();
    cashfreeOtpCtrl.dispose();
    cashfreePanCtrl.dispose();
    cashfreePanNameCtrl.dispose();
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
                  imageQuality: 80,
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
                  imageQuality: 80,
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
        Get.snackbar(
          'Submitted ✓',
          'Your KYC is under review',
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
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Submission failed',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
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
          'OTP Sent',
          res['message'] ??
              'OTP has been sent to your Aadhaar-registered mobile number.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
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
      Get.snackbar(
        'Error',
        'Failed to send OTP: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
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
        kycStatus.value = 'approved';
        isCashfreeOtpSent.value = false;
        cashfreeAadhaarCtrl.clear();
        cashfreeOtpCtrl.clear();
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
          res['message'] ?? 'Could not verify status',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete verification: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
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
        verifiedPanName.value = res['registeredName'] as String;

        fullNameCtrl.text = verifiedPanName.value;
        panCtrl.text = panVal;

        Get.snackbar(
          'PAN Verified! 💳',
          res['message'] ?? 'PAN details are verified successfully.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          res['message'] ?? 'Could not verify PAN details',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete PAN verification: $e',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
