/// Resultado del comparador de entonacion (Pitch F0): curva del alumno y, si hay
/// texto objetivo, curva nativa de referencia + similitud 0..100.
class PitchComparison {
  final bool ok;
  final bool available;
  final double? similarity; // null si no hay referencia (p.ej. entrevista libre)
  final List<double> userCurve;
  final List<double> refCurve;
  final String? reason;

  const PitchComparison({
    required this.ok,
    required this.available,
    this.similarity,
    this.userCurve = const [],
    this.refCurve = const [],
    this.reason,
  });

  bool get hasReference => refCurve.isNotEmpty;

  factory PitchComparison.fromJson(Map<String, dynamic> j) {
    List<double> curve(dynamic v) =>
        (v as List?)?.map((e) => (e as num).toDouble()).toList() ?? const [];
    return PitchComparison(
      ok: j['ok'] as bool? ?? false,
      available: j['available'] as bool? ?? false,
      similarity: (j['similarity'] as num?)?.toDouble(),
      userCurve: curve(j['user_curve']),
      refCurve: curve(j['ref_curve']),
      reason: j['reason'] as String?,
    );
  }
}
