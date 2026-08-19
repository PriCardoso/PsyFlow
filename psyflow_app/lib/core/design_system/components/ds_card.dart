/// Design System Card Component
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? shadows;

  const DSCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? (isDark ? AppColors.surfaceDark : AppColors.surface);
    final effectiveElevation = elevation ?? AppElevation.card;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppBorderRadius.card);
    final effectiveShadows = shadows ?? AppElevation.shadows(elevation: effectiveElevation);

    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: effectiveShadows,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: card,
        ),
      );
    }

    return card;
  }
}

class DSCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const DSCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class DSCardSection extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const DSCardSection({
    super.key,
    required this.title,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class DSCardActionRow extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment alignment;
  final EdgeInsetsGeometry? padding;

  const DSCardActionRow({
    super.key,
    required this.actions,
    this.alignment = MainAxisAlignment.end,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: AppSpacing.md),
      child: Row(
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: actions
            .expand((widget) => [
                  widget,
                  if (widget != actions.last) const SizedBox(width: AppSpacing.md),
                ])
            .toList(),
      ),
    );
  }
}