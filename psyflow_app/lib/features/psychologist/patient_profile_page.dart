import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/invite_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/patient_link_model.dart';
import '../mood/patient_mood_history_page.dart';
import '../tasks/psychologist_tasks_page.dart';

class PatientProfilePage extends StatefulWidget {
  final PatientLink link;
  final VoidCallback? onStatusChanged;

  const PatientProfilePage({
    super.key,
    required this.link,
    this.onStatusChanged,
  });

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final _service = sl<InviteService>();
  bool _loading = false;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.link.active;
  }

  Future<void> _toggleLink() async {
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _loading = true);
    try {
      if (_isActive) {
        await _service.deactivateLink(widget.link.linkId);
      } else {
        await _service.reactivateLink(widget.link.linkId);
      }
      setState(() => _isActive = !_isActive);
      widget.onStatusChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isActive ? 'Vínculo reativado!' : 'Paciente desvinculado.'),
            backgroundColor: _isActive ? AppColors.success : AppColors.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<bool> _showConfirmDialog() async {
    final name = widget.link.patient.fullName;
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isActive ? 'Desvincular paciente' : 'Reativar vínculo',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          _isActive
              ? 'Deseja desvincular $name? O vínculo pode ser reativado depois.'
              : 'Deseja reativar o vínculo com $name?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _isActive ? 'Desvincular' : 'Reativar',
              style: TextStyle(
                color: _isActive ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDate(DateTime date) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.link.patient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppColors.psychologist,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.psychologist, AppColors.gradientEnd],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            patient.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Badge de status
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isActive
                              ? AppColors.success.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isActive
                                ? AppColors.success.withValues(alpha: 0.5)
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _isActive
                                    ? AppColors.success
                                    : Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isActive ? 'Vínculo ativo' : 'Vínculo inativo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Informações ──────────────────────────────
                const _SectionTitle(title: 'Informações'),
                const SizedBox(height: 12),
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'E-mail',
                      value: patient.email,
                    ),
                    if (patient.phone != null &&
                        patient.phone!.isNotEmpty) ...[
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        value: patient.phone!,
                      ),
                    ],
                    const _Divider(),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Paciente desde',
                      value: _formatDate(widget.link.createdAt),
                    ),
                  ],
                ),

                // ── Bio ──────────────────────────────────────
                if (patient.bio != null && patient.bio!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Sobre o paciente'),
                  const SizedBox(height: 12),
                  _InfoCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          patient.bio!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Acompanhamento ────────────────────────────
                const SizedBox(height: 24),
                const _SectionTitle(title: 'Acompanhamento'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.favorite_rounded,
                        label: 'Mapa Emocional',
                        color: AppColors.cardRed,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientMoodHistoryPage(
                              patientId: patient.id,
                              patientName: patient.fullName,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.task_alt_rounded,
                        label: 'Tarefas',
                        color: AppColors.cardGreen,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PsychologistTasksPage()),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Ação ─────────────────────────────────────
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: _isActive
                      ? OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _loading ? null : _toggleLink,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error),
                                )
                              : const Icon(Icons.link_off_rounded),
                          label: const Text('Desvincular paciente',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _loading ? null : _toggleLink,
                          icon: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Icon(Icons.link_rounded),
                          label: const Text('Reativar vínculo',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ───────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.psychologist.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: AppColors.psychologist, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(
          height: 1,
          color: AppColors.textSecondary.withValues(alpha: 0.12),
        ),
      );
}
