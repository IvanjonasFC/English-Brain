/// Data contracts shared by every practice tab. Pure models with JSON
/// (de)serialization so they can come from local seeds, published snapshots
/// or the backend interchangeably.
library;

import 'taxonomy.dart';

/// Interview practice pack — a set of related questions around one objective.
class InterviewPack {
  final String id;
  final LearningScenario scenario;
  final String subtopic;
  final String objectiveId;
  final DifficultyBand band;
  final PracticeMode mode;
  final List<int> questionIds;
  final List<String> skills;
  final int estMinutes;
  final String feedbackType; // e.g. "STAR + pronunciation"
  final String domain; // 'general' | 'tech'

  const InterviewPack({
    required this.id,
    required this.scenario,
    required this.subtopic,
    required this.objectiveId,
    required this.band,
    required this.mode,
    required this.questionIds,
    required this.skills,
    required this.estMinutes,
    required this.feedbackType,
    this.domain = 'tech',
  });

  factory InterviewPack.fromJson(Map<String, dynamic> j) => InterviewPack(
        id: j['id'] as String,
        scenario: LearningScenarioX.parse(j['scenario'] as String?),
        subtopic: (j['subtopic'] ?? '') as String,
        objectiveId: (j['objectiveId'] ?? '') as String,
        band: DifficultyBandX.parse(j['band'] as String?),
        mode: PracticeModeX.parse(j['mode'] as String?),
        questionIds: ((j['questionIds'] ?? []) as List).map((e) => e as int).toList(),
        skills: ((j['skills'] ?? []) as List).map((e) => e.toString()).toList(),
        estMinutes: (j['estMinutes'] ?? 8) as int,
        feedbackType: (j['feedbackType'] ?? '') as String,
        domain: (j['domain'] ?? 'tech') as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'scenario': scenario.id,
        'subtopic': subtopic,
        'objectiveId': objectiveId,
        'band': band.label,
        'mode': mode.id,
        'questionIds': questionIds,
        'skills': skills,
        'estMinutes': estMinutes,
        'feedbackType': feedbackType,
        'domain': domain,
      };
}

enum VocabFamily {
  technicalTerms,
  workplacePhrases,
  interviewPhrases,
  collocations,
  irregularVerbs,
  phrasalVerbs,
  backend,
  frontend,
  devops,
  database,
}

extension VocabFamilyX on VocabFamily {
  String get id => name;
  static VocabFamily parse(String? v) =>
      VocabFamily.values.firstWhere((f) => f.name == v, orElse: () => VocabFamily.technicalTerms);
}

enum VocabItemKind { term, phrase, irregularVerb, phrasalVerb, collocation }

extension VocabItemKindX on VocabItemKind {
  String get id => name;
  static VocabItemKind parse(String? v) =>
      VocabItemKind.values.firstWhere((k) => k.name == v, orElse: () => VocabItemKind.term);
}

/// Canonical vocabulary entry (supersedes the flat VocabularyItem in phase 3).
class VocabEntry {
  final String term;
  final String ipa;
  final String definition;
  final String exampleSentence;
  final String spanishHint;
  final List<String> relatedTerms;
  final String? partOfSpeech;
  final VocabItemKind kind;
  final bool audioAvailable;

  const VocabEntry({
    required this.term,
    required this.ipa,
    required this.definition,
    required this.exampleSentence,
    this.spanishHint = '',
    this.relatedTerms = const [],
    this.partOfSpeech,
    this.kind = VocabItemKind.term,
    this.audioAvailable = true,
  });

  factory VocabEntry.fromJson(Map<String, dynamic> j) => VocabEntry(
        term: j['term'] as String,
        ipa: (j['ipa'] ?? '') as String,
        definition: (j['definition'] ?? '') as String,
        exampleSentence: (j['exampleSentence'] ?? '') as String,
        spanishHint: (j['spanishHint'] ?? '') as String,
        relatedTerms: ((j['relatedTerms'] ?? []) as List).map((e) => e.toString()).toList(),
        partOfSpeech: j['partOfSpeech'] as String?,
        kind: VocabItemKindX.parse(j['kind'] as String?),
        audioAvailable: (j['audioAvailable'] ?? true) as bool,
      );

  Map<String, dynamic> toJson() => {
        'term': term,
        'ipa': ipa,
        'definition': definition,
        'exampleSentence': exampleSentence,
        'spanishHint': spanishHint,
        'relatedTerms': relatedTerms,
        'partOfSpeech': partOfSpeech,
        'kind': kind.id,
        'audioAvailable': audioAvailable,
      };
}

class VocabPack {
  final String id;
  final String title;
  final String description;
  final VocabFamily family;
  final DifficultyBand band;
  final String objectiveId;
  final List<VocabEntry> items;

  const VocabPack({
    required this.id,
    required this.title,
    required this.description,
    required this.family,
    required this.band,
    required this.objectiveId,
    required this.items,
  });

  factory VocabPack.fromJson(Map<String, dynamic> j) => VocabPack(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        family: VocabFamilyX.parse(j['family'] as String?),
        band: DifficultyBandX.parse(j['band'] as String?),
        objectiveId: (j['objectiveId'] ?? '') as String,
        items: ((j['items'] ?? []) as List)
            .map((e) => VocabEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'family': family.id,
        'band': band.label,
        'objectiveId': objectiveId,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

/// Grammar unit as a functional route around a communicative objective.
class GrammarUnitDef {
  final String id;
  final String title;
  final String objectiveId;
  final DifficultyBand band;
  final String guidebook;
  final List<String> keyContrasts;
  final List<String> commonEsMistakes; // typical Spanish-speaker errors
  final List<Map<String, dynamic>> drills; // raw drill payloads
  final List<String> miniSpeakingPrompts;
  final List<String> prerequisites;

  const GrammarUnitDef({
    required this.id,
    required this.title,
    required this.objectiveId,
    required this.band,
    required this.guidebook,
    this.keyContrasts = const [],
    this.commonEsMistakes = const [],
    this.drills = const [],
    this.miniSpeakingPrompts = const [],
    this.prerequisites = const [],
  });

  factory GrammarUnitDef.fromJson(Map<String, dynamic> j) => GrammarUnitDef(
        id: j['id'] as String,
        title: (j['title'] ?? '') as String,
        objectiveId: (j['objectiveId'] ?? '') as String,
        band: DifficultyBandX.parse(j['band'] as String?),
        guidebook: (j['guidebook'] ?? '') as String,
        keyContrasts: ((j['keyContrasts'] ?? []) as List).map((e) => e.toString()).toList(),
        commonEsMistakes: ((j['commonEsMistakes'] ?? []) as List).map((e) => e.toString()).toList(),
        drills: ((j['drills'] ?? []) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
        miniSpeakingPrompts: ((j['miniSpeakingPrompts'] ?? []) as List).map((e) => e.toString()).toList(),
        prerequisites: ((j['prerequisites'] ?? []) as List).map((e) => e.toString()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'objectiveId': objectiveId,
        'band': band.label,
        'guidebook': guidebook,
        'keyContrasts': keyContrasts,
        'commonEsMistakes': commonEsMistakes,
        'drills': drills,
        'miniSpeakingPrompts': miniSpeakingPrompts,
        'prerequisites': prerequisites,
      };
}

enum ReviewSource { interviewMistake, vocabulary, grammar, listening }

extension ReviewSourceX on ReviewSource {
  String get id => name;
  static ReviewSource parse(String? v) =>
      ReviewSource.values.firstWhere((s) => s.name == v, orElse: () => ReviewSource.vocabulary);
}

enum ReviewItemType {
  wordMeaning,
  sentenceCorrection,
  audioRecognition,
  irregularVerbForm,
  interviewOpener,
  phraseCompletion,
}

extension ReviewItemTypeX on ReviewItemType {
  String get id => name;
  static ReviewItemType parse(String? v) =>
      ReviewItemType.values.firstWhere((t) => t.name == v, orElse: () => ReviewItemType.wordMeaning);
}

/// A retention item that can be ingested into the FSRS deck from any tab.
class ReviewItem {
  final String front;
  final String back;
  final ReviewSource sourceType;
  final String sourceRef;      // e.g. mistake id, term, unit id
  final ReviewItemType itemType;
  final String unitOrPackId;
  final Track skill;

  const ReviewItem({
    required this.front,
    required this.back,
    required this.sourceType,
    required this.sourceRef,
    required this.itemType,
    required this.unitOrPackId,
    required this.skill,
  });

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
        'source_type': sourceType.id,
        'source_ref': sourceRef,
        'item_type': itemType.id,
        'unit_or_pack_id': unitOrPackId,
        'skill': skill.id,
      };

  factory ReviewItem.fromJson(Map<String, dynamic> j) => ReviewItem(
        front: j['front'] as String,
        back: j['back'] as String,
        sourceType: ReviewSourceX.parse(j['source_type'] as String?),
        sourceRef: (j['source_ref'] ?? '') as String,
        itemType: ReviewItemTypeX.parse(j['item_type'] as String?),
        unitOrPackId: (j['unit_or_pack_id'] ?? '') as String,
        skill: TrackX.parse(j['skill'] as String?),
      );
}
