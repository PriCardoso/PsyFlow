import 'package:flutter/material.dart';

class TherapyJourneyPage extends StatelessWidget {
  const TherapyJourneyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Jornada',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          _step(
            'Semana 1',
            'Psicoeducação',
            true,
          ),

          _step(
            'Semana 2',
            'Monitoramento Emocional',
            true,
          ),

          _step(
            'Semana 3',
            'Pensamentos Automáticos',
            false,
          ),

          _step(
            'Semana 4',
            'Reestruturação Cognitiva',
            false,
          ),
        ],
      ),
    );
  }

  Widget _step(
    String title,
    String subtitle,
    bool completed,
  ) {
    return ListTile(
      leading: Icon(
        completed
            ? Icons.check_circle
            : Icons.lock_outline,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}