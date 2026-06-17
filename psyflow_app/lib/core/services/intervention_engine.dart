import '../../models/intervention_template.dart';

class InterventionEngine {
  const InterventionEngine();

  String? getNextIntervention({
    required InterventionTemplate current,
    required int completionScore,
  }) {
    if (
      completionScore >=
      current.successThreshold
    ) {
      return current.nextSuccessCode;
    }

    if (
      completionScore <=
      current.failureThreshold
    ) {
      return current.nextFailureCode;
    }

    return current.interventionCode;
  }
}