import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/modules/kyc/controllers/kyc_controller.dart';

class MainShellController extends GetxController {
  final tabIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
