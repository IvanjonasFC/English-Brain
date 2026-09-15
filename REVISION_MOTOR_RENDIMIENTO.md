# Revisión: Motor de Práctica y Rendimiento con Volumen

> Foco: ¿el motor FSRS y el render de listas aguantan 510 términos + 243 drills, y la recomendación es de calidad?
> Fecha: 2026-09-09 · Ficheros: `core/pedagogy/*`, `features/vocabulary/*`, `features/deck/*`, `features/grammar/*`.

## Veredicto

El volumen **no** provoca problemas de rendimiento: las listas visibles son pequeñas (packs ≤20 términos, ≤40 tarjetas de gramática por pestaña) y el motor es puro y O(n) sobre pools reducidos. El riesgo no es la velocidad; son **tres desconexiones** que hacen que todo el trabajo de CEFR y el motor adaptativo no lleguen al usuario. Dicho de otro modo: acabas de subir la calidad del combustible, pero el motor bueno está desembragado.

## Hallazgos (por severidad)

| # | Sev | Hallazgo | Evidencia |
|---|---|---|---|
| 1 | 🔴 Alta | **El motor adaptativo NO alimenta la práctica de vocabulario.** El quiz hace `shuffle + take(10)` de un solo pack e ignora `PracticeEngine`, las mezclas 70/20/10, el repaso reciente/espaciado y FSRS. | `vocabulary_practice_screen.dart:_buildExercises()` usa `getVocabularyItemsForPack(packId)` directo; nunca instancia `PracticeEngine`. |
| 2 | 🔴 Alta | **`DifficultyBandX.parse(level)` está roto para tus niveles.** El enum `DifficultyBand` solo tiene `{a2b1, b1b2, b2c1, c1}`; tus niveles ahora son single (A1/A2/B1/B2/C1), anchos (A1-B2…) y llevan sufijo `• Systems`. `parse` hace `replaceAll(' ','')` y matchea 4 strings exactos → **todo cae al default `b1b2`**. La taxonomía CEFR es invisible al motor. | `vocabulary_adapter.dart`: `band: DifficultyBandX.parse(level)`; `taxonomy.dart:DifficultyBandX.parse`. |
| 3 | 🟠 Media | **Métricas falsas en la UI** (mismo patrón que los contadores que ya corregimos). El hero "SESIÓN RECOMENDADA FSRS" muestra `14 términos por consolidar` y `8 min` **hardcoded**; `vocabulary_screen` calcula `retention` como `60 + (term.length*4)%35` (retención derivada de la longitud de la palabra). | `vocabulary_hub_screen.dart:453`, `:472`; `vocabulary_screen.dart:228`. |
| 4 | 🟠 Media | **Ningún `ListView.builder`.** `grammar_hub` recomputa el getter `_filteredUnits` (77 units) y construye TODAS las tarjetas filtradas en un `Column` dentro de `SingleChildScrollView` en cada `build`; `vocabulary_screen` recomputa varios `.where` por build. Correcto a 77/20, pero no escala y desperdicia frames. | `grammar_hub_screen.dart:101,138`; `vocabulary_screen.dart:499-500,873`. |
| 5 | 🟡 Baja | **Deck carga todo el mazo `due` en memoria** y revisa de uno en uno; sin límite/paginación. El `sort` se hace una vez al cargar (bien). | `deck_screen.dart:66 _sortDueFirst(loaded)`; `:289 ListView(` es la home fija, no la lista de cartas. |
| 6 | 🟡 Baja | **Quiz con seed determinista por pack** (`packId.hashCode ^ const`): el mismo pack da siempre el mismo orden y distractores. Conviene variar por día para no memorizar posición. Distractores tomados del mismo pack: correcto pedagógicamente. | `vocabulary_practice_screen.dart:96` |

## Lo que está bien (conservar)

- `PracticeEngine` y `PracticeService` son **puros, testables y O(n)**: mezcla por fase, interleaving controlado, variación reproducible por seed, mastery con media móvil exponencial (EMA), XP/streak coherentes.
- Deck: `sort` una sola vez en carga, `dispose` limpio de micro y timers, fallback anti-crash en pack vacío.
- El render actual **no lagea** con el volumen nuevo.

## El punto clave

No tienes un problema de rendimiento; tienes un problema de **cableado**. El hallazgo #1 y #2 significan que tus 510 términos con CEFR verificado y tu motor 70/20/10 hoy **no se usan** en el flujo principal de vocabulario: el usuario recibe 10 términos al azar de un pack, sin nivel, sin repaso espaciado, sin FSRS. Es el mayor retorno pendiente y no cuesta contenido, cuesta conectar tres cables:

1. **Conectar** `vocabulary_practice_screen` al `PracticeEngine` (construir `CandidateItem` desde el pack + due de FSRS, y pedir el plan al motor).
2. **Arreglar el nivel**: dar a `CandidateItem`/adapter un `cefr` estructurado (o ampliar el enum a A1–C1 y parsear separando el sufijo `•`).
3. **Quitar los literales**: que `14 términos` y `retention` salgan de FSRS/`unitProgressLocal`, no de constantes ni de `term.length`.

## Recomendación de prioridad

| Paso | Esfuerzo | Efecto |
|---|---|---|
| Fix `DifficultyBandX.parse` (split `•`, mapear single/anchos) + `cefr` en CandidateItem | Bajo | El motor "ve" el nivel real |
| Cablear el quiz de vocab al `PracticeEngine` con pools desde FSRS | Medio | Activa mezcla adaptativa y repaso |
| Sustituir literales del hero y `retention` por datos FSRS reales | Bajo | Credibilidad + bucle "why now" real |
| Migrar `grammar_hub`/listas largas a `ListView.builder` cuando superen ~60 visibles | Bajo | Escalabilidad futura |

### Contraintuitivo

El instinto sería optimizar el render "por si acaso" con tanto contenido. No hace falta: Flutter aguanta de sobra 40 `Column` y pools de 20. El verdadero desperdicio es que el motor sofisticado que ya escribiste está **apagado** en el camino que más usa el usuario. Conectar tres cables rinde más que cualquier optimización de listas.
