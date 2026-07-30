import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/bindings/digi_gold_binding.dart';
import 'package:vika1/modules/silver/bindings/silver_binding.dart';
import '../controllers/main_shell_controller.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<MainShellController>(() => MainShellController());
    // Shared gold/wallet state, used by every gold-related screen.
    DigiGoldBinding().dependencies();
    // Silver is now a direct shell tab (not a separately-routed page), so its
    // controller must be ready before the shell renders too.
    SilverBinding().dependencies();
  }
}
