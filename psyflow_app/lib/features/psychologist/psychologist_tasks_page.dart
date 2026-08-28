import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../core/services/invite_service.dart';
import '../../core/services/therapist_patient_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/task_item.dart';
import '../../models/patient_link_model.dart';
import '../../models/task_template_model.dart';
import '../../data/task_templates.dart';

class PsychologistTasksPage extends StatefulWidget {
  const PsychologistTasksPage({super.key});

  @override
  State<PsychologistTasksPage> createState() => _PsychologistTasksPageState();
}

class _PsychologistTasksPageState extends State<PsychologistTasksPage> {
  final _taskService = sl<TaskService>();
  final _inviteService = sl<InviteService>();
  final _therapistService = sl<TherapistPatientService>();

  List<TaskItem> _tasks = [];
  List<PatientLink> _patients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await _taskService.getTasksCreatedByMe();

      // Busca pacientes dos dois sistemas de vínculo
      List<PatientLink> allPatients = [];

      // Sistema legado (InviteService → coleção 'links')
      try {
        final legacyLinks = await _inviteService.getMyPatients();
        allPatients.addAll(legacyLinks);
      } catch (_) {}

      // Sistema novo (TherapistPatientService → coleção 'therapist_patient_links')
      try {
        final newLinks = await _therapistService.getMyPatientsLinks();
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

  @override
  Widget build(BuildContext context) {
    final pending = _tasks.where((t) => !t.isCompleted).toList();
    final completed = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
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
                          'Tarefas',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pending.length} pendente(s) • ${completed.length} concluída(s)',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
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
                    Icon(Icons.task_alt_rounded, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    const Text('Nenhuma tarefa criada ainda', style: TextStyle(color: AppColors.textSecondary)),
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
                    ...pending.map((t) => _TaskCard(
                          task: t,
                          onDelete: () => _deleteTask(t),
                        )),
                    const SizedBox(height: 20),
                  ],
                  if (completed.isNotEmpty) ...[
                    const _SectionLabel(text: 'Concluídas'),
                    const SizedBox(height: 10),
                    ...completed.map((t) => _TaskCard(
                          task: t,
                          onDelete: () => _deleteTask(t),
                        )),
                  ],
                  const SizedBox(height: 80),
                ]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.psychologist,
        onPressed: _openCreateTaskSheet,
        child: const Icon(Icons.add_rounded, color: Colors.white),
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

  const _TaskCard({required this.task, required this.onDelete});

  String _formatDate(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${d.day} ${months[d.month - 1]}';
  }

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: task.isCompleted
                  ? AppColors.success.withValues(alpha: 0.12)
                  : task.isOverdue
                      ? AppColors.error.withValues(alpha: 0.12)
                      : AppColors.psychologist.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              task.isCompleted
                  ? Icons.check_circle_rounded
                  : task.isOverdue
                      ? Icons.warning_rounded
                      : Icons.task_alt_rounded,
              color: task.isCompleted
                  ? AppColors.success
                  : task.isOverdue
                      ? AppColors.error
                      : AppColors.psychologist,
              size: 20,
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
                if (task.patientName != null) ...[
                  const SizedBox(height: 2),
                  Text('Para: ${task.patientName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
                if (task.dueDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Até ${_formatDate(task.dueDate!)}',
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
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _CreateTaskSheet extends StatefulWidget {
  final List<PatientLink> patients;
  final TaskService taskService;

  const _CreateTaskSheet({required this.patients, required this.taskService});

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String? selectedPatientId;
  DateTime? selectedDate;
  bool saving = false;

  // Modelo pronto selecionado (se houver) e os campos que ele preenche.
  TaskTemplate? selectedTemplate;
  String? selectedTemplateCategory;
  String? category;
  String? protocol;
  int difficultyLevel = 1;

  void _applyTemplate(TaskTemplate template) {
    setState(() {
      selectedTemplate = template;
      titleController.text = template.title;
      descController.text = template.fullDescription;
      category = template.category;
      protocol = template.protocol;
      difficultyLevel = template.difficultyLevel;
    });
  }

  void _clearTemplate() {
    setState(() {
      selectedTemplate = null;
      category = null;
      protocol = null;
      difficultyLevel = 1;
    });
  }

  Future<void> _openTemplatePicker() async {
    final picked = await showModalBottomSheet<TaskTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TemplatePickerSheet(initialCategory: selectedTemplateCategory),
    );
    if (picked != null) {
      selectedTemplateCategory = picked.category;
      _applyTemplate(picked);
    }
  }


  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _save() async {
    if (titleController.text.trim().isEmpty || selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha o título e selecione um paciente'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => saving = true);
    try {
      await widget.taskService.createTask(
        patientId: selectedPatientId!,
        title: titleController.text.trim(),
        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
        category: category,
        protocol: protocol,
        difficultyLevel: difficultyLevel,
        dueDate: selectedDate,
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
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Nova tarefa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),

              // Atalho para escolher um modelo pronto
              GestureDetector(
                onTap: _openTemplatePicker,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.psychologist.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.psychologist.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.psychologist),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedTemplate == null
                              ? 'Usar um modelo pronto de tarefa'
                              : 'Modelo: ${selectedTemplate!.title}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.psychologist,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedTemplate != null)
                        GestureDetector(
                          onTap: _clearTemplate,
                          child: Icon(Icons.close_rounded, size: 18, color: AppColors.psychologist),
                        )
                      else
                        Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.psychologist),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),


              // Paciente
              const Text('Paciente', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
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
                        borderRadius: BorderRadius.circular(20),
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

              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título da tarefa'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descrição (opcional)'),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        selectedDate == null
                            ? 'Data limite (opcional)'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.psychologist,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Criar tarefa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet com a lista de modelos de tarefa prontos (TaskTemplates),
/// com busca por texto e filtro por categoria. Ao tocar em um modelo, ele é
/// devolvido para o _CreateTaskSheet via Navigator.pop.
class _TemplatePickerSheet extends StatefulWidget {
  final String? initialCategory;

  const _TemplatePickerSheet({this.initialCategory});

  @override
  State<_TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<_TemplatePickerSheet> {
  late List<TaskTemplate> _all;
  late List<TaskTemplate> _filtered;
  String? _selectedCategory;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _all = TaskTemplates.all;
    _selectedCategory = widget.initialCategory;
    _filtered = _all;
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      _filtered = _all.where((t) {
        final matchCat = _selectedCategory == null || t.category == _selectedCategory;
        final matchSearch = _search.isEmpty ||
            t.title.toLowerCase().contains(_search.toLowerCase()) ||
            t.description.toLowerCase().contains(_search.toLowerCase());
        return matchCat && matchSearch;
      }).toList();
    });
  }

  List<String> get _categories {
    final cats = _all.map((t) => t.category).toSet().toList();
    cats.sort();
    return cats;
  }

  Color _difficultyColor(int level) {
    return switch (level) {
      1 => AppColors.cardGreen,
      2 => AppColors.cardOrange,
      _ => AppColors.error,
    };
  }

  String _difficultyLabel(int level) {
    return switch (level) {
      1 => 'Fácil',
      2 => 'Médio',
      _ => 'Avançado',
    };
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Modelos de tarefa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (v) {
                        _search = v;
                        _applyFilter();
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar modelo...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _CategoryChip(
                            label: 'Todas',
                            selected: _selectedCategory == null,
                            onTap: () {
                              _selectedCategory = null;
                              _applyFilter();
                            },
                          ),
                          ..._categories.map((cat) => _CategoryChip(
                                label: TaskTemplates.categoryToLabel[cat] ?? cat,
                                selected: _selectedCategory == cat,
                                onTap: () {
                                  _selectedCategory = cat == _selectedCategory ? null : cat;
                                  _applyFilter();
                                },
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            const Text('Nenhum modelo encontrado', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final t = _filtered[i];
                          return GestureDetector(
                            onTap: () => Navigator.pop(context, t),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE7ECF1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _difficultyColor(t.difficultyLevel).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _difficultyLabel(t.difficultyLevel),
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _difficultyColor(t.difficultyLevel)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        t.categoryLabel,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Chip de filtro de categoria reutilizado dentro do seletor de modelos.
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.psychologist : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.psychologist : const Color(0xFFE0E7EF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}