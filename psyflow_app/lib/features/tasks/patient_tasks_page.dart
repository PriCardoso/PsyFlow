import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../models/task_model.dart';

class PatientTasksPage extends StatefulWidget {
  const PatientTasksPage({super.key});

  @override
  State<PatientTasksPage> createState() => _PatientTasksPageState();
}

class _PatientTasksPageState extends State<PatientTasksPage> {
  final _taskService = TaskService();
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

  String _formatDate(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    final completed = _tasks.where((t) => t.isCompleted).toList();

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
                          'Minhas Tarefas',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pending.isEmpty
                              ? 'Tudo em dia! 🎉'
                              : '${pending.length} pendente(s)',
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
                    Icon(Icons.task_alt_rounded, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const Text('Nenhuma tarefa por aqui ainda', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (pending.isNotEmpty) ...[
                    const _SectionLabel(text: 'Pendentes'),
                    const SizedBox(height: 10),
                    ...pending.map((t) => _PatientTaskCard(
                          task: t,
                          formatDate: _formatDate,
                          onToggle: () => _toggle(t),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (completed.isNotEmpty) ...[
                    const _SectionLabel(text: 'Concluídas'),
                    const SizedBox(height: 10),
                    ...completed.map((t) => _PatientTaskCard(
                          task: t,
                          formatDate: _formatDate,
                          onToggle: () => _toggle(t),
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

  const _PatientTaskCard({required this.task, required this.formatDate, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: task.isCompleted ? AppColors.success : AppColors.textSecondary.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 4),
                  Text(task.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
                if (task.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Até ${formatDate(task.dueDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                      fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
