enum IrregularVerbGroup {
  allSame, // A-A-A: cut / cut / cut
  pastParticipleSame, // A-B-B: build / built / built
  baseParticipleSame, // A-B-A: come / came / come
  iAU, // i - a - u: sing / sang / sung
  ewOwn, // -ew / -own: know / knew / known
  enParticiple, // -en participle: break / broke / broken
  completelyIrregular, // be / was-were / been
  seniorTechnical, // arise / undertake / undergo / withstand
}

extension IrregularVerbGroupX on IrregularVerbGroup {
  String get id {
    switch (this) {
      case IrregularVerbGroup.allSame:
        return 'all_same';
      case IrregularVerbGroup.pastParticipleSame:
        return 'past_participle_same';
      case IrregularVerbGroup.baseParticipleSame:
        return 'base_participle_same';
      case IrregularVerbGroup.iAU:
        return 'i_a_u';
      case IrregularVerbGroup.ewOwn:
        return 'ew_own';
      case IrregularVerbGroup.enParticiple:
        return 'en_participle';
      case IrregularVerbGroup.completelyIrregular:
        return 'completely_irregular';
      case IrregularVerbGroup.seniorTechnical:
        return 'senior_technical';
    }
  }

  String get label {
    switch (this) {
      case IrregularVerbGroup.allSame:
        return 'A-A-A (Idénticos)';
      case IrregularVerbGroup.pastParticipleSame:
        return 'A-B-B (Pasado = Participio)';
      case IrregularVerbGroup.baseParticipleSame:
        return 'A-B-A (Base = Participio)';
      case IrregularVerbGroup.iAU:
        return 'i — a — u';
      case IrregularVerbGroup.ewOwn:
        return '-ew / -own';
      case IrregularVerbGroup.enParticiple:
        return '-en (Participio)';
      case IrregularVerbGroup.completelyIrregular:
        return 'Totalmente Irregulares';
      case IrregularVerbGroup.seniorTechnical:
        return 'Senior Technical & Core';
    }
  }

  String get description {
    switch (this) {
      case IrregularVerbGroup.allSame:
        return 'Las tres formas (presente, pasado y participio) se escriben y pronuncian exactamente igual.';
      case IrregularVerbGroup.pastParticipleSame:
        return 'El Pasado Simple y el Participio Pasado son idénticos en escritura y pronunciación.';
      case IrregularVerbGroup.baseParticipleSame:
        return 'La forma base de presente y el Participio Pasado coinciden exactamente.';
      case IrregularVerbGroup.iAU:
        return 'Patrón vocal que cambia de /ɪ/ en presente a /æ/ en pasado y termina en /ʌ/ en participio.';
      case IrregularVerbGroup.ewOwn:
        return 'Terminaciones en -ew en pasado y -own/-awn en participio.';
      case IrregularVerbGroup.enParticiple:
        return 'El participio pasado termina con el sufijo -en o -ne.';
      case IrregularVerbGroup.completelyIrregular:
        return 'Verbos fundamentales de alta frecuencia con transformaciones léxicas únicas.';
      case IrregularVerbGroup.seniorTechnical:
        return 'Verbos indispensables para arquitectura, riesgos, post-mortems y decisiones técnicas senior.';
    }
  }
}

class VerbProgressMetrics {
  final int formRecallCorrect;
  final int formRecallTotal;
  final int listeningCorrect;
  final int listeningTotal;
  final int sentenceUsageCorrect;
  final int sentenceUsageTotal;
  final int pronunciationAttempts;
  final double pronunciationAvgScore;
  final int speakingCount;
  final Set<String> recallDates; // ISO strings YYYY-MM-DD
  final String? lastMistakeType;
  final DateTime? lastPracticedAt;

  const VerbProgressMetrics({
    this.formRecallCorrect = 0,
    this.formRecallTotal = 0,
    this.listeningCorrect = 0,
    this.listeningTotal = 0,
    this.sentenceUsageCorrect = 0,
    this.sentenceUsageTotal = 0,
    this.pronunciationAttempts = 0,
    this.pronunciationAvgScore = 0.0,
    this.speakingCount = 0,
    this.recallDates = const {},
    this.lastMistakeType,
    this.lastPracticedAt,
  });

  double get recognitionScore => formRecallTotal > 0 ? (formRecallCorrect / formRecallTotal).clamp(0.0, 1.0) : 0.0;
  double get formRecallScore => formRecallTotal > 0 ? (formRecallCorrect / formRecallTotal).clamp(0.0, 1.0) : 0.0;
  double get contextualUsageScore => sentenceUsageTotal > 0 ? (sentenceUsageCorrect / sentenceUsageTotal).clamp(0.0, 1.0) : 0.0;
  double get listeningScore => listeningTotal > 0 ? (listeningCorrect / listeningTotal).clamp(0.0, 1.0) : 0.0;
  double get pronunciationScore => (pronunciationAvgScore / 100.0).clamp(0.0, 1.0);

  /// Composite Mastery Formula:
  /// 25% recognition + 30% form recall + 20% contextual usage + 15% listening + 10% pronunciation
  double get compositeMastery {
    final score = (0.25 * recognitionScore) +
        (0.30 * formRecallScore) +
        (0.20 * contextualUsageScore) +
        (0.15 * listeningScore) +
        (0.10 * pronunciationScore);
    return score.clamp(0.0, 1.0);
  }

  /// Strictly checks pedagogical mastery criteria:
  /// - At least 2 correct recalls on distinct dates
  /// - At least 1 correct listening discrimination
  /// - At least 1 correct sentence usage
  bool get isMastered {
    return recallDates.length >= 2 &&
        formRecallCorrect >= 2 &&
        listeningCorrect >= 1 &&
        sentenceUsageCorrect >= 1 &&
        compositeMastery >= 0.80;
  }

  bool get isInterviewReady => isMastered && speakingCount >= 1;

  Map<String, dynamic> toJson() => {
        'formRecallCorrect': formRecallCorrect,
        'formRecallTotal': formRecallTotal,
        'listeningCorrect': listeningCorrect,
        'listeningTotal': listeningTotal,
        'sentenceUsageCorrect': sentenceUsageCorrect,
        'sentenceUsageTotal': sentenceUsageTotal,
        'pronunciationAttempts': pronunciationAttempts,
        'pronunciationAvgScore': pronunciationAvgScore,
        'speakingCount': speakingCount,
        'recallDates': recallDates.toList(),
        'lastMistakeType': lastMistakeType,
        'lastPracticedAt': lastPracticedAt?.toIso8601String(),
      };

  factory VerbProgressMetrics.fromJson(Map<String, dynamic> json) {
    return VerbProgressMetrics(
      formRecallCorrect: json['formRecallCorrect'] as int? ?? 0,
      formRecallTotal: json['formRecallTotal'] as int? ?? 0,
      listeningCorrect: json['listeningCorrect'] as int? ?? 0,
      listeningTotal: json['listeningTotal'] as int? ?? 0,
      sentenceUsageCorrect: json['sentenceUsageCorrect'] as int? ?? 0,
      sentenceUsageTotal: json['sentenceUsageTotal'] as int? ?? 0,
      pronunciationAttempts: json['pronunciationAttempts'] as int? ?? 0,
      pronunciationAvgScore: (json['pronunciationAvgScore'] as num?)?.toDouble() ?? 0.0,
      speakingCount: json['speakingCount'] as int? ?? 0,
      recallDates: (json['recallDates'] as List<dynamic>?)?.cast<String>().toSet() ?? {},
      lastMistakeType: json['lastMistakeType'] as String?,
      lastPracticedAt: json['lastPracticedAt'] != null ? DateTime.tryParse(json['lastPracticedAt'] as String) : null,
    );
  }
}

class IrregularVerb {
  final String id;
  final String v1; // Base / Infinitive
  final String v2; // Past Simple
  final String v3; // Past Participle
  final String ipaV1;
  final String ipaV2;
  final String ipaV3;
  final String spanish;
  final IrregularVerbGroup group;
  final String cefrLevel; // A1-A2, A2-B1, B1-B2, B2-C1, C1+
  final String stressSeparation; // e.g. be-GIN → be-GAN → be-GUN
  final String exampleSentence;
  final String examplePastSentence;
  final String exampleParticipleSentence;
  final String? commonMistake; // e.g. "He builded..." -> "He built..."
  final String? usageTip; // e.g. "Distingue /t/ en built de /d/ en build"
  final String? starContext; // e.g. "Describe a complex refactor you led"
  final List<String> relatedPhrasalVerbs; // e.g. ['spin up', 'spin off'] for 'spin'
  final bool isTechRelevant;

  const IrregularVerb({
    required this.id,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.ipaV1,
    required this.ipaV2,
    required this.ipaV3,
    required this.spanish,
    required this.group,
    this.cefrLevel = 'A2',
    required this.stressSeparation,
    required this.exampleSentence,
    required this.examplePastSentence,
    required this.exampleParticipleSentence,
    this.commonMistake,
    this.usageTip,
    this.starContext,
    this.relatedPhrasalVerbs = const [],
    this.isTechRelevant = false,
  });

  String get sequenceText => '$v1, $v2, $v3';
}

/// Metadata pedagógica y objetivo comunicativo por ruta CEFR
class CefrRouteInfo {
  final String band; // 'A1-A2', 'A2-B1', 'B1-B2', 'B2-C1', 'C1+'
  final String title;
  final String communicativeGoal;
  final String sampleVerbs;
  final bool isOptional;
  final String? badgeNote;

  const CefrRouteInfo({
    required this.band,
    required this.title,
    required this.communicativeGoal,
    required this.sampleVerbs,
    this.isOptional = false,
    this.badgeNote,
  });

  static const List<CefrRouteInfo> routes = [
    CefrRouteInfo(
      band: 'A1-A2',
      title: 'A1-A2 · Essentials & Daily Actions',
      communicativeGoal: 'Presentarte, describir acciones cotidianas y contar hechos simples en pasado.',
      sampleVerbs: 'be · have · do · go · get · make · take · come · see · give · find · know',
    ),
    CefrRouteInfo(
      band: 'A2-B1',
      title: 'A2-B1 · Everyday & Work',
      communicativeGoal: 'Hablar de tareas, reuniones, problemas y experiencias laborales básicas.',
      sampleVerbs: 'say · tell · think · feel · leave · meet · read · write · run · keep · bring · buy',
    ),
    CefrRouteInfo(
      band: 'B1-B2',
      title: 'B1-B2 · Projects & Interviews',
      communicativeGoal: 'Explicar proyectos, responsabilidades, decisiones, resultados y errores con estructura STAR.',
      sampleVerbs: 'build · lead · choose · break · send · deal · mean · grow · become · hold · win · lose',
    ),
    CefrRouteInfo(
      band: 'B2-C1',
      title: 'B2-C1 · Senior Technical',
      communicativeGoal: 'Explicar incidentes, arquitectura, riesgos, trade-offs, ownership y decisiones técnicas complejas.',
      sampleVerbs: 'arise · overcome · undertake · undergo · withdraw · withstand · seek · bind · spin · wind · split · cast · bear',
    ),
    CefrRouteInfo(
      band: 'C1+',
      title: 'C1+ · Advanced Precision',
      communicativeGoal: 'Matizar, argumentar y comunicarte con precisión en situaciones formales o técnicas complejas.',
      sampleVerbs: 'foresee · strive · shed · breed · forbid · swear · shake · stride · weave · forsake · shrink · tread',
      isOptional: true,
      badgeNote: 'Precisión avanzada — útil para lectura, redacción y comunicación técnica formal; no necesaria para completar entrevistas B2-C1.',
    ),
  ];

  static CefrRouteInfo forBand(String band) {
    return routes.firstWhere(
      (r) => r.band == band,
      orElse: () => routes[2], // Default B1-B2
    );
  }
}

