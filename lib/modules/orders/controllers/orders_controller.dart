import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

class OrdersController extends GetxController {
  static OrdersController get to => Get.find();

  final _dio = ApiClient.instance;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final selectedFilter = 'all'.obs; // 'all', 'in_transit', 'delivered'

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final res = await _dio.get('/jewellery/my-orders');
      if (res.data != null && res.data['data'] != null && res.data['data'] is List) {
        final list = (res.data['data'] as List)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
        orders.assignAll(list);
      }
    } catch (e) {
      errorMsg.value = 'Failed to load order history. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  List<OrderModel> get filteredOrders {
    if (selectedFilter.value == 'in_transit') {
      return orders
          .where((o) =>
              o.deliveryStatus != 'delivered' && o.deliveryStatus != 'cancelled')
          .toList();
    } else if (selectedFilter.value == 'delivered') {
      return orders.where((o) => o.deliveryStatus == 'delivered').toList();
    }
    return orders;
  }
}
