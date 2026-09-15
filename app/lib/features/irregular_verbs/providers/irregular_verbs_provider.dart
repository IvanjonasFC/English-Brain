import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/providers/app_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/tab_theme.dart';
import '../models/irregular_verb.dart';
import '../data/irregular_verbs_data.dart';

class VerbsLabState {
  final String activeCefrRoute; // 'A1-A2', 'A2-B1', 'B1-B2', 'B2-C1', 'C1+'
  final String searchQuery;
  final String selectedGroup; // 'all' or IrregularVerbGroup.id
  final String statusFilter; // 'all', 'mastered', 'pending', 'favorites', 'mistakes'
  final Set<String> favoriteIds;
  final Map<String, VerbProgressMetrics> metricsByVerb;

  const VerbsLabState({
    this.activeCefrRoute = 'B1-B2',
    this.searchQuery = '',
    this.selectedGroup = 'all',
    this.statusFilter = 'all',
    this.favoriteIds = const {},
    this.metricsByVerb = const {},
  });

  VerbsLabState copyWith({
    String? activeCefrRoute,
    String? searchQuery,
    String? selectedGroup,
    String? statusFilter,
    Set<String>? favoriteIds,
    Map<String, VerbProgressMetrics>? metricsByVerb,
  }) {
    return VerbsLabState(
      activeCefrRoute: activeCefrRoute ?? this.activeCefrRoute,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      statusFilter: statusFilter ?? this.statusFilter,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      metricsByVerb: metricsByVerb ?? this.metricsByVerb,
    );
  }
}

class VerbsLabNotifier extends StateNotifier<VerbsLabState> {
  final Ref ref;

  VerbsLabNotifier(this.ref) : super(const VerbsLabState()) {
    _loadPersistedState();
  }

  String get _userId {
    final raw = ref.read(activeUserIdProvider);
    return raw.trim().isNotEmpty ? raw.trim() : 'default_user';
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final favKey = 'irregular_favs_$_userId';
    final metricsKey = 'irregular_metrics_$_userId';
    final routeKey = 'irregular_route_$_userId';

    final favRaw = prefs.getString(favKey);
    final metricsRaw = prefs.getString(metricsKey);
    final profile = ref.read(activeProfileProvider).valueOrNull;
    final defaultPill = TabTheme.defaultPillForUserLevel(profile?.targetLevel);
    final fallbackRoute = defaultPill == 'C1' ? 'C1+' : defaultPill;
    final savedRoute = prefs.getString(routeKey) ?? fallbackRoute;

    Set<String> favs = {};
    Map<String, VerbProgressMetrics> metrics = {};

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
          metrics[key] = VerbProgressMetrics.fromJson(value as Map<String, dynamic>);
        });
      } catch (_) {}
    }

    state = state.copyWith(
      activeCefrRoute: savedRoute,
      favoriteIds: favs,
      metricsByVerb: metrics,
    );
  }

  void setActiveCefrRoute(String route) async {
    state = state.copyWith(activeCefrRoute: route);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('irregular_route_$_userId', route);
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }

  void setSelectedGroup(String g) {
    state = state.copyWith(selectedGroup: g);
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
    await prefs.setString('irregular_favs_$_userId', jsonEncode(updated.toList()));
  }

  /// Records an exercise attempt, calculates new mastery, and pushes mistakes into FSRS
  Future<void> recordAttempt({
    required String verbId,
    required String exerciseType, // 'form_recall', 'listening', 'sentence_usage', 'pronunciation', 'speaking'
    required bool isSuccess,
    double? pronunciationScore,
    String? expectedForm,
    String? actualForm,
    String? contextSentence,
  }) async {
    final existing = state.metricsByVerb[verbId] ?? const VerbProgressMetrics();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final updatedDates = Set<String>.from(existing.recallDates);
    if (isSuccess && (exerciseType == 'form_recall' || exerciseType == 'sentence_usage')) {
      updatedDates.add(today);
    }

    int formRecallCorrect = existing.formRecallCorrect;
    int formRecallTotal = existing.formRecallTotal;
    int listeningCorrect = existing.listeningCorrect;
    int listeningTotal = existing.listeningTotal;
    int sentenceUsageCorrect = existing.sentenceUsageCorrect;
    int sentenceUsageTotal = existing.sentenceUsageTotal;
    int pronAttempts = existing.pronunciationAttempts;
    double pronAvg = existing.pronunciationAvgScore;
    int speakingCount = existing.speakingCount;

    if (exerciseType == 'form_recall') {
      formRecallTotal++;
      if (isSuccess) formRecallCorrect++;
    } else if (exerciseType == 'listening') {
      listeningTotal++;
      if (isSuccess) listeningCorrect++;
    } else if (exerciseType == 'sentence_usage') {
      sentenceUsageTotal++;
      if (isSuccess) sentenceUsageCorrect++;
    } else if (exerciseType == 'pronunciation') {
      pronAttempts++;
      final score = pronunciationScore ?? 80.0;
      pronAvg = pronAttempts == 1 ? score : ((pronAvg * (pronAttempts - 1)) + score) / pronAttempts;
    } else if (exerciseType == 'speaking') {
      if (isSuccess) speakingCount++;
    }

    final updatedMetrics = VerbProgressMetrics(
      formRecallCorrect: formRecallCorrect,
      formRecallTotal: formRecallTotal,
      listeningCorrect: listeningCorrect,
      listeningTotal: listeningTotal,
      sentenceUsageCorrect: sentenceUsageCorrect,
      sentenceUsageTotal: sentenceUsageTotal,
      pronunciationAttempts: pronAttempts,
      pronunciationAvgScore: pronAvg,
      speakingCount: speakingCount,
      recallDates: updatedDates,
      lastMistakeType: isSuccess ? null : exerciseType,
      lastPracticedAt: DateTime.now(),
    );

    final map = Map<String, VerbProgressMetrics>.from(state.metricsByVerb);
    map[verbId] = updatedMetrics;
    state = state.copyWith(metricsByVerb: map);

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final encoded = map.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString('irregular_metrics_$_userId', jsonEncode(encoded));

    // Ingest mistake to FSRS Cards table if failed
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
      final verb = IrregularVerbsData.verbs.firstWhere((v) => v.id == verbId);
      final cardId = (verbId.hashCode + exerciseType.hashCode).abs();

      final front = contextSentence.isNotEmpty
          ? contextSentence.replaceAll(expectedForm, '____')
          : '${verb.v1} (${verb.spanish}) → ${exerciseType == 'form_recall' ? 'Pasado Simple / Participio Pasado' : 'Forma correcta'}';
      final back = 'Correcto: $expectedForm\nTu intento: $actualForm\nSecuencia: ${verb.sequenceText}';

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
                sourceType: const drift.Value('irregular_verbs'),
                itemType: drift.Value(exerciseType),
                unitOrPackId: drift.Value(verb.group.id),
                skill: drift.Value(exerciseType == 'listening' ? 'listening' : 'grammar'),
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

final verbsLabNotifierProvider = StateNotifierProvider<VerbsLabNotifier, VerbsLabState>((ref) {
  return VerbsLabNotifier(ref);
});

final allIrregularVerbsProvider = Provider<List<IrregularVerb>>((ref) {
  return IrregularVerbsData.verbs;
});

final activeRouteVerbsProvider = Provider<List<IrregularVerb>>((ref) {
  final state = ref.watch(verbsLabNotifierProvider);
  return IrregularVerbsData.getVerbsByRoute(state.activeCefrRoute);
});

final filteredIrregularVerbsProvider = Provider<List<IrregularVerb>>((ref) {
  final all = ref.watch(allIrregularVerbsProvider);
  final filter = ref.watch(verbsLabNotifierProvider);

  return all.where((v) {
    // 1. Search Query
    if (filter.searchQuery.trim().isNotEmpty) {
      final q = filter.searchQuery.trim().toLowerCase();
      final matchV1 = v.v1.toLowerCase().contains(q);
      final matchV2 = v.v2.toLowerCase().contains(q);
      final matchV3 = v.v3.toLowerCase().contains(q);
      final matchSp = v.spanish.toLowerCase().contains(q);
      if (!matchV1 && !matchV2 && !matchV3 && !matchSp) {
        return false;
      }
    }

    // 2. CEFR Route Filter
    if (filter.activeCefrRoute != 'all') {
      final routeVerbs = IrregularVerbsData.getVerbsByRoute(filter.activeCefrRoute);
      if (!routeVerbs.any((rv) => rv.id == v.id)) return false;
    }

    // 3. Pattern Group
    if (filter.selectedGroup != 'all') {
      if (v.group.id != filter.selectedGroup) return false;
    }

    // 3. Status Filter
    final metrics = filter.metricsByVerb[v.id] ?? const VerbProgressMetrics();
    if (filter.statusFilter == 'favorites') {
      if (!filter.favoriteIds.contains(v.id)) return false;
    } else if (filter.statusFilter == 'mastered') {
      if (!metrics.isMastered) return false;
    } else if (filter.statusFilter == 'pending') {
      if (metrics.isMastered) return false;
    } else if (filter.statusFilter == 'mistakes') {
      if (metrics.lastMistakeType == null) return false;
    }

    return true;
  }).toList();
});

class VerbsLabStats {
  final int totalVerbs;
  final int masteredCount;
  final int interviewReadyCount;
  final int routeTotal;
  final int routeMastered;
  final int routeInterviewReady;
  final double overallProgress;
  final double routeProgress;
  final double formsScore;
  final double listeningScore;
  final double speakingScore;

  const VerbsLabStats({
    required this.totalVerbs,
    required this.masteredCount,
    required this.interviewReadyCount,
    required this.routeTotal,
    required this.routeMastered,
    required this.routeInterviewReady,
    required this.overallProgress,
    required this.routeProgress,
    required this.formsScore,
    required this.listeningScore,
    required this.speakingScore,
  });
}

final irregularVerbsStatsProvider = Provider<VerbsLabStats>((ref) {
  final all = ref.watch(allIrregularVerbsProvider);
  final state = ref.watch(verbsLabNotifierProvider);
  final routeVerbs = ref.watch(activeRouteVerbsProvider);

  int mastered = 0;
  int interviewReady = 0;
  for (final v in all) {
    final m = state.metricsByVerb[v.id];
    if (m?.isMastered == true) mastered++;
    if (m?.isInterviewReady == true) interviewReady++;
  }

  int routeMastered = 0;
  int routeInterviewReady = 0;
  double sumForms = 0;
  double sumListening = 0;
  int speakingCount = 0;

  for (final v in routeVerbs) {
    final m = state.metricsByVerb[v.id];
    if (m?.isMastered == true) routeMastered++;
    if (m?.isInterviewReady == true) routeInterviewReady++;
    if (m != null) {
      sumForms += m.formRecallScore;
      sumListening += m.listeningScore;
      if (m.speakingCount >= 1) speakingCount++;
    }
  }

  final total = all.length;
  final routeTotal = routeVerbs.length;

  final avgForms = routeTotal > 0 ? (sumForms / routeTotal).clamp(0.0, 1.0) : 0.0;
  final avgListening = routeTotal > 0 ? (sumListening / routeTotal).clamp(0.0, 1.0) : 0.0;
  final avgSpeaking = routeTotal > 0 ? (speakingCount / routeTotal).clamp(0.0, 1.0) : 0.0;

  return VerbsLabStats(
    totalVerbs: total,
    masteredCount: mastered,
    interviewReadyCount: interviewReady,
    routeTotal: routeTotal,
    routeMastered: routeMastered,
    routeInterviewReady: routeInterviewReady,
    overallProgress: total > 0 ? (mastered / total).clamp(0.0, 1.0) : 0.0,
    routeProgress: routeTotal > 0 ? (routeMastered / routeTotal).clamp(0.0, 1.0) : 0.0,
    formsScore: avgForms,
    listeningScore: avgListening,
    speakingScore: avgSpeaking,
  );
});
