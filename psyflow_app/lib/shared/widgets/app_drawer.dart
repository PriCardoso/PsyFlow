import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/edit_profile_page.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String roleLabel;
  final Color accentColor;
  final int selectedIndex;
  final List<DrawerMenuItem> items;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.roleLabel,
    required this.accentColor,
    required this.selectedIndex,
    required this.items,
  });

  String get _initials {
    final parts = userName.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ── Cabeçalho com perfil ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfilePage()),
                      );
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accentColor, AppColors.gradientEnd]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userEmail,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            roleLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEDF1F5)),
            const SizedBox(height: 8),

            // ── Itens de menu ───────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final selected = i == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: selected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Icon(item.icon, color: selected ? accentColor : AppColors.textSecondary, size: 22),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                            color: selected ? accentColor : AppColors.textPrimary,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          item.onTap();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Color(0xFFEDF1F5)),

            // ── Sair ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
                title: const Text(
                  'Sair',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.error),
                ),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const DrawerMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
