import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Item de Emoção com intensidade inicial e final (pós-reestruturação)
class EmotionIntensityItem {
  final String name;
  final String emoji;
  final int initialIntensity; // 0 a 100%
  final int? finalIntensity; // 0 a 100% após a resposta racional

  const EmotionIntensityItem({
    required this.name,
    required this.emoji,
    required this.initialIntensity,
    this.finalIntensity,
  });

  int get reliefPercentage {
    if (finalIntensity == null) return 0;
    final diff = initialIntensity - finalIntensity!;
    return diff > 0 ? diff : 0;
  }

  factory EmotionIntensityItem.fromMap(Map<String, dynamic> map) {
    return EmotionIntensityItem(
      name: map['name']?.toString() ?? '',
      emoji: map['emoji']?.toString() ?? '😐',
      initialIntensity: (map['initial_intensity'] as num?)?.toInt() ?? 50,
      finalIntensity: (map['final_intensity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'initial_intensity': initialIntensity,
      'final_intensity': finalIntensity,
    };
  }
}

/// Catálogo didático de Emoções da TCC
class PrimaryEmotionsCatalog {
  static const List<Map<String, dynamic>> all = [
    {'name': 'Ansiedade', 'emoji': '😰', 'color': Color(0xFFF59E0B)},
    {'name': 'Tristeza', 'emoji': '😢', 'color': Color(0xFF3B82F6)},
    {'name': 'Raiva', 'emoji': '😡', 'color': Color(0xFFEF4444)},
    {'name': 'Medo', 'emoji': '😨', 'color': Color(0xFF8B5CF6)},
    {'name': 'Culpa', 'emoji': '😔', 'color': Color(0xFF6B7280)},
    {'name': 'Vergonha', 'emoji': '😳', 'color': Color(0xFFEC4899)},
    {'name': 'Frustração', 'emoji': '😤', 'color': Color(0xFFF97316)},
    {'name': 'Desesperança', 'emoji': '😞', 'color': Color(0xFF475569)},
    {'name': 'Insegurança', 'emoji': '🥺', 'color': Color(0xFF64748B)},
    {'name': 'Alegria', 'emoji': '😄', 'color': Color(0xFF10B981)},
    {'name': 'Alívio', 'emoji': '😌', 'color': Color(0xFF06B6D4)},
    {'name': 'Gratidão', 'emoji': '🙏', 'color': Color(0xFF14B8A6)},
  ];
}

/// Informação didática sobre uma Distorção Cognitiva da TCC
class CognitiveDistortionInfo {
  final String id;
  final String title;
  final String shortName;
  final String description;
  final String example;
  final IconData icon;

  const CognitiveDistortionInfo({
    required this.id,
    required this.title,
    required this.shortName,
    required this.description,
    required this.example,
    required this.icon,
  });
}

/// Catálogo das 10 principais Distorções Cognitivas da TCC
class CognitiveDistortionCatalog {
  static const List<CognitiveDistortionInfo> all = [
    CognitiveDistortionInfo(
      id: 'catastrofizacao',
      title: 'Catastrofização (Prever o Pior)',
      shortName: 'Catastrofização',
      description: 'Acreditar que o pior cenário possível certamente vai acontecer, sem considerar outras probabilidades mais realistas.',
      example: '"Se eu errar essa apresentação, serei demitido e minha carreira estará arruinada."',
      icon: Icons.thunderstorm_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'leitura_mental',
      title: 'Leitura Mental',
      shortName: 'Leitura Mental',
      description: 'Presumir saber exatamente o que as outras pessoas estão pensando sobre você, geralmente de forma negativa e sem evidências.',
      example: '"Ele não me respondeu no WhatsApp porque com certeza está com raiva de mim."',
      icon: Icons.psychology_alt_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'tudo_ou_nada',
      title: 'Pensamento Tudo-ou-Nada (8 ou 80)',
      shortName: 'Tudo-ou-Nada',
      description: 'Avaliar as situações em termos de preto ou branco, sucesso absoluto ou fracasso total, sem meio-termo.',
      example: '"Se eu não fizer com perfeição, então não valeu nada."',
      icon: Icons.compare_arrows_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'raciocinio_emocional',
      title: 'Raciocínio Emocional',
      shortName: 'Raciocínio Emocional',
      description: 'Acreditar que algo é verdade simplesmente porque você está sentindo aquilo intensamente.',
      example: '"Sinto que sou incompetente, portanto eu devo ser mesmo incompetente."',
      icon: Icons.favorite_border_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'desqualificacao_positivo',
      title: 'Desqualificação do Positivo',
      shortName: 'Desqualificar Positivo',
      description: 'Transformar experiências neutras ou positivas em algo insignificante ou sem valor.',
      example: '"Eles só elogiaram o meu trabalho por pura educação."',
      icon: Icons.highlight_off_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'supergeneralizacao',
      title: 'Supergeneralização',
      shortName: 'Supergeneralização',
      description: 'Concluir que um evento negativo isolado é um padrão que continuará se repetindo para sempre.',
      example: '"Nada dá certo na minha vida. Eu sempre fracasso nisso."',
      icon: Icons.all_inclusive_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'rotulacao',
      title: 'Rotulação Global',
      shortName: 'Rotulação',
      description: 'Colocar um rótulo rígido e depreciativo em si mesmo ou nos outros com base em um único comportamento.',
      example: '"Eu cometi um erro, logo sou um idiota/inútil."',
      icon: Icons.label_important_outline_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'personalizacao',
      title: 'Personalização / Culpa',
      shortName: 'Personalização',
      description: 'Assumir a culpa ou responsabilidade excessiva por eventos negativos fora do seu controle total.',
      example: '"O almoço em família foi tenso por minha causa."',
      icon: Icons.person_off_outlined,
    ),
    CognitiveDistortionInfo(
      id: 'deveria_tenho_que',
      title: 'Afirmações do Tipo "Deveria" e "Tenho que"',
      shortName: 'Tiranização do Dever',
      description: 'Regras rígidas e inflexíveis sobre como você e os outros deveriam se comportar.',
      example: '"Eu nunca deveria demonstrar fraqueza ou ansiedade."',
      icon: Icons.rule_rounded,
    ),
    CognitiveDistortionInfo(
      id: 'filtro_mental',
      title: 'Filtro Mental Negativo',
      shortName: 'Filtro Mental',
      description: 'Focar exclusivamente em um detalhe negativo, ignorando todo o restante positivo ou neutro da experiência.',
      example: '"O evento foi ótimo, mas aquela pessoa fez uma cara feia, então o dia foi péssimo."',
      icon: Icons.filter_alt_off_rounded,
    ),
  ];

  static CognitiveDistortionInfo? findById(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Modelo Completo do Registro de Pensamento Disfuncional (RPD)
class ThoughtRecordEntry {
  final String id;
  final String patientId;
  final String? patientName;
  final DateTime createdAt;

  // 1. Situação / Contexto / Gatilho
  final String situation;
  final String? location;
  final String? trigger;

  // 2. Emoções
  final List<EmotionIntensityItem> emotions;

  // 3. Pensamentos Automáticos
  final String automaticThought;
  final int beliefInitial; // 0 a 100%

  // 4. Distorções Cognitivas
  final List<String> cognitiveDistortions;

  // 5. Exame de Evidências
  final String? evidenceFor; // Evidências que apoiam
  final String? evidenceAgainst; // Evidências contrárias

  // 6. Resposta Racional / Reestruturação
  final String rationalResponse;
  final int? beliefFinal; // 0 a 100% de crença no pensamento inicial pós-resposta

  // 7. Emoções Reavaliadas
  final List<EmotionIntensityItem> emotionsAfter;

  // 8. Comportamento / Ação
  final String? behavior;

  // 9. Fatores / Tags contextuais
  final List<String> tags;

  const ThoughtRecordEntry({
    required this.id,
    required this.patientId,
    this.patientName,
    required this.createdAt,
    required this.situation,
    this.location,
    this.trigger,
    required this.emotions,
    required this.automaticThought,
    this.beliefInitial = 80,
    required this.cognitiveDistortions,
    this.evidenceFor,
    this.evidenceAgainst,
    required this.rationalResponse,
    this.beliefFinal,
    this.emotionsAfter = const [],
    this.behavior,
    this.tags = const [],
  });

  /// Retorna o alívio emocional médio obtido neste RPD (%)
  int get averageRelief {
    if (emotions.isEmpty) return 0;
    int totalDiff = 0;
    int count = 0;

    for (final eInitial in emotions) {
      final eAfter = emotionsAfter.firstWhere(
        (a) => a.name == eInitial.name,
        orElse: () => EmotionIntensityItem(
          name: eInitial.name,
          emoji: eInitial.emoji,
          initialIntensity: eInitial.initialIntensity,
          finalIntensity: eInitial.finalIntensity,
        ),
      );
      if (eAfter.finalIntensity != null) {
        final diff = eInitial.initialIntensity - eAfter.finalIntensity!;
        totalDiff += diff;
        count++;
      }
    }

    if (count == 0 && beliefFinal != null) {
      return (beliefInitial - beliefFinal!).clamp(0, 100);
    }

    return count > 0 ? (totalDiff / count).round().clamp(0, 100) : 0;
  }

  factory ThoughtRecordEntry.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    List<EmotionIntensityItem> parseEmotions(dynamic val) {
      if (val is List) {
        return val.map((e) {
          if (e is Map<String, dynamic>) return EmotionIntensityItem.fromMap(e);
          if (e is Map) return EmotionIntensityItem.fromMap(Map<String, dynamic>.from(e));
          return EmotionIntensityItem(name: e.toString(), emoji: '😐', initialIntensity: 50);
        }).toList();
      }
      return const [];
    }

    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return const [];
    }

    return ThoughtRecordEntry(
      id: id,
      patientId: map['patient_id']?.toString() ?? '',
      patientName: map['patient_name']?.toString(),
      createdAt: parseDate(map['created_at']),
      situation: map['situation']?.toString() ?? '',
      location: map['location']?.toString(),
      trigger: map['trigger']?.toString(),
      emotions: parseEmotions(map['emotions']),
      automaticThought: map['automatic_thought']?.toString() ?? '',
      beliefInitial: (map['belief_initial'] as num?)?.toInt() ?? 80,
      cognitiveDistortions: parseList(map['cognitive_distortions']),
      evidenceFor: map['evidence_for']?.toString(),
      evidenceAgainst: map['evidence_against']?.toString(),
      rationalResponse: map['rational_response']?.toString() ?? '',
      beliefFinal: (map['belief_final'] as num?)?.toInt(),
      emotionsAfter: parseEmotions(map['emotions_after']),
      behavior: map['behavior']?.toString(),
      tags: parseList(map['tags']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'patient_name': patientName,
      'created_at': Timestamp.fromDate(createdAt),
      'situation': situation,
      'location': location,
      'trigger': trigger,
      'emotions': emotions.map((e) => e.toMap()).toList(),
      'automatic_thought': automaticThought,
      'belief_initial': beliefInitial,
      'cognitive_distortions': cognitiveDistortions,
      'evidence_for': evidenceFor,
      'evidence_against': evidenceAgainst,
      'rational_response': rationalResponse,
      'belief_final': beliefFinal,
      'emotions_after': emotionsAfter.map((e) => e.toMap()).toList(),
      'behavior': behavior,
      'tags': tags,
    };
  }
}
