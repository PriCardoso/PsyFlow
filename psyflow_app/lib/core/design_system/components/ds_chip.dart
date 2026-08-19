/// Design System Chip & Badge Components
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

class DSChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final bool isSelected;
  final DSChipVariant variant;

  const DSChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
    this.onTap,
    this.onDeleted,
    this.isSelected = false,
    this.variant = DSChipVariant.defaultChip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.primary;
    final effectiveTextColor = textColor ?? (isSelected || variant == DSChipVariant.filled ? Colors.white : effectiveColor);
    final backgroundColor = _getBackgroundColor(isDark, effectiveColor);

    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.chip),
        border: variant == DSChipVariant.outlined
            ? Border.all(color: effectiveColor, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: effectiveTextColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: effectiveTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: effectiveTextColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.chip),
          child: chip,
        ),
      );
    }

    return chip;
  }

  Color _getBackgroundColor(bool isDark, Color color) {
    switch (variant) {
      case DSChipVariant.filled:
        return isSelected ? color : color.withOpacity(isDark ? 0.2 : 0.1);
      case DSChipVariant.outlined:
        return Colors.transparent;
      case DSChipVariant.defaultChip:
      default:
        return isSelected ? color.withOpacity(0.2) : (isDark ? color.withOpacity(0.15) : color.withOpacity(0.1));
    }
  }
}

enum DSChipVariant {
  defaultChip,
  filled,
  outlined,
}

class DSBadge extends StatelessWidget {
  final String label;
  final DSBadgeVariant variant;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const DSBadge({
    super.key,
    required this.label,
    this.variant = DSBadgeVariant.defaultBadge,
    this.fontSize = 10,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case DSBadgeVariant.defaultBadge:
        backgroundColor = isDark ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        break;
      case DSBadgeVariant.success:
        backgroundColor = isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case DSBadgeVariant.warning:
        backgroundColor = isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case DSBadgeVariant.error:
        backgroundColor = isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case DSBadgeVariant.info:
        backgroundColor = isDark ? AppColors.info.withOpacity(0.2) : AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case DSBadgeVariant.neutral:
        backgroundColor = isDark ? Colors.white.withOpacity(0.1) : AppColors.surfaceVariant;
        textColor = isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary;
        break;
    }

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.chip),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum DSBadgeVariant {
  defaultBadge,
  success,
  warning,
  error,
  info,
  neutral,
}

class DSStatusIndicator extends StatelessWidget {
  final DSStatus status;
  final double size;
  final String? label;

  const DSStatusIndicator({
    super.key,
    required this.status,
    this.size = 8,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color color;
    switch (status) {
      case DSStatus.online:
        color = AppColors.success;
        break;
      case DSStatus.away:
        color = AppColors.warning;
        break;
      case DSStatus.busy:
        color = AppColors.error;
        break;
      case DSStatus.offline:
        color = isDark ? Colors.white.withOpacity(0.4) : AppColors.textMuted;
        break;
      case DSStatus.pending:
        color = AppColors.info;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              width: 2,
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            label!,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

enum DSStatus {
  online,
  away,
  busy,
  offline,
  pending,
}