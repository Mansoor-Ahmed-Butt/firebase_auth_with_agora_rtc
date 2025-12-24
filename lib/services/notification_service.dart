import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

/// Simple notification service that shows `AwesomeSnackbarContent` via the
/// app `navigatorKey`. Keep this file focused and robust: if no mounted
/// navigator context is available we no-op rather than throwing.
enum SnackType { success, error, info }

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext? get _context => navigatorKey.currentContext;

  void show({required String message, SnackType type = SnackType.info, Duration duration = const Duration(seconds: 3)}) {
    final ctx = _context;
    if (ctx == null) return; // no mounted navigator; nothing to do

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contentType = type == SnackType.success
          ? ContentType.success
          : type == SnackType.error
          ? ContentType.failure
          : ContentType.help;

      final title = type == SnackType.success
          ? 'Success'
          : type == SnackType.error
          ? 'Error'
          : 'Info';

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: AwesomeSnackbarContent(title: title, message: message, contentType: contentType),
      );

      final messenger = ScaffoldMessenger.maybeOf(ctx);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(snackBar);
    });
  }

  void showSuccess(String message) => show(message: message, type: SnackType.success);
  void showError(String message) => show(message: message, type: SnackType.error);
  void showInfo(String message) => show(message: message, type: SnackType.info);
}
