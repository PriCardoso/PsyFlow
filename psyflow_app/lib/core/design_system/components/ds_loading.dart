/// Design System Loading & Empty State Components
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

class DSLoading extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? message;

  const DSLoading({
    super.key,
    this.size = 24,
    this.strokeWidth = 3,
    this.color,
    this.message,
  });

  const DSLoading.small({
    super.key,
    this.color,
    this.message,
  }) : size = 16,
       strokeWidth = 2;

  const DSLoading.large({
    super.key,
    this.color,
    this.message,
  }) : size = 48,
       strokeWidth = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class DSLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? color;

  const DSLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: DSLoading.large(
                  color: color,
                  message: message,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DSShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const DSShimmer({
    super.key,
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<DSShimmer> createState() => _DSShimmerState();
}

class _DSShimmerState extends State<DSShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = widget.baseColor ?? (isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300]!);
    final highlightColor = widget.highlightColor ?? (isDark ? Colors.white.withOpacity(0.2) : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((v) => v.clamp(0.0, 1.0)).toList(),
              transform: const GradientRotation(0.5),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class DSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const DSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  const DSEmptyState.noData({
    super.key,
    String? title,
    String? subtitle,
    this.action,
    this.padding,
  }) : icon = Icons.inbox_outlined,
       title = title ?? 'Nenhum dado encontrado',
       subtitle = subtitle ?? 'Parece que não há nada aqui ainda';

  const DSEmptyState.noConnection({
    super.key,
    this.action,
    this.padding,
  }) : icon = Icons.wifi_off_rounded,
       title = 'Sem conexão',
       subtitle = 'Verifique sua internet e tente novamente';

  const DSEmptyState.error({
    super.key,
    String? title,
    String? subtitle,
    this.action,
    this.padding,
  }) : icon = Icons.error_outline_rounded,
       title = title ?? 'Oops! Algo deu errado',
       subtitle = subtitle ?? 'Tente novamente mais tarde';

  const DSEmptyState.noSearchResults({
    super.key,
    String? query,
    this.action,
    this.padding,
  }) : icon = Icons.search_off_rounded,
       title = 'Nenhum resultado',
       subtitle = query != null ? 'Nenhum resultado para "$query"' : 'Tente buscar com outros termos';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

class DSEmptyStateSliver extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const DSEmptyStateSliver({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: DSEmptyState(
          icon: icon,
          title: title,
          subtitle: subtitle,
          action: action,
        ),
      ),
    );
  }
}

class DSPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final String? message;

  const DSPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.primary;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: effectiveColor,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      displacement: 40,
      strokeWidth: 3,
      child: child,
    );
  }
}