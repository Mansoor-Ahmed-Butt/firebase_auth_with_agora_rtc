import 'package:go_router/go_router.dart';
import '../services/notification_service.dart';
import 'package:sign_in_google_with_agora/modules/auth/views/home_screen.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/signup_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/auth_wrapper.dart';

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
    ],
  );
}
