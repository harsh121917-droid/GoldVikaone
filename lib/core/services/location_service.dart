import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../network/api_client.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class LocationService extends GetxService {
  static LocationService get to => Get.find<LocationService>();

  final _box = GetStorage();
  final isCapturing = false.obs;
  bool _isPromptShowing = false;

  bool get isLocationCaptured {
    if (Get.isRegistered<AuthController>()) {
      final user = Get.find<AuthController>().user.value;
      if (user != null) {
        if (user.hasLocation) {
          _box.write('user_location_captured', true);
          return true;
        } else {
          // If admin deleted location on backend -> sync local cache and re-prompt
          _box.write('user_location_captured', false);
          return false;
        }
      }
    }
    return _box.read<bool>('user_location_captured') ?? false;
  }

  /// Checks if location is already captured. If NOT, prompts the user.
  Future<void> checkAndPromptLocation({bool isMandatory = false}) async {
    // If location is already captured, do nothing (one-time rule)
    if (isLocationCaptured) return;
    if (_isPromptShowing) return;

    // Small delay to ensure active view rendering completes
    await Future.delayed(const Duration(milliseconds: 1000));
    if (isLocationCaptured) return;

    showLocationPromptDialog(isMandatory: isMandatory);
  }

  /// Shows the high-conversion permission dialog explaining why location is required
  void showLocationPromptDialog({bool isMandatory = false}) {
    if (_isPromptShowing) return;
    _isPromptShowing = true;

    Get.dialog(
      PopScope(
        canPop: !isMandatory,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF0F172A),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Pin Icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4A017).withValues(alpha: 0.35), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.location_on_rounded, color: Color(0xFFD4A017), size: 30),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                const Text(
                  'Enable Location',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Clean Concise Message
                Text(
                  'Please enable location access to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Obx(() => Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A017),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: isCapturing.value
                            ? null
                            : () async {
                                final success = await captureAndSaveLocation();
                                if (success) {
                                  _isPromptShowing = false;
                                  Get.back();
                                  Get.snackbar(
                                    'Location Enabled',
                                    'Location access enabled successfully.',
                                    backgroundColor: const Color(0xFF1FAE7A),
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(12),
                                  );
                                }
                              },
                        child: isCapturing.value
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.my_location_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Enable Location',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (!isMandatory) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: isCapturing.value
                            ? null
                            : () {
                                _isPromptShowing = false;
                                Get.back();
                              },
                        child: Text(
                          'Not Now',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5),
                        ),
                      ),
                    ],
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: !isMandatory,
    );
  }

    Future<bool> captureAndSaveLocation() async {
    try {
      isCapturing.value = true;

      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          Get.snackbar('GPS Disabled', 'Please turn on GPS/Location in device settings.',
              backgroundColor: const Color(0xFFE05A47), colorText: Colors.white);
          return false;
        }
      }

      // 2. Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Permission Denied', 'Location permission is required to verify your account.',
              backgroundColor: const Color(0xFFE05A47), colorText: Colors.white);
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Blocked',
          'Please grant Location permission from App Settings to continue.',
          backgroundColor: const Color(0xFFE05A47),
          colorText: Colors.white,
          mainButton: TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        return false;
      }

      // 3. Acquire GPS Position
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // 4. Send to Backend API (backend performs full reverse geocoding to resolve city/state/address)
      final dio = ApiClient.instance;
      final res = await dio.post('/users/location', data: {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });

      if (res.statusCode == 200 && res.data['success'] == true) {
        // Mark locally as captured — never ask again
        _box.write('user_location_captured', true);
        if (Get.isRegistered<AuthController>()) {
          await Get.find<AuthController>().fetchCurrentUser();
        }
        return true;
      } else {
        Get.snackbar('Failed', res.data?['message'] ?? 'Could not save location.',
            backgroundColor: const Color(0xFFE05A47), colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Location Error', 'Failed to retrieve location: $e',
          backgroundColor: const Color(0xFFE05A47), colorText: Colors.white);
      return false;
    } finally {
      isCapturing.value = false;
    }
  }
}
