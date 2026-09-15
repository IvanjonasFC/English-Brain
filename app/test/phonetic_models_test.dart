import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/phonetics/models/phonetic_models.dart';

void main() {
  group('Phonetic Taxonomy & Signal Detection Theory Tests', () {
    test('PhoneticTaxonomy contains all 44 English phonemes with articulation metadata', () {
      expect(PhoneticTaxonomy.all44Phonemes.length, equals(44));
      
      final shortVowels = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.shortVowel).toList();
      final longVowels = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.longVowel).toList();
      final diphthongs = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.diphthong).toList();
      final plosives = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.plosive).toList();
      final fricatives = PhoneticTaxonomy.all44Phonemes.where((p) => p.category == PhonemeCategory.fricative).toList();

      expect(shortVowels.length, equals(7));
      expect(longVowels.length, equals(5));
      expect(diphthongs.length, equals(8));
      expect(plosives.length, equals(6));
      expect(fricatives.length, equals(9));

      // Check L1 Spanish priors
      final vPhoneme = PhoneticTaxonomy.findPhoneme('v');
      expect(vPhoneme, isNotNull);
      expect(vPhoneme!.l1SpanishDifficultyPrior, greaterThanOrEqualTo(0.8));
    });

    test('Minimal pairs dataset covers critical L1 Spanish transfer contrast pairs', () {
      expect(PhoneticTaxonomy.minimalPairs.isNotEmpty, isTrue);
      
      final shipSheep = PhoneticTaxonomy.minimalPairs.firstWhere((p) => p.wordA == 'ship' && p.wordB == 'sheep');
      expect(shipSheep.phonemeA, equals('ɪ'));
      expect(shipSheep.phonemeB, equals('iː'));

      final veryBerry = PhoneticTaxonomy.minimalPairs.firstWhere((p) => p.wordA == 'very' && p.wordB == 'berry');
      expect(veryBerry.phonemeA, equals('v'));
      expect(veryBerry.phonemeB, equals('b'));
    });

    test('SignalDetectionDPrime calculates correct sensitivity index (d\')', () {
      // Perfect discrimination: 8 hits / 8 targets, 0 false alarms / 8 distractors
      final dPrimeHigh = SignalDetectionDPrime.calculate(
        hits: 8,
        totalTargets: 8,
        falseAlarms: 0,
        totalDistractors: 8,
      );
      expect(dPrimeHigh, greaterThan(2.0));

      // Chance / guessing performance (50% hit, 50% false alarm)
      final dPrimeChance = SignalDetectionDPrime.calculate(
        hits: 4,
        totalTargets: 8,
        falseAlarms: 4,
        totalDistractors: 8,
      );
      expect(dPrimeChance.abs(), lessThan(0.2));
    });
  });
}
