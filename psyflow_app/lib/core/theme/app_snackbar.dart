import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppSnackBarType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        content: _SnackBarContent(message: message, type: type),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, type: AppSnackBarType.success, actionLabel: actionLabel, onAction: onAction);
  }

  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, type: AppSnackBarType.error, actionLabel: actionLabel, onAction: onAction);
  }

  static void warning(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, type: AppSnackBarType.warning, actionLabel: actionLabel, onAction: onAction);
  }

  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, type: AppSnackBarType.info, actionLabel: actionLabel, onAction: onAction);
  }
}

class _SnackBarContent extends StatelessWidget {
  final String message;
  final AppSnackBarType type;

  const _SnackBarContent({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;

    switch (type) {
      case AppSnackBarType.success:
        bgColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackBarType.error:
        bgColor = AppColors.error;
        icon = Icons.error_rounded;
        break;
      case AppSnackBarType.warning:
        bgColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        break;
      case AppSnackBarType.info:
        bgColor = AppColors.info;
        icon = Icons.info_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}