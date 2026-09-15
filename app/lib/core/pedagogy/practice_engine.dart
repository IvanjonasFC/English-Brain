/// The adaptive practice engine: turns pools of candidate content into a
/// coherent mixed session (70% current objective / 20% recent review /
/// 10% spaced review), with controlled interleaving and reproducible
/// variation via a seed. Pure Dart, no I/O, so it is fully unit-testable.
library;

import 'dart:math';

import 'taxonomy.dart';
import 'contracts.dart';

/// Where a phase of the objective sits, which changes the mix.
enum ObjectivePhase { fresh, learning, mastered }

extension ObjectivePhaseX on ObjectivePhase {
  static ObjectivePhase fromMastery(double mastery, {int attempts = 0}) {
    if (attempts == 0 || mastery < 0.15) return ObjectivePhase.fresh;
    if (mastery >= 0.85) return ObjectivePhase.mastered;
    return ObjectivePhase.learning;
  }
}

/// A single practicable item the engine can schedule.
class CandidateItem {
  final String id;
  final ExerciseType exerciseType;
  final ContentType contentType;
  final String objectiveId;
  final DifficultyBand band;

  /// Non-null marks this as a review (surfaced from FSRS / recent mistakes).
  final ReviewSource? reviewSource;

  const CandidateItem({
    required this.id,
    required this.exerciseType,
    required this.contentType,
    required this.objectiveId,
    required this.band,
    this.reviewSource,
  });

  bool get isReview => reviewSource != null;
}

/// Everything the engine needs to compose one session, provided by the
/// repository layer (which reads drift + content seeds).
class PracticeRequest {
  final String userId;
  final Track track;
  final int minutes;
  final String currentObjectiveId;
  final ObjectivePhase phase;

  /// New content for the current objective, already ordered pedagogically.
  final List<CandidateItem> newItems;

  /// Recently missed / recently seen items (last few sessions).
  final List<CandidateItem> recentReview;

  /// Older, spaced items due per FSRS (+ the occasional useful surprise).
  final List<CandidateItem> spacedReview;

  /// Fix the seed to reproduce a session; leave null for daily variation.
  final int? seed;

  const PracticeRequest({
    required this.userId,
    required this.track,
    required this.minutes,
    required this.currentObjectiveId,
    required this.phase,
    this.newItems = const [],
    this.recentReview = const [],
    this.spacedReview = const [],
    this.seed,
  });
}

/// Mix weights for a phase: (new, recent, spaced). Guided when fresh,
/// progressively more interleaved review as the objective is mastered.
class MixWeights {
  final double newW;
  final double recentW;
  final double spacedW;
  const MixWeights(this.newW, this.recentW, this.spacedW);

  static MixWeights forPhase(ObjectivePhase p) {
    switch (p) {
      case ObjectivePhase.fresh:
        return const MixWeights(0.85, 0.15, 0.0); // guided
      case ObjectivePhase.learning:
        return const MixWeights(0.70, 0.20, 0.10); // the target mix
      case ObjectivePhase.mastered:
        return const MixWeights(0.50, 0.30, 0.20); // interleave harder
    }
  }
}

class SessionPlan {
  final List<CandidateItem> items;
  final int targetCount;
  final MixWeights weights;
  final ObjectivePhase phase;
  final bool endsWithMixedQuiz;

  const SessionPlan({
    required this.items,
    required this.targetCount,
    required this.weights,
    required this.phase,
    required this.endsWithMixedQuiz,
  });

  int get newCount => items.where((i) => !i.isReview).length;
  int get reviewCount => items.where((i) => i.isReview).length;
}

class PracticeEngine {
  const PracticeEngine();

  /// ~1.3 exercises per minute, clamped to a short, focused session.
  static int targetCountForMinutes(int minutes) =>
      (minutes * 1.3).round().clamp(5, 20);

  SessionPlan compose(PracticeRequest req) {
    final rng = Random(req.seed ?? DateTime.now().millisecondsSinceEpoch);
    final total = targetCountForMinutes(req.minutes);
    final w = MixWeights.forPhase(req.phase);

    int newN = (total * w.newW).round();
    int recentN = (total * w.recentW).round();
    int spacedN = total - newN - recentN;
    if (spacedN < 0) spacedN = 0;

    // Draw from each pool (seeded shuffle for variation, cycle if short).
    final newPick = _draw(req.newItems, newN, rng, keepOrder: req.phase == ObjectivePhase.fresh);
    final recentPick = _draw(req.recentReview, recentN, rng);
    final spacedPick = _draw(req.spacedReview, spacedN, rng);

    // Rebalance if a pool was empty: fill the gap from the others so the
    // session still reaches its target length when content exists.
    final reviewPool = [...recentPick, ...spacedPick];
    var deficit = total - (newPick.length + reviewPool.length);
    if (deficit > 0) {
      final extraNew = _draw(
        req.newItems.where((e) => !newPick.contains(e)).toList(), deficit, rng);
      newPick.addAll(extraNew);
      deficit = total - (newPick.length + reviewPool.length);
    }
    if (deficit > 0) {
      final leftoverReview = [...req.recentReview, ...req.spacedReview]
          .where((e) => !reviewPool.contains(e))
          .toList();
      reviewPool.addAll(_draw(leftoverReview, deficit, rng));
    }

    final ordered = req.phase == ObjectivePhase.fresh
        ? _guidedOrder(newPick, reviewPool)
        : _interleave(newPick, reviewPool, rng);

    return SessionPlan(
      items: ordered,
      targetCount: total,
      weights: w,
      phase: req.phase,
      endsWithMixedQuiz: ordered.length >= 4,
    );
  }

  /// Draw up to [n] items. Seeded shuffle unless [keepOrder] (guided phase).
  List<CandidateItem> _draw(List<CandidateItem> pool, int n, Random rng,
      {bool keepOrder = false}) {
    if (n <= 0 || pool.isEmpty) return [];
    final list = List<CandidateItem>.from(pool);
    if (!keepOrder) list.shuffle(rng);
    if (list.length <= n) return list;
    return list.sublist(0, n);
  }

  /// Guided: new items first in their pedagogical order, a little review at the end.
  List<CandidateItem> _guidedOrder(
      List<CandidateItem> newItems, List<CandidateItem> review) {
    return [...newItems, ...review];
  }

  /// Controlled interleaving: spread review items at regular intervals through
  /// the new items instead of clustering — related, not random.
  List<CandidateItem> _interleave(
      List<CandidateItem> newItems, List<CandidateItem> review, Random rng) {
    if (review.isEmpty) return List.of(newItems);
    if (newItems.isEmpty) return List.of(review);
    final out = <CandidateItem>[];
    final step = (newItems.length / (review.length + 1)).ceil().clamp(1, 999);
    int ri = 0;
    for (var i = 0; i < newItems.length; i++) {
      out.add(newItems[i]);
      if ((i + 1) % step == 0 && ri < review.length) {
        out.add(review[ri++]);
      }
    }
    while (ri < review.length) {
      out.add(review[ri++]);
    }
    return out;
  }
}
