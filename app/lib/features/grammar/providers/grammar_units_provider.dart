import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/database/app_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../grammar_models.dart';

/// Grammar units.
///
/// Local-first (stale-while-revalidate): the first render NEVER waits on the
/// network. Content is served instantly from the persisted cache, or — on a
/// fresh install — from the bundled asset (kept in sync with the backend by
/// tools/sync_offline_seeds.py), or finally from the compiled-in seed. The
/// backend is fetched in the background and only updates the cache, so fresh
/// content lands on the next open. This avoids the multi-second spinner the
/// Dio retry backoff (1s/2s/5s) would otherwise cause when the backend is slow
/// or unreachable.
final grammarUnitsProvider = FutureProvider<List<GrammarUnit>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final cache = ref.watch(localCacheProvider);
  const cacheKey = AppConstants.keyCacheGrammar;

  List<GrammarUnit> parse(List<dynamic> raw) =>
      raw.map((e) => GrammarUnit.fromJson(e as Map<String, dynamic>)).toList();

  // Background revalidation: fetch the backend and refresh the cache for the
  // next open. Fire-and-forget — never blocks the UI.
  Future<void> revalidate() async {
    try {
      final res = await api.dio.get('/api/packs/grammar');
      final data = res.data;
      if (data is List && data.isNotEmpty) {
        await cache.saveContentList(cacheKey, data);
      }
    } catch (_) {
      // Offline / backend down: keep whatever is cached.
    }
  }

  // 1) Persisted cache (last known good) -> instant.
  final cached = await cache.getContentList(cacheKey);
  if (cached.isNotEmpty) {
    try {
      final models = parse(cached);
      unawaited(revalidate());
      return models;
    } catch (_) {
      // Cache written by an older schema: ignore and use the asset.
    }
  }

  // 2) Bundled offline asset -> instant on a fresh install. Seed the cache.
  try {
    final decoded = jsonDecode(await rootBundle.loadString('assets/seed/grammar.json'));
    if (decoded is List && decoded.isNotEmpty) {
      await cache.saveContentList(cacheKey, decoded);
      final models = parse(decoded);
      unawaited(revalidate());
      return models;
    }
  } catch (_) {}

  // 3) Compiled-in seed (ultimate net).
  unawaited(revalidate());
  return allGrammarUnits;
});

/// Pull-to-refresh: force a backend fetch, update the cache, then rebuild the
/// provider so it re-reads the freshened cache. Safe from a RefreshIndicator;
/// on failure the existing cache is left untouched.
Future<void> refreshGrammar(WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  final cache = ref.read(localCacheProvider);
  try {
    final res = await api.dio.get('/api/packs/grammar');
    final data = res.data;
    if (data is List && data.isNotEmpty) {
      await cache.saveContentList(AppConstants.keyCacheGrammar, data);
    }
  } catch (_) {}
  ref.invalidate(grammarUnitsProvider);
  await ref.read(grammarUnitsProvider.future);
}

/// Progreso local de las unidades de gramática.
///
/// Lee [GrammarProgressLocal] (y como fallback [PracticeAttemptsLocal] track=grammar)
/// para el usuario activo. Devuelve un mapa unitId → GrammarUnitProgress.
class GrammarUnitProgress {
  final bool isCompleted;
  final double lastScore;   // 0.0 – 1.0
  final double bestScore;   // 0.0 – 1.0
  final int attempts;
  final DateTime? completedAt;

  const GrammarUnitProgress({
    this.isCompleted = false,
    this.lastScore = 0.0,
    this.bestScore = 0.0,
    this.attempts = 0,
    this.completedAt,
  });
}

final grammarUnitProgressProvider = FutureProvider<Map<String, GrammarUnitProgress>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final userId = ref.watch(activeUserIdProvider);

  // 1. GrammarProgressLocal (populated by grammar_drill_runner when completed)
  final grammarRows = await (db.select(db.grammarProgressLocal)
        ..where((t) => t.userId.equals(userId)))
      .get();

  final Map<String, GrammarUnitProgress> result = {
    for (final r in grammarRows)
      r.unitId: GrammarUnitProgress(
        isCompleted: r.isCompleted,
        lastScore: r.lastScore,
        bestScore: r.bestScore,
        attempts: r.attemptsCount,
        completedAt: r.completedAt,
      ),
  };

  // 2. PracticeAttemptsLocal (fallback: all grammar attempts even before
  //    GrammarProgressLocal was populated)
  final attemptRows = await (db.select(db.practiceAttemptsLocal)
        ..where((t) => t.userId.equals(userId) & t.track.equals('grammar'))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  for (final row in attemptRows) {
    if (!result.containsKey(row.objectiveId)) {
      result[row.objectiveId] = GrammarUnitProgress(
        isCompleted: row.score >= 0.7,
        lastScore: row.score,
        bestScore: row.score,
        attempts: 1,
      );
    }
  }

  return result;
});
