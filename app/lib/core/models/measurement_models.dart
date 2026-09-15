// Modelos de medidas de voz (comparacion baseline "Dia 1 vs Hoy" y resumen de perfil).
// Disenado para ser extensible: cualquier metrica nueva se transporta con su metricKey
// y campos genericos, sin cambiar estos modelos.

double _asDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
double? _asDoubleN(dynamic v) => (v as num?)?.toDouble();
DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}

class MeasurementComparison {
  final bool hasBaseline;
  final bool isInitial;
  final String? zone;
  final String? targetType;
  final String? targetId;
  final String? metricKey;
  final String? label;
  final int attempts;

  final double baselineValue;
  final String? baselineAudioUrl;
  final DateTime? baselineCreatedAt;

  final double latestValue;
  final String? latestAudioUrl;
  final DateTime? latestUpdatedAt;

  final double? bestValue;
  final String? bestAudioUrl;

  final double deltaValue;

  const MeasurementComparison({
    this.hasBaseline = true,
    this.isInitial = false,
    this.zone,
    this.targetType,
    this.targetId,
    this.metricKey,
    this.label,
    this.attempts = 0,
    this.baselineValue = 0.0,
    this.baselineAudioUrl,
    this.baselineCreatedAt,
    this.latestValue = 0.0,
    this.latestAudioUrl,
    this.latestUpdatedAt,
    this.bestValue,
    this.bestAudioUrl,
    this.deltaValue = 0.0,
  });

  /// True cuando ya hay al menos un intento posterior al Día 1 (hay algo que comparar).
  bool get hasProgress => attempts > 1 && latestUpdatedAt != null;

  factory MeasurementComparison.fromJson(Map<String, dynamic> j) {
    return MeasurementComparison(
      hasBaseline: j['has_baseline'] as bool? ?? true,
      isInitial: j['is_initial'] as bool? ?? false,
      zone: j['zone'] as String?,
      targetType: j['target_type'] as String?,
      targetId: j['target_id'] as String?,
      metricKey: j['metric_key'] as String?,
      label: j['label'] as String?,
      attempts: (j['attempts'] as num?)?.toInt() ?? 0,
      baselineValue: _asDouble(j['baseline_value']),
      baselineAudioUrl: j['baseline_audio_url'] as String?,
      baselineCreatedAt: _asDate(j['baseline_created_at']),
      latestValue: _asDouble(j['latest_value']),
      latestAudioUrl: j['latest_audio_url'] as String?,
      latestUpdatedAt: _asDate(j['latest_updated_at']),
      bestValue: _asDoubleN(j['best_value']),
      bestAudioUrl: j['best_audio_url'] as String?,
      deltaValue: _asDouble(j['delta_value']),
    );
  }
}

class MeasurementProfileEntry {
  final String zone;
  final String metricKey;
  final int targets;
  final double avgLatest;
  final double avgDelta;
  final List<MeasurementComparison> topImprovements;

  const MeasurementProfileEntry({
    required this.zone,
    required this.metricKey,
    required this.targets,
    required this.avgLatest,
    required this.avgDelta,
    required this.topImprovements,
  });

  factory MeasurementProfileEntry.fromJson(Map<String, dynamic> j) {
    final rawItems = (j['top_improvements'] as List?) ?? const [];
    return MeasurementProfileEntry(
      zone: j['zone'] as String? ?? '',
      metricKey: j['metric_key'] as String? ?? '',
      targets: (j['targets'] as num?)?.toInt() ?? 0,
      avgLatest: _asDouble(j['avg_latest']),
      avgDelta: _asDouble(j['avg_delta']),
      topImprovements: rawItems
          .map((e) => MeasurementComparison.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
