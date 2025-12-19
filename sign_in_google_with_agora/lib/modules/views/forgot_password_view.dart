import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/services/notification_service.dart';
import 'package:sign_in_google_with_agora/widgets/common/custom_text_field.dart';
import '../controllers/forgot_password_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:sign_in_google_with_agora/routes/app_router.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  ForgotPasswordView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //  CustomAppTextField(

                      //       controller: controller.emailController,
                      //       keyboardType: TextInputType.emailAddress,
                      //       label: 'Email',
                      //       icon: Icons.email_rounded,

                      //       hint: 'Email',

                      //       prefixIcon: const Icon(Icons.lock_outline),

                      //       validator: (value) {
                      //         if (value == null || value.isEmpty) {
                      //           return 'Please enter your email';
                      //         }
                      //         if (!value.contains('@')) {
                      //           return 'Please enter a valid email';
                      //         }
                      //         return null;
                      //       },
                      //     ),
                      TextFormField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', hintText: 'Enter your account email'),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter your email';
                          if (!v.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    if (!(_formKey.currentState?.validate() ?? false)) return;
                                    NotificationService.instance.showSuccess('Password reset email sent. Check your inbox.');
                                    await Future.delayed(const Duration(seconds: 3));
                                    if (!context.mounted) return;
                                    context.go('/login');

                                    // // hide keyboard to avoid focus/navigation issues
                                    // FocusScope.of(context).unfocus();
                                    // // debug
                                    // // ignore: avoid_print
                                    // print('ForgotPasswordView: calling sendReset');
                                    // final success = await controller.sendReset();
                                    // // debug
                                    // // ignore: avoid_print
                                    // print('ForgotPasswordView: sendReset returned $success');
                                    // if (success) {
                                    //   // small delay to ensure state updates and keyboard hide finish
                                    //   await Future.delayed(const Duration(milliseconds: 200));
                                    //   // force-clear loading in case controller state didn't propagate yet
                                    //   controller.isLoading.value = false;
                                    //   if (!context.mounted) return;
                                    //   // use the app router instance in a post-frame callback
                                    //   SchedulerBinding.instance.addPostFrameCallback((_) {
                                    //     AppRouter.router.go('/login');
                                    //   });
                                    // }
                                  },
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                                : const Text('Send Reset Email'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
