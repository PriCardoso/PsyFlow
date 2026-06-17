import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/appointment_service.dart';
import '../../models/appointment_model.dart';

class ManageAvailabilityPage extends StatefulWidget {
  const ManageAvailabilityPage({super.key});

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
  final _service = AppointmentService();
  List<AvailabilitySlot> _slots = [];
  List<AppointmentItem> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final slots = await _service.getMySlots();
      final appts = await _service.getMyAppointmentsAsPsychologist();
      if (mounted) setState(() { _slots = slots; _appointments = appts; });
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

  Future<void> _addSlot() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;

    final start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final end = start.add(const Duration(minutes: 50));

    try {
      await _service.addAvailabilitySlot(startTime: start, endTime: end);
      _load();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _removeSlot(AvailabilitySlot slot) async {
    try {
      await _service.deleteSlot(slot.id);
      _load();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  String _formatDateTime(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _appointments.where((a) => a.isUpcoming).toList();

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
                        const Text('Minha Agenda', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('${upcoming.length} consulta(s) agendada(s)', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.psychologist)))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Próximas consultas ────────────────────────
                  if (upcoming.isNotEmpty) ...[
                    const _SectionLabel(text: 'Próximas consultas'),
                    const SizedBox(height: 10),
                    ...upcoming.map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: AppColors.success, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.otherPartyName ?? 'Paciente', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text(_formatDateTime(a.startTime), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ── Horários disponíveis ──────────────────────
                  const _SectionLabel(text: 'Horários disponíveis'),
                  const SizedBox(height: 10),

                  if (_slots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E7EF)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 36),
                          SizedBox(height: 10),
                          Text('Nenhum horário cadastrado', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  else
                    ..._slots.map((slot) => Container(
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
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: slot.isBooked
                                      ? AppColors.success.withValues(alpha: 0.12)
                                      : AppColors.psychologist.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  slot.isBooked ? Icons.event_busy_rounded : Icons.schedule_rounded,
                                  color: slot.isBooked ? AppColors.success : AppColors.psychologist,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_formatDateTime(slot.startTime), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text(slot.isBooked ? 'Reservado' : 'Disponível',
                                        style: TextStyle(fontSize: 12, color: slot.isBooked ? AppColors.success : AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              if (!slot.isBooked)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
                                  onPressed: () => _removeSlot(slot),
                                ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.psychologist,
        onPressed: _addSlot,
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
