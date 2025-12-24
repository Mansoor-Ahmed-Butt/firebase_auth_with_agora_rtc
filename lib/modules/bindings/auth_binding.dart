import 'package:get/get.dart';
import 'package:sign_in_google_with_agora/modules/controllers/home_controller.dart';
import 'package:sign_in_google_with_agora/modules/controllers/video_call_controller.dart';

import '../controllers/login_controller.dart';
import '../controllers/signup_controller.dart';
import '../controllers/forgot_password_controller.dart';
import '../controllers/phone_auth_controller.dart';
import '../controllers/verify_otp_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<SignupController>(() => SignupController());
    Get.lazyPut<VideoCallController>(() => VideoCallController());
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
    Get.lazyPut<PhoneAuthController>(() => PhoneAuthController());
    Get.lazyPut<VerifyOtpController>(() => VerifyOtpController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
