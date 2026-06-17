import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmotionalMapPage extends StatefulWidget {
  const EmotionalMapPage({super.key});

  @override
  State<EmotionalMapPage> createState() =>
      _EmotionalMapPageState();
}

class _EmotionalMapPageState
    extends State<EmotionalMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Mapa Emocional',
        ),
        backgroundColor: AppColors.psychologist,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Row(
            children: [

              Expanded(
                child: _StatCard(
                  title: 'Humor Médio',
                  value: '7.4',
                  icon: Icons.mood,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  title: 'Adesão',
                  value: '82%',
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [

              Expanded(
                child: _StatCard(
                  title: 'Concluídas',
                  value: '15',
                  icon: Icons.task_alt,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _StatCard(
                  title: 'Evolução',
                  value: '+18%',
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Alertas Clínicos',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Colors.green,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nenhum alerta clínico relevante.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [

          Icon(
            icon,
            color: AppColors.psychologist,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}