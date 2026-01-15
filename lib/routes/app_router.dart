import 'package:go_router/go_router.dart';
import 'package:sign_in_google_with_agora/modules/views/bottom_navigation_screens/chat_screen/chat_detail_screen.dart';
import 'package:sign_in_google_with_agora/modules/views/google_map.dart';
import 'package:sign_in_google_with_agora/modules/views/home_screen.dart';
import '../services/notification_service.dart';
import 'package:sign_in_google_with_agora/modules/views/video_call_screen.dart';

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
          return LoginView();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) {
          AuthBinding().dependencies();
          return SignupView();
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          AuthBinding().dependencies();
          return MapView();
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
        path: '/video_call_screen',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const VideoCallScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          AuthBinding().dependencies();
          return HomeScreen();
        },
      ),
      GoRoute(
        path: '/chatDetailScreen',
        builder: (context, state) {
          AuthBinding().dependencies();
          final extra = state.extra as Map<String, dynamic>?;
          final receiverId = extra?['receiverId'] as String? ?? '';
          final receiverName = extra?['receiverName'] as String? ?? '';
          return ChatDetailScreen(receiverId: receiverId, receiverName: receiverName);
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
