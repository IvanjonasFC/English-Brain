import json
import os

units = [
    # ================= TRACK 1: LEVEL 1 (JUNIOR - A2/B1) =================
    {
        "id": "unit-1-junior",
        "level": "Level 1: Junior",
        "title": "Unit 1: Past Simple in STAR Stories",
        "tag": "A2 - B1",
        "subtitle": "Cómo narrar tus proyectos y bugs pasados con precisión temporal",
        "ruleSummary": "En entrevistas, usa SIEMPRE Past Simple (built, refactored, resolved) para eventos en un momento específico del pasado (ej. 'in 2023', 'last quarter'). Usa Present Perfect (have worked) SOLAMENTE para experiencias sin fecha o que siguen activas hoy.",
        "comparisonExamples": [
            {"wrong": "In 2023, I have redesigned our payment microservice.", "right": "In 2023, I redesigned our payment microservice.", "tip": "Una fecha concreta en el pasado (2023) exige Past Simple."},
            {"wrong": "I work at this company since two years.", "right": "I have been working at this company for two years.", "tip": "Para estados continuados hasta hoy, usa Present Perfect Continuous con 'for'."}
        ],
        "questions": [
            {
                "id": 101, "prompt": "When our Redis cluster crashed last month, I _____ the traffic to the fallback replica.",
                "contextSentence": "STAR Situation/Action: Specific past event (last month).",
                "options": ["have rerouted", "rerouted", "am rerouting", "had reroute"], "correctAnswer": "rerouted",
                "spanishExplanation": "Con 'last month' (fecha específica), la regla exige Past Simple ('rerouted').",
                "audioText": "When our Redis cluster crashed last month, I rerouted the traffic to the fallback replica."
            },
            {
                "id": 102, "prompt": "Throughout my career, I _____ distributed backends in Python and Go.",
                "contextSentence": "General career experience with no specific past timestamp.",
                "options": ["built", "have built", "was building", "builded"], "correctAnswer": "have built",
                "spanishExplanation": "'Throughout my career' expresa experiencia acumulada; requiere Present Perfect.",
                "audioText": "Throughout my career, I have built distributed backends in Python and Go."
            },
            {
                "id": 103, "prompt": "Yesterday the QA engineer _____ a critical memory leak in the parser.",
                "contextSentence": "Specific completed time marker: Yesterday.",
                "options": ["has identified", "identified", "is identifying", "identifies"], "correctAnswer": "identified",
                "spanishExplanation": "'Yesterday' exige Past Simple ('identified'). Nunca 'has identified' con marcadores cerrados.",
                "audioText": "Yesterday the QA engineer identified a critical memory leak in the parser."
            },
            {
                "id": 104, "prompt": "We _____ that legacy monolithic repository for over three years now.",
                "contextSentence": "Ongoing activity starting in the past and continuing today.",
                "options": ["maintained", "have been maintaining", "maintain", "were maintaining"], "correctAnswer": "have been maintaining",
                "spanishExplanation": "'For over three years now' indica acción continuada hasta hoy (Present Perfect Continuous).",
                "audioText": "We have been maintaining that legacy monolithic repository for over three years now."
            }
        ]
    },
    {
        "id": "unit-2-junior",
        "level": "Level 1: Junior",
        "title": "Unit 2: Describing Daily Tasks & Standups",
        "tag": "A2 - B1",
        "subtitle": "Present Simple vs Present Continuous en tus ceremonias ágiles",
        "ruleSummary": "Usa Present Continuous ('I am currently investigating the timeout') para lo que estás haciendo hoy o en este sprint. Usa Present Simple ('I maintain the billing API') para responsabilidades y rutinas permanentes.",
        "comparisonExamples": [
            {"wrong": "Today I work on the database indexing.", "right": "Today I am working on the database indexing.", "tip": "Las tareas temporales en progreso se expresan en Present Continuous."},
            {"wrong": "Every morning I am checking server alerts.", "right": "Every morning I check server alerts.", "tip": "Rutinas diarias repetitivas se expresan en Present Simple."}
        ],
        "questions": [
            {
                "id": 105, "prompt": "In today's standup, I reported that I _____ the OAuth token expiration bug.",
                "contextSentence": "Activity currently in progress this morning.",
                "options": ["investigate", "am currently investigating", "investigated", "have investigate"], "correctAnswer": "am currently investigating",
                "spanishExplanation": "Para tareas en curso durante el día de trabajo se usa 'am currently investigating'.",
                "audioText": "In today's standup, I reported that I am currently investigating the OAuth token expiration bug."
            },
            {
                "id": 106, "prompt": "Our engineering squad usually _____ a sprint planning session every other Monday.",
                "contextSentence": "Recurring team routine.",
                "options": ["is holding", "holds", "held", "has hold"], "correctAnswer": "holds",
                "spanishExplanation": "'Usually' indica hábito periódico recurrente; exige Present Simple ('holds').",
                "audioText": "Our engineering squad usually holds a sprint planning session every other Monday."
            },
            {
                "id": 107, "prompt": "Right now, the front-end team _____ the design system to Material 3.",
                "contextSentence": "Temporary sprint migration in progress.",
                "options": ["migrates", "is migrating", "migrated", "was migrate"], "correctAnswer": "is migrating",
                "spanishExplanation": "'Right now' exige Present Continuous ('is migrating').",
                "audioText": "Right now, the front-end team is migrating the design system to Material 3."
            }
        ]
    },
    {
        "id": "unit-3-junior",
        "level": "Level 1: Junior",
        "title": "Unit 3: Prepositions of Tech (In, On, At)",
        "tag": "A2 - B1",
        "subtitle": "Dominio de ubicaciones técnicas: in memory, on the server, at runtime",
        "ruleSummary": "Usa 'IN' para contenedores, lenguajes y almacenes internos ('in Python', 'in memory', 'in the database'). Usa 'ON' para plataformas, servidores y puertos ('on AWS', 'on the server', 'on port 8080'). Usa 'AT' para momentos y fases ('at runtime', 'at startup').",
        "comparisonExamples": [
            {"wrong": "The application crashes in runtime.", "right": "The application crashes at runtime.", "tip": "Las fases de ejecución usan la preposición 'at' (at runtime, at compile time)."},
            {"wrong": "We host our microservices in AWS.", "right": "We host our microservices on AWS.", "tip": "Las plataformas y proveedores de nube usan 'on' (on AWS, on GCP)."}
        ],
        "questions": [
            {
                "id": 108, "prompt": "We store session tokens _____ memory using an encrypted Redis cache.",
                "contextSentence": "Internal container storage.",
                "options": ["on", "in", "at", "by"], "correctAnswer": "in",
                "spanishExplanation": "El almacenamiento interno de datos se expresa como 'in memory'.",
                "audioText": "We store session tokens in memory using an encrypted Redis cache."
            },
            {
                "id": 109, "prompt": "The background daemon listens for webhook events _____ port 443.",
                "contextSentence": "Network port configuration.",
                "options": ["in", "on", "at", "to"], "correctAnswer": "on",
                "spanishExplanation": "La escucha en puertos de red se formula siempre como 'on port X'.",
                "audioText": "The background daemon listens for webhook events on port 443."
            },
            {
                "id": 110, "prompt": "Environment variables are loaded _____ startup to configure database connections.",
                "contextSentence": "Process lifecycle phase.",
                "options": ["at", "in", "on", "during of"], "correctAnswer": "at",
                "spanishExplanation": "Las fases del ciclo de vida de un proceso usan 'at' ('at startup', 'at runtime').",
                "audioText": "Environment variables are loaded at startup to configure database connections."
            }
        ]
    },
    {
        "id": "unit-4-junior",
        "level": "Level 1: Junior",
        "title": "Unit 4: Reporting Bugs & Concordance",
        "tag": "A2 - B1",
        "subtitle": "Concordancia sujeto-verbo en métricas y datos: 'data is/are', 'each', 'none'",
        "ruleSummary": "En inglés técnico moderno, 'data' suele tratarse como incontable singular ('the data shows'). Sujetos como 'Each service' o 'Neither cluster' son estrictamente singulares ('each service has its own DB').",
        "comparisonExamples": [
            {"wrong": "Each of the microservices have a health check endpoint.", "right": "Each of the microservices has a health check endpoint.", "tip": "'Each' es singular y rige verbo en tercera persona ('has')."},
            {"wrong": "The telemetry data show high memory usage.", "right": "The telemetry data shows high memory usage.", "tip": "En la práctica de ingeniería de software, 'data' funciona como un sustantivo colectivo singular."}
        ],
        "questions": [
            {
                "id": 111, "prompt": "Each of our worker nodes _____ a local copy of the machine learning model.",
                "contextSentence": "Distributed architecture node configuration.",
                "options": ["maintain", "maintains", "are maintaining", "have maintained"], "correctAnswer": "maintains",
                "spanishExplanation": "'Each' toma verbo en singular de tercera persona ('maintains').",
                "audioText": "Each of our worker nodes maintains a local copy of the machine learning model."
            },
            {
                "id": 112, "prompt": "Telemetry metrics indicate that the collected data _____ anomalous latency spikes.",
                "contextSentence": "Log analysis.",
                "options": ["exhibits", "exhibit", "are exhibiting", "have exhibit"], "correctAnswer": "exhibits",
                "spanishExplanation": "'Data' en software corporativo se conjuga en singular ('exhibits').",
                "audioText": "Telemetry metrics indicate that the collected data exhibits anomalous latency spikes."
            }
        ]
    },
    {
        "id": "unit-5-junior",
        "level": "Level 1: Junior",
        "title": "Unit 5: Technical Questions in Interviews",
        "tag": "A2 - B1",
        "subtitle": "Inversión y auxiliares para formular preguntas inteligentes al entrevistador",
        "ruleSummary": "Para preguntar sobre el stack o retos técnicos del equipo, invierte el auxiliar: 'How does your team handle tech debt?' (nunca 'How your team handles?'). Para preguntas indirectas educadas usa: 'Could you tell me how the team approaches testing?'",
        "comparisonExamples": [
            {"wrong": "How your deployment pipeline works?", "right": "How does your deployment pipeline work?", "tip": "Las preguntas directas en Present Simple requieren el auxiliar 'does' + infinitivo."},
            {"wrong": "Could you tell me how does the on-call rotation work?", "right": "Could you tell me how the on-call rotation works?", "tip": "En preguntas indirectas no hay inversión auxiliar; el orden vuelve a ser sujeto + verbo."}
        ],
        "questions": [
            {
                "id": 113, "prompt": "Could you tell me how your engineering team _____ production incidents?",
                "contextSentence": "Polite indirect question to interviewer.",
                "options": ["does handle", "handles", "is handling", "did handle"], "correctAnswer": "handles",
                "spanishExplanation": "En preguntas indirectas ('Could you tell me how...'), no se usa 'does'; el verbo va directo en presente ('handles').",
                "audioText": "Could you tell me how your engineering team handles production incidents?"
            },
            {
                "id": 114, "prompt": "What observability tools _____ currently use to track microservice latency?",
                "contextSentence": "Direct technical question.",
                "options": ["do you", "you do", "are you to", "did you used to"], "correctAnswer": "do you",
                "spanishExplanation": "La pregunta directa requiere 'do you' antes del verbo principal.",
                "audioText": "What observability tools do you currently use to track microservice latency?"
            }
        ]
    },
    {
        "id": "unit-6-junior",
        "level": "Level 1: Junior",
        "title": "Unit 6: Passive Voice in Incident Reports",
        "tag": "A2 - B1",
        "subtitle": "Cómo redactar post-mortems sin culpar a personas individuales",
        "ruleSummary": "En ingeniería de software libre de culpa (blameless post-mortem), la voz pasiva es fundamental: 'The configuration was updated without validation' en lugar de 'John broke production'. Estructura: Sujeto + was/were + participio.",
        "comparisonExamples": [
            {"wrong": "The backend was crash by the bad query.", "right": "The backend was crashed by the unindexed query.", "tip": "Usa el participio correcto del verbo en la pasiva."},
            {"wrong": "Carlos pushed buggy code to main.", "right": "An unverified pull request was merged into the main branch.", "tip": "Enfoca la acción en el objeto del incidente, no en la persona."}
        ],
        "questions": [
            {
                "id": 115, "prompt": "During the outage, the primary database instance _____ automatically to the secondary zone.",
                "contextSentence": "Failover mechanism post-mortem.",
                "options": ["was failed over", "failed over", "is fail over", "was failing"], "correctAnswer": "was failed over",
                "spanishExplanation": "Voz pasiva en pasado ('was failed over') para describir el proceso ejecutado por el orquestador.",
                "audioText": "During the outage, the primary database instance was failed over automatically to the secondary zone."
            },
            {
                "id": 116, "prompt": "All corrupted cache entries _____ within fifteen minutes of the initial alert.",
                "contextSentence": "Incident remediation report.",
                "options": ["were invalidated", "was invalidated", "invalidated", "have been invalidate"], "correctAnswer": "were invalidated",
                "spanishExplanation": "'Entries' es plural, por lo que exige 'were invalidated'.",
                "audioText": "All corrupted cache entries were invalidated within fifteen minutes of the initial alert."
            }
        ]
    },
    {
        "id": "unit-7-junior",
        "level": "Level 1: Junior",
        "title": "Unit 7: Essential Phrasal Verbs in Code",
        "tag": "A2 - B1",
        "subtitle": "Spin up, roll back, tear down, scale out: verbos frasales indispensables",
        "ruleSummary": "Los ingenieros nativos usan phrasal verbs en el 70% de las conversaciones cotidianas: 'spin up a container' (arrancar), 'roll back a release' (revertir), 'tear down test infra' (destruir), 'scale out' (escalar horizontalmente).",
        "comparisonExamples": [
            {"wrong": "We returned the release to the previous version.", "right": "We rolled back the release immediately.", "tip": "'Roll back' es el estándar técnico indiscutible para revertir despliegues."},
            {"wrong": "I opened a new Docker container.", "right": "I spun up a new Docker container.", "tip": "Usa 'spin up' para creación y arranque dinámico de entornos."}
        ],
        "questions": [
            {
                "id": 117, "prompt": "When the canary release showed a 5% error rate, we immediately _____ the deployment.",
                "contextSentence": "Continuous delivery rollback.",
                "options": ["rolled back", "spun up", "tore down", "scaled out"], "correctAnswer": "rolled back",
                "spanishExplanation": "'Rolled back' significa revertir a una versión previa ante errores.",
                "audioText": "When the canary release showed a 5% error rate, we immediately rolled back the deployment."
            },
            {
                "id": 118, "prompt": "Our CI pipeline automatically _____ temporary testing environments after PR approval.",
                "contextSentence": "Infrastructure automation.",
                "options": ["tears down", "rolls back", "drills down", "falls back"], "correctAnswer": "tears down",
                "spanishExplanation": "'Tear down' significa desmantelar o destruir recursos temporales.",
                "audioText": "Our CI pipeline automatically tears down temporary testing environments after PR approval."
            }
        ]
    },
    {
        "id": "unit-8-junior",
        "level": "Level 1: Junior",
        "title": "Unit 8: Modals for Permissions & Capabilities",
        "tag": "A2 - B1",
        "subtitle": "Can, May, Must, Should en especificaciones de APIs y requerimientos",
        "ruleSummary": "RFC 2119 define el lenguaje técnico oficial: 'MUST' (obligatorio sin excepción), 'SHOULD' (recomendado con justificación si se omite), 'MAY' (opcional), 'CAN' (capacidad técnica del sistema).",
        "comparisonExamples": [
            {"wrong": "Clients must optional send an API key.", "right": "Clients may optionally send an API key.", "tip": "'May' expresa opcionalidad o permiso; 'must' es obligatorio."},
            {"wrong": "The microservice can to handle 10k requests.", "right": "The microservice can handle 10k requests.", "tip": "Los verbos modales van siempre seguidos de infinitivo sin 'to'."}
        ],
        "questions": [
            {
                "id": 119, "prompt": "In accordance with OAuth standards, the client _____ include a valid bearer token in the Authorization header.",
                "contextSentence": "Mandatory security requirement.",
                "options": ["must", "may", "can to", "might optionally"], "correctAnswer": "must",
                "spanishExplanation": "Un requisito ineludible de seguridad se formula con 'must'.",
                "audioText": "In accordance with OAuth standards, the client must include a valid bearer token in the Authorization header."
            },
            {
                "id": 120, "prompt": "Under heavy burst traffic, our autoscaler _____ spawn up to fifty replica pods.",
                "contextSentence": "Technical capability.",
                "options": ["can", "should to", "ought", "must to"], "correctAnswer": "can",
                "spanishExplanation": "'Can' expresa capacidad técnica del sistema sin partícula 'to'.",
                "audioText": "Under heavy burst traffic, our autoscaler can spawn up to fifty replica pods."
            }
        ]
    },

    # ================= TRACK 2: LEVEL 2 (MID-LEVEL - B1/B2) =================
    {
        "id": "unit-9-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 2: System Conditionals & Projections",
        "tag": "B1 - B2",
        "subtitle": "Cómo formular hipótesis de escalabilidad y justificar decisiones técnicas",
        "ruleSummary": "Usa Primer Condicional (If + Present Simple, will + Verb) para predicciones técnicas realistas. Usa Segundo Condicional (If + Past Simple, would + Verb) para escenarios hipotéticos de arquitectura ('If we used Cassandra, we would achieve...').",
        "comparisonExamples": [
            {"wrong": "If we will add a cache, the database will be faster.", "right": "If we add a cache, the database will be faster.", "tip": "En la cláusula con 'If', NUNCA pongas 'will'. Usa Present Simple."},
            {"wrong": "If we migrated to microservices, we will solve all bugs.", "right": "If we migrated to microservices, we would face distributed tracing challenges.", "tip": "El segundo condicional usa 'would', no 'will'."}
        ],
        "questions": [
            {
                "id": 201, "prompt": "If we _____ write-heavy workloads to Kafka, the primary database latency will drop by 40%.",
                "contextSentence": "Realistic system projection (First Conditional).",
                "options": ["offload", "will offload", "would offload", "offloaded"], "correctAnswer": "offload",
                "spanishExplanation": "En la cláusula 'If' del primer condicional se usa Present Simple ('offload'), nunca 'will'.",
                "audioText": "If we offload write-heavy workloads to Kafka, the primary database latency will drop by 40%."
            },
            {
                "id": 202, "prompt": "If we switched from REST to gRPC, we _____ payload serialization overhead dramatically.",
                "contextSentence": "Hypothetical architecture evaluation (Second Conditional).",
                "options": ["will reduce", "would reduce", "reduced", "reduce"], "correctAnswer": "would reduce",
                "spanishExplanation": "La condición hipotética en pasado ('switched') rige 'would reduce' en la cláusula principal.",
                "audioText": "If we switched from REST to gRPC, we would reduce payload serialization overhead dramatically."
            },
            {
                "id": 203, "prompt": "Unless we _____ strict connection pooling, the Postgres database will exhaust available file descriptors.",
                "contextSentence": "System constraint with 'Unless' (= If not).",
                "options": ["enforce", "will enforce", "enforced", "don't enforce"], "correctAnswer": "enforce",
                "spanishExplanation": "'Unless' ya incluye la negación y actúa como 'If'; requiere presente ('enforce').",
                "audioText": "Unless we enforce strict connection pooling, the Postgres database will exhaust available file descriptors."
            }
        ]
    },
    {
        "id": "unit-10-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 10: Present Perfect with 'Since' & 'For'",
        "tag": "B1 - B2",
        "subtitle": "Evolución histórica de repositorios y stacks tecnológicos",
        "ruleSummary": "'Since' marca el punto de inicio específico en el tiempo ('since 2021', 'since the last major refactor'). 'For' mide la duración o período de tiempo transcurrido ('for three years', 'for several sprints').",
        "comparisonExamples": [
            {"wrong": "We use Kubernetes since two years.", "right": "We have been using Kubernetes for two years.", "tip": "Usa Present Perfect Continuous con 'for' para duraciones acumuladas."},
            {"wrong": "The service has been stable for the v2 launch.", "right": "The service has been stable since the v2 launch.", "tip": "Un hito puntual de inicio en el pasado requiere 'since'."}
        ],
        "questions": [
            {
                "id": 204, "prompt": "Our engineering department _____ using event sourcing _____ early 2022.",
                "contextSentence": "Architecture adoption history.",
                "options": ["has been / since", "is / for", "was / since", "have been / for"], "correctAnswer": "has been / since",
                "spanishExplanation": "Acción continua hasta el presente con hito temporal de inicio específico: 'has been / since'.",
                "audioText": "Our engineering department has been using event sourcing since early 2022."
            },
            {
                "id": 205, "prompt": "The batch processing pipeline has operated without any downtime _____ over six consecutive months.",
                "contextSentence": "Duration measurement.",
                "options": ["for", "since", "during", "from"], "correctAnswer": "for",
                "spanishExplanation": "Un intervalo de tiempo de duración ('over six consecutive months') exige 'for'.",
                "audioText": "The batch processing pipeline has operated without any downtime for over six consecutive months."
            }
        ]
    },
    {
        "id": "unit-11-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 11: Cause & Effect Connectors in RCA",
        "tag": "B1 - B2",
        "subtitle": "Due to, As a result, Consequently, Therefore en análisis de causa raíz",
        "ruleSummary": "'Due to' va seguido de un sustantivo o frase sustantiva ('due to a memory leak'). 'Consequently' y 'As a result' conectan oraciones completas y van seguidos de coma ('Consequently, the server crashed').",
        "comparisonExamples": [
            {"wrong": "Due to the memory leaked, the process crashed.", "right": "Due to the memory leak, the process crashed.", "tip": "'Due to' rige un sustantivo, no una cláusula verbal completa."},
            {"wrong": "The node failed because of it had no disk space.", "right": "The node failed because it had no disk space.", "tip": "'Because' introduce oraciones completas (sujeto + verbo); 'because of' rige sustantivos."}
        ],
        "questions": [
            {
                "id": 206, "prompt": "The query timed out _____ an unindexed foreign key in the orders table.",
                "contextSentence": "Root cause explanation.",
                "options": ["due to", "because", "consequently", "as a result"], "correctAnswer": "due to",
                "spanishExplanation": "Delante de una frase nominal ('an unindexed foreign key') se usa 'due to'.",
                "audioText": "The query timed out due to an unindexed foreign key in the orders table."
            },
            {
                "id": 207, "prompt": "The microservice failed its health checks. _____, Kubernetes routed all live traffic away.",
                "contextSentence": "Sentence-level cause and consequence.",
                "options": ["Consequently", "Due to", "Owing to", "Because of"], "correctAnswer": "Consequently",
                "spanishExplanation": "Para abrir una nueva oración introduciendo la consecuencia lógica se usa 'Consequently,'.",
                "audioText": "The microservice failed its health checks. Consequently, Kubernetes routed all live traffic away."
            }
        ]
    },
    {
        "id": "unit-12-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 12: Past Continuous vs Past Simple",
        "tag": "B1 - B2",
        "subtitle": "Interrupción de procesos: 'While the migration was running, the network dropped'",
        "ruleSummary": "Usa Past Continuous ('was running', 'were deploying') para la tarea de fondo que estaba en curso. Usa Past Simple ('dropped', 'failed') para el evento puntual que interrumpió la acción.",
        "comparisonExamples": [
            {"wrong": "While I deployed, the alert was firing.", "right": "While I was deploying, the alert fired.", "tip": "El proceso en progreso lleva Past Continuous y la interrupción Past Simple."},
            {"wrong": "The database crashed when we were run the benchmark.", "right": "The database crashed while we were running the benchmark.", "tip": "Usa 'while' con la forma continua del verbo."}
        ],
        "questions": [
            {
                "id": 208, "prompt": "While our background job _____ the transaction table, a sudden dead-lock occurred.",
                "contextSentence": "Process interruption narrative.",
                "options": ["was backfilling", "backfilled", "is backfilling", "has backfilled"], "correctAnswer": "was backfilling",
                "spanishExplanation": "La acción continua de fondo interrumpida por el deadlock requiere Past Continuous ('was backfilling').",
                "audioText": "While our background job was backfilling the transaction table, a sudden dead-lock occurred."
            },
            {
                "id": 209, "prompt": "The automated canary script aborted immediately when latency metrics _____ the 200ms threshold.",
                "contextSentence": "Punctual threshold breach.",
                "options": ["exceeded", "were exceeding", "have exceeded", "had exceed"], "correctAnswer": "exceeded",
                "spanishExplanation": "El cruce puntual del umbral de latencia se formula en Past Simple ('exceeded').",
                "audioText": "The automated canary script aborted immediately when latency metrics exceeded the 200ms threshold."
            }
        ]
    },
    {
        "id": "unit-13-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 13: Third Conditional in Post-Mortems",
        "tag": "B1 - B2",
        "subtitle": "Análisis contrafáctico: 'If we had cached the query, the DB wouldn't have crashed'",
        "ruleSummary": "El Tercer Condicional formula escenarios hipotéticos pasados que no sucedieron. Estructura: If + Past Perfect (had + V3), would have + V3 ('If we had set up alerts, we would have caught the regression earlier').",
        "comparisonExamples": [
            {"wrong": "If we had cache the endpoint, the server would not crash.", "right": "If we had cached the endpoint, the server would not have crashed.", "tip": "Ambas cláusulas deben reflejar el pasado irreal (had + V3 ... would have + V3)."},
            {"wrong": "If we would have tested in staging, we avoided the bug.", "right": "If we had tested in staging, we would have avoided the bug.", "tip": "NUNCA pongas 'would have' en la cláusula con 'If'."}
        ],
        "questions": [
            {
                "id": 210, "prompt": "If we _____ strict rate limiting on the auth route, the DDoS attack would not have overwhelmed our gateway.",
                "contextSentence": "Security post-mortem counterfactual.",
                "options": ["had enforced", "would enforce", "enforced", "would have enforced"], "correctAnswer": "had enforced",
                "spanishExplanation": "En la condición del tercer condicional se usa Past Perfect ('had enforced').",
                "audioText": "If we had enforced strict rate limiting on the auth route, the DDoS attack would not have overwhelmed our gateway."
            },
            {
                "id": 211, "prompt": "Had we enabled read replicas sooner, the primary database _____ during peak Black Friday traffic.",
                "contextSentence": "Inverted third conditional.",
                "options": ["would not have stalled", "did not stall", "will not stall", "would not stall"], "correctAnswer": "would not have stalled",
                "spanishExplanation": "La consecuencia pasada no cumplida requiere 'would not have stalled'.",
                "audioText": "Had we enabled read replicas sooner, the primary database would not have stalled during peak Black Friday traffic."
            }
        ]
    },
    {
        "id": "unit-14-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 14: Relative Clauses for Tech Definitions",
        "tag": "B1 - B2",
        "subtitle": "Definir componentes con 'which', 'that', 'where' sin ambigüedad",
        "ruleSummary": "Usa 'which' con comas para información adicional no restrictiva ('Redis, which is an in-memory datastore, provides sub-millisecond lookups'). Usa 'that' sin comas para identificar restrictivamente ('A broker that supports partitioning').",
        "comparisonExamples": [
            {"wrong": "Postgres that is an open-source database supports JSON.", "right": "Postgres, which is an open-source database, supports JSON.", "tip": "Información complementaria no esencial sobre un nombre propio va entre comas con 'which'."},
            {"wrong": "The microservice which handles billing crashed.", "right": "The microservice that handles billing crashed.", "tip": "Para especificar de qué microservicio exacto hablas, usa cláusula restrictiva con 'that'."}
        ],
        "questions": [
            {
                "id": 212, "prompt": "We implemented a circuit breaker pattern _____ isolates failing third-party payment gateways.",
                "contextSentence": "Essential defining clause.",
                "options": ["that", "where", "whom", "what"], "correctAnswer": "that",
                "spanishExplanation": "Cláusula restrictiva esencial que define la función del patrón: se usa 'that'.",
                "audioText": "We implemented a circuit breaker pattern that isolates failing third-party payment gateways."
            },
            {
                "id": 213, "prompt": "Kafka, _____ acts as our central event backbone, decouples ingestion from analytical processing.",
                "contextSentence": "Non-restrictive clause between commas.",
                "options": ["which", "that", "what", "where"], "correctAnswer": "which",
                "spanishExplanation": "Entre comas para información explicativa adicional sobre un sujeto conocido se usa 'which'.",
                "audioText": "Kafka, which acts as our central event backbone, decouples ingestion from analytical processing."
            }
        ]
    },
    {
        "id": "unit-15-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 15: Gerunds vs Infinitives in Dev Workflows",
        "tag": "B1 - B2",
        "subtitle": "Avoiding, Recommending, Stopping: verbos seguidos de -ing o to + infinitivo",
        "ruleSummary": "Verbos de arquitectura y código como 'avoid', 'consider', 'finish', 'recommend' rigen gerundio ('avoid blocking the thread', 'recommend sharding the DB'). Verbos como 'decide', 'refuse', 'attempt' rigen infinitivo ('decided to migrate').",
        "comparisonExamples": [
            {"wrong": "We should avoid to block the UI isolate.", "right": "We should avoid blocking the UI isolate.", "tip": "'Avoid' va siempre seguido de gerundio (-ing)."},
            {"wrong": "The team decided adopting GraphQL.", "right": "The team decided to adopt GraphQL.", "tip": "'Decide' va seguido de infinitivo con 'to'."}
        ],
        "questions": [
            {
                "id": 214, "prompt": "To prevent cold-start latency, we strongly recommend _____ container instances pre-warmed.",
                "contextSentence": "Architectural recommendation.",
                "options": ["keeping", "to keep", "keep", "kept"], "correctAnswer": "keeping",
                "spanishExplanation": "'Recommend' rige gerundio ('keeping') cuando se refiere a la acción recomendada.",
                "audioText": "To prevent cold-start latency, we strongly recommend keeping container instances pre-warmed."
            },
            {
                "id": 215, "prompt": "The architecture committee decided _____ the monolithic database into domain services.",
                "contextSentence": "Technical decision.",
                "options": ["to partition", "partitioning", "partition", "for partitioning"], "correctAnswer": "to partition",
                "spanishExplanation": "'Decide' requiere infinitivo con 'to' ('to partition').",
                "audioText": "The architecture committee decided to partition the monolithic database into domain services."
            }
        ]
    },
    {
        "id": "unit-16-mid",
        "level": "Level 2: Mid-Level",
        "title": "Unit 16: Passive Voice with Agents in Reviews",
        "tag": "B1 - B2",
        "subtitle": "'Designed by the infrastructure team': atribución formal de responsabilidades",
        "ruleSummary": "En code reviews y especificaciones de arquitectura, la combinación de voz pasiva con complemento agente ('by + entity') confiere una autoridad técnica formal y neutral: 'The caching policy was established by the security guild'.",
        "comparisonExamples": [
            {"wrong": "The pipeline was created from the DevOps team.", "right": "The pipeline was created by the DevOps team.", "tip": "El agente que realiza la acción en voz pasiva se introduce con 'by', no 'from'."},
            {"wrong": "The PR was approved through the tech lead.", "right": "The PR was approved by the tech lead.", "tip": "El sujeto agente de la pasiva rige 'by'."}
        ],
        "questions": [
            {
                "id": 216, "prompt": "The revised microservice contract was thoroughly reviewed and validated _____ our security architects.",
                "contextSentence": "Design review compliance.",
                "options": ["by", "from", "through", "with"], "correctAnswer": "by",
                "spanishExplanation": "El agente de la acción en voz pasiva se introduce siempre con 'by'.",
                "audioText": "The revised microservice contract was thoroughly reviewed and validated by our security architects."
            }
        ]
    },

    # ================= TRACK 3: LEVEL 3 (SENIOR ARCHITECT - B2/C1) =================
    {
        "id": "unit-17-senior",
        "level": "Level 3: Senior",
        "title": "Unit 3: Active Voice & Leadership Impact",
        "tag": "B2 - C1",
        "subtitle": "Cómo proponer cambios y defender trade-offs con diplomacia técnica",
        "ruleSummary": "Los arquitectos senior nunca afirman verdades absolutas ('Microservices are always better'). Usan 'hedging' para matizar el contexto: 'It might be prudent to consider...', 'Tend to experience...', 'Arguably the most resilient approach'.",
        "comparisonExamples": [
            {"wrong": "GraphQL is obviously superior to REST in every way.", "right": "In read-heavy mobile clients, GraphQL tends to offer superior bandwidth efficiency.", "tip": "Usa 'tends to' y acota el ámbito técnico para ganar credibilidad como senior."},
            {"wrong": "We must rewrite everything in Rust immediately.", "right": "It might be worthwhile exploring Rust for our CPU-bound worker threads.", "tip": "'It might be worthwhile' suena reflexivo y maduro."}
        ],
        "questions": [
            {
                "id": 301, "prompt": "Given our read-heavy traffic pattern, it _____ to introduce a write-through caching layer.",
                "contextSentence": "Diplomatic architecture recommendation in RFC.",
                "options": ["might be prudent", "is strictly required without debate", "has to make it", "will surely enforce"], "correctAnswer": "might be prudent",
                "spanishExplanation": "'It might be prudent' es el estándar de oro en arquitectura senior para sugerir soluciones sin sonar dogmático.",
                "audioText": "Given our read-heavy traffic pattern, it might be prudent to introduce a write-through caching layer."
            },
            {
                "id": 302, "prompt": "Monolithic architectures _____ suffer from tight coupling as the headcount scales past fifty engineers.",
                "contextSentence": "Nuanced general observation.",
                "options": ["tend to", "will forever", "must inevitably", "are bound without exception to"], "correctAnswer": "tend to",
                "spanishExplanation": "'Tend to' expresa una tendencia empírica sin caer en afirmaciones absolutistas.",
                "audioText": "Monolithic architectures tend to suffer from tight coupling as the headcount scales past fifty engineers."
            }
        ]
    },
    {
        "id": "unit-18-senior",
        "level": "Level 3: Senior",
        "title": "Unit 18: Inversion for Dramatic Retrospectives",
        "tag": "B2 - C1",
        "subtitle": "Estructuras invertidas: 'Never have we observed such high throughput'",
        "ruleSummary": "En presentaciones técnicas de alto impacto y defensas de arquitectura, las estructuras invertidas con adverbios negativos ('Never have we...', 'Rarely do systems...', 'Not only did we scale...') transmiten un dominio verbal nativo y contundente.",
        "comparisonExamples": [
            {"wrong": "We never have seen such a dramatic latency decrease.", "right": "Never have we observed such a dramatic reduction in tail latency.", "tip": "La inversión adverbial ('Never + auxiliary + subject + verb') genera impacto retórico."},
            {"wrong": "Not only we reduced cloud costs, but also improved uptime.", "right": "Not only did we reduce cloud costs, but we also improved overall system availability.", "tip": "'Not only' inicial requiere inversión con auxiliar ('did we reduce')."}
        ],
        "questions": [
            {
                "id": 303, "prompt": "_____ such catastrophic cascading failures until the upstream gateway dropped connection throttling.",
                "contextSentence": "High-impact retrospective statement.",
                "options": ["Rarely had we witnessed", "We had rarely witnessed not", "Rarely we witnessed", "Rarely did we witnessed"], "correctAnswer": "Rarely had we witnessed",
                "spanishExplanation": "La inversión adverbial formal exige 'Rarely had we witnessed' (adverbio + auxiliar + sujeto + participio).",
                "audioText": "Rarely had we witnessed such catastrophic cascading failures until the upstream gateway dropped connection throttling."
            },
            {
                "id": 304, "prompt": "Not only _____ the P99 response time to under 15 milliseconds, but we also cut infrastructure spend by 28%.",
                "contextSentence": "Executive architectural achievement summary.",
                "options": ["did we reduce", "we reduced", "reduced we", "have we reduce"], "correctAnswer": "did we reduce",
                "spanishExplanation": "'Not only' al inicio de oración requiere inversión auxiliar en pasado: 'did we reduce'.",
                "audioText": "Not only did we reduce the P99 response time to under 15 milliseconds, but we also cut infrastructure spend by 28%."
            }
        ]
    },
    {
        "id": "unit-19-senior",
        "level": "Level 3: Senior",
        "title": "Unit 19: Expressing Complex Trade-Offs",
        "tag": "B2 - C1",
        "subtitle": "Whereas, While, On the other hand, In contrast en decisiones de diseño",
        "ruleSummary": "Todo diseño de sistemas implica compromisos. Usa 'Whereas' o 'While' para contrastar dos enfoques en una sola oración balanceada ('While NoSQL provides horizontal elasticity, ACID compliance is sacrificed').",
        "comparisonExamples": [
            {"wrong": "Postgres has strong consistency, on the other hand Cassandra scales better.", "right": "While PostgreSQL offers robust ACID guarantees, Cassandra scales more gracefully under massive write throughput.", "tip": "'While' crea una cláusula subordinada elegante que pondera pros y contras."},
            {"wrong": "Microservices are fast but they are hard.", "right": "Whereas microservices foster team autonomy, they introduce substantial operational complexity.", "tip": "Usa 'Whereas' para contrastar dimensiones de arquitectura formalmente."}
        ],
        "questions": [
            {
                "id": 305, "prompt": "_____ event-driven messaging decouples downstream consumers, it introduces eventual consistency overhead.",
                "contextSentence": "Balanced architectural trade-off formulation.",
                "options": ["While", "Despite", "Because", "However"], "correctAnswer": "While",
                "spanishExplanation": "'While' (= mientras que) encabeza la concesión técnica contrapuesta a la consecuencia principal.",
                "audioText": "While event-driven messaging decouples downstream consumers, it introduces eventual consistency overhead."
            },
            {
                "id": 306, "prompt": "Synchronous RPC guarantees immediate response feedback; _____, asynchronous pub/sub maximizes ingestion throughput.",
                "contextSentence": "Semi-colon transition contrasting systems.",
                "options": ["in contrast", "although", "whereas", "owing to"], "correctAnswer": "in contrast",
                "spanishExplanation": "Tras punto y coma y seguido de coma, la locución adverbial de transición adecuada es 'in contrast,'.",
                "audioText": "Synchronous RPC guarantees immediate response feedback; in contrast, asynchronous pub/sub maximizes ingestion throughput."
            }
        ]
    },
    {
        "id": "unit-20-senior",
        "level": "Level 3: Senior",
        "title": "Unit 20: Subjunctive in Formal RFC Proposals",
        "tag": "B2 - C1",
        "subtitle": "Estructuras de mandato técnico: 'I propose that the API be versioned'",
        "ruleSummary": "En RFCs y recomendaciones de comités técnicos formales en inglés, los verbos de recomendación ('recommend', 'mandate', 'insist', 'propose') toman subjuntivo (verbo en forma base sin conjugación): 'We propose that every service expose a health metric'.",
        "comparisonExamples": [
            {"wrong": "I recommend that the database is upgraded tonight.", "right": "I recommend that the database be upgraded tonight.", "tip": "El subjuntivo formal en inglés técnico utiliza la forma base 'be', no 'is'."},
            {"wrong": "The lead insisted that he writes unit tests.", "right": "The lead insisted that he write comprehensive integration tests.", "tip": "El subjuntivo de tercera persona singular usa 'write', no 'writes'."}
        ],
        "questions": [
            {
                "id": 307, "prompt": "The architecture governance board mandates that each newly created microservice _____ an OpenAPI contract.",
                "contextSentence": "Formal company engineering policy.",
                "options": ["publish", "publishes", "is publishing", "published"], "correctAnswer": "publish",
                "spanishExplanation": "La cláusula subjuntiva tras 'mandates that' exige la forma base pura del verbo ('publish').",
                "audioText": "The architecture governance board mandates that each newly created microservice publish an OpenAPI contract."
            },
            {
                "id": 308, "prompt": "We strongly recommend that the legacy authentication cluster _____ decommissioned by Q4.",
                "contextSentence": "Technical roadmap proposal.",
                "options": ["be", "is", "was", "will be"], "correctAnswer": "be",
                "spanishExplanation": "El subjuntivo pasivo con 'recommend that' utiliza 'be decommissioned'.",
                "audioText": "We strongly recommend that the legacy authentication cluster be decommissioned by Q4."
            }
        ]
    },
    {
        "id": "unit-21-senior",
        "level": "Level 3: Senior",
        "title": "Unit 21: Mixed Conditionals in Tech Debt",
        "tag": "B2 - C1",
        "subtitle": "Pasado que impacta el presente: 'If we had refactored, we would be scalable now'",
        "ruleSummary": "Los condicionales mixtos combinan una causa en el pasado (had + V3) con un estado resultante en el presente (would + verbo base): 'If we had containerized our workloads back then, we would not struggle with server drift today'.",
        "comparisonExamples": [
            {"wrong": "If we migrated last year, we would be fine today.", "right": "If we had migrated last year, we would be far more competitive today.", "tip": "La acción pasada es irrepetible ('had migrated'); el efecto actual es presente ('would be')."},
            {"wrong": "If we had cached early, we would have been faster today.", "right": "If we had cached early, we would have lower latency today.", "tip": "'Today' rige 'would have lower latency', no 'would have had'."}
        ],
        "questions": [
            {
                "id": 309, "prompt": "If the previous team _____ an automated migration harness, we would not be spending half our sprint resolving manual schema drifts today.",
                "contextSentence": "Technical debt evaluation.",
                "options": ["had established", "established", "would establish", "has established"], "correctAnswer": "had established",
                "spanishExplanation": "Condición mixta: acción no realizada en el pasado con impacto en el presente ('had established').",
                "audioText": "If the previous team had established an automated migration harness, we would not be spending half our sprint resolving manual schema drifts today."
            }
        ]
    },
    {
        "id": "unit-22-senior",
        "level": "Level 3: Senior Architect",
        "title": "Unit 22: Cleft Sentences for Emphasis",
        "tag": "B2 - C1",
        "subtitle": "Estructuras de realce: 'What we achieved was a 40% latency reduction'",
        "ruleSummary": "Las 'cleft sentences' dividen la información para enfocar el mérito principal de tu equipo ante el entrevistador: 'What really transformed our delivery velocity was continuous deployment' o 'It was our database partitioning that prevented the downtime'.",
        "comparisonExamples": [
            {"wrong": "We improved the caching and that made the difference.", "right": "What made the critical difference was our multi-tiered caching strategy.", "tip": "La estructura 'What [acción] was [logro]' suena profesional y segura."},
            {"wrong": "The asynchronous queue saved the system.", "right": "It was the asynchronous queue that buffered the traffic spike and prevented data loss.", "tip": "La cleft con 'It was X that Y' enfatiza el factor clave."}
        ],
        "questions": [
            {
                "id": 310, "prompt": "_____ enabled us to maintain five-nines availability was our automated multi-region failover strategy.",
                "contextSentence": "STAR story focal emphasis.",
                "options": ["What", "Which", "That", "It"], "correctAnswer": "What",
                "spanishExplanation": "Wh-cleft sentence introducida por 'What' para enfatizar el componente clave del éxito.",
                "audioText": "What enabled us to maintain five-nines availability was our automated multi-region failover strategy."
            },
            {
                "id": 311, "prompt": "It was our early investment in observability _____ allowed us to pinpoint the memory leak within minutes.",
                "contextSentence": "Attribution cleft sentence.",
                "options": ["that", "which", "what", "who"], "correctAnswer": "that",
                "spanishExplanation": "La estructura 'It was [X] that [Y]' rige 'that' como nexo enfático.",
                "audioText": "It was our early investment in observability that allowed us to pinpoint the memory leak within minutes."
            }
        ]
    },
    {
        "id": "unit-23-senior",
        "level": "Level 3: Senior Architect",
        "title": "Unit 23: Participle Clauses for Concise Docs",
        "tag": "B2 - C1",
        "subtitle": "Sintaxis técnica compacta: 'Having decoupled the queue, we lowered CPU spikes'",
        "ruleSummary": "Las cláusulas de participio ('Having decoupled...', 'Utilizing an LSM-tree...') reemplazan oraciones largas de causa o tiempo y permiten un estilo de escritura y habla ejecutivo, conciso y de alta densidad.",
        "comparisonExamples": [
            {"wrong": "Because we migrated the DB, we observed lower latency.", "right": "Having migrated the database to DynamoDB, we eliminated operational maintenance entirely.", "tip": "'Having + participio' indica que una tarea concluyó exitosamente antes de la siguiente."},
            {"wrong": "When we use Redis, we can cache responses.", "right": "Leveraging Redis as an edge cache, our proxy serves 90% of requests without touching the origin.", "tip": "El participio presente 'Leveraging...' confiere sofisticación técnica."}
        ],
        "questions": [
            {
                "id": 312, "prompt": "_____ the monolithic repository into domain packages, we reduced CI pipeline build times from forty minutes to six.",
                "contextSentence": "Executive technical summary.",
                "options": ["Having refactored", "After we refactor", "Refactoring have", "We had refactored"], "correctAnswer": "Having refactored",
                "spanishExplanation": "'Having refactored' resume de forma compacta y elegante una acción completada con éxito.",
                "audioText": "Having refactored the monolithic repository into domain packages, we reduced CI pipeline build times from forty minutes to six."
            }
        ]
    },
    {
        "id": "unit-24-senior",
        "level": "Level 3: Senior Architect",
        "title": "Unit 24: Discourse Markers in System Design",
        "tag": "B2 - C1",
        "subtitle": "Transiciones fluidas durante entrevistas de System Design de 45 minutos",
        "ruleSummary": "Guiar al entrevistador requiere marcadores de transición deliberados: 'Moving on to data persistence...', 'With regard to horizontal scalability...', 'Turning our attention to fault tolerance...'. Demuestran estructura mental y liderazgo.",
        "comparisonExamples": [
            {"wrong": "Now I talk about the database.", "right": "Moving on to our data persistence layer, let's analyze read-write ratios.", "tip": "'Moving on to...' es la transición profesional perfecta durante un whiteboard design."},
            {"wrong": "About the security, we use OAuth.", "right": "With respect to access governance, OAuth 2.0 with short-lived tokens is our baseline.", "tip": "'With respect to...' introduce dominios de diseño formalmente."}
        ],
        "questions": [
            {
                "id": 313, "prompt": "Now that we have scoped the ingestion API, _____ to the storage tier and discuss data partitioning strategies.",
                "contextSentence": "System design interview transition.",
                "options": ["let us transition", "we go now", "I make a jump", "talking next"], "correctAnswer": "let us transition",
                "spanishExplanation": "'Let us transition to...' marca un cambio de sección ordenado y colaborativo con el entrevistador.",
                "audioText": "Now that we have scoped the ingestion API, let us transition to the storage tier and discuss data partitioning strategies."
            }
        ]
    },

    # ================= TRACK 4: LEVEL 4 (STRATEGIC & LEAD - C1) =================
    {
        "id": "unit-25-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 4: Strategic Negotiation & Idioms",
        "tag": "C1",
        "subtitle": "Cómo hablarle a VPs y directores con convicción fundamentada en datos",
        "ruleSummary": "A nivel Staff/Principal, el lenguaje debe ser asertivo y cuantitativo: 'The data unequivocally demonstrates that...', 'I strongly advocate allocating 20% of sprint capacity to technical debt reduction'.",
        "comparisonExamples": [
            {"wrong": "Maybe we should think about refactoring if you agree.", "right": "I strongly recommend investing in our event backbone this quarter to mitigate catastrophic Q4 outage risk.", "tip": "Sustituye la timidez por recomendaciones asertivas respaldadas por impacto de negocio."},
            {"wrong": "The latency is somewhat bad.", "right": "The tail latency poses a direct threat to our checkout conversion funnels.", "tip": "Conecta problemas técnicos directamente con métricas de negocio."}
        ],
        "questions": [
            {
                "id": 401, "prompt": "To convince senior leadership to invest in distributed tracing, a staff engineer asserts:",
                "contextSentence": "Executive persuasion in engineering committee.",
                "options": [
                    "The telemetry data unequivocally demonstrates that mean-time-to-resolution dropped by 65% in pilot squads.",
                    "Maybe we can try some tracing tools if anyone likes it.",
                    "I think tracing is very pretty and modern.",
                    "We need tracing because Google uses it."
                ],
                "correctAnswer": "The telemetry data unequivocally demonstrates that mean-time-to-resolution dropped by 65% in pilot squads.",
                "spanishExplanation": "A nivel Staff/Principal, las decisiones se defienden con datos concluyentes ('unequivocally demonstrates') y métricas de negocio ('MTTR').",
                "audioText": "The telemetry data unequivocally demonstrates that mean-time-to-resolution dropped by 65% in pilot squads."
            }
        ]
    },
    {
        "id": "unit-26-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 26: Risk Mitigation & Concessive Clauses",
        "tag": "C1",
        "subtitle": "Notwithstanding, Albeit, In spite of en evaluaciones de riesgo corporativo",
        "ruleSummary": "Las cláusulas concesivas avanzadas permiten reconocer riesgos sin restar firmeza a la propuesta: 'Notwithstanding the initial capital expenditure, migrating to self-hosted Kubernetes yields a 40% margin improvement within 18 months'.",
        "comparisonExamples": [
            {"wrong": "Although the high cost, we must migrate.", "right": "Notwithstanding the upfront migration overhead, the strategic elasticity justifies the investment.", "tip": "'Notwithstanding' rige frase sustantiva y denota alto registro ejecutivo."},
            {"wrong": "It is slow but good.", "right": "Our consensus protocol provides robust correctness, albeit at the expense of marginal write latency.", "tip": "'Albeit' introduce concesiones sutiles de forma impecable."}
        ],
        "questions": [
            {
                "id": 402, "prompt": "_____ the steep initial learning curve of Rust, the elimination of memory-safety vulnerabilities resulted in a net productivity gain.",
                "contextSentence": "High-level technology trade-off defense.",
                "options": ["Notwithstanding", "Although", "Despite of", "Even"], "correctAnswer": "Notwithstanding",
                "spanishExplanation": "'Notwithstanding' introduce una frase nominal concesiva con el máximo registro de formalidad.",
                "audioText": "Notwithstanding the steep initial learning curve of Rust, the elimination of memory-safety vulnerabilities resulted in a net productivity gain."
            }
        ]
    },
    {
        "id": "unit-27-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 27: Counterfactual Reasoning in RFCs",
        "tag": "C1",
        "subtitle": "Estructuras sin 'If': 'Had we not implemented backpressure, failure would have ensued'",
        "ruleSummary": "La inversión sin 'If' ('Had we not...', 'Were we to adopt...') es la marca definitiva de prosa técnica formal en RFCs de arquitectura crítica y defensas ejecutivas ante CTOs.",
        "comparisonExamples": [
            {"wrong": "If we would not have backpressure, the queue died.", "right": "Had we not implemented adaptive backpressure, cascading worker exhaustion would have ensued.", "tip": "'Had we not [V3] ... would have [V3]' es la forma más refinada del condicional pasado."},
            {"wrong": "If we would decide to rewrite, it costs too much.", "right": "Were we to undertake a complete rewrite, the opportunity cost would stifle roadmap delivery for six months.", "tip": "'Were we to [infinitive]' formula hipótesis futuras con elegancia."}
        ],
        "questions": [
            {
                "id": 403, "prompt": "_____ we to deprecate the v1 gateway without backward compatibility shims, our enterprise partner integrations would instantly fracture.",
                "contextSentence": "Formal hypothetical risk evaluation.",
                "options": ["Were", "If", "Had", "Should"], "correctAnswer": "Were",
                "spanishExplanation": "La inversión de segundo condicional hipotético para el futuro se construye con 'Were we to [verb]'.",
                "audioText": "Were we to deprecate the v1 gateway without backward compatibility shims, our enterprise partner integrations would instantly fracture."
            },
            {
                "id": 404, "prompt": "Had our site reliability team not acted within ninety seconds, the cache stampede _____ down the payment cluster.",
                "contextSentence": "Severe incident counterfactual.",
                "options": ["would have brought", "will bring", "brought", "had brought"], "correctAnswer": "would have brought",
                "spanishExplanation": "La cláusula principal de un tercer condicional invertido requiere 'would have brought'.",
                "audioText": "Had our site reliability team not acted within ninety seconds, the cache stampede would have brought down the payment cluster."
            }
        ]
    },
    {
        "id": "unit-28-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 28: Advanced Modal Stances for Roadmaps",
        "tag": "C1",
        "subtitle": "Is bound to, Is poised to, Ought to en compromisos de entrega",
        "ruleSummary": "En compromisos estratégicos, los modales compuestos ofrecen precisión sobre certeza y probabilidad: 'Our platform is poised to absorb a 10x traffic spike' (está lista/preparada), 'Unchecked tech debt is bound to cause regressions' (inevitablemente causará).",
        "comparisonExamples": [
            {"wrong": "The database will surely crash eventually.", "right": "Without automated indexing audits, the query engine is bound to degrade under scale.", "tip": "'Is bound to' denota un desenlace inevitable basado en leyes técnicas."},
            {"wrong": "The new architecture is ready to scale.", "right": "Our refactored core is poised to support multi-region expansion seamlessly.", "tip": "'Is poised to' denota preparación estratégica de primer nivel."}
        ],
        "questions": [
            {
                "id": 405, "prompt": "Following the successful Kubernetes cluster consolidation, our platform _____ expand into the APAC region next quarter.",
                "contextSentence": "Strategic roadmap readiness.",
                "options": ["is poised to", "is bound without", "ought have to", "can to"], "correctAnswer": "is poised to",
                "spanishExplanation": "'Is poised to' significa estar en posición óptima y listo para dar el siguiente paso estratégico.",
                "audioText": "Following the successful Kubernetes cluster consolidation, our platform is poised to expand into the APAC region next quarter."
            }
        ]
    },
    {
        "id": "unit-29-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 29: Nominalization for Executive Summaries",
        "tag": "C1",
        "subtitle": "De verbos a sustantivos de alto nivel: 'Decoupling facilitated scalability'",
        "ruleSummary": "La nominalización transforma oraciones coloquiales centradas en acciones ('Because we decoupled the services, they can scale') en declaraciones condensadas de impacto ('Service decoupling facilitated autonomous horizontal scalability').",
        "comparisonExamples": [
            {"wrong": "We refactored how we store logs so developers find bugs faster.", "right": "Centralization of telemetry ingestion substantially accelerated defect discovery cycles.", "tip": "La nominalización produce resúmenes densos, claros y orientados a resultados."},
            {"wrong": "When we migrated to cloud, we saved money.", "right": "Cloud infrastructure migration achieved a 32% reduction in recurring compute costs.", "tip": "Presenta los logros como hitos corporativos consolidados."}
        ],
        "questions": [
            {
                "id": 406, "prompt": "Transform this conversational sentence: 'Because we automated the regression suite, we released faster.'",
                "contextSentence": "Staff-level communication refinement.",
                "options": [
                    "Test harness automation substantially accelerated our release cadence.",
                    "We did automation so we can run very fast now.",
                    "Automating stuff made everybody happy and quick.",
                    "Because tests were automatic, things went rapid."
                ],
                "correctAnswer": "Test harness automation substantially accelerated our release cadence.",
                "spanishExplanation": "La nominalización concisa ('Test harness automation substantially accelerated our release cadence') es el sello distintivo del liderazgo técnico.",
                "audioText": "Test harness automation substantially accelerated our release cadence."
            }
        ]
    },
    {
        "id": "unit-30-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 30: Tactful Disagreement & Steering",
        "tag": "C1",
        "subtitle": "Disentir de forma constructiva con otros Staff Engineers y Directores",
        "ruleSummary": "El desacuerdo constructivo preserva la relación profesional a la vez que defiende la integridad del sistema: 'I see your rationale regarding speed to market; however, from an operational resilience standpoint, skipping schema migrations introduces unacceptable liabilities'.",
        "comparisonExamples": [
            {"wrong": "Your idea is bad and will crash the database.", "right": "I appreciate the ingenuity of this proposal; however, we must weigh it against our strict zero-data-loss SLA.", "tip": "Valida la intención del interlocutor antes de presentar la objeción técnica objetiva."},
            {"wrong": "I disagree with you completely.", "right": "While I recognize the short-term gains, my primary reservation centers on long-term maintainability.", "tip": "'My primary reservation centers on...' enfoca la discusión en el criterio, no en el ego."}
        ],
        "questions": [
            {
                "id": 407, "prompt": "When tactfully dissenting with a Product Manager who wants to bypass database migrations to hit a marketing deadline, say:",
                "contextSentence": "Cross-functional executive alignment.",
                "options": [
                    "While I understand the commercial urgency, bypassing migration validations exposes our billing engine to catastrophic data corruption risk.",
                    "No, marketing people never understand how databases actually work.",
                    "You will destroy the database if you do that.",
                    "I disagree because code quality is always number one regardless of business."
                ],
                "correctAnswer": "While I understand the commercial urgency, bypassing migration validations exposes our billing engine to catastrophic data corruption risk.",
                "spanishExplanation": "Equilibra la comprensión del objetivo de negocio ('commercial urgency') con una advertencia técnica objetiva y ponderada.",
                "audioText": "While I understand the commercial urgency, bypassing migration validations exposes our billing engine to catastrophic data corruption risk."
            }
        ]
    },
    {
        "id": "unit-31-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 31: Strategic Vision & Architectural Roadmaps",
        "tag": "C1",
        "subtitle": "Formulación de planes a 3 años y evolución de plataformas tecnológicas",
        "ruleSummary": "Los Staff y Principals deben proyectar la visión tecnológica hacia el futuro: 'Our three-year objective is to evolve our backend into an event-driven mesh that unlocks autonomous squad iteration without centralized coordination'.",
        "comparisonExamples": [
            {"wrong": "We want to make the backend good in three years.", "right": "Our strategic ambition centers on modularizing domain boundaries to foster self-service platform engineering.", "tip": "Emplea vocabulario estratégico de ingeniería de plataformas."},
            {"wrong": "We will buy more servers when we grow.", "right": "We are architecting our multi-cloud deployment strategy to ensure operational resilience against regional outages.", "tip": "Proyecta gobernanza y resiliencia a largo plazo."}
        ],
        "questions": [
            {
                "id": 408, "prompt": "How does a Lead Architect describe their long-term technical vision in an interview?",
                "contextSentence": "Executive vision interview response.",
                "options": [
                    "Our multi-year strategy focuses on decoupling our transactional core to empower product teams with self-service event streams.",
                    "I want our company to use the newest libraries always.",
                    "We plan to rewrite everything every two years to stay fresh.",
                    "My vision is having zero bugs in the entire company."
                ],
                "correctAnswer": "Our multi-year strategy focuses on decoupling our transactional core to empower product teams with self-service event streams.",
                "spanishExplanation": "Combina arquitectura desacoplada con valor empresarial para los equipos de producto.",
                "audioText": "Our multi-year strategy focuses on decoupling our transactional core to empower product teams with self-service event streams."
            }
        ]
    },
    {
        "id": "unit-32-staff",
        "level": "Level 4: Staff / Lead",
        "title": "Unit 32: Idiomatic Tech Leadership Expressions",
        "tag": "C1",
        "subtitle": "Bite the bullet, Move the needle, Touch base, Double-edged sword",
        "ruleSummary": "Los modismos de liderazgo son comunes en empresas anglosajonas y entrevistas de FAANG/Silicon Valley: 'bite the bullet' (tomar una decisión dura necesaria), 'move the needle' (generar un impacto medible), 'touch base' (sincronizar brevemente), 'a double-edged sword' (arma de doble filo / trade-off).",
        "comparisonExamples": [
            {"wrong": "We had to take the hard decision and kill the monolith.", "right": "We had to bite the bullet and deprecate the legacy monolithic backend.", "tip": "'Bite the bullet' es el modismo nativo estándar para decisiones inevitables y difíciles."},
            {"wrong": "This refactor made good results in the metrics.", "right": "Our latency optimizations truly moved the needle on customer checkout conversion.", "tip": "'Moved the needle' denota impacto comercial tangible."}
        ],
        "questions": [
            {
                "id": 409, "prompt": "When you must finally face an uncomfortable decision (e.g. deprecating a legacy system), you:",
                "contextSentence": "Idiomatic expressions in engineering leadership.",
                "options": [
                    "Bite the bullet",
                    "Break the ice",
                    "Burn the midnight oil",
                    "Spill the beans"
                ],
                "correctAnswer": "Bite the bullet",
                "spanishExplanation": "'Bite the bullet' significa tomar una decisión difícil o incómoda que se ha estado postergando.",
                "audioText": "We had to bite the bullet and deprecate the v1 monolithic API."
            },
            {
                "id": 410, "prompt": "Explain that microservices have both distinct advantages and operational drawbacks:",
                "contextSentence": "Balanced architectural nuance.",
                "options": [
                    "Adopting microservices is a double-edged sword: it unlocks scale but multiplies operational overhead.",
                    "Microservices is a two-knife situation.",
                    "It has two faces of a coin always.",
                    "Microservices are both good and bad things."
                ],
                "correctAnswer": "Adopting microservices is a double-edged sword: it unlocks scale but multiplies operational overhead.",
                "spanishExplanation": "'A double-edged sword' (un arma de doble filo) es el modismo técnico ideal para ponderar trade-offs.",
                "audioText": "Adopting microservices is a double-edged sword: it unlocks scale but multiplies operational overhead."
            }
        ]
    }
]

# Generate Dart code
dart_code = """class GrammarQuestion {
  final int id;
  final String level;
  final String unitTitle;
  final String prompt;
  final String? contextSentence;
  final List<String> options;
  final String correctAnswer;
  final String spanishExplanation;
  final String audioText;

  const GrammarQuestion({
    required this.id,
    required this.level,
    required this.unitTitle,
    required this.prompt,
    this.contextSentence,
    required this.options,
    required this.correctAnswer,
    required this.spanishExplanation,
    required this.audioText,
  });
}

class GrammarUnit {
  final String id;
  final String level;
  final String title;
  final String tag;
  final String subtitle;
  final String ruleSummary;
  final List<Map<String, String>> comparisonExamples;
  final List<GrammarQuestion> questions;

  const GrammarUnit({
    required this.id,
    required this.level,
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.ruleSummary,
    required this.comparisonExamples,
    required this.questions,
  });
}

final List<GrammarUnit> allGrammarUnits = [
"""

for u in units:
    dart_code += f"  const GrammarUnit(\n"
    dart_code += f"    id: {json.dumps(u['id'])},\n"
    dart_code += f"    level: {json.dumps(u['level'])},\n"
    dart_code += f"    title: {json.dumps(u['title'])},\n"
    dart_code += f"    tag: {json.dumps(u['tag'])},\n"
    dart_code += f"    subtitle: {json.dumps(u['subtitle'])},\n"
    dart_code += f"    ruleSummary: {json.dumps(u['ruleSummary'])},\n"
    dart_code += f"    comparisonExamples: [\n"
    for comp in u['comparisonExamples']:
        dart_code += f"      {{\n"
        dart_code += f"        'wrong': {json.dumps(comp['wrong'])},\n"
        dart_code += f"        'right': {json.dumps(comp['right'])},\n"
        dart_code += f"        'tip': {json.dumps(comp['tip'])},\n"
        dart_code += f"      }},\n"
    dart_code += f"    ],\n"
    dart_code += f"    questions: [\n"
    for q in u['questions']:
        dart_code += f"      GrammarQuestion(\n"
        dart_code += f"        id: {q['id']},\n"
        dart_code += f"        level: {json.dumps(u['level'])},\n"
        dart_code += f"        unitTitle: {json.dumps(u['title'])},\n"
        dart_code += f"        prompt: {json.dumps(q['prompt'])},\n"
        dart_code += f"        contextSentence: {json.dumps(q.get('contextSentence'))},\n"
        dart_code += f"        options: {json.dumps(q['options'])},\n"
        dart_code += f"        correctAnswer: {json.dumps(q['correctAnswer'])},\n"
        dart_code += f"        spanishExplanation: {json.dumps(q['spanishExplanation'])},\n"
        dart_code += f"        audioText: {json.dumps(q['audioText'])},\n"
        dart_code += f"      ),\n"
    dart_code += f"    ],\n"
    dart_code += f"  ),\n"

dart_code += "];\n"

target_path = "app/lib/features/grammar/grammar_models.dart"
with open(target_path, "w", encoding="utf-8") as f:
    f.write(dart_code)

print(f"Successfully generated {len(units)} units into {target_path}!")
