import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Card branco simples com título e conteúdo — estilo painel Telavita
class PanelCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? footerLabel;
  final VoidCallback? onFooterTap;

  const PanelCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.onTap,
    this.footerLabel,
    this.onFooterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECF1)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 14),
                child,
                if (footerLabel != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: onFooterTap,
                    child: Text(
                      footerLabel!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vazio dentro de um PanelCard (ex: "Nenhuma reserva criada")
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
