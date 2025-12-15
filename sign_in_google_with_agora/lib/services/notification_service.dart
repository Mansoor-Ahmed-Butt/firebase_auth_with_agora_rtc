import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  OverlayState? get _overlay => navigatorKey.currentState?.overlay;

  void show({required String message, SnackType type = SnackType.info, Duration duration = const Duration(seconds: 3)}) {
    final overlay = _overlay;
    if (overlay == null) {
      // Fallback: try ScaffoldMessenger if overlay not available
      try {
        navigatorKey.currentContext != null
            ? ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(message)))
            : null;
      } catch (_) {}
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: Center(
          child: CustomSnackBar(
            message: message,
            type: type,
            duration: duration,
            onDismiss: () {
              entry.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);
  }

  void showSuccess(String message) => show(message: message, type: SnackType.success);
  void showError(String message) => show(message: message, type: SnackType.error);
  void showInfo(String message) => show(message: message, type: SnackType.info);
}
