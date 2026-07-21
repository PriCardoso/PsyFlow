import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../models/task_item.dart';

class TherapistFeedbackPage extends StatefulWidget {
  final TaskItem task;

  const TherapistFeedbackPage({super.key, required this.task});

  @override
  State<TherapistFeedbackPage> createState() => _TherapistFeedbackPageState();
}

class _TherapistFeedbackPageState extends State<TherapistFeedbackPage> {
  final _notesController = TextEditingController();
  final _taskService = TaskService();
  bool _saving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    if (_notesController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await _taskService.saveTherapistNotes(
        taskId: widget.task.id,
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Anotação salva com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context, true);
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
    if (mounted) setState(() => _saving = false);
  }

  Widget _moodBar(String label, int? value) {
    if (value == null) return const SizedBox.shrink();
    final pct = value / 10.0;
    final color = value >= 7
        ? AppColors.success
        : value >= 4
            ? AppColors.cardOrange
            : AppColors.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text('$value/10', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final hasResponse = task.patientResponse != null && task.patientResponse!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Resposta do paciente',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Cabeçalho da tarefa ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.cardOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.isCompleted ? 'Concluída' : 'Pendente',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: task.isCompleted ? AppColors.success : AppColors.cardOrange,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (task.patientName != null)
                      Text(
                        task.patientName!,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 6),
                  Text(task.description!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Humor antes/depois ──
          if (task.moodBefore != null || task.moodAfter != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7ECF1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Humor reportado',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),
                  _moodBar('Antes da tarefa', task.moodBefore),
                  _moodBar('Após a tarefa', task.moodAfter),
                  if (task.moodBefore != null && task.moodAfter != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            task.moodAfter! >= task.moodBefore!
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: task.moodAfter! >= task.moodBefore!
                                ? AppColors.success
                                : AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.moodAfter! >= task.moodBefore!
                                ? 'Humor melhorou ${task.moodAfter! - task.moodBefore!} ponto(s)'
                                : 'Humor reduziu ${task.moodBefore! - task.moodAfter!} ponto(s)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: task.moodAfter! >= task.moodBefore!
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Resposta do paciente ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resposta do paciente',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                if (hasResponse)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.patientResponse!,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.55),
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 16, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(width: 8),
                      const Text(
                        'Paciente ainda não respondeu.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Anotação do terapeuta ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sua anotação clínica',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Visível apenas para você',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (task.therapistNotes != null && task.therapistNotes!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.psychologist.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.psychologist.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      task.therapistNotes!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ),
                  const Text(
                    'Adicionar nova anotação:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Observações clínicas sobre a resposta...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
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
              onPressed: _saving ? null : _saveNotes,
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Salvar anotação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
