import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/therapist_patient_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../models/task_item.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/panel_card.dart';
import '../../auth/presentation/pages/edit_profile_page.dart';
import '../../patients/presentation/pages/link_patient_page.dart';
import '../../tasks/psychologist_tasks_page.dart';

class PsychologistDashboardPage extends StatefulWidget {
  final String? initialName;

  const PsychologistDashboardPage({super.key, this.initialName});

  @override
  State<PsychologistDashboardPage> createState() => _PsychologistDashboardPageState();
}

class _PsychologistDashboardPageState extends State<PsychologistDashboardPage> {
  final _therapistPatientService = sl<TherapistPatientService>();
  final _taskService = sl<TaskService>();

  String? userName;
  String? userEmail;
  int _activePatients = 0;
  List<TaskItem> _tasks = [];
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
      final userDoc = await sl<UserService>().getProfile();
      if (userDoc != null && mounted) {
        final profileName = userDoc['full_name'] as String? ??
            userDoc['fullName'] as String? ??
            userDoc['name'] as String?;
        if (profileName != null && profileName.trim().isNotEmpty) {
          setState(() => userName = profileName.trim());
        }
      }
      final patients = await _therapistPatientService.getMyPatients();
      List<TaskItem> tasks = [];
      try {
        tasks = await _taskService.getTasksCreatedByMe();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _activePatients = patients.length;
          _tasks = tasks;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${(d.year % 100).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final resolvedFullName = (userName?.trim().isNotEmpty == true)
        ? userName
        : (userProvider.fullName?.trim().isNotEmpty == true
            ? userProvider.fullName
            : (FirebaseAuth.instance.currentUser?.displayName?.trim().isNotEmpty == true
                ? FirebaseAuth.instance.currentUser!.displayName
                : null));

    final firstName = (resolvedFullName != null && resolvedFullName.trim().isNotEmpty)
        ? resolvedFullName.trim().split(' ').first
        : (userEmail != null && userEmail!.contains('@')
            ? userEmail!.split('@').first
            : 'Psicólogo');

    final pendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        userName: resolvedFullName ?? 'Psicólogo',
        userEmail: userEmail ?? userProvider.userEmail ?? '',
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
            label: 'Meus Pacientes',
            icon: Icons.people_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const LinkPatientPage())),
          ),
          DrawerMenuItem(
            label: 'Tarefas e Atividades',
            icon: Icons.task_alt_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const PsychologistTasksPage())),
          ),
          DrawerMenuItem(
            label: 'Configurações',
            icon: Icons.settings_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EditProfilePage())),
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
                        onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EditProfilePage())),
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
                    // ── Saudação + botão gerenciar atividades ───
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
                          MaterialPageRoute<void>(builder: (_) => const PsychologistTasksPage()),
                        ).then((_) => _load()),
                        icon: const Icon(Icons.add_task_rounded, size: 18),
                        label: const Text('Gerenciar Atividades dos Pacientes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Grid de 2 cards: Pacientes / Atividades ───
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
                                  MaterialPageRoute<void>(builder: (_) => const LinkPatientPage()),
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
                                title: 'Atividades',
                                footerLabel: 'Atribuir atividade',
                                onFooterTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(builder: (_) => const PsychologistTasksPage()),
                                ).then((_) => _load()),
                                child: _loading
                                    ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.psychologist)))
                                    : Row(
                                        children: [
                                          Text(
                                            '${_tasks.length}',
                                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.psychologist),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${pendingTasks.length} pendente(s)\n${completedTasks.length} concluída(s)',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.2),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Painel de Atividades Recentes dos Pacientes ───
                    PanelCard(
                      title: 'Atividades Recentes',
                      footerLabel: _tasks.isNotEmpty ? 'Ver todas (${_tasks.length})' : null,
                      onFooterTap: _tasks.isNotEmpty
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(builder: (_) => const PsychologistTasksPage()),
                              ).then((_) => _load())
                          : null,
                      child: _loading
                          ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.psychologist)))
                          : _tasks.isEmpty
                              ? const PanelEmptyState(
                                  icon: Icons.assignment_outlined,
                                  title: 'Nenhuma atividade atribuída',
                                  subtitle: 'Crie e envie tarefas terapêuticas para seus pacientes',
                                )
                              : Column(
                                  children: _tasks.take(4).map((task) {
                                    final isDone = task.isCompleted;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: (isDone ? AppColors.success : AppColors.psychologist).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              isDone ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                                              color: isDone ? AppColors.success : AppColors.psychologist,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.title,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  task.patientName != null && task.patientName!.isNotEmpty
                                                      ? 'Paciente: ${task.patientName}'
                                                      : (task.dueDate != null
                                                          ? 'Entrega: ${_formatDate(task.dueDate!)}'
                                                          : (isDone ? 'Concluída' : 'Pendente')),
                                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (isDone ? AppColors.success : Colors.orange).withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isDone ? 'Concluída' : 'Pendente',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: isDone ? AppColors.success : Colors.orange.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
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
