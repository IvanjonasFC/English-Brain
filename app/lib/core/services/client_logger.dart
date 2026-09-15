import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../storage/local_cache_service.dart';

/// Envia errores/eventos del movil al backend (/api/client-log) para depuracion
/// remota sin cable. Fire-and-forget: NUNCA lanza ni bloquea la UI; si el NAS no
/// responde, el log simplemente se pierde.
class ClientLogger {
  ClientLogger._();

  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 4),
    sendTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
  ));
  static String? _base;
  static const String _appVersion = '1.0.0+1';

  static String get _platform {
    if (kIsWeb) return 'web';
    try {
      return Platform.operatingSystem;
    } catch (_) {
      return 'unknown';
    }
  }

  static Future<String> _baseUrl() async {
    if (_base != null && _base!.isNotEmpty) return _base!;
    try {
      final b = await LocalCacheService().getBaseUrl();
      _base = b.isNotEmpty ? b : AppConstants.defaultBaseUrl;
    } catch (_) {
      _base = AppConstants.defaultBaseUrl;
    }
    return _base!;
  }

  static void log(String level, String tag, String message, {Object? context}) {
    unawaited(_send(level, tag, message, context));
    if (kDebugMode) debugPrint('[ClientLog/$level/$tag] $message');
  }

  static void error(String tag, Object error, [StackTrace? stack]) =>
      log('error', tag, error.toString(), context: stack?.toString());

  static void event(String tag, String message, {Object? context}) =>
      log('event', tag, message, context: context);

  static Future<void> _send(String level, String tag, String message, Object? context) async {
    try {
      final base = await _baseUrl();
      final url = base.endsWith('/') ? '${base}api/client-log' : '$base/api/client-log';
      String? ctx;
      if (context != null) {
        ctx = context is String ? context : jsonEncode({'ctx': context.toString()});
      }
      await _dio.post(url, data: {
        'level': level,
        'tag': tag,
        'message': message,
        if (ctx != null) 'context': ctx,
        'platform': _platform,
        'app_version': _appVersion,
      });
    } catch (_) {
      // Silencio total: la telemetria nunca puede romper la app.
    }
  }
}
