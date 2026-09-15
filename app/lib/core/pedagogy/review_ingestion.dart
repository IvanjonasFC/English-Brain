/// Bridges any tab's mistakes/doubts into the transversal FSRS deck.
/// Online: posts to the backend generalized ingest endpoint.
/// Offline-first: also writes a local FSRS card so it surfaces immediately.
library;

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../network/api_client.dart';
import 'contracts.dart';
import 'taxonomy.dart';

class ReviewIngestionService {
  final AppDatabase _db;
  final ApiClient _api;

  ReviewIngestionService(this._db, this._api);

  /// Ingest a batch of review items for [userId]. Best-effort online push;
  /// always persisted locally so the deck works offline.
  Future<int> ingest(String userId, List<ReviewItem> items) async {
    var count = 0;
    for (final item in items) {
      await _persistLocal(userId, item);
      try {
        await _api.ingestReviewCard(item.toJson());
      } catch (_) {
        // Offline / server unreachable: the local card is enough; sync later.
      }
      count++;
    }
    return count;
  }

  static int _localIdCounter = 0;

  Future<void> _persistLocal(String userId, ReviewItem item) async {
    final now = DateTime.now();
    final uniqueId = -(now.microsecondsSinceEpoch * 100 + ((_localIdCounter++) % 100));
    await _db.into(_db.cardsLocal).insert(
          CardsLocalCompanion.insert(
            // Local-only cards use a negative id to avoid colliding with server ids.
            id: Value(uniqueId),
            front: item.front,
            back: item.back,
            stability: 0.0,
            difficulty: 0.0,
            elapsedDays: 0,
            scheduledDays: 0,
            reps: 0,
            lapses: 0,
            state: 0, // New
            dueDate: now,
            updatedAt: now,
            sourceType: Value(item.sourceType.id),
            itemType: Value(item.itemType.id),
            unitOrPackId: Value(item.unitOrPackId),
            skill: Value(item.skill.id),
            userId: Value(userId),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
