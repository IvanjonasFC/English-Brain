/// Centralized application configuration.
/// Feature flags, XP rules, thresholds, and audio settings.
/// No widget should hardcode these values directly.
class AppConfig {
  AppConfig._();

  // ===== Feature Flags =====
  static const bool enableResources = true;
  static const bool enableShadowing = true;
  static const bool enableDictation = true;
  static const bool enableMockInterview = true;
  static const bool enableFsrsDeck = true;
  static const bool enablePronunciationCheck = true;

  // ===== XP Rules =====
  static const int xpPerSession = 20;
  static const int xpPerCardReview = 5;
  static const int xpPerGrammarDrill = 10;
  static const int xpPerVocabPack = 15;
  static const int xpCheckpointBonus = 50;
  static const int xpStreakBonus = 10;
  static const int xpFirstSessionOfDay = 25;

  // ===== Thresholds =====
  static const int checkpointPassScore = 70;   // % for checkpoint pass
  static const int masteryThreshold = 85;       // % for mastery
  static const int weeklyStreakGoal = 5;         // days per week
  static const int dailyGoalDefault = 20;       // minutes per day

  // ===== Audio =====
  static const double audioNormalSpeed = 1.0;
  static const double audioSlowSpeed = 0.8;
  static const double audioFastSpeed = 1.25;

  // ===== FSRS =====
  static const int fsrsDailyNewCards = 20;
  static const int fsrsMaxReviewsPerDay = 100;
  static const double fsrsRequestRetention = 0.9;

  // ===== Session / Interview =====
  static const int mockInterviewQuestions = 5;
  static const int maxSessionDurationMinutes = 60;
  static const int audioUploadTimeoutSeconds = 120;

  // ===== Sync =====
  static const int offlineSyncRetryIntervalMinutes = 15;
  static const int maxOfflineQueueSize = 50;

  // ===== Vocabulary =====
  static const int vocabularyCardsPerSession = 10;
  static const int vocabularyMasteryReps = 5;

  // ===== Grammar =====
  static const int grammarDrillsPerUnit = 10;
  static const int grammarMinScoreToAdvance = 70;

  // ===== Supported Locales =====
  static const List<String> supportedLocales = ['es', 'en'];
  static const String defaultLocale = 'es';
}
