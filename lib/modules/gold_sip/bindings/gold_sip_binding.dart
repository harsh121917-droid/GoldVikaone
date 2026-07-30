import 'package:get/get.dart';
import 'package:vika1/modules/digi_gold/bindings/digi_gold_binding.dart';

class GoldSipBinding extends Bindings {
  @override
  void dependencies() => DigiGoldBinding().dependencies();
}
