import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';
import 'vocabulary_theme_tokens.dart';
import 'vocabulary_repository.dart' as repo;
import 'vocabulary_practice_screen.dart';
import '../../core/audio/audio_recorder_controller.dart';
import '../../core/widgets/pitch_contour_chart.dart';
import '../../core/services/measurement_service.dart';
import '../../core/models/api_models.dart';
import '../../core/services/client_logger.dart';
import '../../core/theme/tab_theme.dart';
import '../phonetics/hvpt_exercise_screen.dart';
import '../../core/audio/voice_selection.dart';
import '../../core/theme/app_theme.dart';

class VocabularyItem {
  final String term;
  final String phonetic;
  final String partOfSpeech;
  final String category;
  final String level; // Level 1 (Junior), Level 2 (Mid), Level 3 (Senior), Level 4 (Staff)
  final String definition;
  final String spanishDefinition;
  final String spanishNote;
  final String exampleSentence;
  // Campos enriquecidos para la experiencia STAR y FSRS
  final String? starQuote;
  final String? starType;
  final String? starDimension;
  final bool isCritical;
  final int retentionPercent;
  final String state; // 'mastered' | 'pending'
  final String? collocations;
  final String? technicalCallout;
  final bool hasWaveform;
  final List<String> synonyms;

  const VocabularyItem({
    required this.term,
    required this.phonetic,
    required this.partOfSpeech,
    required this.category,
    required this.level,
    required this.definition,
    required this.spanishDefinition,
    required this.spanishNote,
    required this.exampleSentence,
    this.starQuote,
    this.starType,
    this.starDimension,
    this.isCritical = false,
    this.retentionPercent = 85,
    this.state = 'mastered',
    this.collocations,
    this.technicalCallout,
    this.hasWaveform = false,
    this.synonyms = const [],
  });
}

final List<VocabularyItem> allVocabulary = [
  // ================= SYSTEM ARCHITECTURE & SCALABILITY (Del Mockup) =================
  const VocabularyItem(
    term: "Bottleneck",
    phonetic: "/ˈbɒt.əl.nek/",
    partOfSpeech: "Noun",
    category: "System Architecture",
    level: "Level 3: Senior",
    definition: "A critical point in a system where data flow or execution is restricted, severely reducing processing capacity and overall throughput.",
    spanishDefinition: "Punto del sistema donde el flujo de datos se restringe críticamente, reduciendo la capacidad de procesamiento y el rendimiento global.",
    spanishNote: "Cuello de botella técnico en bases de datos, redes o consumo de CPU/I-O.",
    exampleSentence: "During peak traffic, the database read-replica became our primary bottleneck, escalating p99 latency beyond 450ms.",
    starQuote: "“During peak traffic, the database read-replica became our primary bottleneck, escalating p99 latency beyond 450ms.”",
    starType: "STAR Interview Quote",
    starDimension: "Situation • Task",
    isCritical: false,
    retentionPercent: 88,
    state: "mastered",
  ),
  const VocabularyItem(
    term: "Throughput",
    phonetic: "/ˈθruː.pʊt/",
    partOfSpeech: "Noun",
    category: "System Architecture",
    level: "Level 2: Mid-Level",
    definition: "The amount of data, requests, or transactions processed successfully by a system within a given time period (e.g., RPS/TPS).",
    spanishDefinition: "Tasa o volumen de transacciones exitosas, mensajes o paquetes de datos procesados por el sistema por unidad de tiempo (ej. RPS o TPS).",
    spanishNote: "Volumen procesado por segundo (RPS/TPS). No confundir con Latency.",
    exampleSentence: "By optimizing our asynchronous worker queues, we doubled the system throughput to 15,000 requests per second.",
    starQuote: "“By implementing batching and caching, we scaled peak message throughput threefold without provisioning additional server instances.”",
    starType: "STAR Interview Quote",
    starDimension: "Action • Result",
    isCritical: false,
    retentionPercent: 45,
    state: "pending",
    collocations: "• Maximize throughput • Network throughput saturation • I/O throughput rate",
    hasWaveform: true,
  ),
  const VocabularyItem(
    term: "Single Point of Failure (SPOF)",
    phonetic: "/ˌsɪŋ.ɡəl pɔɪnt əv ˈfeɪ.ljər/",
    partOfSpeech: "Noun Phrase",
    category: "System Resilience",
    level: "Level 4: Staff / Lead",
    definition: "A critical part or component whose failure will cause the entire system or service to stop functioning due to lack of redundancy.",
    spanishDefinition: "Parte o componente de una infraestructura técnica cuya eventual falla interrumpe o inhabilita el funcionamiento de todo el sistema por falta de redundancia.",
    spanishNote: "Punto único de fallo. Crítico de resolver en entrevistas de System Design.",
    exampleSentence: "To eliminate this single point of failure, I led the migration toward multi-region active-active clusters with automated geo-DNS failover.",
    starQuote: "“To eliminate this single point of failure, I led the migration toward multi-region active-active clusters with automated geo-DNS failover.”",
    starType: "STAR Defense • Action",
    starDimension: "Leadership • Risk",
    isCritical: true,
    retentionPercent: 52,
    state: "pending",
  ),
  const VocabularyItem(
    term: "Idempotency",
    phonetic: "/ˌaɪ.dəmˈpoʊ.tənsi/",
    partOfSpeech: "Noun",
    category: "API & Distributed Systems",
    level: "Level 3: Senior",
    definition: "The property where an operation can be applied multiple times without changing the result beyond the initial execution.",
    spanishDefinition: "Propiedad donde una operación puede ejecutarse múltiples veces consecutivas produciendo exactamente el mismo resultado sin efectos secundarios adicionales no deseados.",
    spanishNote: "Garantía de idempotencia en pagos y reintentos automáticos de APIs REST.",
    exampleSentence: "We introduced unique idempotency keys in our payment ingestion pipeline to guarantee safe retries during transient network partitions.",
    starQuote: "“By enforcing strict idempotency across our webhook workers, we prevented double-charging customers during upstream third-party gateway timeouts.”",
    starType: "STAR Architecture Quote",
    starDimension: "Task • Action",
    isCritical: false,
    retentionPercent: 94,
    state: "mastered",
    technicalCallout: "Vital al diseñar pasarelas de pago (Stripe / Adyen): uso de cabeceras Idempotency-Key para manejar de forma segura reintentos de red automáticos.",
  ),
  const VocabularyItem(
    term: "Cache Invalidation",
    phonetic: "/kæʃ ɪnˌvæl.əˈdeɪ.ʃən/",
    partOfSpeech: "Noun Phrase",
    category: "Data & Storage",
    level: "Level 3: Senior",
    definition: "The process whereby entries in a cache storage are purged, expired, or replaced to ensure consistency with the persistent database.",
    spanishDefinition: "Proceso mediante el cual las entradas obsoletas en una caché son purgadas o actualizadas para reflejar el estado veraz de la base de datos.",
    spanishNote: "Uno de los dos grandes problemas de la computación según Phil Karlton.",
    exampleSentence: "We combined write-through caching with Redis pub/sub to propagate cache invalidation across all edge nodes in real time.",
    starQuote: "“To eliminate stale product prices, I designed an event-driven cache invalidation mechanism listening to CDC change logs.”",
    starType: "STAR Interview Quote",
    starDimension: "Action • Technical Depth",
    isCritical: true,
    retentionPercent: 82,
    state: "mastered",
  ),
  const VocabularyItem(
    term: "Rate Limiter",
    phonetic: "/reɪt ˈlɪm.ɪ.tər/",
    partOfSpeech: "Noun",
    category: "API Security",
    level: "Level 2: Mid-Level",
    definition: "A network mechanism that controls the rate of requests sent or received by a service to prevent resource exhaustion and abuse.",
    spanishDefinition: "Mecanismo que restringe el número de peticiones por segundo por usuario o IP para evitar agotamiento de recursos y abuso de API.",
    spanishNote: "Uso de Token Bucket o Leaky Bucket en gateways de microservicios.",
    exampleSentence: "To prevent database connection exhaustion during peak traffic, we implemented an asynchronous rate limiter with graceful backoff.",
    starQuote: "“To prevent database connection exhaustion during peak traffic, we implemented an asynchronous rate limiter with graceful backoff.”",
    starType: "STAR Strategy • Action",
    starDimension: "Resilience • SLA",
    isCritical: true,
    retentionPercent: 91,
    state: "mastered",
  ),
  const VocabularyItem(
    term: "Circuit Breaker",
    phonetic: "/ˈsɜː.kɪt ˌbreɪ.kər/",
    partOfSpeech: "Noun",
    category: "Microservices & Fault Tolerance",
    level: "Level 3: Senior",
    definition: "A design pattern used to detect failures and prevent cascading downtime by temporarily halting requests to an unhealthy service.",
    spanishDefinition: "Patrón de diseño que interrumpe llamadas recurrentes a un servicio degradado para permitir su recuperación y aislar fallos en cascada.",
    spanishNote: "Estados: Closed, Open y Half-Open. Básico en arquitecturas resilientes.",
    exampleSentence: "The circuit breaker tripped immediately when the recommendation microservice started timing out, saving the core checkout flow.",
    starQuote: "“I configured the circuit breaker to fall back to cached inventory whenever the fulfillment service latency exceeded our 200ms budget.”",
    starType: "STAR Interview Quote",
    starDimension: "Action • System Protection",
    isCritical: true,
    retentionPercent: 60,
    state: "pending",
  ),
  const VocabularyItem(
    term: "Backpressure",
    phonetic: "/ˈbækˌpreʃ.ər/",
    partOfSpeech: "Noun",
    category: "Streaming & Reactive Systems",
    level: "Level 4: Staff / Lead",
    definition: "Resistance or feedback exerted by a consumer when data incoming rate exceeds its processing capacity, preventing memory saturation.",
    spanishDefinition: "Mecanismo de contrapresión donde un consumidor desbordado frena el ritmo de emisión del productor para evitar saturación de memoria.",
    spanishNote: "Esencial en Kafka, Reactive Streams y procesamiento continuo de eventos.",
    exampleSentence: "Implementing backpressure in our analytics consumer pipeline prevented out-of-memory crashes during high-volume ingestion surges.",
    starQuote: "“We established reactive backpressure with Kafka consumer throttling to protect our relational analytics database from spikes.”",
    starType: "STAR Leadership Quote",
    starDimension: "Architecture • Stability",
    isCritical: false,
    retentionPercent: 40,
    state: "pending",
  ),
];

List<VocabularyItem> getVocabularyItemsForPack(String packId) {
  // Mapear alias de Stitch a packs reales
  String targetId = packId;
  if (packId == 'system_arch' || packId == 'system_design') targetId = 'backend';
  if (packId == 'numbers_metrics') targetId = 'metrics_financial';
  if (packId == 'agile_ceremonies') targetId = 'teamwork';
  if (packId == 'incident_mgmt') targetId = 'devops';

  if (targetId == 'backend') {
    return allVocabulary;
  }

  final matched = repo.VocabularyRepository.packs.firstWhere(
    (p) => p.id == targetId || p.id == packId,
    orElse: () => repo.VocabularyRepository.packs.first,
  );

  final List<VocabularyItem> result = [];

  if (matched.terms.isNotEmpty) {
    result.addAll(matched.terms.map((t) {
      final diff = t.difficulty.toLowerCase();
      final isSenior = diff.contains('senior') || diff.contains('staff');
      final isPending = isSenior || diff.contains('mid');
      final retention = isSenior ? 55 : (diff.contains('mid') ? 70 : 85);

      return VocabularyItem(
        term: t.term,
        phonetic: t.ipa,
        partOfSpeech: t.category,
        category: matched.title,
        level: matched.level,
        definition: t.definition,
        spanishDefinition: t.spanishHint,
        spanishNote: t.spanishHint.isNotEmpty
            ? t.spanishHint
            : (t.relatedTerms.isNotEmpty
                ? 'Relacionados: ${t.relatedTerms.join(', ')}'
                : 'Término de alta frecuencia en entornos tech.'),
        exampleSentence: t.exampleSentence,
        starQuote: t.exampleSentence.isNotEmpty ? '“${t.exampleSentence}”' : null,
        starType: matched.id.contains('interviews') ? 'STAR Interview Quote' : 'Contextual Usage',
        starDimension: matched.title,
        isCritical: isSenior,
        retentionPercent: retention,
        state: isPending ? 'pending' : 'mastered',
        hasWaveform: t.ipa.isNotEmpty,
        synonyms: t.relatedTerms,
      );
    }));
  }

  if (result.isNotEmpty) return result;
  return allVocabulary;
}

String getPackTitle(String packId, bool isEn) {
  switch (packId) {
    case 'system_arch':
    case 'backend':
      return isEn ? 'System Architecture & Scalability' : 'Arquitectura de Sistemas & Escalabilidad';
    case 'numbers_metrics':
      return isEn ? 'Numbers, Metrics & Financial Data' : 'Números, Métricas & Datos Financieros';
    case 'agile_ceremonies':
      return isEn ? 'Agile Ceremonies & Standups' : 'Ceremonias Ágiles & Standups';
    case 'code_review':
      return isEn ? 'Code Review & Technical Debate' : 'Code Review & Debate Técnico';
    case 'client_negotiation':
      return isEn ? 'Client Negotiation & Deadlines' : 'Negociación con Clientes & Plazos';
    case 'incident_mgmt':
      return isEn ? 'Incident Management & DevOps' : 'Gestión de Incidentes & DevOps';
    case 'interviews':
      return isEn ? 'Tech Interviews & STAR Stories' : 'Entrevistas Técnicas & Casos STAR';
    default:
      final pack = repo.VocabularyRepository.packs.firstWhere(
        (p) => p.id == packId,
        orElse: () => repo.VocabularyRepository.packs.first,
      );
      return pack.title;
  }
}

String _translateStarDimension(String? dim, bool isEn) {
  if (dim == null || dim.isEmpty) return isEn ? 'Situation • Task' : 'Situación • Tarea';
  if (isEn) return dim;
  switch (dim) {
    case 'Situation • Task':
      return 'Situación • Tarea';
    case 'Action • Result':
      return 'Acción • Resultado';
    case 'Tech Interviews & STAR Stories':
      return 'Entrevistas Técnicas & Casos STAR';
    case 'System Architecture':
      return 'Arquitectura de Sistemas';
    case 'System Resilience':
      return 'Resiliencia del Sistema';
    case 'Backend & Distributed Systems':
      return 'Backend & Sistemas Distribuidos';
    case 'Databases & Storage':
      return 'Bases de Datos & Almacenamiento';
    case 'Teamwork & Agile':
      return 'Trabajo en Equipo & Agile';
    case 'Frontend & Web Development':
      return 'Frontend & Desarrollo Web';
    case 'DevOps & Cloud Infrastructure':
      return 'DevOps & Infraestructura Cloud';
    case 'Contextual Usage':
      return 'Uso en Contexto Real';
    default:
      return dim;
  }
}

String getPackSubtitle(String packId, bool isEn) {
  switch (packId) {
    case 'system_arch':
    case 'backend':
      return isEn
          ? 'Distributed systems architecture, microservices, and resilience.'
          : 'Arquitectura de sistemas distribuidos, microservicios y resiliencia.';
    case 'numbers_metrics':
      return isEn
          ? 'Quantitative engineering metrics: p99 latency, throughput, SLIs, and KPIs.'
          : 'Métricas cuantitativas de ingeniería: latencia p99, throughput, SLIs y KPIs.';
    case 'agile_ceremonies':
      return isEn
          ? 'Assertive communication during daily standups, planning, and retrospectives.'
          : 'Comunicación asertiva en dailies, sprint planning y retrospectivas.';
    case 'code_review':
      return isEn
          ? 'Diplomatic, assertive technical debate on PRs and code reviews.'
          : 'Defensa diplomática y asertiva de decisiones de código y PRs.';
    case 'client_negotiation':
      return isEn
          ? 'Deadline negotiation, stakeholder management, and executive alignment.'
          : 'Negociación de plazos, gestión de expectativas y liderazgo de clientes.';
    case 'incident_mgmt':
      return isEn
          ? 'Outage triage, incident post-mortems, and blast radius containment.'
          : 'Gestión de caídas en producción, post-mortems y mitigación de fallos.';
    default:
      final pack = repo.VocabularyRepository.packs.firstWhere(
        (p) => p.id == packId,
        orElse: () => repo.VocabularyRepository.packs.first,
      );
      return pack.description;
  }
}

class VocabularyScreen extends ConsumerStatefulWidget {
  final String? initialPackId;
  final String? customTitle;
  final String? customSubtitle;
  final List<VocabularyItem>? customItems;
  final bool showLevelTabs;

  const VocabularyScreen({
    super.key,
    this.initialPackId,
    this.customTitle,
    this.customSubtitle,
    this.customItems,
    this.showLevelTabs = true,
  });

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  String _currentFilter = 'all'; // 'all', 'pending', 'mastered', 'critical'
  String _searchQuery = '';
  final Set<String> _bookmarkedTerms = {'Throughput'};
  final Set<String> _expandedSynonyms = {};
  final Set<String> _cardLanguageSwaps = {};
  String? _playingTerm;
  String? _playingSentence;

  // Pronunciacion por tarjeta (reutiliza checkPronunciation + audioRecorder).
  String? _pronRecordingTerm; // termino que se esta grabando
  String? _pronCheckingTerm;  // termino en evaluacion
  final Map<String, int> _pronScores = {}; // termino -> score 0..100
  final Set<String> _pronErrors = {};       // terminos con fallo de captura
  final Map<String, PronunciationResult> _pronResults = {}; // resultado completo
  final Map<String, String> _pronAudioPath = {}; // termino -> ruta audio grabado (entonación)
  final Map<String, String> _pronTips = {}; // consejo tecnico (LLM)
  final Set<String> _pronTipLoading = {};   // terminos con analisis en curso
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription? _pronSub;

  @override
  void initState() {
    super.initState();
    _pronSub = ref.read(pronunciationQueueProvider).onProcessed.listen((event) {
      if (mounted && event.section == 'vocabulary') {
        setState(() {
          _pronResults[event.term] = event.result;
          if (event.result.score > 0) {
            _pronScores[event.term] = event.result.score;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pronSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<VocabularyItem> get _items {
    if (widget.customItems != null && widget.customItems!.isNotEmpty) {
      return widget.customItems!;
    }
    final packId = widget.initialPackId ?? 'backend';
    return getVocabularyItemsForPack(packId);
  }

  String get _packLevel {
    if (_items.isNotEmpty) return _items.first.level;
    final packId = widget.initialPackId ?? 'backend';
    final pack = repo.VocabularyRepository.packs.firstWhere(
      (p) => p.id == packId,
      orElse: () => repo.VocabularyRepository.packs.first,
    );
    return pack.level;
  }

  List<VocabularyItem> get _filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    return _items.where((item) {
      // Filtro por estado
      if (_currentFilter == 'pending' && item.state != 'pending') return false;
      if (_currentFilter == 'mastered' && item.state != 'mastered') return false;
      if (_currentFilter == 'critical' && !item.isCritical) return false;

      // Filtro por búsqueda
      if (query.isNotEmpty) {
        final inTerm = item.term.toLowerCase().contains(query);
        final inDef = item.definition.toLowerCase().contains(query);
        final inSpan = item.spanishDefinition.toLowerCase().contains(query);
        final inExample = item.exampleSentence.toLowerCase().contains(query);
        return inTerm || inDef || inSpan || inExample;
      }
      return true;
    }).toList();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: VocabTheme.tertiaryFixed, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: VocabTheme.labelSm(color: VocabTheme.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: VocabTheme.onSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _playPronunciation(VocabularyItem item, {double speed = 1.0}) async {
    final player = ref.read(audioPlayerProvider);
    setState(() => _playingTerm = item.term);
    final minTimer = Future.delayed(const Duration(milliseconds: 650));
    try {
      await Future.wait([
        player.playTts(item.term, slow: speed < 1.0, voice: AppVoices.vocabulary),
        minTimer,
      ]);
    } catch (_) {
      if (mounted) _showToast('No se pudo reproducir el audio.');
    } finally {
      if (mounted) {
        setState(() {
          if (_playingTerm == item.term) _playingTerm = null;
        });
      }
    }
  }

  Future<void> _playSentence(VocabularyItem item) async {
    final player = ref.read(audioPlayerProvider);
    setState(() => _playingSentence = item.term);
    final minTimer = Future.delayed(const Duration(milliseconds: 800));
    try {
      await Future.wait([
        player.playTts(item.exampleSentence, voice: AppVoices.vocabulary),
        minTimer,
      ]);
    } catch (_) {
      if (mounted) _showToast('No se pudo reproducir el audio.');
    } finally {
      if (mounted) {
        setState(() {
          if (_playingSentence == item.term) _playingSentence = null;
        });
      }
    }
  }

  Future<void> _toggleBookmark(VocabularyItem item) async {
    final isSaved = _bookmarkedTerms.contains(item.term);
    setState(() {
      if (isSaved) {
        _bookmarkedTerms.remove(item.term);
      } else {
        _bookmarkedTerms.add(item.term);
      }
    });

    if (!isSaved) {
      // Guardar en base de datos drift FSRS
      final db = ref.read(appDatabaseProvider);
      final cardId = item.term.hashCode.abs() % 1000000;
      await db.into(db.cardsLocal).insertOnConflictUpdate(
        CardsLocalCompanion.insert(
          id: Value(cardId),
          front: "${item.term} (${item.partOfSpeech})\n${item.phonetic}\n\nExample: \"${item.exampleSentence}\"",
          back: "${item.spanishDefinition}\n\nNota: ${item.spanishNote}\n\nEN: ${item.definition}",
          stability: 2.0,
          difficulty: 4.5,
          elapsedDays: 0,
          scheduledDays: 1,
          reps: 0,
          lapses: 0,
          state: 0,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
      );
      _showToast('Guardado en mazo prioritario FSRS');
    } else {
      _showToast('Eliminado de tu lista prioritaria');
    }
  }

  void _startPractice() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VocabularyPracticeScreen(
          packId: widget.initialPackId ?? 'backend',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale.languageCode == 'en';
    // Prefetch premium: audio neural del NAS para lo que se ve.
    ref.read(audioPrefetchProvider).warm(
      _filteredItems.expand((i) => [i.term, i.exampleSentence]),
      voice: AppVoices.vocabulary,
    );

    final totalCount = _items.length;
    final pendingCount = _items.where((i) => i.state == 'pending').length;
    final masteredCount = _items.where((i) => i.state == 'mastered').length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Editorial Topic Summary Card
                    _buildEditorialSummaryCard(masteredCount, totalCount, isEn),

                    const SizedBox(height: 16),

                    // 3. Search and Segmented Filter Rail
                    _buildSearchAndFilterRail(
                        totalCount, pendingCount, masteredCount, isEn),

                    const SizedBox(height: 16),

                    // 4. Vocabulary Terms Card Feed
                    _buildTermsList(isEn),
                  ],
                ),
              ),
            ),

            // Bottom Sticky CTA Bar
            _buildBottomStickyBar(isEn),
          ],
        ),
      ),
    );
  }

  String _getTitle(bool isEn) {
    if (widget.customTitle != null && widget.customTitle!.isNotEmpty) {
      return widget.customTitle!;
    }
    return getPackTitle(widget.initialPackId ?? 'backend', isEn);
  }

  String _getSubtitle(bool isEn) {
    if (widget.customSubtitle != null && widget.customSubtitle!.isNotEmpty) {
      return widget.customSubtitle!;
    }
    return getPackSubtitle(widget.initialPackId ?? 'backend', isEn);
  }

  Widget _buildEditorialSummaryCard(int mastered, int total, bool isEn) {
    final percent = total > 0 ? (mastered / total * 100).round() : 75;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VocabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Action Row (Back Button + Badges + Language Switcher)
          Row(
            children: [
              // Back Button
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/vocabulary');
                  }
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VocabTheme.surfaceContainerLowest,
                    border: Border.all(color: VocabTheme.surfaceContainerHigh),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: VocabTheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Badges
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      TabTheme.cefrPill(_packLevel, fontSize: 11),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: VocabTheme.primaryFixed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_graph_rounded,
                              size: 14,
                              color: VocabTheme.onPrimaryFixed,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isEn ? 'Mastery: $percent%' : 'Dominio: $percent%',
                              style: VocabTheme.labelSm(
                                color: VocabTheme.onPrimaryFixed,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: VocabTheme.surfaceContainerLowest,
                          border: Border.all(color: VocabTheme.surfaceContainerHigh),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: VocabTheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '6 min',
                              style: VocabTheme.labelSm(
                                color: VocabTheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Title & Description
          Text(
            _getTitle(isEn).toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: VocabTheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getSubtitle(isEn),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.isLight ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEn
                ? '$total key terms for resilient system design, microservices, and Staff/Principal technical interviews.'
                : '$total términos clave para diseño de sistemas resilientes, microservicios y entrevistas técnicas de nivel Staff & Principal.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.isLight ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Segmented Mastery Tracker (FSRS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEn
                    ? 'FSRS retention progress'
                    : 'Progreso de retención FSRS',
                style: VocabTheme.labelSm(color: VocabTheme.secondary),
              ),
              Text(
                isEn
                    ? '$mastered / $total consolidated'
                    : '$mastered / $total consolidados',
                style: VocabTheme.labelSm(
                  color: VocabTheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 72,
                    child: Container(color: VocabTheme.tertiary),
                  ),
                  Expanded(
                    flex: 17,
                    child: Container(color: VocabTheme.primaryContainer),
                  ),
                  Expanded(
                    flex: 11,
                    child: Container(color: VocabTheme.surfaceDim),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendDot(VocabTheme.tertiary, isEn ? 'Mastered' : 'Dominados'),
              _buildLegendDot(VocabTheme.primaryContainer, isEn ? 'Review today' : 'Repaso hoy'),
              _buildLegendDot(VocabTheme.surfaceDim, isEn ? 'New' : 'Nuevos'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: VocabTheme.labelSm(color: VocabTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterRail(
      int total, int pending, int mastered, bool isEn) {
    final criticalCount = _items.where((i) => i.isCritical).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tactile Search Field
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: VocabTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: VocabTheme.surfaceContainerHigh),
            boxShadow: TabTheme.cardShadow,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() => _searchQuery = val);
            },
            style: VocabTheme.bodyMd(color: VocabTheme.onSurface),
            decoration: InputDecoration(
              hintText: isEn
                  ? 'Search term, definition or synonym...'
                  : 'Buscar término, definición o sinónimo...',
              hintStyle: VocabTheme.bodyMd(color: VocabTheme.outline),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: VocabTheme.secondary,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: 18, color: VocabTheme.secondary),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Segmented Filter Rail
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', isEn ? 'All ($total)' : 'Todos ($total)'),
              const SizedBox(width: 8),
              _buildFilterChip(
                  'pending', isEn ? 'To Master ($pending)' : 'Por Dominar ($pending)'),
              const SizedBox(width: 8),
              _buildFilterChip(
                  'mastered', isEn ? 'Mastered ($mastered)' : 'Dominados ($mastered)'),
              const SizedBox(width: 8),
              _buildFilterChip(
                'critical',
                isEn
                  ? 'STAR Critical ($criticalCount)'
                  : 'STAR Críticos ($criticalCount)',
                icon: Icons.crisis_alert_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterId, String label, {IconData? icon}) {
    final isSelected = _currentFilter == filterId;
    return InkWell(
      onTap: () {
        setState(() => _currentFilter = filterId);
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? VocabTheme.primary : VocabTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? Colors.transparent : VocabTheme.surfaceContainerHigh,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: VocabTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : TabTheme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : VocabTheme.secondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: VocabTheme.labelSm(
                color: isSelected ? Colors.white : VocabTheme.onSurface,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsList(bool isEn) {
    final list = _filteredItems;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.search_off_rounded,
                size: 40, color: VocabTheme.secondary),
            const SizedBox(height: 8),
            Text(
              isEn
                  ? 'No terms found for this search or filter.'
                  : 'No se encontraron términos para esta búsqueda o filtro.',
              style: VocabTheme.bodyMd(color: VocabTheme.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((item) => _buildTermCard(item, isEn)).toList(),
    );
  }

  Widget _buildTermCard(VocabularyItem item, bool isEn) {
    final isBookmarked = _bookmarkedTerms.contains(item.term);
    final hasSyn = item.synonyms.isNotEmpty;
    final synExpanded = _expandedSynonyms.contains(item.term);
    final isCardSwapped = _cardLanguageSwaps.contains(item.term);
    final effectiveIsEn = isCardSwapped ? !isEn : isEn;
    final isPlayingTerm = _playingTerm == item.term;
    final isPlayingSentence = _playingSentence == item.term;

    final primaryTextColor = AppTheme.isLight ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final secondaryTextColor = AppTheme.isLight ? const Color(0xFF475569) : const Color(0xFFCBD5E1);
    final mutedTextColor = AppTheme.isLight ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final boxBgColor = AppTheme.isLight ? const Color(0xFFF5EFE6) : const Color(0xFF201A14);
    final boxBorderColor = AppTheme.isLight ? const Color(0xFFE5DDCF) : const Color(0xFF3A3127);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VocabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Termino, Fonetica, Tag, Badge y Botones
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          item.term,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (item.hasWaveform)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildMiniWaveBar(5),
                              _buildMiniWaveBar(11),
                              _buildMiniWaveBar(4),
                              _buildMiniWaveBar(13),
                              _buildMiniWaveBar(8),
                            ],
                          ),
                        Text(
                          item.phonetic,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppTheme.isLight ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: boxBorderColor),
                          ),
                          child: Text(
                            item.partOfSpeech,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Estado FSRS
                    if (item.isCritical)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppTheme.isLight ? const Color(0xFFFEE2E2) : const Color(0xFF561A18),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppTheme.isLight ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.crisis_alert_rounded,
                              size: 13,
                              color: AppTheme.isLight ? const Color(0xFFDC2626) : const Color(0xFFF87171),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              effectiveIsEn ? 'STAR Critical' : 'Crítico entrevista',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppTheme.isLight ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (item.state == 'mastered')
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: VocabTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            effectiveIsEn
                                ? 'Consolidated (${item.retentionPercent}% memory)'
                                : 'Consolidado (${item.retentionPercent}% memoria)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: VocabTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            Icons.pending_actions_rounded,
                            size: 15,
                            color: VocabTheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            effectiveIsEn
                                ? 'In Progress (${item.retentionPercent}% retention)'
                                : 'En Aprendizaje (${item.retentionPercent}% retención)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: VocabTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Botones de acción: Switch Idioma Tarjeta, Audio y Bookmark
              Row(
                children: [
                  _BouncyCardAction(
                    onTap: () {
                      setState(() {
                        if (isCardSwapped) {
                          _cardLanguageSwaps.remove(item.term);
                        } else {
                          _cardLanguageSwaps.add(item.term);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: effectiveIsEn
                            ? const Color(0xFFE8F8F0)
                            : const Color(0xFFF4F0EA),
                        border: Border.all(
                          color: effectiveIsEn
                              ? const Color(0xFF16A34A).withValues(alpha: 0.45)
                              : const Color(0xFFD6CEC2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveIsEn
                                ? const Color(0xFF16A34A).withValues(alpha: 0.14)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 15,
                            color: effectiveIsEn
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF57534E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            effectiveIsEn ? 'EN' : 'ES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: effectiveIsEn
                                  ? const Color(0xFF14532D)
                                  : const Color(0xFF292524),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _BouncyCardAction(
                    onTap: () => _playPronunciation(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPlayingTerm
                            ? const Color(0xFFE8F8F0)
                            : const Color(0xFFF4F0EA),
                        border: Border.all(
                          color: isPlayingTerm
                              ? const Color(0xFF16A34A).withValues(alpha: 0.45)
                              : const Color(0xFFD6CEC2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isPlayingTerm
                                ? const Color(0xFF16A34A).withValues(alpha: 0.14)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: isPlayingTerm ? 6 : 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            isPlayingTerm
                                ? Icons.graphic_eq_rounded
                                : Icons.volume_up_rounded,
                            key: ValueKey(isPlayingTerm),
                            color: isPlayingTerm
                                ? const Color(0xFF14532D)
                                : const Color(0xFF166534),
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _BouncyCardAction(
                    onTap: () => _toggleBookmark(item),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isBookmarked
                            ? const Color(0xFFFEF7E6)
                            : const Color(0xFFF4F0EA),
                        border: Border.all(
                          color: isBookmarked
                              ? const Color(0xFFD97706).withValues(alpha: 0.4)
                              : const Color(0xFFD6CEC2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isBookmarked
                                ? const Color(0xFFD97706).withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isBookmarked
                            ? const Color(0xFFB45309)
                            : const Color(0xFF57534E),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tabla interactiva de tiempos verbales (Infinitive V1, Past V2, Participle V3) si es verbo irregular
          _buildVerbConjugationTable(item, effectiveIsEn),

          // Definición según idioma efectivo de la tarjeta (toggled con botón o tap)
          InkWell(
            onTap: () {
              setState(() {
                if (isCardSwapped) {
                  _cardLanguageSwaps.remove(item.term);
                } else {
                  _cardLanguageSwaps.add(item.term);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                effectiveIsEn ? item.definition : item.spanishDefinition,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                  height: 1.4,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // STAR Method Quote / Real Context Block
          if ((item.starQuote != null && item.starQuote!.trim().isNotEmpty && item.starQuote != '“”') ||
              item.exampleSentence.trim().isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: boxBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: boxBorderColor, width: 1.2),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4.5,
                      color: item.isCritical
                          ? const Color(0xFFDC2626)
                          : VocabTheme.primary,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (effectiveIsEn
                                      ? (item.starType ?? 'Contextual Usage')
                                      : (item.starType == 'STAR Interview Quote'
                                          ? 'Cita STAR de Entrevista'
                                          : 'Uso en Contexto Real')).toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: item.isCritical
                                        ? const Color(0xFFDC2626)
                                        : VocabTheme.primary,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                Text(
                                  _translateStarDimension(item.starDimension ?? item.category, effectiveIsEn),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: mutedTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.starQuote != null && item.starQuote!.trim().isNotEmpty && item.starQuote != '“”'
                                  ? item.starQuote!
                                  : '“${item.exampleSentence}”',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // Línea divisoria
                            Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 8),
                              height: 1.2,
                              color: boxBorderColor,
                            ),

                            // Acciones y notas funcionales del contexto real
                            Row(
                              children: [
                                _BouncyCardAction(
                                  onTap: () => _playSentence(item),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 11, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isPlayingSentence
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFE8F8F0),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: isPlayingSentence
                                            ? const Color(0xFF16A34A).withValues(alpha: 0.6)
                                            : const Color(0xFF16A34A).withValues(alpha: 0.4),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isPlayingSentence
                                              ? const Color(0xFF16A34A).withValues(alpha: 0.18)
                                              : const Color(0xFF16A34A).withValues(alpha: 0.08),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isPlayingSentence
                                              ? Icons.graphic_eq_rounded
                                              : Icons.volume_up_rounded,
                                          size: 15,
                                          color: const Color(0xFF14532D),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          effectiveIsEn ? 'Listen sentence' : 'Escuchar frase',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: const Color(0xFF14532D),
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (item.spanishNote.isNotEmpty || item.spanishDefinition.isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      item.spanishNote.isNotEmpty ? item.spanishNote : item.spanishDefinition,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Colocaciones habituales
          if (item.collocations != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: boxBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: boxBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    effectiveIsEn ? 'COMMON COLLOCATIONS:' : 'COLOCACIONES HABITUALES:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: mutedTextColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.collocations!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Technical Context Pill (ej. Idempotency)
          if (item.technicalCallout != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: boxBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: boxBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.webhook_rounded,
                        size: 16,
                        color: VocabTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        effectiveIsEn ? 'FinTech & REST Design Pattern' : 'Patrón de Diseño y Contexto Técnico',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.technicalCallout!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Sinónimos técnicos (si existen)
          if (hasSyn) ...[
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (synExpanded) {
                      _expandedSynonyms.remove(item.term);
                    } else {
                      _expandedSynonyms.add(item.term);
                    }
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      effectiveIsEn
                          ? '${synExpanded ? 'Hide' : 'View'} ${item.synonyms.length} technical synonyms'
                          : '${synExpanded ? 'Ocultar' : 'Ver'} ${item.synonyms.length} sinónimos técnicos',
                      style: VocabTheme.labelSm(
                        color: VocabTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      synExpanded
                          ? Icons.expand_less_rounded
                          : Icons.chevron_right_rounded,
                      size: 16,
                      color: VocabTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          _buildPronRow(item, effectiveIsEn),
          if (hasSyn && synExpanded) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.synonyms
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: VocabTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: VocabTheme.primaryContainer, width: 1),
                        ),
                        child: Text(
                          s,
                          style: VocabTheme.labelSm(
                            color: VocabTheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerbConjugationTable(VocabularyItem item, bool isEn) {
    final isVerb = item.category.toLowerCase().contains('irregular') ||
        item.partOfSpeech.toLowerCase().contains('verb') ||
        item.definition.startsWith('Irregular Verb') ||
        item.synonyms.any((s) => s.startsWith('V1:') || s.startsWith('V2:'));

    if (!isVerb) return const SizedBox.shrink();

    String v1 = item.synonyms.firstWhere((s) => s.startsWith('V1:'), orElse: () => '').replaceFirst('V1: ', '');
    String v2 = item.synonyms.firstWhere((s) => s.startsWith('V2:'), orElse: () => '').replaceFirst('V2: ', '');
    String v3 = item.synonyms.firstWhere((s) => s.startsWith('V3:'), orElse: () => '').replaceFirst('V3: ', '');

    if (v1.isEmpty) v1 = item.term;

    // Fallback de parseo de tiempos si no estan en synonyms
    if (v2.isEmpty && item.spanishDefinition.contains('Pasado:')) {
      final match = RegExp(r'Pasado:\s*([^•\)]+)').firstMatch(item.spanishDefinition);
      if (match != null) v2 = match.group(1)?.trim() ?? '';
    }
    if (v3.isEmpty && item.spanishDefinition.contains('Participio:')) {
      final match = RegExp(r'Participio:\s*([^\)]+)').firstMatch(item.spanishDefinition);
      if (match != null) v3 = match.group(1)?.trim() ?? '';
    }

    if (v2.isEmpty && v3.isEmpty) return const SizedBox.shrink();

    final ipas = item.phonetic.split('•').map((s) => s.trim()).toList();
    final ipa1 = ipas.isNotEmpty ? ipas[0] : item.phonetic;
    final ipa2 = ipas.length > 1 ? ipas[1] : '';
    final ipa3 = ipas.length > 2 ? ipas[2] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VocabTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timeline_rounded, size: 16, color: VocabTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    isEn ? 'VERB TENSES & FORMS' : 'TIEMPOS Y FORMAS VERBALES',
                    style: VocabTheme.labelSm(
                      color: VocabTheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: VocabTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Irregular',
                  style: VocabTheme.labelSm(
                    color: VocabTheme.onPrimaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVerbFormColumn(
                  tag: isEn ? 'Infinitive' : 'Infinitivo (Base)',
                  verb: v1,
                  ipa: ipa1,
                  badgeColor: const Color(0xFF56B588),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVerbFormColumn(
                  tag: isEn ? 'Past Simple' : 'Pasado Simple',
                  verb: v2,
                  ipa: ipa2,
                  badgeColor: const Color(0xFF6B9DE8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVerbFormColumn(
                  tag: isEn ? 'Past Participle' : 'Participio Pasado',
                  verb: v3,
                  ipa: ipa3,
                  badgeColor: const Color(0xFF937CD8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerbFormColumn({
    required String tag,
    required String verb,
    required String ipa,
    required Color badgeColor,
  }) {
    return InkWell(
      onTap: verb.isNotEmpty ? () => ref.read(audioPlayerProvider).playTts(verb, voice: AppVoices.vocabulary) : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: VocabTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              tag,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              verb.isNotEmpty ? verb : '-',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: VocabTheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (ipa.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                ipa,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: VocabTheme.secondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _togglePron(VocabularyItem item) async {
    final rec = ref.read(audioRecorderProvider);
    if (rec.state == RecordingState.recording) {
      final path = await rec.stopRecording();
      final wasTerm = _pronRecordingTerm;
      if (mounted) setState(() => _pronRecordingTerm = null);
      int fileLen = -1;
      bool fileExists = false;
      if (path != null && path.isNotEmpty) {
        try {
          final f = File(path);
          fileExists = await f.exists();
          if (fileExists) fileLen = await f.length();
        } catch (_) {}
      }
      ClientLogger.event('pron_rec',
          'stop term=${item.term} path=${path ?? "<null>"} exists=$fileExists len=$fileLen');
      if (wasTerm == item.term && path != null && path.isNotEmpty) {
        await _evaluatePron(item, path);
      } else if (wasTerm == item.term) {
        if (mounted) setState(() => _pronErrors.add(item.term));
      }
      return;
    }
    if (!await rec.requestPermission()) return;
    setState(() {
      _pronRecordingTerm = item.term;
      _pronErrors.remove(item.term);
    });
    await rec.startRecording();
    if (mounted) setState(() {});
  }

  Future<void> _evaluatePron(VocabularyItem item, String path) async {
    setState(() {
      _pronCheckingTerm = item.term;
      _pronTips.remove(item.term);
      _pronResults.remove(item.term);
    });
    final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
      section: 'vocabulary',
      audioPath: path,
      expectedTerm: item.term,
      expectedIpa: item.phonetic,
      userId: ref.read(activeUserIdProvider),
      exerciseType: 'single_word',
      category: item.category,
    );
    if (!mounted) return;
    final res = out.result;
    final ok = out.sttOk; // en vivo y con STT reconocida
    if (out.isLive && !ok) {
      ClientLogger.event('pron_check',
          'reject sttOk=${res.sttOk} recog="${res.recognized_text}" score=${res.score}');
    }
    setState(() {
      _pronCheckingTerm = null;
      if (ok) {
        _pronResults[item.term] = res;
        _pronScores[item.term] = res.score;
        _pronAudioPath[item.term] = path;
        _pronErrors.remove(item.term);
      } else if (out.isOffline) {
        _pronResults[item.term] = res; // marcador "Guardado offline"
        _pronErrors.remove(item.term);
      } else {
        _pronErrors.add(item.term);
      }
    });
    if (ok) _fetchPronTip(item, res); // analisis IA (no bloquea)
  }

  /// Pide al backend (LLM del portatil) un consejo tecnico de pronunciacion.
  Future<void> _fetchPronTip(VocabularyItem item, PronunciationResult res) async {
    setState(() => _pronTipLoading.add(item.term));
    try {
      final api = ref.read(apiClientProvider);
      final tip = await api.getPronunciationTip(
        term: item.term,
        ipa: item.phonetic,
        recognized: res.recognized_text,
        score: res.score,
        wrongPhonemes: res.wrongPhonemes,
        confidence: res.confidence,
      ).timeout(const Duration(seconds: 18));
      if (!mounted) return;
      setState(() {
        _pronTipLoading.remove(item.term);
        if (tip != null && tip.trim().isNotEmpty) {
          _pronTips[item.term] = tip.trim();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pronTipLoading.remove(item.term));
    }
  }

  Widget _buildPronRow(VocabularyItem item, bool isEn) {
    final rec = ref.watch(audioRecorderProvider);
    final bool recording =
        _pronRecordingTerm == item.term && rec.state == RecordingState.recording;
    final bool checking = _pronCheckingTerm == item.term;
    final int? score = _pronScores[item.term];
    final bool error = _pronErrors.contains(item.term);
    final PronunciationResult? res = _pronResults[item.term];
    final String? tip = _pronTips[item.term];
    final bool tipLoading = _pronTipLoading.contains(item.term);

    final String label = recording
        ? (isEn ? 'Stop' : 'Detener')
        : (checking
            ? (isEn ? 'Analyzing…' : 'Analizando…')
            : (isEn ? 'Pronounce' : 'Pronunciar'));

    final Color btnBg = recording
        ? const Color(0xFFFDE8E8)
        : (checking ? const Color(0xFFF4F0EA) : const Color(0xFFE8F8F0));
    final Color btnBorder = recording
        ? const Color(0xFFDC2626).withValues(alpha: 0.40)
        : (checking ? const Color(0xFFD6CEC2) : const Color(0xFF16A34A).withValues(alpha: 0.35));
    final Color btnFg = recording
        ? const Color(0xFF991B1B)
        : (checking ? const Color(0xFF57534E) : const Color(0xFF14532D));

    final Widget controlRow = Row(
      children: [
        _BouncyCardAction(
          onTap: checking ? () {} : () => _togglePron(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
            decoration: BoxDecoration(
              color: btnBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: btnBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: (recording ? Colors.red : const Color(0xFF16A34A)).withValues(alpha: 0.08),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (checking)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: btnFg,
                    ),
                  )
                else
                  Icon(
                    recording ? Icons.stop_rounded : Icons.mic_rounded,
                    size: 14,
                    color: btnFg,
                  ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: btnFg,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (score != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: score >= 70 ? const Color(0xFFE8F8F0) : const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: score >= 70
                    ? const Color(0xFF16A34A).withValues(alpha: 0.35)
                    : const Color(0xFFEA580C).withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: Text(
              '$score%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: score >= 70 ? const Color(0xFF14532D) : const Color(0xFF9A3412),
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        else if (error)
          Flexible(
            child: Text(
              isEn ? "Didn't catch it, try again" : 'No se captó, reinténtalo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                color: const Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );

    if (res == null) return controlRow;

    // Panel de analisis profesional.
    final List<String> phon = res.wrongPhonemes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controlRow,
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VocabTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: VocabTheme.surfaceContainerHigh),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.graphic_eq_rounded, size: 15, color: VocabTheme.primary),
                  const SizedBox(width: 6),
                  Text(isEn ? 'Pronunciation analysis' : 'Análisis de pronunciación',
                      style: VocabTheme.labelSm(
                          color: VocabTheme.onSurface, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              if (res.recognized_text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${isEn ? 'Heard' : 'Te escuché'}: "${res.recognized_text.trim()}"',
                    style: VocabTheme.bodySm(color: VocabTheme.secondary),
                  ),
                ),
              if (phon.isNotEmpty) ...[
                Text(isEn ? 'Sounds to polish:' : 'Sonidos a pulir:',
                    style: VocabTheme.labelSm(
                        color: VocabTheme.onSurface, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: phon.map((ph) {
                    final cleanSymbol = ph.replaceAll('/', '').trim();
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HvptExerciseScreen(targetPhoneme: cleanSymbol),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC26A1B).withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC26A1B).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.hearing_rounded, size: 12, color: Color(0xFFC26A1B)),
                              const SizedBox(width: 4),
                              Text(
                                '/$ph/',
                                style: VocabTheme.labelSm(
                                  color: const Color(0xFFC26A1B),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Color(0xFFC26A1B)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              if (tipLoading)
                Row(
                  children: [
                    SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: VocabTheme.primary)),
                    const SizedBox(width: 8),
                    Text(isEn ? 'Analyzing with AI…' : 'Analizando con IA…',
                        style: VocabTheme.bodySm(color: VocabTheme.secondary)),
                  ],
                )
              else if (tip != null)
                Text(tip, style: VocabTheme.bodySm(color: VocabTheme.onSurface))
              else if (res.feedback.trim().isNotEmpty)
                Text(res.feedback.trim(),
                    style: VocabTheme.bodySm(color: VocabTheme.onSurface)),
            ],
          ),
        ),
        if ((_pronAudioPath[item.term] ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          PitchComparatorPanel(
            audioPath: _pronAudioPath[item.term]!,
            text: item.term,
            voice: AppVoices.vocabulary,
            userId: ref.read(activeUserIdProvider),
            zone: MeasurementZones.vocabulary,
            targetId: item.term,
          ),
        ],
      ],
    );
  }

  Widget _buildMiniWaveBar(double height) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 3.5,
      height: height,
      decoration: BoxDecoration(
        color: VocabTheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildBottomStickyBar(bool isEn) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: VocabTheme.surface.withValues(alpha: 0.95),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _startPractice,
          style: ElevatedButton.styleFrom(
            backgroundColor: VocabTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                isEn
                    ? 'Start Guided Practice (10 exercises)'
                    : 'Iniciar Práctica Guiada (10 ejercicios)',
                style: VocabTheme.titleSm(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BouncyCardAction extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyCardAction({required this.child, required this.onTap});

  @override
  State<_BouncyCardAction> createState() => _BouncyCardActionState();
}

class _BouncyCardActionState extends State<_BouncyCardAction> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
