import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../constants/app_constants.dart';
import '../models/api_models.dart';
import '../models/measurement_models.dart';
import '../models/pitch_models.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_cache_service.dart';

class HumanizedApiException implements Exception {
  final String message;
  final int? statusCode;

  HumanizedApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  final SecureStorageService _secureStorage;
  final LocalCacheService _cacheService;
  late final Dio _dio;
  Dio get dio => _dio;

  ApiClient({
    required SecureStorageService secureStorage,
    required LocalCacheService cacheService,
  })  : _secureStorage = secureStorage,
        _cacheService = cacheService {
    _dio = Dio(
      BaseOptions(
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.connectTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Auth & Dynamic BaseURL Interceptor with transparent 401 auto-refresh
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Dynamic base URL from settings
          final currentBase = await _cacheService.getBaseUrl();
          if (!options.path.startsWith('http')) {
            options.baseUrl = currentBase;
          }

          if (kDebugMode) {
            // ignore: avoid_print
            print('[API ON_REQUEST] -> ${options.baseUrl}${options.path}');
          }

          final storedApiKey = await _secureStorage.getApiKey();
          final apiKey = (storedApiKey != null && storedApiKey.isNotEmpty)
              ? storedApiKey
              : AppConstants.defaultApiKey;
          final token = await _secureStorage.getToken();

          if (apiKey.isNotEmpty) {
            options.headers['X-API-Key'] = apiKey;
          }
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[API ON_RESPONSE] <- ${response.statusCode} from ${response.requestOptions.baseUrl}${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (kDebugMode) {
            // ignore: avoid_print
            print('[API ON_ERROR] ${error.type} - ${error.message} - status: ${error.response?.statusCode} - path: ${error.requestOptions.path}');
          }
          // Transparent token auto-refresh on 401 Unauthorized
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['auth_retry'] != true &&
              !error.requestOptions.path.contains('/auth/login')) {
            final apiKey = await _secureStorage.getApiKey();
            if (apiKey != null && apiKey.isNotEmpty) {
              try {
                final currentBase = await _cacheService.getBaseUrl();
                final refreshDio = Dio(
                  BaseOptions(
                    baseUrl: currentBase,
                    connectTimeout: const Duration(seconds: 5),
                    receiveTimeout: const Duration(seconds: 5),
                  ),
                );
                final storedUserId = await _secureStorage.getActiveUserId();
                final refreshBody = <String, dynamic>{'api_key': apiKey};
                if (storedUserId != null && storedUserId.isNotEmpty) {
                  refreshBody['user_id'] = storedUserId;
                }
                final res = await refreshDio.post(
                  '/api/auth/login',
                  data: refreshBody,
                );
                if (res.statusCode == 200 && res.data is Map) {
                  final newToken = res.data['access_token'] as String?;
                  if (newToken != null && newToken.isNotEmpty) {
                    await _secureStorage.saveToken(newToken);

                    // Replay request with updated token
                    final retryOptions = error.requestOptions;
                    retryOptions.extra['auth_retry'] = true;
                    retryOptions.headers['Authorization'] = 'Bearer $newToken';
                    retryOptions.headers['X-API-Key'] = apiKey;

                    final retryResponse = await _dio.fetch(retryOptions);
                    return handler.resolve(retryResponse);
                  }
                }
              } catch (_) {
                // If refresh fails, clear invalid auth credentials
                await _secureStorage.clearAuth();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Retry Interceptor (3 retries: 1s, 2s, 5s - only for 5xx and network failures, never 4xx)
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 5),
        ],
        retryEvaluator: (error, attempt) {
          // Never retry on 4xx client errors (401, 403, 404, 422, etc.)
          final status = error.response?.statusCode;
          if (status != null && status >= 400 && status < 500) {
            return false;
          }
          // Retry on network timeouts or 5xx server errors
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError ||
              (status != null && status >= 500);
        },
      ),
    );
  }

  // Humanize Dio Exceptions
  HumanizedApiException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return HumanizedApiException(
        'No se pudo conectar con el NAS. Comprueba que el servidor esté encendido y en la misma red.',
        statusCode: status,
      );
    }
    if (e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout) {
      return HumanizedApiException(
        'El entrevistador está tardando en procesar la respuesta. El modelo puede estar ocupado, intenta de nuevo.',
        statusCode: status,
      );
    }
    if (status == 401 || status == 403) {
      return HumanizedApiException(
        'Clave de acceso incorrecta o sesión caducada. Revisa los Ajustes.',
        statusCode: status,
      );
    }
    if (status == 404) {
      return HumanizedApiException(
        'El recurso solicitado no existe en el servidor.',
        statusCode: status,
      );
    }
    if (status != null && status >= 500) {
      return HumanizedApiException(
        'El servidor encontró un error interno. Puede que Ollama o Whisper se estén reiniciando.',
        statusCode: status,
      );
    }
    return HumanizedApiException(
      'Error de comunicación con el servicio (${e.message ?? "desconocido"}).',
      statusCode: status,
    );
  }

  // Authentication Flow
  Future<String> login(String apiKey, {String? userId}) async {
    try {
      final body = <String, dynamic>{'api_key': apiKey};
      if (userId != null && userId.isNotEmpty) {
        body['user_id'] = userId;
      }
      final res = await _dio.post(
        '/api/auth/login',
        data: body,
      );
      final data = res.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      await _secureStorage.saveApiKey(apiKey);
      if (userId != null && userId.isNotEmpty) {
        await _secureStorage.saveActiveUserId(userId);
      }
      await _secureStorage.saveToken(token);
      return token;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Re-issue the JWT for a different profile (used when switching users).
  Future<void> reauthenticateAs(String userId) async {
    final apiKey = await _secureStorage.getApiKey();
    if (apiKey == null || apiKey.isEmpty) return;
    await login(apiKey, userId: userId);
  }

  Future<void> logout() async {
    await _secureStorage.clearAuth();
  }

  /// Ingest a generalized FSRS review card from any source (vocab/grammar/listening).
  Future<void> ingestReviewCard(Map<String, dynamic> body) async {
    await _dio.post('/api/cards/ingest', data: body);
  }

  /// Quick health check returning round-trip latency in ms.
  Future<int> checkHealth() async {
    final sw = Stopwatch()..start();
    try {
      final response = await _dio.get(
        '/api/health',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      sw.stop();
      if (response.statusCode == 200) {
        return sw.elapsedMilliseconds;
      }
      throw HumanizedApiException('Respuesta de salud no exitosa: ${response.statusCode}');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // Detailed Health Check with Ollama / Speaches Diagnostics
  Future<Map<String, dynamic>> checkHealthDetailed() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _dio.get(
        '/api/ready',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      stopwatch.stop();
      if (response.statusCode == 200 && response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        data['latency_ms'] = stopwatch.elapsedMilliseconds;
        return data;
      }
      throw HumanizedApiException('Respuesta anormal del servidor: ${response.statusCode}');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Guarda o actualiza el PIN de un usuario en el servidor (NAS).
  Future<bool> setUserPin(String userId, String pin) async {
    try {
      final res = await _dio.post(
        '/api/profile/users/$userId/pin',
        data: {'pin': pin},
        options: Options(sendTimeout: const Duration(seconds: 4), receiveTimeout: const Duration(seconds: 4)),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Verifica el PIN de un usuario contra el servidor (NAS).
  Future<bool> verifyUserPin(String userId, String pin) async {
    try {
      final res = await _dio.post(
        '/api/profile/users/$userId/verify-pin',
        data: {'pin': pin},
        options: Options(sendTimeout: const Duration(seconds: 4), receiveTimeout: const Duration(seconds: 4)),
      );
      if (res.statusCode == 200 && res.data is Map) {
        return (res.data['valid'] == true);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // Question Bank
  Future<List<QuestionOut>> getQuestions({String? category, String? difficulty}) async {
    try {
      final query = <String, dynamic>{};
      if (category != null && category.isNotEmpty) query['category'] = category;
      if (difficulty != null && difficulty.isNotEmpty) query['difficulty'] = difficulty;

      final res = await _dio.get('/api/questions', queryParameters: query);
      final list = (res.data as List<dynamic>)
          .map((e) => QuestionOut.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cacheService.cacheQuestions(list);
      return list;
    } on DioException catch (e) {
      // Fallback to offline cache
      final cached = await _cacheService.getCachedQuestions();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw _mapDioError(e);
    }
  }

  // Sessions
  Future<SessionOut> createSession({String? category, int? initialQuestionId}) async {
    try {
      final body = <String, dynamic>{
        'category': category ?? 'tech',
      };
      if (initialQuestionId != null) {
        body['initial_question_id'] = initialQuestionId;
      }

      final res = await _dio.post(
        '/api/sessions',
        data: body,
      );
      return SessionOut.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // Submit Spoken Answer (120s timeout for STT -> LLM -> TTS pipeline)
  Future<TurnOut> submitAnswer({
    required String sessionId,
    required String audioPath,
    int? questionId,
  }) async {
    try {
      final MultipartFile audioMultipart;
      if (kIsWeb) {
        if (audioPath.startsWith('blob:') || audioPath.startsWith('http')) {
          final blobRes = await _dio.get<List<int>>(
            audioPath,
            options: Options(responseType: ResponseType.bytes),
          );
          audioMultipart = MultipartFile.fromBytes(
            blobRes.data ?? [],
            filename: 'answer.webm',
          );
        } else {
          audioMultipart = MultipartFile.fromBytes(
            audioPath.codeUnits,
            filename: 'answer.webm',
          );
        }
      } else {
        final file = File(audioPath);
        final fileName = file.path.split(Platform.pathSeparator).last;
        audioMultipart = await MultipartFile.fromFile(file.path, filename: fileName);
      }

      final formData = FormData.fromMap({
        'file': audioMultipart,
        if (questionId != null) 'question_id': questionId.toString(),
      });

      final res = await _dio.post(
        '/api/sessions/$sessionId/answer',
        data: formData,
        options: Options(
          sendTimeout: AppConstants.audioUploadTimeout,
          receiveTimeout: AppConstants.audioUploadTimeout,
        ),
      );

      return TurnOut.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // Flashcards (FSRS)
  Future<List<CardOut>> getCards({bool dueOnly = false}) async {
    try {
      final res = await _dio.get(
        '/api/cards',
        queryParameters: {'due_only': dueOnly},
      );
      final list = (res.data as List<dynamic>)
          .map((e) => CardOut.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cacheService.cacheCards(list);
      return list;
    } on DioException catch (e) {
      final cached = await _cacheService.getCachedCards();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw _mapDioError(e);
    }
  }

  Future<CardOut> reviewCard(int cardId, int rating) async {
    try {
      final res = await _dio.post(
        '/api/cards/$cardId/review',
        data: {'rating': rating},
      );
      return CardOut.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // Stats
  Future<StatsOut> getStats() async {
    try {
      final res = await _dio.get('/api/stats');
      return StatsOut.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<WeeklyReportOut> getWeeklyReport() async {
    try {
      final res = await _dio.get('/api/stats/weekly-report');
      return WeeklyReportOut.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // Pronunciation Checker
  Future<PronunciationResult> checkPronunciation({
    required String audioPath,
    required String expectedTerm,
    String? expectedIpa,
    String? userId,
    String exerciseType = 'single_word',
    String? category,
    bool withTip = true,
  }) async {
    try {
      final MultipartFile audioMultipart;
      if (kIsWeb) {
        if (audioPath.startsWith('blob:') || audioPath.startsWith('http')) {
          final blobRes = await _dio.get<List<int>>(
            audioPath,
            options: Options(responseType: ResponseType.bytes),
          );
          audioMultipart = MultipartFile.fromBytes(
            blobRes.data ?? [],
            filename: 'pronunciation.webm',
          );
        } else {
          audioMultipart = MultipartFile.fromBytes(
            audioPath.codeUnits,
            filename: 'pronunciation.webm',
          );
        }
      } else {
        final filename = audioPath.split(RegExp(r'[\\/]')).last;
        audioMultipart = await MultipartFile.fromFile(audioPath, filename: filename);
      }
      final dataMap = <String, dynamic>{
        'expected_term': expectedTerm,
        'file': audioMultipart,
      };
      if (expectedIpa != null) {
        dataMap['expected_ipa'] = expectedIpa;
      }
      if (userId != null && userId.isNotEmpty) {
        dataMap['user_id'] = userId;
      }
      dataMap['exercise_type'] = exerciseType;
      dataMap['with_tip'] = withTip.toString();
      if (category != null && category.isNotEmpty) {
        dataMap['category'] = category;
      }
      final formData = FormData.fromMap(dataMap);

      final res = await _dio.post(
        '/api/pronunciation/check',
        data: formData,
        options: Options(
          // Subir audio: generoso (conexiones lentas). El corte por servidor
          // caido lo da connectTimeout (~3s), no esto.
          sendTimeout: AppConstants.audioUploadTimeout,
          // Esperar el analisis (STT + fonemas): una FRASE tarda mas de 4s.
          // Con 4s siempre saltaba a la cola offline aunque el servidor
          // estuviera online. 15s cubre el peor caso real sin cuelgues.
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      return PronunciationResult.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Registra una medida de voz (pronunciacion, speaking, ...) y devuelve la comparacion baseline.
  Future<MeasurementComparison?> recordMeasurement({
    required String userId,
    required String zone,
    required String targetId,
    required String metricKey,
    required double value,
    String targetType = 'word',
    String? audioUrl,
    String? label,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final res = await _dio.post(
        '/api/measurements',
        data: {
          'user_id': userId,
          'zone': zone,
          'target_id': targetId,
          'metric_key': metricKey,
          'value': value,
          'target_type': targetType,
          if (audioUrl != null) 'audio_path': audioUrl,
          if (label != null) 'label': label,
          if (extra != null) 'extra': extra,
        },
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      final data = res.data;
      if (data is Map) {
        return MeasurementComparison.fromJson(data.cast<String, dynamic>());
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Comparacion baseline "Dia 1 vs Hoy" de un item concreto (o null si aun no existe).
  Future<MeasurementComparison?> getMeasurementBaseline({
    required String userId,
    required String zone,
    required String targetId,
    String metricKey = 'pronunciation_gop',
  }) async {
    try {
      final res = await _dio.get(
        '/api/measurements/baseline',
        queryParameters: {
          'user_id': userId,
          'zone': zone,
          'target_id': targetId,
          'metric_key': metricKey,
        },
        options: Options(receiveTimeout: const Duration(seconds: 4)),
      );
      final data = res.data;
      if (data is Map) {
        final m = data.cast<String, dynamic>();
        if (m['has_baseline'] == false) return null;
        return MeasurementComparison.fromJson(m);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Resumen de evolucion de voz por zona/metrica para el perfil.
  Future<List<MeasurementProfileEntry>> getMeasurementProfile(String userId) async {
    try {
      final res = await _dio.get(
        '/api/measurements/profile/$userId',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      final data = res.data;
      if (data is Map) {
        final list = (data['summary'] as List?) ?? const [];
        return list
            .map((e) => MeasurementProfileEntry.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  /// Analiza la entonacion (F0) del audio y la compara con la voz nativa del texto objetivo.
  Future<PitchComparison?> analyzePitch({
    required String audioPath,
    String? text,
    String voice = 'en-US-GuyNeural',
  }) async {
    try {
      final MultipartFile audioMultipart;
      if (kIsWeb) {
        audioMultipart = MultipartFile.fromBytes(audioPath.codeUnits, filename: 'pitch.webm');
      } else {
        final filename = audioPath.split(RegExp(r'[\\/]')).last;
        audioMultipart = await MultipartFile.fromFile(audioPath, filename: filename);
      }
      final dataMap = <String, dynamic>{'file': audioMultipart, 'voice': voice};
      if (text != null && text.trim().isNotEmpty) dataMap['text'] = text.trim();
      final res = await _dio.post(
        '/api/pitch/analyze',
        data: FormData.fromMap(dataMap),
        options: Options(receiveTimeout: const Duration(seconds: 20)),
      );
      final data = res.data;
      if (data is Map) return PitchComparison.fromJson(data.cast<String, dynamic>());
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Progreso de pronunciación por usuario (media, términos, débiles, por categoría).
  Future<Map<String, dynamic>> getPronunciationProgress(String userId) async {
    try {
      final res = await _dio.get('/api/pronunciation/progress',
          queryParameters: {'user_id': userId},
          options: Options(receiveTimeout: const Duration(seconds: 3)));
      return (res.data as Map).cast<String, dynamic>();
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  /// Consejo IA de pronunciación bajo demanda (no bloquea la nota).
  Future<String?> getPronunciationTip({
    required String term,
    String? ipa,
    String? recognized,
    required int score,
    List<String> wrongPhonemes = const [],
    double confidence = 1.0,
  }) async {
    try {
      final res = await _dio.post(
        '/api/pronunciation/tip',
        data: {
          'term': term,
          'ipa': ipa,
          'recognized': recognized ?? '',
          'score': score,
          'wrong_phonemes': wrongPhonemes,
          'confidence': confidence,
        },
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );
      return (res.data as Map)['tip'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Analisis gramatical con IA (reutiliza /api/ai/grammar-check).
  Future<Map<String, dynamic>?> grammarCheck(String sentence) async {
    try {
      final res = await _dio.post(
        '/api/ai/grammar-check',
        data: {'sentence': sentence},
        options: Options(receiveTimeout: const Duration(seconds: 20)),
      );
      final data = res.data;
      if (data is Map) return data.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  // Full Audio URL Helper
  Future<String> resolveAudioUrl(String relativeOrAbsoluteUrl) async {
    if (relativeOrAbsoluteUrl.startsWith('http://') || relativeOrAbsoluteUrl.startsWith('https://')) {
      return relativeOrAbsoluteUrl;
    }
    final base = await _cacheService.getBaseUrl();
    final cleanBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final cleanPath = relativeOrAbsoluteUrl.startsWith('/') ? relativeOrAbsoluteUrl : '/$relativeOrAbsoluteUrl';
    return '$cleanBase$cleanPath';
  }
}
