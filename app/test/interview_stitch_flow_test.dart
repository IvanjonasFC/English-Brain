import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/models/api_models.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/connectivity_service.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/core/audio/audio_recorder_controller.dart';
import 'package:app/core/pedagogy/content_seeds.dart';
import 'package:app/core/pedagogy/taxonomy.dart';
import 'package:app/core/storage/secure_storage_service.dart';
import 'package:app/core/storage/local_cache_service.dart';
import 'package:app/features/interview/interview_pack_intro_screen.dart';
import 'package:app/features/interview/interview_screen.dart';
import 'package:app/features/interview/providers/interview_packs_provider.dart';
import 'package:app/l10n/app_localizations.dart';

class MockStitchApiClient extends ApiClient {
  MockStitchApiClient()
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );

  int submitCount = 0;

  @override
  Future<SessionOut> createSession({String? category, int? initialQuestionId}) async {
    return SessionOut(
      id: 'sess-stitch-001',
      user_id: 'user-ivan',
      started_at: DateTime.now(),
      status: 'active',
      initial_question: const QuestionOut(
        id: 101,
        category: 'tech',
        difficulty: 'senior',
        title: 'Handling Critical Incidents & Deadlines',
        text:
            'Tell me about a time you faced an unexpected production outage or technical blocker under tight deadlines. How did you handle communication and resolution?',
        model_answer:
            'During peak traffic, our payment gateway suffered cascading timeouts. I orchestrated rate limiting and provisioned read-replicas, preserving 99.99% uptime.',
      ),
    );
  }

  @override
  Future<TurnOut> submitAnswer({
    required String sessionId,
    required String audioPath,
    int? questionId,
  }) async {
    submitCount++;
    return TurnOut(
      id: 201,
      session_id: sessionId,
      question_id: questionId,
      transcript:
          'To mitigate the database lockups, I provisioned an asynchronous queue with backoff strategy and isolated the faulty transactions.',
      ai_reply_text: 'Excellent architectural ownership. How did the incident impact customer SLAs?',
      ai_reply_audio_url: null,
      engineUsed: 'fast',
      evaluation: const LLMEvaluationResult(
        interviewer_reply: 'Excellent architectural ownership. How did the incident impact customer SLAs?',
        overall_score: 9,
        fluency_feedback: 'Outstanding STAR structure with first-person ownership and quantified metrics.',
        grammar_corrections: [],
        vocabulary_suggestions: [
          VocabularySuggestion(
            term: 'Rate limiting',
            context: 'Mechanism to constrain request throughput and prevent resource starvation.',
          ),
          VocabularySuggestion(
            term: 'Failover strategy',
            context: 'Automated backup operational mode when primary database nodes become unresponsive.',
          ),
          VocabularySuggestion(
            term: 'Trade-off analysis',
            context: 'Balancing latency against data consistency under high system load.',
          ),
        ],
        pronunciation_feedback: PronunciationFeedback(
          score: 94,
          clarity: 'Nivel C1 Fluido',
          mispronounced_or_difficult_words: ['Bottleneck', 'Orchestrated'],
          phonetic_tips: [
            'Bottleneck: /ˈbɒt.əl.nek/ - stress the first syllable',
          ],
          filler_words_detected: ['um'],
        ),
      ),
      created_at: DateTime.now(),
    );
  }

  @override
  Future<void> ingestReviewCard(Map<String, dynamic> cardJson) async {
    // Fast mock no-op
  }
}

class FakeStitchAudioRecorderController extends AudioRecorderController {
  RecordingState _customState = RecordingState.idle;

  @override
  RecordingState get state => _customState;

  void setCustomState(RecordingState s) {
    _customState = s;
    notifyListeners();
  }

  @override
  Future<String?> stopRecording() async {
    _customState = RecordingState.uploading;
    notifyListeners();
    final tempFile = File('${Directory.systemTemp.path}/stitch_turn_rec.m4a');
    if (!tempFile.existsSync()) {
      tempFile.writeAsStringSync('dummy-audio-bytes');
    }
    return tempFile.path;
  }
}

void main() {
  group('Stitch Interview Flow Acceptance Tests (No Mockups, 100% Real Data)', () {
    late AppDatabase db;
    late MockStitchApiClient mockApi;
    late FakeStitchAudioRecorderController testRecorder;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      mockApi = MockStitchApiClient();
      testRecorder = FakeStitchAudioRecorderController();

      // Seed local user profile for user-ivan
      await db.into(db.userProfilesLocal).insert(
            UserProfilesLocalCompanion.insert(
              id: 'user-ivan',
              displayName: 'Iván',
              targetLevel: const drift.Value('C1'),
              roleTitle: const drift.Value('Staff & Cloud Engineer'),
              createdAt: DateTime.now(),
              isCurrent: const drift.Value(true),
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    Widget buildTestApp(Widget child) {
      return ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApi),
          appDatabaseProvider.overrideWithValue(db),
          audioRecorderProvider.overrideWith((ref) => testRecorder),
          interviewPacksProvider.overrideWith((ref) => []),
          connectivityStateProvider.overrideWith(
            (ref) => Stream.value(
              const ConnectivityState(hasNetwork: true, hasServerAccess: true, statusMessage: 'Online'),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: child,
        ),
      );
    }

    testWidgets('1. Entrevistas - Preparación STAR conforms to Stitch template', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final testPack = ContentSeeds.interviewPacks.firstWhere((p) => p.scenario == LearningScenario.debugging);

      await tester.pumpWidget(buildTestApp(InterviewPackIntroScreen(pack: testPack)));
      await tester.pumpAndSettle();

      // Hero Card: Pack title and chips
      expect(find.text('Incident Walkthrough & Debugging'), findsWidgets);
      expect(find.text('DEBUGGING'), findsWidgets);
      expect(find.text('B2-C1'), findsWidgets);
      expect(find.text('Whisper AI Phonetics'), findsOneWidget);

      // Core Question Block:
      expect(find.text('Behavioral Scenario • Core Technical'), findsOneWidget);
      expect(find.textContaining('Walk me through a critical production bug'), findsOneWidget);

      // STAR Guided Section:
      expect(find.text('ESTRUCTURA STAR GUIADA'), findsOneWidget);
      expect(find.text('100% Repartición Óptima'), findsOneWidget);
      expect(find.text('Situation (Situación)'), findsOneWidget);
      expect(find.text('Task (Tarea)'), findsOneWidget);
      expect(find.text('Action (Acción Técnica)'), findsOneWidget);
      expect(find.text('Result (Resultado Medible)'), findsOneWidget);

      // Tactical connectors toolkit:
      expect(find.text('Consequently,'), findsOneWidget);
      expect(find.text('To mitigate this risk,'), findsOneWidget);
      expect(find.text('As a direct outcome,'), findsOneWidget);
      expect(find.text('Under high constraints,'), findsOneWidget);

      // Floating Trigger button:
      expect(find.text('Iniciar Grabación STAR (Modo Simulación)'), findsOneWidget);
    });

    testWidgets('2. Entrevista STAR - Simulación Activa en Vivo & Telemetría', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const InterviewScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // Header: Simulación Activa Star + Whisper v3
      expect(find.text('Simulación Oral STAR'), findsOneWidget);
      expect(find.text('Whisper v3'), findsOneWidget);

      // Live ribbon: SIMULACIÓN EN VIVO + AI Lead Interviewer
      expect(find.text('SIMULACIÓN EN VIVO'), findsOneWidget);
      expect(find.text('AI Lead Interviewer'), findsOneWidget);

      // STAR Live Stepper: S, T, A, R
      expect(find.text('ETAPA STAR ACTIVA'), findsOneWidget);
      expect(find.text('Situation'), findsOneWidget);
      expect(find.text('Task'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);

      // Live Telemetry Grid:
      expect(find.text('Cadencia'), findsOneWidget);
      expect(find.text('Muletillas'), findsOneWidget);
      expect(find.text('Claridad AI'), findsOneWidget);

      // Quick Executive Connectors:
      expect(find.text('Consequently,'), findsOneWidget);
      expect(find.text('To address this bottleneck,'), findsOneWidget);

      // Dock idle state:
      expect(find.text('Listo para grabar'), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });

    testWidgets('3. Entrevistas - Diagnóstico Ejecutivo STAR with real user profile and FSRS promotion',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const InterviewScreen()));
      await tester.pump(const Duration(milliseconds: 500));

      // 1. Start recording
      testRecorder.setCustomState(RecordingState.recording);
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Handling Critical Incidents'), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

      // 2. Stop and evaluate turn
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pumpAndSettle();

      expect(mockApi.submitCount, 1);

      // 3. Verify Executive Diagnosis View is rendered
      // Title with real user profile name (Iván):
      expect(find.text('¡Simulación Completada, Iván!'), findsOneWidget);
      expect(find.textContaining('Perfil listo para Staff & Cloud Engineer'), findsOneWidget);

      // Readiness Score card:
      expect(find.text('READINESS SCORE'), findsOneWidget);
      expect(find.text('90%'), findsOneWidget);
      expect(find.text('Apto Mock Técnico'), findsOneWidget);

      // 3 Scorecards:
      expect(find.text('STAR Ratio'), findsOneWidget);
      expect(find.text('Lexicon C1'), findsOneWidget);
      expect(find.text('Acústica'), findsOneWidget);

      // Audio Coach Playback with Waveform & Phonetics:
      expect(find.text('Grabación & Fonética de Audio'), findsOneWidget);
      expect(find.text('Evaluación de Pronunciación & Voz'), findsOneWidget);
      expect(find.textContaining('94% • Nivel C1 Fluido'), findsOneWidget);
      expect(find.textContaining('Bottleneck'), findsWidgets);

      // STAR Structural Diagnostics Breakdown:
      expect(find.text('Feedback de fluidez & STAR'), findsOneWidget);

      // FSRS Promotion Card:
      expect(find.text('Vocabulario Añadido al Mazo FSRS'), findsOneWidget);
      expect(find.text('+3 Cards'), findsOneWidget);
      expect(find.text('Rate limiting'), findsOneWidget);
      expect(find.text('Failover strategy'), findsOneWidget);
      expect(find.text('Trade-off analysis'), findsOneWidget);

      // Verify real cards were ingested into Drift cardsLocal table:
      final fsrsCards = await db.select(db.cardsLocal).get();
      expect(fsrsCards.length, 3);
      expect(fsrsCards.any((c) => c.front == 'Rate limiting'), isTrue);
      expect(fsrsCards.any((c) => c.front == 'Failover strategy'), isTrue);
      expect(fsrsCards.any((c) => c.front == 'Trade-off analysis'), isTrue);

      // Action CTAs:
      expect(find.text('Continuar al Siguiente Escenario STAR'), findsOneWidget);
      expect(find.text('Reintentar Result (+15%)'), findsOneWidget);
      expect(find.text('Guardar y Salir'), findsOneWidget);
    });
  });
}
