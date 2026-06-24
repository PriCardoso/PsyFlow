
class PsychologistSummary {
  final String id;
  final String fullName;
  final String modality;

  PsychologistSummary({
    required this.id,
    required this.fullName,
    required this.modality,
  });

  factory PsychologistSummary.fromMap(Map<String, dynamic> map) {
    return PsychologistSummary(
      id: map['id'],
      fullName: map['full_name'],
      modality: map['modality'] ?? 'both',
    );
  }
}
