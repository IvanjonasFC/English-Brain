# Arquitectura pedagógica del motor de práctica — English Brain

**Estado**: Tareas 1 a 6 completamente implementadas y verificadas con suite de tests automatizados (100% passing, 0 analyzer errors).

---

## 1. Idea Central
El aprendizaje en English Brain trasciende los filtros planos unidimensionales (`category`) para estructurarse en **objetivos comunicativos reales** con **mezcla inteligente adaptativa**:
- **85% nuevo / 15% repaso / 0% espaciado** en fase `fresh` (guiada).
- **70% objetivo actual / 20% repaso reciente / 10% repaso espaciado** en fase `learning`.
- **50% reto / 30% consolidación / 20% espaciado** en fase `mastered`.

Incorpora **interleaving controlado**, **variación reproducible por semilla** y **retroalimentación pedagógica inmediata**.

---

## 2. Componentes del Rediseño Pedagógico

### A. Badge `engine_used` (Entrevistas y Sesiones)
- **Modelos (`TurnOut`)**: Soporte del campo `engineUsed` retornado por el backend FastAPI (`app/lib/core/models/api_models.dart`).
- **UI en `interview_screen.dart`**: Renderizado de un badge dinámico en la cabecera del turno evaluado:
  - *Motor Rápido (GPU)*: Icono `Icons.bolt_rounded`, color ámbar/primario, tooltip indicando inferencia acelerada local/worker.
  - *Motor Estándar*: Icono `Icons.cloud_off_rounded`, tooltip indicando fallback CPU/estándar.
- **Verificación**: `test/engine_badge_test.dart` (6/6 tests pasando).

### B. FSRS Transversal con Origen en el Deck
- **Modelo de Carta (`CardOut`)**: Extensión con `sourceType` (`vocabulary`, `grammar`, `interview`), `itemType`, `unitOrPackId`, `skill` y getter `effectiveOrigin` (`app/lib/core/models/api_models.dart`).
- **Deck Screen (`deck_screen.dart`)**:
  - Badge de origen visual en cada tarjeta (Vocabulario, Gramática, Entrevista STAR/Tech) con paleta semántica dedicada.
  - Filtro horizontal de skills (`All`, `Vocabulary`, `Grammar`, `Interview`, `Speaking`).
  - Ordenación pedagógica multicriterio: factor de urgencia FSRS (due date) + peso por origen según el objetivo activo.
  - Merge offline-first con IDs sintéticos negativos preservando cartas locales pendientes de sync.
  - Estado vacío premium con CTA directo para volver a practicar.
- **Verificación**: `test/deck_transversal_test.dart` (5/5 tests pasando).

### C. Gramática como Rutas Funcionales
- **Estructura en `content_seeds.dart`**: Unidades de gramática funcional (`GrammarUnitDef`) organizadas por objetivos comunicativos (`describingExperience`, `hypotheticalTroubleshooting`, etc.).
- **Hub de Gramática (`grammar_hub_screen.dart`)**:
  - Guía pedagógica previa a los drills: explicaciones breves, contrastes clave (p. ej. *Present Perfect vs Past Simple*) y errores típicos de hispanohablantes (*"I have worked yesterday"* -> *"I worked yesterday"*).
- **Drill Runner Duolingo-Style (`grammar_practice_screen.dart`)**:
  - Ejecución de sesiones adaptativas mediante `PracticeEngine`.
  - Ingesta automática de fallos al deck FSRS mediante `ReviewIngestionService` con tipo `sentenceCorrection`.
  - Mini speaking prompt al final del drill para transferencia activa a producción oral.
- **Verificación**: `test/grammar_functional_routes_test.dart` (3/3 tests pasando).

### D. Entrevistas Estructuradas por Packs + Pantalla Intermedia
- **Packs Semilla (`content_seeds.dart`)**:
  - `systemDesignTradeoffs` (Systems Design, A2-B1, 15 min, simulación técnica).
  - `behavioralConflict` (HR STAR, B1-B2, 10 min, checkpoint conductual).
  - Extensiones `label` en `taxonomy.dart` para `LearningScenario` y `PracticeMode`.
- **Pantalla Intermedia (`interview_pack_intro_screen.dart`)**:
  - Card Hero con título, descripción y badges de escenario, banda CEFR, duración estimada y modo.
  - Bloque de Objetivo de la Sesión y chips de habilidades entrenadas.
  - Criterios de evaluación de la IA y tips tácticos antes de iniciar el audio.
  - CTA principal "Empezar Entrenamiento" que inicia el simulador con la configuración exacta del pack.
- **Verificación**: `test/interview_pack_flow_test.dart` (3/3 tests pasando).

### E. UX Premium & Bucle de Feedback de Progreso
- **Cálculo de Progreso (`PracticeImprovement`)**: En `PracticeService`, cálculo de delta de maestría (`deltaPercent`), XP ganado, racha y total de intentos.
- **Invalidación Reactiva**: Invocación de `ref.invalidate(profileSummaryProvider)` tras completar ejercicios en `grammar_practice_screen.dart`, `vocabulary_practice_screen.dart` e `interview_screen.dart`.
- **Completion State**:
  - Bloque visual *"Qué has mejorado"* (*"What you improved"*) mostrando incremento de maestría, puntos XP y racha.
- **Contexto "Por qué ahora" (*"Why this lesson now"*)*:
  - En `HomeScreen`: dentro del banner de *Next Best Action*, justificando pedagógicamente la recomendación según debilidades y espaciado.
  - En `GrammarHubScreen`: badges contextuales dinámicos en cada tarjeta de unidad (*"Refuerza tu precisión técnica"*, *"Frecuente en entrevistas"*, etc.).
- **Verificación**: `test/ux_premium_feedback_test.dart` (4/4 tests pasando).

### F. Verbs Lab & Dominio Compuesto de Verbos Irregulares
- **Taxonomía Limpia**: Desacoplamiento de phrasal verbs técnicos (`spin up`, `wind down`) de la matriz base de formas (`spin`, `wind`).
- **5 Rutas CEFR Funcionales**:
  - `A1-A2 Essentials` (12 verbos de alta frecuencia comunicativa).
  - `A2-B1 Everyday & Work` (12 verbos de tareas y reuniones).
  - `B1-B2 Projects & Interviews` (12 verbos para respuestas STAR y proyectos).
  - `B2-C1 Senior Technical` (13 verbos de arquitectura y post-mortems).
  - `C1+ Advanced Precision` (5 verbos avanzados).
- **Fórmula de Maestría Compuesta**:
  $$\text{mastery} = 0.25 \cdot \text{recognition} + 0.30 \cdot \text{form\_recall} + 0.20 \cdot \text{contextual\_usage} + 0.15 \cdot \text{listening} + 0.10 \cdot \text{pronunciation}$$
- **Condiciones de Dominio (`isMastered`)**:
  1. $\ge 2$ recuperaciones correctas de V2/V3 en días distintos.
  2. $\ge 1$ ejercicio de listening superado.
  3. $\ge 1$ producción en contexto superada.
- **Sesión Multimodal (10 pasos)**: 2 Discriminación auditiva, 3 Recuperación de forma, 2 Construcción de frases, 1 Corrección de errores, 1 Shadowing, 1 Producción oral (STAR).
- **Ingesta FSRS Automática**: Cada fallo genera una tarjeta de revisión con `sourceType: irregular_verbs` y metadata del error.
- **Verificación**: `test/irregular_verbs_test.dart` (7/7 tests pasando).

### G. Phrasal Verbs Lab & Partículas Conceptuales
- **Estructura Pedagógica**: Agrupación por metáfora raíz de la partícula (*UP: completitud/inicio*, *OUT: resolución/exterior*, *DOWN: reducción/parada*, *OFF: desconexión/cancelación*, *BACK: reversión/reserva*).
- **5 Rutas CEFR**:
  - `A1-A2 Essentials & Daily Actions` (*turn on*, *turn off*, *look for*, *wake up*, *get up*, *come in*, *log in*, *go back*).
  - `A2-B1 Everyday & Teamwork` (*catch up*, *figure out*, *find out*, *give up*, *check in*, *run out of*).
  - `B1-B2 Projects & Dailies` (*set up*, *roll out*, *break down*, *point out*, *kick off*, *carry out*, *hand off*, *wrap up*).
  - `B2-C1 Architecture & Incidents` (*spin up*, *roll back*, *fall back on*, *drill down*, *scale up*, *scale down*, *shut down*, *sign off*).
  - `C1+ Senior Nuance & Precision` (*phase out*, *iron out*, *boil down to*, *flesh out*, *weed out*).
- **Connected Speech & Audio Enlazado**: Enlace fonético obligatorio consonante-vocal (ej. `/spɪˈnʌp/` para *spin up*, `/roʊˈlaʊt/` para *roll out*).
- **Fórmula de Maestría Compuesta**:
  $$\text{mastery} = 0.30 \cdot \text{meaning} + 0.25 \cdot \text{sentence} + 0.20 \cdot \text{listening} + 0.15 \cdot \text{pronunciation} + 0.10 \cdot \text{speaking}$$
- **Sesión Multimodal (10 pasos)**: 2 Discriminación auditiva enlazada, 3 Reemplazo formal/partícula, 2 Construcción en Dailies/Incidentes, 1 Corrección de separabilidad, 1 Shadowing, 1 Speaking oral.
- **Ingesta FSRS Automática**: Fallos ingestados en Drift con `sourceType: 'phrasal_verbs'`.
- **Verificación**: `test/phrasal_verbs_test.dart` (6/6 tests pasando).

---

## 3. Persistencia y Modelos de Datos

### Drift SQLite (Schema v5)
- **`CardsLocal`**: `sourceType`, `itemType`, `unitOrPackId`, `skill`, `userId`.
- **`UnitProgressLocal`**: Dominio, estado, streak y timestamps por objetivo comunicativo.
- **`PracticeAttemptsLocal`**: Registro analítico granular por intento con telemetría de errores.
- **`UserSettingsLocal`**: Persistencia local de locale, daily goal y perfil activo.

### Backend FastAPI
- `Card`: Columnas multiusuario y transversales (`user_id`, `source_type`, `item_type`, `unit_id`, `skill`).
- `POST /cards/ingest`: Endpoint para ingesta unificada de flashcards FSRS desde cualquier módulo.
- `Question`: Campos pedagógicos opcionales (`track`, `scenario`, `objective_id`, `difficulty_band`).

---

## 4. Guía de Ejecución y Validación

### Validación de la App Flutter
```powershell
cd app

# 1. Regenerar código de Drift si se modifican tablas
dart run build_runner build --delete-conflicting-outputs

# 2. Generar traducciones i18n
flutter gen-l10n

# 3. Análisis estático (0 errores garantizados)
dart analyze

# 4. Suite completa de tests
flutter test
```

### Tests Específicos del Motor Pedagógico
```powershell
flutter test test/engine_badge_test.dart
flutter test test/deck_transversal_test.dart
flutter test test/grammar_functional_routes_test.dart
flutter test test/interview_pack_flow_test.dart
flutter test test/ux_premium_feedback_test.dart
flutter test test/pedagogy/practice_engine_test.dart
flutter test test/irregular_verbs_test.dart
```
