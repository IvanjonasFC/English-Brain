import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/widgets/glossy_button.dart';
import 'comprehension_models.dart';
import 'comprehension_theme_tokens.dart';
import 'providers/comprehension_pieces_provider.dart';
import '../vocabulary/vocabulary_repository.dart';
import '../../core/widgets/coach_marks.dart';

/// Reading & Listening hub — mirrors the Grammar/Vocabulary hubs: dual segment
/// (Inglés General / Inglés Profesional), CEFR level rail, unified Hero Session card,
/// and a list of pieces with two entry points per piece (Leer / Escuchar).
class ComprehensionHubScreen extends ConsumerStatefulWidget {
  const ComprehensionHubScreen({super.key});

  @override
  ConsumerState<ComprehensionHubScreen> createState() => _ComprehensionHubScreenState();
}

class _ComprehensionHubScreenState extends ConsumerState<ComprehensionHubScreen> {
  bool _general = true;
  String _level = 'A1-A2';
  bool _hasUserSelectedLevel = false;

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
    if (await cache.hasSeenCoach('comprehension')) return;
    if (!mounted) return;
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachToggle,
          title: 'Dos formatos de inmersión',
          body: 'Alterna entre Inglés General (situaciones cotidianas y anécdotas) y Tech / IT (incidentes, arquitectura y post-mortems reales).',
        ),
        CoachStep(
          targetKey: _kCoachLevels,
          title: 'Dificultad adaptativa',
          body: 'Elige tu nivel CEFR (A1 a C1) para ajustar la complejidad del vocabulario y la velocidad del audio a tu progreso.',
        ),
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Sesión recomendada de inmersión',
          body: 'Comienza una sesión guiada con transcripción sincronizada y ejercicios de comprensión lectora y auditiva.',
        ),
        const CoachStep(
          title: 'Preguntas y práctica oral',
          body: 'Cada lectura incluye preguntas interactivas y ejercicios hablados donde grabas tu voz para recibir evaluación.',
        ),
      ],
      accent: CompTheme.primary,
    );
    await cache.markCoachSeen('comprehension');
  }

  // Rail CEFR global (única fuente: TabTheme.cefrRail)
  final List<Map<String, String>> _levels = TabTheme.cefrRail;

  List<ComprehensionPiece> _filter(List<ComprehensionPiece> all) {
    var list = all.where((p) => p.isGeneral == _general).toList();
    if (_level != 'all') {
      list = list.where((p) => Cefr.matchesPill(p.band, _level)).toList();
    }
    return list;
  }


  void _open(ComprehensionPiece p, CompMode mode) {
    final m = mode == CompMode.listening ? 'listening' : 'reading';
    context.go('/comprehension/piece?id=${p.id}&mode=$m');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale.languageCode == 'en';

    final profile = ref.watch(activeProfileProvider).valueOrNull;
    if (!_hasUserSelectedLevel && profile != null) {
      _level = TabTheme.defaultPillForUserLevel(profile.targetLevel);
    }
    final loaded = ref.watch(comprehensionPiecesProvider).maybeWhen(
          data: (l) => l,
          orElse: () => allComprehensionPieces,
        );
    final attemptsMap = ref.watch(comprehensionAttemptsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <String, double>{},
        );
    final allPieces = loaded.where((p) => p.isGeneral == _general).toList();
    final filtered = _filter(loaded);
    final priorityPiece = filtered.isNotEmpty ? filtered.first : (allPieces.isNotEmpty ? allPieces.first : null);

    // Split: pendientes arriba, completadas al fondo
    final pending   = filtered.where((p) => !attemptsMap.containsKey(p.id)).toList();
    final completed = filtered.where((p) =>  attemptsMap.containsKey(p.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => refreshComprehension(ref),
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
              if (priorityPiece != null) ...[
                KeyedSubtree(key: _kCoachHero, child: _buildHeroCard(isEn, priorityPiece)),
                const SizedBox(height: 22),
              ],
              if (filtered.isEmpty)
                _emptyState(isEn)
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Available Stories & Articles' : 'Historias y Artículos Disponibles',
                      style: CompTheme.titleMd(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${pending.length} ${isEn ? 'pending' : 'pendientes'}'  
                      '${completed.isNotEmpty ? ' · ${completed.length} ${isEn ? 'done' : 'completadas'}' : ''}',
                      style: CompTheme.labelSm(color: CompTheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // --- Pendientes ---
                ...pending.map((p) => _buildPieceCard(isEn, p, null)),
                // --- Completadas ---
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 6),
                        Text(
                          isEn ? 'Completed' : 'Completadas',
                          style: CompTheme.labelSm(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...completed.map((p) => _buildPieceCard(isEn, p, attemptsMap[p.id])),
                ],
              ],
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
          isEn ? 'Reading & Listening' : 'Comprensión',
          style: CompTheme.displayMd(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          isEn
              ? 'Immersive reading and listening to master executive technical context and narrative cadence.'
              : 'Lee y escucha textos por nivel con audio nativo, y comprueba tu comprensión con preguntas clave.',
          style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: CompTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _general = true),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _general
                      ? CompTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _general
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
                      color: _general ? CompTheme.primary : CompTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'General English' : 'Inglés General',
                      style: CompTheme.labelMd(
                        color: _general ? CompTheme.onSurface : CompTheme.onSurfaceVariant,
                        fontWeight: _general ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _general = false),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_general
                      ? CompTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: !_general
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
                      color: !_general ? CompTheme.primary : CompTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'Tech / IT Executive' : 'Tech / IT Executive',
                      style: CompTheme.labelMd(
                        color: !_general ? CompTheme.onSurface : CompTheme.onSurfaceVariant,
                        fontWeight: !_general ? FontWeight.w700 : FontWeight.w500,
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
        children: _levels.map((lvl) {
          final isSelected = _level.toLowerCase() == lvl['id']!.toLowerCase();
          final label = isEn ? lvl['en']! : lvl['es']!;
          return TabTheme.filterLevelPill(
            id: lvl['id']!,
            label: label,
            isSelected: isSelected,
            onTap: () => setState(() {
              if (_level.toLowerCase() == lvl['id']!.toLowerCase()) {
                _level = 'all';
              } else {
                _level = lvl['id']!;
              }
              _hasUserSelectedLevel = true;
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeroCard(bool isEn, ComprehensionPiece p) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: CompTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CompTheme.surfaceContainerHigh),
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
                    CompTheme.primary.withValues(alpha: AppTheme.isLight ? 0.14 : 0.08),
                    CompTheme.primary.withValues(alpha: 0.0),
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
                    TabTheme.aiFocusKicker(CompTheme.primary, isEn: isEn),
                    Icon(
                      Icons.headphones_rounded,
                      color: CompTheme.primary,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  p.title,
                  style: CompTheme.headlineSm(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${p.band} · ${p.category} · ${p.wordCount} ${isEn ? 'words' : 'palabras'}. ${isEn ? 'Immersive audio narrator with interactive comprehension checks.' : 'Audio nativo inmersivo con preguntas de comprensión lectora.'}',
                  style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      isEn
                          ? '• ${p.questions.length} questions included'
                          : '• ${p.questions.length} preguntas de comprensión',
                      style: CompTheme.labelSm(
                        color: CompTheme.primary,
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
                          color: CompTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${p.estMinutes} min',
                          style: CompTheme.labelSm(
                            color: CompTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlossyButton(
                  color: CompTheme.primary,
                  onPressed: () => _open(p, CompMode.listening),
                  height: 52,
                  radius: 26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(isEn ? 'Start Reading & Audio' : 'Iniciar Lectura y Audio'),
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

  IconData _categoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('opin')) return Icons.forum_rounded;
    if (cat.contains('tech')) return Icons.terminal_rounded;
    if (cat.contains('work') || cat.contains('trabajo')) return Icons.business_center_rounded;
    if (cat.contains('cultur') || cat.contains('histori')) return Icons.auto_stories_rounded;
    return Icons.article_rounded;
  }

  Widget _buildPieceCard(bool isEn, ComprehensionPiece p, double? lastScore) {
    final isDone = lastScore != null;
    final scorePct = isDone ? (lastScore * 100).round() : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone
            ? CompTheme.surfaceContainerLowest.withValues(alpha: 0.7)
            : CompTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone
              ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
              : CompTheme.surfaceContainerHigh,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabTheme.cefrPill(
                  '${p.band} • ${p.isGeneral ? 'General' : 'Tech'}'),
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded, size: 12, color: Color(0xFF4CAF50)),
                      const SizedBox(width: 4),
                      Text(
                        '$scorePct%',
                        style: CompTheme.labelSm(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 12.5,
                      color: CompTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      '${p.wordCount} ${isEn ? 'words' : 'pal.'}',
                      style: CompTheme.labelSm(color: CompTheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        color: CompTheme.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.schedule_rounded,
                      size: 12.5,
                      color: CompTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      '${p.estMinutes} min',
                      style: CompTheme.labelSm(color: CompTheme.onSurfaceVariant),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(p.title, style: CompTheme.titleMd(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            isDone
                ? (isEn
                    ? '${p.questions.length} questions answered · ${p.wordCount} words · ${p.estMinutes} min'
                    : '${p.questions.length} preguntas respondidas · ${p.wordCount} palabras · ${p.estMinutes} min')
                : (isEn
                    ? '${p.questions.length} questions to verify'
                    : '${p.questions.length} preguntas para comprobar'),
            style: CompTheme.bodyMd(
              color: isDone
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.8)
                  : CompTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(p, CompMode.reading),
                  icon: const Icon(Icons.menu_book_rounded, size: 18),
                  label: Text(isEn ? (isDone ? 'Re-read' : 'Read') : (isDone ? 'Releer' : 'Leer')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CompTheme.primary,
                    side: BorderSide(color: CompTheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _open(p, CompMode.listening),
                  icon: const Icon(Icons.headphones_rounded, size: 18, color: Colors.white),
                  label: Text(
                    isEn ? (isDone ? 'Listen Again' : 'Listen') : (isDone ? 'Volver a escuchar' : 'Escuchar'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDone
                        ? const Color(0xFF4CAF50)
                        : CompTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(bool isEn) => Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 40, color: CompTheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              isEn ? 'No content in this level yet' : 'Aún no hay contenido en este nivel',
              style: CompTheme.titleSm(color: CompTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              isEn ? 'Try another level or switch tabs.' : 'Prueba con otro nivel o el otro segmento.',
              style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
