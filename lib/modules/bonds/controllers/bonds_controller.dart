import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/models/fd_models.dart';
import '../../../data/repositories/fd_repository.dart';

class BondsController extends GetxController {
  final FdRepository _repository = FdRepository();

  final RxBool isLoading = true.obs;
  final Rx<BondsConfigModel?> config = Rx<BondsConfigModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadBondsData();
  }

  Future<void> loadBondsData() async {
    try {
      isLoading.value = true;
      final data = await _repository.getBondsConfig();
      config.value = data;
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  static const String bondBazaarUrl =
      'https://www.bondbazaar.com/open-trading-account/?param=UlZTMTM%3D';

  /// Opens the official BondBazaar bond trading account in-app webview
  Future<void> openBondsWebsite() async {
    Get.toNamed(AppRoutes.bonds);
  }
}
