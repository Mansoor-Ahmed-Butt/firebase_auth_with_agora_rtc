import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notification_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  RxBool obscurePassword = true.obs;
  RxBool isLoading = false.obs;

  //  @override
  // void onInit() {
  //   super.onInit();
  //   print("LoginController onInit");
  // }

  // @override
  // void onReady() {
  //   super.onReady();
  //   print("LoginController onReady");
  // }
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login(BuildContext context) async {
    isLoading.value = true;
    EasyLoading.show(status: 'Signing in...');
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // ignore: avoid_print
      print("User logged in: ${userCredential.user?.uid}");
      isLoading.value = false;
      EasyLoading.dismiss();
      if (!context.mounted) return;
      NotificationService.instance.showSuccess('Login successful!');
      context.go('/home');
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      // Show code + message to help diagnose "internal error" cases
      final code = e.code;
      final friendly = '$code: ${e.message ?? 'Authentication error'}';
      // ignore: avoid_print
      print('LoginController FirebaseAuthException -> $friendly');

      String message;
      if (code == 'user-not-found') {
        message = 'This email does not have an account. Please sign up.';
      } else if (code == 'wrong-password') {
        message = 'Enter a valid password.';
      } else if (code == 'invalid-email') {
        message = 'Enter a valid email address.';
      } else if (code == 'invalid-credential' || code == 'invalid-credentials') {
        message = 'Incorrect email or password. Please check your credentials.';
      } else {
        message = friendly;
      }

      NotificationService.instance.showError(message);
    } catch (e) {
      isLoading.value = false;
      EasyLoading.dismiss();
      // unexpected errors
      // ignore: avoid_print
      print('LoginController unexpected error: $e');
      NotificationService.instance.showError('Login failed: $e');
    }
  }
}
