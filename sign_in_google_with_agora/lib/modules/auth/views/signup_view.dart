import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/widgets/common/custom_text_field.dart';
import '../controllers/signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.purple.shade400, Colors.blue.shade400]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Obx(
                () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: const Icon(Icons.person_add_outlined, size: 60, color: Colors.purple),
                    ),
                    const SizedBox(height: 40),

                    // Welcome text
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text('Sign up to get started', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
                    const SizedBox(height: 40),

                    // Signup form
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // CustomAppTextField(
                            //   controller: controller.nameController,
                            //   label: 'Phone',
                            //   icon: Icons.phone_rounded,
                            //   hint: '+1 234 567 890',
                            //   keyboardType: TextInputType.phone,
                            // ),
                            CustomAppTextField(
                              controller: controller.nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              hint: 'John Doe',
                              keyboardType: TextInputType.name,
                              validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 16),

                            CustomAppTextField(
                              controller: controller.emailController,
                              label: 'Email',
                              icon: Icons.email_rounded,
                              hint: 'john@example.com',
                              keyboardType: TextInputType.emailAddress,
                              // Custom email validator
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Email is required';
                                if (!value.contains('@')) return 'Please enter a valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomAppTextField(
                              controller: controller.passwordController,
                              label: 'Password',
                              icon: Icons.email_rounded,

                              obscureText: controller.obscurePassword.value,
                              hint: 'Password',

                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () {
                                  controller.obscurePassword.value = !controller.obscurePassword.value;
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            CustomAppTextField(
                              controller: controller.confirmPasswordController,
                              hint: 'Confirm Password',
                              label: 'Confirm Password',
                              icon: Icons.lock_outline,

                              obscureText: controller.obscureConfirmPassword.value,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(controller.obscureConfirmPassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () {
                                  controller.obscureConfirmPassword.value = !controller.obscureConfirmPassword.value;
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != controller.passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: controller.agreeToTerms.value,
                                  onChanged: (value) {
                                    controller.agreeToTerms.value = value ?? false;
                                  },
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.agreeToTerms.value = !controller.agreeToTerms.value;
                                    },
                                    child: const Text('I agree to Terms & Conditions', style: TextStyle(fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          controller.signup(context);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                      )
                                    : const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
