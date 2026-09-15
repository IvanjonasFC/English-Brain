import 'package:drift/drift.dart';
import '../audio/offline_queue_service.dart';
import '../audio/pronunciation_queue_service.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';

class SyncResult {
  final int uploadedAudios;
  final int syncedCards;
  final bool success;
  final String? message;

  SyncResult({
    required this.uploadedAudios,
    required this.syncedCards,
    required this.success,
    this.message,
  });
}

class DatabaseSyncService {
  final AppDatabase _db;
  final ApiClient _apiClient;
  final OfflineQueueService _offlineQueueService;
  final PronunciationQueueService? _pronunciationQueueService;

  DatabaseSyncService(
    this._db,
    this._apiClient,
    this._offlineQueueService, [
    this._pronunciationQueueService,
  ]);

  Future<SyncResult> syncAll() async {
    int uploadedCount = 0;
    int cardsCount = 0;

    try {
      // 1. App manda en audios en cola (drenar cola local de entrevistas al backend)
      final uploadedTurns = await _offlineQueueService.processPendingQueue();
      uploadedCount = uploadedTurns.length;

      // 1b. Drenar cola unificada de pronunciación (vocabulario, gramática, comprensión)
      if (_pronunciationQueueService != null) {
        await _pronunciationQueueService.processPending();
      }

      // 2. Subir reviews locales pendientes si las hubiera
      final pendingReviews = await (_db.select(_db.reviewLogsLocal)
            ..where((tbl) => tbl.isSynced.equals(false)))
          .get();

      for (final rev in pendingReviews) {
        try {
          await _apiClient.reviewCard(rev.cardId, rev.rating);
          await (_db.update(_db.reviewLogsLocal)..where((tbl) => tbl.id.equals(rev.id))).write(
            const ReviewLogsLocalCompanion(isSynced: Value(true)),
          );
        } catch (_) {
          // Mantener pendiente si falla
        }
      }

      // 3. El backend manda en datos de FSRS (descargar estado maestro de tarjetas)
      final masterCards = await _apiClient.getCards(dueOnly: false);
      cardsCount = masterCards.length;

      for (final card in masterCards) {
        final scheduledDays = card.due_date.difference(DateTime.now()).inDays;
        await _db.into(_db.cardsLocal).insertOnConflictUpdate(
              CardsLocalCompanion.insert(
                id: Value(card.id),
                mistakeId: Value(card.mistake_id),
                front: card.front,
                back: card.back,
                stability: card.stability,
                difficulty: card.difficulty,
                elapsedDays: 0,
                scheduledDays: scheduledDays > 0 ? scheduledDays : 1,
                reps: card.reps,
                lapses: card.lapses,
                state: card.state,
                lastReview: Value(card.last_review),
                dueDate: card.due_date,
                updatedAt: DateTime.now(),
              ),
            );
      }

      return SyncResult(
        uploadedAudios: uploadedCount,
        syncedCards: cardsCount,
        success: true,
        message: 'Sincronización completada exitosamente.',
      );
    } catch (e) {
      return SyncResult(
        uploadedAudios: uploadedCount,
        syncedCards: cardsCount,
        success: false,
        message: 'Error durante la sincronización: $e',
      );
    }
  }

  // Get local cards for offline reviews
  Future<List<CardsLocalData>> getDueCardsLocal() async {
    final now = DateTime.now();
    return (_db.select(_db.cardsLocal)
          ..where((tbl) => tbl.dueDate.isSmallerOrEqualValue(now))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.dueDate)]))
        .get();
  }
}
