import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/audio/offline_queue_service.dart';
import 'package:app/core/resources/resource_repository.dart';

void main() {
  group('Offline-First Resources & Sync Queue Test Suite', () {
    late AppDatabase db;
    late ResourceRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = ResourceRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('OfflineQueueService.sanitizeHeaders strips sensitive tokens', () {
      final rawHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer secret_token_123',
        'X-Api-Key': 'my_super_secret_nas_key',
        'Cookie': 'session=abc',
        'X-Request-Id': 'req_456',
      };

      final sanitized = OfflineQueueService.sanitizeHeaders(rawHeaders);

      // Verify sensitive keys removed
      expect(sanitized.containsKey('Authorization'), isFalse);
      expect(sanitized.containsKey('X-Api-Key'), isFalse);
      expect(sanitized.containsKey('Cookie'), isFalse);

      // Verify safe operational headers preserved
      expect(sanitized['Content-Type'], 'application/json');
      expect(sanitized['Accept'], 'application/json');
      expect(sanitized['X-Request-Id'], 'req_456');
    });

    test('ResourceRepository imports snapshot JSON into local Drift DB without network', () async {
      const sampleSnapshot = '''
      {
        "version": "v202609081700",
        "exported_at": "2026-09-08T15:00:00Z",
        "resource_count": 2,
        "collection_count": 2,
        "collections": [
          {
            "id": "tech-podcasts",
            "name": "Podcasts de Ingeniería",
            "description": "Listening técnico",
            "icon": "podcasts",
            "color": "#0D9488",
            "order_index": 1
          },
          {
            "id": "speaking-tools",
            "name": "Herramientas de Pronunciación",
            "description": "Fonética nativa",
            "icon": "record_voice_over",
            "color": "#F59E0B",
            "order_index": 2
          }
        ],
        "resources": [
          {
            "id": "res-sed-1",
            "title": "Software Engineering Daily",
            "original_url": "https://softwareengineeringdaily.com/",
            "source_name": "awesome-english",
            "resource_type": "podcast",
            "skill": "listening",
            "domain": "tech_english",
            "level": "B1-B2",
            "tags": ["tech", "podcast", "backend"],
            "transcript_available": true,
            "spanish_support": false,
            "estimated_minutes": 25,
            "recommended_for": "Escucha activa de arquitectura",
            "spanish_notes": "Excelente para familiarizarse con vocabulario de sistemas.",
            "collection_id": "tech-podcasts"
          },
          {
            "id": "res-yg-2",
            "title": "YouGlish",
            "original_url": "https://youglish.com/",
            "source_name": "awesome-english",
            "resource_type": "tool",
            "skill": "speaking",
            "domain": "tech_english",
            "level": "All",
            "tags": ["pronunciation", "tool"],
            "transcript_available": false,
            "spanish_support": true,
            "estimated_minutes": 5,
            "recommended_for": "Pronunciación en contexto de YouTube",
            "spanish_notes": "Buscador de términos técnicos pronunciados por nativos.",
            "collection_id": "speaking-tools"
          }
        ],
        "unit_links": [
          {
            "id": 1,
            "resource_id": "res-sed-1",
            "target_type": "pack",
            "target_id": "backend",
            "relevance_note": "Recomendado para el pack backend"
          },
          {
            "id": 2,
            "resource_id": "res-yg-2",
            "target_type": "unit",
            "target_id": "unit-1-junior",
            "relevance_note": "Recomendado para pronunciación de verbos en pasado"
          }
        ]
      }
      ''';

      final count = await repo.importSnapshotJson(sampleSnapshot);
      expect(count, 2);

      // Query from local Drift DB
      final backendResources = await repo.getResourcesForPack('backend');
      expect(backendResources.length, 1);
      expect(backendResources.first.title, 'Software Engineering Daily');
      expect(backendResources.first.resourceType, 'podcast');

      final unit1Resources = await repo.getResourcesForUnit('unit-1-junior');
      expect(unit1Resources.length, 1);
      expect(unit1Resources.first.title, 'YouGlish');
      expect(unit1Resources.first.resourceType, 'tool');
    });

    test('ResourceRepository records usage telemetry offline in Drift', () async {
      final logId = await repo.logUsage(
        resourceId: 'res-sed-1',
        unitId: 'unit-1-junior',
        eventType: 'open',
        durationSeconds: 120,
      );

      expect(logId, greaterThan(0));

      final logs = await db.select(db.resourceUsageLogsLocal).get();
      expect(logs.length, 1);
      expect(logs.first.resourceId, 'res-sed-1');
      expect(logs.first.durationSeconds, 120);
      expect(logs.first.isSynced, isFalse);
    });
  });
}
