import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:app/core/database/app_database.dart';
import 'package:app/core/providers/app_providers.dart';
import 'package:app/core/profile/profile_repository.dart';
import 'package:app/features/profile/profile_screen.dart';
import 'package:app/l10n/app_localizations.dart';

ProfileSummaryData createMockSummary({
  required String id,
  required String name,
  required String role,
  required String level,
  required int goalMinutes,
  required int totalXp,
  required int streak,
}) {
  return ProfileSummaryData(
    profile: UserProfilesLocalData(
      id: id,
      displayName: name,
      targetLevel: level,
      roleTitle: role,
      learningGoal: 'interview_prep',
      dailyGoalMinutes: goalMinutes,
      totalXp: totalXp,
      streakDays: streak,
      createdAt: DateTime(2026, 1, 1),
      isCurrent: true,
    ),
    totalXp: totalXp,
    weeklyXp: 145,
    streakDays: streak,
    totalMinutes: 240,
    totalSessions: 14,
    completedUnits: 18,
    masteredWords: 42,
    speakingClarityScore: 84,
    listeningScore: 88,
    skills: const SkillScoresData(),
    achievements: const [
      UserAchievementData(
        badgeKey: 'first_interview',
        title: 'Primer Paso STAR',
        description: 'Completaste tu primera respuesta en mock interview',
        iconName: 'mic',
        category: 'interview',
        progress: 1.0,
        isUnlocked: true,
      ),
      UserAchievementData(
        badgeKey: 'streak_7',
        title: 'Racha de Fuego',
        description: 'Mantén 7 días consecutivos de práctica activa',
        iconName: 'local_fire_department',
        category: 'streak',
        progress: 0.71,
        isUnlocked: false,
      ),
    ],
    activity30d: const [
      DailyActivityData(
        date: '2026-09-08',
        xpEarned: 35,
        minutesSpent: 20,
        sessionsCount: 2,
        wordsPracticed: 12,
        grammarDrillsCount: 8,
      ),
    ],
    weeklyActivity: const [
      {'date': '2026-09-02', 'day': 'Mié', 'xp': 25, 'turns': 1, 'minutes': 15},
      {'date': '2026-09-03', 'day': 'Jue', 'xp': 30, 'turns': 1, 'minutes': 20},
      {'date': '2026-09-04', 'day': 'Vie', 'xp': 35, 'turns': 2, 'minutes': 20},
      {'date': '2026-09-05', 'day': 'Sáb', 'xp': 10, 'turns': 1, 'minutes': 10},
      {'date': '2026-09-06', 'day': 'Dom', 'xp': 0, 'turns': 0, 'minutes': 0},
      {'date': '2026-09-07', 'day': 'Lun', 'xp': 25, 'turns': 1, 'minutes': 15},
      {'date': '2026-09-08', 'day': 'Mar', 'xp': 35, 'turns': 2, 'minutes': 20},
    ],
    syncStatus: 'synced',
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Profile Screen & Multi-User Test Suite', () {
    testWidgets('ProfileScreen renders header, global progress, quick stats, skills, calendar, badges, and settings', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            activeUserIdProvider.overrideWith((ref) => 'user-ivan'),
            profileSummaryProvider.overrideWith((ref) async => createMockSummary(
                  id: 'user-ivan',
                  name: 'Iván',
                  role: 'Senior Tech & Cloud Engineer',
                  level: 'B2',
                  goalMinutes: 20,
                  totalXp: 420,
                  streak: 5,
                )),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1200));

      // 1. Header verification
      expect(find.text('Iván'), findsOneWidget);
      expect(find.text('Senior Tech & Cloud Engineer'), findsOneWidget);
      expect(find.text('20 min/día'), findsOneWidget);

      // 2. Global Progress
      expect(find.text('Progreso Global & Experiencia'), findsOneWidget);
      expect(find.text('Total XP'), findsOneWidget);
      expect(find.text('XP Semanal'), findsOneWidget);
      expect(find.text('Racha'), findsOneWidget);

      // 3. Quick Stats (6 Key Learning Metrics)
      expect(find.text('Métricas Clave de Aprendizaje'), findsOneWidget);
      expect(find.text('Sesiones STAR'), findsOneWidget);
      expect(find.text('Gramática CEFR'), findsOneWidget);
      expect(find.text('Vocabulario Dominado'), findsOneWidget);
      expect(find.text('Comprensión & Audio'), findsOneWidget);
      expect(find.text('Precisión Global'), findsOneWidget);
      expect(find.text('Retención FSRS'), findsOneWidget);

      // 4. Module Progress & Coverage
      expect(find.text('Cobertura y Progreso por Módulos'), findsOneWidget);
      expect(find.text('Simulador STAR & Fluidez'), findsOneWidget);
      expect(find.text('Vocabulario Técnico'), findsOneWidget);
      expect(find.text('Gramática Estructural'), findsOneWidget);
      expect(find.text('Comprensión Lectora & Audio'), findsOneWidget);
      expect(find.text('Mazo de Repaso FSRS'), findsOneWidget);

      // 5. Activity Calendar & Heatmap
      expect(find.text('Consistencia & Actividad'), findsOneWidget);
      expect(find.text('Heatmap 30 Días'), findsOneWidget);

      // 6. Settings Modal (open via top gear action)
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Configuración del Sistema & Cuenta'), findsWidgets);
      expect(find.text('Motor de Audio & Pronunciación'), findsOneWidget);
      expect(find.text('Sincronización con NAS'), findsOneWidget);
      expect(find.text('Exportar Diario & Flashcards'), findsOneWidget);
      expect(find.text('Administrar Perfiles Multiusuario'), findsOneWidget);
    });

    testWidgets('Multi-user profile switching updates profile identity', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Render profile with Elena as active user
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            activeUserIdProvider.overrideWith((ref) => 'user-elena'),
            profileSummaryProvider.overrideWith((ref) async => createMockSummary(
                  id: 'user-elena',
                  name: 'Elena',
                  role: 'Distributed Systems Architect',
                  level: 'C1',
                  goalMinutes: 30,
                  totalXp: 180,
                  streak: 2,
                )),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 1200));

      // Verify Elena identity
      expect(find.text('Elena'), findsOneWidget);
      expect(find.text('Distributed Systems Architect'), findsOneWidget);
      expect(find.text('30 min/día'), findsOneWidget);
      expect(find.text('Iván'), findsNothing);
    });
  });
}
