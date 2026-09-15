import '../network/api_client.dart';
import '../storage/local_cache_service.dart';
import '../models/measurement_models.dart';
import '../constants/app_constants.dart';

/// Zonas donde el usuario graba su voz. Añadir una zona nueva = una constante nueva aquí.
class MeasurementZones {
  static const String vocabulary = 'vocabulary';
  static const String grammar = 'grammar';
  static const String comprehension = 'comprehension';
  static const String interview = 'interview';

  static String label(String zone) {
    switch (zone) {
      case vocabulary:
        return 'Vocabulario';
      case grammar:
        return 'Gramática';
      case comprehension:
        return 'Comprensión';
      case interview:
        return 'Entrevista';
      default:
        return zone.isEmpty ? 'General' : zone[0].toUpperCase() + zone.substring(1);
    }
  }
}

/// Metadatos de presentación de una métrica.
class MeasurementMetric {
  final String key;
  final String label;
  final String unit;
  final bool higherIsBetter;
  const MeasurementMetric(this.key, this.label, {this.unit = 'pts', this.higherIsBetter = true});
}

/// Registro extensible de métricas. Para soportar una métrica futura (p.ej. pitch/F0 o
/// fluidez) basta con añadir su constante y una entrada aquí: la UI la mostrará sola.
class MeasurementMetrics {
  static const String pronunciationGop = 'pronunciation_gop';
  static const String speakingScore = 'speaking_score';

  static const Map<String, MeasurementMetric> registry = {
    pronunciationGop: MeasurementMetric(pronunciationGop, 'Pronunciación'),
    speakingScore: MeasurementMetric(speakingScore, 'Speaking'),
    // Ejemplos futuros (ya soportados por el backend sin migración):
    'pitch_similarity': MeasurementMetric('pitch_similarity', 'Entonación', unit: '%'),
    // 'fluency_score': MeasurementMetric('fluency_score', 'Fluidez'),
  };

  static MeasurementMetric describe(String? key) {
    if (key == null || key.isEmpty) return const MeasurementMetric('', 'Medida');
    return registry[key] ?? MeasurementMetric(key, key);
  }
}

/// Servicio central reutilizado por TODAS las zonas de grabación. Best-effort:
/// nunca lanza ni bloquea la práctica; si no hay red devuelve null.
class MeasurementService {
  final ApiClient _api;
  final LocalCacheService _cache;

  MeasurementService(this._api, this._cache);

  Future<MeasurementComparison?> record({
    required String userId,
    required String zone,
    required String targetId,
    required String metricKey,
    required double value,
    String targetType = 'word',
    String? audioUrl,
    String? label,
    Map<String, dynamic>? extra,
  }) {
    if (userId.trim().isEmpty || targetId.trim().isEmpty) {
      return Future.value(null);
    }
    return _api.recordMeasurement(
      userId: userId,
      zone: zone,
      targetId: targetId,
      metricKey: metricKey,
      value: value,
      targetType: targetType,
      audioUrl: audioUrl,
      label: label,
      extra: extra,
    );
  }

  Future<MeasurementComparison?> comparison({
    required String userId,
    required String zone,
    required String targetId,
    String metricKey = MeasurementMetrics.pronunciationGop,
  }) {
    return _api.getMeasurementBaseline(
      userId: userId,
      zone: zone,
      targetId: targetId,
      metricKey: metricKey,
    );
  }

  Future<List<MeasurementProfileEntry>> profile(String userId) => _api.getMeasurementProfile(userId);

  /// Convierte una ruta '/audio/...' del backend en una URL absoluta reproducible por just_audio.
  Future<String?> resolveAudioUrl(String? path) async {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    String base = '';
    try {
      base = await _cache.getBaseUrl();
    } catch (_) {}
    if (base.isEmpty) base = AppConstants.defaultBaseUrl;
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    final rel = path.startsWith('/') ? path : '/$path';
    return '$base$rel';
  }
}
