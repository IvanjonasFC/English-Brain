import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';

class SkillScoresData {
  final int grammarScore;
  final int vocabularyScore;
  final int listeningScore;
  final int speakingScore;
  final String grammarLevel;
  final String vocabularyLevel;
  final String listeningLevel;
  final String speakingLevel;

  const SkillScoresData({
    this.grammarScore = 0,
    this.vocabularyScore = 0,
    this.listeningScore = 0,
    this.speakingScore = 0,
    this.grammarLevel = 'B2',
    this.vocabularyLevel = 'B2',
    this.listeningLevel = 'B2',
    this.speakingLevel = 'B2',
  });

  factory SkillScoresData.fromJson(Map<String, dynamic> json) {
    return SkillScoresData(
      grammarScore: json['grammar_score'] ?? 0,
      vocabularyScore: json['vocabulary_score'] ?? 0,
      listeningScore: json['listening_score'] ?? 0,
      speakingScore: json['speaking_score'] ?? 0,
      grammarLevel: json['grammar_level'] ?? 'B2',
      vocabularyLevel: json['vocabulary_level'] ?? 'B2',
      listeningLevel: json['listening_level'] ?? 'B2',
      speakingLevel: json['speaking_level'] ?? 'B2',
    );
  }
}

class UserAchievementData {
  final String badgeKey;
  final String title;
  final String description;
  final String iconName;
  final String category;
  final double progress;
  final bool isUnlocked;

  const UserAchievementData({
    required this.badgeKey,
    required this.title,
    required this.description,
    required this.iconName,
    required this.category,
    required this.progress,
    required this.isUnlocked,
  });

  factory UserAchievementData.fromDrift(UserAchievementsLocalData row) {
    return UserAchievementData(
      badgeKey: row.badgeKey,
      title: row.title,
      description: row.description,
      iconName: row.iconName,
      category: row.category,
      progress: row.progress,
      isUnlocked: row.isUnlocked,
    );
  }

  factory UserAchievementData.fromJson(Map<String, dynamic> json) {
    return UserAchievementData(
      badgeKey: json['badge_key'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'star',
      category: json['category'] ?? 'general',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      isUnlocked: json['is_unlocked'] ?? false,
    );
  }
}

class DailyActivityData {
  final String date;
  final int xpEarned;
  final int minutesSpent;
  final int sessionsCount;
  final int wordsPracticed;
  final int grammarDrillsCount;

  const DailyActivityData({
    required this.date,
    required this.xpEarned,
    required this.minutesSpent,
    required this.sessionsCount,
    required this.wordsPracticed,
    required this.grammarDrillsCount,
  });

  factory DailyActivityData.fromJson(Map<String, dynamic> json) {
    return DailyActivityData(
      date: json['date'] ?? '',
      xpEarned: json['xp_earned'] ?? 0,
      minutesSpent: json['minutes_spent'] ?? 0,
      sessionsCount: json['sessions_count'] ?? 0,
      wordsPracticed: json['words_practiced'] ?? 0,
      grammarDrillsCount: json['grammar_drills_count'] ?? 0,
    );
  }
}

class ProfileSummaryData {
  final UserProfilesLocalData profile;
  final int totalXp;
  final int weeklyXp;
  final int streakDays;
  final int totalMinutes;
  final int totalSessions;
  final int completedUnits;
  final int masteredWords;
  final int speakingClarityScore;
  final int listeningScore;
  final int completedPieces;      // piezas de comprensión completadas
  final int avgComprehensionScore; // accuracy media (0-100) en esas piezas
  final SkillScoresData skills;
  final List<UserAchievementData> achievements;
  final List<DailyActivityData> activity30d;
  final List<Map<String, dynamic>> weeklyActivity;
  final String syncStatus;

  const ProfileSummaryData({
    required this.profile,
    required this.totalXp,
    required this.weeklyXp,
    required this.streakDays,
    required this.totalMinutes,
    required this.totalSessions,
    required this.completedUnits,
    required this.masteredWords,
    required this.speakingClarityScore,
    required this.listeningScore,
    this.completedPieces = 0,
    this.avgComprehensionScore = 0,
    required this.skills,
    required this.achievements,
    required this.activity30d,
    required this.weeklyActivity,
    this.syncStatus = 'synced',
  });
}

class ProfileRepository {
  final AppDatabase _db;
  final ApiClient _apiClient;
  final SecureStorageService? _secureStorage;

  ProfileRepository(this._db, this._apiClient, [this._secureStorage]);

  static const List<Map<String, dynamic>> defaultDemoAchievements = [
    {
      'badgeKey': 'first_interview',
      'title': 'Primer Paso STAR',
      'description': 'Completaste tu primera respuesta en mock interview',
      'iconName': 'mic',
      'category': 'interview',
      'progress': 1.0,
      'isUnlocked': true,
    },
    {
      'badgeKey': 'streak_7',
      'title': 'Racha de Fuego',
      'description': 'Mantén 7 días consecutivos de práctica activa',
      'iconName': 'local_fire_department',
      'category': 'streak',
      'progress': 0.71,
      'isUnlocked': false,
    },
    {
      'badgeKey': 'fsrs_veteran',
      'title': 'Maestro de la Memoria',
      'description': '50 repasos espaciados con algoritmo FSRS',
      'iconName': 'style',
      'category': 'fsrs',
      'progress': 0.44,
      'isUnlocked': false,
    },
    {
      'badgeKey': 'grammar_ace',
      'title': 'Arquitecto Gramatical',
      'description': 'Supera 10 lecciones de gramática sin errores',
      'iconName': 'spellcheck',
      'category': 'grammar',
      'progress': 0.60,
      'isUnlocked': false,
    },
    {
      'badgeKey': 'vocab_master',
      'title': 'Léxico de Producción',
      'description': 'Domina 100 términos técnicos en tu mazo activo',
      'iconName': 'auto_stories',
      'category': 'vocab',
      'progress': 0.52,
      'isUnlocked': false,
    },
    {
      'badgeKey': 'speech_clarity',
      'title': 'Claridad Técnica 90+',
      'description': 'Obtén un 90%+ en fonética y fluidez',
      'iconName': 'record_voice_over',
      'category': 'speaking',
      'progress': 0.92,
      'isUnlocked': true,
    },
  ];

  /// Bootstrap local user profiles and seed data if database is empty.
  Future<void> ensureLocalUsers() async {
    final existing = await _db.select(_db.userProfilesLocal).get();
    final ivan = existing.where((u) => u.id == 'user-ivan').firstOrNull;
    final now = DateTime.now().toUtc();

    if (ivan == null) {
      await _db.into(_db.userProfilesLocal).insert(
        UserProfilesLocalCompanion.insert(
          id: 'user-ivan',
          displayName: 'Iván',
          email: const Value('ivan@dev.local'),
          avatarUrl: const Value('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80'),
          targetLevel: const Value('B2'),
          roleTitle: const Value('Senior Tech & Cloud Engineer'),
          learningGoal: const Value('interview_prep'),
          dailyGoalMinutes: const Value(20),
          totalXp: const Value(0),
          streakDays: const Value(0),
          lastActiveDate: Value(now),
          createdAt: now,
          isCurrent: const Value(true),
        ),
      );

      for (final ach in defaultDemoAchievements) {
        await _db.into(_db.userAchievementsLocal).insert(
          UserAchievementsLocalCompanion.insert(
            id: 'user-ivan:${ach['badgeKey']}',
            userId: 'user-ivan',
            badgeKey: ach['badgeKey'] as String,
            title: ach['title'] as String,
            description: ach['description'] as String,
            iconName: Value(ach['iconName'] as String),
            category: Value(ach['category'] as String),
            progress: const Value(0.0),
            isUnlocked: const Value(false),
            unlockedAt: const Value(null),
          ),
        );
      }
    }
  }

  /// Reset all metrics to a fresh zero start for Iván (local + backend).
  Future<void> resetToFreshStart() async {
    final now = DateTime.now().toUtc();
    try {
      await _apiClient.dio.post('/api/profile/reset?user_id=user-ivan').timeout(const Duration(seconds: 3));
    } catch (_) {
      // Offline fallback
    }

    await _db.delete(_db.practiceAttemptsLocal).go();
    await _db.delete(_db.unitProgressLocal).go();

    await (_db.update(_db.userProfilesLocal)..where((tbl) => tbl.id.equals('user-ivan'))).write(
      UserProfilesLocalCompanion(
        totalXp: const Value(0),
        streakDays: const Value(0),
        lastActiveDate: Value(now),
        isCurrent: const Value(true),
      ),
    );
    await (_db.update(_db.userAchievementsLocal)..where((tbl) => tbl.userId.equals('user-ivan'))).write(
      const UserAchievementsLocalCompanion(
        progress: Value(0.0),
        isUnlocked: Value(false),
        unlockedAt: Value(null),
      ),
    );
    await (_db.delete(_db.userActivityDailyLocal)..where((tbl) => tbl.userId.equals('user-ivan'))).go();
  }

  /// Create a brand-new local account and return it (not set as current yet).
  Future<UserProfilesLocalData> createUser({
    required String displayName,
    String? email,
    String roleTitle = 'English Learner',
    String targetLevel = 'B2',
    String learningGoal = 'interview_prep',
    int dailyGoalMinutes = 20,
  }) async {
    await ensureLocalUsers();
    final name = displayName.trim();
    var slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) slug = 'u';
    final id = 'user-$slug-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final now = DateTime.now().toUtc();
    
    await _db.into(_db.userProfilesLocal).insert(
          UserProfilesLocalCompanion.insert(
            id: id,
            displayName: name,
            email: Value(email),
            roleTitle: Value(roleTitle),
            targetLevel: Value(targetLevel),
            learningGoal: Value(learningGoal),
            dailyGoalMinutes: Value(dailyGoalMinutes),
            totalXp: const Value(0),
            streakDays: const Value(0),
            createdAt: now,
            isCurrent: const Value(false),
          ),
        );

    for (final ach in defaultDemoAchievements) {
      await _db.into(_db.userAchievementsLocal).insert(
        UserAchievementsLocalCompanion.insert(
          id: '$id:${ach['badgeKey']}',
          userId: id,
          badgeKey: ach['badgeKey'] as String,
          title: ach['title'] as String,
          description: ach['description'] as String,
          iconName: Value(ach['iconName'] as String),
          category: Value(ach['category'] as String),
          progress: const Value(0.0),
          isUnlocked: const Value(false),
          unlockedAt: const Value(null),
        ),
      );
    }

    // Also sync to backend so NAS knows about the new user immediately
    try {
      await _apiClient.dio.post(
        '/api/profile/users',
        data: {
          'id': id,
          'display_name': name,
          'role_title': roleTitle,
          'target_level': targetLevel,
          'learning_goal': learningGoal,
          'daily_goal_minutes': dailyGoalMinutes,
        },
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}

    return (_db.select(_db.userProfilesLocal)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Update user profile details (role, target level, learning goal, daily minutes).
  Future<void> updateUserProfile({
    required String userId,
    String? displayName,
    String? roleTitle,
    String? targetLevel,
    String? learningGoal,
    int? dailyGoalMinutes,
  }) async {
    await ensureLocalUsers();
    await (_db.update(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(userId))).write(
      UserProfilesLocalCompanion(
        displayName: displayName != null ? Value(displayName) : const Value.absent(),
        roleTitle: roleTitle != null ? Value(roleTitle) : const Value.absent(),
        targetLevel: targetLevel != null ? Value(targetLevel) : const Value.absent(),
        learningGoal: learningGoal != null ? Value(learningGoal) : const Value.absent(),
        dailyGoalMinutes: dailyGoalMinutes != null ? Value(dailyGoalMinutes) : const Value.absent(),
      ),
    );
  }

  /// List all cached users.
  Future<List<UserProfilesLocalData>> listUsers() async {
    await ensureLocalUsers();
    await _syncUsersFromBackend();
    return _db.select(_db.userProfilesLocal).get();
  }

  /// Trae del backend los usuarios creados en otros dispositivos (p.ej. web)
  /// y los inserta en la BD local para que aparezcan en el selector. No pisa
  Future<void> _syncUsersFromBackend() async {
    try {
      final res = await _apiClient.dio
          .get('/api/profile/users')
          .timeout(const Duration(seconds: 15));
      dynamic data = res.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is! List) return;
      final locals = await _db.select(_db.userProfilesLocal).get();
      final localIds = locals.map((u) => u.id).toSet();
      final now = DateTime.now().toUtc();
      for (final raw in data) {
        if (raw is! Map) continue;
        final id = (raw['id'] ?? '').toString();
        if (id.isEmpty) continue;
        final backendXp = (raw['total_xp'] as num?)?.toInt() ?? 0;
        final backendStreak = (raw['streak_days'] as num?)?.toInt() ?? 0;
        final backendRole = (raw['role_title'] ?? '').toString();
        final backendName = (raw['display_name'] ?? '').toString();
        final backendLevel = (raw['target_level'] ?? '').toString();
        final backendHasPin = raw['has_pin'] == true;
        if (backendHasPin && _secureStorage != null) {
          try {
            await _secureStorage.setServerHasPin(id, true);
          } catch (_) {}
        }

        if (localIds.contains(id)) {
          final local = locals.firstWhere((u) => u.id == id);
          final bestXp = local.totalXp > backendXp ? local.totalXp : backendXp;
          final bestStreak = local.streakDays > backendStreak ? local.streakDays : backendStreak;
          await (_db.update(_db.userProfilesLocal)..where((t) => t.id.equals(id))).write(
            UserProfilesLocalCompanion(
              totalXp: Value(bestXp),
              streakDays: Value(bestStreak),
              displayName: backendName.isNotEmpty ? Value(backendName) : const Value.absent(),
              roleTitle: backendRole.isNotEmpty ? Value(backendRole) : const Value.absent(),
              targetLevel: backendLevel.isNotEmpty ? Value(backendLevel) : const Value.absent(),
            ),
          );
          continue;
        }

        await _db.into(_db.userProfilesLocal).insert(
              UserProfilesLocalCompanion.insert(
                id: id,
                displayName: (raw['display_name'] ?? 'Usuario').toString(),
                email: Value(raw['email']?.toString()),
                avatarUrl: Value(raw['avatar_url']?.toString()),
                targetLevel: Value((raw['target_level'] ?? 'B2').toString()),
                roleTitle: Value((raw['role_title'] ?? 'English Learner').toString()),
                learningGoal:
                    Value((raw['learning_goal'] ?? 'interview_prep').toString()),
                dailyGoalMinutes:
                    Value((raw['daily_goal_minutes'] as num?)?.toInt() ?? 20),
                totalXp: Value(backendXp),
                streakDays: Value(backendStreak),
                createdAt: now,
                isCurrent: const Value(false),
              ),
            );
      }
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[_syncUsersFromBackend error] $e');
      }
      // Offline o backend caido: el selector sigue con los usuarios locales.
    }
  }

  /// Get the current active user profile.
  Future<UserProfilesLocalData> getActiveUserProfile([String? preferredUserId]) async {
    await ensureLocalUsers();
    if (preferredUserId != null) {
      final user = await (_db.select(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(preferredUserId))).getSingleOrNull();
      if (user != null) return user;
    }
    final current = await (_db.select(_db.userProfilesLocal)..where((tbl) => tbl.isCurrent.equals(true))).getSingleOrNull();
    if (current != null) return current;

    return (_db.select(_db.userProfilesLocal)..limit(1)).getSingle();
  }

  /// Switch the active user profile locally.
  Future<void> switchUser(String userId) async {
    await ensureLocalUsers();
    await (_db.update(_db.userProfilesLocal)..where((tbl) => tbl.isCurrent.equals(true))).write(
      const UserProfilesLocalCompanion(isCurrent: Value(false)),
    );
    await (_db.update(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(userId))).write(
      const UserProfilesLocalCompanion(isCurrent: Value(true)),
    );
  }

  /// Load profile summary: offline first from local Drift, then refresh via API if reachable.
  /// Racha de días actual (contador persistido). Usado por la evaluación de
  /// logros para no pasar un valor hardcodeado.
  Future<int> currentStreakDays(String userId) async {
    final prof = await (_db.select(_db.userProfilesLocal)
          ..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
    return prof?.streakDays ?? 0;
  }

  Future<ProfileSummaryData> getProfileSummary(String userId) async {
    await ensureLocalUsers();

    // 1. Load local profile
    final profile = await (_db.select(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(userId))).getSingleOrNull() ??
        await getActiveUserProfile();

    // 2. Load local achievements
    final achRows = await (_db.select(_db.userAchievementsLocal)..where((tbl) => tbl.userId.equals(profile.id))).get();
    final achievements = achRows.map((r) => UserAchievementData.fromDrift(r)).toList();

    // 3. Load local 30d activity
    final actRows = await (_db.select(_db.userActivityDailyLocal)
          ..where((tbl) => tbl.userId.equals(profile.id))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.activityDate)])
          ..limit(30))
        .get();

    final activity30d = actRows
        .map((r) => DailyActivityData(
              date: r.activityDate,
              xpEarned: r.xpEarned,
              minutesSpent: r.minutesSpent,
              sessionsCount: r.sessionsCount,
              wordsPracticed: r.wordsPracticed,
              grammarDrillsCount: r.grammarDrillsCount,
            ))
        .toList();

    final now = DateTime.now();
    final weeklyActivity = <Map<String, dynamic>>[];
    int weeklyXp = 0;
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final dateStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      final entry = activity30d.where((a) => a.date == dateStr).firstOrNull;
      final xp = entry?.xpEarned ?? 0;
      weeklyXp += xp;
      weeklyActivity.add({
        'date': dateStr,
        'day': ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][d.weekday - 1],
        'xp': xp,
        'turns': entry?.sessionsCount ?? 0,
        'minutes': entry?.minutesSpent ?? 0,
      });
    }

    final totalMinutes = activity30d.fold<int>(0, (sum, a) => sum + a.minutesSpent);

    // Métricas reales calculadas desde las tablas locales de Drift
    final attemptsList = await (_db.select(_db.practiceAttemptsLocal)
          ..where((tbl) => tbl.userId.equals(profile.id)))
        .get();
    final realSessions = attemptsList.length;

    final progressList = await (_db.select(_db.unitProgressLocal)
          ..where((tbl) => tbl.userId.equals(profile.id)))
        .get();
    final realCompletedUnits = progressList
        .where((u) => u.masteryScore >= 0.7 || u.attempts > 0)
        .length;

    final cardsList = await _db.select(_db.cardsLocal).get();
    final realMasteredWords = cardsList
        .where((c) => c.state == 2 || c.reps >= 2 || c.stability >= 4.0)
        .length;

    final scoredAttempts = attemptsList.where((a) => a.score > 0).toList();
    final realClarity = scoredAttempts.isNotEmpty
        ? (scoredAttempts.fold<double>(0.0, (sum, a) => sum + a.score) /
                scoredAttempts.length *
                100)
            .round()
            .clamp(0, 100)
        : 0;

    // Comprensión: contar piezas distintas completadas y accuracy media
    final listeningAttempts = attemptsList.where((a) => a.track == 'listening').toList();
    final distinctPieceIds = <String>{};
    final pieceScores = <String, double>{};
    for (final a in listeningAttempts) {
      distinctPieceIds.add(a.objectiveId);
      // Guardar el score más reciente por pieza (asumiendo lista ordenada por fecha)
      pieceScores[a.objectiveId] = a.score;
    }
    final realCompletedPieces = distinctPieceIds.length;
    final realAvgCompScore = pieceScores.isNotEmpty
        ? (pieceScores.values.fold<double>(0.0, (s, v) => s + v) /
                pieceScores.length *
                100)
            .round()
            .clamp(0, 100)
        : 0;

    // Racha calculada desde la actividad diaria (días consecutivos con actividad
    // que terminan hoy o ayer). Robustez extra sobre el contador persistido.
    final activeDates = <String>{
      for (final a in activity30d)
        if (a.xpEarned > 0 || a.sessionsCount > 0) a.date
    };
    int computedStreak = 0;
    {
      String fmt(DateTime d) =>
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      DateTime cursor = DateTime(now.year, now.month, now.day);
      if (!activeDates.contains(fmt(cursor))) {
        cursor = cursor.subtract(const Duration(days: 1));
      }
      while (activeDates.contains(fmt(cursor))) {
        computedStreak++;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }
    final effectiveStreak =
        computedStreak > profile.streakDays ? computedStreak : profile.streakDays;

    // Initial local real summary from 0
    var summary = ProfileSummaryData(
      profile: profile,
      totalXp: profile.totalXp,
      weeklyXp: weeklyXp,
      streakDays: effectiveStreak,
      totalMinutes: totalMinutes,
      totalSessions: realSessions,
      completedUnits: realCompletedUnits,
      masteredWords: realMasteredWords,
      speakingClarityScore: realClarity,
      listeningScore: realClarity > 0 ? (realClarity * 0.95).round().clamp(0, 100) : 0,
      completedPieces: realCompletedPieces,
      avgComprehensionScore: realAvgCompScore,
      skills: const SkillScoresData(),
      achievements: achievements,
      activity30d: activity30d,
      weeklyActivity: weeklyActivity,
      syncStatus: 'offline',
    );

    // 4. Try network fetch in background / fast online refresh (1.2s max, fallback to instant local)
    try {
      final res = await _apiClient.dio
          .get('/api/profile/summary?user_id=${profile.id}')
          .timeout(const Duration(milliseconds: 1200));
      if (res.statusCode == 200) {
        final data = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : jsonDecode(res.data.toString()) as Map<String, dynamic>;
        final skillsJson = data['skills'] as Map<String, dynamic>? ?? {};
        final remoteAchievements = (data['achievements'] as List<dynamic>? ?? [])
            .map((a) => UserAchievementData.fromJson(a as Map<String, dynamic>))
            .toList();
        final remoteActivity = (data['activity_30d'] as List<dynamic>? ?? [])
            .map((a) => DailyActivityData.fromJson(a as Map<String, dynamic>))
            .toList();
        final remoteWeekly = (data['weekly_activity'] as List<dynamic>? ?? [])
            .map((w) => Map<String, dynamic>.from(w as Map))
            .toList();

        summary = ProfileSummaryData(
          profile: profile,
          totalXp: data['total_xp'] ?? profile.totalXp,
          weeklyXp: data['weekly_xp'] ?? weeklyXp,
          streakDays: data['streak_days'] ?? profile.streakDays,
          totalMinutes: data['total_minutes'] ?? totalMinutes,
          totalSessions: data['total_sessions'] ?? realSessions,
          completedUnits: data['completed_units'] ?? realCompletedUnits,
          masteredWords: data['mastered_words'] ?? realMasteredWords,
          speakingClarityScore: data['speaking_clarity_score'] ?? realClarity,
          listeningScore: data['listening_score'] ?? (realClarity > 0 ? (realClarity * 0.95).round().clamp(0, 100) : 0),
          completedPieces: data['completed_pieces'] ?? realCompletedPieces,
          avgComprehensionScore: data['avg_comprehension_score'] ?? realAvgCompScore,
          skills: SkillScoresData.fromJson(skillsJson),
          achievements: remoteAchievements.isNotEmpty ? remoteAchievements : achievements,
          activity30d: remoteActivity.isNotEmpty ? remoteActivity : activity30d,
          weeklyActivity: remoteWeekly.isNotEmpty ? remoteWeekly : weeklyActivity,
          syncStatus: 'synced',
        );

        // Update local profile XP and streak from verified remote source
        await (_db.update(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(profile.id))).write(
          UserProfilesLocalCompanion(
            totalXp: Value(data['total_xp'] ?? profile.totalXp),
            streakDays: Value(data['streak_days'] ?? profile.streakDays),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ProfileRepository] Offline mode active: $e');
      }
    }

    return summary;
  }

  /// Log offline activity and increment XP.
  Future<void> logLearningActivity({
    required String userId,
    required int xp,
    required int minutes,
    int sessions = 1,
    int words = 0,
    int grammarDrills = 0,
  }) async {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    await _db.into(_db.userActivityDailyLocal).insert(
          UserActivityDailyLocalCompanion.insert(
            userId: userId,
            activityDate: dateStr,
            xpEarned: Value(xp),
            minutesSpent: Value(minutes),
            sessionsCount: Value(sessions),
            wordsPracticed: Value(words),
            grammarDrillsCount: Value(grammarDrills),
            isSynced: const Value(false),
          ),
        );

    final user = await (_db.select(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(userId))).getSingleOrNull();
    if (user != null) {
      await (_db.update(_db.userProfilesLocal)..where((tbl) => tbl.id.equals(userId))).write(
        UserProfilesLocalCompanion(
          totalXp: Value(user.totalXp + xp),
          lastActiveDate: Value(now.toUtc()),
        ),
      );
    }
  }
}
