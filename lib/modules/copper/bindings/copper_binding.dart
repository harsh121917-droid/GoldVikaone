import 'package:get/get.dart';
import 'package:vika1/modules/copper/controllers/copper_controller.dart';
import 'package:vika1/modules/wallet/controllers/wallet_controller.dart';
import 'package:vika1/modules/kyc/controllers/kyc_controller.dart';

class CopperBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CopperController>()) {
      Get.put(CopperController());
    }
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
    if (!Get.isRegistered<KycController>()) {
      Get.put(KycController());
    }
  }
}
