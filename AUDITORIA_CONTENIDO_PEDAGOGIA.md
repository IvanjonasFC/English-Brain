# Auditoría de Contenido y Pedagogía — English Brain

> Documento interno de diagnóstico. Foco: **contenido y aprendizaje**, no infraestructura.
> Fecha: 2026-09-09 · Alcance: `app/lib` (Flutter) + `backend/app/seed` + `content_pipeline`.

---

## 1. Resumen ejecutivo

English Brain tiene una **arquitectura pedagógica sólida** (motor adaptativo con mezcla por fase, FSRS transversal, gramática con contraste `wrong/right/tip` orientado a hispanohablantes) pero un **contenido inmaduro y desalineado** respecto a esa arquitectura. El motor es un Ferrari; el depósito va a un cuarto.

Veredicto por dimensión:

| Dimensión | Estado | Nota |
|---|---|---|
| Organización por pantalla | 🟡 Aceptable | Fragmentada en 3 almacenes hardcodeados que se solapan |
| Coherencia de niveles | 🔴 Débil | Dos sistemas paralelos (CEFR vs seniority) sin puente único; 215 preguntas **sin CEFR** |
| Veracidad UI ↔ datos | 🔴 Rota | La pantalla anuncia cifras (18/14/16/20/12/15 términos, % dominio) que **no existen** en los datos |
| Calidad pedagógica intrínseca | 🟢 Buena | Gramática y ejemplos bien construidos; falta volumen y validación externa |
| Volumen y profundidad | 🔴 Insuficiente | Packs Tech de 4–7 términos; sin listening/shadowing real; pipeline vacío |
| Validación de nivel (CEFR) | 🔴 Ausente | Niveles asignados "a ojo", sin EVP/EGP ni dataset de referencia |

**Los 5 arreglos de mayor impacto** (detalle en §8):

1. **Unificar la taxonomía de nivel** en un único eje CEFR canónico, con seniority como *etiqueta secundaria* derivada, no como sistema paralelo.
2. **Sincronizar UI ↔ datos**: que los contadores y el % de dominio salgan de los datos reales, no de literales.
3. **Etiquetar CEFR las 215 preguntas** (hoy solo tienen `junior/mid/senior`).
4. **Engordar los packs Tech finos** (backend, databases, devops, teamwork, interviews, security) hasta ≥12–15 términos útiles.
5. **Activar el pipeline**: dejar de hardcodear contenido en `.dart` y hacerlo entrar como lotes JSON revisables y CEFR-validados.

---

## 2. Mapa de contenido por pantalla

Dónde vive realmente cada cosa y qué la consume:

| Pantalla / Feature | Fuente de datos real | Qué muestra | Estado |
|---|---|---|---|
| **Vocabulario (hub)** `vocabulary_hub_screen.dart` | `_techCollections` **hardcodeado en la propia pantalla** + `VocabularyRepository.packs` | 6 "colecciones Tech" con cifras/% decorativos que enlazan a packs por `packId` | 🔴 Cifras falsas; solo 6 de los packs IT reales |
| **Vocabulario (packs)** `vocabulary_screen.dart` | `vocabulary_repository.dart` (**41 packs, 312 términos**) | Términos con IPA, definición EN, ejemplo, pista ES | 🟢 Estructura buena; 🔴 packs Tech finos |
| **Práctica vocab** `vocabulary_practice_screen.dart` | `VocabularyRepository` + `PracticeEngine` | Quiz adaptativo (recognition, fillBlank, etc.) | 🟢 |
| **Gramática (hub/screen)** `grammar_hub_screen.dart`, `grammar_screen.dart` | `grammar_models.dart` (**~30 `GrammarUnit`, ~250 `GrammarQuestion`**) | Unidades con regla, ejemplos `wrong/right/tip`, drills | 🟢 Calidad alta |
| **Práctica gramática** `grammar_practice_screen.dart` | ⚠️ `ContentSeeds.grammarUnits` (**solo 4 units**, ≠ las ~30 del hub) | Drill runner + mini speaking | 🟡 Usa un set distinto y mucho más pequeño |
| **Entrevistas (hub/pack)** `interview_hub_screen.dart`, `interview_pack_intro_screen.dart` | `ContentSeeds.interviewPacks` (**4 packs**) con `questionIds: []` | Cards de pack con escenario/banda/modo | 🔴 Packs no enlazados a las preguntas |
| **Preguntas** `questions_screen.dart` | API → `backend/app/seed/questions.json` (**215 preguntas**) | Q + `model_answer` + `tips`, filtrado por `category` | 🟡 Buenas, pero **sin CEFR** y sin objetivo comunicativo |
| **Shadowing / Dictation** `shadowing_screen.dart`, `dictation_screen.dart` | — | Requiere audio/transcript | 🔴 Sin banco de frases propio |
| **Recursos** `resources.py` + `published_snapshot.json` | Snapshot publicado (**3 recursos, 5 colecciones, 12 links**) | Enlaces externos (podcasts, YouGlish) | 🟡 Casi vacío |

**Conclusión estructural:** hay **tres almacenes de contenido** que compiten y se solapan —
`content_seeds.dart` (5 vocab + 4 gramática + 4 entrevista), `vocabulary_repository.dart` (41 packs) y `grammar_models.dart` (~30 units) — más un `questions.json` en backend y un `published_snapshot.json` casi vacío. **Ningún contenido pasa por el pipeline** que tú mismo diseñaste (`content_pipeline/`). El contenido está donde es fácil escribirlo (dentro del código), no donde el sistema lo puede gobernar (nivel, provenance, versionado, delta-sync).

---

## 3. Inventario real vs. lo que anuncia la UI

La pantalla de tu captura ("Tech / IT Executive") define las colecciones con literales. Contrastado con los términos reales del pack al que enlaza cada una:

| Colección en la UI | Anuncia | `packId` real | Términos reales | Nivel UI | Coherencia del mapeo |
|---|---|---|---|---|---|
| System Architecture & Scalability | 18 · 75% | `backend` (Backend & Distributed Systems) | **12** | B2-C1 | 🟡 aproximado |
| Numbers, Metrics & Financial Data | 14 · 90% | `databases` (Databases & Storage) | **5** | B2-C1 | 🔴 el pack no trata de métricas/finanzas |
| Agile Ceremonies & Standups | 16 · 62% | `teamwork` (Teamwork & Agile) | **5** | B1 | 🟢 |
| Code Review & Technical Debate | 20 · 85% | `frontend` (Frontend & Modern Web) | **6** | B1 | 🔴 el pack es de frontend, no de code review |
| Client Negotiation & Deadlines | 12 · NUEVO | `interviews` (Tech Interviews & STAR) | **4** | C1 | 🔴 sin relación temática |
| Incident Management & DevOps | 15 · 50% | `devops` (DevOps, Cloud & Infra) | **4** | B2-C1 | 🟢 |

**Dos problemas graves de confianza:**

- **Contadores y % de dominio son literales decorativos.** Un usuario ve "18 términos · Dominio 75%" y abre un pack de 12 términos sin ningún dominio calculado. Esto erosiona la credibilidad de toda la app y falsea el bucle de progreso (que es tu ventaja pedagógica).
- **El mapeo colección→pack es semánticamente incorrecto** en 4 de 6 casos. Las etiquetas prometen un temario (finanzas, code review, negociación) que el pack detrás no cubre.

**Inventario completo de `vocabulary_repository.dart`** (41 packs / 312 términos):

- **General English (32 packs):** buena amplitud A1–C1 — números/colores, familia, ropa, tiempo, transporte, opiniones, pasado, planes, trabajo, salud, casa, saludos, viajes, comida, verbos comunes/irregulares (2 partes), phrasal verbs, conectores, adjetivos/emociones, business email, collocations, idioms, formal/académico. Tamaño típico 6–10 términos. 🟢 Amplitud, 🟡 profundidad.
- **Tech/IT (9 packs):** `foundations` (20), `backend` (12), `ai_ml` (8), `system_design` (8), `security` (7), `frontend` (6), `databases` (5), `teamwork` (5), `devops` (4), `interviews` (4). 🔴 La mitad por debajo de un tamaño útil (< 8).

---

## 4. El problema de niveles: CEFR vs. seniority

Hay **dos ejes de dificultad que no comparten un único origen de verdad**:

| Almacén | Eje primario | ¿Lleva CEFR? | Ejemplo |
|---|---|---|---|
| `taxonomy.dart` (`DifficultyBand`) | **CEFR** (A2-B1, B1-B2, B2-C1, C1) | ✅ nativo | `band: DifficultyBand.b2c1` |
| `vocabulary_repository.dart` | **CEFR** en `level` string | ✅ (texto libre) | `'B2-C1 • Systems'` |
| `grammar_models.dart` | **Seniority** en `level` + **CEFR en `tag`** | 🟡 secundario | `level:'Level 1: Junior'`, `tag:'A2 - B1'` |
| `questions.json` (215) | **Seniority** en `difficulty` | ❌ **ninguno** | `difficulty:'mid'` |

Consecuencias:

- **El motor adaptativo razona en CEFR (`DifficultyBand`)** pero un tercio del contenido (las 215 preguntas) solo tiene `junior/mid/senior`. El engine no puede secuenciar ni mezclar bien lo que no sabe ubicar en la escala.
- **`level` en vocabulario es texto libre** (`'A2-B1 • General'`, `'B2-C1 • Systems'`), no un enum. Frágil para filtrar (el filtro CEFR del hub hace `contains`, que ya es un parche).
- **Seniority ≠ CEFR.** "Senior" describe complejidad *de dominio técnico*; CEFR describe complejidad *lingüística*. Una pregunta de system design puede ser conceptualmente "senior" y lingüísticamente B1. Mezclarlos en un solo `difficulty` confunde ambas señales.

**El estándar correcto** (y lo que resuelven EVP/EGP): **CEFR como eje canónico único** para la dificultad lingüística, y **seniority/escenario como metadatos ortogonales** (a qué rol/situación pertenece). Tu `taxonomy.dart` ya está a un paso: `DifficultyBand` (CEFR) + `LearningScenario` (situación) + `Track` (skill). Solo falta que **todo** el contenido rellene esos tres campos y que se deriven de ahí las etiquetas de seniority, no al revés.

---

## 5. Evaluación pedagógica cualitativa

**Lo que está bien y hay que conservar:**

- **Gramática funcional por objetivo comunicativo**, no por "tiempo verbal" abstracto. `describingExperience`, `hypotheticalTroubleshooting`… es exactamente el enfoque *can-do* del CEFR. 🟢
- **Contraste `wrong → right → tip` centrado en errores L1→L2 de hispanohablantes** (*"I have fixed it yesterday" → "I fixed it yesterday"*, *"since two years" → "for two years"*). Esto es de las cosas más valiosas y difíciles de encontrar en material genérico. 🟢
- **Ejemplos contextualizados al dominio del usuario** (bugs, deploys, incidentes). Aumenta relevancia y retención. 🟢
- **`model_answer` de las preguntas** son respuestas modelo densas y realistas (150–360 chars), con estructura STAR/PPF. 🟢
- **Mini speaking prompt al final de cada drill**: transferencia a producción oral. 🟢

**Lo que falta o cojea:**

- **Sin listening ni shadowing propios.** `Track.listening` existe en la taxonomía pero no hay banco de frases/audio con transcript. Es el skill peor cubierto y el más pedido en entrevistas reales.
- **Sin writing con feedback.** Tu propio TODO señala Write & Improve como el estándar; hoy no hay ni un ejercicio de escritura corta corregible.
- **IPA inconsistente.** Las frases (`hrInterviewEssentials`, phrases) llevan `ipa: ''`. Correcto para frases, pero conviene un criterio explícito (IPA solo en unidades léxicas ≤3 palabras).
- **Entrevista desconectada del banco.** `InterviewPack.questionIds: []` → los packs no tiran de las 215 preguntas. Duplicas esfuerzo y pierdes el filtrado por escenario.
- **Progreso simulado.** El % de dominio de la UI no viene de FSRS. Rompe el "Why this lesson now", que es tu diferencial.
- **Sin validación externa de nivel.** Nada garantiza que un pack "B2-C1" sea realmente B2-C1.

---

## 6. Huecos de contenido priorizados

| Prioridad | Hueco | Por qué importa |
|---|---|---|
| P0 | CEFR en las 215 preguntas | Desbloquea el motor adaptativo sobre un tercio del contenido |
| P0 | Packs Tech a ≥12–15 términos | Son el núcleo de tu propuesta (entrevistas técnicas) y hoy son los más flojos |
| P1 | Banco de listening/shadowing con transcript | Único skill sin contenido; alto valor para entrevistas |
| P1 | Colecciones Tech reales que cumplan su etiqueta (métricas, code review, negociación) | Hoy prometen temario que no existe |
| P1 | Enlazar `interviewPacks` ↔ `questions.json` por escenario | Elimina duplicación, activa filtrado |
| P2 | Writing corto corregible (modelo Write & Improve) | Cubre el 4º skill |
| P2 | Consolidar 3 almacenes en 1 vía pipeline | Deuda estructural; frena el crecimiento |

---

## 7. Encaje de recursos oficiales

Tu lista es correcta. La ordeno por **cómo entra en la app** y añado un hallazgo que cambia el plan.

### 7.1 Recursos que ya identificaste

| Recurso | Rol en English Brain | Cómo se usa (no copiar texto) |
|---|---|---|
| **English Vocabulary Profile (EVP)** | Autoridad para el CEFR de **palabras** | Consulta manual (con login gratuito) para *validar* el nivel de términos dudosos antes de publicar. No tiene export masivo. |
| **English Grammar Profile (EGP)** | Autoridad para el CEFR de **estructuras** | Validar que `describingExperience` (present perfect) sea B1, `hypotheticalTroubleshooting` (3ª condicional) sea B2-C1, etc. |
| **British Council LearnEnglish / Business** | Fuente de *referencia* por nivel | Guardar como `resource` (URL + metadata) en el snapshot; nunca embeber texto. `license: reference_only`. |
| **BBC Learning English** | Clips + transcript para listening/shadowing | Enlazar como recurso; usar los transcripts como *modelo de formato* para tu banco propio de shadowing. |
| **Write & Improve** | *Estándar de diseño* del feedback de writing | No importar; imitar su feedback CEFR en segundos como objetivo de tu módulo de writing. |
| **EF SET** | **Métrica externa honesta** | Test cada 6–8 semanas; contrastar el progreso real contra el XP interno. |

> ⚠️ **Licencia (crítico y ya contemplado en tu `validator.py`):** BBC, British Council y Cambridge son `license != 'own'`. Tu pipeline ya rechaza embeber >350 chars de texto ajeno y exige `sourceUrl`. Mantén esa regla: de estas fuentes solo entran **URLs + metadata**, nunca el texto de la lección.

### 7.2 Hallazgo que no estaba en tu lista — datasets CEFR abiertos y descargables

EVP/EGP son **autoridad pero manual** (sin API, sin export). Para etiquetar **312 términos + 215 preguntas + ~30 unidades en bloque** necesitas algo programático. Existe:

- **`openlanguageprofiles/olp-en-cefrj`** (GitHub): CSVs descargables con nivel CEFR por palabra — `cefrj-vocabulary-profile-1.5.csv` (A1–B2), `octanove-vocabulary-profile-c1c2-1.0.csv` (C1–C2) y **`cefrj-grammar-profile`** (estructuras por nivel). *(Confianza: Alta en existencia; **Media** en licencia exacta — verifícala antes de redistribuir; para uso interno de etiquetado suele bastar.)*
- **`cefrpy`** (PyPI) y **cefrlookup.com**: lookup CEFR de palabras, útiles para un script de auto-etiquetado.

**Flujo recomendado (auto + humano):**

```
Término/pregunta  →  script auto-tag (CEFR-J CSV / cefrpy)  →  cefr propuesto
                  →  revisión humana rápida (CLI content_cli.py) con EVP/EGP para dudas
                  →  publish snapshot vN
```

Así el 80% se etiqueta solo y tú validas solo el 20% dudoso contra la autoridad oficial (EVP/EGP). Esto es lo que convierte "asignar niveles a ojo" en "niveles verificados y defendibles en tu TFG".

---

## 8. Plan priorizado

### P0 — Cimientos de nivel y verdad (antes de añadir nada)

1. **Un solo eje CEFR canónico.** Convertir `level` de vocabulario a `DifficultyBand` (enum) y añadir `cefr` a `questions.json`. Seniority pasa a metadato derivado.
2. **Auto-etiquetado CEFR** con CEFR-J/cefrpy sobre los 312 términos + 215 preguntas; revisión del 20% dudoso contra EVP/EGP.
3. **UI ↔ datos.** Contadores y % de dominio calculados desde el repositorio y FSRS, no literales. Corregir el mapeo colección→pack (o renombrar colecciones para que digan la verdad).

### P1 — Engordar y conectar el núcleo Tech

4. **Packs Tech a 12–15 términos** verificados (backend, databases→*renombrar o crear* "Numbers & Metrics", frontend→"Code Review", devops, teamwork, interviews, security).
5. **Banco de listening/shadowing** propio: 30–50 frases con transcript y audio TTS (ya tienes Speaches), por escenario y CEFR.
6. **Enlazar `interviewPacks` ↔ `questions.json`** por `scenario`, rellenando `questionIds`.

### P2 — Cerrar skills y deuda estructural

7. **Writing corto corregible** (2–3 tareas por objetivo), con feedback estilo Write & Improve vía el LLM local.
8. **Migrar los 3 almacenes al pipeline**: el contenido deja de vivir en `.dart` y entra como lotes JSON versionados.
9. **Ritual EF SET** cada 6–8 semanas como métrica externa.

**Esfuerzo estimado (orden de magnitud):** P0 ≈ 2–3 sesiones · P1 ≈ 4–6 · P2 ≈ continuo.

---

## 9. Formato del contenido nuevo (JSON del pipeline)

Cuando pasemos a generar, entra por `POST /api/content/ingest/batch` con el esquema real de tu `ContentItemIn`. Tres plantillas listas:

**Término de vocabulario (Tech, B2):**
```json
{
  "id": "vocab_backend_b2_013",
  "type": "vocabulary_term",
  "cefr": "B2",
  "scenario": "system_design",
  "objective": "explain_an_api",
  "difficulty": "senior",
  "source_type": "vocabulary",
  "payload": {
    "term": "idempotent",
    "ipa": "/aɪˈdɛm.pə.tənt/",
    "partOfSpeech": "adjective",
    "definition": "producing the same result no matter how many times an operation is repeated",
    "exampleSentence": "We made the payment endpoint idempotent to survive retries safely.",
    "spanishHint": "idempotente",
    "relatedTerms": ["retry", "at-least-once", "deduplication"],
    "kind": "technicalTerm"
  },
  "origin": { "source": "generated", "license": "own", "reviewedBy": "user-ivan" }
}
```

**Unidad de gramática (B2-C1):**
```json
{
  "id": "grammar_passive_incident_reports",
  "type": "grammar_unit",
  "cefr": "B2",
  "scenario": "debugging",
  "objective": "explaining_cause_result",
  "difficulty": "senior",
  "source_type": "grammar",
  "payload": {
    "title": "Passive voice in incident reports",
    "guidebook": "Use the passive to keep focus on the system, not the person...",
    "keyContrasts": ["Active: 'We deployed a bad config.' → Passive: 'A bad config was deployed.'"],
    "commonEsMistakes": ["✗ 'It was happened' → ✓ 'It happened' (happen no es pasivo)"],
    "drills": [{"type": "fill_blank", "prompt": "The service ___ (restart) automatically.", "answer": "was restarted"}],
    "miniSpeakingPrompts": ["Describe your last outage using the passive for the timeline."]
  },
  "origin": { "source": "generated", "license": "own", "reviewedBy": "user-ivan" }
}
```

**Recurso externo referenciado (BBC/British Council — solo metadata):**
```json
{
  "id": "res_bbc_6min_english_ai",
  "type": "shadowing_phrase",
  "cefr": "B1",
  "scenario": "workplace",
  "source_type": "shadowing",
  "payload": { "title": "6 Minute English — AI at work", "note": "Listening + transcript for shadowing" },
  "origin": {
    "source": "referenced",
    "license": "reference_only",
    "sourceUrl": "https://www.bbc.co.uk/learningenglish/",
    "reviewNotes": "Solo enlace + metadata; sin texto embebido (regla del validator)."
  }
}
```

Regla de oro heredada de tu `validator.py`: **`license: own`** solo para contenido que generamos original (parafraseado, no copiado); todo lo de BBC/BC/Cambridge entra como **`reference_only` con `sourceUrl`** y sin texto.

---

## 10. Métricas de éxito

| Métrica | Hoy | Objetivo |
|---|---|---|
| % de contenido con CEFR verificado | ~60% (vocab+gramática) / 0% preguntas | 100% |
| Términos por pack Tech (mediana) | ~6 | ≥12 |
| Skills con banco propio | 3/4 (falta listening real y writing) | 4/4 |
| Almacenes de contenido | 3 hardcodeados + pipeline vacío | 1 vía pipeline |
| Coherencia UI ↔ datos | contadores falsos | 100% derivado de datos/FSRS |
| Progreso validado externamente | ninguno | EF SET cada 6–8 semanas |

---

### Punto contraintuitivo para cerrar

Tu instinto ("añadir más contenido para dejar la app completa") es probablemente el orden equivocado. **Añadir más términos ahora amplifica el problema**, no lo resuelve: multiplicas contenido sin nivel verificado, en tres almacenes que se solapan, mostrado tras una UI que ya miente sobre las cifras. El movimiento de mayor retorno pedagógico no es *más* contenido, sino **poner un único eje CEFR verificado y una UI que diga la verdad** — y solo entonces verter volumen por el pipeline. Un pack de 12 términos correctamente nivelados enseña más que 30 mal ubicados en la escala.

**¿Empezamos el P0 por el auto-etiquetado CEFR (script + CSV de CEFR-J sobre tus 312 términos y 215 preguntas), o prefieres que primero prepare el primer lote JSON de expansión del pack Tech más crítico (`backend` / System Architecture) para que veas el formato en acción?**
