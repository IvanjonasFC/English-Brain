import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

part 'app_database.g.dart';

class SessionsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get mode => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get overallScore => real().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TurnsLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  IntColumn get questionId => integer().nullable()();
  TextColumn get questionText => text()();
  TextColumn get transcript => text()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get feedbackJson => text().nullable()();
  RealColumn get score => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class ReviewLogsLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer()();
  IntColumn get rating => integer()();
  IntColumn get state => integer()();
  DateTimeColumn get due => dateTime()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  IntColumn get elapsedDays => integer()();
  IntColumn get lastElapsedDays => integer()();
  IntColumn get scheduledDays => integer()();
  DateTimeColumn get review => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class CardsLocal extends Table {
  IntColumn get id => integer()();
  IntColumn get mistakeId => integer().nullable()();
  TextColumn get front => text()();
  TextColumn get back => text()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  IntColumn get elapsedDays => integer()();
  IntColumn get scheduledDays => integer()();
  IntColumn get reps => integer()();
  IntColumn get lapses => integer()();
  IntColumn get state => integer()();
  DateTimeColumn get lastReview => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Pedagogy: generalized FSRS ingestion (any source, per-user).
  TextColumn get sourceType => text().withDefault(const Constant('interview_mistake'))();
  TextColumn get itemType => text().withDefault(const Constant('sentence_correction'))();
  TextColumn get unitOrPackId => text().nullable()();
  TextColumn get skill => text().withDefault(const Constant('speaking'))();
  TextColumn get userId => text().withDefault(const Constant('user-ivan'))();

  @override
  Set<Column> get primaryKey => {id};
}

class QueueItems extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  IntColumn get questionId => integer().nullable()();
  TextColumn get audioPath => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get title => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get durationSeconds => integer()();
  IntColumn get questionsCount => integer()();
  RealColumn get overallScore => real()();
  IntColumn get mistakesCount => integer()();
  TextColumn get mistakesJson => text()();
  TextColumn get vocabularyJson => text()();
  TextColumn get markdownContent => text()();
  BoolColumn get isExported => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserMilestonesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get achieved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get achievedAt => dateTime().nullable()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ResourcesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get originalUrl => text()();
  TextColumn get sourceName => text()();
  TextColumn get resourceType => text()();
  TextColumn get skill => text()();
  TextColumn get domain => text()();
  TextColumn get level => text()();
  TextColumn get tagsJson => text()();
  BoolColumn get transcriptAvailable => boolean().withDefault(const Constant(false))();
  BoolColumn get spanishSupport => boolean().withDefault(const Constant(false))();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(15))();
  TextColumn get recommendedFor => text().nullable()();
  TextColumn get spanishNotes => text().nullable()();
  TextColumn get collectionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ResourceCollectionsLocal extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().withDefault(const Constant('bookmark'))();
  TextColumn get color => text().withDefault(const Constant('#0D9488'))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class UnitResourceLinksLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resourceId => text()();
  TextColumn get targetType => text()(); // unit, pack, question
  TextColumn get targetId => text()(); // e.g. unit-1-junior
  TextColumn get relevanceNote => text().nullable()();
}

class ResourceUsageLogsLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get resourceId => text()();
  TextColumn get unitId => text().nullable()();
  TextColumn get eventType => text().withDefault(const Constant('open'))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class UserProfilesLocal extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get email => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get targetLevel => text().withDefault(const Constant('B2'))();
  TextColumn get roleTitle => text().withDefault(const Constant('Software Engineer'))();
  TextColumn get learningGoal => text().withDefault(const Constant('interview_prep'))();
  IntColumn get dailyGoalMinutes => integer().withDefault(const Constant(20))();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActiveDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserAchievementsLocal extends Table {
  TextColumn get id => text()(); // "userId:badgeKey"
  TextColumn get userId => text()();
  TextColumn get badgeKey => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get iconName => text().withDefault(const Constant('star'))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserActivityDailyLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get activityDate => text()(); // YYYY-MM-DD
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  IntColumn get minutesSpent => integer().withDefault(const Constant(0))();
  IntColumn get sessionsCount => integer().withDefault(const Constant(0))();
  IntColumn get wordsPracticed => integer().withDefault(const Constant(0))();
  IntColumn get grammarDrillsCount => integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Stores user preferences locally (locale, daily goal, etc.)
class UserSettingsLocal extends Table {
  TextColumn get userId => text()();
  TextColumn get locale => text().withDefault(const Constant('es'))();
  IntColumn get dailyGoalMinutes => integer().withDefault(const Constant(20))();
  TextColumn get targetLevel => text().withDefault(const Constant('B2'))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Tracks vocabulary progress per word per pack per user (offline-first)
class VocabularyProgressLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packId => text()();
  TextColumn get wordId => text()();
  TextColumn get userId => text()();
  IntColumn get masteryLevel => integer().withDefault(const Constant(0))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  RealColumn get pronunciationScore => real().withDefault(const Constant(0.0))();
  BoolColumn get isMastered => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Tracks grammar progress per unit per user (offline-first)
class GrammarProgressLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get unitId => text()();
  TextColumn get userId => text()();
  IntColumn get attemptsCount => integer().withDefault(const Constant(0))();
  RealColumn get bestScore => real().withDefault(const Constant(0.0))();
  RealColumn get lastScore => real().withDefault(const Constant(0.0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Queue of offline events (XP earned, progress updates) pending backend sync
class OfflineEventsLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventType => text()(); // xp_earned, session_completed, vocab_reviewed, grammar_completed
  TextColumn get payloadJson => text()(); // Serialized JSON with event data
  TextColumn get userId => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}


class UnitProgressLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get track => text()();
  TextColumn get objectiveId => text()();
  RealColumn get masteryScore => real().withDefault(const Constant(0.0))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('new'))(); // new, learning, mastered
  DateTimeColumn get lastPracticedAt => dateTime().nullable()();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class PracticeAttemptsLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get objectiveId => text()();
  TextColumn get scenario => text().nullable()();
  TextColumn get difficultyBand => text().nullable()();
  TextColumn get track => text()();
  RealColumn get score => real().withDefault(const Constant(0.0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get mistakes => integer().withDefault(const Constant(0))();
  IntColumn get repeatedItems => integer().withDefault(const Constant(0))();
  IntColumn get fsrsGenerated => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Continuous phoneme tracking with Wilson Lower Bound & confusion map
class UserPhonemeProgressLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get phoneme => text()(); // e.g. "TH_V", "IH", "AE"
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get successes => integer().withDefault(const Constant(0))();
  RealColumn get meanGop => real().withDefault(const Constant(0.0))();
  RealColumn get lastGop => real().withDefault(const Constant(0.0))();
  RealColumn get recencyWeightedGop => real().withDefault(const Constant(0.0))();
  RealColumn get wilsonLowerBound => real().withDefault(const Constant(0.0))();
  TextColumn get confusionMapJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get lastPracticedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

/// Day 1 vs Today baseline audio and GOP comparator
class UserAudioBaselinesLocal extends Table {
  TextColumn get id => text()(); // "userId:targetType:targetId"
  TextColumn get userId => text()();
  TextColumn get targetType => text()(); // word, sentence, probe
  TextColumn get targetId => text()();
  TextColumn get baselineAudioPath => text()();
  RealColumn get baselineScore => real().withDefault(const Constant(0.0))();
  RealColumn get baselineGop => real().withDefault(const Constant(0.0))();
  DateTimeColumn get baselineCreatedAt => dateTime()();
  TextColumn get latestAudioPath => text().nullable()();
  RealColumn get latestScore => real().nullable()();
  RealColumn get latestGop => real().nullable()();
  DateTimeColumn get latestUpdatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  SessionsLocal,
  TurnsLocal,
  ReviewLogsLocal,
  CardsLocal,
  QueueItems,
  JournalEntries,
  UserMilestonesLocal,
  ResourcesLocal,
  ResourceCollectionsLocal,
  UnitResourceLinksLocal,
  ResourceUsageLogsLocal,
  UserProfilesLocal,
  UserAchievementsLocal,
  UserActivityDailyLocal,
  UserSettingsLocal,
  VocabularyProgressLocal,
  GrammarProgressLocal,
  OfflineEventsLocal,
  UnitProgressLocal,
  PracticeAttemptsLocal,
  UserPhonemeProgressLocal,
  UserAudioBaselinesLocal,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(resourcesLocal);
            await m.createTable(resourceCollectionsLocal);
            await m.createTable(unitResourceLinksLocal);
            await m.createTable(resourceUsageLogsLocal);
          }
          if (from < 3) {
            await m.createTable(userProfilesLocal);
            await m.createTable(userAchievementsLocal);
            await m.createTable(userActivityDailyLocal);
          }
          if (from < 4) {
            await m.createTable(userSettingsLocal);
            await m.createTable(vocabularyProgressLocal);
            await m.createTable(grammarProgressLocal);
            await m.createTable(offlineEventsLocal);
          }
          if (from < 5) {
            await m.createTable(unitProgressLocal);
            await m.createTable(practiceAttemptsLocal);
            await m.addColumn(cardsLocal, cardsLocal.sourceType);
            await m.addColumn(cardsLocal, cardsLocal.itemType);
            await m.addColumn(cardsLocal, cardsLocal.unitOrPackId);
            await m.addColumn(cardsLocal, cardsLocal.skill);
            await m.addColumn(cardsLocal, cardsLocal.userId);
          }
          if (from < 6) {
            await m.addColumn(userProfilesLocal, userProfilesLocal.learningGoal);
          }
          if (from < 7) {
            await m.createTable(userPhonemeProgressLocal);
            await m.createTable(userAudioBaselinesLocal);
          }
        },
      );
}

