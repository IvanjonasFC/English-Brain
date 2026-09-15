# Guía de Gestión de Contenido Dinámico 📚

> [!TIP]
> **Documento canónico y actualizado:** Consulta [`GUIA_CONTENIDO.md`](GUIA_CONTENIDO.md) para la guía completa con el modelo de 4 bandas CEFR, esquemas JSON exactos, sincronización offline (`sync_offline_seeds.py`) y despliegue OTA con Shorebird.

Esta guía detalla cómo está estructurado el sistema de contenido de la aplicación (Entrevistas, Vocabulario y Gramática) tras la migración a un modelo dinámico. Ahora todo el contenido se sirve a través del backend en lugar de estar hardcodeado en la aplicación de Flutter.

## 1. Arquitectura General
El flujo de datos funciona de la siguiente manera:
1. **Backend (Python / FastAPI)**: Almacena los datos y los provee a través de endpoints REST (`/packs/interview`, `/packs/vocabulary`, `/packs/grammar`).
2. **App (Flutter / Riverpod)**: Realiza llamadas HTTP usando `ApiClient.dio.get()` dentro de un `FutureProvider`.
3. **Modelos Dart (`fromJson`)**: Reciben el JSON del backend y lo mapean a clases fuertemente tipadas.
4. **Pantallas (Hubs)**: Escuchan el estado del proveedor (`ref.watch`) para mostrar indicadores de carga, errores, o el contenido dinámico renderizado y filtrado.

---


## 2. Cómo añadir nuevo contenido

Para agregar una nueva unidad de gramática, un nuevo tema de vocabulario o un pack de entrevista, **ya no necesitas modificar el código de Flutter**. Todo se maneja desde el backend.

### Modificar en el Backend (Ej. `packs.py`)
En tu proyecto backend (ej. en la carpeta `backend/app/seed/` o donde definas los endpoints), simplemente añade un nuevo objeto a la lista correspondiente.

**Ejemplo para Vocabulario (`VocabularyPack`)**:
Asegúrate de respetar las claves exactas que espera el modelo en Dart.
```python
{
  "id": "devops_advanced",
  "title": "DevOps & SRE",
  "description": "Conceptos avanzados de infraestructura.",
  "iconCodePoint": 58342, # Equivalente al IconData en Flutter
  "iconFontFamily": "MaterialIcons",
  "level": "C1",
  "accentColorValue": 4279584255, # Color en formato Int ARGB
  "terms": [
    {
      "term": "Kubernetes",
      "ipa": "/ˌkuːbərˈnɛtɪs/",
      "definition": "A portable, extensible, open-source platform...",
      "exampleSentence": "We migrated our monolithic app to Kubernetes.",
      "spanishHint": "Plataforma de orquestación",
      "category": "infrastructure",
      "difficulty": "advanced",
      "relatedTerms": ["Docker", "Microservices"],
      "origin": "Greek"
    }
  ]
}
```

**Ejemplo para Gramática (`GrammarUnit`)**:
```python
{
  "id": "unit-3-conditionals",
  "level": "Level 2: Mid-Level",
  "title": "Unit 3: First and Second Conditionals",
  "tag": "B2",
  "subtitle": "Hablando de posibilidades en sistemas y negociaciones",
  "ruleSummary": "Usa el primer condicional para situaciones reales/posibles (If we deploy now, the system will...).",
  "comparisonExamples": [
    {
      "wrong": "If we will scale the database, it is faster.",
      "right": "If we scale the database, it will be faster.",
      "tip": "No uses 'will' en la cláusula 'if'."
    }
  ],
  "questions": [
    # ... Lista de GrammarQuestions ...
  ]
}
```

---

## 3. Adaptación Correcta en las Ventanas (Hub Screens)

### Filtrado Automático
Cada pantalla principal (`VocabularyHubScreen`, `GrammarHubScreen`, `InterviewHubScreen`) incluye lógica local para filtrar los datos dinámicos. 

Por ejemplo, si añades un pack con nivel `"C1"`, el filtro de "C1 Executive" en la interfaz lo capturará automáticamente a través de la función de filtrado interna, como `_getFilteredPacks(packs)`:
```dart
  List<VocabularyPack> _getFilteredPacks(List<VocabularyPack> allPacks) {
    return allPacks.where((pack) {
      if (_selectedCefrLevel != 'All') {
        if (!pack.level.contains(_selectedCefrLevel)) return false;
      }
      return true;
    }).toList();
  }
```

### Evita los "Magic Strings"
Las interfaces están diseñadas para procesar **listas de datos**, por lo que se adaptarán a la cantidad de packs que envíe el backend (2 o 50) construyendo las listas (usando `.map((pack) => _buildUnitCard(pack)).toList()`). 

> **Excepción (IA Hero Cards)**: En algunas tarjetas principales como "Sesión Recomendada", el frontend busca un pack específico (por ejemplo, el de ID `'backend'`). Si eliminas o renombras este pack en el backend, la tarjeta mostrará valores seguros (0 términos) en lugar de dar error, pero es importante tenerlo en cuenta al modificar IDs clave.

---

## 4. Troubleshooting (Solución de problemas)

Si añades un pack en el backend pero no aparece correctamente o la App rompe:
1. **Revisa las Nulabilidades**: Comprueba si olvidaste algún campo requerido. En Dart, modelos como `VocabularyItem.fromJson` esperan que el campo `'term'` siempre esté presente y sea un String. Usa valores por defecto en tu JSON del backend (`""` en lugar de omitir el campo).
2. **Revisa la consola de Flutter (`Error cargando packs...`)**: Si ocurre un fallo en el mapeo (`fromJson`), Riverpod capturará el error en la rama `error: (err, stack)` del `.when()` y lo mostrará de manera segura en la interfaz. 
3. **Colores e Iconos Dinámicos**: Ya que Flutter no puede parsear widgets como `IconData` directamente desde el JSON por razones de seguridad de tipos, enviamos representaciones crudas desde el backend (`iconCodePoint`, `accentColorValue` int de 32 bits) y Dart las reconstituye (ej. `Color(j['accentColorValue'] as int)`). Asegúrate de enviar los enteros correctos desde tu API en Python.
