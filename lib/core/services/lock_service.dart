import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../constants/storage_keys.dart';
class LockService extends GetxService {
  static LockService get to => Get.find();

  final _box = GetStorage(StorageKeys.authContainer);
  final _legacyBox = GetStorage();
  final _auth = LocalAuthentication();

  // Guard — true while biometric dialog is open so main.dart doesn't re-lock
  bool isUnlocking = false;
  void setUnlocking(bool v) => isUnlocking = v;

  // Observable so Obx widgets react when PIN is set/cleared
  final pinActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    _migrateLegacyPinIfNeeded();
    pinActive.value = hasPasscode;
  }

  void _migrateLegacyPinIfNeeded() {
    if (_box.read<String>(StorageKeys.passcode) == null) {
      final legacyPin = _legacyBox.read<String>(StorageKeys.passcode);
      if (legacyPin != null) {
        _box.write(StorageKeys.passcode, legacyPin);
        final legacyLock = _legacyBox.read<bool>(StorageKeys.lockEnabled);
        if (legacyLock != null) _box.write(StorageKeys.lockEnabled, legacyLock);
        final legacyBio = _legacyBox.read<bool>(StorageKeys.biometric);
        if (legacyBio != null) _box.write(StorageKeys.biometric, legacyBio);
        _box.save();
      }
    }
  }

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get hasPasscode =>
      (_box.read<String>(StorageKeys.passcode) ??
          _legacyBox.read<String>(StorageKeys.passcode)) !=
      null;
  bool get lockEnabled =>
      _box.read<bool>(StorageKeys.lockEnabled) ??
      _legacyBox.read<bool>(StorageKeys.lockEnabled) ??
      false;
  bool get biometricEnabled =>
      _box.read<bool>(StorageKeys.biometric) ??
      _legacyBox.read<bool>(StorageKeys.biometric) ??
      false;

  // ── Setup passcode (called after login/register) ──────────────────────────
  Future<void> savePasscode(String pin) async {
    final hash = sha256.convert(utf8.encode(pin)).toString();
    await _box.write(StorageKeys.passcode, hash);
    await _box.write(StorageKeys.lockEnabled, true);
    await _box.save();
    pinActive.value = true;
  }

  bool verifyPasscode(String pin) {
    final stored = _box.read<String>(StorageKeys.passcode) ??
        _legacyBox.read<String>(StorageKeys.passcode);
    if (stored == null) return false;
    final hash = sha256.convert(utf8.encode(pin)).toString();
    return stored == hash;
  }

  Future<void> enableBiometric(bool value) async {
    await _box.write(StorageKeys.biometric, value);
    await _box.save();
  }

  void disableLock() {
    _box.remove(StorageKeys.passcode);
    _box.remove(StorageKeys.lockEnabled);
    _box.remove(StorageKeys.biometric);
    _box.save();
    _legacyBox.remove(StorageKeys.passcode);
    _legacyBox.remove(StorageKeys.lockEnabled);
    _legacyBox.remove(StorageKeys.biometric);
    pinActive.value = false;
  }

  // ── Biometric availability ─────────────────────────────────────────────────
  Future<bool> get canUseBiometric async {
    try {
      final available = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return available && supported;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  // ── Biometric auth ─────────────────────────────────────────────────────────
  Future<bool> authenticateWithBiometric() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to open Vikaone',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
