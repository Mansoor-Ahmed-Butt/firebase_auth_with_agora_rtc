import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import 'package:sign_in_google_with_agora/modules/views/home_screen.dart';

import '../modules/bindings/auth_binding.dart';
import '../modules/views/login_view.dart';
import '../modules/views/signup_view.dart';
import '../modules/views/forgot_password_view.dart';
import '../modules/views/phone_auth_view.dart';
import '../modules/views/verify_otp_view.dart';
import '../auth/auth_wrapper.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: NotificationService.instance.navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const AuthWrapper();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const LoginView();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const SignupView();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) {
          AuthBinding().dependencies();
          return ForgotPasswordView();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const PhoneAuthView();
        },
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          AuthBinding().dependencies();
          final extra = state.extra as Map<String, dynamic>?;
          final verificationId = extra?['verificationId'] as String?;
          final phone = extra?['phone'] as String?;
          return VerifyOtpView(verificationId: verificationId, phone: phone);
        },
      ),
    ],
  );
}
