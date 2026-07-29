import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double elevation;
  final double borderRadius;
  final Border? border;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.elevation = 1,
    this.borderRadius = 16,
    this.border,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColors.surfaceDark : AppColors.surface);
    final defaultShadow = shadows ??
        [
          BoxShadow(
            color: Colors.black.withAlpha(elevation <= 1 ? 15 : 30),
            blurRadius: elevation <= 1 ? 4 : elevation * 4,
            offset: Offset(0, elevation <= 1 ? 1 : 2),
          ),
        ];

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: isDark ? Colors.grey[800]! : AppColors.surfaceVariant),
        boxShadow: defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const AppCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.bold,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.muted,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final String? label;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppCardFooter({
    super.key,
    this.leading,
    this.trailing,
    this.label,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading!,
          if (label != null)
            Text(
              label!,
              style: Theme.of(context).textTheme.labelMedium?.semiBold,
            ),
          if (trailing != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: trailing!,
              ),
            ),
        ],
      ),
    );
  }
}

class PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? footerLabel;
  final VoidCallback? onFooterTap;
  final EdgeInsetsGeometry padding;

  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    this.footerLabel,
    this.onFooterTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.semiBold,
            ),
          ),
          Padding(padding: padding, child: child),
          if (footerLabel != null)
            AppCardFooter(
              label: footerLabel,
              onTap: onFooterTap,
              trailing: onFooterTap != null
                  ? const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary)
                  : null,
            ),
        ],
      ),
    );
  }
}

class PanelEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const PanelEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.muted,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}