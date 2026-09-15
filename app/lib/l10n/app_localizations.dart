import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'English Brain'**
  String get appTitle;

  /// App version string
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String appVersion(String version);

  /// Bottom nav: home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: interview
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get navInterview;

  /// Bottom nav: vocabulary
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get navVocabulary;

  /// Bottom nav: grammar
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get navGrammar;

  /// Bottom nav: comprehension
  ///
  /// In en, this message translates to:
  /// **'Input'**
  String get navComprehension;

  /// Bottom nav: FSRS flashcard deck
  ///
  /// In en, this message translates to:
  /// **'FSRS Deck'**
  String get navFsrs;

  /// Bottom nav: profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGreetingEvening;

  /// No description provided for @homeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String homeStreakDays(int count);

  /// No description provided for @homeTotalXp.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP'**
  String homeTotalXp(int xp);

  /// No description provided for @homeLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String homeLevel(String level);

  /// No description provided for @homeDailyProgress.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get homeDailyProgress;

  /// No description provided for @homeModulesSection.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get homeModulesSection;

  /// No description provided for @homeNextBestAction.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get homeNextBestAction;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecentActivity;

  /// No description provided for @homeMetricsSection.
  ///
  /// In en, this message translates to:
  /// **'Today\'s stats'**
  String get homeMetricsSection;

  /// No description provided for @homeSessionsToday.
  ///
  /// In en, this message translates to:
  /// **'Sessions today'**
  String get homeSessionsToday;

  /// No description provided for @homeWordsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Words reviewed'**
  String get homeWordsReviewed;

  /// No description provided for @homeGrammarScore.
  ///
  /// In en, this message translates to:
  /// **'Grammar score'**
  String get homeGrammarScore;

  /// No description provided for @homeStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get homeStreak;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get homeKeepGoing;

  /// No description provided for @homeStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get homeStartSession;

  /// No description provided for @homeResumePractice.
  ///
  /// In en, this message translates to:
  /// **'Resume practice'**
  String get homeResumePractice;

  /// No description provided for @homeNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet today'**
  String get homeNoActivity;

  /// No description provided for @homeStartFirstSession.
  ///
  /// In en, this message translates to:
  /// **'Start your first session'**
  String get homeStartFirstSession;

  /// No description provided for @homeConnectedToServer.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get homeConnectedToServer;

  /// No description provided for @homeOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get homeOfflineMode;

  /// No description provided for @homeOfflineSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get homeOfflineSyncing;

  /// No description provided for @homePendingSync.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String homePendingSync(int count);

  /// No description provided for @interviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Simulator'**
  String get interviewTitle;

  /// No description provided for @interviewHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Interview Hub'**
  String get interviewHubTitle;

  /// No description provided for @interviewHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Practice technical, HR and system design interviews'**
  String get interviewHubSubtitle;

  /// No description provided for @interviewSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get interviewSelectCategory;

  /// No description provided for @interviewSelectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select difficulty'**
  String get interviewSelectDifficulty;

  /// No description provided for @interviewSelectMode.
  ///
  /// In en, this message translates to:
  /// **'Select mode'**
  String get interviewSelectMode;

  /// No description provided for @interviewStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get interviewStartSession;

  /// No description provided for @interviewContinueSession.
  ///
  /// In en, this message translates to:
  /// **'Continue session'**
  String get interviewContinueSession;

  /// No description provided for @interviewEndSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get interviewEndSession;

  /// No description provided for @interviewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String interviewQuestion(int current, int total);

  /// No description provided for @interviewNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'No questions found'**
  String get interviewNoQuestions;

  /// No description provided for @interviewNoQuestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different category or difficulty'**
  String get interviewNoQuestionsSubtitle;

  /// No description provided for @interviewRecordAnswer.
  ///
  /// In en, this message translates to:
  /// **'Record your answer'**
  String get interviewRecordAnswer;

  /// No description provided for @interviewRecordingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get interviewRecordingInProgress;

  /// No description provided for @interviewRecordingStop.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get interviewRecordingStop;

  /// No description provided for @interviewUploading.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your answer...'**
  String get interviewUploading;

  /// No description provided for @interviewFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Feedback'**
  String get interviewFeedbackTitle;

  /// No description provided for @interviewModelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Model answer'**
  String get interviewModelAnswer;

  /// No description provided for @interviewNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get interviewNextQuestion;

  /// No description provided for @interviewPrevQuestion.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get interviewPrevQuestion;

  /// No description provided for @interviewBrowseQuestions.
  ///
  /// In en, this message translates to:
  /// **'Browse questions'**
  String get interviewBrowseQuestions;

  /// No description provided for @interviewSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search questions...'**
  String get interviewSearchPlaceholder;

  /// No description provided for @interviewSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No questions match'**
  String get interviewSearchNoResults;

  /// No description provided for @interviewSearchResults.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String interviewSearchResults(int count);

  /// No description provided for @interviewTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get interviewTips;

  /// No description provided for @interviewTipsToggle.
  ///
  /// In en, this message translates to:
  /// **'Show tips'**
  String get interviewTipsToggle;

  /// No description provided for @interviewStarGuide.
  ///
  /// In en, this message translates to:
  /// **'STAR Framework'**
  String get interviewStarGuide;

  /// No description provided for @interviewStarSituation.
  ///
  /// In en, this message translates to:
  /// **'Situation'**
  String get interviewStarSituation;

  /// No description provided for @interviewStarSituationHint.
  ///
  /// In en, this message translates to:
  /// **'Set the context: when, where, what project?'**
  String get interviewStarSituationHint;

  /// No description provided for @interviewStarTask.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get interviewStarTask;

  /// No description provided for @interviewStarTaskHint.
  ///
  /// In en, this message translates to:
  /// **'Your specific responsibility or challenge'**
  String get interviewStarTaskHint;

  /// No description provided for @interviewStarAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get interviewStarAction;

  /// No description provided for @interviewStarActionHint.
  ///
  /// In en, this message translates to:
  /// **'Concrete steps you took — use \'I did\', not \'We did\''**
  String get interviewStarActionHint;

  /// No description provided for @interviewStarResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get interviewStarResult;

  /// No description provided for @interviewStarResultHint.
  ///
  /// In en, this message translates to:
  /// **'Quantify the impact: % improvement, time saved'**
  String get interviewStarResultHint;

  /// No description provided for @interviewModeLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get interviewModeLesson;

  /// No description provided for @interviewModeCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint'**
  String get interviewModeCheckpoint;

  /// No description provided for @interviewModeMock.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview'**
  String get interviewModeMock;

  /// No description provided for @interviewModeShadowing.
  ///
  /// In en, this message translates to:
  /// **'Shadowing'**
  String get interviewModeShadowing;

  /// No description provided for @interviewScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get interviewScoreLabel;

  /// No description provided for @interviewSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get interviewSessionComplete;

  /// No description provided for @interviewSessionSaved.
  ///
  /// In en, this message translates to:
  /// **'Session saved'**
  String get interviewSessionSaved;

  /// No description provided for @interviewOfflineQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved offline, will sync when connected'**
  String get interviewOfflineQueued;

  /// No description provided for @interviewCategoryTech.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get interviewCategoryTech;

  /// No description provided for @interviewCategoryHr.
  ///
  /// In en, this message translates to:
  /// **'HR'**
  String get interviewCategoryHr;

  /// No description provided for @interviewCategorySystemDesign.
  ///
  /// In en, this message translates to:
  /// **'System Design'**
  String get interviewCategorySystemDesign;

  /// No description provided for @interviewCategoryCloudArch.
  ///
  /// In en, this message translates to:
  /// **'Cloud Architecture'**
  String get interviewCategoryCloudArch;

  /// No description provided for @interviewCategoryAiMl.
  ///
  /// In en, this message translates to:
  /// **'AI / ML'**
  String get interviewCategoryAiMl;

  /// No description provided for @interviewCategorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get interviewCategorySecurity;

  /// No description provided for @interviewCategoryLeadership.
  ///
  /// In en, this message translates to:
  /// **'Leadership'**
  String get interviewCategoryLeadership;

  /// No description provided for @interviewCategoryBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Behavioral'**
  String get interviewCategoryBehavioral;

  /// No description provided for @interviewCategoryVocab.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get interviewCategoryVocab;

  /// No description provided for @interviewCategoryAgile.
  ///
  /// In en, this message translates to:
  /// **'Agile'**
  String get interviewCategoryAgile;

  /// No description provided for @interviewCategoryDatabases.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get interviewCategoryDatabases;

  /// No description provided for @interviewCategoryNetworking.
  ///
  /// In en, this message translates to:
  /// **'Networking'**
  String get interviewCategoryNetworking;

  /// No description provided for @interviewCategoryDevops.
  ///
  /// In en, this message translates to:
  /// **'DevOps'**
  String get interviewCategoryDevops;

  /// No description provided for @interviewDifficultyJunior.
  ///
  /// In en, this message translates to:
  /// **'Junior'**
  String get interviewDifficultyJunior;

  /// No description provided for @interviewDifficultyMid.
  ///
  /// In en, this message translates to:
  /// **'Mid'**
  String get interviewDifficultyMid;

  /// No description provided for @interviewDifficultySenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get interviewDifficultySenior;

  /// No description provided for @interviewDifficultyStrategic.
  ///
  /// In en, this message translates to:
  /// **'Strategic'**
  String get interviewDifficultyStrategic;

  /// No description provided for @vocabTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabTitle;

  /// No description provided for @vocabHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Hub'**
  String get vocabHubTitle;

  /// No description provided for @vocabHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master technical and professional vocabulary'**
  String get vocabHubSubtitle;

  /// No description provided for @vocabPacksAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} packs available'**
  String vocabPacksAvailable(int count);

  /// No description provided for @vocabSelectPack.
  ///
  /// In en, this message translates to:
  /// **'Select a pack to practice'**
  String get vocabSelectPack;

  /// No description provided for @vocabCardFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get vocabCardFront;

  /// No description provided for @vocabCardBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get vocabCardBack;

  /// No description provided for @vocabFlipCard.
  ///
  /// In en, this message translates to:
  /// **'Flip card'**
  String get vocabFlipCard;

  /// No description provided for @vocabFlipToSpanish.
  ///
  /// In en, this message translates to:
  /// **'See Spanish'**
  String get vocabFlipToSpanish;

  /// No description provided for @vocabFlipToEnglish.
  ///
  /// In en, this message translates to:
  /// **'See English'**
  String get vocabFlipToEnglish;

  /// No description provided for @vocabDefinition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get vocabDefinition;

  /// No description provided for @vocabExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get vocabExample;

  /// No description provided for @vocabMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Memory tip'**
  String get vocabMnemonic;

  /// No description provided for @vocabPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get vocabPronunciation;

  /// No description provided for @vocabPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get vocabPlayAudio;

  /// No description provided for @vocabSlowAudio.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get vocabSlowAudio;

  /// No description provided for @vocabNormalAudio.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get vocabNormalAudio;

  /// No description provided for @vocabRecordPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Record your pronunciation'**
  String get vocabRecordPronunciation;

  /// No description provided for @vocabRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get vocabRecording;

  /// No description provided for @vocabCheckPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Check pronunciation'**
  String get vocabCheckPronunciation;

  /// No description provided for @vocabAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing pronunciation...'**
  String get vocabAnalyzing;

  /// No description provided for @vocabPronunciationScore.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation score: {score}%'**
  String vocabPronunciationScore(int score);

  /// No description provided for @vocabPronunciationGood.
  ///
  /// In en, this message translates to:
  /// **'Great pronunciation!'**
  String get vocabPronunciationGood;

  /// No description provided for @vocabPronunciationAverage.
  ///
  /// In en, this message translates to:
  /// **'Good, keep practicing'**
  String get vocabPronunciationAverage;

  /// No description provided for @vocabPronunciationNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs improvement'**
  String get vocabPronunciationNeedsWork;

  /// No description provided for @vocabAddToFsrs.
  ///
  /// In en, this message translates to:
  /// **'Add to FSRS deck'**
  String get vocabAddToFsrs;

  /// No description provided for @vocabAddedToFsrs.
  ///
  /// In en, this message translates to:
  /// **'Added to your review deck'**
  String get vocabAddedToFsrs;

  /// No description provided for @vocabNextWord.
  ///
  /// In en, this message translates to:
  /// **'Next word'**
  String get vocabNextWord;

  /// No description provided for @vocabPrevWord.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get vocabPrevWord;

  /// No description provided for @vocabWordCount.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String vocabWordCount(int current, int total);

  /// No description provided for @vocabProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% mastered'**
  String vocabProgress(int percent);

  /// No description provided for @vocabMarkMastered.
  ///
  /// In en, this message translates to:
  /// **'Mark as mastered'**
  String get vocabMarkMastered;

  /// No description provided for @vocabAlreadyMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered!'**
  String get vocabAlreadyMastered;

  /// No description provided for @vocabDomainTech.
  ///
  /// In en, this message translates to:
  /// **'Technical'**
  String get vocabDomainTech;

  /// No description provided for @vocabDomainInterview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get vocabDomainInterview;

  /// No description provided for @vocabDomainGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get vocabDomainGeneral;

  /// No description provided for @vocabLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get vocabLevelLabel;

  /// No description provided for @vocabPackCompleted.
  ///
  /// In en, this message translates to:
  /// **'Pack completed!'**
  String get vocabPackCompleted;

  /// No description provided for @vocabPackCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All words reviewed. Come back tomorrow for spaced repetition.'**
  String get vocabPackCompletedSubtitle;

  /// No description provided for @vocabNoPackSelected.
  ///
  /// In en, this message translates to:
  /// **'No pack selected'**
  String get vocabNoPackSelected;

  /// No description provided for @vocabNoPackSelectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go back and select a vocabulary pack to practice'**
  String get vocabNoPackSelectedSubtitle;

  /// No description provided for @grammarTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammarTitle;

  /// No description provided for @grammarHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar Hub'**
  String get grammarHubTitle;

  /// No description provided for @grammarHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Master English grammar from basics to advanced'**
  String get grammarHubSubtitle;

  /// No description provided for @grammarSelectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select level'**
  String get grammarSelectLevel;

  /// No description provided for @grammarSelectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select unit'**
  String get grammarSelectUnit;

  /// No description provided for @grammarCheckAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get grammarCheckAnswer;

  /// No description provided for @grammarNextExercise.
  ///
  /// In en, this message translates to:
  /// **'Next exercise'**
  String get grammarNextExercise;

  /// No description provided for @grammarPrevExercise.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get grammarPrevExercise;

  /// No description provided for @grammarScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}%'**
  String grammarScore(int score);

  /// No description provided for @grammarCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get grammarCorrect;

  /// No description provided for @grammarIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get grammarIncorrect;

  /// No description provided for @grammarExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get grammarExplanation;

  /// No description provided for @grammarYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get grammarYourAnswer;

  /// No description provided for @grammarCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get grammarCorrectAnswer;

  /// No description provided for @grammarLevelA1.
  ///
  /// In en, this message translates to:
  /// **'A1 — Beginner'**
  String get grammarLevelA1;

  /// No description provided for @grammarLevelA2.
  ///
  /// In en, this message translates to:
  /// **'A2 — Elementary'**
  String get grammarLevelA2;

  /// No description provided for @grammarLevelB1.
  ///
  /// In en, this message translates to:
  /// **'B1 — Intermediate'**
  String get grammarLevelB1;

  /// No description provided for @grammarLevelB2.
  ///
  /// In en, this message translates to:
  /// **'B2 — Upper Intermediate'**
  String get grammarLevelB2;

  /// No description provided for @grammarLevelC1.
  ///
  /// In en, this message translates to:
  /// **'C1 — Advanced'**
  String get grammarLevelC1;

  /// No description provided for @grammarUnitComplete.
  ///
  /// In en, this message translates to:
  /// **'Unit complete!'**
  String get grammarUnitComplete;

  /// No description provided for @grammarDrillsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} drills remaining'**
  String grammarDrillsRemaining(int count);

  /// No description provided for @grammarSkipExercise.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get grammarSkipExercise;

  /// No description provided for @grammarHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get grammarHint;

  /// No description provided for @grammarShowHint.
  ///
  /// In en, this message translates to:
  /// **'Show hint'**
  String get grammarShowHint;

  /// No description provided for @grammarProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String grammarProgress(int current, int total);

  /// No description provided for @grammarTypeMultipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get grammarTypeMultipleChoice;

  /// No description provided for @grammarTypeFillBlank.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank'**
  String get grammarTypeFillBlank;

  /// No description provided for @grammarTypeReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder words'**
  String get grammarTypeReorder;

  /// No description provided for @grammarTypeTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get grammarTypeTranslate;

  /// No description provided for @fsrsTitle.
  ///
  /// In en, this message translates to:
  /// **'FSRS Deck'**
  String get fsrsTitle;

  /// No description provided for @fsrsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spaced repetition flashcards'**
  String get fsrsSubtitle;

  /// No description provided for @fsrsCardsDue.
  ///
  /// In en, this message translates to:
  /// **'{count} cards due'**
  String fsrsCardsDue(int count);

  /// No description provided for @fsrsNewCards.
  ///
  /// In en, this message translates to:
  /// **'{count} new cards'**
  String fsrsNewCards(int count);

  /// No description provided for @fsrsCardsLearning.
  ///
  /// In en, this message translates to:
  /// **'{count} learning'**
  String fsrsCardsLearning(int count);

  /// No description provided for @fsrsStartReview.
  ///
  /// In en, this message translates to:
  /// **'Start review'**
  String get fsrsStartReview;

  /// No description provided for @fsrsNoCardsDue.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get fsrsNoCardsDue;

  /// No description provided for @fsrsNoCardsDueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No cards due for review. Come back later.'**
  String get fsrsNoCardsDueSubtitle;

  /// No description provided for @fsrsCardFront.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get fsrsCardFront;

  /// No description provided for @fsrsCardBack.
  ///
  /// In en, this message translates to:
  /// **'Back (tap to reveal)'**
  String get fsrsCardBack;

  /// No description provided for @fsrsRevealAnswer.
  ///
  /// In en, this message translates to:
  /// **'Reveal answer'**
  String get fsrsRevealAnswer;

  /// No description provided for @fsrsRatingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get fsrsRatingAgain;

  /// No description provided for @fsrsRatingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get fsrsRatingHard;

  /// No description provided for @fsrsRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get fsrsRatingGood;

  /// No description provided for @fsrsRatingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get fsrsRatingEasy;

  /// No description provided for @fsrsNextReview.
  ///
  /// In en, this message translates to:
  /// **'Next review: {date}'**
  String fsrsNextReview(String date);

  /// No description provided for @fsrsSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get fsrsSessionComplete;

  /// No description provided for @fsrsExportToAnki.
  ///
  /// In en, this message translates to:
  /// **'Export to Anki'**
  String get fsrsExportToAnki;

  /// No description provided for @fsrsExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get fsrsExporting;

  /// No description provided for @fsrsExported.
  ///
  /// In en, this message translates to:
  /// **'Exported successfully'**
  String get fsrsExported;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get profileTotalXp;

  /// No description provided for @profileWeeklyXp.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get profileWeeklyXp;

  /// No description provided for @profileStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get profileStreak;

  /// No description provided for @profileTimeStudied.
  ///
  /// In en, this message translates to:
  /// **'Study time'**
  String get profileTimeStudied;

  /// No description provided for @profileSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get profileSessions;

  /// No description provided for @profileUnitsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Units completed'**
  String get profileUnitsCompleted;

  /// No description provided for @profileWordsMastered.
  ///
  /// In en, this message translates to:
  /// **'Words mastered'**
  String get profileWordsMastered;

  /// No description provided for @profileSpeakingScore.
  ///
  /// In en, this message translates to:
  /// **'Speaking score'**
  String get profileSpeakingScore;

  /// No description provided for @profileListeningScore.
  ///
  /// In en, this message translates to:
  /// **'Listening score'**
  String get profileListeningScore;

  /// No description provided for @profileSkillsSection.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get profileSkillsSection;

  /// No description provided for @profileSkillGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get profileSkillGrammar;

  /// No description provided for @profileSkillVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get profileSkillVocabulary;

  /// No description provided for @profileSkillListening.
  ///
  /// In en, this message translates to:
  /// **'Listening'**
  String get profileSkillListening;

  /// No description provided for @profileSkillSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Speaking'**
  String get profileSkillSpeaking;

  /// No description provided for @profileActivitySection.
  ///
  /// In en, this message translates to:
  /// **'Practice activity'**
  String get profileActivitySection;

  /// No description provided for @profileAchievementsSection.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get profileAchievementsSection;

  /// No description provided for @profileSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsSection;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio settings'**
  String get profileAudio;

  /// No description provided for @profileSync.
  ///
  /// In en, this message translates to:
  /// **'Sync & data'**
  String get profileSync;

  /// No description provided for @profileExport.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get profileExport;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get profilePrivacy;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogout;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get profileLanguageEs;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get profileDailyGoal;

  /// No description provided for @profileDailyGoalMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min / day'**
  String profileDailyGoalMinutes(int minutes);

  /// No description provided for @profileCefrLevel.
  ///
  /// In en, this message translates to:
  /// **'CEFR Level'**
  String get profileCefrLevel;

  /// No description provided for @profileTarget.
  ///
  /// In en, this message translates to:
  /// **'Target level'**
  String get profileTarget;

  /// No description provided for @profileLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active: {date}'**
  String profileLastActive(String date);

  /// No description provided for @profileNoAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get profileNoAchievements;

  /// No description provided for @profileNoAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete sessions to earn badges'**
  String get profileNoAchievementsSubtitle;

  /// No description provided for @profileBadgeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked!'**
  String get profileBadgeUnlocked;

  /// No description provided for @profileBadgeLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get profileBadgeLocked;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get settingsServerUrl;

  /// No description provided for @settingsApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get settingsApiKey;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get settingsReset;

  /// No description provided for @settingsAppInfo.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get settingsAppInfo;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get settingsClearCache;

  /// No description provided for @settingsCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get settingsCacheCleared;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your English Brain account'**
  String get loginSubtitle;

  /// No description provided for @loginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get loginServerUrl;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginSigningIn;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your credentials.'**
  String get loginError;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get loginOfflineMode;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'English Brain'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered English practice coach'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Practice speaking'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real interview simulations with AI feedback'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Master vocabulary'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'3D flashcards with pronunciation check'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Learn grammar'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Structured drills from A1 to C1'**
  String get onboardingStep3Subtitle;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingConfigServer.
  ///
  /// In en, this message translates to:
  /// **'Configure server'**
  String get onboardingConfigServer;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoConnection;

  /// No description provided for @errorNoConnectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Working in offline mode. Data will sync when connected.'**
  String get errorNoConnectionSubtitle;

  /// No description provided for @errorServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable'**
  String get errorServerUnreachable;

  /// No description provided for @errorServerUnreachableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your server URL in settings'**
  String get errorServerUnreachableSubtitle;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get errorRetry;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get errorTimeout;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get stateLoading;

  /// No description provided for @stateEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmpty;

  /// No description provided for @stateEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a session to see your data here'**
  String get stateEmptySubtitle;

  /// No description provided for @stateSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get stateSyncing;

  /// No description provided for @stateSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get stateSyncComplete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @actionCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get actionCopied;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get actionStart;

  /// No description provided for @actionStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get actionStop;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get actionFinish;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @snackOfflineQueued.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. Will sync when connected.'**
  String get snackOfflineQueued;

  /// No description provided for @snackSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data synced successfully'**
  String get snackSyncSuccess;

  /// No description provided for @snackSyncError.
  ///
  /// In en, this message translates to:
  /// **'Sync failed. Will retry automatically.'**
  String get snackSyncError;

  /// No description provided for @snackCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get snackCopied;

  /// No description provided for @snackSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get snackSaved;

  /// No description provided for @snackError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String snackError(String message);

  /// No description provided for @badgeFirstSession.
  ///
  /// In en, this message translates to:
  /// **'First Session'**
  String get badgeFirstSession;

  /// No description provided for @badgeWeekStreak.
  ///
  /// In en, this message translates to:
  /// **'Week Streak'**
  String get badgeWeekStreak;

  /// No description provided for @badgeVocabMaster.
  ///
  /// In en, this message translates to:
  /// **'Vocab Master'**
  String get badgeVocabMaster;

  /// No description provided for @badgeGrammarAce.
  ///
  /// In en, this message translates to:
  /// **'Grammar Ace'**
  String get badgeGrammarAce;

  /// No description provided for @badgeFsrsReviewer.
  ///
  /// In en, this message translates to:
  /// **'FSRS Reviewer'**
  String get badgeFsrsReviewer;

  /// No description provided for @badgePronunciationPro.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation Pro'**
  String get badgePronunciationPro;

  /// No description provided for @badgeMockInterview.
  ///
  /// In en, this message translates to:
  /// **'Mock Interview'**
  String get badgeMockInterview;

  /// No description provided for @badgeCheckpoint.
  ///
  /// In en, this message translates to:
  /// **'Checkpoint Cleared'**
  String get badgeCheckpoint;

  /// No description provided for @badgeTopPerformer.
  ///
  /// In en, this message translates to:
  /// **'Top Performer'**
  String get badgeTopPerformer;

  /// No description provided for @difficultyJunior.
  ///
  /// In en, this message translates to:
  /// **'Junior'**
  String get difficultyJunior;

  /// No description provided for @difficultyMid.
  ///
  /// In en, this message translates to:
  /// **'Mid'**
  String get difficultyMid;

  /// No description provided for @difficultySenior.
  ///
  /// In en, this message translates to:
  /// **'Senior'**
  String get difficultySenior;

  /// No description provided for @difficultyStrategic.
  ///
  /// In en, this message translates to:
  /// **'Strategic'**
  String get difficultyStrategic;

  /// No description provided for @levelA1.
  ///
  /// In en, this message translates to:
  /// **'A1'**
  String get levelA1;

  /// No description provided for @levelA2.
  ///
  /// In en, this message translates to:
  /// **'A2'**
  String get levelA2;

  /// No description provided for @levelB1.
  ///
  /// In en, this message translates to:
  /// **'B1'**
  String get levelB1;

  /// No description provided for @levelB2.
  ///
  /// In en, this message translates to:
  /// **'B2'**
  String get levelB2;

  /// No description provided for @levelC1.
  ///
  /// In en, this message translates to:
  /// **'C1'**
  String get levelC1;

  /// No description provided for @levelC2.
  ///
  /// In en, this message translates to:
  /// **'C2'**
  String get levelC2;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{min}m'**
  String minutesShort(int min);

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{h}h'**
  String hoursShort(int h);

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'{d}d'**
  String daysShort(int d);

  /// No description provided for @actionPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get actionPractice;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get actionCheck;

  /// No description provided for @actionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// No description provided for @commonExitSession.
  ///
  /// In en, this message translates to:
  /// **'Exit session'**
  String get commonExitSession;

  /// No description provided for @ttsListenNatural.
  ///
  /// In en, this message translates to:
  /// **'Listen with Microsoft natural voice'**
  String get ttsListenNatural;

  /// No description provided for @ttsListenCorrect.
  ///
  /// In en, this message translates to:
  /// **'Listen to the correct phrase in native English'**
  String get ttsListenCorrect;

  /// No description provided for @ttsListenInterviewer.
  ///
  /// In en, this message translates to:
  /// **'Listen to the interviewer'**
  String get ttsListenInterviewer;

  /// No description provided for @ttsListenSlow.
  ///
  /// In en, this message translates to:
  /// **'Listen slowly (0.8x)'**
  String get ttsListenSlow;

  /// No description provided for @ttsPlayInterviewer.
  ///
  /// In en, this message translates to:
  /// **'Play interviewer voice'**
  String get ttsPlayInterviewer;

  /// No description provided for @ttsListenNativeVocab.
  ///
  /// In en, this message translates to:
  /// **'Listen in native English (Microsoft Neural Voice)'**
  String get ttsListenNativeVocab;

  /// No description provided for @ttsListenFullPhrase.
  ///
  /// In en, this message translates to:
  /// **'Listen to full phrase'**
  String get ttsListenFullPhrase;

  /// No description provided for @exportCopyMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Copy Markdown to clipboard (Obsidian)'**
  String get exportCopyMarkdown;

  /// No description provided for @exportCopyMarkdownObsidian.
  ///
  /// In en, this message translates to:
  /// **'Copy Markdown for Obsidian'**
  String get exportCopyMarkdownObsidian;

  /// No description provided for @exportCopiedObsidian.
  ///
  /// In en, this message translates to:
  /// **'Copied! Ready to paste into your Obsidian vault.'**
  String get exportCopiedObsidian;

  /// No description provided for @connLocalPc.
  ///
  /// In en, this message translates to:
  /// **'Local PC'**
  String get connLocalPc;

  /// No description provided for @connLanHome.
  ///
  /// In en, this message translates to:
  /// **'Home LAN'**
  String get connLanHome;

  /// No description provided for @connWireguard.
  ///
  /// In en, this message translates to:
  /// **'WireGuard'**
  String get connWireguard;

  /// No description provided for @connHttpsCaddy.
  ///
  /// In en, this message translates to:
  /// **'HTTPS Caddy'**
  String get connHttpsCaddy;

  /// No description provided for @loginServerUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Server URL (NAS / Docker)'**
  String get loginServerUrlLabel;

  /// No description provided for @loginApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Access API Key'**
  String get loginApiKeyLabel;

  /// No description provided for @onboardingConfigAndStart.
  ///
  /// In en, this message translates to:
  /// **'Configure server and start'**
  String get onboardingConfigAndStart;

  /// No description provided for @deckTitle.
  ///
  /// In en, this message translates to:
  /// **'FSRS Review Deck'**
  String get deckTitle;

  /// No description provided for @deckReload.
  ///
  /// In en, this message translates to:
  /// **'Reload deck'**
  String get deckReload;

  /// No description provided for @dictationTitle.
  ///
  /// In en, this message translates to:
  /// **'Dictation module (Phase 2)'**
  String get dictationTitle;

  /// No description provided for @shadowingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shadowing module (Phase 2)'**
  String get shadowingTitle;

  /// No description provided for @grammarGuidebook.
  ///
  /// In en, this message translates to:
  /// **'Guidebook'**
  String get grammarGuidebook;

  /// No description provided for @interviewHistory.
  ///
  /// In en, this message translates to:
  /// **'Session history'**
  String get interviewHistory;

  /// No description provided for @interviewJournal.
  ///
  /// In en, this message translates to:
  /// **'Session journal (Obsidian)'**
  String get interviewJournal;

  /// No description provided for @interviewRandomQuestion.
  ///
  /// In en, this message translates to:
  /// **'Random question'**
  String get interviewRandomQuestion;

  /// No description provided for @interviewYourTranscript.
  ///
  /// In en, this message translates to:
  /// **'Your transcript (Speech-to-Text)'**
  String get interviewYourTranscript;

  /// No description provided for @interviewInterviewerReply.
  ///
  /// In en, this message translates to:
  /// **'Interviewer\'s reply'**
  String get interviewInterviewerReply;

  /// No description provided for @interviewGrammarCorrections.
  ///
  /// In en, this message translates to:
  /// **'Grammar corrections'**
  String get interviewGrammarCorrections;

  /// No description provided for @interviewRecommendedVocab.
  ///
  /// In en, this message translates to:
  /// **'Recommended vocabulary'**
  String get interviewRecommendedVocab;

  /// No description provided for @interviewListenModel.
  ///
  /// In en, this message translates to:
  /// **'Listen to model (1.0x)'**
  String get interviewListenModel;

  /// No description provided for @interviewListenSlowShort.
  ///
  /// In en, this message translates to:
  /// **'Slow (0.8x)'**
  String get interviewListenSlowShort;

  /// No description provided for @interviewNextQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'Next question ({current} of {total})'**
  String interviewNextQuestionCount(int current, int total);

  /// No description provided for @profileSwitchedTo.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String profileSwitchedTo(String name);

  /// No description provided for @profileCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new profile'**
  String get profileCreateNew;

  /// No description provided for @profileNewProfile.
  ///
  /// In en, this message translates to:
  /// **'New profile'**
  String get profileNewProfile;

  /// No description provided for @profileNameAlias.
  ///
  /// In en, this message translates to:
  /// **'Name or alias'**
  String get profileNameAlias;

  /// No description provided for @profileRoleSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Role / Specialty'**
  String get profileRoleSpecialty;

  /// No description provided for @profileTargetCefr.
  ///
  /// In en, this message translates to:
  /// **'Target CEFR level'**
  String get profileTargetCefr;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile: {error}'**
  String profileLoadError(String error);

  /// No description provided for @profileSwitchUser.
  ///
  /// In en, this message translates to:
  /// **'Switch user'**
  String get profileSwitchUser;

  /// No description provided for @profileAudioEngine.
  ///
  /// In en, this message translates to:
  /// **'Audio & pronunciation engine'**
  String get profileAudioEngine;

  /// No description provided for @profileAudioEngineSub.
  ///
  /// In en, this message translates to:
  /// **'Local Speaches TTS • Speed 1.0x'**
  String get profileAudioEngineSub;

  /// No description provided for @profileAudioSnack.
  ///
  /// In en, this message translates to:
  /// **'Audio settings: local Speaches TTS active.'**
  String get profileAudioSnack;

  /// No description provided for @profileNasSync.
  ///
  /// In en, this message translates to:
  /// **'NAS synchronization'**
  String get profileNasSync;

  /// No description provided for @profileNasSyncSub.
  ///
  /// In en, this message translates to:
  /// **'Local / LAN PostgreSQL • Background auto-sync'**
  String get profileNasSyncSub;

  /// No description provided for @profileNasSnack.
  ///
  /// In en, this message translates to:
  /// **'NAS connection verified. Offline queue synced.'**
  String get profileNasSnack;

  /// No description provided for @profileExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export journal & flashcards'**
  String get profileExportTitle;

  /// No description provided for @profileExportSub.
  ///
  /// In en, this message translates to:
  /// **'Markdown for Obsidian and .apkg package for Anki'**
  String get profileExportSub;

  /// No description provided for @profileExportSnack.
  ///
  /// In en, this message translates to:
  /// **'Export ready in /export/apkg and journal in local DB.'**
  String get profileExportSnack;

  /// No description provided for @profileManageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage multi-user profiles'**
  String get profileManageUsers;

  /// No description provided for @profileActiveUser.
  ///
  /// In en, this message translates to:
  /// **'Active user: {name}'**
  String profileActiveUser(String name);

  /// No description provided for @profilePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & local cache'**
  String get profilePrivacyTitle;

  /// No description provided for @profilePrivacySub.
  ///
  /// In en, this message translates to:
  /// **'Secure Drift storage without sensitive headers'**
  String get profilePrivacySub;

  /// No description provided for @profilePrivacySnack.
  ///
  /// In en, this message translates to:
  /// **'Local storage sanitized and privacy-compliant.'**
  String get profilePrivacySnack;

  /// No description provided for @questionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Question bank'**
  String get questionsTitle;

  /// No description provided for @questionsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by technology or topic...'**
  String get questionsSearchHint;

  /// No description provided for @questionsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching questions found.'**
  String get questionsNoResults;

  /// No description provided for @questionsFullQuestion.
  ///
  /// In en, this message translates to:
  /// **'Full question:'**
  String get questionsFullQuestion;

  /// No description provided for @questionsModelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Model answer:'**
  String get questionsModelAnswer;

  /// No description provided for @questionsInterviewTip.
  ///
  /// In en, this message translates to:
  /// **'Interview tip:'**
  String get questionsInterviewTip;

  /// No description provided for @questionsPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice this question'**
  String get questionsPractice;

  /// No description provided for @settingsTitleDiag.
  ///
  /// In en, this message translates to:
  /// **'Settings & diagnostics'**
  String get settingsTitleDiag;

  /// No description provided for @settingsServerConn.
  ///
  /// In en, this message translates to:
  /// **'Server connection'**
  String get settingsServerConn;

  /// No description provided for @settingsServerAddr.
  ///
  /// In en, this message translates to:
  /// **'Server address (Base URL)'**
  String get settingsServerAddr;

  /// No description provided for @settingsApiKeyAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication API Key'**
  String get settingsApiKeyAuth;

  /// No description provided for @settingsDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get settingsDiagnostics;

  /// No description provided for @settingsOfflineQueue.
  ///
  /// In en, this message translates to:
  /// **'Offline recordings queue'**
  String get settingsOfflineQueue;

  /// No description provided for @settingsForceSync.
  ///
  /// In en, this message translates to:
  /// **'Force queue sync'**
  String get settingsForceSync;

  /// No description provided for @settingsSessionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Session & security'**
  String get settingsSessionSecurity;

  /// No description provided for @statsLogEfset.
  ///
  /// In en, this message translates to:
  /// **'Log EF SET score'**
  String get statsLogEfset;

  /// No description provided for @statsLevelScore.
  ///
  /// In en, this message translates to:
  /// **'Level and score'**
  String get statsLevelScore;

  /// No description provided for @statsEfsetUpdated.
  ///
  /// In en, this message translates to:
  /// **'EF SET milestone updated successfully!'**
  String get statsEfsetUpdated;

  /// No description provided for @statsReportCopied.
  ///
  /// In en, this message translates to:
  /// **'Report copied to clipboard!'**
  String get statsReportCopied;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress & journal'**
  String get statsTitle;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get statsLastWeek;

  /// No description provided for @statsMilestones.
  ///
  /// In en, this message translates to:
  /// **'Unlocked milestones'**
  String get statsMilestones;

  /// No description provided for @statsEfsetNote.
  ///
  /// In en, this message translates to:
  /// **'EF SET note'**
  String get statsEfsetNote;

  /// No description provided for @statsTimeline.
  ///
  /// In en, this message translates to:
  /// **'Session timeline'**
  String get statsTimeline;

  /// No description provided for @statsNoteCopied.
  ///
  /// In en, this message translates to:
  /// **'Note copied to clipboard! Ready for Obsidian.'**
  String get statsNoteCopied;

  /// No description provided for @statsErrorsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Error breakdown'**
  String get statsErrorsBreakdown;

  /// No description provided for @statsErrorsLogged.
  ///
  /// In en, this message translates to:
  /// **'{count} errors logged'**
  String statsErrorsLogged(int count);

  /// No description provided for @vocabBackToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Back to English'**
  String get vocabBackToEnglish;

  /// No description provided for @vocabRetryPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Retry pronunciation'**
  String get vocabRetryPronunciation;

  /// No description provided for @vocabReviewInFsrs.
  ///
  /// In en, this message translates to:
  /// **'Review in FSRS deck'**
  String get vocabReviewInFsrs;

  /// No description provided for @vocabSavedToFsrs.
  ///
  /// In en, this message translates to:
  /// **'\'{term}\' saved to your local FSRS deck'**
  String vocabSavedToFsrs(String term);

  /// No description provided for @vocabSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search term or definition...'**
  String get vocabSearchHint;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Private, self-hosted technical interview coach'**
  String get loginTagline;

  /// No description provided for @connPresets.
  ///
  /// In en, this message translates to:
  /// **'Connection presets'**
  String get connPresets;

  /// No description provided for @onboardingHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal coach for technical interview practice in English, 100% private and self-hosted.'**
  String get onboardingHeroSubtitle;

  /// No description provided for @deckDailyComplete.
  ///
  /// In en, this message translates to:
  /// **'Daily review complete!'**
  String get deckDailyComplete;

  /// No description provided for @deckDailyCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reviewed all your due cards with the FSRS algorithm. Retention is optimized for long-term memory.'**
  String get deckDailyCompleteBody;

  /// No description provided for @dictationHeading.
  ///
  /// In en, this message translates to:
  /// **'Listening & dictation training'**
  String get dictationHeading;

  /// No description provided for @dictationBody.
  ///
  /// In en, this message translates to:
  /// **'In the next phase you\'ll be able to listen to technical English audio clips and transcribe them to train listening discrimination and spelling.'**
  String get dictationBody;

  /// No description provided for @shadowingHeading.
  ///
  /// In en, this message translates to:
  /// **'Shadowing technique'**
  String get shadowingHeading;

  /// No description provided for @shadowingBody.
  ///
  /// In en, this message translates to:
  /// **'In the next phase you\'ll be able to immediately repeat native phrases synthesized by Piper/Kokoro, training rhythm, intonation and response speed for real interviews.'**
  String get shadowingBody;

  /// No description provided for @grammarHintEsToggle.
  ///
  /// In en, this message translates to:
  /// **'Show hint in Spanish'**
  String get grammarHintEsToggle;

  /// No description provided for @grammarPracticeComplete.
  ///
  /// In en, this message translates to:
  /// **'Practice session complete!'**
  String get grammarPracticeComplete;

  /// No description provided for @grammarContinueRoadmap.
  ///
  /// In en, this message translates to:
  /// **'Continue to roadmap'**
  String get grammarContinueRoadmap;

  /// No description provided for @grammarRepeatUnit.
  ///
  /// In en, this message translates to:
  /// **'Repeat this unit\'s exercises'**
  String get grammarRepeatUnit;

  /// No description provided for @grammarStartDrills.
  ///
  /// In en, this message translates to:
  /// **'Start interactive drills'**
  String get grammarStartDrills;

  /// No description provided for @grammarLearningPath.
  ///
  /// In en, this message translates to:
  /// **'Grammar Learning Path'**
  String get grammarLearningPath;

  /// No description provided for @grammarInteractiveSession.
  ///
  /// In en, this message translates to:
  /// **'Interactive session'**
  String get grammarInteractiveSession;

  /// No description provided for @grammarKeyRule.
  ///
  /// In en, this message translates to:
  /// **'Key rule:'**
  String get grammarKeyRule;

  /// No description provided for @grammarTipsEsToggle.
  ///
  /// In en, this message translates to:
  /// **'Show tips in Spanish'**
  String get grammarTipsEsToggle;

  /// No description provided for @homeNextBestActionLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT BEST ACTION'**
  String get homeNextBestActionLabel;

  /// No description provided for @homeContinuePath.
  ///
  /// In en, this message translates to:
  /// **'Continue guided path'**
  String get homeContinuePath;

  /// No description provided for @homeYourLearningPath.
  ///
  /// In en, this message translates to:
  /// **'Your learning path'**
  String get homeYourLearningPath;

  /// No description provided for @homeTodayFocus.
  ///
  /// In en, this message translates to:
  /// **'Your focus today'**
  String get homeTodayFocus;

  /// No description provided for @homeTrainingModules.
  ///
  /// In en, this message translates to:
  /// **'Training modules'**
  String get homeTrainingModules;

  /// No description provided for @homeCommProgress.
  ///
  /// In en, this message translates to:
  /// **'Your communication progress'**
  String get homeCommProgress;

  /// No description provided for @interviewHubAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive simulator with Whisper phonetic analysis and STAR evaluation.'**
  String get interviewHubAdaptive;

  /// No description provided for @interviewSessionConfig.
  ///
  /// In en, this message translates to:
  /// **'Session configuration'**
  String get interviewSessionConfig;

  /// No description provided for @interviewSkillsAssessed.
  ///
  /// In en, this message translates to:
  /// **'Skills assessed: Pronunciation and phonetics (Whisper), STAR structure, filler-word detection and grammatical accuracy.'**
  String get interviewSkillsAssessed;

  /// No description provided for @interviewStartPractice.
  ///
  /// In en, this message translates to:
  /// **'Start practice session'**
  String get interviewStartPractice;

  /// No description provided for @interviewSearchNoTermResults.
  ///
  /// In en, this message translates to:
  /// **'No questions found for that term.'**
  String get interviewSearchNoTermResults;

  /// No description provided for @interviewShadowingPhrase.
  ///
  /// In en, this message translates to:
  /// **'Model phrase to repeat (Shadowing):'**
  String get interviewShadowingPhrase;

  /// No description provided for @interviewKeyVocabInclude.
  ///
  /// In en, this message translates to:
  /// **'Recommended key vocabulary to include:'**
  String get interviewKeyVocabInclude;

  /// No description provided for @interviewStarMethod.
  ///
  /// In en, this message translates to:
  /// **'STAR method to structure your answer'**
  String get interviewStarMethod;

  /// No description provided for @interviewPronunciationEval.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation & voice evaluation'**
  String get interviewPronunciationEval;

  /// No description provided for @interviewComplexPhonetics.
  ///
  /// In en, this message translates to:
  /// **'Technical terms with complex phonetics detected:'**
  String get interviewComplexPhonetics;

  /// No description provided for @interviewModelPhraseRef.
  ///
  /// In en, this message translates to:
  /// **'Reference model phrase (Senior IT)'**
  String get interviewModelPhraseRef;

  /// No description provided for @interviewModelPhraseRefSub.
  ///
  /// In en, this message translates to:
  /// **'Learn how a senior engineer would answer using the STAR method'**
  String get interviewModelPhraseRefSub;

  /// No description provided for @profileSwitchUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch user profile'**
  String get profileSwitchUserTitle;

  /// No description provided for @profileSwitchUserBody.
  ///
  /// In en, this message translates to:
  /// **'Choose the active profile to study and sync your independent metrics on the NAS:'**
  String get profileSwitchUserBody;

  /// No description provided for @profileGlobalProgress.
  ///
  /// In en, this message translates to:
  /// **'Global progress & experience'**
  String get profileGlobalProgress;

  /// No description provided for @profileKeyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key learning metrics'**
  String get profileKeyMetrics;

  /// No description provided for @profileMasteryBySkill.
  ///
  /// In en, this message translates to:
  /// **'Mastery level by skill'**
  String get profileMasteryBySkill;

  /// No description provided for @profileConsistencyActivity.
  ///
  /// In en, this message translates to:
  /// **'Consistency & activity'**
  String get profileConsistencyActivity;

  /// No description provided for @profileLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get profileLast30Days;

  /// No description provided for @profileHeatmap30.
  ///
  /// In en, this message translates to:
  /// **'30-day heatmap'**
  String get profileHeatmap30;

  /// No description provided for @profileLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get profileLess;

  /// No description provided for @profileMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get profileMore;

  /// No description provided for @profileAchievementsCheckpoints.
  ///
  /// In en, this message translates to:
  /// **'Achievements & checkpoints'**
  String get profileAchievementsCheckpoints;

  /// No description provided for @profileSystemAccountConfig.
  ///
  /// In en, this message translates to:
  /// **'System & account settings'**
  String get profileSystemAccountConfig;

  /// No description provided for @settingsLogoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The JWT token and API Key will be removed from secure storage. Continue?'**
  String get settingsLogoutConfirmBody;

  /// No description provided for @settingsPresetHelp.
  ///
  /// In en, this message translates to:
  /// **'Select an access preset or enter the direct URL of your NAS or tunnel.'**
  String get settingsPresetHelp;

  /// No description provided for @settingsOfflineQueueHelp.
  ///
  /// In en, this message translates to:
  /// **'Answers recorded without a server connection are stored locally and synced in the background.'**
  String get settingsOfflineQueueHelp;

  /// No description provided for @settingsSessionHelp.
  ///
  /// In en, this message translates to:
  /// **'Your session stores a cryptographic JWT in Flutter Secure Storage. You can log out to clear credentials.'**
  String get settingsSessionHelp;

  /// No description provided for @statsEfsetHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter your official EF SET test score (example: C1 - 65/100 or B2 - 58/100):'**
  String get statsEfsetHelp;

  /// No description provided for @statsWeeklyReportObsidian.
  ///
  /// In en, this message translates to:
  /// **'Weekly Obsidian report'**
  String get statsWeeklyReportObsidian;

  /// No description provided for @statsWeeklyReportSub.
  ///
  /// In en, this message translates to:
  /// **'Export your weekly summary with mistakes and progress in Markdown.'**
  String get statsWeeklyReportSub;

  /// No description provided for @statsWeeklyErrorComparison.
  ///
  /// In en, this message translates to:
  /// **'Weekly error comparison'**
  String get statsWeeklyErrorComparison;

  /// No description provided for @statsNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No journal sessions yet'**
  String get statsNoSessions;

  /// No description provided for @statsNoSessionsSub.
  ///
  /// In en, this message translates to:
  /// **'Each completed simulation will automatically save a note in SQLite ready for Obsidian.'**
  String get statsNoSessionsSub;

  /// No description provided for @statsHabitTip.
  ///
  /// In en, this message translates to:
  /// **'The daily 15-minute habit makes the difference in your fluency.'**
  String get statsHabitTip;

  /// No description provided for @statsAnswerActivity7d.
  ///
  /// In en, this message translates to:
  /// **'Answer activity (last 7 days)'**
  String get statsAnswerActivity7d;

  /// No description provided for @vocabFlipCardHint.
  ///
  /// In en, this message translates to:
  /// **'Flip card (translation & mnemonic)'**
  String get vocabFlipCardHint;

  /// No description provided for @vocabTranslationContext.
  ///
  /// In en, this message translates to:
  /// **'TRANSLATION & CONTEXT'**
  String get vocabTranslationContext;

  /// No description provided for @vocabDefinitionEquiv.
  ///
  /// In en, this message translates to:
  /// **'Definition & equivalence:'**
  String get vocabDefinitionEquiv;

  /// No description provided for @vocabMnemonicTip.
  ///
  /// In en, this message translates to:
  /// **'Mnemonic tip to remember:'**
  String get vocabMnemonicTip;

  /// No description provided for @vocabAnalyzingWhisper.
  ///
  /// In en, this message translates to:
  /// **'Analyzing pronunciation and clarity with Whisper...'**
  String get vocabAnalyzingWhisper;

  /// No description provided for @vocabRecordingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Recording... Pronounce the term in English'**
  String get vocabRecordingPrompt;

  /// No description provided for @vocabTestPronunciation.
  ///
  /// In en, this message translates to:
  /// **'Test my pronunciation (record voice)'**
  String get vocabTestPronunciation;

  /// No description provided for @vocabPacksThematic.
  ///
  /// In en, this message translates to:
  /// **'Thematic engineering packs (7 tracks)'**
  String get vocabPacksThematic;

  /// No description provided for @vocabHubMasterSub.
  ///
  /// In en, this message translates to:
  /// **'Master IPA phonetics, Microsoft TTS pronunciation (1.0x/0.8x) and real IT context.'**
  String get vocabHubMasterSub;

  /// No description provided for @vocabPhoneticsAudioQuiz.
  ///
  /// In en, this message translates to:
  /// **'IPA phonetics • Audio 1.0x/0.8x • Quizzes'**
  String get vocabPhoneticsAudioQuiz;

  /// No description provided for @vocabPronunciationTools.
  ///
  /// In en, this message translates to:
  /// **'Curated pronunciation & IPA tools'**
  String get vocabPronunciationTools;

  /// No description provided for @vocabTrainingPath.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary Training Path'**
  String get vocabTrainingPath;

  /// No description provided for @vocabNoSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No terms found for this search.'**
  String get vocabNoSearchResults;

  /// No description provided for @vocabChooseMode.
  ///
  /// In en, this message translates to:
  /// **'How do you want to practice this pack?'**
  String get vocabChooseMode;

  /// No description provided for @vocabModeLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get vocabModeLearn;

  /// No description provided for @vocabModePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get vocabModePractice;

  /// No description provided for @vocabModeLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Explore cards with definition, example and pronunciation'**
  String get vocabModeLearnSub;

  /// No description provided for @vocabModePracticeSub.
  ///
  /// In en, this message translates to:
  /// **'Adaptive mixed session; mistakes go to your FSRS deck'**
  String get vocabModePracticeSub;

  /// No description provided for @interviewPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Structured Interview Packs'**
  String get interviewPacksTitle;

  /// No description provided for @interviewPacksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pedagogical simulations with clear objectives, tips and STAR evaluation'**
  String get interviewPacksSubtitle;

  /// No description provided for @interviewPackStart.
  ///
  /// In en, this message translates to:
  /// **'Start Practice Session'**
  String get interviewPackStart;

  /// No description provided for @interviewPackObjective.
  ///
  /// In en, this message translates to:
  /// **'Session Objective'**
  String get interviewPackObjective;

  /// No description provided for @interviewPackFeedbackFocus.
  ///
  /// In en, this message translates to:
  /// **'Evaluation Focus'**
  String get interviewPackFeedbackFocus;

  /// No description provided for @interviewPackEstimatedTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min estimated'**
  String interviewPackEstimatedTime(Object minutes);

  /// No description provided for @interviewPackSkillsCovered.
  ///
  /// In en, this message translates to:
  /// **'Skills Practiced'**
  String get interviewPackSkillsCovered;

  /// No description provided for @interviewPackTips.
  ///
  /// In en, this message translates to:
  /// **'Tactical Tips'**
  String get interviewPackTips;

  /// No description provided for @interviewPackBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get interviewPackBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
