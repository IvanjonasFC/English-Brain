/// Structured content seeds built on the shared pedagogy contracts.
/// These expand the app beyond flat interview categories toward general
/// foundations: irregular verbs, technical vocabulary, workplace/HR phrases,
/// debugging language, STAR storytelling and functional grammar routes.
///
/// Sourced/adapted from open lists (awesome-english, LeaTeX) as seed
/// material — normalized here, not shown as raw external lists.
library;

import 'taxonomy.dart';
import 'contracts.dart';

class ContentSeeds {
  ContentSeeds._();

  // ---------------------------------------------------------------------------
  // VOCABULARY PACKS
  // ---------------------------------------------------------------------------

  static const VocabPack irregularVerbsEssentials = VocabPack(
    id: 'vocab_irregular_verbs_essentials',
    title: 'Irregular Verbs — Essentials',
    description: 'The irregular verbs you actually use in interviews and standups.',
    family: VocabFamily.irregularVerbs,
    band: DifficultyBand.a2b1,
    objectiveId: 'daily_english_foundations',
    items: [
      VocabEntry(term: 'build — built — built', ipa: '/bɪld/', definition: 'to create or construct something', exampleSentence: 'I built a CI pipeline that cut deploys in half.', spanishHint: 'construir', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'write — wrote — written', ipa: '/raɪt/', definition: 'to compose code or text', exampleSentence: "I've written unit tests for the auth module.", spanishHint: 'escribir', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'run — ran — run', ipa: '/rʌn/', definition: 'to execute a process', exampleSentence: 'We ran the migration on staging first.', spanishHint: 'ejecutar', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'break — broke — broken', ipa: '/breɪk/', definition: 'to stop working', exampleSentence: 'The release broke the payment flow.', spanishHint: 'romper', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'find — found — found', ipa: '/faɪnd/', definition: 'to discover', exampleSentence: 'I found the root cause in the logs.', spanishHint: 'encontrar', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'take — took — taken', ipa: '/teɪk/', definition: 'to require / to accept', exampleSentence: 'The refactor took two sprints.', spanishHint: 'tomar / llevar', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'lead — led — led', ipa: '/liːd/', definition: 'to guide a team or effort', exampleSentence: 'I led the migration to Kubernetes.', spanishHint: 'liderar', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'grow — grew — grown', ipa: '/ɡroʊ/', definition: 'to increase', exampleSentence: 'We grew throughput by 40%.', spanishHint: 'crecer', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'choose — chose — chosen', ipa: '/tʃuːz/', definition: 'to select', exampleSentence: 'We chose Postgres over Mongo for consistency.', spanishHint: 'elegir', kind: VocabItemKind.irregularVerb),
      VocabEntry(term: 'deal — dealt — dealt', ipa: '/diːl/', definition: 'to handle a situation', exampleSentence: 'I dealt with a production incident calmly.', spanishHint: 'lidiar / tratar', kind: VocabItemKind.irregularVerb),
    ],
  );

  static const VocabPack technicalVerbsForDevelopers = VocabPack(
    id: 'vocab_technical_verbs',
    title: 'Technical Verbs for Developers',
    description: 'Precise verbs to describe what you did to a system.',
    family: VocabFamily.technicalTerms,
    band: DifficultyBand.b1b2,
    objectiveId: 'explain_an_api',
    items: [
      VocabEntry(term: 'refactor', ipa: '/riːˈfæktər/', definition: 'to restructure code without changing behavior', exampleSentence: 'I refactored the service into smaller modules.', spanishHint: 'refactorizar', partOfSpeech: 'verb', relatedTerms: ['restructure', 'clean up']),
      VocabEntry(term: 'deploy', ipa: '/dɪˈplɔɪ/', definition: 'to release software to an environment', exampleSentence: 'We deploy to production every Friday.', spanishHint: 'desplegar', partOfSpeech: 'verb', relatedTerms: ['ship', 'release', 'roll out']),
      VocabEntry(term: 'debug', ipa: '/diːˈbʌɡ/', definition: 'to find and fix defects', exampleSentence: 'I debugged the race condition with logs.', spanishHint: 'depurar', partOfSpeech: 'verb', relatedTerms: ['troubleshoot', 'trace']),
      VocabEntry(term: 'scale', ipa: '/skeɪl/', definition: 'to handle more load', exampleSentence: 'We scaled the workers horizontally.', spanishHint: 'escalar', partOfSpeech: 'verb', relatedTerms: ['scale out', 'scale up']),
      VocabEntry(term: 'roll back', ipa: '/roʊl bæk/', definition: 'to revert to a previous version', exampleSentence: 'We rolled back the release after the spike.', spanishHint: 'revertir', kind: VocabItemKind.phrasalVerb, relatedTerms: ['revert', 'undo']),
      VocabEntry(term: 'spin up', ipa: '/spɪn ʌp/', definition: 'to start a new instance/service', exampleSentence: 'I spun up a staging environment to reproduce it.', spanishHint: 'levantar / arrancar', kind: VocabItemKind.phrasalVerb, relatedTerms: ['provision', 'bootstrap']),
    ],
  );

  static const VocabPack hrInterviewEssentials = VocabPack(
    id: 'vocab_hr_interview_essentials',
    title: 'HR Interview Essentials',
    description: 'Phrases to sound structured and confident in HR rounds.',
    family: VocabFamily.interviewPhrases,
    band: DifficultyBand.b1b2,
    objectiveId: 'tell_me_about_yourself',
    items: [
      VocabEntry(term: 'My background is in…', ipa: '', definition: 'opener to summarize your profile', exampleSentence: 'My background is in backend development and DevOps.', spanishHint: 'Mi experiencia es en…', kind: VocabItemKind.phrase),
      VocabEntry(term: 'I was responsible for…', ipa: '', definition: 'state your ownership', exampleSentence: 'I was responsible for the payments service.', spanishHint: 'Yo era responsable de…', kind: VocabItemKind.phrase),
      VocabEntry(term: 'One of my strengths is…', ipa: '', definition: 'introduce a strength', exampleSentence: 'One of my strengths is staying calm under pressure.', spanishHint: 'Una de mis fortalezas es…', kind: VocabItemKind.phrase),
      VocabEntry(term: 'A challenge I faced was…', ipa: '', definition: 'open a STAR story', exampleSentence: 'A challenge I faced was a data loss incident.', spanishHint: 'Un reto al que me enfrenté fue…', kind: VocabItemKind.phrase),
      VocabEntry(term: 'As a result,…', ipa: '', definition: 'state the outcome (STAR result)', exampleSentence: 'As a result, we reduced downtime by 30%.', spanishHint: 'Como resultado,…', kind: VocabItemKind.phrase),
    ],
  );

  static const VocabPack debuggingLanguage = VocabPack(
    id: 'vocab_debugging_language',
    title: 'Debugging Language',
    description: 'Talk through an incident like a senior engineer.',
    family: VocabFamily.workplacePhrases,
    band: DifficultyBand.b2c1,
    objectiveId: 'describe_a_bug',
    items: [
      VocabEntry(term: 'root cause', ipa: '/ruːt kɔːz/', definition: 'the underlying reason for a problem', exampleSentence: 'The root cause was a missing index.', spanishHint: 'causa raíz', kind: VocabItemKind.collocation),
      VocabEntry(term: 'reproduce the issue', ipa: '', definition: 'to make a bug happen again on demand', exampleSentence: 'I could reproduce the issue only under load.', spanishHint: 'reproducir el problema', kind: VocabItemKind.collocation),
      VocabEntry(term: 'narrow it down', ipa: '', definition: 'to isolate the cause', exampleSentence: 'I narrowed it down to the caching layer.', spanishHint: 'acotarlo', kind: VocabItemKind.phrasalVerb),
      VocabEntry(term: 'edge case', ipa: '/edʒ keɪs/', definition: 'a rare boundary condition', exampleSentence: 'It only failed on an edge case with empty input.', spanishHint: 'caso límite', kind: VocabItemKind.collocation),
      VocabEntry(term: 'roll out a fix', ipa: '', definition: 'to release a correction', exampleSentence: 'We rolled out a fix within the hour.', spanishHint: 'desplegar un arreglo', kind: VocabItemKind.collocation),
    ],
  );

  static const VocabPack dailyEnglishFoundations = VocabPack(
    id: 'vocab_daily_english_foundations',
    title: 'Daily English Foundations',
    description: 'Everyday connectors and phrases beyond IT jargon.',
    family: VocabFamily.workplacePhrases,
    band: DifficultyBand.a2b1,
    objectiveId: 'daily_english_foundations',
    items: [
      VocabEntry(term: 'by the way', ipa: '', definition: 'to add a side comment', exampleSentence: 'By the way, I updated the docs.', spanishHint: 'por cierto', kind: VocabItemKind.phrase),
      VocabEntry(term: 'as far as I know', ipa: '', definition: 'to hedge a statement', exampleSentence: 'As far as I know, the API is stable.', spanishHint: 'que yo sepa', kind: VocabItemKind.phrase),
      VocabEntry(term: 'let me get back to you', ipa: '', definition: 'to defer an answer politely', exampleSentence: 'Let me get back to you on the estimate.', spanishHint: 'te confirmo luego', kind: VocabItemKind.phrase),
      VocabEntry(term: 'make sense', ipa: '', definition: 'to be understandable/reasonable', exampleSentence: 'Does that make sense?', spanishHint: 'tener sentido', kind: VocabItemKind.collocation),
    ],
  );

  static const List<VocabPack> vocabPacks = [
    irregularVerbsEssentials,
    technicalVerbsForDevelopers,
    hrInterviewEssentials,
    debuggingLanguage,
    dailyEnglishFoundations,
  ];

  // ---------------------------------------------------------------------------
  // GRAMMAR — FUNCTIONAL ROUTES
  // ---------------------------------------------------------------------------

  static const GrammarUnitDef pastSimpleForProjects = GrammarUnitDef(
    id: 'grammar_talking_about_the_past',
    title: 'Talking about the past (Past Simple)',
    objectiveId: 'past_simple_projects',
    band: DifficultyBand.a2b1,
    guidebook:
        'Use the Past Simple for finished actions with a clear time: what you built, fixed or shipped. '
        'Regular verbs add -ed (deployed, refactored); irregular verbs change form (build→built, write→wrote).',
    keyContrasts: [
      'Past Simple (finished): "I built the API last quarter."',
      'Present Perfect (experience, no time): "I have built several APIs."',
    ],
    commonEsMistakes: [
      'Using Present Perfect for a finished, dated action: ✗ "I have fixed it yesterday" → ✓ "I fixed it yesterday".',
      'Forgetting the irregular form: ✗ "I builded" → ✓ "I built".',
      'Adding -ed to modal-like structures: ✗ "I did built" → ✓ "I built" / "I did build" (emphasis).',
    ],
    drills: [
      {'type': 'fill_blank', 'prompt': 'Last sprint I ___ (fix) the memory leak.', 'answer': 'fixed'},
      {'type': 'fill_blank', 'prompt': 'We ___ (choose) Postgres for consistency.', 'answer': 'chose'},
      {'type': 'multiple_choice', 'prompt': 'Yesterday I ___ the release.', 'options': ['have shipped', 'shipped', 'ship'], 'answer': 'shipped'},
    ],
    miniSpeakingPrompts: [
      'Describe one thing you built or fixed last month using the Past Simple.',
    ],
  );

  static const GrammarUnitDef explainingCauseAndResult = GrammarUnitDef(
    id: 'grammar_explaining_cause_result',
    title: 'Explaining causes and results',
    objectiveId: 'explaining_cause_result',
    band: DifficultyBand.b2c1,
    guidebook:
        'Link problems to outcomes with connectors: because / since (cause), so / therefore / as a result (result), '
        'which led to (consequence). This is the backbone of a strong incident explanation.',
    keyContrasts: [
      'Cause: "The index was missing, so queries were slow."',
      'Result: "Queries were slow because the index was missing."',
    ],
    commonEsMistakes: [
      'Using "because of" + clause: ✗ "because of it was slow" → ✓ "because it was slow" / "because of the slow query".',
      'Literal "for that reason" overuse → prefer "so" or "as a result".',
    ],
    drills: [
      {'type': 'reorder', 'prompt': 'missing / the / was / index / , / so / slow / it / was', 'answer': 'The index was missing, so it was slow'},
      {'type': 'fill_blank', 'prompt': 'We added caching, ___ a result latency dropped.', 'answer': 'as'},
    ],
    miniSpeakingPrompts: [
      'Explain a recent incident: what caused it and what the result was.',
    ],
  );

  static const GrammarUnitDef describingExperience = GrammarUnitDef(
    id: 'grammar_describing_experience',
    title: 'Describing experience & projects (Present Perfect)',
    objectiveId: 'describing_experience',
    band: DifficultyBand.b1b2,
    guidebook:
        'Use Present Perfect (have/has + past participle) to describe career experience and lifetime skills without a specific date: '
        '"I have built microservices with Go". When specifying WHEN, switch immediately to Past Simple: "I built it in 2024".',
    keyContrasts: [
      'Experience (unspecified time): "I have worked with distributed databases."',
      'Finished time: "I worked at Google from 2021 to 2023."',
      'Duration up to now: "I have been using Flutter for 3 years."',
    ],
    commonEsMistakes: [
      'Using present tense for ongoing duration: ✗ "I work here since 2 years" → ✓ "I have worked here for 2 years".',
      'Using since with duration: ✗ "since 3 months" → ✓ "for 3 months" / "since March".',
    ],
    drills: [
      {
        'type': 'multiple_choice',
        'prompt': 'I ___ in tech for five years now.',
        'options': ['have worked', 'work', 'am working', 'worked'],
        'answer': 'have worked',
      },
      {
        'type': 'fill_blank',
        'prompt': 'She has been a tech lead ___ 2022.',
        'options': ['since', 'for', 'during', 'from'],
        'answer': 'since',
      },
      {
        'type': 'fill_blank',
        'prompt': 'We ___ (migrate) three databases so far this quarter.',
        'options': ['have migrated', 'migrated', 'migrate', 'are migrating'],
        'answer': 'have migrated',
      },
    ],
    miniSpeakingPrompts: [
      'Tell me about two key technologies you have mastered and one project you built with them.',
    ],
  );

  static const GrammarUnitDef hypotheticalTroubleshooting = GrammarUnitDef(
    id: 'grammar_hypothetical_troubleshooting',
    title: 'Hypothetical Troubleshooting & Conditionals',
    objectiveId: 'hypothetical_troubleshooting',
    band: DifficultyBand.b2c1,
    guidebook:
        'Conditionals express cause-and-effect in system architectures: '
        'First conditional (real future): "If CPU spikes, we will scale horizontally." '
        'Second conditional (hypothetical now): "If we redesigned this, we would use gRPC." '
        'Third conditional (past post-mortem): "If we had set up alerts, we would have caught it earlier."',
    keyContrasts: [
      'Post-mortem (past): "If we had cached it, it wouldn\'t have crashed."',
      'Architecture trade-off (present): "If we used Kafka, we would add broker complexity."',
    ],
    commonEsMistakes: [
      'Using "would" in the if-clause: ✗ "If we would have alerts" → ✓ "If we had alerts".',
      'Confusing unless and if not: "Unless the cache fails" = "If the cache does not fail".',
    ],
    drills: [
      {
        'type': 'multiple_choice',
        'prompt': 'If we ___ alerts configured, we would have detected the memory leak in staging.',
        'options': ['had had', 'would have had', 'have had', 'had'],
        'answer': 'had had',
      },
      {
        'type': 'fill_blank',
        'prompt': 'If the database goes down, the standby replica ___ take over automatically.',
        'options': ['will', 'would', 'would have', 'had'],
        'answer': 'will',
      },
    ],
    miniSpeakingPrompts: [
      'Describe a hypothetical post-mortem: what would you have done differently in your last outage?',
    ],
  );

  static const List<GrammarUnitDef> grammarUnits = [
    pastSimpleForProjects,
    explainingCauseAndResult,
    describingExperience,
    hypotheticalTroubleshooting,
  ];

  static GrammarUnitDef? getGrammarUnitById(String id) {
    for (final u in grammarUnits) {
      if (u.id == id) return u;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // SPEAKING & INTERVIEW PACKS (From A1-B1 basics to B2-C1 STAR Executive)
  // ---------------------------------------------------------------------------

  // >>> GENERATED interviewPacks — do not edit by hand (tools/sync_offline_seeds.py)
  static const List<InterviewPack> interviewPacks = [
    InterviewPack(
      id: 'interview_foundations_a1',
      scenario: LearningScenario.foundations,
      subtopic: 'Presentación Personal & Rutinas (A1-A2)',
      objectiveId: 'personal_intro_a1',
      band: DifficultyBand.a2b1,
      mode: PracticeMode.guided,
      questionIds: [1, 2, 5],
      skills: ['present simple', 'basic vocabulary', 'self-introduction'],
      estMinutes: 6,
      feedbackType: 'Pronunciación básica + fluidez inicial',
      domain: 'general',
    ),
    InterviewPack(
      id: 'general_small_talk',
      scenario: LearningScenario.dailyEnglish,
      subtopic: 'Small Talk & Socializar (A2-B1)',
      objectiveId: 'small_talk_social',
      band: DifficultyBand.a2b1,
      mode: PracticeMode.guided,
      questionIds: [146, 147, 106],
      skills: ['greetings', 'follow-up questions', 'small talk'],
      estMinutes: 6,
      feedbackType: 'Naturalidad + preguntas de seguimiento',
      domain: 'general',
    ),
    InterviewPack(
      id: 'interview_workplace_b1',
      scenario: LearningScenario.workplaceEnglish,
      subtopic: 'Describir mi Día a Día (A2-B1)',
      objectiveId: 'describe_daily_work',
      band: DifficultyBand.a2b1,
      mode: PracticeMode.guided,
      questionIds: [148, 149, 150],
      skills: ['daily duties', 'past simple', 'work vocabulary'],
      estMinutes: 8,
      feedbackType: 'Vocabulario cotidiano + estructura clara',
      domain: 'general',
    ),
    InterviewPack(
      id: 'interview_teamwork_b1',
      scenario: LearningScenario.teamwork,
      subtopic: 'Reuniones & Opiniones (B1-B2)',
      objectiveId: 'teamwork_collaboration',
      band: DifficultyBand.b1b2,
      mode: PracticeMode.guided,
      questionIds: [106, 107, 108],
      skills: ['opinions', 'active listening', 'collaboration'],
      estMinutes: 8,
      feedbackType: 'Conectores conversacionales + claridad',
      domain: 'general',
    ),
    InterviewPack(
      id: 'general_travel_situations',
      scenario: LearningScenario.dailyEnglish,
      subtopic: 'Viajes & Situaciones Reales (B1-B2)',
      objectiveId: 'travel_real_situations',
      band: DifficultyBand.b1b2,
      mode: PracticeMode.guided,
      questionIds: [6, 109, 110],
      skills: ['polite requests', 'problem solving', 'transactional English'],
      estMinutes: 8,
      feedbackType: 'Cortesía + resolución de situaciones',
      domain: 'general',
    ),
    InterviewPack(
      id: 'general_storytelling',
      scenario: LearningScenario.dailyEnglish,
      subtopic: 'Contar Experiencias & Historias (B2-C1)',
      objectiveId: 'everyday_storytelling',
      band: DifficultyBand.b2c1,
      mode: PracticeMode.guided,
      questionIds: [4, 136, 137],
      skills: ['narrative tenses', 'descriptive adjectives', 'keeping attention'],
      estMinutes: 10,
      feedbackType: 'Fluidez narrativa + tiempos del pasado',
      domain: 'general',
    ),
    InterviewPack(
      id: 'general_presenting',
      scenario: LearningScenario.workplaceEnglish,
      subtopic: 'Presentar & Convencer (C1)',
      objectiveId: 'presenting_persuading',
      band: DifficultyBand.c1,
      mode: PracticeMode.guided,
      questionIds: [138, 139, 140],
      skills: ['signposting', 'persuasion', 'handling objections'],
      estMinutes: 12,
      feedbackType: 'Estructura ejecutiva + persuasión',
      domain: 'general',
    ),
    InterviewPack(
      id: 'interview_star_basics',
      scenario: LearningScenario.hrInterview,
      subtopic: 'STAR Storytelling & Trayectoria',
      objectiveId: 'tell_me_about_yourself',
      band: DifficultyBand.b1b2,
      mode: PracticeMode.guided,
      questionIds: [3, 4, 6],
      skills: ['structure', 'fluency', 'past tenses'],
      estMinutes: 8,
      feedbackType: 'STAR structure + grammar',
      domain: 'tech',
    ),
    InterviewPack(
      id: 'interview_debugging_walkthrough',
      scenario: LearningScenario.debugging,
      subtopic: 'Incident Walkthrough & Debugging',
      objectiveId: 'describe_a_bug',
      band: DifficultyBand.b2c1,
      mode: PracticeMode.mock,
      questionIds: [56, 57, 58],
      skills: ['cause/result', 'technical vocabulary', 'pronunciation'],
      estMinutes: 10,
      feedbackType: 'STAR + pronunciation + vocabulary',
      domain: 'tech',
    ),
    InterviewPack(
      id: 'interview_system_design',
      scenario: LearningScenario.systemsDesign,
      subtopic: 'Architecture Trade-offs & Scalability',
      objectiveId: 'defend_tradeoffs',
      band: DifficultyBand.b2c1,
      mode: PracticeMode.guided,
      questionIds: [156, 157, 158],
      skills: ['trade-off evaluation', 'scalability', 'conditional clauses'],
      estMinutes: 12,
      feedbackType: 'Clarity + architecture terminology',
      domain: 'tech',
    ),
    InterviewPack(
      id: 'interview_behavioral_conflict',
      scenario: LearningScenario.hrInterview,
      subtopic: 'Handling Disagreements & Conflict',
      objectiveId: 'resolve_conflict',
      band: DifficultyBand.b1b2,
      mode: PracticeMode.mock,
      questionIds: [4, 106, 111],
      skills: ['diplomatic phrasing', 'STAR resolution', 'soft skills'],
      estMinutes: 9,
      feedbackType: 'STAR + diplomatic tone',
      domain: 'tech',
    ),
  ];
  // <<< GENERATED interviewPacks

  static InterviewPack? getInterviewPackById(String id) {
    for (final p in interviewPacks) {
      if (p.id == id) return p;
    }
    return null;
  }
}
