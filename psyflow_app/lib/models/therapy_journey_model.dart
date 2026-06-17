class TherapyJourney {
  final String id;
  final String protocol;
  final int currentPhase;
  final int totalPhases;

  const TherapyJourney({
    required this.id,
    required this.protocol,
    required this.currentPhase,
    required this.totalPhases,
  });

  factory TherapyJourney.fromMap(
    Map<String, dynamic> map,
  ) {
    return TherapyJourney(
      id: map['id'],
      protocol: map['protocol'],
      currentPhase: map['current_phase'],
      totalPhases: map['total_phases'],
    );
  }
}