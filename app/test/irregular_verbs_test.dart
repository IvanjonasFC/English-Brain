import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/irregular_verbs/models/irregular_verb.dart';
import 'package:app/features/irregular_verbs/data/irregular_verbs_data.dart';

void main() {
  group('Verbs Lab — Taxonomy & Routing Tests', () {
    test('A1-A2 Essentials route contains core high-frequency verbs', () {
      final a1a2 = IrregularVerbsData.getVerbsByRoute('A1-A2');
      final ids = a1a2.map((v) => v.id).toSet();

      expect(ids.contains('be'), isTrue);
      expect(ids.contains('have'), isTrue);
      expect(ids.contains('do'), isTrue);
      expect(ids.contains('make'), isTrue);
      expect(ids.contains('find'), isTrue);
      expect(ids.contains('know'), isTrue);
    });

    test('B1-B2 Projects route contains STAR interview verbs', () {
      final b1b2 = IrregularVerbsData.getVerbsByRoute('B1-B2');
      final ids = b1b2.map((v) => v.id).toSet();

      expect(ids.contains('build'), isTrue);
      expect(ids.contains('lead'), isTrue);
      expect(ids.contains('choose'), isTrue);
      expect(ids.contains('deal'), isTrue);
      expect(ids.contains('grow'), isTrue);
    });

    test('B2-C1 Senior Technical route contains architecture & resilience verbs', () {
      final b2c1 = IrregularVerbsData.getVerbsByRoute('B2-C1');
      final ids = b2c1.map((v) => v.id).toSet();

      expect(ids.contains('arise'), isTrue);
      expect(ids.contains('undertake'), isTrue);
      expect(ids.contains('undergo'), isTrue);
      expect(ids.contains('withstand'), isTrue);
      expect(ids.contains('seek'), isTrue);
      expect(ids.contains('bind'), isTrue);
      expect(ids.contains('withdraw'), isTrue, reason: 'withdraw belongs to B2-C1 for release rollbacks and proposals');
    });

    test('withdraw is NOT duplicated in C1+ Advanced Precision and C1+ has 10-15 distinct verbs', () {
      final b2c1 = IrregularVerbsData.getVerbsByRoute('B2-C1');
      final c1 = IrregularVerbsData.getVerbsByRoute('C1+');

      final b2c1Ids = b2c1.map((v) => v.id).toSet();
      final c1Ids = c1.map((v) => v.id).toSet();

      // No overlap between B2-C1 and C1+
      final intersection = b2c1Ids.intersection(c1Ids);
      expect(intersection.isEmpty, isTrue, reason: 'Verbs must not be duplicated across routes: $intersection');

      // C1+ must have between 10 and 15 verbs
      expect(c1.length, greaterThanOrEqualTo(10));
      expect(c1.length, lessThanOrEqualTo(15));
      expect(c1Ids.contains('foresee'), isTrue);
      expect(c1Ids.contains('strive'), isTrue);
      expect(c1Ids.contains('shed'), isTrue);
      expect(c1Ids.contains('breed'), isTrue);
      expect(c1Ids.contains('forbid'), isTrue);
    });

    test('CefrRouteInfo declares clear communicative goals for all 5 bands', () {
      expect(CefrRouteInfo.routes.length, equals(5));

      final a1 = CefrRouteInfo.forBand('A1-A2');
      expect(a1.communicativeGoal, contains('Presentarte'));

      final b1 = CefrRouteInfo.forBand('B1-B2');
      expect(b1.communicativeGoal, contains('STAR'));

      final b2 = CefrRouteInfo.forBand('B2-C1');
      expect(b2.communicativeGoal, contains('incidentes'));

      final c1 = CefrRouteInfo.forBand('C1+');
      expect(c1.isOptional, isTrue);
      expect(c1.badgeNote, isNotNull);
    });

    test('Technical phrasal verbs like spin up and wind down are decoupled from base entries', () {
      final spinVerb = IrregularVerbsData.verbs.firstWhere((v) => v.id == 'spin');
      expect(spinVerb.v1, 'spin');
      expect(spinVerb.v2, 'spun');
      expect(spinVerb.v3, 'spun');
      expect(spinVerb.relatedPhrasalVerbs.any((p) => p.contains('spin up')), isTrue);

      final windVerb = IrregularVerbsData.verbs.firstWhere((v) => v.id == 'wind');
      expect(windVerb.v1, 'wind');
      expect(windVerb.v2, 'wound');
      expect(windVerb.v3, 'wound');
      expect(windVerb.relatedPhrasalVerbs.any((p) => p.contains('wind down')), isTrue);

      // Verify no root entry named 'spin up' or 'wind down' exists
      expect(IrregularVerbsData.verbs.any((v) => v.id == 'spin up'), isFalse);
      expect(IrregularVerbsData.verbs.any((v) => v.id == 'wind down'), isFalse);
    });
  });

  group('Verbs Lab — Composite Mastery Tests', () {
    test('Mastery formula computes weighted score correctly', () {
      const metrics = VerbProgressMetrics(
        formRecallCorrect: 4,
        formRecallTotal: 4, // 1.0 (recognition 0.25 + form recall 0.30 = 0.55)
        listeningCorrect: 2,
        listeningTotal: 2, // 1.0 (listening 0.15)
        sentenceUsageCorrect: 2,
        sentenceUsageTotal: 2, // 1.0 (contextual 0.20)
        pronunciationAttempts: 1,
        pronunciationAvgScore: 90.0, // 0.90 * 0.10 = 0.09
      );

      // 0.25(1) + 0.30(1) + 0.20(1) + 0.15(1) + 0.10(0.9) = 0.99
      expect(metrics.compositeMastery, closeTo(0.99, 0.01));
    });

    test('Verb is NOT marked as isMastered without multiple days and listening/sentence proof', () {
      // High form recall score, but only 1 date and no listening
      const incomplete = VerbProgressMetrics(
        formRecallCorrect: 5,
        formRecallTotal: 5,
        recallDates: {'2026-09-11'},
        listeningCorrect: 0,
        sentenceUsageCorrect: 0,
      );

      expect(incomplete.isMastered, isFalse);

      // Fully qualified with 2 dates, listening, sentence usage and high composite score
      const complete = VerbProgressMetrics(
        formRecallCorrect: 4,
        formRecallTotal: 4,
        recallDates: {'2026-09-10', '2026-09-11'},
        listeningCorrect: 2,
        listeningTotal: 2,
        sentenceUsageCorrect: 2,
        sentenceUsageTotal: 2,
        pronunciationAttempts: 2,
        pronunciationAvgScore: 85.0,
      );
      expect(complete.isMastered, isTrue);
    });

    test('isInterviewReady requires isMastered AND at least 1 oral speaking STAR production', () {
      const masteredOnly = VerbProgressMetrics(
        formRecallCorrect: 4,
        formRecallTotal: 4,
        recallDates: {'2026-09-10', '2026-09-11'},
        listeningCorrect: 2,
        listeningTotal: 2,
        sentenceUsageCorrect: 2,
        sentenceUsageTotal: 2,
        pronunciationAttempts: 2,
        pronunciationAvgScore: 85.0,
        speakingCount: 0, // No STAR speaking yet
      );

      expect(masteredOnly.isMastered, isTrue);
      expect(masteredOnly.isInterviewReady, isFalse);

      const interviewReady = VerbProgressMetrics(
        formRecallCorrect: 4,
        formRecallTotal: 4,
        recallDates: {'2026-09-10', '2026-09-11'},
        listeningCorrect: 2,
        listeningTotal: 2,
        sentenceUsageCorrect: 2,
        sentenceUsageTotal: 2,
        pronunciationAttempts: 2,
        pronunciationAvgScore: 85.0,
        speakingCount: 1, // STAR speaking completed
      );

      expect(interviewReady.isMastered, isTrue);
      expect(interviewReady.isInterviewReady, isTrue);
    });

    test('VerbProgressMetrics JSON serialization preserves all metric fields', () {
      const original = VerbProgressMetrics(
        formRecallCorrect: 3,
        formRecallTotal: 4,
        listeningCorrect: 2,
        listeningTotal: 2,
        sentenceUsageCorrect: 1,
        sentenceUsageTotal: 1,
        pronunciationAttempts: 2,
        pronunciationAvgScore: 88.5,
        speakingCount: 1,
        recallDates: {'2026-09-10', '2026-09-11'},
        lastMistakeType: 'form_recall',
      );

      final json = original.toJson();
      final restored = VerbProgressMetrics.fromJson(json);

      expect(restored.formRecallCorrect, original.formRecallCorrect);
      expect(restored.listeningCorrect, original.listeningCorrect);
      expect(restored.sentenceUsageCorrect, original.sentenceUsageCorrect);
      expect(restored.pronunciationAvgScore, original.pronunciationAvgScore);
      expect(restored.speakingCount, original.speakingCount);
      expect(restored.recallDates, original.recallDates);
      expect(restored.lastMistakeType, original.lastMistakeType);
    });
  });
}
