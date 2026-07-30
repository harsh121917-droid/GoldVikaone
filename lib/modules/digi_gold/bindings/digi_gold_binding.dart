import 'package:get/get.dart';
import 'package:vika1/data/repositories/gold_repository.dart';
import 'package:vika1/data/repositories/wallet_repository.dart';
import 'package:vika1/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';

/// Shared gold/wallet state used by every gold feature (buy, sell, SIP,
/// scheme, coin redemption). Safe to bind on any entry point — only
/// registers what's missing, since GoldController/WalletController are
/// meant to be a single shared instance across the whole gold section.
class DigiGoldBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GoldRepository>()) {
      Get.lazyPut<GoldRepository>(() => GoldRepository());
    }
    if (!Get.isRegistered<WalletRepository>()) {
      Get.lazyPut<WalletRepository>(() => WalletRepository());
    }
    if (!Get.isRegistered<GoldController>()) {
      Get.put(GoldController());
    }
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
  }
}
