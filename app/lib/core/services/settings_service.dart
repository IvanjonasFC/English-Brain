import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Service for persisting user settings locally via Drift.
/// Settings are stored offline-first and synced to backend when online.
class SettingsService {
  final AppDatabase _db;

  SettingsService(this._db);

  /// Get settings for a user, creating defaults if not exists.
  Future<UserSettingsLocalData> getSettings(String userId) async {
    final existing = await (_db.select(_db.userSettingsLocal)
      ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (existing != null) return existing;

    // Create defaults
    final defaults = UserSettingsLocalCompanion(
      userId: Value(userId),
      locale: const Value('es'),
      dailyGoalMinutes: const Value(20),
      targetLevel: const Value('B2'),
      notificationsEnabled: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    await _db.into(_db.userSettingsLocal).insert(defaults);
    return (await (_db.select(_db.userSettingsLocal)
      ..where((t) => t.userId.equals(userId)))
        .getSingle());
  }

  /// Update locale preference.
  Future<void> updateLocale(String userId, String locale) async {
    await (_db.update(_db.userSettingsLocal)
      ..where((t) => t.userId.equals(userId)))
        .write(UserSettingsLocalCompanion(
          locale: Value(locale),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Update daily goal in minutes.
  Future<void> updateDailyGoal(String userId, int minutes) async {
    await (_db.update(_db.userSettingsLocal)
      ..where((t) => t.userId.equals(userId)))
        .write(UserSettingsLocalCompanion(
          dailyGoalMinutes: Value(minutes),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Update target CEFR level.
  Future<void> updateTargetLevel(String userId, String level) async {
    await (_db.update(_db.userSettingsLocal)
      ..where((t) => t.userId.equals(userId)))
        .write(UserSettingsLocalCompanion(
          targetLevel: Value(level),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Watch settings stream for reactive updates.
  Stream<UserSettingsLocalData?> watchSettings(String userId) {
    return (_db.select(_db.userSettingsLocal)
      ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  /// Ensure settings exist for a user (idempotent).
  Future<void> ensureSettingsExist(String userId) async {
    await getSettings(userId);
  }
}
