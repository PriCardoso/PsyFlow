import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/task_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/task_item.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskItem task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final _feedbackController = TextEditingController();
  final _taskService = sl<TaskService>();

  double _moodBefore = 5;
  double _moodAfter = 5;
  bool _saving = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveTaskResponse() async {
    setState(() => _saving = true);
    try {
      await _taskService.completeTask(
        taskId: widget.task.id,
        response: _feedbackController.text.trim(),
        moodBefore: _moodBefore.round(),
        moodAfter: _moodAfter.round(),
      );
      if (mounted) {
        _showSnack('Tarefa concluída com sucesso!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnack(e.toString().replaceAll('Exception: ', ''), error: true);
    }
    if (mounted) setState(() => _saving = false);
  }

  Widget _moodSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    final emoji = value <= 2
        ? '😔'
        : value <= 4
            ? '😐'
            : value <= 6
                ? '🙂'
                : value <= 8
                    ? '😊'
                    : '😄';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '${value.round()}/10',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.patient,
            thumbColor: AppColors.patient,
            inactiveTrackColor: AppColors.background,
            overlayColor: AppColors.patient.withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Responder tarefa',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Cabeçalho da tarefa
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.patient, AppColors.accentLight],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.task_alt_rounded, color: Colors.white, size: 28),
                const SizedBox(height: 10),
                Text(
                  widget.task.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                if (widget.task.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.task.description!,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Humor antes/depois
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como você está se sentindo?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 18),
                _moodSlider(
                  label: 'Antes de começar',
                  value: _moodBefore,
                  onChanged: (v) => setState(() => _moodBefore = v),
                ),
                const SizedBox(height: 16),
                _moodSlider(
                  label: 'Após realizar',
                  value: _moodAfter,
                  onChanged: (v) => setState(() => _moodAfter = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Resposta livre
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como foi realizar esta atividade?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Compartilhe suas percepções com seu psicólogo.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Descreva sua experiência...',
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

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.patient,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _saving ? null : _saveTaskResponse,
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Concluir tarefa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
