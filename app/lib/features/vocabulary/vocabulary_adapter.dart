import 'vocabulary_repository.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/pedagogy/contracts.dart';

/// Bridges the existing hardcoded vocabulary content to the shared pedagogy
/// contracts, so the adaptive engine and FSRS ingestion can use it without
/// rewriting the 900+ lines of seed data.
extension VocabularyItemAdapter on VocabularyItem {
  VocabItemKind get inferredKind {
    final t = term.trim();
    if (t.contains(' ')) {
      // crude but useful: multi-word terms are usually phrases/collocations
      return VocabItemKind.phrase;
    }
    return VocabItemKind.term;
  }

  VocabEntry toEntry() => VocabEntry(
        term: term,
        ipa: ipa,
        definition: definition,
        exampleSentence: exampleSentence,
        spanishHint: spanishHint,
        relatedTerms: relatedTerms,
        kind: inferredKind,
        audioAvailable: true,
      );
}

VocabFamily _familyFromCategory(String category) {
  final c = category.toLowerCase();
  if (c.contains('backend')) return VocabFamily.backend;
  if (c.contains('frontend')) return VocabFamily.frontend;
  if (c.contains('devops')) return VocabFamily.devops;
  if (c.contains('database') || c.contains('data')) return VocabFamily.database;
  if (c.contains('interview')) return VocabFamily.interviewPhrases;
  if (c.contains('workplace') || c.contains('team')) return VocabFamily.workplacePhrases;
  if (c.contains('phrasal')) return VocabFamily.phrasalVerbs;
  if (c.contains('collocation')) return VocabFamily.collocations;
  if (c.contains('irregular')) return VocabFamily.irregularVerbs;
  return VocabFamily.technicalTerms;
}

extension VocabularyPackAdapter on VocabularyPack {
  /// Objective id derived from the pack id so progress/mastery can be tracked.
  String get objectiveId => 'vocab_$id';

  VocabPack toContract() => VocabPack(
        id: id,
        title: title,
        description: description,
        family: _familyFromCategory(terms.isNotEmpty ? terms.first.category : id),
        band: DifficultyBandX.parse(level),
        objectiveId: objectiveId,
        items: terms.map((e) => e.toEntry()).toList(),
      );
}
