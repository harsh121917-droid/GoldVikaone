import 'package:vika1/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/auth_service.dart';
import 'core/services/lock_service.dart';
import 'core/services/location_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/controllers/theme_controller.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local key-value storage � must be ready before anything reads/writes
  // tokens, theme preference, passcode, etc.
  await GetStorage.init();
  await NotificationService.init();

  // App-wide singletons other controllers depend on via Get.find().
  // These must exist before any screen builds, so register them here
  // instead of inside a per-route Binding.
  Get.put(AuthService(), permanent: true);
  Get.put(LockService(), permanent: true);
  Get.put(LocationService(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Vikaone',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeController.to.isDark.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: appPages,
      ),
    );
  }
}
