import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppChip extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.primary;
    final bg = selected ? baseColor : baseColor.withAlpha(25);
    final fg = selected ? Colors.white : baseColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? baseColor : baseColor.withAlpha(80),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
