import 'package:get/get.dart';
import 'package:vika1/modules/silver/bindings/silver_binding.dart';

/// Silver SIP (savings jar) shares the same underlying silver/wallet state
/// as buy/sell/my-silver — just delegates to SilverBinding.
class SilverSipBinding extends Bindings {
  @override
  void dependencies() => SilverBinding().dependencies();
}
