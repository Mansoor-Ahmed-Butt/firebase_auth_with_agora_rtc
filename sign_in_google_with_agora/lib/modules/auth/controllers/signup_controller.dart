import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../../../services/notification_service.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;
  RxBool isLoading = false.obs;
  RxBool agreeToTerms = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void signup(BuildContext context) async {
    if (!agreeToTerms.value) {
      NotificationService.instance.showError('Please agree to terms and conditions');
      return;
    }

    if (formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        NotificationService.instance.showError('Passwords do not match');
        return;
      }

      isLoading.value = true;
      try {
        final name = nameController.text.trim();
        final email = emailController.text.trim();
        final password = passwordController.text;

        final userCred = await AuthService.instance.signUpWithEmail(name: name, email: email, password: password);

        isLoading.value = false;
        NotificationService.instance.showSuccess('Account created successfully!');
        context.go('/login');
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'email-already-in-use') {
          NotificationService.instance.showError('Email already in use. Please login.');
        } else if (e.code == 'weak-password') {
          NotificationService.instance.showError('Password is too weak.');
        } else {
          NotificationService.instance.showError(e.message ?? 'Signup error');
        }
      } catch (e) {
        isLoading.value = false;
        NotificationService.instance.showError('Signup failed: $e');
      }
    }
  }
}
