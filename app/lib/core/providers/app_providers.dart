import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../storage/local_cache_service.dart';
import '../network/api_client.dart';
import '../network/connectivity_service.dart';
import '../audio/offline_queue_service.dart';
import '../audio/pronunciation_queue_service.dart';
import '../audio/audio_recorder_controller.dart';
import '../audio/audio_player_controller.dart';
import '../audio/audio_prefetch_service.dart';
import '../audio/pronunciation_evaluator.dart';

import '../database/app_database.dart';
import '../pedagogy/practice_service.dart';
import '../pedagogy/review_ingestion.dart';
import '../services/ai_service.dart';
import '../services/sync_service.dart';
import '../services/journal_service.dart';
import '../services/milestone_service.dart';
import '../services/measurement_service.dart';
import '../models/measurement_models.dart';
import '../resources/resource_repository.dart';
import '../profile/profile_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final localCacheProvider = Provider<LocalCacheService>((ref) {
  return LocalCacheService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final secure = ref.watch(secureStorageProvider);
  final cache = ref.watch(localCacheProvider);
  return ApiClient(secureStorage: secure, cacheService: cache);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final api = ref.watch(apiClientProvider);
  final service = ConnectivityService(api);
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStateProvider = StreamProvider<ConnectivityState>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

final offlineQueueProvider = Provider<OfflineQueueService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  return OfflineQueueService(db, api);
});

final pronunciationQueueProvider = Provider<PronunciationQueueService>((ref) {
  final api = ref.watch(apiClientProvider);
  final conn = ref.watch(connectivityServiceProvider);
  final service = PronunciationQueueService(api, connectivity: conn);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Evaluador ÚNICO de pronunciación (checkPronunciation + cola offline con una
/// sola política). Todas las pantallas lo usan para comportarse igual.
final pronunciationEvaluatorProvider = Provider<PronunciationEvaluator>((ref) {
  final api = ref.watch(apiClientProvider);
  final queue = ref.watch(pronunciationQueueProvider);
  final practice = ref.watch(practiceServiceProvider);
  return PronunciationEvaluator(api, queue, practice);
});

final pronunciationQueueCountProvider = StreamProvider<int>((ref) {
  final q = ref.watch(pronunciationQueueProvider);
  return q.pendingCountStream;
});

final pendingQueueCountStreamProvider = StreamProvider<int>((ref) {
  final queueService = ref.watch(offlineQueueProvider);
  return queueService.watchPendingCount();
});

final syncServiceProvider = Provider<DatabaseSyncService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  final queue = ref.watch(offlineQueueProvider);
  final pronQueue = ref.watch(pronunciationQueueProvider);
  return DatabaseSyncService(db, api, queue, pronQueue);
});

final databaseSyncServiceProvider = syncServiceProvider;

final journalServiceProvider = Provider<JournalService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  return JournalService(db, api);
});

final milestoneServiceProvider = Provider<MilestoneService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MilestoneService(db);
});

final dueCardsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final rows = await db.select(db.cardsLocal).get();
  final now = DateTime.now();
  int count = 0;
  for (final c in rows) {
    if (!c.dueDate.isAfter(now)) {
      count++;
    }
  }
  return count;
});

final audioRecorderProvider = ChangeNotifierProvider.autoDispose<AudioRecorderController>((ref) {
  return AudioRecorderController();
});

final audioPrefetchProvider = Provider<AudioPrefetchService>((ref) {
  final api = ref.watch(apiClientProvider);
  return AudioPrefetchService(api);
});

final audioPlayerProvider = ChangeNotifierProvider<AudioPlayerController>((ref) {
  final cache = ref.watch(localCacheProvider);
  return AudioPlayerController(cacheService: cache);
});

final resourceRepositoryProvider = Provider<ResourceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  final repo = ResourceRepository(db, api);
  repo.initializeFromLocalSnapshotIfNeeded();
  return repo;
});

final activeUserIdProvider = StateProvider<String>((ref) {
  return 'user-ivan';
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  final secure = ref.watch(secureStorageProvider);
  return ProfileRepository(db, api, secure);
});

final pronunciationProgressProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final uid = ref.watch(activeUserIdProvider);
  return api.getPronunciationProgress(uid);
});

final activeProfileProvider = FutureProvider.autoDispose<UserProfilesLocalData>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final uid = ref.watch(activeUserIdProvider);
  return repo.getActiveUserProfile(uid);
});

final profileSummaryProvider = FutureProvider.autoDispose<ProfileSummaryData>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final activeUserId = ref.watch(activeUserIdProvider);
  return repo.getProfileSummary(activeUserId);
});

/// Controls the app locale dynamically.
/// Default: Spanish ('es'). Can be changed from Profile/Settings screen.
final themeIsLightProvider = StateProvider<bool>((ref) => false);

final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('es');
});

/// Control global del tamaño de contenido y escala de texto (0.9x compacto, 1.0x estándar, 1.15x grande, 1.25x muy grande)
final textScaleFactorProvider = StateProvider<double>((ref) => 1.0);

// ===== Pedagogy engine (Fase 1-2) =====
final practiceServiceProvider = Provider<PracticeService>((ref) {
  return PracticeService(ref.watch(appDatabaseProvider));
});

final reviewIngestionProvider = Provider<ReviewIngestionService>((ref) {
  return ReviewIngestionService(
    ref.watch(appDatabaseProvider),
    ref.watch(apiClientProvider),
  );
});

// ===== IA (worker GPU: grammar-check / vocabulary / analyze-audio) =====
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(api: ref.watch(apiClientProvider));
});

final measurementServiceProvider = Provider<MeasurementService>((ref) {
  final api = ref.watch(apiClientProvider);
  final cache = ref.watch(localCacheProvider);
  return MeasurementService(api, cache);
});

final voiceMeasurementProfileProvider =
    FutureProvider.autoDispose<List<MeasurementProfileEntry>>((ref) async {
  final service = ref.watch(measurementServiceProvider);
  final uid = ref.watch(activeUserIdProvider);
  return service.profile(uid);
});

