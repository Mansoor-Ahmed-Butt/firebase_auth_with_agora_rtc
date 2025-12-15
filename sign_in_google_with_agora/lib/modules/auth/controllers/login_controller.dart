import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../../../services/notification_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
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
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final email = emailController.text.trim();
        final password = passwordController.text;

        // // Check whether the email is registered to provide clearer errors and avoid generic internal errors
        // try {
        //   final methods = await AuthService.instance.fetchSignInMethodsForEmail(email);
        //   if (methods.isEmpty) {
        //     isLoading.value = false;
        //     NotificationService.instance.showError('No account found for that email.');
        //     return;
        //   }
        // } catch (e) {
        //   // If fetchSignInMethodsForEmail fails unexpectedly, log and continue to attempt sign-in
        //   // ignore: avoid_print
        //   print('fetchSignInMethodsForEmail failed: $e');
        // }

        final credential = await AuthService.instance.signInWithEmail(email: email, password: password);

        isLoading.value = false;
        NotificationService.instance.showSuccess('Login successful!');
        context.go('/home');
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        // Show code + message to help diagnose "internal error" cases
        final friendly = '${e.code}: ${e.message ?? 'Authentication error'}';
        // ignore: avoid_print
        print('LoginController FirebaseAuthException -> $friendly');
        if (e.code == 'user-not-found') {
          NotificationService.instance.showError('user-not-found: User not found. Please sign up first.');
        } else if (e.code == 'wrong-password') {
          NotificationService.instance.showError('wrong-password: Incorrect password.');
        } else {
          NotificationService.instance.showError(friendly);
        }
      } catch (e) {
        isLoading.value = false;
        // unexpected errors
        // ignore: avoid_print
        print('LoginController unexpected error: $e');
        NotificationService.instance.showError('Login failed: $e');
      }
    }
  }
}
