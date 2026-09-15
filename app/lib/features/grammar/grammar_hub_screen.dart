import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/widgets/glossy_button.dart';
import '../../core/widgets/coach_marks.dart';
import 'grammar_models.dart';
import 'grammar_theme_tokens.dart';
import 'grammar_screen.dart';
import 'grammar_drill_runner.dart';
import 'providers/grammar_units_provider.dart';
import '../vocabulary/vocabulary_repository.dart';

/// Pantalla 1: "Gramática - Catálogo Principal en Acción"
/// Basada en el diseño Stitch con track switcher ("Inglés General" vs "Tech / IT Executive"),
/// rail de niveles CEFR, Hero de Unidad Prioritaria IA, chips de filtrado,
/// y tarjetas de unidades completas con accesos directos a "Guía" y "Practicar".
class GrammarHubScreen extends ConsumerStatefulWidget {
  const GrammarHubScreen({super.key});

  @override
  ConsumerState<GrammarHubScreen> createState() => _GrammarHubScreenState();
}

class _GrammarHubScreenState extends ConsumerState<GrammarHubScreen> {
  // 'general' | 'it'
  String _category = 'general';

  // 'A1-A2' | 'B1-B2' | 'B2-C1' | 'C1' | 'all'
  String _selectedCefrLevel = 'all';
  bool _hasUserSelectedCefr = false;

  // Coach-marks tutorial targets
  final GlobalKey _kCoachToggle = GlobalKey();
  final GlobalKey _kCoachLevels = GlobalKey();
  final GlobalKey _kCoachHero = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('grammar')) return;
    if (!mounted) return;
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachToggle,
          title: 'Gramática en dos contextos',
          body: 'Inglés General cubre la gramática del día a día; Tech/IT enfoca estructuras típicas del entorno profesional y las entrevistas técnicas.',
        ),
        CoachStep(
          targetKey: _kCoachLevels,
          title: 'Ajusta la dificultad',
          body: 'Filtra las unidades por nivel CEFR (A1 a C1). Empieza por tu nivel y sube gradualmente para avanzar.',
        ),
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Tu unidad prioritaria',
          body: 'Te sugerimos la unidad más importante para ti ahora. Al practicar, recibirás un análisis profesional de tus respuestas, no solo un acierto/fallo.',
        ),
      ],
      accent: GrammarTheme.primary,
    );
    await cache.markCoachSeen('grammar');
  }

  // 'todas' | 'pendientes' | 'dominadas'
  String _statusFilter = 'todas';

  // Rail CEFR global (única fuente: TabTheme.cefrRail)
  final List<Map<String, String>> _cefrLevels = TabTheme.cefrRail;

  List<GrammarUnit> _getFilteredUnits(List<GrammarUnit> allUnits, Map<String, GrammarUnitProgress> progressMap) {
    final matched = allUnits.where((u) {
      // 1. Filtrar por CEFR (si no es 'all')
      if (_selectedCefrLevel != 'all' && !Cefr.matchesPill(u.tag, _selectedCefrLevel)) {
        return false;
      }

      // 2. Filtrar por estado
      final prog = progressMap[u.id];
      final isCompleted = prog?.isCompleted == true;
      if (_statusFilter == 'dominadas') {
        return isCompleted;
      } else if (_statusFilter == 'pendientes') {
        return !isCompleted;
      }

      return true;
    }).toList();

    // 3. ORDENACIÓN PEDAGÓGICA: Las unidades pendientes van ARRIBA y las completadas van AL FONDO
    matched.sort((a, b) {
      final compA = progressMap[a.id]?.isCompleted == true;
      final compB = progressMap[b.id]?.isCompleted == true;
      if (compA != compB) {
        return compA ? 1 : -1; // Las completadas van al fondo
      }
      return 0;
    });

    return matched;
  }

  void _openGuide(GrammarUnit unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GrammarScreen(unit: unit),
      ),
    );
  }

  void _openDrills(GrammarUnit unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GrammarDrillRunner(unit: unit),
      ),
    );
  }

  String _clean(String title) => title.replaceFirst(RegExp(r'^Unit \d+: '), '');

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale.languageCode == 'en';
    final unitsAsync = ref.watch(grammarUnitsProvider);
    final progressAsync = ref.watch(grammarUnitProgressProvider);
    final progressMap = progressAsync.valueOrNull ?? const <String, GrammarUnitProgress>{};

    final profile = ref.watch(activeProfileProvider).valueOrNull;
    if (!_hasUserSelectedCefr && profile != null) {
      _selectedCefrLevel = TabTheme.defaultPillForUserLevel(profile.targetLevel);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => refreshGrammar(ref),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitleSection(isEn),
              const SizedBox(height: 16),
              KeyedSubtree(key: _kCoachToggle, child: _buildSegmentedToggle(isEn)),
              const SizedBox(height: 14),
              KeyedSubtree(key: _kCoachLevels, child: _buildLevelRail(isEn)),
              const SizedBox(height: 18),
              unitsAsync.when(
                data: (units) {
                  if (units.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No grammar units found.'),
                    ));
                  }
                  final filtered = _getFilteredUnits(units, progressMap);
                  // La unidad prioritaria es la primera pendiente relevante
                  final pendingList = filtered.where((u) => progressMap[u.id]?.isCompleted != true).toList();
                  final priorityUnit = pendingList.isNotEmpty
                      ? pendingList.first
                      : (filtered.isNotEmpty ? filtered.first : units.first);
                  final priorityProg = progressMap[priorityUnit.id];

                  return Column(
                    children: [
                      KeyedSubtree(key: _kCoachHero, child: _buildPriorityHeroCard(priorityUnit, priorityProg, isEn)),
                      const SizedBox(height: 22),
                      _buildSectionHeader(filtered.length, isEn),
                      const SizedBox(height: 10),
                      _buildFilterChips(isEn),
                      const SizedBox(height: 14),
                      _buildUnitList(isEn, filtered, progressMap),
                    ],
                  );
                },
                loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: GrammarTheme.error))),
              ),
            ],
          ),
        )),
      ),
    );
  }


  Widget _buildTitleSection(bool isEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Explore Grammar' : 'Explora Gramática',
          style: GrammarTheme.displayMd(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _category == 'it'
              ? (isEn
                  ? 'High-impact structures for technical interviews and executive engineering communication.'
                  : 'Estructuras de alto impacto para entrevistas técnicas y comunicación ejecutiva en equipos globales.')
              : (isEn
                  ? 'Essential grammar rules, sentence patterns, and everyday communicative fluency.'
                  : 'Reglas gramaticales esenciales, patrones de frase y fluidez comunicativa para el día a día.'),
          style: GrammarTheme.bodyMd(color: GrammarTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _category = 'general'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _category == 'general'
                      ? GrammarTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _category == 'general'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 17,
                      color: _category == 'general'
                          ? GrammarTheme.primary
                          : GrammarTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'General English' : 'Inglés General',
                      style: GrammarTheme.labelMd(
                        color: _category == 'general'
                            ? GrammarTheme.onSurface
                            : GrammarTheme.onSurfaceVariant,
                        fontWeight: _category == 'general'
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _category = 'it'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _category == 'it'
                      ? GrammarTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _category == 'it'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      size: 17,
                      color: _category == 'it'
                          ? GrammarTheme.primary
                          : GrammarTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tech / IT Executive',
                      style: GrammarTheme.labelMd(
                        color: _category == 'it'
                            ? GrammarTheme.onSurface
                            : GrammarTheme.onSurfaceVariant,
                        fontWeight: _category == 'it'
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelRail(bool isEn) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _cefrLevels.map((lvl) {
          final isSelected = _selectedCefrLevel.toLowerCase() == lvl['id']!.toLowerCase();
          final label = isEn ? lvl['en']! : lvl['es']!;
          return TabTheme.filterLevelPill(
            id: lvl['id']!,
            label: label,
            isSelected: isSelected,
            onTap: () => setState(() {
              if (_selectedCefrLevel.toLowerCase() == lvl['id']!.toLowerCase()) {
                _selectedCefrLevel = 'all';
              } else {
                _selectedCefrLevel = lvl['id']!;
              }
              _hasUserSelectedCefr = true;
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriorityHeroCard(GrammarUnit unit, GrammarUnitProgress? prog, bool isEn) {
    final hasAttempt = prog != null && (prog.attempts > 0 || prog.bestScore > 0);
    final accuracyPct = hasAttempt ? (prog.bestScore * 100).round() : 0;
    final isDone = prog?.isCompleted == true;
    final totalDrills = unit.questions.length;
    final completedDrills = isDone ? totalDrills : (hasAttempt ? (totalDrills * prog.bestScore).round().clamp(1, totalDrills - 1) : 0);
    final progressValue = isDone ? 1.0 : (hasAttempt ? prog.bestScore.clamp(0.05, 0.95) : 0.0);

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    GrammarTheme.primary.withValues(alpha: AppTheme.isLight ? 0.14 : 0.08),
                    GrammarTheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TabTheme.aiFocusKicker(GrammarTheme.primary, isEn: isEn),
                    Icon(
                      Icons.spellcheck_rounded,
                      color: GrammarTheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _clean(unit.title),
                  style: GrammarTheme.headlineSm(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.subtitle.isNotEmpty
                      ? unit.subtitle
                      : (isEn
                          ? 'Master precise structures and key grammar patterns for technical interviews.'
                          : 'Domina estructuras precisas y patrones clave de gramática para entrevistas técnicas.'),
                  style: GrammarTheme.bodyMd(color: GrammarTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Micro Metric Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasAttempt
                          ? '${isEn ? '$completedDrills of' : '$completedDrills de'} $totalDrills ${isEn ? 'drills completed' : 'drills completados'}'
                          : (isEn ? '0 drills completed' : '0 drills completados'),
                      style: GrammarTheme.labelSm(
                        color: GrammarTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      hasAttempt
                          ? '$accuracyPct% ${isEn ? 'accuracy' : 'acierto'}'
                          : (isEn ? 'Not started' : 'Sin empezar'),
                      style: GrammarTheme.labelSm(
                        color: GrammarTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 6,
                    backgroundColor: GrammarTheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? const Color(0xFF56B588) : GrammarTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Button
                GlossyButton(
                  color: GrammarTheme.primary,
                  onPressed: () => _openDrills(unit),
                  height: 52,
                  radius: 26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(isDone
                          ? (isEn ? 'Review Unit' : 'Repasar Unidad')
                          : (hasAttempt ? (isEn ? 'Continue Drills' : 'Continuar Drills') : (isEn ? 'Start Practice' : 'Empezar Práctica'))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(int count, bool isEn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              isEn ? 'Grammar Units' : 'Unidades de Gramática',
              style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: GrammarTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count ${isEn ? 'available' : 'disponibles'}',
                style: GrammarTheme.labelSm(
                  color: GrammarTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChips(bool isEn) {
    final chips = [
      {'id': 'todas', 'label': isEn ? 'All' : 'Todas'},
      {'id': 'pendientes', 'label': isEn ? 'Pending' : 'Pendientes'},
      {'id': 'dominadas', 'label': isEn ? 'Mastered' : 'Dominadas'},
    ];

    return Row(
      children: chips.map((c) {
        final isSel = _statusFilter == c['id'];
        return Container(
          margin: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => setState(() => _statusFilter = c['id']!),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSel
                    ? GrammarTheme.surfaceContainerHigh
                    : GrammarTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSel ? GrammarTheme.outlineVariant : Colors.transparent,
                ),
              ),
              child: Text(
                c['label']!,
                style: GrammarTheme.labelSm(
                  color: isSel ? GrammarTheme.onSurface : GrammarTheme.onSurfaceVariant,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitList(bool isEn, List<GrammarUnit> units, Map<String, GrammarUnitProgress> progressMap) {
    if (units.isEmpty) {
      final lvlLabel = _cefrLevels.firstWhere(
        (l) => l['id']!.toLowerCase() == _selectedCefrLevel.toLowerCase(),
        orElse: () => {'es': 'este nivel', 'en': 'this level'},
      );
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.auto_stories_rounded, size: 42, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              isEn ? 'No units match these filters.' : 'No hay unidades para ${lvlLabel['es']}.',
              style: GrammarTheme.bodyMd(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              isEn ? 'Tap the active level pill to show all units.' : 'Toca la píldora de nivel activa para ver todas las unidades.',
              style: GrammarTheme.labelSm(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: units.map((u) => _buildUnitCard(isEn, u, progressMap[u.id])).toList(),
    );
  }

  Widget _buildUnitCard(bool isEn, GrammarUnit unit, GrammarUnitProgress? prog) {
    final isMastered = prog?.isCompleted == true;
    final hasAttempt = prog != null && (prog.attempts > 0 || prog.bestScore > 0);
    final accuracyPct = hasAttempt ? (prog.bestScore * 100).round() : 0;

    final level = unit.tag.isNotEmpty ? unit.tag : (unit.level.isNotEmpty ? unit.level : 'B1-B2');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMastered
            ? (AppTheme.isLight ? const Color(0xFFFAFBF9) : GrammarTheme.surfaceContainerLowest)
            : GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMastered
              ? const Color(0xFF56B588).withValues(alpha: 0.35)
              : GrammarTheme.surfaceContainerHigh,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: CEFR a la IZQ; a la DER estado (Dominada/acierto, SIN
          // Pendiente) + nº de drills.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabTheme.cefrPill(
                  '$level • ${_category == 'it' ? 'Tech' : 'General'}'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMastered) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF56B588).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: const Color(0xFF56B588).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 13, color: Color(0xFF2D865B)),
                          const SizedBox(width: 4),
                          Text(
                            '$accuracyPct% ${isEn ? 'Mastered' : 'Dominada'}',
                            style: GrammarTheme.labelSm(
                              color: const Color(0xFF2D865B),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (hasAttempt) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GrammarTheme.tertiary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              size: 13, color: GrammarTheme.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            '$accuracyPct% ${isEn ? 'accuracy' : 'acierto'}',
                            style: GrammarTheme.labelSm(
                              color: GrammarTheme.tertiary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.fitness_center_rounded,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 3.5),
                  Text(
                    '${unit.questions.length} drills',
                    style: GrammarTheme.labelSm(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Subtitle
          Text(
            _clean(unit.title),
            style: GrammarTheme.titleMd(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            unit.subtitle,
            style: GrammarTheme.bodyMd(),
          ),
          const SizedBox(height: 14),

          // Dual Action Row: Guía + Practicar
          Row(
            children: [
              // Guía
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () => _openGuide(unit),
                    icon: Icon(Icons.menu_book_rounded, size: 16, color: GrammarTheme.primary),
                    label: Text(
                      isEn ? 'Guide' : 'Guía',
                      style: TextStyle(
                        color: GrammarTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GrammarTheme.primary,
                      side: BorderSide(color: GrammarTheme.primary.withValues(alpha: 0.45)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Practicar / Repasar
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => _openDrills(unit),
                    icon: Icon(
                      isMastered ? Icons.replay_rounded : Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isMastered
                          ? (isEn ? 'Review' : 'Repasar')
                          : '${isEn ? 'Practice' : 'Practicar'} (${unit.questions.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isMastered
                          ? const Color(0xFF56B588)
                          : GrammarTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
