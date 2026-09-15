import 'package:flutter/foundation.dart';

class AppConstants {
  // Base URL of the self-hosted backend, overridable at build time with
  // --dart-define=BASE_URL=... When not overridden the default is
  // platform-aware: mobile builds target the NAS on the LAN (also reachable
  // over WireGuard, whose AllowedIPs include 192.168.0.0/24), while web and
  // desktop dev builds target localhost, where the backend usually runs during
  // development. Either way the user can change it in Settings.
  static const String _envBaseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: '');

  static bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // Por defecto: dominio publico (Caddy -> NAS). Para desarrollo local se puede
  // sobreescribir en build con --dart-define=BASE_URL=http://localhost:8092
  static String get defaultBaseUrl =>
      _envBaseUrl.isNotEmpty ? _envBaseUrl : 'https://ingles.ivanjonasfc.dev';

  // Optional API key baked at build time with --dart-define=API_KEY=...
  static const String defaultApiKey =
      String.fromEnvironment('API_KEY', defaultValue: 'super-secret-key-123');

  static const String keyBaseUrl = 'coach_base_url';
  static const String keyApiKey = 'coach_api_key';
  static const String keyJwtToken = 'coach_jwt_token';
  static const String keyActiveUserId = 'coach_active_user_id';
  static const String keyCachedQuestions = 'coach_cached_questions';
  static const String keyCachedCards = 'coach_cached_cards';
  static const String keyOfflineQueue = 'coach_offline_queue';

  // Content (packs) offline cache — one key per content tab (cache-first).
  static const String keyCacheComprehension = 'coach_cache_comprehension';
  static const String keyCacheVocabulary = 'coach_cache_vocabulary';
  static const String keyCacheGrammar = 'coach_cache_grammar';
  static const String keyCacheInterview = 'coach_cache_interview';

  static const Duration connectTimeout = Duration(seconds: 3);
  static const Duration receiveTimeout = Duration(seconds: 5);
  static const Duration audioUploadTimeout = Duration(seconds: 120);
}
