import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';
import '../models/api_models.dart';
import '../network/api_client.dart';

class OfflineQueueService {
  final AppDatabase _db;
  final ApiClient _apiClient;

  OfflineQueueService(this._db, this._apiClient);

  AppDatabase get db => _db;

  /// Sanitizes header map by stripping sensitive authorization tokens and secrets
  /// before any offline request or queue operation is persisted to local storage/SQLite.
  static Map<String, String> sanitizeHeaders(Map<String, String>? headers) {
    if (headers == null) return {};
    final sanitized = Map<String, String>.from(headers);
    const sensitiveKeys = {
      'authorization',
      'x-api-key',
      'api-key',
      'cookie',
      'set-cookie',
      'proxy-authorization',
      'token',
      'password',
      'secret',
    };
    sanitized.removeWhere((key, _) => sensitiveKeys.contains(key.toLowerCase()));
    return sanitized;
  }

  Future<String> saveRecordingPermanently(String tempPath) async {
    if (kIsWeb) {
      return tempPath;
    }
    final docDir = await getApplicationDocumentsDirectory();
    final queueDir = Directory('${docDir.path}/offline_recordings');
    if (!await queueDir.exists()) {
      await queueDir.create(recursive: true);
    }
    final fileName = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final permanentPath = '${queueDir.path}/$fileName';
    await File(tempPath).copy(permanentPath);
    return permanentPath;
  }

  Future<String> enqueueRecording({
    required String sessionId,
    required String localPath,
    int? questionId,
  }) async {
    final permanentPath = await saveRecordingPermanently(localPath);
    final id = 'queue_${DateTime.now().millisecondsSinceEpoch}_${sessionId.substring(0, sessionId.length > 6 ? 6 : sessionId.length)}';

    await _db.into(_db.queueItems).insert(
          QueueItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            questionId: Value(questionId),
            audioPath: permanentPath,
            createdAt: DateTime.now(),
            status: const Value('pending'),
          ),
        );
    return id;
  }

  Future<List<QueueItem>> getPendingQueue() async {
    return (_db.select(_db.queueItems)
          ..where((tbl) => tbl.status.equals('pending'))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .get();
  }

  Stream<int> watchPendingCount() {
    return (_db.select(_db.queueItems)..where((tbl) => tbl.status.equals('pending')))
        .watch()
        .map((items) => items.length);
  }

  Future<int> getPendingCount() async {
    final items = await getPendingQueue();
    return items.length;
  }

  Future<List<TurnOut>> processPendingQueue() async {
    final queue = await getPendingQueue();
    if (queue.isEmpty) return [];

    final results = <TurnOut>[];

    for (final item in queue) {
      final file = File(item.audioPath);
      if (!file.existsSync()) {
        // Audio file missing, remove from queue
        await (_db.delete(_db.queueItems)..where((tbl) => tbl.id.equals(item.id))).go();
        continue;
      }

      try {
        final turn = await _apiClient.submitAnswer(
          sessionId: item.sessionId,
          audioPath: item.audioPath,
          questionId: item.questionId,
        );
        results.add(turn);

        // Save local turn record in Drift
        await _db.into(_db.turnsLocal).insert(
              TurnsLocalCompanion.insert(
                sessionId: item.sessionId,
                questionId: Value(item.questionId),
                questionText: 'Turno #${item.questionId ?? 1}',
                transcript: turn.transcript,
                audioPath: Value(item.audioPath),
                score: Value(turn.evaluation.overall_score.toDouble()),
                createdAt: DateTime.now(),
              ),
            );

        // Delete audio file from disk
        try {
          await file.delete();
        } catch (_) {}

        // Remove from queue table
        await (_db.delete(_db.queueItems)..where((tbl) => tbl.id.equals(item.id))).go();
      } catch (e) {
        // Increment retry count and save error
        await (_db.update(_db.queueItems)..where((tbl) => tbl.id.equals(item.id))).write(
          QueueItemsCompanion(
            retryCount: Value(item.retryCount + 1),
            lastError: Value(e.toString()),
          ),
        );
      }
    }

    return results;
  }
}
