import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sign_in_google_with_agora/firebase_options.dart';
import 'notifications/notifications_service.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize notifications (local + FCM handlers)
  await NotificationsService.initialize();

  // For debugging: print FCM token
  try {
    final token = await NotificationsService.getToken();
    if (token != null) {
      // ignore: avoid_print
      print('NFCM token: $token');
    }
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Sign In Demo',
      debugShowCheckedModeBanner: false,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationParser: AppRouter.router.routeInformationParser,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      builder: EasyLoading.init(),
    );
  }
}
