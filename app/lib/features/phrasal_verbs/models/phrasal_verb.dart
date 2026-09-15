/// Escenarios comunicativos e intencionales de trabajo y tecnologia (Eje pedagogico principal)
enum PhrasalScenario {
  dailySync(
    'daily_sync',
    'Trabajo diario y reuniones',
    'A2-B1',
    'Participar con soltura en standups, syncs, pedir seguimiento y comentar bloqueos.',
    'check in, follow up, bring up, go over, catch up, look into',
  ),
  basicDev(
    'basic_dev',
    'Desarrollo y herramientas',
    'A2-B1',
    'Configurar entornos, accesos, credenciales, backups y tareas diarias de desarrollo.',
    'set up, log in, sign in, shut down, back up, plug in',
  ),
  debugging(
    'debugging',
    'Problemas y debugging',
    'B1-B2',
    'Investigar bugs, descubrir causas raiz, desbloquearse y analizar logs en equipo.',
    'find out, figure out, run into, sort out, break down, come across',
  ),
  deployIncident(
    'deploy_incident',
    'Deploys e incidencias',
    'B1-B2',
    'Gestionar releases, rollbacks, aprovisionar contenedores y mitigar caidas en produccion.',
    'roll out, roll back, spin up, scale up, fall back, bring back',
  ),
  collaboration(
    'collaboration',
    'Colaboracion y ownership',
    'B1-B2',
    'Coordinar handoffs, asumir responsabilidad de modulos, brindar soporte y tomar el relevo.',
    'hand off, step in, reach out, take over, back up, follow through',
  ),
  changeDelivery(
    'change_delivery',
    'Cambio y entregas',
    'B2-C1',
    'Planificar migraciones, fases de deprecacion, cierres de sprint y arranque de roadmaps.',
    'phase out, wind down, carry on, move forward, wrap up, kick off',
  ),
  seniorDecision(
    'senior_decision',
    'Decisiones tecnicas senior',
    'B2-C1',
    'Argumentar trade-offs, descartar alternativas, negociar prioridades y justificar workarounds.',
    'weigh up, rule out, push back, narrow down, opt for, work around',
  );

  final String id;
  final String title;
  final String cefr;
  final String communicativeGoal;
  final String samplePhrases;

  const PhrasalScenario(
    this.id,
    this.title,
    this.cefr,
    this.communicativeGoal,
    this.samplePhrases,
  );

  /// Etiqueta corta para el selector de arriba (los titulos completos son
  /// largos y no caben en horizontal; el titulo completo se ve en el hero).
  String get shortLabel {
    switch (this) {
      case PhrasalScenario.dailySync:
        return 'Reuniones';
      case PhrasalScenario.basicDev:
        return 'Desarrollo';
      case PhrasalScenario.debugging:
        return 'Debugging';
      case PhrasalScenario.deployIncident:
        return 'Deploys';
      case PhrasalScenario.collaboration:
        return 'Colaboración';
      case PhrasalScenario.changeDelivery:
        return 'Entregas';
      case PhrasalScenario.seniorDecision:
        return 'Decisiones';
    }
  }

  static PhrasalScenario fromId(String id) {
    return PhrasalScenario.values.firstWhere(
      (s) => s.id == id,
      orElse: () => PhrasalScenario.dailySync,
    );
  }
}

/// Particulas conceptuales que agrupan los Phrasal Verbs por su metafora raiz (Mapa de exploracion secundario)
enum PhrasalParticle {
  up('up', 'UP', 'Completitud, incremento, inicio o finalizacion', 'spin up, set up, scale up, bring up'),
  out('out', 'OUT', 'Exteriorizacion, resolucion o agotamiento', 'roll out, figure out, point out, carry out'),
  down('down', 'DOWN', 'Reduccion, parada, registro o calma', 'shut down, wind down, scale down, break down'),
  off('off', 'OFF', 'Desconexion, inicio de evento o cancelacion', 'call off, kick off, roll off, sign off'),
  back('back', 'BACK', 'Retorno, recuperacion o reversion', 'roll back, fall back on, bounce back'),
  inParticle('in', 'IN', 'Inclusion, ingreso o inicio de sesion', 'check in, log in, plug in, opt in'),
  on('on', 'ON', 'Continuidad, activacion o dependencia', 'count on, carry on, switch on, depend on'),
  through('through', 'THROUGH', 'Proceso completo, analisis exhaustivo', 'go through, walk through, follow through'),
  over('over', 'OVER', 'Transferencia, revision o control', 'hand over, take over, look over');

  final String id;
  final String label;
  final String concept;
  final String examplesPreview;

  const PhrasalParticle(this.id, this.label, this.concept, this.examplesPreview);

  static PhrasalParticle fromId(String id) {
    return PhrasalParticle.values.firstWhere(
      (p) => p.id == id,
      orElse: () => PhrasalParticle.up,
    );
  }
}

/// Alternativa formal con explicacion de registro y contexto de uso
class FormalAlternative {
  final String term;
  final String whenToUse;

  const FormalAlternative({
    required this.term,
    required this.whenToUse,
  });

  Map<String, dynamic> toJson() => {
    'term': term,
    'whenToUse': whenToUse,
  };

  factory FormalAlternative.fromJson(Map<String, dynamic> json) => FormalAlternative(
    term: json['term'] as String? ?? '',
    whenToUse: json['whenToUse'] as String? ?? '',
  );
}

/// Significado especifico con registro y transitividad
class PhrasalMeaning {
  final String definition;
  final String register; // 'conversational', 'technical', 'neutral'
  final String transitivity; // 'separable', 'inseparable', 'intransitive'
  final List<String> examples;

  const PhrasalMeaning({
    required this.definition,
    required this.register,
    required this.transitivity,
    required this.examples,
  });

  Map<String, dynamic> toJson() => {
    'definition': definition,
    'register': register,
    'transitivity': transitivity,
    'examples': examples,
  };

  factory PhrasalMeaning.fromJson(Map<String, dynamic> json) => PhrasalMeaning(
    definition: json['definition'] as String? ?? '',
    register: json['register'] as String? ?? 'conversational',
    transitivity: json['transitivity'] as String? ?? 'separable',
    examples: (json['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
  );
}

/// Modelo pedagogico de un Phrasal Verb orientado a contexto profesional
class PhrasalVerb {
  final String id;
  final String verb; // e.g. "roll"
  final PhrasalParticle particle; // e.g. PhrasalParticle.back
  final PhrasalScenario scenario; // e.g. PhrasalScenario.deployIncident
  final List<String> secondaryScenarios;
  final String fullPhrase; // e.g. "roll back"
  final String spanish; // e.g. "revertir / volver a version anterior"
  final String literalMeaning; // e.g. "Rodar hacia atras"
  final String idiomaticMeaning; // e.g. "Volver una release o cambio a un estado anterior"
  final String ipa; // e.g. "/roʊl bæk/" (palabras separadas)
  final String connectedSpeechChunk; // e.g. "rolled_back_the_release" o "roll‿back"
  final String cefrLevel; // 'A1-A2', 'A2-B1', 'B1-B2', 'B2-C1', 'C1+'
  final bool isSeparable; // true si admite objeto en medio: "roll it back"
  final String correctPattern; // e.g. "roll back + noun / roll + noun + back"
  final String incorrectPattern; // e.g. "*roll back it"
  final List<PhrasalMeaning> meanings;
  final List<FormalAlternative> formalAlternatives;
  final List<String> commonErrorsEs;
  final List<String> relatedCollocations;
  final String pronunciationFocus;
  final String dailySyncExample; // Frase tipica en reuniones
  final String workplaceExample; // Frase en documentacion o contexto tecnico
  final String incidentPrompt; // Situacion de produccion o post-mortem
  final String commonMistake; // Error comun de hispanohablantes
  final String usageTip; // Tip tactico de uso nativo

  const PhrasalVerb({
    required this.id,
    required this.verb,
    required this.particle,
    required this.scenario,
    this.secondaryScenarios = const [],
    required this.fullPhrase,
    required this.spanish,
    required this.literalMeaning,
    required this.idiomaticMeaning,
    required this.ipa,
    required this.connectedSpeechChunk,
    required this.cefrLevel,
    required this.isSeparable,
    required this.correctPattern,
    required this.incorrectPattern,
    this.meanings = const [],
    this.formalAlternatives = const [],
    this.commonErrorsEs = const [],
    this.relatedCollocations = const [],
    required this.pronunciationFocus,
    required this.dailySyncExample,
    required this.workplaceExample,
    required this.incidentPrompt,
    required this.commonMistake,
    required this.usageTip,
  });

  String get formalEquivalent => formalAlternatives.isNotEmpty ? formalAlternatives.first.term : '';
}

/// Metricas de progreso y maestria de un Phrasal Verb
class PhrasalVerbMetrics {
  final int meaningRecallCorrect;
  final int meaningRecallTotal;
  final int listeningCorrect;
  final int listeningTotal;
  final int wordOrderCorrect;
  final int wordOrderTotal;
  final int sentenceUsageCorrect;
  final int sentenceUsageTotal;
  final int pronunciationAttempts;
  final double pronunciationAvgScore;
  final int speakingCount;
  final Set<String> recallDates; // Fechas 'YYYY-MM-DD'
  final String? lastMistakeType;
  final DateTime? lastPracticedAt;

  const PhrasalVerbMetrics({
    this.meaningRecallCorrect = 0,
    this.meaningRecallTotal = 0,
    this.listeningCorrect = 0,
    this.listeningTotal = 0,
    this.wordOrderCorrect = 0,
    this.wordOrderTotal = 0,
    this.sentenceUsageCorrect = 0,
    this.sentenceUsageTotal = 0,
    this.pronunciationAttempts = 0,
    this.pronunciationAvgScore = 0.0,
    this.speakingCount = 0,
    this.recallDates = const {},
    this.lastMistakeType,
    this.lastPracticedAt,
  });

  /// 1. Meaning / Definition Recall (20%)
  double get meaningScore {
    if (meaningRecallTotal == 0) return 0.0;
    return (meaningRecallCorrect / meaningRecallTotal).clamp(0.0, 1.0);
  }

  /// 2. Contextual Sentence Usage (25%)
  double get sentenceScore {
    if (sentenceUsageTotal == 0) return 0.0;
    return (sentenceUsageCorrect / sentenceUsageTotal).clamp(0.0, 1.0);
  }

  /// 3. Listening Discrimination (20%)
  double get listeningScore {
    if (listeningTotal == 0) return 0.0;
    return (listeningCorrect / listeningTotal).clamp(0.0, 1.0);
  }

  /// 4. Word Order & Separability (15%)
  double get wordOrderScore {
    if (wordOrderTotal == 0) return 0.0;
    return (wordOrderCorrect / wordOrderTotal).clamp(0.0, 1.0);
  }

  /// 5. Pronunciation & Connected Speech (10%)
  double get pronunciationScore {
    if (pronunciationAttempts == 0) return 0.0;
    return (pronunciationAvgScore / 100.0).clamp(0.0, 1.0);
  }

  /// 6. Oral Speaking Use (10%)
  double get speakingScore {
    return (speakingCount / 2.0).clamp(0.0, 1.0);
  }

  /// Puntuacion de maestria compuesta (0 a 100)
  /// mastery = 20% meaning + 25% contextualUse + 20% listening + 15% wordOrder + 10% pronunciation + 10% speaking
  double get compositeMasteryScore {
    final raw = (0.20 * meaningScore) +
        (0.25 * sentenceScore) +
        (0.20 * listeningScore) +
        (0.15 * wordOrderScore) +
        (0.10 * pronunciationScore) +
        (0.10 * speakingScore);
    return (raw * 100.0).clamp(0.0, 100.0);
  }

  /// Requisitos estrictos de consolidacion (isMastered):
  /// - Puntuacion compuesta >= 75%
  /// - Al menos 2 recuperaciones de significado en dias diferentes (recallDates.length >= 2)
  /// - Al menos 1 listening correcto
  /// - Al menos 1 uso en frase correcto
  /// - Al menos 1 ejercicio de orden/separabilidad correcto
  bool get isMastered {
    if (compositeMasteryScore < 75.0) return false;
    if (recallDates.length < 2) return false;
    if (meaningRecallCorrect < 2) return false;
    if (listeningCorrect < 1) return false;
    if (sentenceUsageCorrect < 1) return false;
    if (wordOrderCorrect < 1) return false;
    return true;
  }

  /// Estado superior: Listo para entrevista / Standup
  /// Requiere estar consolidado Y haber producido el phrasal verb en speaking oral (speakingCount >= 1)
  bool get isInterviewReady => isMastered && speakingCount >= 1;

  Map<String, dynamic> toJson() {
    return {
      'meaningRecallCorrect': meaningRecallCorrect,
      'meaningRecallTotal': meaningRecallTotal,
      'listeningCorrect': listeningCorrect,
      'listeningTotal': listeningTotal,
      'wordOrderCorrect': wordOrderCorrect,
      'wordOrderTotal': wordOrderTotal,
      'sentenceUsageCorrect': sentenceUsageCorrect,
      'sentenceUsageTotal': sentenceUsageTotal,
      'pronunciationAttempts': pronunciationAttempts,
      'pronunciationAvgScore': pronunciationAvgScore,
      'speakingCount': speakingCount,
      'recallDates': recallDates.toList(),
      'lastMistakeType': lastMistakeType,
      'lastPracticedAt': lastPracticedAt?.toIso8601String(),
    };
  }

  factory PhrasalVerbMetrics.fromJson(Map<String, dynamic> json) {
    return PhrasalVerbMetrics(
      meaningRecallCorrect: json['meaningRecallCorrect'] as int? ?? 0,
      meaningRecallTotal: json['meaningRecallTotal'] as int? ?? 0,
      listeningCorrect: json['listeningCorrect'] as int? ?? 0,
      listeningTotal: json['listeningTotal'] as int? ?? 0,
      wordOrderCorrect: json['wordOrderCorrect'] as int? ?? 0,
      wordOrderTotal: json['wordOrderTotal'] as int? ?? 0,
      sentenceUsageCorrect: json['sentenceUsageCorrect'] as int? ?? 0,
      sentenceUsageTotal: json['sentenceUsageTotal'] as int? ?? 0,
      pronunciationAttempts: json['pronunciationAttempts'] as int? ?? 0,
      pronunciationAvgScore: (json['pronunciationAvgScore'] as num?)?.toDouble() ?? 0.0,
      speakingCount: json['speakingCount'] as int? ?? 0,
      recallDates: (json['recallDates'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? const {},
      lastMistakeType: json['lastMistakeType'] as String?,
      lastPracticedAt: json['lastPracticedAt'] != null ? DateTime.tryParse(json['lastPracticedAt'] as String) : null,
    );
  }
}
