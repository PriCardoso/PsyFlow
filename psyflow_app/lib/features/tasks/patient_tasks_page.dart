import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/task_item.dart';
import 'task_execution_page.dart';

class PatientTasksPage extends StatefulWidget {
  const PatientTasksPage({super.key});

  @override
  State<PatientTasksPage> createState() => _PatientTasksPageState();
}

class _PatientTasksPageState extends State<PatientTasksPage> {
  final _taskService = sl<TaskService>();
  List<TaskItem> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await _taskService.getMyTasks();
      if (mounted) setState(() => _tasks = tasks);
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

  Future<void> _toggle(TaskItem task) async {
    try {
      await _taskService.toggleTaskStatus(task.id, !task.isCompleted);
      _load();
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
  }

  Future<void> _openTaskExecution(TaskItem task) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskExecutionPage(task: task)),
    );
    if (result == true) {
      _load();
    }
  }

  String _formatDate(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    final completed = _tasks.where((t) => t.isCompleted).toList();
    final firstPending = pending.isNotEmpty ? pending.first : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.patient,
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
                    colors: [AppColors.patient, AppColors.accentLight],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Minhas Atividades',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pending.isEmpty
                              ? 'Tudo em dia! 🎉'
                              : '${pending.length} atividade(s) pendente(s)',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.patient)),
            )
          else if (_tasks.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.task_alt_rounded, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhuma atividade por aqui ainda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'As tarefas e questionários enviados pelo seu psicólogo\naparecerão automaticamente nesta tela.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Card Sinalizador de Alta Visibilidade no Topo
                  if (firstPending != null) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  '✨ Atividade em Destaque',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const Spacer(),
                              if (firstPending.dueDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Até ${_formatDate(firstPending.dueDate!)}',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            firstPending.title,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          if (firstPending.description != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              firstPending.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.3),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () => _openTaskExecution(firstPending),
                              icon: const Icon(Icons.play_arrow_rounded, size: 20),
                              label: Text(
                                firstPending.isDraft ? 'Continuar Rascunho' : 'Iniciar Atividade',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (pending.isNotEmpty) ...[
                    _SectionLabel(text: 'Todas as Pendentes (${pending.length})'),
                    const SizedBox(height: 10),
                    ...pending.map((t) => _PatientTaskCard(
                          task: t,
                          formatDate: _formatDate,
                          onToggle: () => _toggle(t),
                          onTap: () => _openTaskExecution(t),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (completed.isNotEmpty) ...[
                    _SectionLabel(text: 'Concluídas (${completed.length})'),
                    const SizedBox(height: 10),
                    ...completed.map((t) => _PatientTaskCard(
                          task: t,
                          formatDate: _formatDate,
                          onToggle: () => _toggle(t),
                          onTap: () => _openTaskExecution(t),
                        )),
                  ],
                  const SizedBox(height: 24),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
      );
}

class _PatientTaskCard extends StatelessWidget {
  final TaskItem task;
  final String Function(DateTime) formatDate;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _PatientTaskCard({
    required this.task,
    required this.formatDate,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? AppColors.success : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: task.isCompleted ? AppColors.success : AppColors.textSecondary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (task.isDraft)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Rascunho', style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      if (task.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (task.dueDate != null) ...[
                            Icon(Icons.calendar_today_rounded, size: 12, color: task.isOverdue ? AppColors.error : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Até ${formatDate(task.dueDate!)}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                                fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (task.formFields.isNotEmpty)
                            Text(
                              '${task.formFields.length} item(ns)',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
