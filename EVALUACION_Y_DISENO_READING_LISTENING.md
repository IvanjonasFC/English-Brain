# Evaluación de contenido por pestaña + Diseño de la pestaña Reading & Listening

> Documento interno. Parte A: estado real de cada pestaña (robusto / útil / qué falta). Parte B: diseño de la nueva pestaña Reading & Listening.
> Fecha: 2026-09-09.

---

## Parte A — Evaluación por pestaña

Escala: 🟢 robusto y útil · 🟡 funciona pero incompleto · 🔴 flojo o vacío.

| Pestaña | Contenido hoy | Estado | Qué falta para completarla |
|---|---|---|---|
| **Inicio (Home)** | Next Best Action, "why this lesson now", resumen de perfil | 🟡 | Que las recomendaciones tiren de datos FSRS reales (due, debilidades), no de heurística fija; enlazar directo a la sesión que propone |
| **Entrevista / Speaking** | Packs desde backend: **7 General (A2→C1) + 4 Tech**; intro con pregunta/consejo/conectores; simulación oral con STT+STAR | 🟢 (General) 🟡 (Tech) | Huecos deliberados: **Tech+Foundations** y **Tech+Strategic** sin packs. Preguntas por pack (`questionIds` vacío) → enlazar al banco de 215 |
| **Vocabulario** | **44 packs / 510 términos** CEFR-verificados, IT + General todos los niveles; quiz cableado a `PracticeEngine` + FSRS | 🟢 | Audio real por término (ya hay TTS); que "dominio %" salga de FSRS, no decorativo; algún pack fino aún (backend base) |
| **Gramática** | **77 unidades / 243 drills**, General A2–C1 + IT + registro C1; contrastes wrong/right/tip; ingesta de fallos a FSRS | 🟢 | Nada crítico; opcional: más unidades C1 de registro profesional |
| **Mazo FSRS** | Repaso transversal (vocab+gramática+entrevista); repaso espaciado cross-pack cableado; ingesta de fallos desde vocab y gramática | 🟢 | Que la entrevista también ingiera fallos al mazo; migrar a `ListView.builder` si crece |
| **Preguntas** | **215** con CEFR; filtro por categoría | 🟡 | Sin objetivo comunicativo ni enlace a los packs de entrevista; sin práctica hablada sobre ellas |
| **Recursos** | **3 recursos, 5 colecciones** (snapshot casi vacío) | 🔴 | Es el gancho natural para Reading/Listening: enlaces BBC/British Council por nivel (solo URL+metadata, licencia `reference_only`) |
| **Perfil / Stats** | XP, racha, actividad diaria | 🟡 | Métrica externa (EF SET cada 6–8 semanas) y desglose por skill (los 4: speaking/listening/reading/writing) |

**Lectura transversal:** el eje **producción** está fuerte (vocabulario, gramática, speaking) y el eje **recepción** (listening, reading) **no existe como práctica evaluable** — solo enlaces externos casi vacíos en Recursos. Los 4 skills del MCER: hoy cubres speaking (🟢), y reading/listening (🔴). Writing sigue sin cubrir. La pestaña que propones **cierra el hueco más grande de la app**.

---

## Parte B — Pestaña Reading & Listening

### B.0 Idea en una frase

Una pestaña de **comprensión** (input) gemela de las de producción: mismos patrones (segmento General/Profesional, rail CEFR, contenido desde backend, color de acento propio), con **textos** y **audios** de dificultad y categoría variables, y **preguntas comprobables** en dos formatos: **test (opción múltiple)** y **respuesta hablada** (verificada con el STT que ya tienes).

### B.1 Encaje visual (coherente con el resto)

- **Nombre e icono**: "Comprensión" o "Reading & Listening" · icono `Icons.menu_book_rounded` / `Icons.headphones_rounded`.
- **Color de acento**: **teal `#0D9488`** (verde azulado). Libre en tu paleta actual (deck=violeta, interview=ámbar, vocab=rosa/naranja, grammar=azul) y ya lo usabas para la colección de podcasts, así que "suena" a listening. Crear `reading_theme_tokens.dart` clonando el patrón de `fsrs_theme_tokens.dart` con esa base.
- **Estructura idéntica**: título + subtítulo, **toggle dual "Inglés General / Inglés Profesional"**, **rail CEFR** (A1-A2 / B1 / B2 / B2-C1 / C1), tarjeta hero "Sesión recomendada", y lista de piezas por categoría — exactamente como Vocabulario y Speaking.

> Nota de navegación: la barra inferior ya tiene 6 items (Inicio, Entrevista, Vocabulario, Gramática, Mazo, Perfil). Un 7º aprieta. Opciones: (a) sub-toggle Reading/Listening **dentro** de una sola pestaña "Comprensión"; (b) mover "Preguntas" y "Recursos" a un menú "Más" y meter Comprensión en la barra. Recomiendo (a): **una pestaña, dos modos** (Leer / Escuchar) con el mismo color.

### B.2 Modelo de datos (backend, mismo patrón que `packs.py`)

Nuevo `backend/app/routers/comprehension.py`, endpoint `GET /api/comprehension?domain=&skill=&band=`. Cada pieza:

```json
{
  "id": "read_tech_b2_001",
  "skill": "reading",              // reading | listening
  "domain": "tech",                // general | tech
  "band": "b2",                    // a1..c1
  "category": "incident_report",   // taxonomía por dominio
  "title": "A post-mortem for a 3 a.m. outage",
  "body": "At 03:14, latency spiked...",   // texto (reading) o guion (listening→TTS)
  "estMinutes": 5,
  "wordCount": 180,
  "glossary": [{"term": "throughput", "es": "caudal"}],
  "questions": [
    {"type": "mcq", "q": "What caused the outage?",
     "options": ["A missing index", "A DDoS", "A bad deploy"], "answer": 0,
     "explanation_es": "El texto dice 'a missing index on the orders table'."},
    {"type": "spoken", "q": "In one sentence, summarize the root cause.",
     "expected_keywords": ["missing", "index", "orders"],
     "model_answer": "The root cause was a missing index on the orders table."}
  ],
  "origin": {"source": "generated", "license": "own"}
}
```

Reutiliza tu pipeline de contenido (revisión + CEFR + licencia) y el auto-etiquetado CEFR-J para validar el nivel del texto por su léxico.

### B.3 Listening sin grabar audios a mano (tu intuición del TTS/traducción)

**No necesitas subir mp3.** El "audio" es el mismo `body`/guion pasado por tu **`/tts`** (Speaches) — igual que ya haces en vocabulario y gramática. Ventajas: cero ficheros, control de velocidad (0.8×/1.0×) ya implementado, y el mismo texto sirve para Reading y Listening. La "traducción" que mencionas encaja como **ayuda opcional** (mostrar el ES bajo demanda, generado por tu LLM local `ai.py`), no como el motor del audio.

- **Reading** = se muestra el texto; opcional "escúchalo" (TTS) y "tradúcelo" (LLM).
- **Listening** = se oculta el texto y solo suena el TTS; el usuario responde de oído; el texto se revela al comprobar.

### B.4 Preguntas comprobables (los dos formatos que pides)

1. **Test (MCQ)** — comprobación local instantánea (índice correcto), con explicación en español y, si falla, **ingesta al mazo FSRS** (ya tienes `ReviewIngestionService`: `sourceType: listening/reading`, `itemType: comprehension`).
2. **Respuesta hablada** — el usuario graba; se transcribe con **`/pronunciation/check`** (Whisper) y se puntúa. Dos niveles de comprobación, de menor a mayor esfuerzo:
   - **v1 (sin coste extra):** cobertura de `expected_keywords` sobre la transcripción + score fonético → "3/3 ideas clave, pronunciación 88%". Determinista y barato.
   - **v2 (más rico):** mandar transcripción + `model_answer` a tu LLM local (`ai.py`) para un veredicto semántico ("captaste la causa pero te faltó el impacto"). Reutiliza el patrón STAR que ya evalúa en la entrevista.

### B.5 Taxonomía de contenido (dificultad × categoría × dominio)

| Dominio | Categorías sugeridas | Bandas |
|---|---|---|
| **General** | Small talk, viajes, noticias breves, correos, vida diaria, cultura | A1-A2 → C1 |
| **Profesional/Tech** | Post-mortems, release notes, RFC/design docs, code review, standup recap, cliente/negociación | B1 → C1 |

Arranque realista: **2 piezas por (dominio × banda)** = ~20 textos + ~20 guiones de listening, cada una con 3 MCQ + 1 spoken. Generadas por ti (licencia `own`), CEFR-validadas. Los recursos externos (BBC 6 Minute English, British Council) entran **como enlaces** en la pieza ("escucha el original aquí"), nunca copiando su texto.

### B.6 Plan de construcción por fases

| Fase | Alcance | Reutiliza |
|---|---|---|
| **1 — Reading MVP** | Endpoint `comprehension` + pantalla lectora con toggle/rail + MCQ comprobable + FSRS en fallo | patrón `packs.py`, hub de vocabulario, `ReviewIngestionService` |
| **2 — Listening** | Mismo contenido con texto oculto + botón TTS (0.8×/1.0×) + revelar al comprobar | `/tts`, controles de audio de gramática |
| **3 — Respuesta hablada** | Pregunta abierta → grabar → `/pronunciation/check` → keywords + score | `/pronunciation/check`, flujo de grabación de la entrevista |
| **4 — Traducción y glosario** | ES bajo demanda (LLM) + glosario tocable que ingiere términos al mazo | `ai.py`, deck FSRS |
| **5 — Semántico (opcional)** | Veredicto LLM de la respuesta hablada | patrón de evaluación STAR |

### B.7 Métricas de completitud

| Métrica | Objetivo v1 |
|---|---|
| Piezas Reading (general+tech, A1–C1) | ≥ 20 |
| Piezas Listening | ≥ 20 (mismo texto vía TTS) |
| Preguntas por pieza | 3 MCQ + 1 hablada |
| Comprobación hablada | keywords + score fonético (v1) |
| Skills MCER cubiertos | 3/4 (añade listening+reading; falta writing) |

---

### Punto contraintuitivo

La tentación es tratar Reading y Listening como dos pestañas distintas con dos bancos de contenido. Es el doble de trabajo para nada: **un solo texto es a la vez lectura y —vía tu TTS— audio**. La diferencia no está en el contenido sino en *si se enseña el texto o se oculta*. Diséñalo como **una pieza, dos modos de consumo**, y el contenido que crees rinde el doble. Y el verdadero hueco pedagógico que te queda después de esto no es más input: es **writing** — el único de los 4 skills sin práctica evaluable, y el que Write & Improve te marca como estándar.

**¿Quiero que arranque la Fase 1 (Reading MVP: endpoint `comprehension` + pantalla + MCQ + FSRS) con el color teal, o prefieres que primero cierre los dos huecos de Tech en Speaking que quedaron pendientes?**
