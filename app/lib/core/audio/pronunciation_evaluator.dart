import '../models/api_models.dart';
import '../network/api_client.dart';
import 'pronunciation_queue_service.dart';
import '../pedagogy/practice_service.dart';

/// Estado de una evaluación de pronunciación, común a TODA la app.
enum PronEvalStatus {
  /// El servidor evaluó en vivo (hay resultado real).
  success,

  /// No se pudo evaluar en vivo (timeout/red) pero se guardó en la cola
  /// offline: se evaluará al reconectar.
  offline,

  /// No se pudo evaluar NI guardar en la cola (fallo duro).
  error,
}

/// Resultado unificado de evaluar una pronunciación. `result` SIEMPRE viene
/// relleno: con la evaluación real (success) o con un marcador estándar
/// (offline/error) que las pantallas pueden mostrar tal cual.
class PronEvalOutcome {
  final PronunciationResult result;
  final PronEvalStatus status;
  final bool enqueued;

  const PronEvalOutcome(this.result, this.status, this.enqueued);

  bool get isLive => status == PronEvalStatus.success;
  bool get isOffline => status == PronEvalStatus.offline;
  bool get isError => status == PronEvalStatus.error;

  /// La STT reconoció texto y hay evaluación aprovechable.
  bool get sttOk =>
      isLive && result.sttOk && result.recognized_text.trim().isNotEmpty;
}

/// Servicio ÚNICO de evaluación de pronunciación para toda la app.
///
/// Antes cada pantalla (vocabulario, gramática, verbos, phrasals, comprensión,
/// tarjetas…) tenía su propia copia del try/checkPronunciation/catch/enqueue,
/// y divergían: algunas encolaban offline y avisaban, otras fallaban en
/// silencio, otras tenían timeouts distintos. Esto lo centraliza:
///   - una sola llamada a checkPronunciation (con el timeout de api_client),
///   - una sola política de cola offline ante fallo,
///   - un marcador de resultado estándar (mismo texto y feedback en toda la app).
///
/// Cada pantalla solo tiene que llamar a [evaluate] y pintar el [PronEvalOutcome]
/// con su propia UI. Un cambio de comportamiento futuro se toca AQUÍ, una vez.
class PronunciationEvaluator {
  final ApiClient _api;
  final PronunciationQueueService _queue;
  final PracticeService _practice;

  PronunciationEvaluator(this._api, this._queue, this._practice);

  Future<PronEvalOutcome> evaluate({
    required String audioPath,
    required String expectedTerm,
    String? expectedIpa,
    required String userId,
    required String section,
    required String exerciseType,
    String? category,
    bool withTip = false,
  }) async {
    // Marca la racha del día: cualquier intento de pronunciación cuenta, en un
    // único sitio para las 8 pantallas (online u offline).
    // ignore: unawaited_futures
    _practice.registerActivityDay(userId);
    try {
      final res = await _api.checkPronunciation(
        audioPath: audioPath,
        expectedTerm: expectedTerm,
        expectedIpa: expectedIpa,
        userId: userId,
        exerciseType: exerciseType,
        category: category,
        withTip: withTip,
      );
      return PronEvalOutcome(res, PronEvalStatus.success, false);
    } catch (_) {
      // Fallo real (timeout/red): intentamos guardar en la cola offline SIEMPRE,
      // de forma consistente en todas las pantallas.
      bool enqueued = false;
      try {
        enqueued = await _queue.enqueue(
          section: section,
          audioPath: audioPath,
          expectedTerm: expectedTerm,
          expectedIpa: expectedIpa,
          userId: userId,
          exerciseType: exerciseType,
          category: category,
        );
      } catch (_) {
        enqueued = false;
      }

      final placeholder = PronunciationResult(
        expected_term: expectedTerm,
        recognized_text: enqueued ? 'Guardado offline' : 'Sin conexión',
        score: -1,
        is_match: false,
        feedback: enqueued
            ? 'Audio guardado offline. Se evaluará automáticamente al reconectar.'
            : 'No se pudo evaluar ni guardar. Revisa tu conexión e inténtalo de nuevo.',
        sttOk: false,
        engineUsed: 'offline_queue',
      );
      return PronEvalOutcome(
        placeholder,
        enqueued ? PronEvalStatus.offline : PronEvalStatus.error,
        enqueued,
      );
    }
  }
}
