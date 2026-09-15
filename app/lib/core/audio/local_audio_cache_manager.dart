import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalAudioCacheManager {
  static final LocalAudioCacheManager instance = LocalAudioCacheManager._();
  LocalAudioCacheManager._();

  // LRU Cap: 200 Megabytes
  static const int maxCacheSizeBytes = 200 * 1024 * 1024;
  
  Directory? _cacheDir;
  final Dio _dio = Dio(BaseOptions(
    // 3500ms era demasiado corto: una síntesis neural en frío (worker LAN)
    // superaba el timeout y el cliente caía al TTS nativo ("voz mala") sin
    // llegar a cachear nada. Se sube al nivel del backend (Speaches ~15s).
    connectTimeout: const Duration(milliseconds: 4000),
    receiveTimeout: const Duration(milliseconds: 15000),
  ));

  int _localHits = 0;
  int _localMisses = 0;

  int get localHits => _localHits;
  int get localMisses => _localMisses;
  double get hitRatePct => (_localHits + _localMisses > 0)
      ? (_localHits / (_localHits + _localMisses) * 100)
      : 100.0;

  Future<Directory> _getCacheDirectory() async {
    if (_cacheDir != null && await _cacheDir!.exists()) {
      return _cacheDir!;
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDocDir.path, 'audio_cache_lru'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cacheDir = dir;
    return dir;
  }

  String computeAudioKey(String text, {String voice = 'en-US-GuyNeural', String rate = '+0%'}) {
    final cleaned = text.trim();
    final payload = '${cleaned}_${voice}_${rate}_edge_neural_v1';
    final hash = sha256.convert(utf8.encode(payload)).toString().substring(0, 18);
    return 'tts_$hash.mp3';
  }

  /// Retorna la ruta local del archivo si ya existe en la caché LRU (0 ms).
  Future<String?> getCachedAudioFilePath(
    String text, {
    String voice = 'en-US-GuyNeural',
    String rate = '+0%',
  }) async {
    try {
      final dir = await _getCacheDirectory();
      final filename = computeAudioKey(text, voice: voice, rate: rate);
      final file = File(p.join(dir.path, filename));

      if (await file.exists() && await file.length() > 100) {
        _localHits += 1;
        // Actualizar timestamp de acceso para LRU
        try {
          await file.setLastModified(DateTime.now());
        } catch (_) {}
        return file.path;
      }
    } catch (e) {
      debugPrint('LocalAudioCache lookup error: $e');
    }
    _localMisses += 1;
    return null;
  }

  /// Descarga el audio desde la URL remota y lo almacena localmente en la caché LRU.
  Future<String?> fetchAndCacheAudio(
    String remoteUrl,
    String text, {
    String voice = 'en-US-GuyNeural',
    String rate = '+0%',
  }) async {
    try {
      final dir = await _getCacheDirectory();
      final filename = computeAudioKey(text, voice: voice, rate: rate);
      final targetFile = File(p.join(dir.path, filename));

      final response = await _dio.get<List<int>>(
        remoteUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null && response.data!.length > 100) {
        await targetFile.writeAsBytes(response.data!, flush: true);
        
        // Ejecutar limpieza LRU en segundo plano si supera 200 MB
        _enforceLruLimit(dir);

        return targetFile.path;
      }
    } catch (e) {
      debugPrint('LocalAudioCache download error: $e');
    }
    return null;
  }

  /// Limpieza LRU: si supera el tope de 200MB, elimina los menos recientemente usados
  Future<void> _enforceLruLimit(Directory dir) async {
    try {
      final files = <File>[];
      int totalBytes = 0;

      await for (final entity in dir.list()) {
        if (entity is File) {
          final len = await entity.length();
          totalBytes += len;
          files.add(entity);
        }
      }

      if (totalBytes > maxCacheSizeBytes) {
        // Ordenar por última fecha de modificación / acceso (los más viejos primero)
        files.sort((a, b) {
          final aDate = a.lastModifiedSync();
          final bDate = b.lastModifiedSync();
          return aDate.compareTo(bDate);
        });

        // Eliminar hasta quedar en el 80% del límite (~160 MB)
        final targetBytes = (maxCacheSizeBytes * 0.8).toInt();
        for (final f in files) {
          if (totalBytes <= targetBytes) break;
          try {
            final len = await f.length();
            await f.delete();
            totalBytes -= len;
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Error enforcing LRU audio cache: $e');
    }
  }

  /// Vaciar caché manualmente si el usuario lo solicita en Ajustes
  Future<void> clearCache() async {
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
      _localHits = 0;
      _localMisses = 0;
    } catch (e) {
      debugPrint('Error clearing local audio cache: $e');
    }
  }

  Future<int> getCacheSizeBytes() async {
    try {
      final dir = await _getCacheDirectory();
      int total = 0;
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            total += await entity.length();
          }
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }
}
