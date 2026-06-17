import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/mood_service.dart';
import '../../models/mood_model.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final _moodService = MoodService();
  List<MoodEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entries = await _moodService.getMyEntries();
      if (mounted) setState(() => _entries = entries);
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

  Future<void> _openRegisterSheet() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterMoodSheet(moodService: _moodService),
    );
    if (saved == true) _load();
  }

  String _formatDateTime(DateTime d) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
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
                          'Mapa Emocional',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Acompanhe como você está se sentindo',
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
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Botão de registro ────────────────────────
                  GestureDetector(
                    onTap: _openRegisterSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.patient, AppColors.accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppColors.patient.withValues(alpha: 0.3), blurRadius: 14, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Registrar como me sinto hoje',
                              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Histórico',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  if (_entries.isEmpty)
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
                          Icon(Icons.favorite_border_rounded, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                          const SizedBox(height: 10),
                          const Text('Nenhum registro ainda', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    )
                  else
                    ..._entries.map((entry) => _MoodEntryCard(entry: entry, formatDateTime: _formatDateTime)),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final MoodEntry entry;
  final String Function(DateTime) formatDateTime;

  const _MoodEntryCard({required this.entry, required this.formatDateTime});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.moodEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.moodLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    Text(formatDateTime(entry.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MetricBar(label: 'Ansiedade', value: entry.anxiety, color: AppColors.cardOrange)),
              const SizedBox(width: 10),
              Expanded(child: _MetricBar(label: 'Energia', value: entry.energy, color: AppColors.cardGreen)),
            ],
          ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(entry.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          ],
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String label;
  final int value; // 1-5
  final Color color;

  const _MetricBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 2),
              height: 5,
              decoration: BoxDecoration(
                color: i < value ? color : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          )),
        ),
      ],
    );
  }
}

// ── Bottom sheet de registro ────────────────────────────────────

class _RegisterMoodSheet extends StatefulWidget {
  final MoodService moodService;
  const _RegisterMoodSheet({required this.moodService});

  @override
  State<_RegisterMoodSheet> createState() => _RegisterMoodSheetState();
}

class _RegisterMoodSheetState extends State<_RegisterMoodSheet> {
  int mood = 3;
  int anxiety = 3;
  int energy = 3;
  final notesController = TextEditingController();
  bool saving = false;

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await widget.moodService.addEntry(
        mood: mood,
        anxiety: anxiety,
        energy: energy,
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
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
    notesController.dispose();
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
                  decoration: BoxDecoration(color: AppColors.textSecondary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Como você está hoje?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),

              _EmojiSelector(
                label: 'Humor',
                value: mood,
                onChanged: (v) => setState(() => mood = v),
              ),
              const SizedBox(height: 24),
              _SliderSelector(
                label: 'Ansiedade',
                value: anxiety,
                color: AppColors.cardOrange,
                onChanged: (v) => setState(() => anxiety = v),
              ),
              const SizedBox(height: 20),
              _SliderSelector(
                label: 'Energia',
                value: energy,
                color: AppColors.cardGreen,
                onChanged: (v) => setState(() => energy = v),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Observações (opcional)'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.patient,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Salvar registro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiSelector extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _EmojiSelector({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final level = i + 1;
            final selected = value == level;
            return GestureDetector(
              onTap: () => onChanged(level),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected ? AppColors.patient.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: selected ? AppColors.patient : Colors.transparent, width: 2),
                ),
                child: Center(
                  child: Text(MoodEntry.moodEmojis[i], style: TextStyle(fontSize: selected ? 28 : 24)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SliderSelector extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onChanged;

  const _SliderSelector({required this.label, required this.value, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            Text('$value/5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.15),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}