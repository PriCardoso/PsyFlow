import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../services/appointment_service.dart';

class PsychologistScheduleScreen extends StatefulWidget {
  const PsychologistScheduleScreen({super.key});

  @override
  State<PsychologistScheduleScreen> createState() =>
      _PsychologistScheduleScreenState();
}

class _PsychologistScheduleScreenState
    extends State<PsychologistScheduleScreen> {
  final _service = AppointmentService();

  List<AvailabilitySlot> _slots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _loading = true);
    try {
      final slots = await _service.getMySlots();
      setState(() => _slots = slots);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _removeSlot(String slotId) async {
    try {
      await _service.deactivateSlot(slotId);
      _loadSlots();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _openAddSlotSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddSlotSheet(
        onSaved: _loadSlots,
        service: _service,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Agenda'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddSlotSheet,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _slots.isEmpty
              ? const Center(
                  child: Text('Nenhum horário disponível criado ainda.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _slots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final slot = _slots[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(
                          slot.isRecurring
                              ? slot.weekdayLabel
                              : _formatDate(slot.date!),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${slot.startTime} — ${slot.endTime}'),
                            Text(
                              _modalityLabel(slot.modality),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => _confirmDelete(slot.id),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }

  void _confirmDelete(String slotId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover horário'),
        content: const Text('Deseja remover este horário disponível?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeSlot(slotId);
            },
            child: const Text('Remover',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _modalityLabel(String modality) {
    switch (modality) {
      case 'presencial':
        return 'Presencial';
      case 'online':
        return 'Online';
      default:
        return 'Presencial e Online';
    }
  }
}

// ─────────────────────────────────────────────
// Bottom sheet para adicionar slot
// ─────────────────────────────────────────────

class _AddSlotSheet extends StatefulWidget {
  final VoidCallback onSaved;
  final AppointmentService service;

  const _AddSlotSheet({required this.onSaved, required this.service});

  @override
  State<_AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<_AddSlotSheet> {
  bool _isRecurring = false;
  int _selectedWeekday = 1;
  DateTime? _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String _modality = 'both';
  bool _saving = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_isRecurring && _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      if (_isRecurring) {
        await widget.service.createRecurringSlot(
          weekday: _selectedWeekday,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          modality: _modality,
        );
      } else {
        await widget.service.createSingleSlot(
          date: _selectedDate!,
          startTime: _formatTime(_startTime),
          endTime: _formatTime(_endTime),
          modality: _modality,
        );
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adicionar Horário',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Tipo: avulso ou recorrente
          Row(
            children: [
              const Text('Tipo: '),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Avulso'),
                selected: !_isRecurring,
                onSelected: (_) => setState(() => _isRecurring = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Recorrente'),
                selected: _isRecurring,
                onSelected: (_) => setState(() => _isRecurring = true),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Data ou dia da semana
          if (!_isRecurring)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _selectedDate == null
                    ? 'Selecionar data'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
              onTap: _pickDate,
            )
          else
            DropdownButtonFormField<int>(
              value: _selectedWeekday,
              decoration: const InputDecoration(labelText: 'Dia da semana'),
              items: List.generate(7, (i) {
                return DropdownMenuItem(
                  value: i,
                  child: Text(AvailabilitySlot.weekdayLabels[i]),
                );
              }),
              onChanged: (v) => setState(() => _selectedWeekday = v!),
            ),

          const SizedBox(height: 12),

          // Horários
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text('Início: ${_formatTime(_startTime)}'),
                  onTap: () => _pickTime(true),
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_filled),
                  title: Text('Fim: ${_formatTime(_endTime)}'),
                  onTap: () => _pickTime(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Modalidade
          DropdownButtonFormField<String>(
            value: _modality,
            decoration: const InputDecoration(labelText: 'Modalidade'),
            items: const [
              DropdownMenuItem(value: 'both', child: Text('Presencial e Online')),
              DropdownMenuItem(value: 'presencial', child: Text('Presencial')),
              DropdownMenuItem(value: 'online', child: Text('Online')),
            ],
            onChanged: (v) => setState(() => _modality = v!),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar horário'),
            ),
          ),
        ],
      ),
    );
  }
}