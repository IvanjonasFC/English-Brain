import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:app/core/database/app_database.dart';
import 'package:app/core/pedagogy/taxonomy.dart';
import 'package:app/core/pedagogy/contracts.dart';
import 'package:app/core/pedagogy/practice_engine.dart';
import 'package:app/core/pedagogy/practice_service.dart';

AttemptResult _attempt(double score) => AttemptResult(
      userId: 'user-ivan',
      objectiveId: 'describe_a_bug',
      track: Track.speaking,
      scenario: LearningScenario.debugging,
      band: DifficultyBand.b2c1,
      score: score,
      durationSeconds: 120,
    );

CandidateItem _new(int i) => CandidateItem(
      id: 'new_$i',
      exerciseType: ExerciseType.speakShort,
      contentType: ContentType.lesson,
      objectiveId: 'describe_a_bug',
      band: DifficultyBand.b2c1,
    );

CandidateItem _review(int i) => CandidateItem(
      id: 'rev_$i',
      exerciseType: ExerciseType.chooseBestTerm,
      contentType: ContentType.review,
      // Reviews come from OTHER packs/objectives — cross-pack surfacing.
      objectiveId: 'obj_other_$i',
      band: DifficultyBand.b2c1,
      reviewSource: ReviewSource.vocabulary,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PracticeService service;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    service = PracticeService(db);
    await db.into(db.userProfilesLocal).insert(
          UserProfilesLocalCompanion.insert(
            id: 'user-ivan',
            displayName: 'Iván',
            createdAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('an objective with no stored progress is fresh', () async {
    final phase = await service.phaseFor('user-ivan', 'describe_a_bug');
    expect(phase, ObjectivePhase.fresh);
  });

  test('first attempt seeds mastery = score, and moves the objective out of fresh',
      () async {
    final imp = await service.recordAttempt(_attempt(0.8));

    expect(imp.previousMastery, 0.0);
    expect(imp.newMastery, closeTo(0.8, 1e-9));
    expect(imp.attempts, 1);
    expect(imp.streak, 1, reason: 'score >= 0.7 keeps a streak alive');
    expect(imp.xpGained, (0.8 * 40).round() + 10); // 42
    expect(imp.hasImproved, isTrue);

    expect(await service.phaseFor('user-ivan', 'describe_a_bug'), ObjectivePhase.learning);
  });

  test('mastery blends with an EMA and promotes to mastered across good attempts',
      () async {
    await service.recordAttempt(_attempt(0.8)); // 0.80
    final second = await service.recordAttempt(_attempt(0.9)); // 0.8*0.6 + 0.9*0.4

    expect(second.previousMastery, closeTo(0.8, 1e-9));
    expect(second.newMastery, closeTo(0.84, 1e-9));
    expect(second.attempts, 2);
    expect(second.streak, 2);
    expect(await service.phaseFor('user-ivan', 'describe_a_bug'), ObjectivePhase.learning);

    final third = await service.recordAttempt(_attempt(0.95)); // -> 0.884
    expect(third.newMastery, closeTo(0.884, 1e-9));
    expect(await service.phaseFor('user-ivan', 'describe_a_bug'), ObjectivePhase.mastered);
  });

  test('a weak attempt resets the streak but keeps blended mastery', () async {
    await service.recordAttempt(_attempt(0.8)); // streak 1
    final weak = await service.recordAttempt(_attempt(0.5)); // < 0.7

    expect(weak.streak, 0, reason: 'a sub-0.7 score breaks the streak');
    expect(weak.newMastery, closeTo(0.8 * 0.6 + 0.5 * 0.4, 1e-9)); // 0.68
    expect(weak.attempts, 2);
  });

  test('the service drives PracticeEngine with the stored phase to compose a session',
      () async {
    // One learning-level attempt so the stored phase is `learning`.
    await service.recordAttempt(_attempt(0.5));
    final phase = await service.phaseFor('user-ivan', 'describe_a_bug');
    expect(phase, ObjectivePhase.learning);

    final plan = service.engine.compose(
      PracticeRequest(
        userId: 'user-ivan',
        track: Track.speaking,
        minutes: 10,
        currentObjectiveId: 'describe_a_bug',
        phase: phase,
        newItems: List.generate(20, _new),
        recentReview: List.generate(6, _review),
        spacedReview: List.generate(6, (i) => _review(100 + i)),
        seed: 7,
      ),
    );

    expect(plan.phase, ObjectivePhase.learning);
    expect(plan.items.length, plan.targetCount);
    expect(plan.newCount, greaterThan(0));
    expect(plan.reviewCount, greaterThan(0),
        reason: 'learning phase interleaves cross-pack review into the session');
    // Reviews surfaced belong to other objectives (cross-pack), not the current one.
    expect(
      plan.items.where((i) => i.isReview).every((i) => i.objectiveId != 'describe_a_bug'),
      isTrue,
    );
  });
}
