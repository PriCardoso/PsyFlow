import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/appointment_service.dart';
import '../../../models/appointment_item.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/panel_card.dart';
import '../../auth/presentation/pages/edit_profile_page.dart';
import '../../patient/enter_invite_page.dart';
import '../../tasks/patient_tasks_page.dart';
import '../../mood/mood_page.dart';
import '../../appointments/book_appointment_page.dart';

class PatientDashboardPage extends StatefulWidget {
  final String? initialName;

  const PatientDashboardPage({super.key, this.initialName});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final _appointmentService =
    AppointmentService(Supabase.instance.client);
  String? userName;
  String? userEmail;
  List<AppointmentItem> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    userName = widget.initialName;
    userEmail = Supabase.instance.client.auth.currentUser?.email;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final appts = await _appointmentService.getMyAppointmentsAsPatient();
      if (mounted) setState(() => _appointments = appts);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${(d.year % 100).toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}h${d.minute > 0 ? d.minute.toString().padLeft(2, '0') : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = userName?.split(' ').first ?? 'Paciente';
    final upcoming = _appointments.where((a) => a.isUpcoming).toList();
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        userName: userName ?? 'Paciente',
        userEmail: userEmail ?? '',
        roleLabel: 'Paciente',
        accentColor: AppColors.patient,
        selectedIndex: 0,
        items: [
          DrawerMenuItem(
            label: 'Início',
            icon: Icons.home_rounded,
            onTap: () {},
          ),
          DrawerMenuItem(
            label: 'Minhas consultas',
            icon: Icons.calendar_today_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookAppointmentPage())),
          ),
          DrawerMenuItem(
            label: 'Meu Psicólogo',
            icon: Icons.psychology_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnterInvitePage())),
          ),
          DrawerMenuItem(
            label: 'Minhas Tarefas',
            icon: Icons.task_alt_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientTasksPage())),
          ),
          DrawerMenuItem(
            label: 'Mapa Emocional',
            icon: Icons.favorite_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodPage())),
          ),
          DrawerMenuItem(
            label: 'Configurações',
            icon: Icons.settings_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.patient,
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              // ── Header simples ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'PsyFlow',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.patient),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.patient, AppColors.accentLight]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Saudação + botão agendar ────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Bem-vindo(a), $firstName',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.patient,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
                        ).then((_) => _load()),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: const Text('Marcar consulta', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Próxima consulta ─────────────────────────
                    PanelCard(
                      title: 'Próxima consulta',
                      footerLabel: 'Ver todas as consultas',
                      onFooterTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookAppointmentPage()),
                      ).then((_) => _load()),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(color: AppColors.patient, strokeWidth: 2)),
                            )
                          : next == null
                              ? const PanelEmptyState(
                                  icon: Icons.event_busy_rounded,
                                  title: 'Nenhuma consulta agendada',
                                  subtitle: 'Marque uma consulta para começar',
                                )
                              : Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.success,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            _formatDate(next.startTime),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatTime(next.startTime),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'agendada',
                                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(colors: [AppColors.psychologist, AppColors.gradientEnd]),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 16),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Consulta com',
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            next.otherPartyName ?? 'Psicólogo',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                                          ),
                                          const Text(
                                            'Psicólogo(a)',
                                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                    const SizedBox(height: 16),

                    // ── Grid de 2 cards: Meu psicólogo / Espaço PsyFlow ─
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: (constraints.maxWidth - 16) / 2,
                              child: PanelCard(
                                title: 'Meu Psicólogo',
                                footerLabel: 'Ver vínculo',
                                onFooterTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EnterInvitePage()),
                                ),
                                child: const PanelEmptyState(
                                  icon: Icons.psychology_outlined,
                                  title: 'Toque para ver',
                                ),
                              ),
                            ),
                            SizedBox(
                              width: (constraints.maxWidth - 16) / 2,
                              child: PanelCard(
                                title: 'Mapa Emocional',
                                footerLabel: 'Registrar humor',
                                onFooterTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MoodPage()),
                                ),
                                child: const PanelEmptyState(
                                  icon: Icons.favorite_outline_rounded,
                                  title: 'Como você está hoje?',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Minhas tarefas ───────────────────────────
                    PanelCard(
                      title: 'Minhas Tarefas',
                      footerLabel: 'Ver todas as tarefas',
                      onFooterTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PatientTasksPage()),
                      ),
                      child: const PanelEmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'Acompanhe suas atividades',
                        subtitle: 'Tarefas atribuídas pelo seu psicólogo aparecem aqui',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Espaço PsyFlow (estilo "Espaço Telavita") ──
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE7ECF1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Espaço PsyFlow',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.patient.withValues(alpha: 0.15), AppColors.accentLight.withValues(alpha: 0.1)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text('💜', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Seu espaço seguro para acompanhar sua jornada de bem-estar, com ferramentas e acompanhamento contínuo.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
