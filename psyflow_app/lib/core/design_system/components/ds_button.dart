/// Design System Button Component
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

enum DSButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  destructive,
}

enum DSButtonSize {
  small,
  medium,
  large,
}

class DSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? customColor;

  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = customColor ?? AppColors.primary;
    
    final buttonStyle = _getButtonStyle(context, effectiveColor, isDark, size);
    final textStyle = _getTextStyle(context, effectiveColor, isDark);

    final child = isLoading
        ? SizedBox(
            width: _getSpinnerSize(),
            height: _getSpinnerSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == DSButtonVariant.primary || variant == DSButtonVariant.destructive
                    ? Colors.white
                    : effectiveColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: _getIconSize(), color: textStyle.color),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(label, style: textStyle),
              if (trailingIcon != null) ...[
                SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, size: _getIconSize(), color: textStyle.color),
              ],
            ],
          );

    final button = switch (variant) {
      DSButtonVariant.primary => FilledButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      DSButtonVariant.secondary => FilledButton.tonal(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      DSButtonVariant.outlined => OutlinedButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      DSButtonVariant.text => TextButton(
          style: buttonStyle,
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      DSButtonVariant.destructive => FilledButton(
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStatePropertyAll(AppColors.error),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
    };

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  ButtonStyle _getButtonStyle(BuildContext context, Color color, bool isDark, DSButtonSize size) {
    final baseStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(_getPadding(size)),
      minimumSize: WidgetStatePropertyAll(_getMinSize(size)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.button)),
      ),
      elevation: WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(_getTextStyle(context, color, isDark)),
    );

    return switch (variant) {
      DSButtonVariant.primary => baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(color),
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        ),
      DSButtonVariant.secondary => baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(isDark ? color.withOpacity(0.15) : color.withOpacity(0.1)),
          foregroundColor: WidgetStatePropertyAll(color),
        ),
      DSButtonVariant.outlined => baseStyle.copyWith(
          side: WidgetStatePropertyAll(BorderSide(color: color, width: 1.5)),
          foregroundColor: WidgetStatePropertyAll(color),
        ),
      DSButtonVariant.text => baseStyle.copyWith(
          foregroundColor: WidgetStatePropertyAll(color),
        ),
      DSButtonVariant.destructive => baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(AppColors.error),
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        ),
    };
  }

  TextStyle _getTextStyle(BuildContext context, Color color, bool isDark) {
    final baseStyle = switch (size) {
      DSButtonSize.small => AppTypography.labelSmall,
      DSButtonSize.medium => AppTypography.labelLarge,
      DSButtonSize.large => AppTypography.titleMedium,
    };

    return baseStyle.copyWith(
      color: variant == DSButtonVariant.primary || variant == DSButtonVariant.destructive
          ? Colors.white
          : color,
    );
  }

  static EdgeInsetsGeometry _getPadding(DSButtonSize size) {
    return switch (size) {
      DSButtonSize.small => EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      DSButtonSize.medium => EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      DSButtonSize.large => EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
    };
  }

  static Size _getMinSize(DSButtonSize size) {
    return switch (size) {
      DSButtonSize.small => const Size(64, 32),
      DSButtonSize.medium => const Size(88, 40),
      DSButtonSize.large => const Size(120, 48),
    };
  }

  double _getIconSize() {
    return switch (size) {
      DSButtonSize.small => 14,
      DSButtonSize.medium => 18,
      DSButtonSize.large => 20,
    };
  }

  double _getSpinnerSize() {
    return switch (size) {
      DSButtonSize.small => 16,
      DSButtonSize.medium => 20,
      DSButtonSize.large => 24,
    };
  }
}