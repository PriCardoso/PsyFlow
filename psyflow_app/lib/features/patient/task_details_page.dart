import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task_model.dart';

class TaskDetailsPage extends StatefulWidget {
  final TaskItem task;

  const TaskDetailsPage({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsPage> createState() =>
      _TaskDetailsPageState();
}

class _TaskDetailsPageState
    extends State<TaskDetailsPage> {

  final feedbackController =
      TextEditingController();

  final taskService = TaskService();

  double moodBefore = 5;
  double moodAfter = 5;

  bool saving = false;

  Future<void> _finishTask() async {
  try {
    await taskService.completeTask(
      taskId: widget.task.id,
      response: feedbackController.text.trim(),
      moodBefore: moodBefore.round(),
      moodAfter: moodAfter.round(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tarefa concluída com sucesso!',
        ),
      ),
    );

    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }
}

  Future<void> saveTaskResponse() async {
  try {
    setState(() {
      saving = true;
    });

    await Supabase.instance.client
        .from('tasks')
        .update({
      'patient_response':
          feedbackController.text.trim(),

      'mood_before':
          moodBefore.round(),

      'mood_after':
          moodAfter.round(),

      'status': 'completed',

      'completed_at':
          DateTime.now().toIso8601String(),
    })
        .eq('id', widget.task.id);

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Tarefa concluída com sucesso'),
        ),
      );

      Navigator.pop(context, true);
    }
  } catch (e) {
    debugPrint(e.toString());

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          e.toString(),
        ),
      ),
    );
  }

  setState(() {
    saving = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Responder tarefa',
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(
              widget.task.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (widget.task.description != null)
              Text(
                widget.task.description!,
              ),

            const SizedBox(height: 24),

            const Text(
              'Como você estava antes?',
            ),

            Slider(
              value: moodBefore,
              min: 1,
              max: 10,
              divisions: 9,
              label:
                  moodBefore.round().toString(),
              onChanged: (value) {
                setState(() {
                  moodBefore = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Como você está agora?',
            ),

            Slider(
              value: moodAfter,
              min: 1,
              max: 10,
              divisions: 9,
              label:
                  moodAfter.round().toString(),
              onChanged: (value) {
                setState(() {
                  moodAfter = value;
                });
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  feedbackController,
              maxLines: 5,
              decoration:
                  const InputDecoration(
                labelText:
                    'Como foi realizar esta atividade?',
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              ElevatedButton(
                onPressed: saving
                    ? null
                    : saveTaskResponse,
                child: saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Concluir tarefa',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}