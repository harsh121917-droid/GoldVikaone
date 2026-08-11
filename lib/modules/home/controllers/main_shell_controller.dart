import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/modules/kyc/controllers/kyc_controller.dart';
import 'package:vika1/routes/app_routes.dart';

class MainShellController extends GetxController {
  final tabIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void onReady() {
    super.onReady();
    // Check for app updates on startup
    _checkForUpdate();
  }

  void _checkForUpdate() {
    // Current Local App Version
    const currentVersion = '0.9.0';
    
    // Target PlayStore/AppStore version (In production, this would be fetched from /api/app-version)
    const storeVersion = '1.0.0'; 
    const forceUpdate = false;
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.vikaone.app';

    if (currentVersion != storeVersion) {
      // Delay slightly to ensure UI is fully rendered before showing dialog/routing
      Future.delayed(const Duration(seconds: 1), () {
        Get.toNamed(
          AppRoutes.update,
          arguments: {
            'newVersion': storeVersion,
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
      if (Get.isRegistered<WalletController>()) {
        WalletController.to.loadAll();
      }
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
