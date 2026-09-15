/// Content model + local seed for the Comprehension (Reading & Listening) tab.
///
/// One PIECE is consumed in two modes: Reading (text shown, ES translation on
/// demand) or Listening (same text spoken via TTS, hidden until questions).
/// Questions come in two kinds:
///   - mcq:    multiple choice, checked locally.
///   - spoken: an open question answered by voice; the runner records audio,
///             sends it to /pronunciation/check (STT + phonetic score) and
///             verifies keyword coverage on the transcription.
/// Wrong / weak answers are ingested into the FSRS deck by the runner.
library;

enum CompMode { reading, listening }

enum CompQType { mcq, spoken }

class CompQuestion {
  final CompQType type;
  final String prompt;
  // MCQ
  final List<String> options;
  final int correctIndex;
  // Spoken
  final List<String> keywords; // lower-case ideas expected in the answer
  final String modelAnswer;
  final String explanationEs;

  const CompQuestion({
    this.type = CompQType.mcq,
    required this.prompt,
    this.options = const [],
    this.correctIndex = 0,
    this.keywords = const [],
    this.modelAnswer = '',
    required this.explanationEs,
  });

  factory CompQuestion.fromJson(Map<String, dynamic> j) => CompQuestion(
        type: (j['type'] == 'spoken') ? CompQType.spoken : CompQType.mcq,
        prompt: (j['prompt'] ?? '') as String,
        options: (j['options'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        correctIndex: (j['correctIndex'] as num?)?.toInt() ?? 0,
        keywords: (j['keywords'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        modelAnswer: (j['modelAnswer'] ?? '') as String,
        explanationEs: (j['explanationEs'] ?? '') as String,
      );
}

class ComprehensionPiece {
  final String id;
  final String domain; // 'general' | 'tech'
  final String band; // 'A1-A2' | 'B1' | 'B2' | 'B2-C1' | 'C1'
  final String category; // display category (ES)
  final String title;
  final String body; // English text (shown in reading / spoken in listening)
  final String bodyEs; // Spanish translation, revealed on demand
  final int estMinutes;
  final List<CompQuestion> questions;

  const ComprehensionPiece({
    required this.id,
    required this.domain,
    required this.band,
    required this.category,
    required this.title,
    required this.body,
    required this.bodyEs,
    required this.estMinutes,
    required this.questions,
  });

  factory ComprehensionPiece.fromJson(Map<String, dynamic> j) => ComprehensionPiece(
        id: (j['id'] ?? '') as String,
        domain: (j['domain'] ?? 'general') as String,
        band: (j['band'] ?? 'B1') as String,
        category: (j['category'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        body: (j['body'] ?? '') as String,
        bodyEs: (j['bodyEs'] ?? '') as String,
        estMinutes: (j['estMinutes'] as num?)?.toInt() ?? 4,
        questions: (j['questions'] as List?)
                ?.map((e) => CompQuestion.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  int get wordCount => body.trim().split(RegExp(r'\s+')).length;
  bool get isGeneral => domain == 'general';
  int get spokenCount => questions.where((q) => q.type == CompQType.spoken).length;
}

const List<ComprehensionPiece> allComprehensionPieces = [
  // ═══════════════════════════════ GENERAL ═══════════════════════════════
  ComprehensionPiece(
    id: 'gen_a2b1_flatmate',
    domain: 'general',
    band: 'A1-A2',
    category: 'Vida diaria',
    title: 'A note for a new flatmate',
    estMinutes: 4,
    body: '''Hi Marco, welcome to the flat! A few things to make your first week easier. The recycling is collected on Tuesday mornings, so please take the blue bin out on Monday night. The heating is on a timer: it comes on at seven and goes off at eleven, but you can change it with the dial in the hallway if you are cold. The wifi password is on the fridge. One favour: the walls are thin, so try to keep the music down after eleven — our neighbour works early shifts and she has already complained twice. If anything breaks, message me before you call the landlord; last time he charged us for a repair we could have done ourselves. Make yourself at home!''',
    bodyEs: '''Hola Marco, ¡bienvenido al piso! Unas cosas para que tu primera semana sea más fácil. El reciclaje se recoge los martes por la mañana, así que saca el cubo azul el lunes por la noche. La calefacción va con temporizador: se enciende a las siete y se apaga a las once, pero puedes cambiarla con el dial del pasillo si tienes frío. La contraseña del wifi está en la nevera. Un favor: las paredes son finas, así que intenta bajar la música después de las once — nuestra vecina trabaja en turnos de mañana y ya se ha quejado dos veces. Si algo se rompe, escríbeme antes de llamar al casero; la última vez nos cobró por un arreglo que podríamos haber hecho nosotros mismos. ¡Estás en tu casa!''',
    questions: [
      CompQuestion(prompt: 'When should the blue bin go out?', options: ['Tuesday morning', 'Monday night', 'Any day'], correctIndex: 1, explanationEs: 'La recogida es el martes, pero pide sacarlo "Monday night" (la noche anterior).'),
      CompQuestion(prompt: 'Why does the writer ask about the music?', options: ['They dislike music', 'A neighbour on early shifts has complained', 'It breaks the wifi'], correctIndex: 1, explanationEs: 'Inferencia: "the walls are thin... our neighbour works early shifts and she has already complained twice".'),
      CompQuestion(prompt: 'What does "make yourself at home" suggest here?', options: ['Feel free and comfortable', 'Do repairs yourself', 'Stay only one week'], correctIndex: 0, explanationEs: 'Es una expresión de bienvenida: siéntete cómodo, como en tu casa.'),
      CompQuestion(type: CompQType.spoken, prompt: 'In one or two sentences, explain what to do if something breaks in the flat.', keywords: ['message', 'before', 'landlord'], modelAnswer: 'You should message the flatmate before calling the landlord, because he once charged for a repair they could have done themselves.', explanationEs: 'Idea clave: avisar al compañero (message) antes de (before) llamar al casero (landlord).'),
    ],
  ),
  ComprehensionPiece(
    id: 'gen_b1_review',
    domain: 'general',
    band: 'B1',
    category: 'Opiniones',
    title: 'A review of a new café',
    estMinutes: 4,
    body: '''I had heard so much about the new café on Oak Street that I finally went last Saturday, and I left with mixed feelings. On the positive side, the coffee was excellent — easily the best flat white I have had in months — and the staff were friendly without being pushy. The problem was everything else. We waited almost twenty minutes just to order, the tables were sticky, and the music was so loud that my friend and I had to lean in to hear each other. It is a shame, because the place clearly has potential. If they hired one more person and turned the volume down, I would happily go back every week. For now, I would recommend it only if you are in no hurry.''',
    bodyEs: '''Había oído hablar tanto de la nueva cafetería de Oak Street que por fin fui el sábado pasado, y me fui con sentimientos encontrados. En lo positivo, el café estaba excelente — sin duda el mejor flat white que he tomado en meses — y el personal era amable sin ser insistente. El problema era todo lo demás. Esperamos casi veinte minutos solo para pedir, las mesas estaban pegajosas y la música estaba tan alta que mi amiga y yo teníamos que acercarnos para oírnos. Es una pena, porque el sitio claramente tiene potencial. Si contrataran a una persona más y bajaran el volumen, volvería encantado cada semana. Por ahora, solo lo recomendaría si no tienes prisa.''',
    questions: [
      CompQuestion(prompt: 'What is the writer\'s overall opinion?', options: ['Totally negative', 'Mixed — good coffee, poor service', 'Totally positive'], correctIndex: 1, explanationEs: '"I left with mixed feelings": el café bien, el servicio mal.'),
      CompQuestion(prompt: 'What does "the place clearly has potential" imply?', options: ['It is already perfect', 'It could be good if problems were fixed', 'It will close soon'], correctIndex: 1, explanationEs: 'Potencial = podría ser bueno si arreglan lo demás (personal, volumen).'),
      CompQuestion(prompt: 'Who would the writer recommend it to?', options: ['Anyone', 'People in a hurry', 'People who are not in a hurry'], correctIndex: 2, explanationEs: '"only if you are in no hurry" (por la espera larga).'),
      CompQuestion(type: CompQType.spoken, prompt: 'Would you go to this café? Give two reasons based on the text.', keywords: ['coffee', 'wait', 'music'], modelAnswer: 'I might go for the excellent coffee, but the long wait and the loud music would put me off.', explanationEs: 'Menciona al menos dos: café excelente (coffee), la espera (wait) y/o la música alta (music).'),
    ],
  ),
  ComprehensionPiece(
    id: 'gen_b2_remote',
    domain: 'general',
    band: 'B2',
    category: 'Opiniones',
    title: 'Is remote work really better?',
    estMinutes: 5,
    body: '''Supporters of remote work argue that it saves hours of commuting and lets people focus without the constant interruptions of an open-plan office. Critics counter that it quietly erodes the boundary between work and home, and that the people who suffer most are the juniors, who learn a surprising amount simply by overhearing how experienced colleagues handle a tricky call. There is also the question of trust: managers who cannot see their teams sometimes compensate by demanding more meetings, which defeats the whole purpose. In practice, most companies have landed on a hybrid model — a few days in the office for the conversations that are awkward over video, and the rest at home for the deep, uninterrupted work that an office rarely allows. The debate, then, is less about where we work than about what each kind of task actually needs.''',
    bodyEs: '''Los partidarios del teletrabajo argumentan que ahorra horas de desplazamiento y permite concentrarse sin las interrupciones constantes de una oficina diáfana. Los críticos responden que erosiona silenciosamente la frontera entre trabajo y hogar, y que quienes más sufren son los junior, que aprenden muchísimo simplemente al oír cómo los compañeros con experiencia manejan una llamada difícil. También está la cuestión de la confianza: los jefes que no ven a sus equipos a veces lo compensan exigiendo más reuniones, lo que echa por tierra todo el propósito. En la práctica, la mayoría de las empresas han optado por un modelo híbrido — unos días en la oficina para las conversaciones que resultan incómodas por vídeo, y el resto en casa para el trabajo profundo e ininterrumpido que una oficina rara vez permite. El debate, entonces, va menos sobre dónde trabajamos que sobre qué necesita realmente cada tipo de tarea.''',
    questions: [
      CompQuestion(prompt: 'According to the text, why do juniors suffer most?', options: ['They have worse laptops', 'They learn by overhearing experienced colleagues', 'They dislike commuting'], correctIndex: 1, explanationEs: 'Inferencia del texto: aprenden "by overhearing how experienced colleagues handle a tricky call".'),
      CompQuestion(prompt: 'What does "which defeats the whole purpose" refer to?', options: ['More meetings cancel out the benefit of remote work', 'Trust is impossible', 'Offices are useless'], correctIndex: 0, explanationEs: 'Referencia: exigir más reuniones anula el propósito del teletrabajo (foco/autonomía).'),
      CompQuestion(prompt: 'What is the writer\'s main conclusion?', options: ['Remote work is best', 'The office is best', 'The question is what each task needs, not just where we work'], correctIndex: 2, explanationEs: 'Última frase: el debate va sobre qué necesita cada tarea, no solo el lugar.'),
      CompQuestion(type: CompQType.spoken, prompt: 'Summarize the argument for a hybrid model in your own words.', keywords: ['office', 'collaboration', 'home', 'focus'], modelAnswer: 'A hybrid model uses the office for conversations and collaboration that are awkward over video, and home for deep, focused work without interruptions.', explanationEs: 'Ideas clave: oficina (office) para colaborar/hablar, casa (home) para el trabajo de concentración (focus).'),
    ],
  ),
  ComprehensionPiece(
    id: 'gen_b2c1_train',
    domain: 'general',
    band: 'B2-C1',
    category: 'Historias',
    title: 'The train I was glad to miss',
    estMinutes: 5,
    body: '''I had planned the trip for months, so when I reached the platform and watched the tail lights of my train slide into the tunnel, my stomach dropped. I had misread the timetable by exactly one hour — the kind of small, stupid mistake that feels enormous in the moment. My first instinct was to blame everyone but myself: the confusing signs, the app that had not updated, the queue at security. Then, with nothing left to do, I bought a coffee and asked a member of staff whether there was any other way. It turned out there was a slower regional line that wound through half a dozen villages and would still get me to the coast by evening. That detour became the part of the journey I remember best: empty carriages, fields turning gold in the late sun, and an unexpectedly long conversation with a retired teacher who had, it seemed, a story for every station. I have caught every train since. But a part of me is still quietly grateful for the one I lost.''',
    bodyEs: '''Había planeado el viaje durante meses, así que cuando llegué al andén y vi las luces traseras de mi tren deslizarse hacia el túnel, se me cayó el alma a los pies. Había leído mal el horario por exactamente una hora — ese tipo de error pequeño y tonto que en el momento parece enorme. Mi primer instinto fue culpar a todos menos a mí mismo: las señales confusas, la app que no se había actualizado, la cola del control de seguridad. Luego, sin nada más que hacer, me compré un café y le pregunté a un empleado si había alguna otra forma. Resultó que había una línea regional más lenta que serpenteaba por media docena de pueblos y que aún me llevaría a la costa por la tarde. Ese desvío se convirtió en la parte del viaje que mejor recuerdo: vagones vacíos, campos volviéndose dorados bajo el sol de la tarde, y una conversación inesperadamente larga con un maestro jubilado que, al parecer, tenía una historia para cada estación. Desde entonces no he perdido ni un tren. Pero una parte de mí sigue estando calladamente agradecida por el que perdí.''',
    questions: [
      CompQuestion(prompt: 'What was the narrator\'s FIRST reaction to missing the train?', options: ['To stay calm', 'To blame external things', 'To go home'], correctIndex: 1, explanationEs: '"My first instinct was to blame everyone but myself" (señales, app, cola).'),
      CompQuestion(prompt: 'The phrase "my stomach dropped" mainly conveys...', options: ['hunger', 'sudden dismay', 'relief'], correctIndex: 1, explanationEs: 'Vocabulario en contexto: expresa un golpe de angustia/decepción repentina.'),
      CompQuestion(prompt: 'Why is the narrator "grateful for the one I lost"?', options: ['It was cheaper', 'The detour became the best memory', 'They hated the destination'], correctIndex: 1, explanationEs: 'El desvío fue "the part of the journey I remember best".'),
      CompQuestion(type: CompQType.spoken, prompt: 'Tell the story of what happened after the narrator missed the train.', keywords: ['coffee', 'regional', 'detour', 'conversation'], modelAnswer: 'After missing the train, the narrator stayed calm, took a slower regional line through several villages, and the detour became the best part of the trip, including a long conversation with a retired teacher.', explanationEs: 'Ideas: mantuvo la calma, cogió la línea regional (regional), el desvío (detour) y la conversación (conversation).'),
    ],
  ),
  // ═══════════════════════════════ PROFESIONAL / TECH ═══════════════════════════════
  ComprehensionPiece(
    id: 'tech_b1_standup',
    domain: 'tech',
    band: 'B1',
    category: 'Agile & Standups',
    title: 'A standup update with a blocker',
    estMinutes: 4,
    body: '''Morning, everyone. Yesterday I finished the login screen and opened a pull request, so if someone has ten minutes to review it, that would really help. Today I am moving on to the password reset flow. I do have one blocker: I am still waiting for the design team to confirm the wording of the error messages, and I do not want to guess and redo the work later. My plan is this — if I have not heard back by lunchtime, I will use placeholders, ship the logic, and swap the final text in once design replies. That way the feature is not stuck on a decision that is out of my hands. Nothing else from me; back to you.''',
    bodyEs: '''Buenos días a todos. Ayer terminé la pantalla de login y abrí un pull request, así que si alguien tiene diez minutos para revisarlo, me vendría muy bien. Hoy paso al flujo de restablecer contraseña. Tengo un impedimento: sigo esperando a que el equipo de diseño confirme el texto de los mensajes de error, y no quiero adivinar y rehacer el trabajo luego. Mi plan es este — si no tengo respuesta antes de comer, usaré placeholders, subiré la lógica y cambiaré el texto final cuando diseño responda. Así la funcionalidad no se queda atascada por una decisión que no depende de mí. Nada más por mi parte; te devuelvo la palabra.''',
    questions: [
      CompQuestion(prompt: 'What does the speaker ask the team for?', options: ['More time', 'A code review of the pull request', 'A new laptop'], correctIndex: 1, explanationEs: '"if someone has ten minutes to review it".'),
      CompQuestion(prompt: 'Why won\'t the speaker just guess the error wording?', options: ['To avoid redoing the work later', 'Because they forgot it', 'It is not important'], correctIndex: 0, explanationEs: '"I do not want to guess and redo the work later".'),
      CompQuestion(prompt: 'What is the purpose of the placeholder plan?', options: ['To skip the feature', 'To keep progress despite a decision out of their hands', 'To blame the design team'], correctIndex: 1, explanationEs: '"the feature is not stuck on a decision that is out of my hands".'),
      CompQuestion(type: CompQType.spoken, prompt: 'Give your own standup update: what you did, what you will do, and one blocker.', keywords: ['yesterday', 'today', 'blocker'], modelAnswer: 'Yesterday I finished the API tests, today I will start the payment flow, and my blocker is that I am waiting for access to the staging server.', explanationEs: 'Estructura clásica: ayer (yesterday), hoy (today), y un impedimento (blocker).'),
    ],
  ),
  ComprehensionPiece(
    id: 'tech_b2_postmortem',
    domain: 'tech',
    band: 'B2',
    category: 'Incidentes & DevOps',
    title: 'A blameless post-mortem',
    estMinutes: 5,
    body: '''At 03:14 our checkout service began returning errors, and within four minutes almost a third of requests were failing. The trigger was a routine deploy, but the deploy was not the root cause; it simply exposed a missing index on the orders table that had been fine at low traffic and fell apart under the overnight batch load. As queries slowed, database connections piled up until the pool was exhausted, and healthy requests started timing out too. We mitigated it by adding the index and restarting the workers, and the service recovered within twenty minutes. Crucially, this write-up is blameless: the engineer who shipped the deploy followed every process we had. The gap was in our process, not in a person. To stop a repeat, we added an alert on connection-pool saturation and a check for unindexed foreign keys in code review.''',
    bodyEs: '''A las 03:14 nuestro servicio de checkout empezó a devolver errores, y en cuatro minutos casi un tercio de las peticiones fallaban. El detonante fue un deploy rutinario, pero el deploy no fue la causa raíz; simplemente sacó a la luz un índice ausente en la tabla de pedidos que iba bien con poco tráfico y se desmoronó bajo la carga del batch nocturno. Al ralentizarse las consultas, las conexiones a la base de datos se acumularon hasta agotar el pool, y las peticiones sanas también empezaron a dar timeout. Lo mitigamos añadiendo el índice y reiniciando los workers, y el servicio se recuperó en veinte minutos. Es importante: este informe es sin culpables — el ingeniero que hizo el deploy siguió todos los procesos que teníamos. El fallo estaba en nuestro proceso, no en una persona. Para evitar que se repita, añadimos una alerta sobre la saturación del pool de conexiones y una comprobación de claves foráneas sin índice en el code review.''',
    questions: [
      CompQuestion(prompt: 'What was the ROOT cause (not just the trigger)?', options: ['The routine deploy', 'A missing index exposed under batch load', 'A DDoS attack'], correctIndex: 1, explanationEs: 'Distinción clave: el deploy fue el detonante; la causa raíz fue el índice ausente bajo carga.'),
      CompQuestion(prompt: 'Why did healthy requests also start failing?', options: ['The office lost power', 'The connection pool was exhausted', 'The code was deleted'], correctIndex: 1, explanationEs: 'Cadena: consultas lentas → conexiones acumuladas → pool agotado → timeouts.'),
      CompQuestion(prompt: 'What does "blameless" emphasise here?', options: ['No one will be paid', 'The gap was in the process, not the person', 'The deploy should be reverted'], correctIndex: 1, explanationEs: '"The gap was in our process, not in a person".'),
      CompQuestion(type: CompQType.spoken, prompt: 'Explain the difference between the trigger and the root cause of this incident.', keywords: ['deploy', 'trigger', 'index', 'root'], modelAnswer: 'The trigger was a routine deploy, but the root cause was a missing database index that only failed under heavy batch load.', explanationEs: 'Contrasta detonante (deploy/trigger) vs causa raíz (root) = índice ausente (index).'),
    ],
  ),
  ComprehensionPiece(
    id: 'tech_b2c1_database',
    domain: 'tech',
    band: 'B2-C1',
    category: 'System Design',
    title: 'Relational or document store?',
    estMinutes: 6,
    body: '''When the team asked whether to build on a relational database or a document store, I pushed back on the framing: the right answer almost never comes from the technology itself, but from the shape of the data and how it will be read. Their core entities — customers, orders, payments — were densely interrelated, and the business demanded strict consistency: you cannot afford to charge a card twice because two writes raced. A relational database gave us transactions and foreign keys that enforce those invariants for free. A document store would have let us prototype faster and scale writes more easily, but it would have quietly pushed the burden of joins and integrity up into application code, where bugs are harder to see and easier to ship. That is the real trade-off, and it is rarely about raw speed: it is about where you want your complexity to live, and who pays for it later.''',
    bodyEs: '''Cuando el equipo preguntó si construir sobre una base de datos relacional o un almacén de documentos, cuestioné el planteamiento: la respuesta correcta casi nunca viene de la tecnología en sí, sino de la forma de los datos y de cómo se van a leer. Sus entidades principales — clientes, pedidos, pagos — estaban densamente interrelacionadas, y el negocio exigía consistencia estricta: no puedes permitirte cobrar una tarjeta dos veces porque dos escrituras compitieron. Una base de datos relacional nos daba transacciones y claves foráneas que imponen esas invariantes gratis. Un almacén de documentos nos habría dejado prototipar más rápido y escalar las escrituras más fácilmente, pero habría empujado silenciosamente la carga de los joins y la integridad hacia el código de la aplicación, donde los bugs son más difíciles de ver y más fáciles de publicar. Ese es el verdadero compromiso, y rara vez va sobre velocidad bruta: va sobre dónde quieres que viva tu complejidad, y quién la paga después.''',
    questions: [
      CompQuestion(prompt: 'Why does the writer "push back on the framing"?', options: ['They dislike both databases', 'The answer depends on the data, not the technology', 'They prefer to prototype'], correctIndex: 1, explanationEs: '"the right answer... comes from the shape of the data and how it will be read".'),
      CompQuestion(prompt: 'What is the risk of a document store, per the text?', options: ['It cannot scale', 'Joins and integrity move into application code', 'It is always slower'], correctIndex: 1, explanationEs: '"pushed the burden of joins and integrity up into application code".'),
      CompQuestion(prompt: 'How does the writer reframe the trade-off?', options: ['Speed vs cost', 'Where complexity lives and who pays later', 'Old vs new tech'], correctIndex: 1, explanationEs: '"where you want your complexity to live, and who pays for it later".'),
      CompQuestion(type: CompQType.spoken, prompt: 'Argue for the relational choice for a payments system, in your own words.', keywords: ['consistency', 'transactions', 'payments', 'integrity'], modelAnswer: 'For payments you need strict consistency, so a relational database is safer because transactions and foreign keys enforce integrity and prevent double charges.', explanationEs: 'Ideas: consistencia estricta (consistency), transacciones (transactions), integridad (integrity) para pagos.'),
    ],
  ),
  ComprehensionPiece(
    id: 'tech_c1_review',
    domain: 'tech',
    band: 'C1',
    category: 'Code Review & Registro',
    title: 'Disagreeing well in a code review',
    estMinutes: 6,
    body: '''I want to be careful here, because the benchmark is genuinely impressive and I do not want to wave it away. I take the point that the optimised path is faster under load. That said, my hesitation is not about performance but about maintainability, and I would weigh that more heavily at this stage of the project. The optimised version introduces a hand-rolled cache whose invalidation logic, as far as I can tell, only two people on the team fully understand — and we have been burned before by exactly this kind of hidden state, twice in the last quarter. So rather than block the change outright, could I propose a middle path? Let us ship the simple version now, add the metric you care about, and let production tell us whether the optimisation is worth the complexity. If the numbers justify it, I will be the first to advocate for merging your approach. Does that feel reasonable?''',
    bodyEs: '''Quiero tener cuidado aquí, porque el benchmark es de verdad impresionante y no quiero despacharlo sin más. Acepto que el camino optimizado es más rápido bajo carga. Dicho esto, mi reparo no es sobre rendimiento sino sobre mantenibilidad, y a estas alturas del proyecto le daría más peso a eso. La versión optimizada introduce una caché hecha a mano cuya lógica de invalidación, por lo que veo, solo dos personas del equipo entienden del todo — y ya nos hemos quemado antes con exactamente este tipo de estado oculto, dos veces el último trimestre. Así que, en lugar de bloquear el cambio de plano, ¿puedo proponer un camino intermedio? Subamos la versión simple ahora, añadamos la métrica que te importa, y dejemos que producción nos diga si la optimización merece la complejidad. Si los números lo justifican, seré el primero en abogar por integrar tu enfoque. ¿Te parece razonable?''',
    questions: [
      CompQuestion(prompt: 'What is the reviewer\'s real objection?', options: ['Performance', 'Maintainability and hidden state', 'The benchmark is fake'], correctIndex: 1, explanationEs: '"my hesitation is not about performance but about maintainability".'),
      CompQuestion(prompt: 'How would you describe the reviewer\'s TONE?', options: ['Aggressive and dismissive', 'Diplomatic: acknowledges, then hedges', 'Indifferent'], correctIndex: 1, explanationEs: 'Registro C1: reconoce el mérito ("I take the point"), luego matiza ("That said...").'),
      CompQuestion(prompt: 'What concrete compromise does the reviewer propose?', options: ['Reject the change', 'Ship simple, measure in production, revisit', 'Rewrite from scratch'], correctIndex: 1, explanationEs: '"ship the simple version now, add the metric... let production tell us".'),
      CompQuestion(type: CompQType.spoken, prompt: 'Disagree diplomatically with a teammate who wants to add a complex cache. Acknowledge, object, and propose a compromise.', keywords: ['point', 'maintainability', 'simple', 'measure'], modelAnswer: 'I take your point about performance, but my concern is maintainability. Could we ship the simple version first, measure it in production, and revisit the cache only if the numbers justify it?', explanationEs: 'Estructura: reconocer (I take your point), objetar (maintainability), proponer intermedio (ship simple + measure).'),
    ],
  ),
];

List<ComprehensionPiece> comprehensionPiecesFor({required bool general}) =>
    allComprehensionPieces.where((p) => p.isGeneral == general).toList();

ComprehensionPiece? comprehensionPieceById(String id) {
  for (final p in allComprehensionPieces) {
    if (p.id == id) return p;
  }
  return null;
}
