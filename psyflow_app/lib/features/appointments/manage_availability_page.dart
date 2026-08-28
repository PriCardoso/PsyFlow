import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/appointment_service.dart';
import '../../models/appointment_item.dart';
import '../../models/availability_slot.dart';

class ManageAvailabilityPage extends StatefulWidget {
  const ManageAvailabilityPage({super.key});

  @override
  State<ManageAvailabilityPage> createState() => _ManageAvailabilityPageState();
}

class _ManageAvailabilityPageState extends State<ManageAvailabilityPage> {
  final _appointmentService = AppointmentService(FirebaseFirestore.instance);
  List<AvailabilitySlot> _slots = [];
  List<AppointmentItem> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    try {
      final slots = await _appointmentService.getAvailableSlotsForPsychologist(user.uid);
      final appts = await _appointmentService.getMyAppointmentsAsPsychologist(user.uid);
      if (mounted) {
        setState(() {
          _slots = slots;
          _slots.sort((a, b) => a.startTime.compareTo(b.startTime));
          _appointments = appts;
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openAddSlotsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSlotsSheet(
        appointmentService: _appointmentService,
        onSlotsAdded: (count) {
          _load();
          _showSuccess('$count horário(s) adicionado(s) com sucesso na sua agenda!');
        },
      ),
    );
  }

  Future<void> _removeSlot(AvailabilitySlot slot) async {
    try {
      await _appointmentService.deleteSlot(slot.id);
      _load();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
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
                        const Text(
                          'Minha Agenda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_slots.where((s) => !s.isBooked).length} horários livres • ${upcoming.length} consulta(s) agendada(s)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
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
              child: Center(
                child: CircularProgressIndicator(color: AppColors.psychologist),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Botão de ação rápida
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.psychologist,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _openAddSlotsModal,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: const Text(
                        'Disponibilizar horários na agenda',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),

                  // ── Próximas consultas ────────────────────────
                  if (upcoming.isNotEmpty) ...[
                    const _SectionLabel(text: 'Consultas agendadas'),
                    const SizedBox(height: 10),
                    ...upcoming.map(
                      (a) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_available_rounded,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.displayPatientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _formatDateTime(a.startTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Confirmada',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Horários livres na agenda ─────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionLabel(text: 'Horários disponíveis para pacientes'),
                      Text(
                        '${_slots.where((s) => !s.isBooked).length} slots',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.psychologist,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_slots.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E7EF)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.event_note_rounded,
                            color: AppColors.textSecondary,
                            size: 44,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nenhum horário cadastrado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Clique no botão acima ou no botão (+) para adicionar seus dias e horários de atendimento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.psychologist,
                              side: const BorderSide(color: AppColors.psychologist),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _openAddSlotsModal,
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Adicionar agora'),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._slots.map(
                      (slot) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: slot.isBooked
                                ? AppColors.success.withValues(alpha: 0.3)
                                : const Color(0xFFEAEFF5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: slot.isBooked
                                    ? AppColors.success.withValues(alpha: 0.12)
                                    : AppColors.psychologist.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                slot.isBooked
                                    ? Icons.event_busy_rounded
                                    : Icons.schedule_rounded,
                                color: slot.isBooked
                                    ? AppColors.success
                                    : AppColors.psychologist,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateTime(slot.startTime),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        slot.isBooked ? 'Reservado' : 'Disponível',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: slot.isBooked
                                              ? AppColors.success
                                              : AppColors.psychologist,
                                        ),
                                      ),
                                      const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                                      Text(
                                        slot.modality == 'online' ? 'Online 🌐' : 'Presencial 🏢',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!slot.isBooked)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => _removeSlot(slot),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.psychologist,
        foregroundColor: Colors.white,
        onPressed: _openAddSlotsModal,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo Horário', style: TextStyle(fontWeight: FontWeight.w700)),
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
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
        ),
      );
}

// ── Modal de Configuração de Agenda com Grade de Horários ─────────

class _AddSlotsSheet extends StatefulWidget {
  final AppointmentService appointmentService;
  final ValueChanged<int> onSlotsAdded;

  const _AddSlotsSheet({
    required this.appointmentService,
    required this.onSlotsAdded,
  });

  @override
  State<_AddSlotsSheet> createState() => _AddSlotsSheetState();
}

class _AddSlotsSheetState extends State<_AddSlotsSheet> {
  bool _isRecurring = true;
  String _modality = 'online';
  int _weeksToGenerate = 4;
  DateTime _specificDate = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  // Dias da semana selecionados (1=Seg, 2=Ter, 3=Qua, 4=Qui, 5=Sex, 6=Sáb, 7=Dom)
  final Set<int> _selectedWeekdays = {1, 3}; // Padrão: Seg e Qua

  // Horários selecionados em grade (hora inteira: 7 a 21)
  final Set<int> _selectedHours = {9, 10, 14, 15, 16};

  final List<int> _availableHours = [
    7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21
  ];

  final Map<int, String> _weekdayLabels = {
    1: 'Seg',
    2: 'Ter',
    3: 'Qua',
    4: 'Qui',
    5: 'Sex',
    6: 'Sáb',
    7: 'Dom',
  };

  void _selectPreset(String preset) {
    setState(() {
      _selectedHours.clear();
      if (preset == 'morning') {
        _selectedHours.addAll([8, 9, 10, 11]);
      } else if (preset == 'afternoon') {
        _selectedHours.addAll([13, 14, 15, 16, 17]);
      } else if (preset == 'evening') {
        _selectedHours.addAll([18, 19, 20, 21]);
      } else if (preset == 'all') {
        _selectedHours.addAll(_availableHours);
      }
    });
  }

  List<DateTime> _computeTargetDates() {
    if (!_isRecurring) {
      return [_specificDate];
    }

    final List<DateTime> dates = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDays = _weeksToGenerate * 7;

    for (int i = 1; i <= totalDays; i++) {
      final date = today.add(Duration(days: i));
      if (_selectedWeekdays.contains(date.weekday)) {
        dates.add(date);
      }
    }
    return dates;
  }

  int get _estimatedSlotsCount {
    final dates = _computeTargetDates();
    return dates.length * _selectedHours.length;
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_isRecurring && _selectedWeekdays.isEmpty) {
      _showSnack('Selecione pelo menos um dia da semana.');
      return;
    }
    if (_selectedHours.isEmpty) {
      _showSnack('Selecione pelo menos um horário na grade.');
      return;
    }

    final dates = _computeTargetDates();
    if (dates.isEmpty) {
      _showSnack('Nenhuma data correspondente no período selecionado.');
      return;
    }

    setState(() => _saving = true);
    try {
      final count = await widget.appointmentService.addBatchAvailabilitySlots(
        psychologistId: user.uid,
        dates: dates,
        selectedHours: _selectedHours.toList()..sort(),
        modality: _modality,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSlotsAdded(count);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceAll('Exception: ', ''));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Barra de arrasto
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              // Cabeçalho
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Disponibilizar Horários',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Configure sua grade de atendimento',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Conteúdo rolável
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    // Seletor de Modo: Recorrente vs Data Específica
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isRecurring = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isRecurring ? AppColors.psychologist : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '🔁 Dias da Semana',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _isRecurring ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isRecurring = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isRecurring ? AppColors.psychologist : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '📅 Data Específica',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: !_isRecurring ? Colors.white : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Seção de Dias da Semana (Se Recorrente)
                    if (_isRecurring) ...[
                      const Text(
                        'Selecione os dias de atendimento',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _weekdayLabels.entries.map((entry) {
                          final isSelected = _selectedWeekdays.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            selectedColor: AppColors.psychologist.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.psychologist,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isSelected ? AppColors.psychologist : AppColors.textPrimary,
                            ),
                            side: BorderSide(
                              color: isSelected ? AppColors.psychologist : const Color(0xFFD0DCE8),
                              width: isSelected ? 1.5 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedWeekdays.add(entry.key);
                                } else {
                                  _selectedWeekdays.remove(entry.key);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => setState(() => _selectedWeekdays.addAll([1, 2, 3, 4, 5])),
                            child: const Text('Seg a Sex', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => setState(() {
                              _selectedWeekdays.clear();
                              _selectedWeekdays.addAll([1, 3]);
                            }),
                            child: const Text('Seg e Qua', style: TextStyle(fontSize: 12)),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => setState(() => _selectedWeekdays.clear()),
                            child: const Text('Limpar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Duração / Quantidade de semanas
                      const Text(
                        'Repetir pelas próximas',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [2, 4, 8].map((weeks) {
                          final selected = _weeksToGenerate == weeks;
                          return ChoiceChip(
                            label: Text('$weeks semanas'),
                            selected: selected,
                            selectedColor: AppColors.psychologist,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            onSelected: (_) => setState(() => _weeksToGenerate = weeks),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      // Se Data Específica
                      const Text(
                        'Data do atendimento',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _specificDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setState(() => _specificDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFD0DCE8)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: AppColors.psychologist, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                '${_specificDate.day.toString().padLeft(2, '0')}/${_specificDate.month.toString().padLeft(2, '0')}/${_specificDate.year}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const Spacer(),
                              const Text('Alterar', style: TextStyle(color: AppColors.psychologist, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Grade de Horários de 1 em 1 hora ─────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grade de Horários (1h cada)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${_selectedHours.length} selecionado(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.psychologist,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Atalhos rápidos
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickPresetButton(
                            label: 'Manhã (08h-11h)',
                            onTap: () => _selectPreset('morning'),
                          ),
                          const SizedBox(width: 8),
                          _QuickPresetButton(
                            label: 'Tarde (13h-17h)',
                            onTap: () => _selectPreset('afternoon'),
                          ),
                          const SizedBox(width: 8),
                          _QuickPresetButton(
                            label: 'Noite (18h-21h)',
                            onTap: () => _selectPreset('evening'),
                          ),
                          const SizedBox(width: 8),
                          _QuickPresetButton(
                            label: 'Todos',
                            onTap: () => _selectPreset('all'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Grade visual (Grid de chips)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _availableHours.length,
                      itemBuilder: (context, i) {
                        final hour = _availableHours[i];
                        final isSelected = _selectedHours.contains(hour);
                        final label = '${hour.toString().padLeft(2, '0')}:00';

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedHours.remove(hour);
                              } else {
                                _selectedHours.add(hour);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.psychologist : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.psychologist : const Color(0xFFD0DCE8),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.psychologist.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                    size: 14,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Modalidade
                    const Text(
                      'Modalidade de Atendimento',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ModalityCard(
                            label: 'Online',
                            icon: Icons.videocam_rounded,
                            selected: _modality == 'online',
                            onTap: () => setState(() => _modality = 'online'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModalityCard(
                            label: 'Presencial',
                            icon: Icons.business_rounded,
                            selected: _modality == 'presential',
                            onTap: () => setState(() => _modality = 'presential'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Botão de Gerar
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.psychologist,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Gerar $_estimatedSlotsCount horários na agenda',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickPresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.psychologist.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.psychologist.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.psychologist,
          ),
        ),
      ),
    );
  }
}

class _ModalityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModalityCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.psychologist.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.psychologist : const Color(0xFFD0DCE8),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.psychologist : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.psychologist : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
