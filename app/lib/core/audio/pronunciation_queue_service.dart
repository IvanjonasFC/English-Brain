import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/api_models.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../services/client_logger.dart';

/// Resultado de una grabación de pronunciación evaluada tras reconectar.
class PronQueueResult {
  final String section; // 'vocabulary' | 'grammar' | 'comprehension'
  final String term; // expectedTerm (clave con la que la UI empareja)
  final PronunciationResult result;
  PronQueueResult(this.section, this.term, this.result);
}

/// Cola offline UNIFICADA para la evaluación de pronunciación de todas las
/// ventanas (vocabulario, gramática, comprensión). Si no hay ruta a los
/// workers al grabar, la grabación se guarda en disco y se evalúa sola al
/// reconectar — igual que la entrevista, pero sin tocar el esquema Drift.
///
/// Persistencia: ficheros JSON en <documentos>/pron_queue/ + copias de audio.
/// Robusto: nunca lanza, reintenta con tope, descarta audios perdidos o
/// tras demasiados fallos, y auto-drena al recuperar acceso al servidor.
class PronunciationQueueService {
  final ApiClient _api;
  final ConnectivityService? _connectivity;
  StreamSubscription<ConnectivityState>? _connSub;
  bool _draining = false;

  final StreamController<PronQueueResult> _processed =
      StreamController<PronQueueResult>.broadcast();
  Stream<PronQueueResult> get onProcessed => _processed.stream;

  final StreamController<int> _count = StreamController<int>.broadcast();
  Stream<int> get pendingCountStream => _count.stream;

  static const int _maxRetries = 8;

  PronunciationQueueService(this._api, {ConnectivityService? connectivity})
      : _connectivity = connectivity {
    final c = _connectivity;
    if (c != null) {
      _connSub = c.statusStream.listen((s) {
        if (s.isReady) unawaited(processPending());
      });
    }
  }

  bool get isOnline => _connectivity?.currentState.isReady ?? true;

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/pron_queue');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<File> _queueFile() async => File('${(await _dir()).path}/queue.json');
  Future<File> _resultsFile() async => File('${(await _dir()).path}/results.json');

  Future<List<Map<String, dynamic>>> _readQueue() async {
    try {
      final f = await _queueFile();
      if (!await f.exists()) return [];
      final txt = await f.readAsString();
      if (txt.trim().isEmpty) return [];
      return (jsonDecode(txt) as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> q) async {
    try {
      await (await _queueFile()).writeAsString(jsonEncode(q));
    } catch (_) {}
    if (!_count.isClosed) _count.add(q.length);
  }

  Future<int> pendingCount() async => (await _readQueue()).length;

  /// Copia el audio a almacenamiento persistente y lo encola. No lanza.
  Future<bool> enqueue({
    required String section,
    required String audioPath,
    required String expectedTerm,
    String? expectedIpa,
    String? userId,
    required String exerciseType,
    String? category,
  }) async {
    if (kIsWeb) return false;
    try {
      final src = File(audioPath);
      if (!await src.exists()) return false;
      final d = await _dir();
      final permanent =
          '${d.path}/pron_${DateTime.now().millisecondsSinceEpoch}_$section.m4a';
      await src.copy(permanent);
      final q = await _readQueue();
      q.add({
        'section': section,
        'audioPath': permanent,
        'expectedTerm': expectedTerm,
        'expectedIpa': expectedIpa,
        'userId': userId,
        'exerciseType': exerciseType,
        'category': category,
        'createdAt': DateTime.now().toIso8601String(),
        'retry': 0,
      });
      await _writeQueue(q);
      ClientLogger.event('pron_queue',
          'encolado section=$section term="$expectedTerm" total=${q.length}');
      return true;
    } catch (e, st) {
      ClientLogger.error('pron_queue', e, st);
      return false;
    }
  }

  /// Drena la cola contra el backend. Idempotente y seguro ante reentradas.
  Future<void> processPending() async {
    if (_draining) return;
    _draining = true;
    try {
      final q = await _readQueue();
      if (q.isEmpty) return;
      final remaining = <Map<String, dynamic>>[];
      for (final item in q) {
        final path = item['audioPath'] as String?;
        if (path == null || !File(path).existsSync()) {
          continue; // audio perdido -> descartar entrada
        }
        final section = (item['section'] as String?) ?? '';
        final term = (item['expectedTerm'] as String?) ?? '';
        try {
          final res = await _api.checkPronunciation(
            audioPath: path,
            expectedTerm: term,
            expectedIpa: item['expectedIpa'] as String?,
            userId: item['userId'] as String?,
            exerciseType: (item['exerciseType'] as String?) ?? 'single_word',
            category: item['category'] as String?,
            withTip: false,
          );
          await _storeResult(section, term, res);
          if (!_processed.isClosed) {
            _processed.add(PronQueueResult(section, term, res));
          }
          try {
            await File(path).delete();
          } catch (_) {}
        } catch (e) {
          final r = ((item['retry'] as int?) ?? 0) + 1;
          if (r <= _maxRetries) {
            item['retry'] = r;
            item['lastError'] = e.toString();
            remaining.add(item);
          } else {
            try {
              await File(path).delete();
            } catch (_) {}
          }
        }
      }
      await _writeQueue(remaining);
    } catch (e, st) {
      ClientLogger.error('pron_queue', e, st);
    } finally {
      _draining = false;
    }
  }

  Future<void> _storeResult(
      String section, String term, PronunciationResult res) async {
    try {
      final f = await _resultsFile();
      Map<String, dynamic> m = {};
      if (await f.exists()) {
        final t = await f.readAsString();
        if (t.trim().isNotEmpty) m = (jsonDecode(t) as Map).cast<String, dynamic>();
      }
      m['$section::$term'] = {
        'score': res.score,
        'ts': DateTime.now().toIso8601String(),
      };
      await f.writeAsString(jsonEncode(m));
    } catch (_) {}
  }

  /// Nota cacheada de una evaluación offline ya procesada (o null).
  Future<int?> cachedScore(String section, String term) async {
    try {
      final f = await _resultsFile();
      if (!await f.exists()) return null;
      final t = await f.readAsString();
      if (t.trim().isEmpty) return null;
      final m = (jsonDecode(t) as Map).cast<String, dynamic>();
      final e = m['$section::$term'];
      if (e is Map && e['score'] is int) return e['score'] as int;
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _connSub?.cancel();
    if (!_processed.isClosed) _processed.close();
    if (!_count.isClosed) _count.close();
  }
}
