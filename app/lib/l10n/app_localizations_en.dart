// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'English Brain';

  @override
  String appVersion(String version) {
    return 'v$version';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navInterview => 'Speaking';

  @override
  String get navVocabulary => 'Vocabulary';

  @override
  String get navGrammar => 'Grammar';

  @override
  String get navComprehension => 'Input';

  @override
  String get navFsrs => 'FSRS Deck';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreetingMorning => 'Good morning';

  @override
  String get homeGreetingAfternoon => 'Good afternoon';

  @override
  String get homeGreetingEvening => 'Good evening';

  @override
  String homeStreakDays(int count) {
    return '$count day streak';
  }

  @override
  String homeTotalXp(int xp) {
    return '$xp XP';
  }

  @override
  String homeLevel(String level) {
    return 'Level $level';
  }

  @override
  String get homeDailyProgress => 'Daily goal';

  @override
  String get homeModulesSection => 'Modules';

  @override
  String get homeNextBestAction => 'Continue where you left off';

  @override
  String get homeRecentActivity => 'Recent activity';

  @override
  String get homeMetricsSection => 'Today\'s stats';

  @override
  String get homeSessionsToday => 'Sessions today';

  @override
  String get homeWordsReviewed => 'Words reviewed';

  @override
  String get homeGrammarScore => 'Grammar score';

  @override
  String get homeStreak => 'Streak';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeKeepGoing => 'Keep going!';

  @override
  String get homeStartSession => 'Start session';

  @override
  String get homeResumePractice => 'Resume practice';

  @override
  String get homeNoActivity => 'No activity yet today';

  @override
  String get homeStartFirstSession => 'Start your first session';

  @override
  String get homeConnectedToServer => 'Connected';

  @override
  String get homeOfflineMode => 'Offline mode';

  @override
  String get homeOfflineSyncing => 'Syncing...';

  @override
  String homePendingSync(int count) {
    return '$count pending';
  }

  @override
  String get interviewTitle => 'Interview Simulator';

  @override
  String get interviewHubTitle => 'Interview Hub';

  @override
  String get interviewHubSubtitle =>
      'Practice technical, HR and system design interviews';

  @override
  String get interviewSelectCategory => 'Select category';

  @override
  String get interviewSelectDifficulty => 'Select difficulty';

  @override
  String get interviewSelectMode => 'Select mode';

  @override
  String get interviewStartSession => 'Start session';

  @override
  String get interviewContinueSession => 'Continue session';

  @override
  String get interviewEndSession => 'End session';

  @override
  String interviewQuestion(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get interviewNoQuestions => 'No questions found';

  @override
  String get interviewNoQuestionsSubtitle =>
      'Try a different category or difficulty';

  @override
  String get interviewRecordAnswer => 'Record your answer';

  @override
  String get interviewRecordingInProgress => 'Recording...';

  @override
  String get interviewRecordingStop => 'Stop recording';

  @override
  String get interviewUploading => 'Analyzing your answer...';

  @override
  String get interviewFeedbackTitle => 'AI Feedback';

  @override
  String get interviewModelAnswer => 'Model answer';

  @override
  String get interviewNextQuestion => 'Next question';

  @override
  String get interviewPrevQuestion => 'Previous';

  @override
  String get interviewBrowseQuestions => 'Browse questions';

  @override
  String get interviewSearchPlaceholder => 'Search questions...';

  @override
  String get interviewSearchNoResults => 'No questions match';

  @override
  String interviewSearchResults(int count) {
    return '$count questions';
  }

  @override
  String get interviewTips => 'Tips';

  @override
  String get interviewTipsToggle => 'Show tips';

  @override
  String get interviewStarGuide => 'STAR Framework';

  @override
  String get interviewStarSituation => 'Situation';

  @override
  String get interviewStarSituationHint =>
      'Set the context: when, where, what project?';

  @override
  String get interviewStarTask => 'Task';

  @override
  String get interviewStarTaskHint =>
      'Your specific responsibility or challenge';

  @override
  String get interviewStarAction => 'Action';

  @override
  String get interviewStarActionHint =>
      'Concrete steps you took — use \'I did\', not \'We did\'';

  @override
  String get interviewStarResult => 'Result';

  @override
  String get interviewStarResultHint =>
      'Quantify the impact: % improvement, time saved';

  @override
  String get interviewModeLesson => 'Lesson';

  @override
  String get interviewModeCheckpoint => 'Checkpoint';

  @override
  String get interviewModeMock => 'Mock Interview';

  @override
  String get interviewModeShadowing => 'Shadowing';

  @override
  String get interviewScoreLabel => 'Score';

  @override
  String get interviewSessionComplete => 'Session complete';

  @override
  String get interviewSessionSaved => 'Session saved';

  @override
  String get interviewOfflineQueued =>
      'Saved offline, will sync when connected';

  @override
  String get interviewCategoryTech => 'Technical';

  @override
  String get interviewCategoryHr => 'HR';

  @override
  String get interviewCategorySystemDesign => 'System Design';

  @override
  String get interviewCategoryCloudArch => 'Cloud Architecture';

  @override
  String get interviewCategoryAiMl => 'AI / ML';

  @override
  String get interviewCategorySecurity => 'Security';

  @override
  String get interviewCategoryLeadership => 'Leadership';

  @override
  String get interviewCategoryBehavioral => 'Behavioral';

  @override
  String get interviewCategoryVocab => 'Vocabulary';

  @override
  String get interviewCategoryAgile => 'Agile';

  @override
  String get interviewCategoryDatabases => 'Databases';

  @override
  String get interviewCategoryNetworking => 'Networking';

  @override
  String get interviewCategoryDevops => 'DevOps';

  @override
  String get interviewDifficultyJunior => 'Junior';

  @override
  String get interviewDifficultyMid => 'Mid';

  @override
  String get interviewDifficultySenior => 'Senior';

  @override
  String get interviewDifficultyStrategic => 'Strategic';

  @override
  String get vocabTitle => 'Vocabulary';

  @override
  String get vocabHubTitle => 'Vocabulary Hub';

  @override
  String get vocabHubSubtitle => 'Master technical and professional vocabulary';

  @override
  String vocabPacksAvailable(int count) {
    return '$count packs available';
  }

  @override
  String get vocabSelectPack => 'Select a pack to practice';

  @override
  String get vocabCardFront => 'Front';

  @override
  String get vocabCardBack => 'Back';

  @override
  String get vocabFlipCard => 'Flip card';

  @override
  String get vocabFlipToSpanish => 'See Spanish';

  @override
  String get vocabFlipToEnglish => 'See English';

  @override
  String get vocabDefinition => 'Definition';

  @override
  String get vocabExample => 'Example';

  @override
  String get vocabMnemonic => 'Memory tip';

  @override
  String get vocabPronunciation => 'Pronunciation';

  @override
  String get vocabPlayAudio => 'Play audio';

  @override
  String get vocabSlowAudio => 'Slow';

  @override
  String get vocabNormalAudio => 'Normal';

  @override
  String get vocabRecordPronunciation => 'Record your pronunciation';

  @override
  String get vocabRecording => 'Recording...';

  @override
  String get vocabCheckPronunciation => 'Check pronunciation';

  @override
  String get vocabAnalyzing => 'Analyzing pronunciation...';

  @override
  String vocabPronunciationScore(int score) {
    return 'Pronunciation score: $score%';
  }

  @override
  String get vocabPronunciationGood => 'Great pronunciation!';

  @override
  String get vocabPronunciationAverage => 'Good, keep practicing';

  @override
  String get vocabPronunciationNeedsWork => 'Needs improvement';

  @override
  String get vocabAddToFsrs => 'Add to FSRS deck';

  @override
  String get vocabAddedToFsrs => 'Added to your review deck';

  @override
  String get vocabNextWord => 'Next word';

  @override
  String get vocabPrevWord => 'Previous';

  @override
  String vocabWordCount(int current, int total) {
    return '$current / $total';
  }

  @override
  String vocabProgress(int percent) {
    return '$percent% mastered';
  }

  @override
  String get vocabMarkMastered => 'Mark as mastered';

  @override
  String get vocabAlreadyMastered => 'Mastered!';

  @override
  String get vocabDomainTech => 'Technical';

  @override
  String get vocabDomainInterview => 'Interview';

  @override
  String get vocabDomainGeneral => 'General';

  @override
  String get vocabLevelLabel => 'Level';

  @override
  String get vocabPackCompleted => 'Pack completed!';

  @override
  String get vocabPackCompletedSubtitle =>
      'All words reviewed. Come back tomorrow for spaced repetition.';

  @override
  String get vocabNoPackSelected => 'No pack selected';

  @override
  String get vocabNoPackSelectedSubtitle =>
      'Go back and select a vocabulary pack to practice';

  @override
  String get grammarTitle => 'Grammar';

  @override
  String get grammarHubTitle => 'Grammar Hub';

  @override
  String get grammarHubSubtitle =>
      'Master English grammar from basics to advanced';

  @override
  String get grammarSelectLevel => 'Select level';

  @override
  String get grammarSelectUnit => 'Select unit';

  @override
  String get grammarCheckAnswer => 'Check answer';

  @override
  String get grammarNextExercise => 'Next exercise';

  @override
  String get grammarPrevExercise => 'Previous';

  @override
  String grammarScore(int score) {
    return 'Score: $score%';
  }

  @override
  String get grammarCorrect => 'Correct!';

  @override
  String get grammarIncorrect => 'Incorrect';

  @override
  String get grammarExplanation => 'Explanation';

  @override
  String get grammarYourAnswer => 'Your answer';

  @override
  String get grammarCorrectAnswer => 'Correct answer';

  @override
  String get grammarLevelA1 => 'A1 — Beginner';

  @override
  String get grammarLevelA2 => 'A2 — Elementary';

  @override
  String get grammarLevelB1 => 'B1 — Intermediate';

  @override
  String get grammarLevelB2 => 'B2 — Upper Intermediate';

  @override
  String get grammarLevelC1 => 'C1 — Advanced';

  @override
  String get grammarUnitComplete => 'Unit complete!';

  @override
  String grammarDrillsRemaining(int count) {
    return '$count drills remaining';
  }

  @override
  String get grammarSkipExercise => 'Skip';

  @override
  String get grammarHint => 'Hint';

  @override
  String get grammarShowHint => 'Show hint';

  @override
  String grammarProgress(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get grammarTypeMultipleChoice => 'Multiple choice';

  @override
  String get grammarTypeFillBlank => 'Fill in the blank';

  @override
  String get grammarTypeReorder => 'Reorder words';

  @override
  String get grammarTypeTranslate => 'Translate';

  @override
  String get fsrsTitle => 'FSRS Deck';

  @override
  String get fsrsSubtitle => 'Spaced repetition flashcards';

  @override
  String fsrsCardsDue(int count) {
    return '$count cards due';
  }

  @override
  String fsrsNewCards(int count) {
    return '$count new cards';
  }

  @override
  String fsrsCardsLearning(int count) {
    return '$count learning';
  }

  @override
  String get fsrsStartReview => 'Start review';

  @override
  String get fsrsNoCardsDue => 'All caught up!';

  @override
  String get fsrsNoCardsDueSubtitle =>
      'No cards due for review. Come back later.';

  @override
  String get fsrsCardFront => 'Front';

  @override
  String get fsrsCardBack => 'Back (tap to reveal)';

  @override
  String get fsrsRevealAnswer => 'Reveal answer';

  @override
  String get fsrsRatingAgain => 'Again';

  @override
  String get fsrsRatingHard => 'Hard';

  @override
  String get fsrsRatingGood => 'Good';

  @override
  String get fsrsRatingEasy => 'Easy';

  @override
  String fsrsNextReview(String date) {
    return 'Next review: $date';
  }

  @override
  String get fsrsSessionComplete => 'Session complete';

  @override
  String get fsrsExportToAnki => 'Export to Anki';

  @override
  String get fsrsExporting => 'Exporting...';

  @override
  String get fsrsExported => 'Exported successfully';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileTotalXp => 'Total XP';

  @override
  String get profileWeeklyXp => 'This week';

  @override
  String get profileStreak => 'day streak';

  @override
  String get profileTimeStudied => 'Study time';

  @override
  String get profileSessions => 'Sessions';

  @override
  String get profileUnitsCompleted => 'Units completed';

  @override
  String get profileWordsMastered => 'Words mastered';

  @override
  String get profileSpeakingScore => 'Speaking score';

  @override
  String get profileListeningScore => 'Listening score';

  @override
  String get profileSkillsSection => 'Skills';

  @override
  String get profileSkillGrammar => 'Grammar';

  @override
  String get profileSkillVocabulary => 'Vocabulary';

  @override
  String get profileSkillListening => 'Listening';

  @override
  String get profileSkillSpeaking => 'Speaking';

  @override
  String get profileActivitySection => 'Practice activity';

  @override
  String get profileAchievementsSection => 'Achievements';

  @override
  String get profileSettingsSection => 'Settings';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileAudio => 'Audio settings';

  @override
  String get profileSync => 'Sync & data';

  @override
  String get profileExport => 'Export data';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileLanguage => 'App language';

  @override
  String get profileLanguageEs => 'Spanish';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileDailyGoal => 'Daily goal';

  @override
  String profileDailyGoalMinutes(int minutes) {
    return '$minutes min / day';
  }

  @override
  String get profileCefrLevel => 'CEFR Level';

  @override
  String get profileTarget => 'Target level';

  @override
  String profileLastActive(String date) {
    return 'Last active: $date';
  }

  @override
  String get profileNoAchievements => 'No achievements yet';

  @override
  String get profileNoAchievementsSubtitle =>
      'Complete sessions to earn badges';

  @override
  String get profileBadgeUnlocked => 'Unlocked!';

  @override
  String get profileBadgeLocked => 'Locked';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsServerUrl => 'Server URL';

  @override
  String get settingsApiKey => 'API Key';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get settingsReset => 'Reset to defaults';

  @override
  String get settingsAppInfo => 'App information';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsClearCache => 'Clear cache';

  @override
  String get settingsCacheCleared => 'Cache cleared';

  @override
  String get loginTitle => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to your English Brain account';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginServerUrl => 'Server URL';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginSigningIn => 'Signing in...';

  @override
  String get loginError => 'Login failed. Check your credentials.';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginOfflineMode => 'Continue offline';

  @override
  String get onboardingTitle => 'English Brain';

  @override
  String get onboardingSubtitle => 'Your AI-powered English practice coach';

  @override
  String get onboardingStep1Title => 'Practice speaking';

  @override
  String get onboardingStep1Subtitle =>
      'Real interview simulations with AI feedback';

  @override
  String get onboardingStep2Title => 'Master vocabulary';

  @override
  String get onboardingStep2Subtitle =>
      '3D flashcards with pronunciation check';

  @override
  String get onboardingStep3Title => 'Learn grammar';

  @override
  String get onboardingStep3Subtitle => 'Structured drills from A1 to C1';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingConfigServer => 'Configure server';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorNoConnection => 'No internet connection';

  @override
  String get errorNoConnectionSubtitle =>
      'Working in offline mode. Data will sync when connected.';

  @override
  String get errorServerUnreachable => 'Server unreachable';

  @override
  String get errorServerUnreachableSubtitle =>
      'Check your server URL in settings';

  @override
  String get errorRetry => 'Try again';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorTimeout => 'Request timed out';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorUnauthorized => 'Session expired. Please sign in again.';

  @override
  String get stateLoading => 'Loading...';

  @override
  String get stateEmpty => 'Nothing here yet';

  @override
  String get stateEmptySubtitle => 'Start a session to see your data here';

  @override
  String get stateSyncing => 'Syncing data...';

  @override
  String get stateSyncComplete => 'Sync complete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionClose => 'Close';

  @override
  String get actionShare => 'Share';

  @override
  String get actionCopy => 'Copy';

  @override
  String get actionCopied => 'Copied to clipboard';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionStart => 'Start';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionFinish => 'Finish';

  @override
  String get actionSkip => 'Skip';

  @override
  String get snackOfflineQueued => 'Saved offline. Will sync when connected.';

  @override
  String get snackSyncSuccess => 'Data synced successfully';

  @override
  String get snackSyncError => 'Sync failed. Will retry automatically.';

  @override
  String get snackCopied => 'Copied!';

  @override
  String get snackSaved => 'Saved';

  @override
  String snackError(String message) {
    return 'Error: $message';
  }

  @override
  String get badgeFirstSession => 'First Session';

  @override
  String get badgeWeekStreak => 'Week Streak';

  @override
  String get badgeVocabMaster => 'Vocab Master';

  @override
  String get badgeGrammarAce => 'Grammar Ace';

  @override
  String get badgeFsrsReviewer => 'FSRS Reviewer';

  @override
  String get badgePronunciationPro => 'Pronunciation Pro';

  @override
  String get badgeMockInterview => 'Mock Interview';

  @override
  String get badgeCheckpoint => 'Checkpoint Cleared';

  @override
  String get badgeTopPerformer => 'Top Performer';

  @override
  String get difficultyJunior => 'Junior';

  @override
  String get difficultyMid => 'Mid';

  @override
  String get difficultySenior => 'Senior';

  @override
  String get difficultyStrategic => 'Strategic';

  @override
  String get levelA1 => 'A1';

  @override
  String get levelA2 => 'A2';

  @override
  String get levelB1 => 'B1';

  @override
  String get levelB2 => 'B2';

  @override
  String get levelC1 => 'C1';

  @override
  String get levelC2 => 'C2';

  @override
  String minutesShort(int min) {
    return '${min}m';
  }

  @override
  String hoursShort(int h) {
    return '${h}h';
  }

  @override
  String daysShort(int d) {
    return '${d}d';
  }

  @override
  String get actionPractice => 'Practice';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionCheck => 'Check';

  @override
  String get actionExport => 'Export';

  @override
  String get commonExitSession => 'Exit session';

  @override
  String get ttsListenNatural => 'Listen with Microsoft natural voice';

  @override
  String get ttsListenCorrect =>
      'Listen to the correct phrase in native English';

  @override
  String get ttsListenInterviewer => 'Listen to the interviewer';

  @override
  String get ttsListenSlow => 'Listen slowly (0.8x)';

  @override
  String get ttsPlayInterviewer => 'Play interviewer voice';

  @override
  String get ttsListenNativeVocab =>
      'Listen in native English (Microsoft Neural Voice)';

  @override
  String get ttsListenFullPhrase => 'Listen to full phrase';

  @override
  String get exportCopyMarkdown => 'Copy Markdown to clipboard (Obsidian)';

  @override
  String get exportCopyMarkdownObsidian => 'Copy Markdown for Obsidian';

  @override
  String get exportCopiedObsidian =>
      'Copied! Ready to paste into your Obsidian vault.';

  @override
  String get connLocalPc => 'Local PC';

  @override
  String get connLanHome => 'Home LAN';

  @override
  String get connWireguard => 'WireGuard';

  @override
  String get connHttpsCaddy => 'HTTPS Caddy';

  @override
  String get loginServerUrlLabel => 'Server URL (NAS / Docker)';

  @override
  String get loginApiKeyLabel => 'Access API Key';

  @override
  String get onboardingConfigAndStart => 'Configure server and start';

  @override
  String get deckTitle => 'FSRS Review Deck';

  @override
  String get deckReload => 'Reload deck';

  @override
  String get dictationTitle => 'Dictation module (Phase 2)';

  @override
  String get shadowingTitle => 'Shadowing module (Phase 2)';

  @override
  String get grammarGuidebook => 'Guidebook';

  @override
  String get interviewHistory => 'Session history';

  @override
  String get interviewJournal => 'Session journal (Obsidian)';

  @override
  String get interviewRandomQuestion => 'Random question';

  @override
  String get interviewYourTranscript => 'Your transcript (Speech-to-Text)';

  @override
  String get interviewInterviewerReply => 'Interviewer\'s reply';

  @override
  String get interviewGrammarCorrections => 'Grammar corrections';

  @override
  String get interviewRecommendedVocab => 'Recommended vocabulary';

  @override
  String get interviewListenModel => 'Listen to model (1.0x)';

  @override
  String get interviewListenSlowShort => 'Slow (0.8x)';

  @override
  String interviewNextQuestionCount(int current, int total) {
    return 'Next question ($current of $total)';
  }

  @override
  String profileSwitchedTo(String name) {
    return 'Switched to $name';
  }

  @override
  String get profileCreateNew => 'Create new profile';

  @override
  String get profileNewProfile => 'New profile';

  @override
  String get profileNameAlias => 'Name or alias';

  @override
  String get profileRoleSpecialty => 'Role / Specialty';

  @override
  String get profileTargetCefr => 'Target CEFR level';

  @override
  String profileLoadError(String error) {
    return 'Error loading profile: $error';
  }

  @override
  String get profileSwitchUser => 'Switch user';

  @override
  String get profileAudioEngine => 'Audio & pronunciation engine';

  @override
  String get profileAudioEngineSub => 'Local Speaches TTS • Speed 1.0x';

  @override
  String get profileAudioSnack => 'Audio settings: local Speaches TTS active.';

  @override
  String get profileNasSync => 'NAS synchronization';

  @override
  String get profileNasSyncSub =>
      'Local / LAN PostgreSQL • Background auto-sync';

  @override
  String get profileNasSnack =>
      'NAS connection verified. Offline queue synced.';

  @override
  String get profileExportTitle => 'Export journal & flashcards';

  @override
  String get profileExportSub =>
      'Markdown for Obsidian and .apkg package for Anki';

  @override
  String get profileExportSnack =>
      'Export ready in /export/apkg and journal in local DB.';

  @override
  String get profileManageUsers => 'Manage multi-user profiles';

  @override
  String profileActiveUser(String name) {
    return 'Active user: $name';
  }

  @override
  String get profilePrivacyTitle => 'Privacy & local cache';

  @override
  String get profilePrivacySub =>
      'Secure Drift storage without sensitive headers';

  @override
  String get profilePrivacySnack =>
      'Local storage sanitized and privacy-compliant.';

  @override
  String get questionsTitle => 'Question bank';

  @override
  String get questionsSearchHint => 'Search by technology or topic...';

  @override
  String get questionsNoResults => 'No matching questions found.';

  @override
  String get questionsFullQuestion => 'Full question:';

  @override
  String get questionsModelAnswer => 'Model answer:';

  @override
  String get questionsInterviewTip => 'Interview tip:';

  @override
  String get questionsPractice => 'Practice this question';

  @override
  String get settingsTitleDiag => 'Settings & diagnostics';

  @override
  String get settingsServerConn => 'Server connection';

  @override
  String get settingsServerAddr => 'Server address (Base URL)';

  @override
  String get settingsApiKeyAuth => 'Authentication API Key';

  @override
  String get settingsDiagnostics => 'Diagnostics';

  @override
  String get settingsOfflineQueue => 'Offline recordings queue';

  @override
  String get settingsForceSync => 'Force queue sync';

  @override
  String get settingsSessionSecurity => 'Session & security';

  @override
  String get statsLogEfset => 'Log EF SET score';

  @override
  String get statsLevelScore => 'Level and score';

  @override
  String get statsEfsetUpdated => 'EF SET milestone updated successfully!';

  @override
  String get statsReportCopied => 'Report copied to clipboard!';

  @override
  String get statsTitle => 'Progress & journal';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsLastWeek => 'Last week';

  @override
  String get statsMilestones => 'Unlocked milestones';

  @override
  String get statsEfsetNote => 'EF SET note';

  @override
  String get statsTimeline => 'Session timeline';

  @override
  String get statsNoteCopied => 'Note copied to clipboard! Ready for Obsidian.';

  @override
  String get statsErrorsBreakdown => 'Error breakdown';

  @override
  String statsErrorsLogged(int count) {
    return '$count errors logged';
  }

  @override
  String get vocabBackToEnglish => 'Back to English';

  @override
  String get vocabRetryPronunciation => 'Retry pronunciation';

  @override
  String get vocabReviewInFsrs => 'Review in FSRS deck';

  @override
  String vocabSavedToFsrs(String term) {
    return '\'$term\' saved to your local FSRS deck';
  }

  @override
  String get vocabSearchHint => 'Search term or definition...';

  @override
  String get loginTagline => 'Private, self-hosted technical interview coach';

  @override
  String get connPresets => 'Connection presets';

  @override
  String get onboardingHeroSubtitle =>
      'Your personal coach for technical interview practice in English, 100% private and self-hosted.';

  @override
  String get deckDailyComplete => 'Daily review complete!';

  @override
  String get deckDailyCompleteBody =>
      'You\'ve reviewed all your due cards with the FSRS algorithm. Retention is optimized for long-term memory.';

  @override
  String get dictationHeading => 'Listening & dictation training';

  @override
  String get dictationBody =>
      'In the next phase you\'ll be able to listen to technical English audio clips and transcribe them to train listening discrimination and spelling.';

  @override
  String get shadowingHeading => 'Shadowing technique';

  @override
  String get shadowingBody =>
      'In the next phase you\'ll be able to immediately repeat native phrases synthesized by Piper/Kokoro, training rhythm, intonation and response speed for real interviews.';

  @override
  String get grammarHintEsToggle => 'Show hint in Spanish';

  @override
  String get grammarPracticeComplete => 'Practice session complete!';

  @override
  String get grammarContinueRoadmap => 'Continue to roadmap';

  @override
  String get grammarRepeatUnit => 'Repeat this unit\'s exercises';

  @override
  String get grammarStartDrills => 'Start interactive drills';

  @override
  String get grammarLearningPath => 'Grammar Learning Path';

  @override
  String get grammarInteractiveSession => 'Interactive session';

  @override
  String get grammarKeyRule => 'Key rule:';

  @override
  String get grammarTipsEsToggle => 'Show tips in Spanish';

  @override
  String get homeNextBestActionLabel => 'NEXT BEST ACTION';

  @override
  String get homeContinuePath => 'Continue guided path';

  @override
  String get homeYourLearningPath => 'Your learning path';

  @override
  String get homeTodayFocus => 'Your focus today';

  @override
  String get homeTrainingModules => 'Training modules';

  @override
  String get homeCommProgress => 'Your communication progress';

  @override
  String get interviewHubAdaptive =>
      'Adaptive simulator with Whisper phonetic analysis and STAR evaluation.';

  @override
  String get interviewSessionConfig => 'Session configuration';

  @override
  String get interviewSkillsAssessed =>
      'Skills assessed: Pronunciation and phonetics (Whisper), STAR structure, filler-word detection and grammatical accuracy.';

  @override
  String get interviewStartPractice => 'Start practice session';

  @override
  String get interviewSearchNoTermResults =>
      'No questions found for that term.';

  @override
  String get interviewShadowingPhrase => 'Model phrase to repeat (Shadowing):';

  @override
  String get interviewKeyVocabInclude =>
      'Recommended key vocabulary to include:';

  @override
  String get interviewStarMethod => 'STAR method to structure your answer';

  @override
  String get interviewPronunciationEval => 'Pronunciation & voice evaluation';

  @override
  String get interviewComplexPhonetics =>
      'Technical terms with complex phonetics detected:';

  @override
  String get interviewModelPhraseRef => 'Reference model phrase (Senior IT)';

  @override
  String get interviewModelPhraseRefSub =>
      'Learn how a senior engineer would answer using the STAR method';

  @override
  String get profileSwitchUserTitle => 'Switch user profile';

  @override
  String get profileSwitchUserBody =>
      'Choose the active profile to study and sync your independent metrics on the NAS:';

  @override
  String get profileGlobalProgress => 'Global progress & experience';

  @override
  String get profileKeyMetrics => 'Key learning metrics';

  @override
  String get profileMasteryBySkill => 'Mastery level by skill';

  @override
  String get profileConsistencyActivity => 'Consistency & activity';

  @override
  String get profileLast30Days => 'Last 30 days';

  @override
  String get profileHeatmap30 => '30-day heatmap';

  @override
  String get profileLess => 'Less';

  @override
  String get profileMore => 'More';

  @override
  String get profileAchievementsCheckpoints => 'Achievements & checkpoints';

  @override
  String get profileSystemAccountConfig => 'System & account settings';

  @override
  String get settingsLogoutConfirmBody =>
      'The JWT token and API Key will be removed from secure storage. Continue?';

  @override
  String get settingsPresetHelp =>
      'Select an access preset or enter the direct URL of your NAS or tunnel.';

  @override
  String get settingsOfflineQueueHelp =>
      'Answers recorded without a server connection are stored locally and synced in the background.';

  @override
  String get settingsSessionHelp =>
      'Your session stores a cryptographic JWT in Flutter Secure Storage. You can log out to clear credentials.';

  @override
  String get statsEfsetHelp =>
      'Enter your official EF SET test score (example: C1 - 65/100 or B2 - 58/100):';

  @override
  String get statsWeeklyReportObsidian => 'Weekly Obsidian report';

  @override
  String get statsWeeklyReportSub =>
      'Export your weekly summary with mistakes and progress in Markdown.';

  @override
  String get statsWeeklyErrorComparison => 'Weekly error comparison';

  @override
  String get statsNoSessions => 'No journal sessions yet';

  @override
  String get statsNoSessionsSub =>
      'Each completed simulation will automatically save a note in SQLite ready for Obsidian.';

  @override
  String get statsHabitTip =>
      'The daily 15-minute habit makes the difference in your fluency.';

  @override
  String get statsAnswerActivity7d => 'Answer activity (last 7 days)';

  @override
  String get vocabFlipCardHint => 'Flip card (translation & mnemonic)';

  @override
  String get vocabTranslationContext => 'TRANSLATION & CONTEXT';

  @override
  String get vocabDefinitionEquiv => 'Definition & equivalence:';

  @override
  String get vocabMnemonicTip => 'Mnemonic tip to remember:';

  @override
  String get vocabAnalyzingWhisper =>
      'Analyzing pronunciation and clarity with Whisper...';

  @override
  String get vocabRecordingPrompt =>
      'Recording... Pronounce the term in English';

  @override
  String get vocabTestPronunciation => 'Test my pronunciation (record voice)';

  @override
  String get vocabPacksThematic => 'Thematic engineering packs (7 tracks)';

  @override
  String get vocabHubMasterSub =>
      'Master IPA phonetics, Microsoft TTS pronunciation (1.0x/0.8x) and real IT context.';

  @override
  String get vocabPhoneticsAudioQuiz =>
      'IPA phonetics • Audio 1.0x/0.8x • Quizzes';

  @override
  String get vocabPronunciationTools => 'Curated pronunciation & IPA tools';

  @override
  String get vocabTrainingPath => 'Vocabulary Training Path';

  @override
  String get vocabNoSearchResults => 'No terms found for this search.';

  @override
  String get vocabChooseMode => 'How do you want to practice this pack?';

  @override
  String get vocabModeLearn => 'Learn';

  @override
  String get vocabModePractice => 'Practice';

  @override
  String get vocabModeLearnSub =>
      'Explore cards with definition, example and pronunciation';

  @override
  String get vocabModePracticeSub =>
      'Adaptive mixed session; mistakes go to your FSRS deck';

  @override
  String get interviewPacksTitle => 'Structured Interview Packs';

  @override
  String get interviewPacksSubtitle =>
      'Pedagogical simulations with clear objectives, tips and STAR evaluation';

  @override
  String get interviewPackStart => 'Start Practice Session';

  @override
  String get interviewPackObjective => 'Session Objective';

  @override
  String get interviewPackFeedbackFocus => 'Evaluation Focus';

  @override
  String interviewPackEstimatedTime(Object minutes) {
    return '$minutes min estimated';
  }

  @override
  String get interviewPackSkillsCovered => 'Skills Practiced';

  @override
  String get interviewPackTips => 'Tactical Tips';

  @override
  String get interviewPackBack => 'Back';
}
