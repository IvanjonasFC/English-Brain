import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';

class ResourceRepository {
  final AppDatabase _db;
  final ApiClient? _apiClient;

  ResourceRepository(this._db, [this._apiClient]);

  AppDatabase get db => _db;

  /// Loads published resources from local asset snapshot if Drift database is empty.
  Future<void> initializeFromLocalSnapshotIfNeeded() async {
    final count = await (_db.select(_db.resourcesLocal)).get();
    if (count.isEmpty) {
      await importSnapshotFromAsset();
    }
  }

  /// Imports snapshot JSON string directly into Drift tables.
  Future<int> importSnapshotJson(String jsonString) async {
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final collections = data['collections'] as List<dynamic>? ?? [];
    final resources = data['resources'] as List<dynamic>? ?? [];
    final links = data['unit_links'] as List<dynamic>? ?? [];

    await _db.batch((batch) {
      // 1. Insert Collections
      for (final c in collections) {
        final col = c as Map<String, dynamic>;
        batch.insert(
          _db.resourceCollectionsLocal,
          ResourceCollectionsLocalCompanion.insert(
            id: col['id'] as String,
            name: col['name'] as String,
            description: Value(col['description'] as String?),
            icon: Value(col['icon'] as String? ?? 'bookmark'),
            color: Value(col['color'] as String? ?? '#0D9488'),
            orderIndex: Value(col['order_index'] as int? ?? 0),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      // 2. Insert Resources
      for (final r in resources) {
        final res = r as Map<String, dynamic>;
        batch.insert(
          _db.resourcesLocal,
          ResourcesLocalCompanion.insert(
            id: res['id'] as String,
            title: res['title'] as String,
            originalUrl: res['original_url'] as String,
            sourceName: res['source_name'] as String? ?? 'awesome-english',
            resourceType: res['resource_type'] as String? ?? 'tool',
            skill: res['skill'] as String? ?? 'listening',
            domain: res['domain'] as String? ?? 'tech_english',
            level: res['level'] as String? ?? 'B1-B2',
            tagsJson: json.encode(res['tags'] ?? []),
            transcriptAvailable: Value(res['transcript_available'] as bool? ?? false),
            spanishSupport: Value(res['spanish_support'] as bool? ?? false),
            estimatedMinutes: Value(res['estimated_minutes'] as int? ?? 15),
            recommendedFor: Value(res['recommended_for'] as String?),
            spanishNotes: Value(res['spanish_notes'] as String?),
            collectionId: Value(res['collection_id'] as String?),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }

      // 3. Insert Unit Links
      for (final l in links) {
        final link = l as Map<String, dynamic>;
        batch.insert(
          _db.unitResourceLinksLocal,
          UnitResourceLinksLocalCompanion.insert(
            resourceId: link['resource_id'] as String,
            targetType: link['target_type'] as String,
            targetId: link['target_id'] as String,
            relevanceNote: Value(link['relevance_note'] as String?),
          ),
        );
      }
    });

    return resources.length;
  }

  /// Imports from the bundled Flutter asset seed.
  Future<int> importSnapshotFromAsset() async {
    try {
      final content = await rootBundle.loadString('assets/seed/published_snapshot.json');
      return await importSnapshotJson(content);
    } catch (e) {
      return 0;
    }
  }

  /// Watch all collections sorted by orderIndex.
  Stream<List<ResourceCollectionsLocalData>> watchCollections() {
    return (_db.select(_db.resourceCollectionsLocal)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.orderIndex)]))
        .watch();
  }

  /// Watch resources belonging to a collection.
  Stream<List<ResourcesLocalData>> watchResourcesByCollection(String collectionId) {
    return (_db.select(_db.resourcesLocal)
          ..where((tbl) => tbl.collectionId.equals(collectionId)))
        .watch();
  }

  /// Get resources belonging to a collection (one-shot Future).
  Future<List<ResourcesLocalData>> getResourcesByCollection(String collectionId) {
    return (_db.select(_db.resourcesLocal)
          ..where((tbl) => tbl.collectionId.equals(collectionId)))
        .get();
  }

  /// Fetch companion resources for a specific unit (e.g. 'unit-1-junior').
  Future<List<ResourcesLocalData>> getResourcesForUnit(String unitId) async {
    final links = await (_db.select(_db.unitResourceLinksLocal)
          ..where((tbl) => tbl.targetType.equals('unit') & tbl.targetId.equals(unitId)))
        .get();

    if (links.isEmpty) return [];
    final resIds = links.map((l) => l.resourceId).toList();
    return (_db.select(_db.resourcesLocal)..where((tbl) => tbl.id.isIn(resIds))).get();
  }

  /// Fetch companion resources for a specific pack (e.g. 'backend').
  Future<List<ResourcesLocalData>> getResourcesForPack(String packId) async {
    final links = await (_db.select(_db.unitResourceLinksLocal)
          ..where((tbl) => tbl.targetType.equals('pack') & tbl.targetId.equals(packId)))
        .get();

    if (links.isEmpty) return [];
    final resIds = links.map((l) => l.resourceId).toList();
    return (_db.select(_db.resourcesLocal)..where((tbl) => tbl.id.isIn(resIds))).get();
  }

  /// Logs interaction telemetry in local Drift table first (offline-first).
  Future<int> logUsage({
    required String resourceId,
    String? unitId,
    String eventType = 'open',
    int durationSeconds = 0,
  }) async {
    final id = await _db.into(_db.resourceUsageLogsLocal).insert(
          ResourceUsageLogsLocalCompanion.insert(
            resourceId: resourceId,
            unitId: Value(unitId),
            eventType: Value(eventType),
            durationSeconds: Value(durationSeconds),
            createdAt: DateTime.now(),
            isSynced: const Value(false),
          ),
        );

    // Try background sync if client available
    _syncSingleUsage(resourceId, unitId, eventType, durationSeconds, id);
    return id;
  }

  Future<void> _syncSingleUsage(
    String resourceId,
    String? unitId,
    String eventType,
    int durationSeconds,
    int localId,
  ) async {
    if (_apiClient == null) return;
    try {
      await _apiClient.dio.post(
        '/api/resources/usage',
        data: {
          'resource_id': resourceId,
          'unit_id': unitId,
          'event_type': eventType,
          'duration_seconds': durationSeconds,
        },
      );
      await (_db.update(_db.resourceUsageLogsLocal)..where((tbl) => tbl.id.equals(localId))).write(
        const ResourceUsageLogsLocalCompanion(isSynced: Value(true)),
      );
    } catch (_) {
      // Stays in local Drift with isSynced=false to drain later
    }
  }

  /// Synchronize from backend /api/resources/sync/snapshot if online.
  Future<bool> syncFromBackend() async {
    if (_apiClient == null) return false;
    try {
      final response = await _apiClient.dio.get('/api/resources/sync/snapshot');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        await importSnapshotJson(json.encode(response.data));
        return true;
      }
    } catch (_) {
      // Offline: keep working with local Drift seamlessly
    }
    return false;
  }
}
