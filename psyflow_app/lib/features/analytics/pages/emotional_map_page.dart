import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:psyflow_app/core/providers/mood_provider.dart';
import 'package:psyflow_app/core/theme/app_theme.dart';
import 'package:psyflow_app/core/design_system/tokens/tokens.dart';
import 'package:psyflow_app/models/mood_model.dart';

/// Página de Mapa Emocional — exibe estatísticas calculadas a partir dos
/// registros reais de humor do [MoodProvider].
class EmotionalMapPage extends StatefulWidget {
  const EmotionalMapPage({super.key});

  @override
  State<EmotionalMapPage> createState() => _EmotionalMapPageState();
}

class _EmotionalMapPageState extends State<EmotionalMapPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodProvider>().loadMyEntries(limit: 30);
    });
  }

  // ── Cálculos estatísticos ────────────────────────────────────────────────

  double _avgMood(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.mood).reduce((a, b) => a + b) / entries.length;
  }

  /// Taxa de adesão: quantos dos últimos 30 dias têm pelo menos 1 registro.
  double _adherenceRate(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;
    final days = <String>{};
    for (final e in entries) {
      final d = e.createdAt;
      days.add('${d.year}-${d.month}-${d.day}');
    }
    return (days.length / 30).clamp(0, 1) * 100;
  }

  /// Evolução: diferença entre humor médio da última semana vs semana anterior.
  double _evolution(List<MoodEntry> entries) {
    if (entries.length < 2) return 0;
    final now = DateTime.now();
    final lastWeek = entries
        .where((e) => now.difference(e.createdAt).inDays < 7)
        .toList();
    final prevWeek = entries
        .where((e) {
          final diff = now.difference(e.createdAt).inDays;
          return diff >= 7 && diff < 14;
        })
        .toList();
    if (lastWeek.isEmpty || prevWeek.isEmpty) return 0;
    final avgLast =
        lastWeek.map((e) => e.mood).reduce((a, b) => a + b) / lastWeek.length;
    final avgPrev =
        prevWeek.map((e) => e.mood).reduce((a, b) => a + b) / prevWeek.length;
    return ((avgLast - avgPrev) / avgPrev * 100);
  }

  bool _hasClinicalAlert(List<MoodEntry> entries) {
    if (entries.isEmpty) return false;
    final recent = entries.take(7);
    // Alerta se humor médio recente < 4 ou ansiedade média > 7
    final avgMood =
        recent.map((e) => e.mood).reduce((a, b) => a + b) / recent.length;
    final avgAnxiety =
        recent.map((e) => e.anxiety).reduce((a, b) => a + b) / recent.length;
    return avgMood < 4 || avgAnxiety > 7;
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = context.watch<MoodProvider>();
    final entries = moodProvider.entries;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mapa Emocional'),
        backgroundColor: AppColors.psychologist,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                moodProvider.loadMyEntries(limit: 30),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: moodProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.psychologist),
            )
          : entries.isEmpty
              ? _EmptyState(onRefresh: () => moodProvider.loadMyEntries())
              : _EmotionalMapContent(
                  entries: entries,
                  avgMood: _avgMood(entries),
                  adherenceRate: _adherenceRate(entries),
                  evolution: _evolution(entries),
                  hasClinicalAlert: _hasClinicalAlert(entries),
                ),
    );
  }
}

// ── Conteúdo principal ────────────────────────────────────────────────────────

class _EmotionalMapContent extends StatelessWidget {
  const _EmotionalMapContent({
    required this.entries,
    required this.avgMood,
    required this.adherenceRate,
    required this.evolution,
    required this.hasClinicalAlert,
  });

  final List<MoodEntry> entries;
  final double avgMood;
  final double adherenceRate;
  final double evolution;
  final bool hasClinicalAlert;

  @override
  Widget build(BuildContext context) {
    final evolutionPositive = evolution >= 0;
    final evolutionText =
        '${evolutionPositive ? '+' : ''}${evolution.toStringAsFixed(0)}%';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Grid de estatísticas ─────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Humor Médio',
                value: avgMood.toStringAsFixed(1),
                suffix: '/ 10',
                icon: Icons.mood,
                color: MoodEntry.getScoreColor(avgMood.round()),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Adesão (30d)',
                value: '${adherenceRate.toStringAsFixed(0)}%',
                icon: Icons.check_circle_outline,
                color: adherenceRate >= 70
                    ? AppColors.success
                    : adherenceRate >= 40
                        ? AppColors.warning
                        : AppColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Registros',
                value: '${entries.length}',
                icon: Icons.bar_chart,
                color: AppColors.psychologist,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                title: 'Evolução',
                value: evolutionText,
                icon: evolutionPositive
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: evolutionPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Alertas Clínicos ─────────────────────────────────────────────
        _SectionTitle(label: 'Alertas Clínicos'),
        const SizedBox(height: AppSpacing.md),
        _AlertCard(hasAlert: hasClinicalAlert),

        const SizedBox(height: AppSpacing.xl),

        // ── Histórico recente ────────────────────────────────────────────
        _SectionTitle(label: 'Últimos Registros'),
        const SizedBox(height: AppSpacing.md),
        ...entries.take(7).map(_EntryTile.new),
      ],
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
  });

  final String title;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    suffix!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.hasAlert});

  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    final color = hasAlert ? AppColors.error : AppColors.success;
    final bg = hasAlert ? AppColors.errorBg : AppColors.successBg;
    final icon = hasAlert ? Icons.warning_amber_rounded : Icons.verified;
    final message = hasAlert
        ? 'Humor baixo ou ansiedade elevada detectados nos últimos 7 dias. Considere uma intervenção.'
        : 'Nenhum alerta clínico relevante nos últimos registros.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry);

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${entry.createdAt.day.toString().padLeft(2, '0')}/'
        '${entry.createdAt.month.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Text(entry.moodEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.moodLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ansiedade ${entry.anxiety}/10  •  Energia ${entry.energy}/10',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.mood}/10',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: MoodEntry.getScoreColor(entry.mood),
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mood_bad_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Nenhum registro de humor ainda.',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}