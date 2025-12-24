import 'package:flutter/material.dart';

enum SnackType { success, error, info }

class CustomSnackBar extends StatefulWidget {
  final String message;
  final SnackType type;
  final Duration duration;
  final VoidCallback? onDismiss;

  const CustomSnackBar({super.key, required this.message, this.type = SnackType.info, this.duration = const Duration(seconds: 3), this.onDismiss});

  @override
  State<CustomSnackBar> createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    Future.delayed(widget.duration, _hide);
  }

  void _hide() async {
    await _ctrl.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _backgroundForType(SnackType type) {
    switch (type) {
      case SnackType.success:
        return Colors.green.shade700;
      case SnackType.error:
        return Colors.red.shade700;
      case SnackType.info:
      default:
        return Colors.black87;
    }
  }

  IconData _iconForType(SnackType type) {
    switch (type) {
      case SnackType.success:
        return Icons.check_circle_outline;
      case SnackType.error:
        return Icons.error_outline;
      case SnackType.info:
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgroundForType(widget.type);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: _ctrl,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(8),
              color: bg,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconForType(widget.type), color: Colors.white),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(widget.message, style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _hide,
                      child: const Icon(Icons.close, color: Colors.white70),
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
