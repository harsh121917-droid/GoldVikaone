import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';

class MainShellController extends GetxController {
  final tabIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  void changeTab(int i) {
    tabIndex.value = i;
    // IndexedStack keeps tabs alive forever — initState only runs once.
    // Refresh live data manually whenever a tab is (re)selected.
    if (i == 0) {
      if (Get.isRegistered<GoldController>()) GoldController.to.loadBalance();
      if (Get.isRegistered<GoldController>())
        GoldController.to.loadTransactions();
      if (Get.isRegistered<WalletController>()) WalletController.to.loadAll();
    }
    if (i == 1) {
      if (Get.isRegistered<SilverController>()) SilverController.to.loadAll();
      if (Get.isRegistered<WalletController>()) WalletController.to.loadAll();
    }
    if (i == 2) {
      if (Get.isRegistered<WalletController>()) WalletController.to.loadAll();
    }
  }
}
