import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/services/notification_service.dart';

class VerifyOtpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController pinController = TextEditingController();
  final RxBool isVerifying = false.obs;

  Future<void> verifyCode(String verificationId, BuildContext context) async {
    final smsCode = pinController.text.trim();
    if (verificationId.isEmpty || smsCode.isEmpty) {
      NotificationService.instance.showInfo('Please enter the verification code');

      return;
    }

    isVerifying.value = true;
    try {
      final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
      await _auth.signInWithCredential(credential);
      if (context.mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      NotificationService.instance.showError('Verification failed: ${e.message}');
    } catch (e) {
      NotificationService.instance.showError('Error: $e');
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendCode(String phone, BuildContext context) async {
    if (phone.isEmpty) return;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            if (context.mounted) context.go('/home');
          } catch (_) {}
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resend failed: ${e.message}')));
        },
        codeSent: (verificationId, _) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code resent')));
        },
        codeAutoRetrievalTimeout: (v) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void onClose() {
    pinController.dispose();
    super.onClose();
  }
}
