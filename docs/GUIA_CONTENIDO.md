# Guía de Contenido — English Brain

Cómo buscar, calificar (CEFR) y añadir contenido en cada dificultad y cada
ventana, respetando la parte **offline** (assets) y la parte **backend** (seeds).
Documento interno de trabajo.

---

## 1. Modelo de dificultad: 4 bandas, una sola fuente de verdad

Toda la app usa el mismo rail CEFR, definido en un único sitio:
`app/lib/core/theme/tab_theme.dart` → `TabTheme.cefrRail`.

| id (rail) | Etiqueta UI | Banda del motor | Color | Perfil típico |
|-----------|-------------|-----------------|-------|---------------|
| `all` | Todos | — | gris | filtro "sin filtrar" |
| `A1-A2` | A1 - A2 | `a2b1` | menta | principiante |
| `B1-B2` | B1 - B2 | `b1b2` | cyan | intermedio |
| `B2-C1` | B2 - C1 | `b2c1` | terracota | avanzado |
| `C1` | C1 Executive | `c1` | lavanda | dominio |

El motor (`app/lib/core/pedagogy/taxonomy.dart` → `DifficultyBand`) tiene
exactamente esas 4 bandas. La función `DifficultyBandX.parse()` convierte
**cualquier** etiqueta a una de las 4, **por el nivel más alto presente**, y
acepta:

- Etiquetas CEFR sueltas o rango: `A1`, `A2`, `B1`, `B2`, `C1`, `C2`, `A1-A2`, `B1-B2`, `B2-C1`.
- Nombres de enum: `a2b1`, `b1b2`, `b2c1`, `c1`.
- Sufijos de track: `B2 • Systems`, `B1-B2 • Executive` (corta en el `•`).

El filtrado por píldora es **1:1 con la banda del motor** (una sola función,
`Cefr.matchesPill` en `vocabulary_repository.dart`): un contenido aparece bajo
la píldora cuya banda coincide con `parse(nivel_del_contenido)`.

### Regla de oro al etiquetar

Etiqueta cada contenido con **una de las 4 bandas canónicas** (`A1-A2`,
`B1-B2`, `B2-C1`, `C1`). Como `parse` clasifica por el nivel más alto:

- `A1-B1` cae en **B1-B2** (su techo es B1 → sube). Si querías que fuera
  principiante, etiqueta `A1-A2`.
- `A2-B2` cae en **B1-B2**.
- `B2` suelto cae en **B1-B2** (no hay cubo "B2" propio).

Evita rangos amplios (`A1-B2`): elige el cubo donde quieres que aparezca.

---

## 2. Cómo se muestra el contenido: offline + backend

**Fuente de verdad = `backend/app/seed/*.json`.** La app es *local-first*:

```
Al abrir una pestaña:
  1) pinta AL INSTANTE desde:  caché (SharedPreferences) -> asset offline -> const compilado
  2) en 2º plano revalida el backend y actualiza la caché para el próximo open
Pull-to-refresh:  fuerza fetch del backend -> guarda caché -> repinta
```

Consecuencia práctica (clave para tu flujo):

| Qué cambias | ¿Requiere recompilar APK? |
|-------------|---------------------------|
| Contenido nuevo en el **backend** (seeds + rebuild backend) | **NO.** Aparece con *pull-to-refresh* en la app ya instalada |
| Que la **línea base offline** (recién instalado / sin red) traiga el contenido nuevo | Sí: `sync_offline_seeds.py` + `make shorebird-patch` (o APK) |
| Código Dart (pantallas, lógica) | Sí (`make shorebird-patch` o hot reload en desarrollo, ver §6) |

Es decir: **para cargar contenido no necesitas generar un APK cada vez.** Subes
al backend y refrescas. El APK solo se rehace de vez en cuando para actualizar
la copia offline.

---

## 3. Dónde va cada contenido (por ventana)

| Ventana | Seed backend | Asset offline | Campo que marca CEFR | Se filtra por |
|---------|--------------|---------------|----------------------|---------------|
| Vocabulario | `backend/app/seed/vocab.json` | `app/assets/seed/vocab.json` | `level` (`"B1-B2 • Systems"`) | `Cefr.matchesPill(level)` |
| Gramática | `backend/app/seed/grammar.json` | `app/assets/seed/grammar.json` | `tag` (`"B1 - B2"`) | `Cefr.matchesPill(tag)` |
| Inmersión (Reading/Listening) | `backend/app/seed/comprehension_seed.json` | `app/assets/seed/comprehension.json` | `band` (`"B2-C1"`) | `Cefr.matchesPill(band)` |
| Entrevista — packs | `backend/app/seed/interview.json` | `app/assets/seed/interview.json` | `band` (`"b1b2"` o `"B1-B2"`) | `Cefr.matchesPill(band.label)` |
| Entrevista — preguntas | `backend/app/seed/questions.json` | (vía backend) | `cefr` + `difficulty` | `difficulty` al iniciar; `cefr` para etiqueta |

### Esquema mínimo por archivo

**vocab.json** (lista de packs):
```json
{
  "id": "systems_scaling",
  "title": "Systems & Scaling",
  "description": "Vocabulario de sistemas distribuidos.",
  "iconCodePoint": 983105, "iconFontFamily": "MaterialIcons",
  "level": "B1-B2 • Systems",           // <- una de las 4 bandas + track opcional
  "accentColorValue": 4294210230,
  "terms": [
    { "term": "throughput", "ipa": "/ˈθruːpʊt/",
      "definition": "Amount of work processed per unit of time.",
      "exampleSentence": "We doubled throughput by batching writes.",
      "spanishHint": "rendimiento / caudal", "category": "systems",
      "difficulty": "mid", "relatedTerms": [], "origin": null }
  ]
}
```

**grammar.json** (lista de unidades):
```json
{
  "id": "unit-past-simple", "level": "Level 1: Junior",
  "title": "Past Simple in STAR Stories",
  "tag": "B1-B2",                        // <- ESTE es el que ordena el rail
  "subtitle": "…", "ruleSummary": "…",
  "comparisonExamples": [ { "wrong": "…", "right": "…", "tip": "…" } ],
  "questions": [ /* GrammarQuestion */ ]
}
```

**comprehension_seed.json** (lista de piezas):
```json
{
  "id": "gen_b1b2_standup", "domain": "general",   // general | tech
  "band": "B1-B2",                                 // <- rail
  "category": "Workplace", "title": "…", "estMinutes": 4,
  "body": "English text…", "bodyEs": "Traducción ES…",
  "questions": [ { "type": "mcq|spoken", "…": "…" } ]
}
```

**interview.json** (lista de packs):
```json
{
  "id": "interview_systems_b1", "domain": "tech",  // general | tech
  "scenario": "systemsDesign", "subtopic": "APIs & Bases de datos (B1-B2)",
  "band": "b1b2",                                  // enum o "B1-B2", ambos valen
  "mode": "guided", "questionIds": [], "skills": ["…"],
  "estMinutes": 8, "feedbackType": "…"
}
```

**questions.json** (lista de preguntas de entrevista):
```json
{
  "id": 42, "category": "tech", "difficulty": "mid",  // junior|mid|senior
  "title": "…", "text": "English question…",
  "model_answer": "English STAR model…", "tips": "…",
  "cefr": "B1-B2",                                    // etiqueta CEFR
  "text_es": "Enunciado en español…",                 // opcional, instantáneo/offline
  "model_answer_es": "Respuesta modelo en español…"   // opcional
}
```

> Mapa CEFR → dificultad de sesión de entrevista (al pulsar "Empezar"):
> `A1-A2 → junior`, `B1-B2 → mid`, `B2-C1 / C1 → senior`.
> Añade `text_es` / `model_answer_es` a las preguntas para que el toggle
> "Traducir ES" sea instantáneo y offline (sin LLM).

---

## 4. Cómo calificar el CEFR (rúbrica breve)

Decide la banda por el **techo** de exigencia del ítem (vocabulario, longitud y
complejidad de frase, abstracción del tema):

| Banda | Vocabulario | Gramática/frase | Tema |
|-------|-------------|-----------------|------|
| **A1-A2** | ~1.000 palabras más frecuentes, concreto | frases cortas, presente/pasado simple | rutinas, datos personales, necesidades básicas |
| **B1-B2** | frecuencia media, algo técnico | subordinadas, condicionales, voz pasiva | trabajo, opiniones, explicaciones técnicas |
| **B2-C1** | específico/técnico, colocaciones | matices, hipótesis, registro | trade-offs, argumentación, diseño de sistemas |
| **C1** | preciso, idiomático, abstracto | estructuras complejas fluidas | liderazgo, estrategia, ambigüedad |

Para calibrar con criterio, apóyate en listas abiertas (CEFR-J wordlist,
English Profile / EVP para vocabulario, English Grammar Profile para
estructuras). Ante la duda, **baja** un nivel: es peor frustrar que aburrir.

Requisitos de cada ítem nuevo: **CEFR** (una de las 4 bandas), **licencia /
fuente** del texto, y **revisión humana** antes de subir (ver el pipeline en
`content_pipeline` / `ContentItemIn` y las notas de `agregar mas contenido , hacer.txt`).

---

## 5. Proceso para añadir contenido (paso a paso)

1. **Edita** el seed del backend correspondiente en `backend/app/seed/*.json`
   (respeta el esquema, **ids únicos**, banda = una de las 4, licencia).
2. **Valida y sincroniza** la copia offline:
   ```bash
   cd C:\Users\IvN\Desktop\Ingles
   python tools\sync_offline_seeds.py --check      # solo valida (esquema + ids)
   python tools\sync_offline_seeds.py              # copia a app/assets/seed + regenera const
   ```
   `--check` debe salir en verde antes de continuar.
3. **Rebuild del backend** en la NAS (la imagen hornea `./backend`, no va montado):
   ```bash
   DOCKER_BUILDKIT=0 docker build --network=host -t english_coach_backend:local ./backend
   docker compose up -d
   ```
   Tras esto, el contenido ya aparece en la app con **pull-to-refresh**.
4. **(Opcional) Refrescar offline empaquetado vía OTA:**
   Ejecuta `make shorebird-patch` para enviar los nuevos seeds a los móviles ya instalados sin reinstalar.

---

## 6. Actualizar la app sin reinstalar cada vez

Tres caminos según qué cambies:

**A) Contenido (lo más habitual): sin APK.**
Subes al backend (§5) y haces *pull-to-refresh* en la app instalada. Nada más.

**B) Código Dart en desarrollo: hot reload.**
Usa `flutter run` (creado en la raíz del repo). Con el móvil conectado por USB
(o wireless debugging) y depuración USB activada:
- `r` = hot reload (aplica cambios al instante), `R` = restart, `q` = salir.
Wireless (una vez, con el móvil y el PC en la misma red):
```bash
adb tcpip 5555
adb connect IP_DEL_MOVIL:5555
```
y luego `flutter run`.

**C) App instalada (release) que se auto-actualiza por internet: Shorebird (OTA).**
Empuja cambios de Dart y de assets a la app ya instalada sin reinstalar ni pasar por la tienda.
Uso directo con los scripts del repositorio:
- **Actualizar código / hornear offline:** Ejecuta `make shorebird-patch` (sincroniza seeds y envía el parche).
- **Nuevo APK base parcheable (si cambias nativo):** Ejecuta `make shorebird-release` (copia el nuevo `English_Coach.apk` al Escritorio).
- Consulta [`SHOREBIRD.md`](SHOREBIRD.md) para todos los detalles técnicos.

**D) Baseline release manual:** `make build-release-apk` (como hasta ahora), cuando quieras un APK firmado nuevo tradicional sin OTA.

Recomendación para tu caso (te vas a centrar en contenido): trabaja por **A** (backend + pull-to-refresh, cero APKs). Usa **C (`make shorebird-patch`)** para empujar de vez en cuando el offline baseline y los retoques de código sin reinstalar. Usa **B** solo cuando desarrolles pantallas interactivas.

---

## 7. Checklist antes de subir contenido

- [ ] Esquema del JSON correcto (campos obligatorios de §3).
- [ ] `id` únicos dentro del archivo.
- [ ] Banda = **una** de `A1-A2` / `B1-B2` / `B2-C1` / `C1` (o `a2b1`…`c1`).
- [ ] Licencia / fuente del texto anotada; revisión humana hecha.
- [ ] `python tools\sync_offline_seeds.py --check` en verde.
- [ ] Rebuild del backend hecho; verificado con *pull-to-refresh* en la app.
