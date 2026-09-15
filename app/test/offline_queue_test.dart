import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/models/api_models.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/audio/offline_queue_service.dart';
import 'package:app/core/storage/secure_storage_service.dart';
import 'package:app/core/storage/local_cache_service.dart';

class MockQueueApiClient extends ApiClient {
  MockQueueApiClient()
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );

  int submitCalls = 0;
  bool shouldFail = false;

  @override
  Future<TurnOut> submitAnswer({
    required String sessionId,
    required String audioPath,
    int? questionId,
  }) async {
    submitCalls++;
    if (shouldFail) {
      throw HumanizedApiException('Network connection failed');
    }

    return TurnOut(
      id: 101,
      session_id: sessionId,
      question_id: questionId,
      transcript: 'I have worked with Flutter for three years.',
      ai_reply_text: 'Excellent explanation.',
      ai_reply_audio_url: null,
      evaluation: const LLMEvaluationResult(
        interviewer_reply: 'Excellent explanation.',
        overall_score: 9,
        fluency_feedback: 'Very natural response.',
        grammar_corrections: [],
        vocabulary_suggestions: [],
      ),
      created_at: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineQueueService with Drift SQLite Database', () {
    late AppDatabase db;
    late MockQueueApiClient mockApi;
    late OfflineQueueService queueService;
    late File dummyAudioFile;

    setUp(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async {
          return Directory.systemTemp.path;
        },
      );

      db = AppDatabase(NativeDatabase.memory());
      mockApi = MockQueueApiClient();
      queueService = OfflineQueueService(db, mockApi);

      dummyAudioFile = File('${Directory.systemTemp.path}/test_offline_audio.m4a');
      await dummyAudioFile.writeAsString('audio-sample-binary-content');
    });

    tearDown(() async {
      await db.close();
      if (dummyAudioFile.existsSync()) {
        await dummyAudioFile.delete();
      }
    });

    test('Enqueue audio saves to queue_items table with pending status', () async {
      expect(await queueService.getPendingCount(), 0);

      final queueId = await queueService.enqueueRecording(
        sessionId: 'sess-offline-01',
        localPath: dummyAudioFile.path,
        questionId: 42,
      );

      expect(queueId.startsWith('queue_'), isTrue);
      expect(await queueService.getPendingCount(), 1);

      final pending = await queueService.getPendingQueue();
      expect(pending.length, 1);
      expect(pending.first.sessionId, 'sess-offline-01');
      expect(pending.first.questionId, 42);
      expect(pending.first.status, 'pending');
      expect(pending.first.retryCount, 0);
    });

    test('Process queue handles failure by incrementing retryCount and retaining item', () async {
      await queueService.enqueueRecording(
        sessionId: 'sess-offline-02',
        localPath: dummyAudioFile.path,
        questionId: 10,
      );

      // Simulate failure on first attempt
      mockApi.shouldFail = true;
      final resultsFail = await queueService.processPendingQueue();
      expect(resultsFail.isEmpty, isTrue);
      expect(mockApi.submitCalls, 1);

      // Verify item still pending but retryCount incremented
      final pendingAfterFail = await queueService.getPendingQueue();
      expect(pendingAfterFail.length, 1);
      expect(pendingAfterFail.first.retryCount, 1);
      expect(pendingAfterFail.first.lastError, contains('Network connection failed'));

      // Simulate network restored on second attempt
      mockApi.shouldFail = false;
      final resultsSuccess = await queueService.processPendingQueue();
      expect(resultsSuccess.length, 1);
      expect(resultsSuccess.first.transcript, 'I have worked with Flutter for three years.');
      expect(mockApi.submitCalls, 2);

      // Verify queue is now drained and turn saved in SQLite turns_local
      expect(await queueService.getPendingCount(), 0);

      final localTurns = await db.select(db.turnsLocal).get();
      expect(localTurns.length, 1);
      expect(localTurns.first.transcript, 'I have worked with Flutter for three years.');
    });
  });
}
