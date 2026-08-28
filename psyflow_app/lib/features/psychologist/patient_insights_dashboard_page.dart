import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/mood_service.dart';
import '../../core/services/task_service.dart';
import '../../core/di/service_locator.dart';
import '../../models/mood_model.dart';
import '../../models/task_item.dart';
import '../../models/assessment_template_model.dart';
import 'clinical_report_generator_dialog.dart';

class PatientInsightsDashboardPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientInsightsDashboardPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientInsightsDashboardPage> createState() => _PatientInsightsDashboardPageState();
}

class _PatientInsightsDashboardPageState extends State<PatientInsightsDashboardPage> {
  final _moodService = sl<MoodService>();
  final _taskService = sl<TaskService>();

  List<MoodEntry> _entries = [];
  List<TaskItem> _patientTasks = [];
  bool _loading = true;
  int _selectedDaysPeriod = 7; // 7, 30, 90

  // Toggles de visualização no gráfico
  bool _showMood = true;
  bool _showAnxiety = true;
  bool _showSleep = true;
  bool _showEnergy = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final sinceDate = DateTime.now().subtract(Duration(days: _selectedDaysPeriod));
      final entries = await _moodService.getPatientEntries(
        widget.patientId,
        limit: 120,
        since: sinceDate,
      );

      // Carregar tarefas para cruzamento de dados
      List<TaskItem> tasks = [];
      try {
        tasks = await _taskService.getTasksForPatient(widget.patientId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _entries = entries;
          _patientTasks = tasks;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showError('Erro ao carregar dados do paciente: $e');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int get _completedTasksCount => _patientTasks.where((t) => t.isCompleted).length;
  int get _totalTasksCount => _patientTasks.length;

  void _openReportGenerator() {
    showDialog(
      context: context,
      builder: (_) => ClinicalReportGeneratorDialog(
        patientId: widget.patientId,
        patientName: widget.patientName,
        entries: _entries,
        completedTasks: _completedTasksCount,
        totalTasks: _totalTasksCount,
      ),
    );
  }

  Future<void> _openCheckInConfigDialog() async {
    final currentConfig = await _moodService.getPatientAssessmentConfig(widget.patientId);
    if (!mounted) return;

    bool trackMood = currentConfig.trackMood;
    bool trackAnxiety = currentConfig.trackAnxiety;
    bool trackSleep = currentConfig.trackSleep;
    bool trackEnergy = currentConfig.trackEnergy;
    bool trackStress = currentConfig.trackStress;
    String frequency = currentConfig.frequency;
    String reminderTime = currentConfig.reminderTime ?? '08:00';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.psychologist),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Configurar Check-in do Paciente',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Defina quais perguntas e frequência estarão ativas para este paciente:',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                const Text('Frequência:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Diário')),
                    DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                    DropdownMenuItem(value: 'custom', child: Text('Personalizado')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => frequency = val);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Perguntas ativas:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                CheckboxListTile(
                  dense: true,
                  title: const Text('Humor (1-10)'),
                  value: trackMood,
                  onChanged: (v) => setDialogState(() => trackMood = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  title: const Text('Ansiedade (1-10)'),
                  value: trackAnxiety,
                  onChanged: (v) => setDialogState(() => trackAnxiety = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  title: const Text('Qualidade do Sono (1-10)'),
                  value: trackSleep,
                  onChanged: (v) => setDialogState(() => trackSleep = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  title: const Text('Energia & Disposição (1-10)'),
                  value: trackEnergy,
                  onChanged: (v) => setDialogState(() => trackEnergy = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  title: const Text('Nível de Estresse (1-10)'),
                  value: trackStress,
                  onChanged: (v) => setDialogState(() => trackStress = v ?? true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.psychologist,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final newConfig = AssessmentTemplate(
                  id: widget.patientId,
                  title: 'Check-in Personalizado',
                  description: 'Check-in clínico configurado pelo psicólogo.',
                  frequency: frequency,
                  reminderTime: reminderTime,
                  trackMood: trackMood,
                  trackAnxiety: trackAnxiety,
                  trackSleep: trackSleep,
                  trackEnergy: trackEnergy,
                  trackStress: trackStress,
                );
                await _moodService.savePatientAssessmentConfig(widget.patientId, newConfig);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configurações de check-in salvas com sucesso!')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final averages = _moodService.calculateAverages(_entries);
    final weeklyTrend = _moodService.calculateWeeklyTrend(_entries);
    final observations = _moodService.generateClinicalObservations(
      _entries,
      completedTasks: _completedTasksCount,
      totalTasks: _totalTasksCount,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar do Psicólogo ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.psychologist,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                tooltip: 'Configurar Check-ins',
                onPressed: _openCheckInConfigDialog,
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                tooltip: 'Gerar Relatório',
                onPressed: _openReportGenerator,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF4F46E5),
                      Color(0xFF4338CA),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
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
                                  Icon(Icons.insights_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'PsyFlow Insights',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          widget.patientName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Acompanhamento Longitudinal & Padrões Emocionais',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Conteúdo do Dashboard ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtro de Período
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),

                  // Cards de Médias do Período
                  _buildMetricsGrid(averages, weeklyTrend),
                  const SizedBox(height: 24),

                  // Gráfico de Evolução Temporal
                  _buildEvolutionChartSection(),
                  const SizedBox(height: 24),

                  // Cruzamento de Dados & Observações Clínicas
                  _buildCrossAnalysisSection(observations),
                  const SizedBox(height: 24),

                  // Resumo da Semana & Pontos de Atenção
                  _buildAttentionPointsSection(weeklyTrend),
                  const SizedBox(height: 24),

                  // Botão de Gerar Relatório em Destaque
                  _buildReportActionCard(),
                  const SizedBox(height: 28),

                  // Histórico de Registros
                  const Text(
                    'Registros Individuais no Período',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Lista de Registros Recentes
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.psychologist),
              ),
            )
          else if (_entries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.hourglass_empty_rounded, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'Nenhum registro encontrado no período',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tente selecionar um período mais amplo acima.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                    return _buildEntryItemCard(entry);
                  },
                  childCount: _entries.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        const Text(
          'Período:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDaysPeriod,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('Últimos 7 dias')),
                  DropdownMenuItem(value: 14, child: Text('Últimos 14 dias')),
                  DropdownMenuItem(value: 30, child: Text('Últimos 30 dias')),
                  DropdownMenuItem(value: 90, child: Text('Últimos 90 dias')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedDaysPeriod = val);
                    _loadData();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(Map<String, double> avg, Map<String, double?> trends) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Humor médio',
                value: avg['mood'] ?? 0,
                color: const Color(0xFF0EA5E9),
                icon: '😊',
                trendPercent: trends['moodDiff'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Ansiedade média',
                value: avg['anxiety'] ?? 0,
                color: const Color(0xFFF59E0B),
                icon: '😰',
                trendPercent: trends['anxietyDiff'],
                inverseTrend: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Qualidade do sono',
                value: avg['sleep'] ?? 0,
                color: const Color(0xFF6366F1),
                icon: '😴',
                trendPercent: trends['sleepDiff'],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Energia média',
                value: avg['energy'] ?? 0,
                color: const Color(0xFF10B981),
                icon: '⚡',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double value,
    required Color color,
    required String icon,
    double? trendPercent,
    bool inverseTrend = false,
  }) {
    String? trendLabel;
    Color trendColor = AppColors.textSecondary;
    IconData? trendIcon;

    if (trendPercent != null && trendPercent.abs() >= 1.0) {
      final isPositive = trendPercent > 0;
      final isFavorable = inverseTrend ? !isPositive : isPositive;
      trendColor = isFavorable ? AppColors.success : AppColors.error;
      trendIcon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
      trendLabel = '${trendPercent > 0 ? '+' : ''}${trendPercent.toStringAsFixed(0)}%';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(icon, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value > 0 ? value.toStringAsFixed(1) : '-',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/10',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (trendLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(trendIcon, size: 13, color: trendColor),
                      const SizedBox(width: 2),
                      Text(
                        trendLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionChartSection() {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Evolução Temporal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.psychologist.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Escala 1 a 10',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.psychologist,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Toggles de Linhas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChartToggleChip('😊 Humor', const Color(0xFF0EA5E9), _showMood, (v) => setState(() => _showMood = v)),
                const SizedBox(width: 8),
                _buildChartToggleChip('😰 Ansiedade', const Color(0xFFF59E0B), _showAnxiety, (v) => setState(() => _showAnxiety = v)),
                const SizedBox(width: 8),
                _buildChartToggleChip('😴 Sono', const Color(0xFF6366F1), _showSleep, (v) => setState(() => _showSleep = v)),
                const SizedBox(width: 8),
                _buildChartToggleChip('⚡ Energia', const Color(0xFF10B981), _showEnergy, (v) => setState(() => _showEnergy = v)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Canvas do Gráfico Interativo
          if (_entries.isEmpty)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: const Text(
                'Sem registros suficientes para traçar a evolução.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomPaint(
                painter: _EvolutionChartPainter(
                  entries: _entries.reversed.toList(),
                  showMood: _showMood,
                  showAnxiety: _showAnxiety,
                  showSleep: _showSleep,
                  showEnergy: _showEnergy,
                ),
              ),
            ),
          const SizedBox(height: 10),
          const Text(
            'Toque e observe os pontos ao longo das datas para acompanhar as variações relatadas.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggleChip(String label, Color color, bool isSelected, ValueChanged<bool> onChanged) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      selectedColor: color,
      backgroundColor: AppColors.background,
      side: BorderSide(color: isSelected ? color : Colors.black.withValues(alpha: 0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: onChanged,
    );
  }

  Widget _buildCrossAnalysisSection(List<String> observations) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.psychologist.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: AppColors.psychologist, size: 20),
              SizedBox(width: 8),
              Text(
                'Cruzamento de Dados & Correlações',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...observations.map((obs) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.psychologist, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      obs,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Observações estatísticas dos registros para apoio à condução clínica, sem valor diagnóstico causal automatizado.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionPointsSection(Map<String, double?> weeklyTrend) {
    final highAnxiety = _entries.where((e) => e.anxiety >= 8).length;
    final poorSleep = _entries.where((e) => e.sleepQuality <= 3).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Row(
            children: [
              Icon(Icons.flag_outlined, color: Color(0xFFF59E0B), size: 20),
              SizedBox(width: 8),
              Text(
                'Pontos de Atenção no Período',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (highAnxiety == 0 && poorSleep == 0)
            const Text(
              'Nenhum pico crítico de ansiedade ou sono muito baixo registrado no período selecionado.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else ...[
            if (highAnxiety > 0)
              _buildAttentionItem(
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFEF4444),
                text: '$highAnxiety registro(s) de ansiedade severa (nível ≥ 8).',
              ),
            if (poorSleep > 0)
              _buildAttentionItem(
                icon: Icons.bedtime_off_rounded,
                color: const Color(0xFF6366F1),
                text: '$poorSleep noite(s) com queixa de sono muito ruim (nível ≤ 3).',
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttentionItem({required IconData icon, required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportActionCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _openReportGenerator,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.description_rounded, color: Colors.white, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gerar Relatório de Acompanhamento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Exporte dados, gráficos e médias para a sessão ou prontuário.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEntryItemCard(MoodEntry entry) {
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final dateStr = '${entry.createdAt.day} ${months[entry.createdAt.month - 1]} às ${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(entry.moodEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Humor: ${entry.mood}/10 (${entry.moodLabel})',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Text(dateStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildMiniBadge('Ansiedade: ${entry.anxiety}/10', const Color(0xFFF59E0B)),
              _buildMiniBadge('Sono: ${entry.sleepQuality}/10', const Color(0xFF6366F1)),
              _buildMiniBadge('Energia: ${entry.energy}/10', const Color(0xFF10B981)),
              if (entry.stress > 0)
                _buildMiniBadge('Estresse: ${entry.stress}/10', const Color(0xFFEF4444)),
            ],
          ),
          if (entry.factors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Fatores: ${entry.factors.join(", ")}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
          if (entry.notes != null && entry.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '📝 "${entry.notes}"',
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter: Gráfico de Evolução Temporal
// ─────────────────────────────────────────────────────────────────────────────

class _EvolutionChartPainter extends CustomPainter {
  final List<MoodEntry> entries;
  final bool showMood;
  final bool showAnxiety;
  final bool showSleep;
  final bool showEnergy;

  _EvolutionChartPainter({
    required this.entries,
    required this.showMood,
    required this.showAnxiety,
    required this.showSleep,
    required this.showEnergy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bottomMargin = 26.0;
    final leftMargin = 28.0;
    final chartHeight = size.height - bottomMargin;
    final chartWidth = size.width - leftMargin;

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final textStyle = TextStyle(
      color: Colors.black.withValues(alpha: 0.4),
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    // Linhas horizontais (1, 3.25, 5.5, 7.75, 10)
    for (int i = 0; i <= 4; i++) {
      final y = chartHeight - (chartHeight * (i / 4.0));
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      final val = (1 + (9 * (i / 4.0))).toStringAsFixed(i == 0 || i == 4 ? 0 : 1);
      final textPainter = TextPainter(
        text: TextSpan(text: val, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(leftMargin - textPainter.width - 6, y - textPainter.height / 2));
    }

    if (entries.isEmpty) return;

    final n = entries.length;
    double getX(int index) {
      if (n == 1) return leftMargin + chartWidth / 2;
      return leftMargin + (chartWidth * (index / (n - 1)));
    }

    double getY(int score) {
      // score 1 -> chartHeight, score 10 -> 0
      final norm = ((score - 1) / 9.0).clamp(0.0, 1.0);
      return chartHeight - (chartHeight * norm);
    }

    // Desenhar séries
    if (showMood) {
      _drawLineSeries(canvas, (e) => e.mood, const Color(0xFF0EA5E9), getX, getY, n);
    }
    if (showAnxiety) {
      _drawLineSeries(canvas, (e) => e.anxiety, const Color(0xFFF59E0B), getX, getY, n);
    }
    if (showSleep) {
      _drawLineSeries(canvas, (e) => e.sleepQuality, const Color(0xFF6366F1), getX, getY, n);
    }
    if (showEnergy) {
      _drawLineSeries(canvas, (e) => e.energy, const Color(0xFF10B981), getX, getY, n);
    }

    // Datas no eixo X
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    final step = (n / 5).ceil().clamp(1, n);

    for (int i = 0; i < n; i += step) {
      final x = getX(i);
      final d = entries[i].createdAt;
      final label = '${d.day} ${months[d.month - 1]}';
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height - bottomMargin + 8));
    }
  }

  void _drawLineSeries(
    Canvas canvas,
    int Function(MoodEntry) getValue,
    Color color,
    double Function(int) getX,
    double Function(int) getY,
    int count,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    for (int i = 0; i < count; i++) {
      final x = getX(i);
      final y = getY(getValue(entries[i]));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Desenhar pontos
    for (int i = 0; i < count; i++) {
      final x = getX(i);
      final y = getY(getValue(entries[i]));
      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);
      canvas.drawCircle(Offset(x, y), 2.5, dotWhitePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EvolutionChartPainter oldDelegate) => true;
}
