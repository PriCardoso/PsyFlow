import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;
  final EdgeInsetsGeometry contentPadding;
  final bool barrierDismissible;
  final Widget? icon;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.maxWidth = 400,
    this.contentPadding = const EdgeInsets.all(20),
    this.barrierDismissible = true,
    this.icon,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    double maxWidth = 400,
    bool barrierDismissible = true,
    Widget? icon,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
        barrierDismissible: barrierDismissible,
        icon: icon,
      ),
    );
  }

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
    Widget? icon,
  }) {
    return show<bool>(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isDestructive ? AppColors.error : null,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<void> alert({
    required BuildContext context,
    required String title,
    required String message,
    String okText = 'OK',
    Widget? icon,
  }) {
    return show(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(height: 16),
          ],
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(okText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.semiBold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: contentPadding,
                child: content,
              ),
              if (actions != null && actions!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!.map((action) {
                      if (action is TextButton || action is FilledButton || action is OutlinedButton) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: action,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry contentPadding;
  final bool isDismissible;
  final bool enableDrag;
  final double? initialChildSize;
  final double? maxChildSize;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.contentPadding = const EdgeInsets.all(20),
    this.isDismissible = true,
    this.enableDrag = true,
    this.initialChildSize,
    this.maxChildSize,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    double? initialChildSize,
    double? maxChildSize,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        content: content,
        actions: actions,
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: initialChildSize ?? 0.5,
      maxChildSize: maxChildSize ?? 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.semiBold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: contentPadding,
                  child: content,
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!.map((action) {
                        if (action is TextButton || action is FilledButton || action is OutlinedButton) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: action,
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}