import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/services/therapist_patient_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/appointment_item.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/panel_card.dart';
import '../../auth/presentation/pages/edit_profile_page.dart';
import '../../patients/presentation/pages/link_patient_page.dart';
import '../../tasks/psychologist_tasks_page.dart';
import '../../appointments/manage_availability_page.dart';

class PsychologistDashboardPage extends StatefulWidget {
  final String? initialName;

  const PsychologistDashboardPage({super.key, this.initialName});

  @override
  State<PsychologistDashboardPage> createState() => _PsychologistDashboardPageState();
}

class _PsychologistDashboardPageState extends State<PsychologistDashboardPage> {
  final _appointmentService = sl<AppointmentService>();
  final _therapistPatientService = sl<TherapistPatientService>();

  String? userName;
  String? userEmail;
  List<AppointmentItem> _appointments = [];
  int _activePatients = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    userName = widget.initialName;
    userEmail = FirebaseAuth.instance.currentUser?.email;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final appts = await _appointmentService.getMyAppointmentsAsPsychologist(user.uid);
      final links = await _therapistPatientService.getMyPatientsLinks();
      if (mounted) {
        setState(() {
          _appointments = appts;
          _activePatients = links.length;
        });
      }
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
    final firstName = userName?.split(' ').first ?? 'Psicólogo';
    final upcoming = _appointments.where((a) => a.isUpcoming).toList();
    final next = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        userName: userName ?? 'Psicólogo',
        userEmail: userEmail ?? '',
        roleLabel: 'Psicólogo(a)',
        accentColor: AppColors.psychologist,
        selectedIndex: 0,
        items: [
          DrawerMenuItem(
            label: 'Início',
            icon: Icons.home_rounded,
            onTap: () {},
          ),
          DrawerMenuItem(
            label: 'Minha Agenda',
            icon: Icons.calendar_today_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageAvailabilityPage())),
          ),
          DrawerMenuItem(
            label: 'Meus Pacientes',
            icon: Icons.people_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkPatientPage())),
          ),
          DrawerMenuItem(
            label: 'Tarefas',
            icon: Icons.task_alt_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PsychologistTasksPage())),
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
          color: AppColors.psychologist,
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.psychologist),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.psychologist, AppColors.gradientEnd]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
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
                    // ── Saudação + botão agenda ──────────────────
                    Text(
                      'Bem-vindo(a), Dr. $firstName',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.psychologist,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ManageAvailabilityPage()),
                        ).then((_) => _load()),
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: const Text('Gerenciar agenda', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Próxima sessão ───────────────────────────
                    PanelCard(
                      title: 'Próxima sessão',
                      footerLabel: 'Ver toda a agenda',
                      onFooterTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ManageAvailabilityPage()),
                      ).then((_) => _load()),
                      child: _loading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator(color: AppColors.psychologist, strokeWidth: 2)),
                            )
                          : next == null
                              ? const PanelEmptyState(
                                  icon: Icons.event_busy_rounded,
                                  title: 'Nenhuma sessão agendada',
                                  subtitle: 'Configure sua agenda para começar',
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
                                                  gradient: const LinearGradient(colors: [AppColors.patient, AppColors.accentLight]),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
                                              ),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text(
                                                  'Consulta com',
                                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            next.otherPartyName ?? 'Paciente',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                                          ),
                                          const Text(
                                            'Paciente',
                                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                    const SizedBox(height: 16),

                    // ── Grid de 2 cards: Pacientes / Tarefas ──────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: (constraints.maxWidth - 16) / 2,
                              child: PanelCard(
                                title: 'Meus Pacientes',
                                footerLabel: 'Vincular paciente',
                                onFooterTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LinkPatientPage()),
                                ).then((_) => _load()),
                                child: _loading
                                    ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.psychologist)))
                                    : Row(
                                        children: [
                                          Text(
                                            '$_activePatients',
                                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.psychologist),
                                          ),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text(
                                              'vínculo(s)\nativo(s)',
                                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.2),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(
                              width: (constraints.maxWidth - 16) / 2,
                              child: PanelCard(
                                title: 'Tarefas',
                                footerLabel: 'Atribuir atividade',
                                onFooterTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PsychologistTasksPage()),
                                ),
                                child: const PanelEmptyState(
                                  icon: Icons.task_alt_rounded,
                                  title: 'Acompanhe atividades',
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Próximas sessões da semana ────────────────
                    PanelCard(
                      title: 'Próximas sessões',
                      footerLabel: upcoming.length > 1 ? 'Ver todas (${upcoming.length})' : null,
                      onFooterTap: upcoming.length > 1
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ManageAvailabilityPage()),
                              ).then((_) => _load())
                          : null,
                      child: _loading
                          ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.psychologist)))
                          : upcoming.length <= 1
                              ? const PanelEmptyState(
                                  icon: Icons.calendar_month_outlined,
                                  title: 'Sem outras sessões na fila',
                                )
                              : Column(
                                  children: upcoming.skip(1).take(3).map((a) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.event_rounded, color: AppColors.psychologist, size: 18),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                '${a.otherPartyName ?? 'Paciente'} • ${_formatDate(a.startTime)} ${_formatTime(a.startTime)}',
                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )).toList(),
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
