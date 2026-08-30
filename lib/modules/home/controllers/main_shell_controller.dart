import 'package:vika1/services/notification_service.dart';
import 'package:vika1/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/modules/kyc/controllers/kyc_controller.dart';
import 'package:vika1/core/network/api_client.dart';
import 'package:vika1/routes/app_routes.dart';

class MainShellController extends GetxController {
  final tabIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final refreshSchemesEvent = 0.obs;
  final refreshJewelleryEvent = 0.obs;
  final refreshRewardsEvent = 0.obs;

  @override
  void onReady() {
    super.onReady();
    // Check for app updates on startup
    _checkForUpdate();
    LocationService.to.checkAndPromptLocation();
    NotificationService.syncCurrentToken();
  }

  Future<void> _checkForUpdate() async {
    try {
      const currentVersion = '0.12.0';
      final dio = ApiClient.instance;
      final res = await dio.get('/app-version');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data;
        final latestVersion = data['latestVersion']?.toString() ?? '0.9.0';
        final forceUpdate = data['forceUpdate'] == true;
        final playStoreUrl = data['playStoreUrl']?.toString() ??
            'https://play.google.com/store/apps/details?id=com.vikaone.app';

        if (currentVersion != latestVersion) {
          // Delay slightly to ensure UI is fully rendered before showing dialog/routing
          Future.delayed(const Duration(seconds: 1), () {
            Get.toNamed(
              AppRoutes.update,
              arguments: {
                'newVersion': latestVersion,
                'isForceUpdate': forceUpdate,
                'changelog': [
                  '💎 Premium Jewellery & Hallmarked Coins Catalog',
                  '💳 Direct Razorpay checkout for making charges',
                  '📈 Real-time calibrated domestic Indian gold/silver rates',
                  '⚡ Ultra-fast seamless bottom navigation switching',
                  '🔒 Enhanced account KYC and Aadhaar security features',
                ],
                'onUpdatePressed': () async {
                  final uri = Uri.parse(playStoreUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            );
          });
        }
      }
    } catch (_) {}
  }

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  void changeTab(int i) {
    if (tabIndex.value == i) return;
    tabIndex.value = i;
    // Defer data refresh to after layout — never triggers reentrant layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshTab(i));
  }

  void _refreshTab(int i) {
    if (i == 0) {
      if (Get.isRegistered<GoldController>()) {
        GoldController.to.loadBalance();
        GoldController.to.loadTransactions();
      }
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadAll();
      }
    }
    if (i == 1) {
      refreshSchemesEvent.value++;
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadAll();
      }
    }
    if (i == 2) {
      refreshJewelleryEvent.value++;
    }
    if (i == 3) {
      refreshRewardsEvent.value++;
    }
    if (i == 4) {
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadWallet();
      }
      if (Get.isRegistered<KycController>()) {
        Get.find<KycController>().loadMyKyc();
      }
    }
  }
}
