import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/phrasal_verbs/models/phrasal_verb.dart';
import 'package:app/features/phrasal_verbs/data/phrasal_verbs_data.dart';
import 'package:app/features/irregular_verbs/data/irregular_verbs_data.dart';

void main() {
  group('Phrasal Verbs Lab — Scenario & Intentions Architecture Tests', () {
    test('Main routes are organized by communicative intention & workplace scenario', () {
      expect(PhrasalScenario.values.length, equals(7));

      final dailyVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.dailySync);
      final devVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.basicDev);
      final debugVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.debugging);
      final deployVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.deployIncident);
      final collabVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.collaboration);
      final changeVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.changeDelivery);
      final seniorVerbs = PhrasalVerbsData.getVerbsByScenario(PhrasalScenario.seniorDecision);

      expect(dailyVerbs.any((v) => v.fullPhrase == 'check in' || v.fullPhrase == 'bring up'), isTrue);
      expect(devVerbs.any((v) => v.fullPhrase == 'set up' || v.fullPhrase == 'log in'), isTrue);
      expect(debugVerbs.any((v) => v.fullPhrase == 'find out' || v.fullPhrase == 'figure out'), isTrue);
      expect(deployVerbs.any((v) => v.fullPhrase == 'roll back' || v.fullPhrase == 'spin up'), isTrue);
      expect(collabVerbs.any((v) => v.fullPhrase == 'hand off' || v.fullPhrase == 'reach out'), isTrue);
      expect(changeVerbs.any((v) => v.fullPhrase == 'phase out' || v.fullPhrase == 'wrap up'), isTrue);
      expect(seniorVerbs.any((v) => v.fullPhrase == 'rule out' || v.fullPhrase == 'push back'), isTrue);
    });

    test('Particles function as secondary visual map & exploration filter', () {
      final upVerbs = PhrasalVerbsData.getVerbsByParticle(PhrasalParticle.up);
      final backVerbs = PhrasalVerbsData.getVerbsByParticle(PhrasalParticle.back);

      expect(upVerbs.any((v) => v.fullPhrase == 'spin up' || v.fullPhrase == 'set up'), isTrue);
      expect(backVerbs.any((v) => v.fullPhrase == 'roll back' || v.fullPhrase == 'fall back on'), isTrue);
    });

    test('Separable verbs accept both valid orders; Inseparable verbs reject separation', () {
      final rollBack = PhrasalVerbsData.verbs.firstWhere((v) => v.fullPhrase == 'roll back');
      expect(rollBack.isSeparable, isTrue);
      expect(rollBack.correctPattern, contains('roll back'));
      expect(rollBack.correctPattern, contains('roll [release] back'));
      expect(rollBack.incorrectPattern, contains('roll back it'));

      final lookInto = PhrasalVerbsData.verbs.firstWhere((v) => v.fullPhrase == 'look into');
      expect(lookInto.isSeparable, isFalse);
      expect(lookInto.incorrectPattern, contains('look the issue into'));
    });

    test('Polysemic / Rich data schema includes register alternatives, not 1:1 false equivalences', () {
      final rollBack = PhrasalVerbsData.verbs.firstWhere((v) => v.fullPhrase == 'roll back');
      expect(rollBack.formalAlternatives.length, greaterThanOrEqualTo(2));
      expect(rollBack.formalAlternatives.any((a) => a.term.contains('revert')), isTrue);
      expect(rollBack.formalAlternatives.any((a) => a.term.contains('restore')), isTrue);
      expect(rollBack.connectedSpeechChunk, contains('back'));
      expect(rollBack.ipa, equals('/roʊl bæk/'));
    });

    test('spin up is a technical phrasal verb, not listed as irregular verb in Verbs Lab', () {
      final irregularList = IrregularVerbsData.verbs;
      expect(irregularList.any((v) => v.v1 == 'spin up'), isFalse);
      expect(irregularList.any((v) => v.v1 == 'spin'), isTrue);

      final irregularSpin = irregularList.firstWhere((v) => v.v1 == 'spin');
      expect(irregularSpin.v2, equals('spun'));
      expect(irregularSpin.v3, equals('spun'));
      expect(irregularSpin.relatedPhrasalVerbs.any((pv) => pv.contains('spin up')), isTrue);
    });
  });

  group('Phrasal Verbs Lab — 6-Component Mastery & Interview Readiness Tests', () {
    test('Computes 6-component composite mastery accurately (0.20/0.25/0.20/0.15/0.10/0.10)', () {
      const metrics = PhrasalVerbMetrics(
        meaningRecallCorrect: 10,
        meaningRecallTotal: 10, // 1.0 * 20 = 20
        sentenceUsageCorrect: 10,
        sentenceUsageTotal: 10, // 1.0 * 25 = 25
        listeningCorrect: 10,
        listeningTotal: 10, // 1.0 * 20 = 20
        wordOrderCorrect: 10,
        wordOrderTotal: 10, // 1.0 * 15 = 15
        pronunciationAttempts: 2,
        pronunciationAvgScore: 100.0, // 1.0 * 10 = 10
        speakingCount: 2, // 1.0 * 10 = 10
        recallDates: {'2026-09-10', '2026-09-11'},
      );

      expect(metrics.compositeMasteryScore, closeTo(100.0, 0.01));
      expect(metrics.isMastered, isTrue);
      expect(metrics.isInterviewReady, isTrue);
    });

    test('Differentiates Consolidado from Listo para Entrevista (requires speaking practice)', () {
      const consolidatedWithoutSpeaking = PhrasalVerbMetrics(
        meaningRecallCorrect: 10,
        meaningRecallTotal: 10,
        sentenceUsageCorrect: 10,
        sentenceUsageTotal: 10,
        listeningCorrect: 10,
        listeningTotal: 10,
        wordOrderCorrect: 10,
        wordOrderTotal: 10,
        pronunciationAttempts: 2,
        pronunciationAvgScore: 90.0,
        speakingCount: 0, // No speaking yet!
        recallDates: {'2026-09-10', '2026-09-11'},
      );

      expect(consolidatedWithoutSpeaking.isMastered, isTrue);
      expect(consolidatedWithoutSpeaking.isInterviewReady, isFalse); // Pending oral simulation
    });

    test('JSON serialization roundtrip preserves all 6 components and FSRS error types', () {
      final original = PhrasalVerbMetrics(
        meaningRecallCorrect: 5,
        meaningRecallTotal: 6,
        sentenceUsageCorrect: 4,
        sentenceUsageTotal: 4,
        listeningCorrect: 3,
        listeningTotal: 3,
        wordOrderCorrect: 2,
        wordOrderTotal: 2,
        pronunciationAttempts: 1,
        pronunciationAvgScore: 94.0,
        speakingCount: 1,
        recallDates: const {'2026-09-08', '2026-09-11'},
        lastMistakeType: 'word_order',
        lastPracticedAt: DateTime.parse('2026-09-11T12:00:00Z'),
      );

      final json = original.toJson();
      final decoded = PhrasalVerbMetrics.fromJson(json);

      expect(decoded.wordOrderCorrect, equals(2));
      expect(decoded.lastMistakeType, equals('word_order'));
      expect(decoded.speakingCount, equals(1));
      expect(decoded.isInterviewReady, isTrue);
    });
  });

  group('Phrasal Verbs Lab — ZERO EMOJIS Quality Assertion', () {
    test('No emojis exist in PhrasalVerbs dataset strings', () {
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true);
      for (final v in PhrasalVerbsData.verbs) {
        expect(emojiRegex.hasMatch(v.fullPhrase), isFalse, reason: 'Verb ${v.fullPhrase} has emoji');
        expect(emojiRegex.hasMatch(v.spanish), isFalse, reason: 'Verb ${v.fullPhrase} spanish has emoji');
        expect(emojiRegex.hasMatch(v.dailySyncExample), isFalse, reason: 'Verb ${v.fullPhrase} dailySyncExample has emoji');
        expect(emojiRegex.hasMatch(v.workplaceExample), isFalse, reason: 'Verb ${v.fullPhrase} workplaceExample has emoji');
      }
    });

    test('No emojis exist in IrregularVerbs dataset strings', () {
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true);
      for (final v in IrregularVerbsData.verbs) {
        expect(emojiRegex.hasMatch(v.v1), isFalse);
        expect(emojiRegex.hasMatch(v.spanish), isFalse);
        expect(emojiRegex.hasMatch(v.exampleSentence), isFalse);
      }
    });
  });
}
