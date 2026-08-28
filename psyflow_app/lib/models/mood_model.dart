import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoodEntry {
  final String id;
  final String patientId;
  final int mood; // 1-10
  final int anxiety; // 1-10
  final int energy; // 1-10
  final int sleepQuality; // 1-10
  final int stress; // 1-10
  final String? notes;
  final List<String> factors;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.patientId,
    required this.mood,
    required this.anxiety,
    required this.energy,
    this.sleepQuality = 5,
    this.stress = 5,
    this.notes,
    this.factors = const [],
    required this.createdAt,
  });

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    int parseScore(dynamic val, {int defaultValue = 5}) {
      if (val is num) {
        final v = val.toInt();
        // Retrocompatibilidade se era escala 1-5 antiga
        if (v >= 1 && v <= 5 && !map.containsKey('sleep_quality') && !map.containsKey('sleepQuality')) {
          return v * 2;
        }
        return v.clamp(1, 10);
      }
      return defaultValue;
    }

    List<String> parseFactors(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return MoodEntry(
      id: (map['id'] ?? '') as String,
      patientId: (map['patient_id'] ?? map['patientId'] ?? '') as String,
      mood: parseScore(map['mood'], defaultValue: 7),
      anxiety: parseScore(map['anxiety'], defaultValue: 4),
      energy: parseScore(map['energy'], defaultValue: 6),
      sleepQuality: parseScore(map['sleep_quality'] ?? map['sleepQuality'], defaultValue: 6),
      stress: parseScore(map['stress'], defaultValue: 5),
      notes: map['notes'] as String?,
      factors: parseFactors(map['factors']),
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'mood': mood,
      'anxiety': anxiety,
      'energy': energy,
      'sleep_quality': sleepQuality,
      'stress': stress,
      'notes': notes,
      'factors': factors,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // --- Helpers visuais para Humor (1 a 10) ---
  static const List<String> moodEmojis10 = [
    '😭', '😞', '🙁', '😕', '😐',
    '🙂', '😊', '😁', '😄', '🌟'
  ];

  static const List<String> moodLabels10 = [
    'Péssimo', 'Muito mal', 'Mal', 'Desanimado', 'Neutro',
    'Razoável', 'Bem', 'Muito bem', 'Ótimo', 'Radiante'
  ];

  String get moodEmoji => mood >= 1 && mood <= 10 ? moodEmojis10[mood - 1] : '😐';
  String get moodLabel => mood >= 1 && mood <= 10 ? moodLabels10[mood - 1] : 'Neutro';

  // --- Helpers visuais para Ansiedade (1 a 10) ---
  String get anxietyLabel {
    if (anxiety <= 2) return 'Muito calmo';
    if (anxiety <= 4) return 'Tranquilo';
    if (anxiety <= 6) return 'Moderada';
    if (anxiety <= 8) return 'Alta';
    return 'Muito intensa';
  }

  String get anxietyEmoji {
    if (anxiety <= 2) return '😌';
    if (anxiety <= 4) return '🙂';
    if (anxiety <= 6) return '😐';
    if (anxiety <= 8) return '😰';
    return '🤯';
  }

  // --- Helpers visuais para Sono (1 a 10) ---
  String get sleepLabel {
    if (sleepQuality <= 2) return 'Péssima noite';
    if (sleepQuality <= 4) return 'Ruim';
    if (sleepQuality <= 6) return 'Razoável';
    if (sleepQuality <= 8) return 'Boa noite';
    return 'Excelente reparador';
  }

  String get sleepEmoji {
    if (sleepQuality <= 2) return '🥱';
    if (sleepQuality <= 4) return '😵‍💫';
    if (sleepQuality <= 6) return '😴';
    if (sleepQuality <= 8) return '🛌';
    return '✨';
  }

  // --- Helpers visuais para Energia (1 a 10) ---
  String get energyLabel {
    if (energy <= 2) return 'Exausto';
    if (energy <= 4) return 'Baixa';
    if (energy <= 6) return 'Moderada';
    if (energy <= 8) return 'Disposto';
    return 'Cheio de energia';
  }

  String get energyEmoji {
    if (energy <= 2) return '🪫';
    if (energy <= 4) return '🥱';
    if (energy <= 6) return '🔋';
    if (energy <= 8) return '⚡';
    return '🔥';
  }

  // --- Helpers visuais para Estresse (1 a 10) ---
  String get stressLabel {
    if (stress <= 2) return 'Sem estresse';
    if (stress <= 4) return 'Leve';
    if (stress <= 6) return 'Moderado';
    if (stress <= 8) return 'Elevado';
    return 'Crítico';
  }

  static Color getScoreColor(int score, {bool inverse = false}) {
    // Para humor/energia/sono: 10 é verde, 1 é vermelho
    // Para ansiedade/estresse: 10 é vermelho, 1 é verde (inverse = true)
    final val = inverse ? (11 - score) : score;
    if (val >= 8) return const Color(0xFF10B981);
    if (val >= 6) return const Color(0xFF3B82F6);
    if (val >= 4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
