import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../vocabulary_repository.dart';

/// Vocabulary packs.
///
/// Local-first (stale-while-revalidate): the first render NEVER waits on the
/// network. Content is served instantly from the persisted cache, or — on a
/// fresh install — from the bundled asset (kept in sync with the backend by
/// tools/sync_offline_seeds.py), or finally from the compiled-in seed. The
/// backend is fetched in the background and only updates the cache, so fresh
/// content lands on the next open. This avoids the multi-second spinner the
/// Dio retry backoff (1s/2s/5s) would otherwise cause when the backend is slow
/// or unreachable.
final vocabularyPacksProvider = FutureProvider<List<VocabularyPack>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final cache = ref.watch(localCacheProvider);
  const cacheKey = AppConstants.keyCacheVocabulary;

  List<VocabularyPack> parse(List<dynamic> raw) =>
      raw.map((e) => VocabularyPack.fromJson(e as Map<String, dynamic>)).toList();

  // Background revalidation: fetch the backend and refresh the cache for the
  // next open. Fire-and-forget — never blocks the UI.
  Future<void> revalidate() async {
    try {
      final res = await api.dio.get('/api/packs/vocabulary');
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
    final decoded = jsonDecode(await rootBundle.loadString('assets/seed/vocab.json'));
    if (decoded is List && decoded.isNotEmpty) {
      await cache.saveContentList(cacheKey, decoded);
      final models = parse(decoded);
      unawaited(revalidate());
      return models;
    }
  } catch (_) {}

  // 3) Compiled-in seed (ultimate net).
  unawaited(revalidate());
  return VocabularyRepository.packs;
});

/// Pull-to-refresh: force a backend fetch, update the cache, then rebuild the
/// provider so it re-reads the freshened cache. Safe from a RefreshIndicator;
/// on failure the existing cache is left untouched.
Future<void> refreshVocabulary(WidgetRef ref) async {
  final api = ref.read(apiClientProvider);
  final cache = ref.read(localCacheProvider);
  try {
    final res = await api.dio.get('/api/packs/vocabulary');
    final data = res.data;
    if (data is List && data.isNotEmpty) {
      await cache.saveContentList(AppConstants.keyCacheVocabulary, data);
    }
  } catch (_) {}
  ref.invalidate(vocabularyPacksProvider);
  await ref.read(vocabularyPacksProvider.future);
}
