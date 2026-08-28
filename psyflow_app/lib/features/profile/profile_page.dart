import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/services.dart';
import 'package:psyflow_app/core/services/data_export_service.dart';
import 'package:psyflow_app/core/providers/user_provider.dart';
import 'package:psyflow_app/core/providers/locale_provider.dart';
import 'package:psyflow_app/core/theme/app_theme.dart';
import 'package:psyflow_app/core/design_system/components/ds_button.dart';
import 'package:psyflow_app/core/design_system/tokens/tokens.dart';
import 'package:psyflow_app/core/services/analytics_service.dart';
import 'package:psyflow_app/core/di/service_locator.dart';
import 'package:psyflow_app/features/profile/change_password_page.dart';
import 'package:psyflow_app/features/auth/presentation/auth_gate.dart';
import 'package:psyflow_app/l10n/generated/app_localizations.dart';

/// Página de perfil do usuário com dados reais e seletor de idioma.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loggingOut = false;
  bool _exportingData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadProfile();
    });
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  String _roleLabel(String? role) {
    switch (role) {
      case 'psychologist':
      case 'professional':
        return 'Psicólogo(a)';
      case 'patient':
        return 'Paciente';
      default:
        return 'Usuário';
    }
  }

  Color _roleColor(String? role) {
    switch (role) {
      case 'psychologist':
      case 'professional':
        return AppColors.psychologist;
      default:
        return AppColors.patient;
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    try {
      await sl<AnalyticsService>().logLogout();
      context.read<UserProvider>().logout();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Future<void> _exportUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _exportingData = true);
    try {
      final jsonString = await sl<DataExportService>().exportUserDataAsFormattedJson(uid);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Exportação LGPD'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Seus dados pessoais foram compilados com sucesso conforme os direitos de portabilidade da LGPD/GDPR.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 160,
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Text(
                      jsonString,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonString));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados copiados para a área de transferência!')),
                );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copiar JSON'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar dados: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _exportingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final name = userProvider.fullName;
    final email = userProvider.userEmail;
    final role = userProvider.userRole;
    final color = _roleColor(role);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: userProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // ── Avatar & Info ──────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: color.withOpacity(0.15),
                        child: Text(
                          _initials(name),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        name ?? 'Sem nome',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        email ?? '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppBorderRadius.full),
                        ),
                        child: Text(
                          _roleLabel(role),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                const Divider(),

                // ── Dados adicionais ───────────────────────────────────────
                if (profile != null) ...[
                  if ((profile['phone'] as String?)?.isNotEmpty == true)
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Telefone',
                      value: profile['phone'] as String,
                    ),
                  if ((profile['crp'] as String?)?.isNotEmpty == true)
                    _InfoTile(
                      icon: Icons.badge_outlined,
                      label: 'CRP',
                      value: profile['crp'] as String,
                    ),
                  if ((profile['bio'] as String?)?.isNotEmpty == true)
                    _InfoTile(
                      icon: Icons.info_outline,
                      label: 'Bio',
                      value: profile['bio'] as String,
                    ),
                ],

                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),

                // ── Ações ──────────────────────────────────────────────────
                _ActionTile(
                  icon: Icons.lock_outline,
                  label: 'Alterar senha',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
                _ActionTile(
                  icon: Icons.download_outlined,
                  label: _exportingData ? 'Exportando dados...' : 'Exportar meus dados (LGPD)',
                  onTap: _exportingData ? () {} : _exportUserData,
                ),

                const SizedBox(height: AppSpacing.lg),

                DSButton(
                  label: _loggingOut ? 'Saindo...' : 'Sair da conta',
                  variant: DSButtonVariant.outlined,
                  isFullWidth: true,
                  isLoading: _loggingOut,
                  leadingIcon: Icons.logout,
                  customColor: AppColors.error,
                  onPressed: _loggingOut ? null : _confirmLogout,
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Idioma ──────────────────────────────────────────────────
                Consumer<LocaleProvider>(
                  builder: (context, localeProvider, _) {
                    final l10n = AppLocalizations.of(context)!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.language,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _LanguageTile(
                          locale: const Locale('pt', 'BR'),
                          label: l10n.portuguese,
                          isSelected:
                              localeProvider.locale.languageCode == 'pt',
                          onTap: () => localeProvider.setLanguage('pt', countryCode: 'BR'),
                        ),
                        _LanguageTile(
                          locale: const Locale('en', 'US'),
                          label: l10n.english,
                          isSelected:
                              localeProvider.locale.languageCode == 'en',
                          onTap: () => localeProvider.setLanguage('en', countryCode: 'US'),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }
}

// ── Helpers internos ───────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.locale,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Locale locale;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}