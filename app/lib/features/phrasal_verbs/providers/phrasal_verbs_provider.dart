import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/tab_theme.dart';
import '../../vocabulary/vocabulary_repository.dart';
import '../models/phrasal_verb.dart';
import '../data/phrasal_verbs_data.dart';

class PhrasalVerbsStats {
  final int totalVerbs;
  final int masteredVerbs;
  final int interviewReadyVerbs;
  final int scenarioTotal;
  final int scenarioMastered;
  final int scenarioInterviewReady;
  final double meaningScore;
  final double contextScore;
  final double listeningScore;
  final double wordOrderScore;
  final double pronunciationScore;
  final double speakingScore;

  const PhrasalVerbsStats({
    this.totalVerbs = 0,
    this.masteredVerbs = 0,
    this.interviewReadyVerbs = 0,
    this.scenarioTotal = 0,
    this.scenarioMastered = 0,
    this.scenarioInterviewReady = 0,
    this.meaningScore = 0.0,
    this.contextScore = 0.0,
    this.listeningScore = 0.0,
    this.wordOrderScore = 0.0,
    this.pronunciationScore = 0.0,
    this.speakingScore = 0.0,
  });
}

class PhrasalVerbsLabState {
  final PhrasalScenario activeScenario; // Eje principal de aprendizaje
  final String activeCefrRoute; // 'A1-A2', 'A2-B1', 'B1-B2', 'B2-C1', 'C1+'
  final String searchQuery;
  final String selectedParticle; // 'all' or PhrasalParticle.id (mapa secundario)
  final String statusFilter; // 'all', 'mastered', 'pending', 'favorites', 'mistakes'
  final Set<String> favoriteIds;
  final Map<String, PhrasalVerbMetrics> metricsByVerb;

  const PhrasalVerbsLabState({
    this.activeScenario = PhrasalScenario.dailySync,
    this.activeCefrRoute = 'B1-B2',
    this.searchQuery = '',
    this.selectedParticle = 'all',
    this.statusFilter = 'all',
    this.favoriteIds = const {},
    this.metricsByVerb = const {},
  });

  PhrasalVerbsLabState copyWith({
    PhrasalScenario? activeScenario,
    String? activeCefrRoute,
    String? searchQuery,
    String? selectedParticle,
    String? statusFilter,
    Set<String>? favoriteIds,
    Map<String, PhrasalVerbMetrics>? metricsByVerb,
  }) {
    return PhrasalVerbsLabState(
      activeScenario: activeScenario ?? this.activeScenario,
      activeCefrRoute: activeCefrRoute ?? this.activeCefrRoute,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedParticle: selectedParticle ?? this.selectedParticle,
      statusFilter: statusFilter ?? this.statusFilter,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      metricsByVerb: metricsByVerb ?? this.metricsByVerb,
    );
  }
}

class PhrasalVerbsLabNotifier extends StateNotifier<PhrasalVerbsLabState> {
  final Ref ref;

  PhrasalVerbsLabNotifier(this.ref) : super(const PhrasalVerbsLabState()) {
    _loadPersistedState();
  }

  String get _userId {
    final raw = ref.read(activeUserIdProvider);
    return raw.trim().isNotEmpty ? raw.trim() : 'default_user';
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final favKey = 'phrasal_favs_$_userId';
    final metricsKey = 'phrasal_metrics_$_userId';
    final routeKey = 'phrasal_route_$_userId';
    final scenarioKey = 'phrasal_scenario_$_userId';

    final favRaw = prefs.getString(favKey);
    final metricsRaw = prefs.getString(metricsKey);
    final profile = ref.read(activeProfileProvider).valueOrNull;
    final defaultPill = TabTheme.defaultPillForUserLevel(profile?.targetLevel);
    final fallbackRoute = defaultPill == 'C1' ? 'C1+' : defaultPill;
    final savedRoute = prefs.getString(routeKey) ?? fallbackRoute;

    String defaultScenario;
    if (defaultPill == 'A1-A2') {
      defaultScenario = 'daily_sync';
    } else if (defaultPill == 'B1-B2') {
      defaultScenario = 'debugging';
    } else if (defaultPill == 'B2-C1') {
      defaultScenario = 'change_delivery';
    } else {
      defaultScenario = 'senior_decision';
    }
    final savedScenarioId = prefs.getString(scenarioKey) ?? defaultScenario;

    Set<String> favs = {};
    Map<String, PhrasalVerbMetrics> metrics = {};

    if (favRaw != null) {
      try {
        final list = (jsonDecode(favRaw) as List).cast<String>();
        favs = list.toSet();
      } catch (_) {}
    }

    if (metricsRaw != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(metricsRaw);
        decoded.forEach((key, value) {
          metrics[key] = PhrasalVerbMetrics.fromJson(value as Map<String, dynamic>);
        });
      } catch (_) {}
    }

    state = state.copyWith(
      activeScenario: PhrasalScenario.fromId(savedScenarioId),
      activeCefrRoute: savedRoute,
      favoriteIds: favs,
      metricsByVerb: metrics,
    );
  }

  void setActiveScenario(PhrasalScenario scenario) async {
    state = state.copyWith(activeScenario: scenario);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phrasal_scenario_$_userId', scenario.id);
  }

  void setActiveCefrRoute(String route) async {
    state = state.copyWith(activeCefrRoute: route);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phrasal_route_$_userId', route);
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setSelectedParticle(String p) {
    state = state.copyWith(selectedParticle: p);
  }

  void setStatusFilter(String s) {
    state = state.copyWith(statusFilter: s);
  }

  Future<void> toggleFavorite(String verbId) async {
    final updated = Set<String>.from(state.favoriteIds);
    if (updated.contains(verbId)) {
      updated.remove(verbId);
    } else {
      updated.add(verbId);
    }
    state = state.copyWith(favoriteIds: updated);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phrasal_favs_$_userId', jsonEncode(updated.toList()));
  }

  Future<void> recordAttempt({
    required String verbId,
    required String exerciseType, // 'meaning_recall', 'word_order', 'listening', 'sentence_usage', 'pronunciation', 'speaking'
    required bool isSuccess,
    double? pronunciationScore,
    String? expectedForm,
    String? actualForm,
    String? contextSentence,
  }) async {
    final existing = state.metricsByVerb[verbId] ?? const PhrasalVerbMetrics();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final updatedDates = Set<String>.from(existing.recallDates);
    if (isSuccess && (exerciseType == 'meaning_recall' || exerciseType == 'sentence_usage' || exerciseType == 'word_order')) {
      updatedDates.add(today);
    }

    int meaningRecallCorrect = existing.meaningRecallCorrect;
    int meaningRecallTotal = existing.meaningRecallTotal;
    int listeningCorrect = existing.listeningCorrect;
    int listeningTotal = existing.listeningTotal;
    int wordOrderCorrect = existing.wordOrderCorrect;
    int wordOrderTotal = existing.wordOrderTotal;
    int sentenceUsageCorrect = existing.sentenceUsageCorrect;
    int sentenceUsageTotal = existing.sentenceUsageTotal;
    int pronAttempts = existing.pronunciationAttempts;
    double pronAvg = existing.pronunciationAvgScore;
    int speakingCount = existing.speakingCount;

    if (exerciseType == 'meaning_recall') {
      meaningRecallTotal++;
      if (isSuccess) meaningRecallCorrect++;
    } else if (exerciseType == 'word_order') {
      wordOrderTotal++;
      if (isSuccess) wordOrderCorrect++;
    } else if (exerciseType == 'listening') {
      listeningTotal++;
      if (isSuccess) listeningCorrect++;
    } else if (exerciseType == 'sentence_usage') {
      sentenceUsageTotal++;
      if (isSuccess) sentenceUsageCorrect++;
    } else if (exerciseType == 'pronunciation') {
      pronAttempts++;
      final score = pronunciationScore ?? 85.0;
      pronAvg = pronAttempts == 1 ? score : ((pronAvg * (pronAttempts - 1)) + score) / pronAttempts;
    } else if (exerciseType == 'speaking') {
      if (isSuccess) speakingCount++;
    }

    final updatedMetrics = PhrasalVerbMetrics(
      meaningRecallCorrect: meaningRecallCorrect,
      meaningRecallTotal: meaningRecallTotal,
      listeningCorrect: listeningCorrect,
      listeningTotal: listeningTotal,
      wordOrderCorrect: wordOrderCorrect,
      wordOrderTotal: wordOrderTotal,
      sentenceUsageCorrect: sentenceUsageCorrect,
      sentenceUsageTotal: sentenceUsageTotal,
      pronunciationAttempts: pronAttempts,
      pronunciationAvgScore: pronAvg,
      speakingCount: speakingCount,
      recallDates: updatedDates,
      lastMistakeType: isSuccess ? null : exerciseType,
      lastPracticedAt: DateTime.now(),
    );

    final map = Map<String, PhrasalVerbMetrics>.from(state.metricsByVerb);
    map[verbId] = updatedMetrics;
    state = state.copyWith(metricsByVerb: map);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final encoded = map.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString('phrasal_metrics_$_userId', jsonEncode(encoded));

    // Ingest mistake into Drift SQLite FSRS Cards
    if (!isSuccess) {
      await _ingestFsrsMistake(
        verbId: verbId,
        exerciseType: exerciseType,
        expectedForm: expectedForm ?? '',
        actualForm: actualForm ?? '',
        contextSentence: contextSentence ?? '',
      );
    }
  }

  Future<void> _ingestFsrsMistake({
    required String verbId,
    required String exerciseType,
    required String expectedForm,
    required String actualForm,
    required String contextSentence,
  }) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final verb = PhrasalVerbsData.verbs.firstWhere((v) => v.id == verbId);
      final cardId = (verbId.hashCode + exerciseType.hashCode).abs();

      // Granular FSRS item types: 'word_order', 'contextual_meaning', 'listening', 'pronunciation'
      String fsrsItemType = 'contextual_meaning';
      if (exerciseType == 'word_order') {
        fsrsItemType = 'word_order';
      } else if (exerciseType == 'listening') {
        fsrsItemType = 'listening';
      } else if (exerciseType == 'pronunciation') {
        fsrsItemType = 'pronunciation';
      }

      final front = contextSentence.isNotEmpty
          ? contextSentence.replaceAll(expectedForm, '____')
          : '${verb.fullPhrase} (${verb.spanish}) -> ${verb.idiomaticMeaning}';
      
      final formalAltPreview = verb.formalAlternatives.isNotEmpty 
          ? verb.formalAlternatives.map((a) => '${a.term} (${a.whenToUse})').join(' | ') 
          : '';

      final back = 'Correcto: $expectedForm\nTu intento: $actualForm\nPatron: ${verb.correctPattern}\nAlternativas de registro: $formalAltPreview';

      final existing = await (db.select(db.cardsLocal)..where((t) => t.id.equals(cardId))).getSingleOrNull();

      if (existing == null) {
        await db.into(db.cardsLocal).insert(
              CardsLocalCompanion(
                id: drift.Value(cardId),
                front: drift.Value(front),
                back: drift.Value(back),
                stability: const drift.Value(0.4),
                difficulty: const drift.Value(6.0),
                elapsedDays: const drift.Value(0),
                scheduledDays: const drift.Value(1),
                reps: const drift.Value(1),
                lapses: const drift.Value(1),
                state: const drift.Value(1), // Learning
                dueDate: drift.Value(DateTime.now().add(const Duration(hours: 12))),
                updatedAt: drift.Value(DateTime.now()),
                sourceType: const drift.Value('phrasal_verbs'),
                itemType: drift.Value(fsrsItemType),
                unitOrPackId: drift.Value(verb.scenario.id),
                skill: drift.Value(exerciseType == 'listening' ? 'listening' : 'vocabulary'),
                userId: drift.Value(_userId),
              ),
            );
      } else {
        await (db.update(db.cardsLocal)..where((t) => t.id.equals(cardId))).write(
          CardsLocalCompanion(
            lapses: drift.Value(existing.lapses + 1),
            difficulty: drift.Value((existing.difficulty + 0.5).clamp(1.0, 10.0)),
            dueDate: drift.Value(DateTime.now().add(const Duration(hours: 6))),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }
    } catch (_) {}
  }
}

final phrasalVerbsLabNotifierProvider = StateNotifierProvider<PhrasalVerbsLabNotifier, PhrasalVerbsLabState>((ref) {
  return PhrasalVerbsLabNotifier(ref);
});

final allPhrasalVerbsProvider = Provider<List<PhrasalVerb>>((ref) {
  return PhrasalVerbsData.verbs;
});

final activeScenarioPhrasalVerbsProvider = Provider<List<PhrasalVerb>>((ref) {
  final state = ref.watch(phrasalVerbsLabNotifierProvider);
  return PhrasalVerbsData.getVerbsByScenario(state.activeScenario);
});

final activeRoutePhrasalVerbsProvider = Provider<List<PhrasalVerb>>((ref) {
  final state = ref.watch(phrasalVerbsLabNotifierProvider);
  return PhrasalVerbsData.getVerbsByRoute(state.activeCefrRoute);
});

final phrasalVerbsStatsProvider = Provider<PhrasalVerbsStats>((ref) {
  final all = ref.watch(allPhrasalVerbsProvider);
  final state = ref.watch(phrasalVerbsLabNotifierProvider);
  final scenarioVerbs = PhrasalVerbsData.getVerbsByScenario(state.activeScenario);

  int masteredCount = 0;
  int interviewReadyCount = 0;
  double totalMeaning = 0.0;
  double totalContext = 0.0;
  double totalListening = 0.0;
  double totalWordOrder = 0.0;
  double totalPron = 0.0;
  double totalSpeaking = 0.0;

  for (final v in all) {
    final m = state.metricsByVerb[v.id];
    if (m != null) {
      if (m.isMastered) masteredCount++;
      if (m.isInterviewReady) interviewReadyCount++;
      totalMeaning += m.meaningScore;
      totalContext += m.sentenceScore;
      totalListening += m.listeningScore;
      totalWordOrder += m.wordOrderScore;
      totalPron += m.pronunciationScore;
      totalSpeaking += m.speakingScore;
    }
  }

  int scenarioMastered = 0;
  int scenarioInterviewReady = 0;
  for (final v in scenarioVerbs) {
    final m = state.metricsByVerb[v.id];
    if (m != null) {
      if (m.isMastered) scenarioMastered++;
      if (m.isInterviewReady) scenarioInterviewReady++;
    }
  }

  final len = all.isEmpty ? 1 : all.length;

  return PhrasalVerbsStats(
    totalVerbs: all.length,
    masteredVerbs: masteredCount,
    interviewReadyVerbs: interviewReadyCount,
    scenarioTotal: scenarioVerbs.length,
    scenarioMastered: scenarioMastered,
    scenarioInterviewReady: scenarioInterviewReady,
    meaningScore: totalMeaning / len,
    contextScore: totalContext / len,
    listeningScore: totalListening / len,
    wordOrderScore: totalWordOrder / len,
    pronunciationScore: totalPron / len,
    speakingScore: totalSpeaking / len,
  );
});

final filteredPhrasalVerbsProvider = Provider<List<PhrasalVerb>>((ref) {
  final all = ref.watch(allPhrasalVerbsProvider);
  final filter = ref.watch(phrasalVerbsLabNotifierProvider);

  return all.where((v) {
    // 1. Search Query
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.toLowerCase().trim();
      final matchesText = v.fullPhrase.toLowerCase().contains(q) ||
          v.spanish.toLowerCase().contains(q) ||
          v.idiomaticMeaning.toLowerCase().contains(q) ||
          v.formalAlternatives.any((a) => a.term.toLowerCase().contains(q));
      if (!matchesText) return false;
    }

    // 2. Particle Filter (Secondary Map)
    if (filter.selectedParticle != 'all' && v.particle.id != filter.selectedParticle) {
      return false;
    }

    // 2.5 CEFR Route Filter
    if (filter.activeCefrRoute != 'all') {
      if (!Cefr.matchesPill(v.cefrLevel, filter.activeCefrRoute)) {
        return false;
      }
    }

    // 3. Status Filter
    final metrics = filter.metricsByVerb[v.id];
    final isMastered = metrics?.isMastered ?? false;
    final isFav = filter.favoriteIds.contains(v.id);
    final hasMistakes = (metrics?.lastMistakeType != null);

    if (filter.statusFilter == 'mastered' && !isMastered) return false;
    if (filter.statusFilter == 'pending' && isMastered) return false;
    if (filter.statusFilter == 'favorites' && !isFav) return false;
    if (filter.statusFilter == 'mistakes' && !hasMistakes) return false;

    return true;
  }).toList();
});

