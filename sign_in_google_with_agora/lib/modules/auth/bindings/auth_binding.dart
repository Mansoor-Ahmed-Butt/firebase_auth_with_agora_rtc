import 'package:get/get.dart';
import 'package:sign_in_google_with_agora/modules/auth/controllers/home_controller.dart';

import '../controllers/login_controller.dart';
import '../controllers/signup_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignupController>(() => SignupController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
