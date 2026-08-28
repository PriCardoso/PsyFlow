import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/mood_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/mood_model.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final _moodService = sl<MoodService>();
  List<MoodEntry> _entries = [];
  bool _loading = true;
  bool _hasToday = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final entries = await _moodService.getMyEntries();
      final hasToday = await _moodService.hasEntryToday();
      if (mounted) {
        setState(() {
          _entries = entries;
          _hasToday = hasToday;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
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

  Future<void> _openRegisterSheet({String? initialCategory}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DailyCheckInSheet(
        moodService: _moodService,
        initialCategory: initialCategory,
      ),
    );
    if (saved == true) {
      _load();
    }
  }

  String _formatDateTime(DateTime d) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${d.day} de ${months[d.month - 1]} às $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final averages = _moodService.calculateAverages(_entries);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header Premium ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.patient,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D9488),
                      Color(0xFF14B8A6),
                      Color(0xFF2DD4BF),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.spa_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'PsyFlow Insights',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_hasToday)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Check-in feito hoje',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Meu Acompanhamento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitore suas emoções, sono, energia e pensamentos diários.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Corpo Principal ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de Ação de Check-in
                  _buildDailyCheckInBanner(),
                  const SizedBox(height: 24),

                  // Pilares de Acompanhamento (Atalhos rápidos)
                  const Text(
                    'Dimensões de Bem-estar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDimensionsGrid(),
                  const SizedBox(height: 28),

                  // Resumo Médio das Últimas Semanas
                  if (_entries.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Minha Evolução Recente',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${_entries.length} registro(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryMetrics(averages),
                    const SizedBox(height: 28),
                  ],

                  // Histórico de Registros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de Diários & Check-ins',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                        onPressed: _load,
                        tooltip: 'Atualizar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Lista de Registros
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.patient),
              ),
            )
          else if (_entries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.patient.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 48,
                          color: AppColors.patient,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum registro ainda',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Faça seu primeiro check-in diário para começar a visualizar suas tendências.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.patient,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _openRegisterSheet(),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Fazer check-in agora', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = _entries[index];
                    return _buildEntryCard(entry);
                  },
                  childCount: _entries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyCheckInBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _hasToday ? AppColors.success.withValues(alpha: 0.3) : AppColors.patient.withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openRegisterSheet(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _hasToday
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF0D9488), const Color(0xFF047857)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _hasToday ? '✨' : '🌱',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasToday ? 'Novo Registro / Atualização' : 'Como você está hoje?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasToday
                            ? 'Você pode registrar outros momentos do dia.'
                            : 'Leva menos de 2 minutos para registrar seu bem-estar.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.patient.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.patient,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionsGrid() {
    final dimensions = [
      {'title': 'Humor', 'icon': '😊', 'color': const Color(0xFF0EA5E9), 'category': 'mood'},
      {'title': 'Ansiedade', 'icon': '😰', 'color': const Color(0xFFF59E0B), 'category': 'anxiety'},
      {'title': 'Sono', 'icon': '😴', 'color': const Color(0xFF6366F1), 'category': 'sleep'},
      {'title': 'Energia', 'icon': '⚡', 'color': const Color(0xFF10B981), 'category': 'energy'},
      {'title': 'Estresse', 'icon': '❤️', 'color': const Color(0xFFEF4444), 'category': 'stress'},
      {'title': 'Diário', 'icon': '📝', 'color': const Color(0xFF8B5CF6), 'category': 'journal'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.15,
      ),
      itemCount: dimensions.length,
      itemBuilder: (context, index) {
        final item = dimensions[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openRegisterSheet(initialCategory: item['category'] as String),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['icon'] as String,
                  style: const TextStyle(fontSize: 26),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryMetrics(Map<String, double> averages) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Médias Registradas (Escala 1 a 10)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('😊 Humor', averages['mood'] ?? 0, const Color(0xFF0EA5E9)),
              _buildMetricItem('😰 Ansiedade', averages['anxiety'] ?? 0, const Color(0xFFF59E0B)),
              _buildMetricItem('😴 Sono', averages['sleep'] ?? 0, const Color(0xFF6366F1)),
              _buildMetricItem('⚡ Energia', averages['energy'] ?? 0, const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value > 0 ? value.toStringAsFixed(1) : '-',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(MoodEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha de Cabeçalho com Emoji e Data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    entry.moodEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Humor: ${entry.moodLabel} (${entry.mood}/10)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDateTime(entry.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Badges de Indicadores
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildIndicatorBadge('Ansiedade: ${entry.anxiety}/10', entry.anxietyEmoji, const Color(0xFFF59E0B)),
              _buildIndicatorBadge('Sono: ${entry.sleepQuality}/10', entry.sleepEmoji, const Color(0xFF6366F1)),
              _buildIndicatorBadge('Energia: ${entry.energy}/10', entry.energyEmoji, const Color(0xFF10B981)),
              if (entry.stress > 0)
                _buildIndicatorBadge('Estresse: ${entry.stress}/10', '❤️', const Color(0xFFEF4444)),
            ],
          ),

          // Fatores de Influência
          if (entry.factors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.factors.map((factor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Text(
                    '• $factor',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Notas / Diário
          if (entry.notes != null && entry.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                entry.notes!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIndicatorBadge(String text, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Modal de Check-in Diário ("Como você está hoje?")
// ─────────────────────────────────────────────────────────────────────────────

class _DailyCheckInSheet extends StatefulWidget {
  final MoodService moodService;
  final String? initialCategory;

  const _DailyCheckInSheet({
    required this.moodService,
    this.initialCategory,
  });

  @override
  State<_DailyCheckInSheet> createState() => _DailyCheckInSheetState();
}

class _DailyCheckInSheetState extends State<_DailyCheckInSheet> {
  double _mood = 7.0;
  double _anxiety = 4.0;
  double _energy = 6.0;
  double _sleep = 6.0;
  double _stress = 4.0;
  final _notesController = TextEditingController();
  final Set<String> _selectedFactors = {};
  bool _saving = false;

  final List<Map<String, dynamic>> _availableFactors = [
    {'name': 'Trabalho', 'icon': '💼'},
    {'name': 'Família', 'icon': '👨‍👩‍👧'},
    {'name': 'Relacionamento', 'icon': '❤️'},
    {'name': 'Estudos', 'icon': '📚'},
    {'name': 'Saúde', 'icon': '🩺'},
    {'name': 'Finanças', 'icon': '💳'},
    {'name': 'Sono', 'icon': '😴'},
    {'name': 'Alimentação', 'icon': '🥗'},
    {'name': 'Atividade Física', 'icon': '🏃'},
    {'name': 'Outro', 'icon': '✨'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.moodService.addEntry(
        mood: _mood.round(),
        anxiety: _anxiety.round(),
        energy: _energy.round(),
        sleepQuality: _sleep.round(),
        stress: _stress.round(),
        notes: _notesController.text.trim(),
        factors: _selectedFactors.toList(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Text('Registro de acompanhamento salvo com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Puxador
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como você está hoje?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Registre suas percepções e emoções de 1 a 10',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Formulário com Rolagem
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Humor
                  _buildSliderSection(
                    title: 'Humor',
                    value: _mood,
                    emojiStart: '😞 1',
                    emojiEnd: '10 😄',
                    currentEmoji: MoodEntry.moodEmojis10[_mood.round().clamp(1, 10) - 1],
                    currentLabel: MoodEntry.moodLabels10[_mood.round().clamp(1, 10) - 1],
                    color: const Color(0xFF0EA5E9),
                    onChanged: (v) => setState(() => _mood = v),
                  ),
                  const SizedBox(height: 24),

                  // 2. Ansiedade
                  _buildSliderSection(
                    title: 'Ansiedade',
                    value: _anxiety,
                    emojiStart: '😌 1 (Calmo)',
                    emojiEnd: '10 😰 (Intensa)',
                    currentEmoji: _getAnxietyEmoji(_anxiety.round()),
                    currentLabel: _getAnxietyLabel(_anxiety.round()),
                    color: const Color(0xFFF59E0B),
                    onChanged: (v) => setState(() => _anxiety = v),
                  ),
                  const SizedBox(height: 24),

                  // 3. Sono
                  _buildSliderSection(
                    title: 'Qualidade do Sono',
                    value: _sleep,
                    emojiStart: '🥱 1 (Péssimo)',
                    emojiEnd: '10 😴 (Reparador)',
                    currentEmoji: _getSleepEmoji(_sleep.round()),
                    currentLabel: _getSleepLabel(_sleep.round()),
                    color: const Color(0xFF6366F1),
                    onChanged: (v) => setState(() => _sleep = v),
                  ),
                  const SizedBox(height: 24),

                  // 4. Energia
                  _buildSliderSection(
                    title: 'Energia & Disposição',
                    value: _energy,
                    emojiStart: '🪫 1 (Exausto)',
                    emojiEnd: '10 ⚡ (Cheio)',
                    currentEmoji: _getEnergyEmoji(_energy.round()),
                    currentLabel: _getEnergyLabel(_energy.round()),
                    color: const Color(0xFF10B981),
                    onChanged: (v) => setState(() => _energy = v),
                  ),
                  const SizedBox(height: 24),

                  // 5. Estresse
                  _buildSliderSection(
                    title: 'Nível de Estresse',
                    value: _stress,
                    emojiStart: '🕊️ 1 (Leve)',
                    emojiEnd: '10 💥 (Crítico)',
                    currentEmoji: '❤️',
                    currentLabel: _getStressLabel(_stress.round()),
                    color: const Color(0xFFEF4444),
                    onChanged: (v) => setState(() => _stress = v),
                  ),
                  const SizedBox(height: 28),

                  // 6. Fatores de Influência
                  const Text(
                    'O que mais influenciou seu dia?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecione uma ou mais opções que impactaram suas emoções:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableFactors.map((f) {
                      final name = f['name'] as String;
                      final icon = f['icon'] as String;
                      final isSelected = _selectedFactors.contains(name);
                      return FilterChip(
                        selected: isSelected,
                        label: Text('$icon $name'),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.patient : AppColors.textPrimary,
                        ),
                        selectedColor: AppColors.patient.withValues(alpha: 0.15),
                        backgroundColor: AppColors.background,
                        side: BorderSide(
                          color: isSelected ? AppColors.patient : Colors.black.withValues(alpha: 0.1),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFactors.add(name);
                            } else {
                              _selectedFactors.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // 7. Diário / Como foi seu dia
                  const Text(
                    'Como foi seu dia?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Descreva pensamentos, acontecimentos ou como você se sentiu:',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escreva livremente o que passou pela sua cabeça hoje...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.patient,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Concluir Registro',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String title,
    required double value,
    required String emojiStart,
    required String emojiEnd,
    required String currentEmoji,
    required String currentLabel,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(currentEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      '${value.round()}/10 • $currentLabel',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emojiStart, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(emojiEnd, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  String _getAnxietyEmoji(int val) {
    if (val <= 2) return '😌';
    if (val <= 4) return '🙂';
    if (val <= 6) return '😐';
    if (val <= 8) return '😰';
    return '🤯';
  }

  String _getAnxietyLabel(int val) {
    if (val <= 2) return 'Calmo';
    if (val <= 4) return 'Leve';
    if (val <= 6) return 'Moderada';
    if (val <= 8) return 'Alta';
    return 'Intensa';
  }

  String _getSleepEmoji(int val) {
    if (val <= 2) return '🥱';
    if (val <= 4) return '😵‍💫';
    if (val <= 6) return '😴';
    if (val <= 8) return '🛌';
    return '✨';
  }

  String _getSleepLabel(int val) {
    if (val <= 2) return 'Péssimo';
    if (val <= 4) return 'Ruim';
    if (val <= 6) return 'Razoável';
    if (val <= 8) return 'Bom';
    return 'Excelente';
  }

  String _getEnergyEmoji(int val) {
    if (val <= 2) return '🪫';
    if (val <= 4) return '🥱';
    if (val <= 6) return '🔋';
    if (val <= 8) return '⚡';
    return '🔥';
  }

  String _getEnergyLabel(int val) {
    if (val <= 2) return 'Exausto';
    if (val <= 4) return 'Baixa';
    if (val <= 6) return 'Moderada';
    if (val <= 8) return 'Disposto';
    return 'Cheio de energia';
  }

  String _getStressLabel(int val) {
    if (val <= 2) return 'Sem estresse';
    if (val <= 4) return 'Leve';
    if (val <= 6) return 'Moderado';
    if (val <= 8) return 'Elevado';
    return 'Crítico';
  }
}
