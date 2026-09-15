import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_client.dart';
import 'voice_selection.dart';

/// Servicio central de PREFETCH de audio neural ("modelo pro").
///
/// Objetivo: que al entrar en cualquier pantalla (vocabulario, gramática,
/// entrevista, inmersión, phrasal/irregular verbs, laboratorio fonético) el
/// audio del NAS ya esté generado, para que el primer play sea instantáneo y
/// nunca caiga al TTS nativo del dispositivo ("voz mala"). Sensación premium.
///
/// Diseño robusto:
///  - Idempotente y no bloqueante: se llama con fire-and-forget desde la UI.
///  - Dedupe en memoria por sesión: solo marca "hecho" tras éxito, así un fallo
///    puntual (offline) se reintenta al reentrar, sin machacar el backend.
///  - Timeout propio y generoso (el ApiClient global usa 5s, insuficiente para
///    sintetizar en frío) + lotes pequeños para acotar cada petición.
///  - Silencioso ante errores/offline: jamás rompe la pantalla que lo invoca.
///  - Reutiliza el ApiClient (base URL dinámica + auth).
class AudioPrefetchService {
  AudioPrefetchService(this._api);

  final ApiClient _api;

  /// Claves ya generadas con éxito en esta sesión (voice|rate|texto).
  final Set<String> _done = <String>{};

  static const String _defaultVoice = 'en-US-GuyNeural';
  static const int _batchSize = 24;
  static const int _maxDedupeEntries = 8000;

  /// Pre-genera en el NAS el audio de [texts].
  ///
  /// [includeSlow] añade también la variante lenta (-20%) que usan los botones
  /// "slow" de las pantallas de práctica.
  void warm(
    Iterable<String> texts, {
    bool includeSlow = true,
    String voice = _defaultVoice,
  }) {
    unawaited(_warm(texts, includeSlow: includeSlow, voice: voice));
  }

  Future<void> _warm(
    Iterable<String> texts, {
    required bool includeSlow,
    required String voice,
  }) async {
    try {
      // 1) Normalizar + dedupe de textos.
      final seen = <String>{};
      final clean = <String>[];
      for (final raw in texts) {
        final t = raw.trim();
        if (t.isEmpty || t.length > 1400) continue;
        if (seen.add(t.toLowerCase())) clean.add(t);
      }
      if (clean.isEmpty) return;

      // 2) Construir items pendientes (los que aún no se generaron con éxito).
      final rates = includeSlow ? const ['+0%', '-20%'] : const ['+0%'];
      final pending = <Map<String, String>>[];
      for (final t in clean) {
        final v = AppVoices.resolve(voice, t);
        for (final r in rates) {
          if (!_done.contains('$v|$r|$t')) {
            pending.add({'text': t, 'voice': v, 'rate': r});
          }
        }
      }
      if (pending.isEmpty) return;

      // 3) Enviar en lotes con timeout propio. Solo se marca "hecho" tras éxito.
      for (var i = 0; i < pending.length; i += _batchSize) {
        final slice = pending.sublist(
          i,
          (i + _batchSize < pending.length) ? i + _batchSize : pending.length,
        );
        try {
          await _api.dio.post(
            '/api/tts/prefetch',
            data: {'items': slice, 'max_concurrency': 4},
            options: Options(
              receiveTimeout: const Duration(seconds: 90),
              sendTimeout: const Duration(seconds: 30),
            ),
          );
          for (final it in slice) {
            _done.add('${it['voice']}|${it['rate']}|${it['text']}');
          }
        } catch (e) {
          // Offline o backend ocupado: no se marca; se reintentará al reentrar.
          // El primer play real generará y cacheará igualmente ese término.
          if (kDebugMode) debugPrint('AudioPrefetch lote falló (se reintentará): $e');
          return;
        }
      }

      // 4) Evitar crecimiento ilimitado del set en sesiones muy largas.
      if (_done.length > _maxDedupeEntries) _done.clear();
    } catch (e) {
      if (kDebugMode) debugPrint('AudioPrefetch error: $e');
    }
  }
}
