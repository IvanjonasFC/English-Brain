import 'grammar_models.dart';

class InteractiveDecisionStep {
  final String question;
  final String yesOutcome;
  final String yesReason;
  final String noOutcome;
  final String noReason;

  const InteractiveDecisionStep({
    required this.question,
    required this.yesOutcome,
    required this.yesReason,
    required this.noOutcome,
    required this.noReason,
  });
}

class SyntaxSlot {
  final String label;
  final List<String> options;

  const SyntaxSlot({
    required this.label,
    required this.options,
  });
}

class InteractiveSyntaxBuilder {
  final String title;
  final List<SyntaxSlot> slots;

  const InteractiveSyntaxBuilder({
    required this.title,
    required this.slots,
  });
}

class TemplatePreset {
  final String tag;
  final String fullSentence;
  final String highlight;

  const TemplatePreset({
    required this.tag,
    required this.fullSentence,
    required this.highlight,
  });
}

class InteractiveProTemplate {
  final String title;
  final String rawTemplate;
  final List<TemplatePreset> presets;
  final String contextUsage;

  const InteractiveProTemplate({
    required this.title,
    required this.rawTemplate,
    required this.presets,
    required this.contextUsage,
  });
}

class CheckpointOption {
  final String text;
  final bool isCorrect;
  final String feedback;

  const CheckpointOption({
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}

class InteractiveCheckpoint {
  final String situation;
  final String question;
  final List<CheckpointOption> options;

  const InteractiveCheckpoint({
    required this.situation,
    required this.question,
    required this.options,
  });
}

class GrammarTopicGuide {
  final String categoryName;
  final List<String> affirmativeFormula;
  final String affirmativeExample;
  final List<String> negativeFormula;
  final String negativeExample;
  final List<String> questionFormula;
  final String questionExample;
  final List<String> keyTriggers;
  final String whenToUse;
  final String whenNotToUse;
  final String spanishTrapTip;

  // Secciones robustas
  final List<String> morphologyAndRules;
  final List<String> mentalModelSteps;
  final List<Map<String, String>> proTemplates;

  // Secciones interactivas avanzadas
  final InteractiveDecisionStep decisionStep;
  final InteractiveSyntaxBuilder syntaxBuilder;
  final List<InteractiveProTemplate> interactiveTemplates;
  final InteractiveCheckpoint checkpoint;

  const GrammarTopicGuide({
    required this.categoryName,
    required this.affirmativeFormula,
    required this.affirmativeExample,
    required this.negativeFormula,
    required this.negativeExample,
    required this.questionFormula,
    required this.questionExample,
    required this.keyTriggers,
    required this.whenToUse,
    required this.whenNotToUse,
    required this.spanishTrapTip,
    required this.morphologyAndRules,
    required this.mentalModelSteps,
    required this.proTemplates,
    required this.decisionStep,
    required this.syntaxBuilder,
    required this.interactiveTemplates,
    required this.checkpoint,
  });
}

/// Generates pedagogical formulas, triggers, rules and interactive systems for any GrammarUnit
GrammarTopicGuide getGrammarTopicGuide(GrammarUnit unit) {
  final id = unit.id.toLowerCase();
  final title = unit.title.toLowerCase();
  final rule = unit.ruleSummary.toLowerCase();

  // 1. Past Simple in STAR Stories
  if (id.contains('unit-1-junior') || (title.contains('past simple') && title.contains('star')) || rule.contains('past simple')) {
    return const GrammarTopicGuide(
      categoryName: 'Tiempos Pasados & Narrativa STAR',
      affirmativeFormula: ['Sujeto', 'Verbo Pasado (-ed / Irreg.)', 'Timestamp / Métrica'],
      affirmativeExample: 'I resolved the race condition yesterday, reducing latency by 30%.',
      negativeFormula: ['Sujeto', "didn't / did not", 'Verbo Base', 'Complemento'],
      negativeExample: "We didn't experience any data loss during the failover window.",
      questionFormula: ['Did', 'Sujeto', 'Verbo Base', '... ?'],
      questionExample: 'Did you benchmark the database before merging the pull request?',
      keyTriggers: ['yesterday', 'last month', 'in 2023', 'ago', 'during the sprint', 'at that time'],
      whenToUse: 'Para hechos técnicos y logros concluidos en un punto temporal específico del pasado con inicio y fin cerrado.',
      whenNotToUse: 'No uses Past Simple si la acción continúa abierta hoy o si describes trayectoria acumulada sin fecha.',
      spanishTrapTip: 'En español solemos decir "Ayer he solucionado...", pero en inglés con fechas concretas NUNCA uses Present Perfect ("have resolved" ❌); usa siempre Past Simple ("resolved" ✅).',
      morphologyAndRules: [
        'Regulares con -ed: añade -ed a la base (deploy -> deployed). Si termina en -e muda, solo añade -d (migrate -> migrated).',
        'Duplicación consonante (CVC): si el verbo termina en Consonante-Vocal-Consonante, duplica la consonante final (stop -> stopped, commit -> committed).',
        'Terminación en consonante + y: sustituye la -y por -ied (retry -> retried, apply -> applied). Si hay vocal antes de la y, solo -ed (deploy -> deployed).',
        'Auxiliar did/didn\'t absorbe el pasado: en preguntas y negativas el verbo principal SIEMPRE va en infinitivo base ("Did you built?" ❌ -> "Did you build?" ✅).',
      ],
      mentalModelSteps: [
        '1. ¿El evento técnico ocurrió en un momento o periodo cerrado del pasado? -> Sí -> Aplica Past Simple.',
        '2. ¿Existe un marcador como "yesterday", "in 2023", "during the migration"? -> Es obligatorio cerrar con Past Simple.',
        '3. ¿Estás en una entrevista STAR? -> Elige un verbo de acción fuerte (refactored, benchmarked, orchestrated) en lugar de "made" o "did".',
      ],
      proTemplates: [
        {
          'title': 'Narrativa STAR de Alto Impacto',
          'template': 'When [incidente técnico], I [verbo de acción fuerte] the [módulo], which [verbo de resultado] by [métrica].',
          'example': 'When our payment gateway throttled, I re-architected the retry queue, which cut failed requests by 45%.',
          'usage': 'Úsala en preguntas de entrevista sobre resolución de conflictos técnicos y resolución de fallos.',
        },
      ],
      decisionStep: InteractiveDecisionStep(
        question: '¿El evento técnico tiene fecha, momento o periodo cerrado en el pasado (ej. yesterday, last month, in 2023)?',
        yesOutcome: 'Usa Past Simple (built, refactored, resolved)',
        yesReason: 'Con marcadores temporales cerrados, el inglés técnico exige obligatoriamente Past Simple. Nunca uses Present Perfect.',
        noOutcome: 'Usa Present Perfect (have built, have maintained)',
        noReason: 'Si estás describiendo tu trayectoria acumulada general sin fecha fija o un estado que continúa activo hoy, usa Present Perfect.',
      ),
      syntaxBuilder: InteractiveSyntaxBuilder(
        title: 'Constructor de Narrativa STAR en Pasado',
        slots: [
          SyntaxSlot(
            label: 'Marcador & Contexto',
            options: [
              'When our Redis cluster crashed last month, I',
              'During the Q3 performance sprint, our team',
              'Yesterday afternoon, I',
            ],
          ),
          SyntaxSlot(
            label: 'Acción Técnica en Pasado',
            options: [
              'rerouted ingress traffic to the standby replica,',
              'refactored the authentication middleware,',
              'isolated the memory leak in the parser worker,',
            ],
          ),
          SyntaxSlot(
            label: 'Impacto & Métrica',
            options: [
              'cutting latency by 35%.',
              'preventing all customer data loss.',
              'saving 4 hours of critical server downtime.',
            ],
          ),
        ],
      ),
      interactiveTemplates: [
        InteractiveProTemplate(
          title: 'Narrativa STAR de Alto Impacto',
          rawTemplate: 'When [incidente], I [acción técnica] the [módulo], which [métrica].',
          contextUsage: 'Ideal para respuestas en entrevistas sobre proyectos y superación de incidencias críticas.',
          presets: [
            TemplatePreset(
              tag: '🗄️ Bases de Datos',
              fullSentence: 'When our primary database timed out, I promoted the standby replica, which restored uptime in 90 seconds.',
              highlight: 'promoted the standby replica',
            ),
            TemplatePreset(
              tag: '☁️ Cloud & DevOps',
              fullSentence: 'When memory usage breached the threshold, I scaled out worker pods, which stabilized cluster latency.',
              highlight: 'scaled out worker pods',
            ),
            TemplatePreset(
              tag: '🔒 Seguridad & Auth',
              fullSentence: 'When expired tokens flooded the ingress, I patched the verification middleware, which cut invalid requests by 99%.',
              highlight: 'patched the verification middleware',
            ),
          ],
        ),
      ],
      checkpoint: InteractiveCheckpoint(
        situation: 'Estás en una entrevista con un Engineering Manager narrando un logro del año pasado:',
        question: '¿Cuál de estas respuestas demuestra precisión sintáctica impecable?',
        options: [
          CheckpointOption(
            text: 'In 2023, I have redesigned our payment microservice to handle peak traffic.',
            isCorrect: false,
            feedback: 'Penalizado: Con una fecha fija como "In 2023", no se debe usar Present Perfect ("have redesigned"). El tiempo correcto es Past Simple.',
          ),
          CheckpointOption(
            text: 'In 2023, I redesigned our payment microservice to handle peak traffic.',
            isCorrect: true,
            feedback: '¡Exacto! "In 2023" es un marcador de tiempo cerrado en el pasado, por lo que exige el verbo en Past Simple ("redesigned").',
          ),
        ],
      ),
    );
  }

  // 2. Daily Tasks & Standups (Present Simple vs Continuous)
  if (id.contains('unit-2-junior') || title.contains('standup') || (title.contains('present simple') && title.contains('continuous'))) {
    return const GrammarTopicGuide(
      categoryName: 'Presente Simple vs Continuo (Standups & Rutinas)',
      affirmativeFormula: ['Sujeto', 'am / is / are', 'Verbo -ing (En curso)', 'vs', 'Verbo Base (Rutina)'],
      affirmativeExample: 'Right now I am investigating the token timeout, though I usually maintain the billing API.',
      negativeFormula: ['Sujeto', 'am/is/are not', 'Verbo -ing', 'vs', "don't / doesn't", 'Verbo Base'],
      negativeExample: "I am not deploying code today because the release pipeline is frozen.",
      questionFormula: ['What are you working on today?', 'vs', 'How do you usually monitor alerts?'],
      questionExample: 'Are you still debugging the connection pool leak in staging?',
      keyTriggers: ['currently', 'today', 'right now', 'this sprint', 'usually', 'every morning', 'always'],
      whenToUse: 'Continuous para lo que estás investigando o ejecutando en el sprint actual; Simple para funciones permanentes y arquitectura viva.',
      whenNotToUse: 'No uses Continuous con verbos de estado ("I am knowing the system" ❌ -> "I know the system" ✅).',
      spanishTrapTip: 'En español decimos "Hoy trabajo en el bug", pero en un standup profesional en inglés se exige Continuous: "Today I am working on the bug" ✅.',
      morphologyAndRules: [
        'Stative Verbs (Verbos de Estado): Verbos cognitivos y de posesión NO admiten forma continua (understand, know, contain, belong, prefer).',
        'Ortografía de -ing: si el verbo termina en -e muda se elimina (write -> writing); si termina en CVC acentuada se duplica (run -> running, begin -> beginning).',
        'Tercera persona en Present Simple: he/she/it añade -s o -es (the worker fetches, the API returns, the server crashes).',
      ],
      mentalModelSteps: [
        '1. ¿Es tu foco temporal inmediato del día o sprint? -> Usa Present Continuous: "Today I am investigating..."',
        '2. ¿Describe cómo funciona tu servicio o qué haces como regla general? -> Usa Present Simple: "The microservice validates tokens."',
        '3. ¿El verbo describe estado mental o pertenencia? -> Forzar siempre Present Simple aunque sea ahora mismo: "I understand the requirement".',
      ],
      proTemplates: [
        {
          'title': 'Actualización de Daily Standup',
          'template': 'Today I am focusing on [tarea activa], while continuing to maintain [servicio o módulo central].',
          'example': 'Today I am focusing on profiling memory usage, while continuing to maintain the billing gateway.',
          'usage': 'Fórmula estándar para reuniones diarias de sincronización (Daily Scrum).',
        },
      ],
      decisionStep: InteractiveDecisionStep(
        question: '¿Estás describiendo lo que estás investigando/desarrollando en este preciso momento o sprint?',
        yesOutcome: 'Usa Present Continuous (am/is/are + -ing)',
        yesReason: 'Para tareas activas en curso: "Today I am investigating the memory leak." Comunica foco transitorio.',
        noOutcome: 'Usa Present Simple (Verbo base / he/she/it con -s)',
        noReason: 'Para responsabilidades permanentes y comportamiento continuo del software: "Our API handles 10,000 requests per second."',
      ),
      syntaxBuilder: InteractiveSyntaxBuilder(
        title: 'Constructor de Actualización para Daily Standup',
        slots: [
          SyntaxSlot(
            label: 'Marcador de Foco',
            options: [
              'Today I am focusing on',
              'Currently, our squad is',
              'Right now I am',
            ],
          ),
          SyntaxSlot(
            label: 'Tarea en Curso (-ing)',
            options: [
              'profiling the memory leak in staging,',
              'refactoring the checkout payment gateway,',
              'investigating intermittent gRPC timeouts,',
            ],
          ),
          SyntaxSlot(
            label: 'Contraste con Rutina',
            options: [
              'while usually I maintain the core auth service.',
              'though we normally ship releases on Thursdays.',
              'before resuming the scheduled database migration.',
            ],
          ),
        ],
      ),
      interactiveTemplates: [
        InteractiveProTemplate(
          title: 'Reporte Rápido de Standup',
          rawTemplate: 'Today I am focusing on [tarea activa], while continuing to [tarea secundaria].',
          contextUsage: 'Sincronización en standups sin rodeos ni ambigüedades.',
          presets: [
            TemplatePreset(
              tag: '⚡ Rendimiento',
              fullSentence: 'Today I am focusing on profiling query latencies, while continuing to review open pull requests.',
              highlight: 'focusing on profiling query latencies',
            ),
            TemplatePreset(
              tag: '🐛 Depuración',
              fullSentence: 'Today I am focusing on isolating the deadlock in staging, while continuing to monitor error budgets.',
              highlight: 'focusing on isolating the deadlock',
            ),
            TemplatePreset(
              tag: '🚀 Despliegue',
              fullSentence: 'Today I am focusing on validating the canary deployment, while continuing to maintain the legacy API.',
              highlight: 'focusing on validating the canary deployment',
            ),
          ],
        ),
      ],
      checkpoint: InteractiveCheckpoint(
        situation: 'Estás en el Daily Standup matutino explicando en qué estás trabajando hoy:',
        question: '¿Qué opción suena nativa y profesional?',
        options: [
          CheckpointOption(
            text: 'Today I work on the authentication bug with the senior engineer.',
            isCorrect: false,
            feedback: 'En español decimos "Hoy trabajo...", pero en un standup profesional en inglés se exige Present Continuous ("Today I am working...").',
          ),
          CheckpointOption(
            text: 'Today I am working on the authentication bug with the senior engineer.',
            isCorrect: true,
            feedback: '¡Perfecto! Para actividades en progreso durante el día o sprint actual, se usa Present Continuous.',
          ),
        ],
      ),
    );
  }

  // 3. Prepositions of Tech (In, On, At)
  if (id.contains('unit-3-junior') || title.contains('preposition') || title.contains('(in, on, at)')) {
    return const GrammarTopicGuide(
      categoryName: 'Preposiciones Técnicas de Lugar y Ejecución',
      affirmativeFormula: ['IN (Contenedor/Memoria/Lenguaje)', 'ON (Plataforma/Servidor/Puerto)', 'AT (Fase/Momento)'],
      affirmativeExample: 'We store tokens in memory, host microservices on AWS, and load configs at startup.',
      negativeFormula: ['Never: "in AWS" ❌', 'Never: "on memory" ❌', 'Never: "in runtime" ❌'],
      negativeExample: 'The service does not crash at compile time, but it throws an exception at runtime.',
      questionFormula: ['Where is the payload stored?', 'On which port does the container listen?'],
      questionExample: 'Does the worker process jobs in parallel on the worker node?',
      keyTriggers: ['in memory', 'in Python', 'in the database', 'on AWS', 'on port 8080', 'at runtime', 'at scale'],
      whenToUse: "'IN' para lo que reside dentro de algo; 'ON' para infraestructura/red/plataformas; 'AT' para momentos y fases del ciclo de vida.",
      whenNotToUse: "No traduzcas el 'en' español por defecto; cada contexto técnico exige su preposición exacta.",
      spanishTrapTip: 'El error más común es decir "in the server" o "in AWS". En inglés siempre se dice "on the server" y "on AWS" ✅.',
      morphologyAndRules: [
        'Regla IN: Dentro de límites físicos, memorias, contenedores o lenguajes de programación ("in Redis", "in Go", "in memory", "in production").',
        'Regla ON: Superficies virtuales, plataformas de nube, interfaces de red y puertos ("on AWS", "on Linux", "on port 443", "on the front-end").',
        'Regla AT: Puntos temporales del ciclo de vida y tasas de escala ("at runtime", "at compile time", "at startup", "at scale").',
      ],
      mentalModelSteps: [
        '1. ¿El dato está contenido dentro de un fichero, memoria o lenguaje? -> "IN" (in JSON, in RAM, in Rust).',
        '2. ¿Se ejecuta sobre una máquina, servidor, nube o puerto? -> "ON" (on the host, on GCP, on port 3000).',
        '3. ¿Es una etapa del ciclo de vida o métrica? -> "AT" (at deployment, at runtime, at 10k RPS).',
      ],
      proTemplates: [
        {
          'title': 'Topología de Despliegue',
          'template': 'Our API is hosted on [plataforma de nube], runs in [lenguaje/entorno], and triggers backups at [momento].',
          'example': 'Our API is hosted on AWS ECS, runs in Go containers, and triggers snapshots at midnight.',
          'usage': 'Documentación de arquitectura técnica y diagramas de bloques.',
        },
      ],
      decisionStep: InteractiveDecisionStep(
        question: '¿El elemento técnico reside dentro de una memoria, lenguaje de programación o contenedor?',
        yesOutcome: 'Usa "IN" (in memory, in Python, in production)',
        yesReason: 'Para almacenamiento interior o lenguajes: "Tokens are stored in memory."',
        noOutcome: 'Usa "ON" para plataformas/puertos, o "AT" para fases del ciclo de vida',
        noReason: 'Servidores y nubes llevan "ON" (on AWS, on Linux). Momentos y fases llevan "AT" (at runtime, at scale).',
      ),
      syntaxBuilder: InteractiveSyntaxBuilder(
        title: 'Constructor de Topología con Preposiciones',
        slots: [
          SyntaxSlot(
            label: 'Almacenamiento (IN)',
            options: [
              'We store JWT tokens in memory,',
              'Our team builds microservices in Go,',
              'Cache indices are persisted in Redis,',
            ],
          ),
          SyntaxSlot(
            label: 'Infraestructura (ON)',
            options: [
              'host our containers on AWS ECS,',
              'listen for ingress traffic on port 443,',
              'execute background daemons on dedicated Linux nodes,',
            ],
          ),
          SyntaxSlot(
            label: 'Ciclo de Vida (AT)',
            options: [
              'and inject secrets at runtime.',
              'while enforcing validation at compile time.',
              'ensuring linear throughput at scale.',
            ],
          ),
        ],
      ),
      interactiveTemplates: [
        InteractiveProTemplate(
          title: 'Arquitectura de Sistema en 1 Frase',
          rawTemplate: 'We run [servicio] in [lenguaje], deploy on [plataforma], and handle [evento] at [fase].',
          contextUsage: 'Explicación clara de stack tecnológico en entrevistas de System Design.',
          presets: [
            TemplatePreset(
              tag: '☁️ Cloud Native',
              fullSentence: 'We run services in Go containers, deploy on Kubernetes, and resolve dependencies at build time.',
              highlight: 'in Go containers, deploy on Kubernetes, at build time',
            ),
            TemplatePreset(
              tag: '⚡ Cache & Red',
              fullSentence: 'We cache payloads in Redis, expose endpoints on port 8080, and measure latency at 50k RPS.',
              highlight: 'in Redis, on port 8080, at 50k RPS',
            ),
          ],
        ),
      ],
      checkpoint: InteractiveCheckpoint(
        situation: 'Explicando la infraestructura de tu backend en una entrevista técnica:',
        question: '¿Cuál es la combinación correcta de preposiciones?',
        options: [
          CheckpointOption(
            text: 'We host our service in AWS, listening in port 443 and parsing logs in runtime.',
            isCorrect: false,
            feedback: 'Error común: En inglés técnico se dice "on AWS", "on port 443" y "at runtime".',
          ),
          CheckpointOption(
            text: 'We host our service on AWS, listening on port 443 and parsing logs at runtime.',
            isCorrect: true,
            feedback: '¡Excelente! Plataformas y puertos exigen "on", mientras que fases del ciclo de vida exigen "at".',
          ),
        ],
      ),
    );
  }

  // 9. Conditionals (Zero, First, Second, Third, Mixed)
  if (title.contains('conditional') || id.contains('unit-9-mid') || id.contains('unit-13-mid') || id.contains('unit-21-senior') || id.contains('unit-27-staff')) {
    final isThird = title.contains('third') || title.contains('post-mortem') || id.contains('unit-13-mid');
    return GrammarTopicGuide(
      categoryName: isThird ? 'Third Conditional (Análisis Contrafáctico en Post-Mortems)' : 'Condicionales Técnicos & Proyecciones de Sistema',
      affirmativeFormula: isThird
          ? ['If + Sujeto + had + V3', 'Sujeto + would have + V3']
          : ['If + Presente Simple', 'Sujeto + will / would + Verbo Base'],
      affirmativeExample: isThird
          ? "If we had cached the query, the primary database wouldn't have crashed."
          : 'If we double the cache TTL, we will reduce database CPU utilization by 40%.',
      negativeFormula: ['Unless (= If not)', 'Sujeto + Verbo', 'Resultado'],
      negativeExample: 'Unless we implement rate limiting, the API will remain vulnerable to DDoS spikes.',
      questionFormula: isThird ? ['Would the server have crashed if we had throttled traffic?'] : ['What would happen if the message broker failed?'],
      questionExample: isThird
          ? 'Would the system have stayed up if we had configured circuit breakers?'
          : 'Would response time degrade if we encrypted payloads at rest?',
      keyTriggers: ['if', 'unless', 'provided that', 'in case of', 'as long as', 'had we known'],
      whenToUse: 'Para formular hipótesis de escalabilidad, justificar decisiones de diseño o analizar fallos evitables en post-mortems.',
      whenNotToUse: 'NUNCA coloques "would" en la cláusula con "if" ("If we would have cached" ❌ -> "If we had cached" ✅).',
      spanishTrapTip: 'En español decimos "Si habríamos cacheado...", pero en inglés técnico la cláusula "if" exige Past Perfect ("had cached") y el resultado "would have crashed" ✅.',
      morphologyAndRules: [
        'Puntuación con coma: Si la cláusula con "If" va primero, lleva coma ("If we scale up, latency drops."). Si va al revés, NO lleva coma ("Latency drops if we scale up.").',
        'Primer Condicional: If + Present Simple, will + Base (predicción técnica realista).',
        'Segundo Condicional: If + Past Simple, would + Base (hipótesis de diseño o arquitectura teórica).',
        'Tercer Condicional: If + had + V3, would have + V3 (lo que no ocurrió en el pasado y su consecuencia imaginada).',
        '"Were to" formal: "If we were to migrate..." añade cortesía y formalidad en RFCs ante comités técnicos.',
      ],
      mentalModelSteps: [
        '1. ¿El escenario es un hecho probable del próximo release? -> Primer Condicional (will).',
        '2. ¿Estás debatiendo una hipótesis arquitectónica abstracta? -> Segundo Condicional (would).',
        '3. ¿Estás analizando qué habría salvado el sistema en un incidente pasado? -> Tercer Condicional (had + would have).',
      ],
      proTemplates: [
        {
          'title': 'Defensa de Trade-Off en RFC',
          'template': 'If we were to adopt [propuesta técnica], we would need to [requisito], ensuring that [beneficio].',
          'example': 'If we were to adopt gRPC, we would need to update our load balancers, ensuring sub-5ms RPC latency.',
          'usage': 'Presentación de propuestas técnicas ante arquitectos y comités de ingeniería.',
        },
      ],
      decisionStep: const InteractiveDecisionStep(
        question: '¿Tu hipótesis es una consecuencia probable del sistema o un escenario teórico/contrafáctico?',
        yesOutcome: 'Primer Condicional: If + Present Simple, will + Verbo',
        yesReason: 'Para predicciones realistas y proyecciones de capacidad: "If we add a cache, latency will drop."',
        noOutcome: 'Segundo o Tercer Condicional: would + Verbo / would have + V3',
        noReason: 'Para escenarios hipotéticos teóricos (would) o análisis contrafácticos en post-mortems (would have).',
      ),
      syntaxBuilder: const InteractiveSyntaxBuilder(
        title: 'Constructor de Hipótesis y Proyecciones Técnicas',
        slots: [
          SyntaxSlot(
            label: 'Cláusula de Condición',
            options: [
              'If we double the Redis cache TTL,',
              'If we shard the database by customer ID,',
              'Unless we implement strict circuit breakers,',
            ],
          ),
          SyntaxSlot(
            label: 'Impacto Técnico Principal',
            options: [
              'we will reduce database CPU utilization by 40%,',
              'we will eliminate primary node write contention,',
              'cascading timeouts will bring down the auth service,',
            ],
          ),
          SyntaxSlot(
            label: 'Garantía Arquitectónica',
            options: [
              'preserving our 99.99% availability SLA.',
              'enabling sub-5ms query response times.',
              'jeopardizing production release stability.',
            ],
          ),
        ],
      ),
      interactiveTemplates: const [
        InteractiveProTemplate(
          title: 'Defensa de Trade-Off en RFC',
          rawTemplate: 'If we were to adopt [propuesta], we would [coste/esfuerzo], but we would achieve [beneficio].',
          contextUsage: 'Ideal para debatir arquitecturas en comités técnicos sin sonar dogmático.',
          presets: [
            TemplatePreset(
              tag: '⚡ Microservicios',
              fullSentence: 'If we were to adopt gRPC, we would update our gateways, but we would achieve sub-5ms serialization latency.',
              highlight: 'were to adopt gRPC ... would achieve sub-5ms',
            ),
            TemplatePreset(
              tag: '🗄️ Sharding & DB',
              fullSentence: 'If we were to shard by tenant ID, we would introduce routing complexity, but we would eliminate write deadlocks.',
              highlight: 'were to shard ... would eliminate write deadlocks',
            ),
          ],
        ),
      ],
      checkpoint: const InteractiveCheckpoint(
        situation: 'En una reunión de System Design con el Staff Architect debatiendo escalabilidad:',
        question: '¿Cuál de las siguientes oraciones cumple la regla condicional formal?',
        options: [
          CheckpointOption(
            text: 'If we will add a cache, the database will be much faster.',
            isCorrect: false,
            feedback: 'Error frecuente: En la cláusula introducida por "If" NUNCA se usa "will". Debe ser: "If we add a cache...".',
          ),
          CheckpointOption(
            text: 'If we add a cache, the database will be much faster.',
            isCorrect: true,
            feedback: '¡Impecable! La cláusula "If" rige Present Simple ("add") y la consecuencia lleva "will be".',
          ),
        ],
      ),
    );
  }

  // Fallback robusto y dinámico para todas las demás unidades
  final sampleRight = unit.comparisonExamples.isNotEmpty
      ? unit.comparisonExamples.first['right'] ?? 'Follow the recommended architectural pattern.'
      : 'Apply the grammatical rule in technical conversations.';
  final sampleWrong = unit.comparisonExamples.isNotEmpty
      ? unit.comparisonExamples.first['wrong'] ?? 'Avoid direct translation from Spanish.'
      : 'Avoid direct literal translations.';
  final sampleTip = unit.comparisonExamples.isNotEmpty
      ? unit.comparisonExamples.first['tip'] ?? 'Aplica la estructura estándar en inglés técnico.'
      : 'Aplica la estructura estándar en inglés técnico.';

  return GrammarTopicGuide(
    categoryName: 'Guía Pedagógica y Uso Práctico',
    affirmativeFormula: ['[Estructura Recomendada]', '+', '[Componente Técnico]', '+', '[Resultado Medible]'],
    affirmativeExample: sampleRight,
    negativeFormula: ['[Forma Incorrecta]', 'vs', '[Corrección de Alto Impacto]'],
    negativeExample: sampleWrong,
    questionFormula: ['How do you formulate this in technical interviews?'],
    questionExample: unit.questions.isNotEmpty
        ? unit.questions.first.audioText
        : 'Can you explain the trade-offs of this approach?',
    keyTriggers: ['temporal clues', 'syntax markers', 'context clues', 'signal words'],
    whenToUse: unit.ruleSummary,
    whenNotToUse: sampleTip,
    spanishTrapTip: 'Presta atención a las diferencias estructurales con el español: $sampleTip',
    morphologyAndRules: [
      'Regla central: ${unit.ruleSummary}',
      'Cuidado con la concordancia: revisa siempre que los verbos auxiliares concuerden con el sujeto técnico de la oración.',
      'Claridad y precisión: prioriza estructuras activas y términos inequívocos en entornos de producción y entrevistas.',
    ],
    mentalModelSteps: [
      '1. Analiza el objetivo comunicativo: ¿estás reportando un bug, defendiendo una arquitectura o explicando un logro?',
      '2. Identifica los marcadores de contexto o tiempo en la pregunta o situación.',
      '3. Aplica la estructura verbal correspondiente asegurándote de no traducir literalmente modismos del español.',
    ],
    proTemplates: [
      {
        'title': 'Aplicación Profesional en Entrevistas',
        'template': 'In technical conversations, use: "$sampleRight"',
        'example': sampleRight,
        'usage': 'Útil para respuestas claras y contundentes con entrevistadores internacionales.',
      },
    ],
    decisionStep: InteractiveDecisionStep(
      question: '¿Estás aplicando la formulación estándar recomendada para este contexto?',
      yesOutcome: 'Aplica: "$sampleRight"',
      yesReason: unit.ruleSummary,
      noOutcome: 'Evita: "$sampleWrong"',
      noReason: sampleTip,
    ),
    syntaxBuilder: InteractiveSyntaxBuilder(
      title: 'Constructor Sintáctico de la Unidad',
      slots: [
        const SyntaxSlot(
          label: 'Contexto / Sujeto',
          options: [
            'In production environments, our team',
            'When evaluating distributed system trade-offs, we',
            'To ensure high availability, engineers',
          ],
        ),
        SyntaxSlot(
          label: 'Estructura Clave',
          options: [
            sampleRight.split(',').first,
            'always adheres to the established architectural pattern,',
            'prioritizes fault tolerance over raw speed,',
          ],
        ),
        const SyntaxSlot(
          label: 'Resultado',
          options: [
            'guaranteeing compliance with technical SLAs.',
            'minimizing potential incident downtime.',
            'ensuring clear communication across global squads.',
          ],
        ),
      ],
    ),
    interactiveTemplates: [
      InteractiveProTemplate(
        title: 'Plantilla de Aplicación Profesional',
        rawTemplate: 'In technical discussions: "$sampleRight"',
        contextUsage: 'Aplicación de la regla en reuniones y entrevistas.',
        presets: [
          TemplatePreset(
            tag: '⚡ Estándar',
            fullSentence: sampleRight,
            highlight: sampleRight,
          ),
          if (unit.questions.isNotEmpty)
            TemplatePreset(
              tag: '💼 Pregunta Clave',
              fullSentence: unit.questions.first.audioText,
              highlight: unit.questions.first.audioText,
            ),
        ],
      ),
    ],
    checkpoint: InteractiveCheckpoint(
      situation: 'En una conversación profesional donde debes aplicar la regla de esta unidad:',
      question: '¿Cuál de las siguientes opciones es la correcta?',
      options: [
        CheckpointOption(
          text: sampleWrong,
          isCorrect: false,
          feedback: 'Penalizado: $sampleTip',
        ),
        CheckpointOption(
          text: sampleRight,
          isCorrect: true,
          feedback: '¡Correcto! ${unit.ruleSummary}',
        ),
      ],
    ),
  );
}
