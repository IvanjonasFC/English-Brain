/// ai_service.dart
/// Servicio central de IA para toda la app.
///
/// Funcionalidades:
///   - Corrección gramatical con feedback pedagógico en español
///   - Lookup de vocabulario con IPA, ejemplos y truco mnemotécnico
///   - Análisis de audio (STT + LLM) para dictado, shadowing, pronunciación
///   - Cache local con TTL 5min para respuestas rápidas offline-first
///   - `Stream<AiFeedbackState>` para UX premium (shimmer → resultado)
///   - Rating positivo/negativo que alimenta el bucle de auto-aprendizaje del backend
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/api_client.dart';
import '../models/api_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State types
// ─────────────────────────────────────────────────────────────────────────────

enum AiFeedbackStatus { idle, loading, success, offline, error }

class AiFeedbackState {
  final AiFeedbackStatus status;
  final dynamic data; // GrammarResult | VocabularyResult | AudioAnalysisResult | String
  final String? errorMessage;
  final String engineUsed; // "fast" (GPU) | "standard" (fallback)
  final double? tokensPerSec;
  final double? latencyMs;

  const AiFeedbackState({
    required this.status,
    this.data,
    this.errorMessage,
    this.engineUsed = 'standard',
    this.tokensPerSec,
    this.latencyMs,
  });

  static const idle = AiFeedbackState(status: AiFeedbackStatus.idle);
  static const loading = AiFeedbackState(status: AiFeedbackStatus.loading);

  bool get isLoading => status == AiFeedbackStatus.loading;
  bool get isSuccess => status == AiFeedbackStatus.success;
  bool get isOffline => status == AiFeedbackStatus.offline;
  bool get isGpu => engineUsed == 'fast';
}

// ─────────────────────────────────────────────────────────────────────────────
// Result models
// ─────────────────────────────────────────────────────────────────────────────

class GrammarResult {
  final bool hasErrors;
  final String original;
  final String? corrected;
  final String? errorType;
  final String? explanation;
  final String? exampleCorrect;
  final String? cefrLevel;
  final String engineUsed;

  const GrammarResult({
    required this.hasErrors,
    required this.original,
    this.corrected,
    this.errorType,
    this.explanation,
    this.exampleCorrect,
    this.cefrLevel,
    this.engineUsed = 'fast',
  });

  factory GrammarResult.fromJson(Map<String, dynamic> json) => GrammarResult(
        hasErrors: json['has_errors'] as bool? ?? false,
        original: json['original'] as String? ?? '',
        corrected: json['corrected'] as String?,
        errorType: json['error_type'] as String?,
        explanation: json['explanation'] as String?,
        exampleCorrect: json['example_correct'] as String?,
        cefrLevel: json['cefr_level'] as String?,
        engineUsed: json['engine_used'] as String? ?? 'fast',
      );

  GrammarResult offline() => GrammarResult(
        hasErrors: false,
        original: original,
        explanation: 'Worker GPU offline. Conéctate para obtener corrección detallada.',
        engineUsed: 'standard',
      );
}

class VocabularyResult {
  final String word;
  final String? ipa;
  final String translation;
  final String? cefrLevel;
  final String definition;
  final List<String> examples;
  final List<String> synonyms;
  final List<String> collocations;
  final String? memoryTip;
  final String engineUsed;

  const VocabularyResult({
    required this.word,
    this.ipa,
    required this.translation,
    this.cefrLevel,
    required this.definition,
    this.examples = const [],
    this.synonyms = const [],
    this.collocations = const [],
    this.memoryTip,
    this.engineUsed = 'fast',
  });

  factory VocabularyResult.fromJson(Map<String, dynamic> json) => VocabularyResult(
        word: json['word'] as String? ?? '',
        ipa: json['ipa'] as String?,
        translation: json['translation'] as String? ?? '',
        cefrLevel: json['cefr_level'] as String?,
        definition: json['definition'] as String? ?? '',
        examples: List<String>.from(json['examples'] as List? ?? []),
        synonyms: List<String>.from(json['synonyms'] as List? ?? []),
        collocations: List<String>.from(json['collocations'] as List? ?? []),
        memoryTip: json['memory_tip'] as String?,
        engineUsed: json['engine_used'] as String? ?? 'fast',
      );
}

class AudioAnalysisResult {
  final String transcript;
  final List<Map<String, dynamic>> grammarErrors;
  final List<String> pronunciationIssues;
  final int fluencyScore;
  final String? vocabularyLevel;
  final String feedback;
  final List<String> strengths;
  final List<String> improvements;
  final String engineUsed;

  const AudioAnalysisResult({
    required this.transcript,
    this.grammarErrors = const [],
    this.pronunciationIssues = const [],
    this.fluencyScore = 0,
    this.vocabularyLevel,
    required this.feedback,
    this.strengths = const [],
    this.improvements = const [],
    this.engineUsed = 'fast',
  });

  factory AudioAnalysisResult.fromJson(Map<String, dynamic> json) => AudioAnalysisResult(
        transcript: json['transcript'] as String? ?? '',
        grammarErrors: List<Map<String, dynamic>>.from(
          (json['grammar_errors'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
        ),
        pronunciationIssues: List<String>.from(json['pronunciation_issues'] as List? ?? []),
        fluencyScore: json['fluency_score'] as int? ?? 0,
        vocabularyLevel: json['vocabulary_level'] as String?,
        feedback: json['feedback'] as String? ?? '',
        strengths: List<String>.from(json['strengths'] as List? ?? []),
        improvements: List<String>.from(json['improvements'] as List? ?? []),
        engineUsed: json['engine_used'] as String? ?? 'fast',
      );
}

class FreeTalkTurnResult {
  final String userTranscript;
  final String aiReplyText;
  final String? aiReplyAudioUrl;
  final List<Map<String, dynamic>> grammarCorrections;
  final List<Map<String, dynamic>> vocabularySuggestions;
  final List<String> pronunciationTips;
  final int fluencyScore;
  final String engineUsed;

  const FreeTalkTurnResult({
    required this.userTranscript,
    required this.aiReplyText,
    this.aiReplyAudioUrl,
    this.grammarCorrections = const [],
    this.vocabularySuggestions = const [],
    this.pronunciationTips = const [],
    this.fluencyScore = 80,
    this.engineUsed = 'fast',
  });

  factory FreeTalkTurnResult.fromJson(Map<String, dynamic> json) => FreeTalkTurnResult(
        userTranscript: json['user_transcript'] as String? ?? '',
        aiReplyText: json['ai_reply_text'] as String? ?? '',
        aiReplyAudioUrl: json['ai_reply_audio_url'] as String?,
        grammarCorrections: (json['grammar_corrections'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        vocabularySuggestions: (json['vocabulary_suggestions'] as List<dynamic>?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            const [],
        pronunciationTips: (json['pronunciation_tips'] as List<dynamic>?)
                ?.map((e) => _freeTalkTipToString(e))
                .where((t) => t.trim().isNotEmpty)
                .toList() ??
            const [],
        fluencyScore: json['fluency_score'] as int? ?? 80,
        engineUsed: json['engine_used'] as String? ?? 'fast',
      );

  // Alias que usa la UI de Free Talk (evita duplicar nombres).
  String get replyText => aiReplyText;
  String? get audioUrl => aiReplyAudioUrl;

  /// Vista tipada de la evaluacion para la tarjeta de correcciones.
  FreeTalkEvaluation get evaluation => FreeTalkEvaluation.fromResult(this);
}

/// Item de vocabulario sugerido en Free Talk (termino + explicacion + ejemplo).
class FreeTalkVocabItem {
  final String term;
  final String explanation;
  final String contextSentence;
  final String c1Alternative;

  const FreeTalkVocabItem({
    required this.term,
    this.explanation = '',
    this.contextSentence = '',
    this.c1Alternative = '',
  });

  factory FreeTalkVocabItem.fromMap(Map<String, dynamic> m) {
    final alts = (m['alternatives'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((x) => x.trim().isNotEmpty)
            .toList() ??
        const [];
    final explanation =
        (m['explanation'] ?? m['meaning'] ?? m['definition'] ?? '').toString().trim();
    return FreeTalkVocabItem(
      term: (m['term'] ?? m['word'] ?? '').toString(),
      explanation: explanation.isNotEmpty
          ? explanation
          : (alts.isNotEmpty ? 'Alternativas: ${alts.join(', ')}' : ''),
      contextSentence: (m['contextSentence'] ??
              m['context'] ??
              m['example'] ??
              m['example_sentence'] ??
              '')
          .toString(),
      c1Alternative: (m['c1Alternative'] ??
              m['c1_alternative'] ??
              m['c1'] ??
              (alts.isNotEmpty ? alts.first : ''))
          .toString(),
    );
  }
}

/// Evaluacion tipada de un turno de Free Talk. Reutiliza el modelo global
/// [GrammarCorrection] y normaliza los mapas crudos que envia el backend.
class FreeTalkEvaluation {
  final int fluencyScore;
  final List<GrammarCorrection> grammarCorrections;
  final List<FreeTalkVocabItem> vocabularySuggestions;
  final List<String> pronunciationTips;

  const FreeTalkEvaluation({
    this.fluencyScore = 0,
    this.grammarCorrections = const [],
    this.vocabularySuggestions = const [],
    this.pronunciationTips = const [],
  });

  factory FreeTalkEvaluation.fromResult(FreeTalkTurnResult r) => FreeTalkEvaluation(
        fluencyScore: r.fluencyScore,
        grammarCorrections: r.grammarCorrections
            .map((m) => GrammarCorrection(
                  original: (m['original'] ?? '').toString(),
                  correction: (m['correction'] ?? '').toString(),
                  explanation: (m['explanation'] ?? m['rule'] ?? '').toString(),
                ))
            .where((c) => c.original.isNotEmpty || c.correction.isNotEmpty)
            .toList(),
        vocabularySuggestions: r.vocabularySuggestions
            .map((m) => FreeTalkVocabItem.fromMap(m))
            .toList(),
        pronunciationTips: r.pronunciationTips,
      );
}

class AiStatusResult {
  final bool gpuOnline;
  final String modelActive;
  final String ollamaUrl;
  final List<String> availableModels;

  const AiStatusResult({
    required this.gpuOnline,
    required this.modelActive,
    required this.ollamaUrl,
    this.availableModels = const [],
  });

  factory AiStatusResult.fromJson(Map<String, dynamic> json) => AiStatusResult(
        gpuOnline: json['gpu_online'] as bool? ?? false,
        modelActive: json['model_active'] as String? ?? 'unknown',
        ollamaUrl: json['ollama_url'] as String? ?? '',
        availableModels: List<String>.from(json['available_models'] as List? ?? []),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Cache entry
// ─────────────────────────────────────────────────────────────────────────────

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  _CacheEntry(this.value, {int ttlSeconds = 300})
      : expiresAt = DateTime.now().add(Duration(seconds: ttlSeconds));
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ─────────────────────────────────────────────────────────────────────────────
// AiService
// ─────────────────────────────────────────────────────────────────────────────

class AiService {
  final ApiClient _api;
  final _cache = <String, _CacheEntry>{};

  // Streams independientes por funcionalidad para UX premium
  final _grammarController = StreamController<AiFeedbackState>.broadcast();
  final _vocabularyController = StreamController<AiFeedbackState>.broadcast();
  final _audioController = StreamController<AiFeedbackState>.broadcast();

  Stream<AiFeedbackState> get grammarStream => _grammarController.stream;
  Stream<AiFeedbackState> get vocabularyStream => _vocabularyController.stream;
  Stream<AiFeedbackState> get audioStream => _audioController.stream;

  AiService({required ApiClient api}) : _api = api;

  // ── Cache helpers ──────────────────────────────────────────────────────────

  T? _getCache<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T?;
  }

  void _setCache(String key, dynamic value, {int ttlSeconds = 300}) {
    _cache[key] = _CacheEntry(value, ttlSeconds: ttlSeconds);
  }

  void clearCache() => _cache.clear();

  // ── Status del GPU Worker ──────────────────────────────────────────────────

  Future<AiStatusResult?> getStatus() async {
    try {
      final res = await _api.dio.get(
        '/api/ai/status',
        options: Options(sendTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5)),
      );
      if (res.statusCode == 200) {
        return AiStatusResult.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AiService] status error: $e');
    }
    return null;
  }

  // ── Corrección gramatical ──────────────────────────────────────────────────

  Future<GrammarResult?> checkGrammar(String sentence) async {
    final cacheKey = 'grammar:${sentence.toLowerCase().trim()}';
    final cached = _getCache<GrammarResult>(cacheKey);
    if (cached != null) return cached;

    _grammarController.add(AiFeedbackState.loading);

    try {
      final res = await _api.dio.post(
        '/api/ai/grammar-check',
        data: {'sentence': sentence},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      if (res.statusCode == 200) {
        final result = GrammarResult.fromJson(res.data as Map<String, dynamic>);
        _setCache(cacheKey, result);
        _grammarController.add(AiFeedbackState(
          status: AiFeedbackStatus.success,
          data: result,
          engineUsed: result.engineUsed,
        ));
        return result;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        _grammarController.add(const AiFeedbackState(
          status: AiFeedbackStatus.offline,
          errorMessage: 'Sin conexión al servidor',
          engineUsed: 'standard',
        ));
      } else {
        _grammarController.add(AiFeedbackState(
          status: AiFeedbackStatus.error,
          errorMessage: e.message,
        ));
      }
    } catch (e) {
      debugPrint('[AiService] grammar error: $e');
      _grammarController.add(AiFeedbackState(
        status: AiFeedbackStatus.error,
        errorMessage: e.toString(),
      ));
    }
    return null;
  }

  // ── Lookup de vocabulario ──────────────────────────────────────────────────

  Future<VocabularyResult?> lookupVocabulary(String word) async {
    final cacheKey = 'vocab:${word.toLowerCase().trim()}';
    final cached = _getCache<VocabularyResult>(cacheKey);
    if (cached != null) {
      _vocabularyController.add(AiFeedbackState(
        status: AiFeedbackStatus.success,
        data: cached,
        engineUsed: cached.engineUsed,
      ));
      return cached;
    }

    _vocabularyController.add(AiFeedbackState.loading);

    try {
      final res = await _api.dio.post(
        '/api/ai/vocabulary',
        data: {'word': word},
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      if (res.statusCode == 200) {
        final result = VocabularyResult.fromJson(res.data as Map<String, dynamic>);
        _setCache(cacheKey, result, ttlSeconds: 3600); // 1h para vocab
        _vocabularyController.add(AiFeedbackState(
          status: AiFeedbackStatus.success,
          data: result,
          engineUsed: result.engineUsed,
        ));
        return result;
      }
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError;
      _vocabularyController.add(AiFeedbackState(
        status: isOffline ? AiFeedbackStatus.offline : AiFeedbackStatus.error,
        errorMessage: isOffline ? 'Sin conexión' : e.message,
        engineUsed: 'standard',
      ));
    } catch (e) {
      debugPrint('[AiService] vocab error: $e');
    }
    return null;
  }

  // ── Análisis de audio ──────────────────────────────────────────────────────

  Future<AudioAnalysisResult?> analyzeAudio(
    File audioFile, {
    String contextType = 'speaking',
  }) async {
    _audioController.add(AiFeedbackState.loading);

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'context_type': contextType,
      });

      final res = await _api.dio.post(
        '/api/ai/analyze-audio',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
          contentType: 'multipart/form-data',
        ),
      );

      if (res.statusCode == 200) {
        final result = AudioAnalysisResult.fromJson(res.data as Map<String, dynamic>);
        _audioController.add(AiFeedbackState(
          status: AiFeedbackStatus.success,
          data: result,
          engineUsed: result.engineUsed,
        ));
        return result;
      }
    } on DioException catch (e) {
      final isOffline = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError;
      _audioController.add(AiFeedbackState(
        status: isOffline ? AiFeedbackStatus.offline : AiFeedbackStatus.error,
        errorMessage: isOffline ? 'Sin conexión al servidor' : (e.message ?? 'Error'),
        engineUsed: 'standard',
      ));
    } catch (e) {
      debugPrint('[AiService] audio analysis error: $e');
      _audioController.add(AiFeedbackState(
        status: AiFeedbackStatus.error,
        errorMessage: e.toString(),
      ));
    }
    return null;
  }

  // ── Rating feedback ────────────────────────────────────────────────────────

  Future<void> rateFeedback(int logId, int score, {String? errorTag}) async {
    try {
      await _api.dio.post(
        '/api/ai/feedback/$logId/score',
        data: {'score': score, 'error_tag': errorTag},
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint('[AiService] rateFeedback error: $e');
    }
  }

  // ── Feedback general ───────────────────────────────────────────────────────

  Future<String?> getFeedback(String text, {String context = 'general'}) async {
    try {
      final res = await _api.dio.post(
        '/api/ai/feedback',
        data: {'text': text, 'context': context},
        options: Options(receiveTimeout: const Duration(seconds: 30)),
      );
      if (res.statusCode == 200) {
        return res.data['feedback'] as String?;
      }
    } catch (e) {
      debugPrint('[AiService] feedback error: $e');
    }
    return null;
  }

  // ── Conversacion Libre (Free Talk) ────────────────────────────────────────

  Future<FreeTalkTurnResult?> sendFreeTalkTurn({
    Uint8List? audioBytes,
    String? audioFileName,
    String? userText,
    List<Map<String, String>> conversationHistory = const [],
    String topic = 'General Tech & Architecture',
    String targetLevel = 'B2',
  }) async {
    try {
      final map = <String, dynamic>{
        'topic': topic,
        'target_level': targetLevel,
      };
      if (userText != null && userText.trim().isNotEmpty) {
        map['user_text'] = userText.trim();
      }
      if (conversationHistory.isNotEmpty) {
        map['conversation_history_json'] = jsonEncode(conversationHistory);
      }
      if (audioBytes != null && audioBytes.isNotEmpty) {
        map['file'] = MultipartFile.fromBytes(
          audioBytes,
          filename: audioFileName ?? 'speech.m4a',
        );
      }
      final formData = FormData.fromMap(map);

      final res = await _api.dio.post(
        '/api/ai/free-talk',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 25),
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        return FreeTalkTurnResult.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AiService] free-talk error: $e');
    }
    return null;
  }

  /// Free Talk en STREAMING con fallback blindado.
  ///
  /// Intenta el endpoint SSE `/api/ai/free-talk/stream` para pintar la respuesta
  /// de Lito en vivo ([onDelta]). Ante CUALQUIER problema (worker GPU offline,
  /// proxy sin flush, error de red o de parseo) cae automaticamente a
  /// [sendFreeTalkTurn] — el flujo probado. Devuelve el mismo [FreeTalkTurnResult].
  Future<FreeTalkTurnResult?> streamFreeTalkTurn({
    Uint8List? audioBytes,
    String? audioFileName,
    String? userText,
    List<Map<String, String>> conversationHistory = const [],
    String topic = 'General Tech & Architecture',
    String targetLevel = 'B2',
    void Function(String transcript)? onTranscript,
    void Function(String delta, String fullReply)? onDelta,
    void Function(String reply, String? ttsUrl)? onReplyReady,
  }) async {
    Future<FreeTalkTurnResult?> fallback() => sendFreeTalkTurn(
          audioBytes: audioBytes,
          audioFileName: audioFileName,
          userText: userText,
          conversationHistory: conversationHistory,
          topic: topic,
          targetLevel: targetLevel,
        );

    try {
      final map = <String, dynamic>{'topic': topic, 'target_level': targetLevel};
      if (userText != null && userText.trim().isNotEmpty) {
        map['user_text'] = userText.trim();
      }
      if (conversationHistory.isNotEmpty) {
        map['conversation_history_json'] = jsonEncode(conversationHistory);
      }
      if (audioBytes != null && audioBytes.isNotEmpty) {
        map['file'] = MultipartFile.fromBytes(
          audioBytes,
          filename: audioFileName ?? 'speech.m4a',
        );
      }
      final formData = FormData.fromMap(map);

      final res = await _api.dio.post<ResponseBody>(
        '/api/ai/free-talk/stream',
        data: formData,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      final body = res.data;
      if (res.statusCode != 200 || body == null) {
        return fallback();
      }

      var userTranscript = userText?.trim() ?? '';
      var fullReply = '';
      String? ttsUrl;
      Map<String, dynamic> feedback = const {};
      var gotFallback = false;
      var buffer = '';

      await for (final chunk in body.stream) {
        buffer += utf8.decode(chunk, allowMalformed: true);
        int sep;
        while ((sep = buffer.indexOf('\n\n')) != -1) {
          final rawEvent = buffer.substring(0, sep);
          buffer = buffer.substring(sep + 2);
          String? event;
          final dataBuf = StringBuffer();
          for (final line in rawEvent.split('\n')) {
            if (line.startsWith('event:')) {
              event = line.substring(6).trim();
            } else if (line.startsWith('data:')) {
              dataBuf.write(line.substring(5).trim());
            }
          }
          if (event == null) continue;
          Map<String, dynamic> payload = const {};
          final dataStr = dataBuf.toString();
          if (dataStr.isNotEmpty) {
            try {
              payload = jsonDecode(dataStr) as Map<String, dynamic>;
            } catch (_) {
              payload = const {};
            }
          }
          switch (event) {
            case 'transcript':
              userTranscript =
                  (payload['user_transcript'] as String?)?.trim() ?? userTranscript;
              onTranscript?.call(userTranscript);
              break;
            case 'delta':
              final t = (payload['t'] as String?) ?? '';
              fullReply += t;
              onDelta?.call(t, fullReply);
              break;
            case 'reply_done':
              final r = (payload['reply'] as String?)?.trim();
              if (r != null && r.isNotEmpty) fullReply = r;
              break;
            case 'audio':
              ttsUrl = payload['tts_url'] as String?;
              onReplyReady?.call(fullReply.trim(), ttsUrl);
              break;
            case 'feedback':
              feedback = payload;
              break;
            case 'fallback':
              gotFallback = true;
              break;
          }
        }
        if (gotFallback) break;
      }

      if (gotFallback || fullReply.trim().isEmpty) {
        return fallback();
      }

      List<Map<String, dynamic>> mapList(dynamic v) => (v as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return FreeTalkTurnResult(
        userTranscript: userTranscript,
        aiReplyText: fullReply.trim(),
        aiReplyAudioUrl: ttsUrl,
        grammarCorrections: mapList(feedback['grammar_corrections']),
        vocabularySuggestions: mapList(feedback['vocabulary_suggestions']),
        pronunciationTips: (feedback['pronunciation_tips'] as List? ?? const [])
            .map((e) => _freeTalkTipToString(e))
            .where((t) => t.trim().isNotEmpty)
            .toList(),
        fluencyScore: feedback['fluency_score'] as int? ?? 80,
        engineUsed: 'fast',
      );
    } catch (e) {
      debugPrint('[AiService] free-talk stream error, fallback: $e');
      return fallback();
    }
  }

  void dispose() {
    _grammarController.close();
    _vocabularyController.close();
    _audioController.close();
  }
}


/// Normaliza un tip de pronunciacion (puede venir como String o como objeto
/// {word, ipa, tip}) a una linea legible: "word /ipa/ — tip".
String _freeTalkTipToString(dynamic e) {
  if (e is String) return e.trim();
  if (e is Map) {
    final word = (e['word'] ?? '').toString().trim();
    final ipa = (e['ipa'] ?? '').toString().trim();
    final tip = (e['tip'] ?? e['text'] ?? e['advice'] ?? '').toString().trim();
    final head = [word, ipa].where((x) => x.isNotEmpty).join(' ');
    if (head.isNotEmpty && tip.isNotEmpty) return '$head — $tip';
    if (tip.isNotEmpty) return tip;
    if (head.isNotEmpty) return head;
    return e.values.map((v) => v.toString()).where((x) => x.trim().isNotEmpty).join(' ');
  }
  return e.toString();
}
