import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.secondary;
        fg = AppColors.textPrimary;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.primary;
        side = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = AppColors.primary;
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: side,
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.fromBorderSide(side),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
