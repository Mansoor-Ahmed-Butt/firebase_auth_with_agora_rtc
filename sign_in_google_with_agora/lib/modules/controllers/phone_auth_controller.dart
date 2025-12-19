import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/auth/firebase_auth/firebase_auth.dart';
import 'package:sign_in_google_with_agora/services/notification_service.dart';

class PhoneAuthController extends GetxController {
  TextEditingController phoneController = TextEditingController();
  final RxBool isSending = false.obs;
  String? phoneNumber;

  Future<void> sendCode(BuildContext context) async {
    // Prefer the complete number provided by IntlPhoneField (includes country code)
    final phone = (phoneNumber != null && phoneNumber!.isNotEmpty) ? phoneNumber!.trim() : phoneController.text.trim();

    if (phone.isEmpty) {
      NotificationService.instance.showInfo('Please enter a phone number');
      return;
    }

    debugPrint('Sending code to $phone');
    isSending.value = true;
    EasyLoading.show(status: 'Sending code...');
    try {
      await AuthService.instance.verifyPhoneNumbertoLogIn(context, phone);
    } finally {
      isSending.value = false;
      EasyLoading.dismiss();
    }
  }
}
