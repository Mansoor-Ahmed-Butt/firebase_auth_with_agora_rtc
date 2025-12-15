import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class HomeController extends GetxController {
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

        final credential = await AuthService.instance.signInWithEmail(email: email, password: password);

        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful!')));
        // Optionally navigate or do other post-login actions here
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not found. Please sign up first.')));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect password.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Authentication error')));
        }
      } catch (e) {
        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }
}
