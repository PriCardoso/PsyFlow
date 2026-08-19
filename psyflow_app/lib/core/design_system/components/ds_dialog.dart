/// Design System Dialog & Bottom Sheet Components
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

class DSDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final CrossAxisAlignment actionsAlignment;
  final MainAxisAlignment actionsMainAxisAlignment;
  final bool barrierDismissible;
  final Color? backgroundColor;

  const DSDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding,
    this.actionsPadding,
    this.actionsAlignment = CrossAxisAlignment.end,
    this.actionsMainAxisAlignment = MainAxisAlignment.end,
    this.barrierDismissible = true,
    this.backgroundColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.dialog),
      ),
      elevation: AppElevation.modal,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Text(
                  title!,
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            if (content != null)
              Padding(
                padding: contentPadding ??
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: content!,
              ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: actionsPadding ??
                    const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                child: Row(
                  mainAxisAlignment: actionsMainAxisAlignment,
                  crossAxisAlignment: actionsAlignment,
                  children: actions!
                      .expand((widget) => [
                            widget,
                            if (widget != actions!.last)
                              const SizedBox(width: AppSpacing.md),
                          ])
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DSAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool barrierDismissible;

  const DSAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.barrierDismissible = true,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    bool barrierDismissible = true,
  }) {
    return DSDialog.show<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => DSAlertDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DSDialog(
      title: title,
      content: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Text(
          message,
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? Colors.white.withOpacity(0.8) : AppColors.textPrimary,
          ),
        ),
      ),
      actions: [
        if (cancelText != null || onCancel != null)
          DSTextButton(
            label: cancelText ?? 'Cancelar',
            onPressed: () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            },
          ),
        DSFilledButton(
          label: confirmText ?? 'Confirmar',
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
          variant: isDestructive ? DSButtonVariant.destructive : DSButtonVariant.primary,
        ),
      ],
      barrierDismissible: barrierDismissible,
    );
  }
}

class DSBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool isDismissible;
  final bool enableDrag;
  final double? maxHeight;
  final Color? backgroundColor;

  const DSBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.isDismissible = true,
    this.enableDrag = true,
    this.maxHeight,
    this.backgroundColor,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: builder,
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.bottomSheet),
        ),
        boxShadow: AppElevation.shadows(elevation: AppElevation.bottomSheet),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.2) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (title != null || actions != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: AppTypography.titleLarge.copyWith(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  if (actions != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions!
                          .expand((widget) => [
                                widget,
                                if (widget != actions!.last)
                                  const SizedBox(width: AppSpacing.md),
                              ])
                          .toList(),
                    ),
                ],
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// Convenience button classes for dialogs
class DSFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final bool isFullWidth;

  const DSFilledButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return DSButton(
      label: label,
      onPressed: onPressed,
      variant: variant,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}

class DSTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonSize size;
  final Color? color;

  const DSTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DSButton(
      label: label,
      onPressed: onPressed,
      variant: DSButtonVariant.text,
      size: size,
      customColor: color,
    );
  }
}

class DSOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonSize size;
  final Color? color;

  const DSOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.size = DSButtonSize.medium,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DSButton(
      label: label,
      onPressed: onPressed,
      variant: DSButtonVariant.outlined,
      size: size,
      customColor: color,
    );
  }
}