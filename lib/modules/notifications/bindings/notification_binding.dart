import 'package:get/get.dart';
import '../controllers/notification_inbox_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationInboxController>(() => NotificationInboxController());
  }
}
