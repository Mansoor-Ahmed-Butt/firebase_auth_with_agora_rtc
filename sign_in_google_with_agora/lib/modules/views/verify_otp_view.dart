import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  final String? verificationId;
  final String? phone;

  const VerifyOtpView({super.key, this.verificationId, this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (phone != null) Text('Code sent to $phone'),
            const SizedBox(height: 16),
            Pinput(length: 6, controller: controller.pinController, onCompleted: (pin) => controller.verifyCode(verificationId ?? '', context)),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isVerifying.value ? null : () => controller.verifyCode(verificationId ?? '', context),
                child: controller.isVerifying.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
              ),
            ),
            TextButton(onPressed: () => controller.resendCode(phone ?? '', context), child: const Text('Resend code')),
          ],
        ),
      ),
    );
  }
}
