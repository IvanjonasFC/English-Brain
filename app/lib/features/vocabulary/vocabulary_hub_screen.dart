import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/widgets/glossy_button.dart';
import '../../core/widgets/coach_marks.dart';
import 'vocabulary_theme_tokens.dart';
import 'providers/vocabulary_packs_provider.dart';
import 'vocabulary_repository.dart';

class VocabularyHubScreen extends ConsumerStatefulWidget {
  const VocabularyHubScreen({super.key});

  @override
  ConsumerState<VocabularyHubScreen> createState() => _VocabularyHubScreenState();
}

class _VocabularyHubScreenState extends ConsumerState<VocabularyHubScreen> {
  String _category = 'general'; // 'general' | 'it'
  String _selectedCefrLevel = 'A1-A2'; // 'A1-A2', 'B1-B2', 'B2-C1', 'C1'
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
    if (await cache.hasSeenCoach('vocabulary')) return;
    if (!mounted) return;
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachToggle,
          title: 'Dos mundos de vocabulario',
          body: 'Cambia entre Inglés General (situaciones del día a día) y Tech/IT (vocabulario técnico para entrevistas y trabajo). Cada pestaña tiene sus propios packs.',
        ),
        CoachStep(
          targetKey: _kCoachLevels,
          title: 'Filtra por tu nivel',
          body: 'Elige tu nivel CEFR (A1 a C1). "Todos" muestra el catálogo completo. Los packs se filtran para ajustarse a la dificultad que selecciones.',
        ),
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Práctica recomendada de refuerzo',
          body: 'Detecta tus términos y áreas más débiles y te sugiere un tema relacionado para consolidar tus puntos de mejora.',
        ),
        const CoachStep(
          title: 'Practica tu pronunciación',
          body: 'Dentro de cada tarjeta puedes grabarte y recibir un análisis técnico de tu pronunciación. ¡Explora y aprende a tu ritmo!',
        ),
      ],
      accent: VocabTheme.primary,
    );
    await cache.markCoachSeen('vocabulary');
  }

  // Rail CEFR global (única fuente: TabTheme.cefrRail)
  final List<Map<String, String>> _cefrLevels = TabTheme.cefrRail;

  // Contador real de la sesion recomendada (pack 'backend'), sin literales.
  int _getRecTerms(List<VocabularyPack> packs) {
    try {
      return packs.firstWhere((p) => p.id == 'backend').totalTerms;
    } catch (_) {
      return 0;
    }
  }

  int _getRecMin(int terms) => (terms * 0.6).ceil().clamp(3, 20);

  List<VocabularyPack> _getFilteredTechPacks(List<VocabularyPack> allPacks) {
    return allPacks
        .where((pack) => pack.track == VocabTrack.tech)
        .where((pack) => pack.matchesCefrPill(_selectedCefrLevel))
        .toList();
  }

  List<VocabularyPack> _getFilteredGeneralPacks(List<VocabularyPack> allPacks) {
    return allPacks
        .where((pack) => pack.track == VocabTrack.general)
        .where((pack) => pack.matchesCefrPill(_selectedCefrLevel))
        .toList();
  }

  void _openPack(VocabularyPack pack, bool isEn) {
    context.go('/vocabulary/pack?pack_id=${pack.id}');
  }

  void _openRecommendedSession() {
    context.go('/vocabulary/practice?pack_id=backend');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale.languageCode == 'en';
    final packsAsync = ref.watch(vocabularyPacksProvider);

    final profile = ref.watch(activeProfileProvider).valueOrNull;
    if (!_hasUserSelectedCefr && profile != null) {
      _selectedCefrLevel = TabTheme.defaultPillForUserLevel(profile.targetLevel);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => refreshVocabulary(ref),
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
              packsAsync.when(
                data: (packs) => KeyedSubtree(key: _kCoachHero, child: _buildHeroFsrsCard(isEn, packs)),
                loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
                error: (e, s) => const SizedBox(height: 160, child: Center(child: Text('Error'))),
              ),
              const SizedBox(height: 22),
              packsAsync.when(
                data: (packs) => _category == 'it'
                    ? _buildTechCollectionsSection(isEn, _getFilteredTechPacks(packs))
                    : _buildGeneralPacksSection(isEn, _getFilteredGeneralPacks(packs)),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: VocabTheme.primary)),
                ),
                error: (err, stack) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Error cargando packs: $err', style: const TextStyle(color: VocabTheme.error))),
                ),
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
          isEn ? 'Explore Vocabulary' : 'Explora Vocabulario',
          style: VocabTheme.displayMd(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isEn
              ? 'High-impact executive lexicon for technical interviews and global leadership.'
              : 'Léxico de alto impacto para entrevistas técnicas y comunicación ejecutiva en equipos globales.',
          style: VocabTheme.bodyMd(color: VocabTheme.secondary),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          // Tab 1: Inglés General
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _category = 'general'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _category == 'general'
                      ? VocabTheme.surfaceContainerLowest
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
                          ? VocabTheme.primary
                          : VocabTheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'General English' : 'Inglés General',
                      style: VocabTheme.labelMd(
                        color: _category == 'general'
                            ? VocabTheme.onSurface
                            : VocabTheme.secondary,
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
          // Tab 2: Tech / IT Executive
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _category = 'it'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _category == 'it'
                      ? VocabTheme.surfaceContainerLowest
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
                          ? VocabTheme.primary
                          : VocabTheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'Tech / IT Executive' : 'Tech / IT Executive',
                      style: VocabTheme.labelMd(
                        color: _category == 'it'
                            ? VocabTheme.onSurface
                            : VocabTheme.secondary,
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

  Widget _buildHeroFsrsCard(bool isEn, List<VocabularyPack> packs) {
    // Adaptativo REAL: nº de tarjetas FSRS vencidas del usuario (cambia cada
    // día según su repaso). Si no hay ninguna vencida, cae al tamaño del pack.
    final int dueNow = ref.watch(dueCardsCountProvider).maybeWhen(
          data: (d) => d,
          orElse: () => 0,
        );
    final int fallbackTerms = _getRecTerms(packs);
    final terms = dueNow > 0 ? dueNow : fallbackTerms;
    final mins = _getRecMin(terms);
    
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VocabTheme.surfaceContainerHigh),
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
                    VocabTheme.primary.withValues(alpha: AppTheme.isLight ? 0.14 : 0.08),
                    VocabTheme.primary.withValues(alpha: 0.0),
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
                    TabTheme.aiFocusKicker(VocabTheme.primary, isEn: isEn),
                    Icon(
                      Icons.explore_rounded,
                      color: VocabTheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isEn
                      ? 'Daily Tech Vocabulary Drill'
                      : 'Práctica Diaria de Vocabulario Tech',
                  style: VocabTheme.headlineSm(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEn
                      ? 'Adaptive quiz focusing on your weakest terms and related topics to reinforce.'
                      : 'Quiz adaptativo enfocado en tus términos más débiles y temas relacionados a reforzar.',
                  style: VocabTheme.bodyMd(color: VocabTheme.secondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      isEn
                          ? '• $terms terms to consolidate'
                          : '• $terms términos por consolidar',
                      style: VocabTheme.labelSm(
                        color: VocabTheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: VocabTheme.secondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$mins min',
                          style: VocabTheme.labelSm(
                            color: VocabTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlossyButton(
                  color: VocabTheme.primary,
                  onPressed: _openRecommendedSession,
                  height: 52,
                  radius: 26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(isEn
                          ? 'Start Adaptive Session'
                          : 'Empezar sesión adaptativa'),
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

  Widget _buildTechCollectionsSection(bool isEn, List<VocabularyPack> packs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn
                  ? 'Tech Thematic Collections'
                  : 'Colecciones Temáticas Tech',
              style: VocabTheme.titleMd(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${packs.length} ${isEn ? 'topics' : 'temas'}',
              style: VocabTheme.labelSm(color: VocabTheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (packs.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              isEn
                  ? 'No collections found for level $_selectedCefrLevel'
                  : 'No se encontraron colecciones para el nivel $_selectedCefrLevel',
              style: VocabTheme.bodyMd(color: VocabTheme.secondary),
            ),
          )
        else
          Column(
            children: packs.map((pack) => _buildVocabPackCard(isEn, pack)).toList(),
          ),
      ],
    );
  }

  Widget _buildGeneralPacksSection(bool isEn, List<VocabularyPack> packs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? 'Daily Communication Topics' : 'Temas de Comunicación Diaria',
              style: VocabTheme.titleMd(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${packs.length} ${isEn ? 'topics' : 'temas'}',
              style: VocabTheme.labelSm(color: VocabTheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (packs.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              isEn
                  ? 'No topics found for level $_selectedCefrLevel'
                  : 'No se encontraron temas para el nivel $_selectedCefrLevel',
              style: VocabTheme.bodyMd(color: VocabTheme.secondary),
            ),
          )
        else
          Column(
            children: packs.map((pack) => _buildVocabPackCard(isEn, pack)).toList(),
          ),
      ],
    );
  }

  Widget _buildVocabPackCard(bool isEn, VocabularyPack pack) {
    final accentColor = pack.accentColor;
    final totalTerms = pack.totalTerms;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
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
          // Cabecera unificada GLOBAL: sin icono; meta (términos) + dificultad
          // (CEFR) alineadas a la DERECHA. Sin etiqueta General/Tech (se agrupa
          // por sección arriba).
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabTheme.cefrPill(pack.level),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.style_rounded,
                    size: 13,
                    color: VocabTheme.secondary,
                  ),
                  const SizedBox(width: 3.5),
                  Text(
                    '$totalTerms ${isEn ? 'terms' : 'términos'}',
                    style: VocabTheme.labelSm(color: VocabTheme.secondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Título y Subtítulo
          Text(
            pack.title,
            style: VocabTheme.titleMd(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isEn
                ? '$totalTerms technical terms with FSRS spaced repetition, natural TTS and phonetic feedback.'
                : '$totalTerms términos clave con algoritmo FSRS, pronunciación neural y análisis de voz.',
            style: VocabTheme.bodyMd(color: VocabTheme.secondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),

          // Botones de Acción Dual: Explorar + Practicar
          Row(
            children: [
              // Botón Secundario: Explorar
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () => _openPack(pack, isEn),
                    icon: Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: VocabTheme.primary,
                    ),
                    label: Text(
                      isEn ? 'Explore' : 'Explorar',
                      style: TextStyle(
                        color: VocabTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VocabTheme.primary,
                      side: BorderSide(
                        color: VocabTheme.primary.withValues(alpha: 0.45),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Botón Primario: Practicar
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/vocabulary/practice?pack_id=${pack.id}'),
                    icon: const Icon(
                      Icons.flash_on_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      isEn ? 'Practice ($totalTerms)' : 'Practicar ($totalTerms)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VocabTheme.primary,
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
