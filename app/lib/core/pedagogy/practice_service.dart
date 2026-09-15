/// Orchestrates the adaptive engine with persistence: derives objective phase
/// from stored progress, records each attempt for analytics, and updates
/// mastery. Reads/writes drift; delegates selection to [PracticeEngine].
library;

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'taxonomy.dart';
import 'practice_engine.dart';

class AttemptResult {
  final String userId;
  final String objectiveId;
  final Track track;
  final LearningScenario? scenario;
  final DifficultyBand? band;
  final double score;        // 0..1
  final int durationSeconds;
  final int mistakes;
  final int repeatedItems;
  final int fsrsGenerated;

  const AttemptResult({
    required this.userId,
    required this.objectiveId,
    required this.track,
    this.scenario,
    this.band,
    required this.score,
    required this.durationSeconds,
    this.mistakes = 0,
    this.repeatedItems = 0,
    this.fsrsGenerated = 0,
  });
}

/// Summary of progress and improvement from completing a practice attempt.
class PracticeImprovement {
  final double previousMastery;
  final double newMastery;
  final int streak;
  final int attempts;
  final int xpGained;

  const PracticeImprovement({
    required this.previousMastery,
    required this.newMastery,
    required this.streak,
    required this.attempts,
    required this.xpGained,
  });

  double get delta => newMastery - previousMastery;
  bool get hasImproved => newMastery >= previousMastery;
  String get deltaPercent {
    final pct = ((newMastery - previousMastery) * 100).round();
    return pct >= 0 ? '+$pct%' : '$pct%';
  }
}

class PracticeService {
  final AppDatabase _db;
  final PracticeEngine _engine;

  PracticeService(this._db, {PracticeEngine engine = const PracticeEngine()})
      : _engine = engine;

  PracticeEngine get engine => _engine;

  /// Current phase for an objective, from stored mastery/attempts.
  Future<ObjectivePhase> phaseFor(String userId, String objectiveId) async {
    final row = await (_db.select(_db.unitProgressLocal)
          ..where((t) => t.userId.equals(userId) & t.objectiveId.equals(objectiveId)))
        .getSingleOrNull();
    if (row == null) return ObjectivePhase.fresh;
    return ObjectivePhaseX.fromMastery(row.masteryScore, attempts: row.attempts);
  }

  /// Record an attempt (analytics) and update the objective's mastery.
  /// Marca "practicó hoy" para la RACHA, sin inflar XP ni sesiones. Lo llama el
  /// evaluador de pronunciación para que la racha avance también en las pantallas
  /// por-tarjeta (vocabulario, verbos, phrasals, contextual), no solo al cerrar
  /// una sesión completa. Idempotente dentro del mismo día.
  Future<void> registerActivityDay(String userId) async {
    try {
      final now = DateTime.now();
      final prof = await (_db.select(_db.userProfilesLocal)
            ..where((t) => t.id.equals(userId)))
          .getSingleOrNull();
      if (prof == null) return;
      final today = DateTime(now.year, now.month, now.day);
      final last = prof.lastActiveDate;
      final lastDay =
          last == null ? null : DateTime(last.year, last.month, last.day);
      if (lastDay == today && prof.streakDays >= 1) {
        return; // ya marcado hoy
      }
      int newStreak;
      if (lastDay == null) {
        newStreak = 1;
      } else {
        final diff = today.difference(lastDay).inDays;
        if (diff <= 0) {
          newStreak = prof.streakDays < 1 ? 1 : prof.streakDays;
        } else if (diff == 1) {
          newStreak = prof.streakDays + 1;
        } else {
          newStreak = 1;
        }
      }
      await (_db.update(_db.userProfilesLocal)
            ..where((t) => t.id.equals(userId)))
          .write(UserProfilesLocalCompanion(
        lastActiveDate: Value(now),
        streakDays: Value(newStreak),
      ));
    } catch (_) {}
  }

  Future<PracticeImprovement> recordAttempt(AttemptResult r) async {
    final now = DateTime.now();
    await _db.into(_db.practiceAttemptsLocal).insert(
          PracticeAttemptsLocalCompanion.insert(
            userId: r.userId,
            objectiveId: r.objectiveId,
            track: r.track.id,
            scenario: Value(r.scenario?.id),
            difficultyBand: Value(r.band?.label),
            score: Value(r.score),
            durationSeconds: Value(r.durationSeconds),
            mistakes: Value(r.mistakes),
            repeatedItems: Value(r.repeatedItems),
            fsrsGenerated: Value(r.fsrsGenerated),
            createdAt: now,
          ),
        );
    final improvement = await _updateMastery(r);

    // 1. Actualizar perfil del usuario (totalXp y lastActiveDate)
    try {
      final prof = await (_db.select(_db.userProfilesLocal)
            ..where((t) => t.id.equals(r.userId)))
          .getSingleOrNull();
      if (prof != null) {
        // Racha robusta (funciona offline): +1 si la última actividad fue AYER,
        // se mantiene si ya se practicó HOY, y se reinicia a 1 si hubo un hueco.
        final today = DateTime(now.year, now.month, now.day);
        int newStreak;
        final last = prof.lastActiveDate;
        if (last == null) {
          newStreak = 1;
        } else {
          final lastDay = DateTime(last.year, last.month, last.day);
          final diff = today.difference(lastDay).inDays;
          if (diff <= 0) {
            newStreak = prof.streakDays < 1 ? 1 : prof.streakDays; // ya practicó hoy
          } else if (diff == 1) {
            newStreak = prof.streakDays + 1; // día consecutivo
          } else {
            newStreak = 1; // hueco -> reinicia
          }
        }
        await (_db.update(_db.userProfilesLocal)..where((t) => t.id.equals(r.userId)))
            .write(
          UserProfilesLocalCompanion(
            totalXp: Value(prof.totalXp + improvement.xpGained),
            lastActiveDate: Value(now),
            streakDays: Value(newStreak),
          ),
        );
      }
    } catch (_) {}

    // 2. Actualizar registro de actividad diaria (userActivityDailyLocal)
    try {
      final dateStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final daily = await (_db.select(_db.userActivityDailyLocal)
            ..where((t) =>
                t.userId.equals(r.userId) & t.activityDate.equals(dateStr)))
          .getSingleOrNull();
      final addedMins = (r.durationSeconds / 60).ceil().clamp(1, 60);

      if (daily != null) {
        await (_db.update(_db.userActivityDailyLocal)
              ..where((t) => t.id.equals(daily.id)))
            .write(
          UserActivityDailyLocalCompanion(
            xpEarned: Value(daily.xpEarned + improvement.xpGained),
            minutesSpent: Value(daily.minutesSpent + addedMins),
            sessionsCount: Value(daily.sessionsCount + 1),
            grammarDrillsCount: Value(daily.grammarDrillsCount +
                (r.track == Track.grammar ? 1 : 0)),
            wordsPracticed: Value(daily.wordsPracticed +
                (r.track == Track.vocabulary ? 10 : 0)),
            isSynced: const Value(false),
          ),
        );
      } else {
        await _db.into(_db.userActivityDailyLocal).insert(
              UserActivityDailyLocalCompanion.insert(
                userId: r.userId,
                activityDate: dateStr,
                xpEarned: Value(improvement.xpGained),
                minutesSpent: Value(addedMins),
                sessionsCount: const Value(1),
                grammarDrillsCount:
                    Value(r.track == Track.grammar ? 1 : 0),
                wordsPracticed:
                    Value(r.track == Track.vocabulary ? 10 : 0),
                isSynced: const Value(false),
              ),
            );
      }
    } catch (_) {}

    return improvement;
  }

  Future<PracticeImprovement> _updateMastery(AttemptResult r) async {
    final existing = await (_db.select(_db.unitProgressLocal)
          ..where((t) =>
              t.userId.equals(r.userId) & t.objectiveId.equals(r.objectiveId)))
        .getSingleOrNull();
    final now = DateTime.now();
    final xp = (r.score * 40).round() + 10;

    if (existing == null) {
      final mastery = r.score.clamp(0.0, 1.0);
      final streak = r.score >= 0.7 ? 1 : 0;
      await _db.into(_db.unitProgressLocal).insert(
            UnitProgressLocalCompanion.insert(
              userId: r.userId,
              track: r.track.id,
              objectiveId: r.objectiveId,
              masteryScore: Value(mastery),
              attempts: const Value(1),
              state: Value(_stateFor(mastery)),
              lastPracticedAt: Value(now),
              streak: Value(streak),
            ),
          );
      return PracticeImprovement(
        previousMastery: 0.0,
        newMastery: mastery,
        streak: streak,
        attempts: 1,
        xpGained: xp,
      );
    }

    // Exponential moving average so mastery reflects recent performance.
    final blended = (existing.masteryScore * 0.6 + r.score * 0.4).clamp(0.0, 1.0);
    final streak = r.score >= 0.7 ? existing.streak + 1 : 0;
    final attempts = existing.attempts + 1;
    await (_db.update(_db.unitProgressLocal)..where((t) => t.id.equals(existing.id)))
        .write(UnitProgressLocalCompanion(
      masteryScore: Value(blended),
      attempts: Value(attempts),
      state: Value(_stateFor(blended)),
      lastPracticedAt: Value(now),
      streak: Value(streak),
      isSynced: const Value(false),
    ));

    return PracticeImprovement(
      previousMastery: existing.masteryScore,
      newMastery: blended,
      streak: streak,
      attempts: attempts,
      xpGained: xp,
    );
  }

  String _stateFor(double mastery) {
    if (mastery >= 0.85) return 'mastered';
    if (mastery >= 0.15) return 'learning';
    return 'new';
  }
}
