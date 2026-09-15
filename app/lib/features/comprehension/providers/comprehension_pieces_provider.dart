import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/database/app_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../comprehension_models.dart';

/// Reading & Listening pieces.
///
/// Local-first (stale-while-revalidate): the first render NEVER waits on the
/// network. Content is served instantly from the persisted cache, or — on a
/// fresh install — from the bundled asset (kept in sync with the backend by
/// tools/sync_offline_seeds.py), or finally from the compiled-in seed. The
/// backend is fetched in the background and only updates the cache, so fresh
/// content lands on the next open. This avoids the multi-second spinner the
/// Dio retry backoff (1s/2s/5s) would otherwise cause when the backend is slow
/// or unreachable.
final comprehensionPiecesProvider = FutureProvider<List<ComprehensionPiece>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final cache = ref.watch(localCacheProvider);
  const cacheKey = AppConstants.keyCacheComprehension;

  List<ComprehensionPiece> parse(List<dynamic> raw) =>
      raw.map((e) => ComprehensionPiece.fromJson(e as Map<String, dynamic>)).toList();

  // Background revalidation: fetch the backend and refresh the cache for the
  // next open. Fire-and-forget — never blocks the UI.
  Future<void> revalidate() async {
    try {
      final res = await api.dio.get('/api/comprehension');
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
    final decoded = jsonDecode(await rootBundle.loadString('assets/seed/comprehension.json'));
    if (decoded is List && decoded.isNotEmpty) {
      await cache.saveContentList(cacheKey, decoded);
      final models = parse(decoded);
      unawaited(revalidate());
      return models;
    }
  } catch (_) {}

  // 3) Compiled-in seed (ultimate net).
  unawaited(revalidate());
  return allComprehensionPieces;
});

/// Pull-to-refresh: force a backend fetch, update the cache, then rebuild the
/// provider so it re-reads the freshened cache. Safe from a RefreshIndicator;
/// on failure the existing cache is left untouched.
Future<void> refreshComprehension(WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  final cache = ref.read(localCacheProvider);
  try {
    final res = await api.dio.get('/api/comprehension');
    final data = res.data;
    if (data is List && data.isNotEmpty) {
      await cache.saveContentList(AppConstants.keyCacheComprehension, data);
    }
  } catch (_) {}
  ref.invalidate(comprehensionPiecesProvider);
  await ref.read(comprehensionPiecesProvider.future);
}

/// Progreso local de las piezas de comprensión.
///
/// Lee [PracticeAttemptsLocal] filtrado por track='listening' para el usuario
/// activo y devuelve un mapa pieceId → lastScore (0.0–1.0).
/// El score del intento más reciente es el que se muestra en el hub.
final comprehensionAttemptsProvider = FutureProvider<Map<String, double>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final userId = ref.watch(activeUserIdProvider);

  final rows = await (db.select(db.practiceAttemptsLocal)
        ..where((t) => t.userId.equals(userId) & t.track.equals('listening'))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();

  // pieceId → score del intento más reciente (orderBy desc garantiza el orden)
  final Map<String, double> result = {};
  for (final row in rows) {
    if (!result.containsKey(row.objectiveId)) {
      result[row.objectiveId] = row.score;
    }
  }
  return result;
});
