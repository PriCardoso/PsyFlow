import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../core/services/therapist_patient_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/task_item.dart';
import '../../models/patient_link_model.dart';
import '../../data/task_catalog.dart';

class PsychologistTasksPage extends StatefulWidget {
  const PsychologistTasksPage({super.key});

  @override
  State<PsychologistTasksPage> createState() => _PsychologistTasksPageState();
}

class _PsychologistTasksPageState extends State<PsychologistTasksPage> {
  final _taskService = sl<TaskService>();
  final _therapistService = sl<TherapistPatientService>();

  List<TaskItem> _tasks = [];
  List<PatientLink> _patients = [];
  bool _loading = true;
  String? _filterPatientId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await _taskService.getTasksCreatedByMe();

      final List<PatientLink> allPatients = [];

      try {
        final newLinks = await _therapistService.getMyPatients();
        for (final link in newLinks) {
          if (link.isActive && link.patientId != null) {
            final alreadyAdded = allPatients.any((p) => p.patient.id == link.patientId);
            if (!alreadyAdded) {
              allPatients.add(PatientLink(
                linkId: link.id,
                active: true,
                createdAt: link.createdAt,
                patient: link.patientProfile ??
                    PatientProfile(
                      id: link.patientId!,
                      fullName: 'Paciente',
                      email: '',
                    ),
              ));
            }
          }
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _patients = allPatients.where((l) => l.active).toList();
        });
      }
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openCreateTaskSheet() async {
    if (_patients.isEmpty) {
      _showError('Você precisa ter ao menos um paciente vinculado.');
      return;
    }

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateTaskSheet(patients: _patients, taskService: _taskService),
    );

    if (created == true) _load();
  }

  Future<void> _deleteTask(TaskItem task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Excluir tarefa', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Deseja excluir "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _taskService.deleteTask(task.id);
        _load();
      } catch (e) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _viewTaskDetails(TaskItem task) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskDetailsViewSheet(task: task, taskService: _taskService, onUpdate: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filterPatientId == null
        ? _tasks
        : _tasks.where((t) => t.patientId == _filterPatientId).toList();

    final pending = filteredTasks.where((t) => !t.isCompleted).toList();
    final completed = filteredTasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Módulo de Tarefas',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pending.length} pendente(s) • ${completed.length} concluída(s)',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        // Filtro de Paciente rápido
                        if (_patients.isNotEmpty)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _PatientFilterChip(
                                  label: 'Todos',
                                  selected: _filterPatientId == null,
                                  onSelected: () => setState(() => _filterPatientId = null),
                                ),
                                ..._patients.map((p) => _PatientFilterChip(
                                      label: p.patient.fullName,
                                      selected: _filterPatientId == p.patient.id,
                                      onSelected: () => setState(() => _filterPatientId = p.patient.id),
                                    )),
                              ],
                            ),
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
              child: Center(child: CircularProgressIndicator(color: AppColors.psychologist)),
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
                      'Nenhuma tarefa criada ainda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Utilize o botão abaixo para atribuir questionários\nou tarefas personalizadas aos seus pacientes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.psychologist,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _openCreateTaskSheet,
                      icon: const Icon(Icons.add_task_rounded, size: 20),
                      label: const Text('Atribuir Nova Tarefa', style: TextStyle(fontWeight: FontWeight.w700)),
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
                  if (pending.isNotEmpty) ...[
                    _SectionLabel(text: 'Pendentes (${pending.length})'),
                    const SizedBox(height: 10),
                    ...pending.map((t) => _TaskCard(
                          task: t,
                          onDelete: () => _deleteTask(t),
                          onTap: () => _viewTaskDetails(t),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (completed.isNotEmpty) ...[
                    _SectionLabel(text: 'Concluídas (${completed.length})'),
                    const SizedBox(height: 10),
                    ...completed.map((t) => _TaskCard(
                          task: t,
                          onDelete: () => _deleteTask(t),
                          onTap: () => _viewTaskDetails(t),
                        )),
                  ],
                  const SizedBox(height: 80),
                ]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.psychologist,
        onPressed: _openCreateTaskSheet,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Atribuir Tarefa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _PatientFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PatientFilterChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? AppColors.psychologist : Colors.white,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 12,
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.18),
        selectedColor: Colors.white,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
        onSelected: (_) => onSelected(),
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

class _TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onDelete, required this.onTap});

  String _formatDate(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDraft = task.isDraft;

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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.success.withValues(alpha: 0.12)
                        : hasDraft
                            ? Colors.amber.withValues(alpha: 0.15)
                            : task.isOverdue
                                ? AppColors.error.withValues(alpha: 0.12)
                                : AppColors.psychologist.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : hasDraft
                            ? Icons.edit_note_rounded
                            : task.isOverdue
                                ? Icons.warning_rounded
                                : Icons.assignment_rounded,
                    color: task.isCompleted
                        ? AppColors.success
                        : hasDraft
                            ? Colors.amber.shade800
                            : task.isOverdue
                                ? AppColors.error
                                : AppColors.psychologist,
                    size: 22,
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
                          if (task.isSessionRestricted)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_rounded, size: 10, color: Colors.purple),
                                  SizedBox(width: 3),
                                  Text('Sessão', style: TextStyle(fontSize: 10, color: Colors.purple, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (task.patientName != null)
                            Text(
                              '👤 ${task.patientName}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.faixaEtaria,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (task.category.isNotEmpty && task.category != 'geral')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.psychologist.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                task.category.toUpperCase(),
                                style: const TextStyle(fontSize: 10, color: AppColors.psychologist, fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 10,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (task.dueDate != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded, size: 13, color: task.isOverdue ? AppColors.error : AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'Prazo: ${_formatDate(task.dueDate!)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                                    fontWeight: task.isOverdue ? FontWeight.w700 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          if (task.formFields.isNotEmpty)
                            Text(
                              '${task.formFields.length} item(ns)',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          if (hasDraft)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Rascunho salvo', style: TextStyle(fontSize: 10, color: Colors.amber, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// MODAL DE DETALHES E RESPOSTAS DA TAREFA (VISÃO DO PSICÓLOGO)
// =========================================================================
class _TaskDetailsViewSheet extends StatefulWidget {
  final TaskItem task;
  final TaskService taskService;
  final VoidCallback onUpdate;

  const _TaskDetailsViewSheet({required this.task, required this.taskService, required this.onUpdate});

  @override
  State<_TaskDetailsViewSheet> createState() => _TaskDetailsViewSheetState();
}

class _TaskDetailsViewSheetState extends State<_TaskDetailsViewSheet> {
  final _notesController = TextEditingController();
  bool _savingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.task.therapistNotes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    setState(() => _savingNotes = true);
    try {
      await widget.taskService.saveTherapistNotes(
        taskId: widget.task.id,
        notes: _notesController.text.trim(),
      );
      widget.onUpdate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anotações clínicas salvas com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar anotação: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    if (mounted) setState(() => _savingNotes = false);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final patientValues = task.patientValues;
    final formFields = task.formFields;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Paciente: ${task.patientName ?? "Paciente"} • ${task.faixaEtaria}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.psychologist.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.isCompleted ? 'Concluída' : 'Pendente',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: task.isCompleted ? AppColors.success : AppColors.psychologist,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const Text('Instruções da Tarefa:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(task.description!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                      const SizedBox(height: 16),
                    ],

                    // Humor antes e depois
                    if (task.moodBefore != null || task.moodAfter != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if (task.moodBefore != null)
                              Column(
                                children: [
                                  const Text('Humor Antes', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('${task.moodBefore}/10', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.psychologist)),
                                ],
                              ),
                            if (task.moodAfter != null)
                              Column(
                                children: [
                                  const Text('Humor Depois', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('${task.moodAfter}/10', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Respostas aos Campos do Formulário Dinâmico
                    const Text('Respostas do Paciente:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),

                    if (patientValues.isEmpty && (task.patientResponse == null || task.patientResponse!.isEmpty))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'O paciente ainda não enviou respostas para esta atividade.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      )
                    else if (formFields.isNotEmpty) ...[
                      ...formFields.map((field) {
                        final val = patientValues['campo_${field.ordem}'] ?? patientValues[field.label];
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(field.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              Text(
                                val != null ? val.toString() : '(Sem resposta)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: val != null ? AppColors.textPrimary : AppColors.textSecondary,
                                  fontWeight: val != null ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else if (task.patientResponse != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(task.patientResponse!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Anotações Clínicas do Psicólogo
                    const Text('Anotações do Psicólogo:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Adicione suas notas clínicas sobre a evolução nesta tarefa...',
                        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.psychologist,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _savingNotes ? null : _saveNotes,
                        icon: _savingNotes
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save_rounded, size: 18),
                        label: const Text('Salvar Anotações', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// SHEET DE CRIAÇÃO E ATRIBUIÇÃO DE TAREFAS / QUESTIONÁRIOS
// =========================================================================
class _CreateTaskSheet extends StatefulWidget {
  final List<PatientLink> patients;
  final TaskService taskService;

  const _CreateTaskSheet({required this.patients, required this.taskService});

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form State
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String? selectedPatientId;
  String selectedAgeGroup = 'adulto';
  String selectedCategory = 'ansiedade';
  String protocol = '';
  DateTime? selectedDate;
  int difficultyLevel = 1;

  // Form Fields Customizados
  List<TaskFormFieldConfig> dynamicFields = [];

  // Configurações de Envio e Privacidade
  bool permiteNotificacao = true;
  String frequenciaLembrete = 'diario';
  String horarioLembrete = '20:00';
  String compartilhamento = 'automatico'; // 'automatico' ou 'sessao_presencial'

  // Filtros da Biblioteca
  String libAgeFilter = 'todas';
  String libCategoryFilter = 'todas';

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.patients.isNotEmpty) {
      selectedPatientId = widget.patients.first.patient.id;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _applyTemplate(CatalogTaskTemplate template) {
    setState(() {
      titleController.text = template.title;
      descController.text = template.description;
      selectedAgeGroup = template.ageGroup == 'todas' ? 'adulto' : template.ageGroup;
      selectedCategory = template.category;
      protocol = template.protocol;
      difficultyLevel = template.difficultyLevel;
      dynamicFields = List.from(template.campos);
    });

    _tabController.animateTo(1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modelo "${template.title}" carregado! Ajuste os detalhes e clique em Criar Tarefa.'),
        backgroundColor: AppColors.psychologist,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _addNewField() {
    setState(() {
      final newIndex = dynamicFields.length + 1;
      dynamicFields.add(
        TaskFormFieldConfig(
          ordem: newIndex,
          label: 'Nova Pergunta $newIndex',
          tipo: 'texto_longo',
          placeholder: 'Instruções para o paciente...',
        ),
      );
    });
  }

  void _removeField(int index) {
    setState(() {
      dynamicFields.removeAt(index);
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty || selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha o título da tarefa e selecione um paciente.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => saving = true);
    try {
      final formMap = dynamicFields.isNotEmpty
          ? {
              'tipo_input': 'formulario_multiplo',
              'campos': dynamicFields.map((f) => f.toMap()).toList(),
            }
          : null;

      final configMap = {
        'permite_notificacao': permiteNotificacao,
        'frequencia_lembrete': frequenciaLembrete,
        'horario_lembrete': horarioLembrete,
        'compartilhamento': compartilhamento,
      };

      await widget.taskService.createTask(
        patientId: selectedPatientId!,
        title: titleController.text.trim(),
        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
        category: selectedCategory,
        protocol: protocol,
        difficultyLevel: difficultyLevel,
        dueDate: selectedDate,
        faixaEtaria: TaskCatalog.ageGroups[selectedAgeGroup] ?? 'Adultos',
        configuracoes: configMap,
        estruturaResposta: formMap,
      );

      if (mounted) Navigator.pop(context, true);
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
    if (mounted) setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Tab Bar Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.psychologist,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(icon: Icon(Icons.library_books_rounded, size: 18), text: 'Biblioteca de Modelos'),
                    Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Configurar e Enviar'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLibraryTab(),
                  _buildEditorTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ABA 1: BIBLIOTECA DE MODELOS & QUESTIONÁRIOS
  // =========================================================================
  Widget _buildLibraryTab() {
    final templates = TaskCatalog.filter(
      ageGroup: libAgeFilter,
      category: libCategoryFilter,
    );

    return Column(
      children: [
        // Filtro de Faixa Etária
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: TaskCatalog.ageGroups.entries.map((e) {
              final selected = libAgeFilter == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.psychologist,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (val) => setState(() => libAgeFilter = e.key),
                ),
              );
            }).toList(),
          ),
        ),

        // Filtro de Categoria
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          child: Row(
            children: TaskCatalog.categories.entries.map((e) {
              final selected = libCategoryFilter == e.key;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: selected,
                  selectedColor: AppColors.psychologist.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.psychologist : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (val) => setState(() => libCategoryFilter = e.key),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 12),

        // Lista de Templates
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final item = templates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.psychologist.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.protocol,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.psychologist),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                item.ageGroupLabel,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.format_list_numbered_rounded, size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${item.campos.length} item(ns)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.psychologist,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        onPressed: () => _applyTemplate(item),
                        icon: const Icon(Icons.add_task_rounded, size: 16),
                        label: const Text('Usar Este Modelo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // ABA 2: EDITOR E CONFIGURAÇÕES DE ENVIO
  // =========================================================================
  Widget _buildEditorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paciente Destinatário
          const Text('1. Paciente Destinatário', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.patients.map((link) {
              final selected = selectedPatientId == link.patient.id;
              return GestureDetector(
                onTap: () => setState(() => selectedPatientId = link.patient.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.psychologist : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: selected ? AppColors.psychologist : const Color(0xFFE0E7EF)),
                  ),
                  child: Text(
                    link.patient.fullName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Título e Descrição
          const Text('2. Informações da Tarefa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Título da tarefa / questionário',
              hintText: 'Ex: Registro de Pensamentos (RPD)',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: descController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Descrição e instruções para o paciente',
              hintText: 'Explique o objetivo e quando realizar...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),

          // Construtor Dinâmico de Formulário
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('3. Perguntas / Campos do Formulário', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              TextButton.icon(
                onPressed: _addNewField,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.psychologist),
                label: const Text('Adicionar Campo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.psychologist)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (dynamicFields.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Sem campos específicos. O paciente responderá em formato livre de texto.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            )
          else
            ...dynamicFields.asMap().entries.map((entry) {
              final idx = entry.key;
              final field = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.psychologist.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${idx + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.psychologist)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(field.label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(
                            'Tipo: ${field.tipo == "escala_linear" ? "Escala Linear (${field.min}-${field.max})" : field.tipo == "emoji_picker" ? "Seleção de Emojis" : field.tipo == "selecao_unica" ? "Múltipla Escolha" : "Texto"}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 18),
                      onPressed: () => _removeField(idx),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 18),

          // 4. Parâmetros de Envio e Trava de Privacidade
          const Text('4. Parâmetros de Envio e Privacidade', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 8),

          // Data Limite
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.psychologist),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate == null
                        ? 'Definir Data Limite de Entrega'
                        : 'Prazo: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selectedDate != null ? FontWeight.w700 : FontWeight.normal,
                      color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Trava de Privacidade
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 18, color: AppColors.psychologist),
                    const SizedBox(width: 8),
                    const Text('Modo de Compartilhamento:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                RadioListTile<String>(
                  value: 'automatico',
                  groupValue: compartilhamento,
                  title: const Text('Envio Automático', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: const Text('O psicólogo recebe os resultados assim que o paciente conclui.', style: TextStyle(fontSize: 11)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: AppColors.psychologist,
                  onChanged: (v) => setState(() => compartilhamento = v!),
                ),
                RadioListTile<String>(
                  value: 'sessao_presencial',
                  groupValue: compartilhamento,
                  title: const Text('🔒 Trava de Privacidade (Em Sessão)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: const Text('A resposta é guardada de forma restrita para ser aberta apenas durante a consulta.', style: TextStyle(fontSize: 11)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  activeColor: AppColors.psychologist,
                  onChanged: (v) => setState(() => compartilhamento = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botão Criar / Atribuir
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.psychologist,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: saving ? null : _save,
              child: saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Atribuir Tarefa ao Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
