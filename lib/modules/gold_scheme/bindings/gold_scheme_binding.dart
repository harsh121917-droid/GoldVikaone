import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/bindings/digi_gold_binding.dart';

class GoldSchemeBinding extends Bindings {
  @override
  void dependencies() => DigiGoldBinding().dependencies();
}
