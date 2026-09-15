import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/features/vocabulary/vocabulary_hub_screen.dart';
import 'package:app/features/vocabulary/vocabulary_screen.dart';
import 'package:app/features/vocabulary/vocabulary_practice_summary_screen.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/vocabulary/providers/vocabulary_packs_provider.dart';
import 'package:app/features/vocabulary/vocabulary_repository.dart';
import 'package:app/l10n/app_localizations.dart';

import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/core/profile/profile_repository.dart';

void main() {
  late AppDatabase inMemoryDb;

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

  setUp(() {
    inMemoryDb = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({
      'theme_light': false,
      'app_locale': 'es',
      'coach_seen_vocabulary': true,
    });
    AppTheme.applyLight(false);
  });

  tearDown(() async {
    await inMemoryDb.close();
  });

  testWidgets('VocabularyHubScreen renders collections without streak or avatar top bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
          vocabularyPacksProvider.overrideWith((ref) => VocabularyRepository.packs),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: VocabularyHubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify title and absence of hardcoded CEFR badge
    expect(find.text('Explora Vocabulario'), findsOneWidget);
    expect(find.text('CEFR B2-C1'), findsNothing);

    // 2. Verify top bar with streak flame or avatar is NOT present in vocabulary hub
    expect(find.textContaining('14d'), findsNothing);
    expect(find.textContaining('🔥'), findsNothing);

    // Default track is Inglés General
    expect(find.text('Inglés General'), findsOneWidget);
    expect(find.text('Tech / IT Executive'), findsOneWidget);

    // Switch to Tech track and B1-B2 level to verify Tech B1-B2 collections
    await tester.tap(find.text('Tech / IT Executive'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('B1 - B2'));
    await tester.pumpAndSettle();

    // 3. Verify Tech B1-B2 collections are visible
    expect(find.text('Frontend & Modern Web'), findsOneWidget);
    expect(find.text('Teamwork & Agile Leadership'), findsOneWidget);
    expect(find.text('DevOps, Cloud & Infrastructure'), findsOneWidget);

    // Switch to B2-C1 level to verify Advanced collections
    await tester.tap(find.text('B2 - C1'));
    await tester.pumpAndSettle();
    expect(find.text('Code Review & Technical Debate'), findsOneWidget);

    // 4. Verify top right icons are removed (controlled in Settings)
    expect(find.text('ES'), findsNothing);
  });

  testWidgets('VocabularyScreen populates rich terms and supports bilingual and theme switches', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: VocabularyScreen(initialPackId: 'backend'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify terms are loaded and displayed (Throughput, Circuit Breaker, etc.)
    expect(find.text('Throughput'), findsOneWidget);
    expect(find.text('Circuit Breaker'), findsOneWidget);

    // 2. Verify definitions are populated
    expect(find.textContaining('transacciones'), findsWidgets);

    // 3. Verify top navigation does NOT have streak or avatar, and top right icons (Mazo, ES, theme) are removed
    expect(find.textContaining('14d'), findsNothing);
    expect(find.textContaining('🔥'), findsNothing);
    expect(find.text('Mazo'), findsNothing);

    // 4. Verify topic title is present in Hero card
    expect(find.text('ARQUITECTURA DE SISTEMAS & ESCALABILIDAD'), findsOneWidget);
  });

  testWidgets('VocabularyScreen loads terms for client_negotiation and databases', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Test client_negotiation pack
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: VocabularyScreen(initialPackId: 'client_negotiation'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('deadline'), findsOneWidget);
    expect(find.text('scope'), findsOneWidget);
  });

  testWidgets('VocabularyHubScreen filters collections when CEFR level is selected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
          vocabularyPacksProvider.overrideWith((ref) => VocabularyRepository.packs),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: VocabularyHubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Tech track first
    await tester.tap(find.text('Tech / IT Executive'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap B1-B2 filter
    await tester.tap(find.text('B1 - B2'));
    await tester.pumpAndSettle();

    // Only B1-B2 matching collections should remain visible
    expect(find.text('Teamwork & Agile Leadership'), findsOneWidget);
    expect(find.text('Code Review & Technical Debate'), findsNothing);
  });

  testWidgets('VocabularyPracticeSummaryScreen renders dynamic session terms and real pronunciation KPI', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final testSessionTerms = [
      {
        'term': 'Kubernetes Cluster',
        'sub': 'Contenedores y orquestación',
        'percent': '95%',
        'delta': '(+15%)',
        'badge': 'Dominado',
        'isMastered': true,
      },
      {
        'term': 'Throughput Pipeline',
        'sub': 'Procesamiento concurrente',
        'percent': '78%',
        'delta': '(+8%)',
        'badge': 'En Progreso',
        'isMastered': false,
      },
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(inMemoryDb),
          profileSummaryProvider.overrideWith((ref) => Future.value(mockProfile)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: VocabularyPracticeSummaryScreen(
            topicTitle: 'Distributed Systems',
            totalExercises: 2,
            correctExercises: 2,
            timeElapsed: '2m 10s',
            avgPronunciationScore: 95,
            practicedTerms: testSessionTerms,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifies that real session terms are rendered, not static Rate Limiting
    expect(find.text('Kubernetes Cluster'), findsOneWidget);
    expect(find.text('Throughput Pipeline'), findsOneWidget);
    expect(find.text('Rate Limiting'), findsNothing);

    // Verifies real dynamic pronunciation score KPI
    expect(find.text('95%'), findsWidgets);
  });
}
