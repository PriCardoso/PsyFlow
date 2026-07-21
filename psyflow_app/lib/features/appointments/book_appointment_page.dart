import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/appointment_service.dart';
import '../../models/appointment_item.dart';
import '../../models/psychologist_summary.dart';
import '../../models/availability_slot.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _appointmentService = AppointmentService(FirebaseFirestore.instance);
  List<PsychologistSummary> _psychologists = [];
  List<AppointmentItem> _myAppointments = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _appointmentService.listAvailablePsychologists();
      final appts = await _appointmentService.getMyAppointmentsAsPatient();
      if (mounted) {
        setState(() {
          _psychologists = data.map((m) => PsychologistSummary.fromMap(m)).toList();
          _myAppointments = appts;
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

  List<PsychologistSummary> get _filtered {
    if (_search.isEmpty) return _psychologists;
    final q = _search.toLowerCase();
    return _psychologists.where((p) => p.fullName.toLowerCase().contains(q)).toList();
  }

  Future<void> _openSlotPicker(PsychologistSummary psychologist) async {
    final booked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SlotPickerSheet(psychologist: psychologist, service: _appointmentService),
    );
    if (booked == true) _load();
  }

  String _formatDateTime(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} • $hour:$minute';
  }

  Future<void> _cancelAppointment(AppointmentItem appt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancelar consulta', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Tem certeza que deseja cancelar esta consulta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancelar consulta', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _appointmentService.cancelAppointment(appt.id);
        _load();
      } catch (e) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _myAppointments.where((a) => a.isUpcoming).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
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
                        const Text('Agendar Consulta', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Escolha um psicólogo disponível', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.patient)))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Minhas consultas agendadas ────────────────
                  if (upcoming.isNotEmpty) ...[
                    const _SectionLabel(text: 'Minhas consultas'),
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
                                    Text(a.otherPartyName ?? 'Psicólogo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text(_formatDateTime(a.startTime), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () => _cancelAppointment(a),
                                child: const Text('Cancelar', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // ── Busca ──────────────────────────────────────
                  const _SectionLabel(text: 'Psicólogos disponíveis'),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_filtered.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E7EF)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.search_off_rounded, color: AppColors.textSecondary, size: 36),
                          SizedBox(height: 10),
                          Text('Nenhum psicólogo encontrado', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  else
                    ..._filtered.map((p) => _PsychologistCard(
                          psychologist: p,
                          onTap: () => _openSlotPicker(p),
                        )),

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

class _PsychologistCard extends StatelessWidget {
  final PsychologistSummary psychologist;
  final VoidCallback onTap;

  const _PsychologistCard({required this.psychologist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.psychologist, AppColors.gradientEnd]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(psychologist.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(psychologist.fullName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                  if (psychologist.crp != null) ...[
                    const SizedBox(height: 2),
                    Text('CRP: ${psychologist.crp}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                  if (psychologist.bio != null && psychologist.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(psychologist.bio!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet com horários disponíveis ───────────────────────

class _SlotPickerSheet extends StatefulWidget {
  final PsychologistSummary psychologist;
  final AppointmentService service;

  const _SlotPickerSheet({required this.psychologist, required this.service});

  @override
  State<_SlotPickerSheet> createState() => _SlotPickerSheetState();
}

class _SlotPickerSheetState extends State<_SlotPickerSheet> {
  List<AvailabilitySlot> _slots = [];
  bool _loading = true;
  bool _booking = false;
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final slots = await widget.service.getAvailableSlotsForPsychologist(widget.psychologist.id);
      if (mounted) setState(() => _slots = slots);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlotId == null) return;
    final slot = _slots.firstWhere((s) => s.id == _selectedSlotId);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _booking = true);
    try {
      await widget.service.bookAppointment(
        psychologistId: widget.psychologist.id,
        patientId: user.uid,
        slot: slot,
        modality: slot.modality,
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
    if (mounted) setState(() => _booking = false);
  }

  String _formatDateTime(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text(widget.psychologist.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Escolha um horário disponível', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.patient)))
              else if (_slots.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 40, color: AppColors.textSecondary),
                        SizedBox(height: 10),
                        Text('Nenhum horário disponível agora', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: _slots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final slot = _slots[i];
                      final selected = _selectedSlotId == slot.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSlotId = slot.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.patient.withValues(alpha: 0.1) : AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? AppColors.patient : const Color(0xFFE0E7EF), width: selected ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule_rounded, color: selected ? AppColors.patient : AppColors.textSecondary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                _formatDateTime(slot.startTime),
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: selected ? AppColors.patient : AppColors.textPrimary),
                              ),
                              const Spacer(),
                              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.patient, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              if (_slots.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.patient,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: (_selectedSlotId == null || _booking) ? null : _confirmBooking,
                    child: _booking
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Confirmar agendamento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
