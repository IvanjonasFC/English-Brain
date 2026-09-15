import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/pedagogy/taxonomy.dart';
import 'package:app/core/pedagogy/contracts.dart';
import 'package:app/core/pedagogy/practice_engine.dart';

CandidateItem _newItem(int i) => CandidateItem(
      id: 'new_$i',
      exerciseType: ExerciseType.recognition,
      contentType: ContentType.lesson,
      objectiveId: 'obj_current',
      band: DifficultyBand.b1b2,
    );

CandidateItem _reviewItem(int i, {ReviewSource src = ReviewSource.vocabulary}) =>
    CandidateItem(
      id: 'rev_$i',
      exerciseType: ExerciseType.fillBlank,
      contentType: ContentType.review,
      objectiveId: 'obj_$i',
      band: DifficultyBand.b1b2,
      reviewSource: src,
    );

void main() {
  const engine = PracticeEngine();

  PracticeRequest req(ObjectivePhase phase, {int? seed, int minutes = 10}) =>
      PracticeRequest(
        userId: 'user-ivan',
        track: Track.vocabulary,
        minutes: minutes,
        currentObjectiveId: 'obj_current',
        phase: phase,
        newItems: List.generate(30, _newItem),
        recentReview: List.generate(15, (i) => _reviewItem(i, src: ReviewSource.interviewMistake)),
        spacedReview: List.generate(15, (i) => _reviewItem(100 + i)),
        seed: seed,
      );

  test('target count scales with minutes and is clamped', () {
    expect(PracticeEngine.targetCountForMinutes(5), inInclusiveRange(5, 20));
    expect(PracticeEngine.targetCountForMinutes(10), 13);
    expect(PracticeEngine.targetCountForMinutes(60), 20); // clamped
    expect(PracticeEngine.targetCountForMinutes(1), 5); // clamped floor
  });

  test('learning phase ~ 70/20/10 mix', () {
    final plan = engine.compose(req(ObjectivePhase.learning, seed: 42));
    expect(plan.items.length, plan.targetCount);
    final total = plan.targetCount;
    // 70% new
    expect(plan.newCount, closeTo(total * 0.7, 2));
    // 30% review (recent + spaced)
    expect(plan.reviewCount, closeTo(total * 0.3, 2));
  });

  test('fresh phase is guided: mostly new, review only at the end', () {
    final plan = engine.compose(req(ObjectivePhase.fresh, seed: 7));
    expect(plan.newCount, greaterThan(plan.reviewCount));
    // guided ordering: no review appears before the last new item
    final lastNew = plan.items.lastIndexWhere((i) => !i.isReview);
    final firstReview = plan.items.indexWhere((i) => i.isReview);
    if (firstReview != -1) {
      expect(firstReview, greaterThan(lastNew - 1));
    }
  });

  test('mastered phase interleaves more review than learning', () {
    final learning = engine.compose(req(ObjectivePhase.learning, seed: 1));
    final mastered = engine.compose(req(ObjectivePhase.mastered, seed: 1));
    expect(mastered.reviewCount, greaterThanOrEqualTo(learning.reviewCount));
  });

  test('deterministic with same seed, varies with different seed', () {
    final a = engine.compose(req(ObjectivePhase.learning, seed: 99));
    final b = engine.compose(req(ObjectivePhase.learning, seed: 99));
    final c = engine.compose(req(ObjectivePhase.learning, seed: 123));
    expect(a.items.map((e) => e.id).toList(), b.items.map((e) => e.id).toList());
    // extremely unlikely to be identical order with a different seed
    expect(a.items.map((e) => e.id).toList() ==
        c.items.map((e) => e.id).toList(), isFalse);
  });

  test('interleaving does not cluster all review at the front', () {
    final plan = engine.compose(req(ObjectivePhase.learning, seed: 5));
    final firstHalf = plan.items.take(plan.items.length ~/ 2);
    final reviewInFirstHalf = firstHalf.where((i) => i.isReview).length;
    // review should be spread, not dumped in the first half
    expect(reviewInFirstHalf, lessThanOrEqualTo((plan.reviewCount / 2).ceil() + 1));
  });

  test('handles empty review pools without crashing and still fills session', () {
    final plan = engine.compose(PracticeRequest(
      userId: 'u',
      track: Track.grammar,
      minutes: 10,
      currentObjectiveId: 'obj_current',
      phase: ObjectivePhase.learning,
      newItems: List.generate(30, _newItem),
      seed: 3,
    ));
    expect(plan.items.length, plan.targetCount);
    expect(plan.reviewCount, 0);
  });

  test('phase derivation from mastery', () {
    expect(ObjectivePhaseX.fromMastery(0.0, attempts: 0), ObjectivePhase.fresh);
    expect(ObjectivePhaseX.fromMastery(0.5, attempts: 3), ObjectivePhase.learning);
    expect(ObjectivePhaseX.fromMastery(0.9, attempts: 8), ObjectivePhase.mastered);
  });
}
