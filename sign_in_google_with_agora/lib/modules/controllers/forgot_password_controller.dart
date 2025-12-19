import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_google_with_agora/auth/firebase_auth/firebase_auth.dart';
import 'package:sign_in_google_with_agora/services/notification_service.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<bool> sendReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      NotificationService.instance.showError('Please enter a valid email');
      return false;
    }
    try {
      // debug
      // ignore: avoid_print
      print('ForgotPasswordController.sendReset: starting for $email');
      isLoading.value = true;
      await AuthService.instance.forgetPassword(email: email);
      // debug
      // ignore: avoid_print
      print('ForgotPasswordController.sendReset: forgetPassword returned');
      isLoading.value = false;
      NotificationService.instance.showSuccess('Password reset email sent. Check your inbox.');
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      NotificationService.instance.showError(e.message ?? 'Failed to send reset email');
      return false;
    } catch (e) {
      isLoading.value = false;
      NotificationService.instance.showError('An unexpected error occurred');
      return false;
    }
  }
}
