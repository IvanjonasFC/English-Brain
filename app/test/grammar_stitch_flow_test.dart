import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/grammar/grammar_hub_screen.dart';
import 'package:app/features/grammar/grammar_screen.dart';
import 'package:app/features/grammar/grammar_drill_runner.dart';
import 'package:app/features/grammar/grammar_practice_summary_screen.dart';
import 'package:app/features/grammar/grammar_models.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/features/grammar/providers/grammar_units_provider.dart';
import 'package:app/l10n/app_localizations.dart';

import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/storage/secure_storage_service.dart';
import 'package:app/core/storage/local_cache_service.dart';

import 'package:app/core/profile/profile_repository.dart';

class MockGrammarApiClient extends ApiClient {
  MockGrammarApiClient()
      : super(
          secureStorage: SecureStorageService(),
          cacheService: LocalCacheService(),
        );

  @override
  Future<Map<String, dynamic>?> grammarCheck(String text) async {
    return {
      'is_correct': true,
      'explanation': 'La estructura seleccionada es correcta y concisa.',
      'corrected': text,
      'cefr_level': 'B2',
    };
  }
}

void main() {
  late AppDatabase inMemoryDb;

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await inMemoryDb.close();
  });

  final mockProfile = ProfileSummaryData(
    profile: UserProfilesLocalData(
      id: 'test_user',
      displayName: 'Iván',
      targetLevel: 'B2',
      roleTitle: 'Software Engineer',
      learningGoal: 'interview_prep',
      dailyGoalMinutes: 30,
      totalXp: 100,
      streakDays: 5,
      createdAt: DateTime(2026, 1, 1),
      isCurrent: true,
    ),
    totalXp: 100,
    weeklyXp: 50,
    streakDays: 5,
    totalMinutes: 30,
    totalSessions: 4,
    completedUnits: 2,
    masteredWords: 10,
    speakingClarityScore: 85,
    listeningScore: 85,
    skills: const SkillScoresData(),
    achievements: const [],
    activity30d: const [],
    weeklyActivity: const [],
  );

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(inMemoryDb),
        profileSummaryProvider.overrideWith((ref) => Future.value(mockProfile)),
        themeIsLightProvider.overrideWith((ref) => true),
        localeProvider.overrideWith((ref) => const Locale('es')),
        apiClientProvider.overrideWithValue(MockGrammarApiClient()),
        grammarUnitProgressProvider.overrideWith((ref) => Future.value({})),
        grammarUnitsProvider.overrideWith((ref) => allGrammarUnits),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: child,
      ),
    );
  }

  group('Grammar Stitch Workflow & Clean Header Tests', () {
    testWidgets('1. GrammarHubScreen renders clean header, track switcher, CEFR rail, and unit cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(const GrammarHubScreen()));
      await tester.pumpAndSettle();

      // Header limpio estilo Vocabulario: Explora Gramática, sin barra duplicada ni iconos
      expect(find.text('Explora Gramática'), findsOneWidget);
      expect(find.textContaining('Estructuras de alto impacto'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsNothing);

      // Track switcher idéntico a Vocabulario
      expect(find.text('Inglés General'), findsOneWidget);
      expect(find.text('Tech / IT Executive'), findsOneWidget);

      // CEFR level rail: solo selectores por dificultad (sin 'Todos')
      expect(find.text('Todos'), findsNothing);
      expect(find.text('A1 - A2'), findsWidgets);
      expect(find.text('B1 - B2'), findsWidgets);
      expect(find.text('B2 - C1'), findsWidgets);
      expect(find.text('C1 Executive'), findsWidgets);

      // Priority hero card & action
      expect(find.text('UNIDAD PRIORITARIA • IA'), findsOneWidget);
      expect(find.text('Empezar Práctica'), findsOneWidget);

      // Filter chips & units
      expect(find.text('Unidades de Gramática'), findsOneWidget);
      expect(find.text('Pendientes'), findsOneWidget);
      expect(find.text('Dominadas'), findsOneWidget);

      // Switch to Tech track to verify Tech unit cards
      await tester.tap(find.text('Tech / IT Executive'));
      await tester.pumpAndSettle();

      // Unit card action buttons
      expect(find.text('Guía'), findsWidgets);
      expect(find.textContaining('Practicar ('), findsWidgets);
    });


    testWidgets('2. GrammarScreen renders Executive Guide with Golden Rule, Comparative Matrix, and STAR Formula', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(GrammarScreen(unit: allGrammarUnits.first)));
      await tester.pumpAndSettle();

      // Clean header
      expect(find.text('Guía De Unidad De Gramática'), findsOneWidget);

      // Reading time and return
      expect(find.text('Volver a Gramática'), findsOneWidget);
      expect(find.text('3 min lectura'), findsOneWidget);

      // Hero & Golden rule
      expect(find.text('GUÍA EJECUTIVA STAR'), findsOneWidget);
      expect(find.text('Regla de Oro Ejecutiva'), findsOneWidget);

      // Comparative Matrix
      expect(find.text('Matriz Comparativa Ejecutiva'), findsOneWidget);
      expect(find.text('OPCIÓN CONFUSA / PENALIZADA'), findsOneWidget);
      expect(find.text('OPCIÓN DE ALTO IMPACTO (PAST SIMPLE)'), findsOneWidget);
      expect(find.text('OPCIÓN DE ALTO IMPACTO (PRESENT PERFECT)'), findsOneWidget);

      // STAR Syntactic Formula
      expect(find.text('Fórmula Sintáctica STAR'), findsOneWidget);
      expect(find.text('[Sujeto ‘I’]'), findsOneWidget);
      expect(find.text('[Past Simple Fuerte]'), findsOneWidget);

      // Avoid Passive voice
      expect(find.text('Evita la Trampa: “Passive Voice”'), findsOneWidget);
      expect(find.text('PASIVO / DILUIDO'), findsOneWidget);
      expect(find.text('ACTIVO / LIDERAZGO'), findsOneWidget);

      // Sticky dock button
      expect(find.text('Comenzar Drills Prácticos'), findsOneWidget);
    });

    testWidgets('3. GrammarDrillRunner executes interactive drill with STAR scenario and immediate feedback', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(GrammarDrillRunner(unit: allGrammarUnits.first)));
      await tester.pumpAndSettle();

      // Status bar elements
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('5 Días'), findsOneWidget);
      expect(find.text('Situación & Acción STAR'), findsOneWidget);

      // Select correct option
      final correctOpt = allGrammarUnits.first.questions.first.correctAnswer;
      final optFinder = find.text(correctOpt);
      expect(optFinder, findsOneWidget);
      await tester.tap(optFinder);
      await tester.pumpAndSettle();

      // Immediate feedback card appears (idéntico a la imagen de vocabulario)
      expect(find.text('¡Exacto!'), findsOneWidget);
      expect(find.textContaining('La estructura correcta es «rerouted»'), findsOneWidget);
      expect(find.text('Pronunciation practice'), findsOneWidget);
      expect(find.text('Hear model'), findsOneWidget);
      expect(find.text('Slow (0.8×)'), findsOneWidget);
      expect(find.text('Record'), findsOneWidget);
      expect(find.text('My recording'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget); // Botón de traducción al inglés
      expect(find.textContaining('Siguiente Drill'), findsOneWidget);

      // Probar toggle de traducción al inglés
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('ES'), findsOneWidget);
    });

    testWidgets('4. GrammarPracticeSummaryScreen renders FSRS sync card, KPIs, and rule mastery', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestApp(GrammarPracticeSummaryScreen(
        unit: allGrammarUnits.first,
        totalQuestions: 5,
        correctAnswers: 5,
        timeElapsed: '3m 45s',
      )));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Resumen De Sesión Gramatical'), findsOneWidget);
      expect(find.text('Drill Finalizado'), findsOneWidget);

      // Hero Card
      expect(find.textContaining('¡Sesión Gramatical Consolidada'), findsOneWidget);
      expect(find.text('CEFR BENCHMARK'), findsOneWidget);
      expect(find.text('+8% precisión'), findsOneWidget);

      // KPIs
      expect(find.text('Precisión Verbal'), findsOneWidget);
      expect(find.text('Claridad Fonética'), findsOneWidget);
      expect(find.text('5/5 Ok'), findsOneWidget);

      // FSRS v5 sync card
      expect(find.text('Memoria Gramatical Sincronizada'), findsOneWidget);
      expect(find.text('Estabilidad +0.40'), findsOneWidget);
      expect(find.text('Ver reglas en Mazo FSRS'), findsOneWidget);

      // Rule mastery & AI coach tip
      expect(find.text('DESGLOSE DE REGLAS PRACTICADAS'), findsOneWidget);
      expect(find.text('Consejo Táctico para Entrevistas (STAR)'), findsOneWidget);

      // Sticky action dock
      expect(find.text('Continuar al Catálogo de Gramática'), findsOneWidget);
      expect(find.text('Reforzar regla en Modo Relámpago'), findsOneWidget);
    });
  });
}
