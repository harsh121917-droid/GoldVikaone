import 'package:get/get.dart';
import 'package:vika1/data/repositories/silver_repository.dart';
import 'package:vika1/data/repositories/wallet_repository.dart';
import 'package:vika1/modules/silver/controllers/silver_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';

/// Shared silver/wallet state used by buy, sell, and my-silver screens.
/// Safe to bind on any entry point — only registers what's missing.
class SilverBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SilverRepository>()) {
      Get.lazyPut<SilverRepository>(() => SilverRepository());
    }
    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(() => WalletRepository());
    }
    if (!Get.isRegistered<SilverController>()) {
      Get.put(SilverController());
    }
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
  }
}
