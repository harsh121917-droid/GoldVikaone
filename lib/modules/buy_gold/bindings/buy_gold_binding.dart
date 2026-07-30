import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/bindings/digi_gold_binding.dart';

/// Buy Gold has no state of its own — it just needs the shared gold/wallet
/// controllers available (in case this screen is opened before Home ever
/// registered them, e.g. a deep link).
class BuyGoldBinding extends Bindings {
  @override
  void dependencies() => DigiGoldBinding().dependencies();
}
