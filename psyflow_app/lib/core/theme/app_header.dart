import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface);

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: bgColor,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.semiBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      actions: actions,
    );
  }
}

class AppHeaderWithAvatar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? userName;
  final String? userRole;
  final String? avatarUrl;
  final Color accentColor;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actions;

  const AppHeaderWithAvatar({
    super.key,
    required this.title,
    this.subtitle,
    this.userName,
    this.userRole,
    this.avatarUrl,
    required this.accentColor,
    this.onAvatarTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.semiBold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.muted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (userName != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onAvatarTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userRole != null)
                      Text(
                        userRole!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName!,
                          style: Theme.of(context).textTheme.bodyMedium?.semiBold,
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: accentColor.withAlpha(30),
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                          child: avatarUrl == null
                              ? Icon(
                                  Icons.person_rounded,
                                  size: 16,
                                  color: accentColor,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (actions != null) ...[
              const SizedBox(width: 8),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}

class AppSliverHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool pinned;
  final bool floating;

  const AppSliverHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface);

    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      elevation: 0,
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.semiBold,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.muted,
            ),
        ],
      ),
      actions: actions,
    );
  }
}