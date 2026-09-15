/// Shared pedagogical taxonomy for the adaptive practice engine.
///
/// Everything the app teaches is described along these axes so that the
/// [PracticeEngine] can mix, sequence and surface content coherently instead
/// of relying on flat category filters.
library;

/// Skill family a piece of content trains.
enum Track { speaking, listening, grammar, vocabulary, writing }

/// Real-world situation the content belongs to.
enum LearningScenario {
  foundations,
  dailyEnglish,
  hrInterview,
  technicalInterview,
  debugging,
  teamwork,
  systemsDesign,
  workplaceEnglish,
}

/// CEFR-aligned difficulty band.
enum DifficultyBand { a2b1, b1b2, b2c1, c1 }

/// Kind of activity inside a unit/pack.
enum ContentType { lesson, drill, checkpoint, review, shadowing, dictation }

/// Interview practice modes.
enum PracticeMode { guided, checkpoint, mock, shadowing }

/// Individual exercise formats used inside a mixed session.
enum ExerciseType {
  recognition,   // multiple choice / meaning recognition
  fillBlank,
  reorder,
  writeShort,
  speakShort,
  listenChoose,
  chooseBestTerm,
  sayASentence,
  shadowing,
  dictation,
}

String _bandLabel(DifficultyBand b) {
  switch (b) {
    case DifficultyBand.a2b1: return 'A1-A2';
    case DifficultyBand.b1b2: return 'B1-B2';
    case DifficultyBand.b2c1: return 'B2-C1';
    case DifficultyBand.c1:   return 'C1';
  }
}

extension DifficultyBandX on DifficultyBand {
  String get label => _bandLabel(this);
  /// 0-based ordinal used to compare mastered difficulty.
  int get rank => index;
  static DifficultyBand parse(String? v) {
    // Mapea CUALQUIER etiqueta a las 4 bandas canónicas del motor (A1-A2 · B1-B2 · B2-C1 · C1).
    final raw = (v ?? '').trim();
    final low = raw.toLowerCase().replaceAll(' ', '');
    for (final b in DifficultyBand.values) {
      if (low == b.name) return b; // nombre de enum directo
    }
    var s = raw.toUpperCase();
    final dot = s.indexOf('•');
    if (dot >= 0) s = s.substring(0, dot);
    s = s.replaceAll(' ', '').replaceAll('-', '');

    // 1. C2 / C1 / Strategic / Lead / Executive / Level 4
    if (s.contains('C2') || s.contains('EXECUTIVE') || s.contains('STRATEGIC') || s.contains('LEAD') || s.contains('STAFF') || s.contains('LEVEL4')) {
      return DifficultyBand.c1;
    }
    // 2. B2-C1 / Senior / Architecture / Level 3
    if (s.contains('B2C1') || s.contains('SENIOR') || s.contains('ARCHITECTURE') || s.contains('LEVEL3')) {
      return DifficultyBand.b2c1;
    }
    if (s.contains('C1') && !s.contains('B2')) {
      return DifficultyBand.c1;
    }
    // 3. A1-A2 / A2-B1 / Junior / Foundations / Level 1 (Cubeta Foundations)
    if (s.contains('A1') || s.contains('A2B1') || s.contains('A2') || s.contains('JUNIOR') || s.contains('FOUNDATIONS') || s.contains('LEVEL1')) {
      return DifficultyBand.a2b1;
    }
    // 4. B1-B2 / Systems / Mid / Level 2 (Cubeta Systems)
    if (s.contains('B1') || s.contains('B2') || s.contains('MID') || s.contains('SYSTEMS') || s.contains('LEVEL2')) {
      return DifficultyBand.b1b2;
    }
    return DifficultyBand.a2b1;
  }
}

extension TrackX on Track {
  String get id => name;
  static Track parse(String? v) =>
      Track.values.firstWhere((t) => t.name == v, orElse: () => Track.speaking);
}

extension LearningScenarioX on LearningScenario {
  String get id => name;
  String get label {
    switch (this) {
      case LearningScenario.foundations:
        return 'Foundations';
      case LearningScenario.dailyEnglish:
        return 'Daily English';
      case LearningScenario.hrInterview:
        return 'HR & Behavioral';
      case LearningScenario.technicalInterview:
        return 'Technical Interview';
      case LearningScenario.debugging:
        return 'Live Debugging';
      case LearningScenario.teamwork:
        return 'Teamwork & Agile';
      case LearningScenario.systemsDesign:
        return 'System Design';
      case LearningScenario.workplaceEnglish:
        return 'Workplace English';
    }
  }
  static LearningScenario parse(String? v) => LearningScenario.values
      .firstWhere((s) => s.name == v, orElse: () => LearningScenario.foundations);
}

extension PracticeModeX on PracticeMode {
  String get id => name;
  String get label {
    switch (this) {
      case PracticeMode.guided:
        return 'Lección Guiada';
      case PracticeMode.checkpoint:
        return 'Checkpoint';
      case PracticeMode.mock:
        return 'Mock Interview';
      case PracticeMode.shadowing:
        return 'Shadowing';
    }
  }
  static PracticeMode parse(String? v) => PracticeMode.values
      .firstWhere((m) => m.name == v, orElse: () => PracticeMode.guided);
}

extension ExerciseTypeX on ExerciseType {
  String get id => name;
  static ExerciseType parse(String? v) => ExerciseType.values
      .firstWhere((e) => e.name == v, orElse: () => ExerciseType.recognition);
}

/// A communicative objective: what the user should be able to DO.
/// The engine sequences and mixes content around objectives, not topics.
class Objective {
  final String id;
  final Track track;
  final LearningScenario scenario;
  final DifficultyBand band;
  final String textEn;
  final String textEs;

  const Objective({
    required this.id,
    required this.track,
    required this.scenario,
    required this.band,
    required this.textEn,
    required this.textEs,
  });
}

/// Canonical catalog of communicative objectives shared across tabs.
class ObjectiveCatalog {
  ObjectiveCatalog._();

  static const List<Objective> all = [
    Objective(id: 'describe_a_bug', track: Track.speaking, scenario: LearningScenario.debugging, band: DifficultyBand.b1b2, textEn: 'Describe a bug you fixed', textEs: 'Describir un bug que resolviste'),
    Objective(id: 'explain_an_api', track: Track.speaking, scenario: LearningScenario.technicalInterview, band: DifficultyBand.b2c1, textEn: 'Explain an API', textEs: 'Explicar una API'),
    Objective(id: 'past_simple_projects', track: Track.grammar, scenario: LearningScenario.technicalInterview, band: DifficultyBand.a2b1, textEn: 'Use past simple to talk about projects', textEs: 'Usar past simple para hablar de proyectos'),
    Objective(id: 'compare_two_technologies', track: Track.speaking, scenario: LearningScenario.systemsDesign, band: DifficultyBand.b2c1, textEn: 'Compare two technologies', textEs: 'Comparar dos tecnologías'),
    Objective(id: 'tell_me_about_yourself', track: Track.speaking, scenario: LearningScenario.hrInterview, band: DifficultyBand.b1b2, textEn: 'Answer "tell me about yourself"', textEs: 'Responder "tell me about yourself"'),
    Objective(id: 'understand_tech_explanation', track: Track.listening, scenario: LearningScenario.technicalInterview, band: DifficultyBand.b1b2, textEn: 'Understand a short tech explanation', textEs: 'Entender una explicación técnica corta'),
    Objective(id: 'describing_experience', track: Track.grammar, scenario: LearningScenario.hrInterview, band: DifficultyBand.b1b2, textEn: 'Describe your experience (present perfect)', textEs: 'Describir tu experiencia (present perfect)'),
    Objective(id: 'explaining_cause_result', track: Track.grammar, scenario: LearningScenario.debugging, band: DifficultyBand.b2c1, textEn: 'Explain causes and results', textEs: 'Explicar causas y resultados'),
    Objective(id: 'hypothetical_troubleshooting', track: Track.grammar, scenario: LearningScenario.debugging, band: DifficultyBand.b2c1, textEn: 'Handle hypothetical troubleshooting (conditionals)', textEs: 'Resolver hipótesis de troubleshooting (condicionales)'),
    Objective(id: 'structured_opinions', track: Track.speaking, scenario: LearningScenario.teamwork, band: DifficultyBand.b1b2, textEn: 'Give structured opinions', textEs: 'Dar opiniones estructuradas'),
    Objective(id: 'daily_english_foundations', track: Track.vocabulary, scenario: LearningScenario.foundations, band: DifficultyBand.a2b1, textEn: 'Daily English foundations', textEs: 'Bases de inglés diario'),
  ];

  static Objective? byId(String id) {
    for (final o in all) {
      if (o.id == id) return o;
    }
    return null;
  }
}
