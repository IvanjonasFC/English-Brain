import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/contextual_pronunciation_practice_sheet.dart';
import 'models/irregular_verb.dart';
import 'data/irregular_verbs_data.dart';
import 'providers/irregular_verbs_provider.dart';

class IrregularVerbsScreen extends ConsumerStatefulWidget {
  const IrregularVerbsScreen({super.key});

  @override
  ConsumerState<IrregularVerbsScreen> createState() => _IrregularVerbsScreenState();
}

class _IrregularVerbsScreenState extends ConsumerState<IrregularVerbsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedVerbIds = {};
  String? _currentlyPlayingVerbId;
  String? _recordingVerbId;
  String? _evaluatingVerbId;
  final Map<String, double> _recentVerbScores = {};
  final Map<String, String> _recentFeedback = {};

  final Color _primaryAccent = const Color(0xFF0D9488); // Teal Tecnológico C1

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _generateWorkplaceScenariosForIrregularVerb(IrregularVerb verb) {
    return [
      'Yesterday the senior engineer ${verb.v2} a hotfix to patch the memory leak.',
      'We have ${verb.v3} comprehensive end-to-end tests for the new microservice.',
      'Before the incident was resolved, the team ${verb.v2} all configuration parameters.',
      'The architecture team has ${verb.v3} an RFC to refactor our caching layer.',
      'In yesterday\'s sprint review, we ${verb.v2} the latency metrics with stakeholders.',
      'Our DevOps pipeline has ${verb.v3} the build artifacts to the cloud cluster.',
    ];
  }

  Future<void> _toggleRecordVerb(IrregularVerb verb) async {
    final rec = ref.read(audioRecorderProvider);
    if (_recordingVerbId == verb.id) {
      // Stop and evaluate
      AppHaptics.medium();
      setState(() {
        _recordingVerbId = null;
        _evaluatingVerbId = verb.id;
      });
      final path = await rec.stopRecording();
      if (path != null && mounted) {
        // Evaluación centralizada: en vivo si se puede, y si no, cola offline
        // + aviso (antes esto fallaba en silencio).
        final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
          section: 'irregular_verbs',
          audioPath: path,
          expectedTerm: '${verb.v1}, ${verb.v2}, ${verb.v3}',
          expectedIpa: '${verb.ipaV1} ${verb.ipaV2} ${verb.ipaV3}',
          userId: ref.read(activeUserIdProvider),
          exerciseType: 'irregular_verbs_matrix',
          category: 'irregular_verbs',
        );
        if (!mounted) return;
        final res = out.result;
        setState(() {
          _evaluatingVerbId = null;
          if (out.isLive) {
            _recentVerbScores[verb.id] =
                res.score.toDouble().clamp(0.0, 100.0);
          }
          if (res.feedback.isNotEmpty) {
            _recentFeedback[verb.id] = res.feedback;
          }
        });
        if (out.isLive) {
          ref.read(verbsLabNotifierProvider.notifier).recordAttempt(
                verbId: verb.id,
                exerciseType: 'pronunciation',
                isSuccess: res.score >= 65,
                pronunciationScore: res.score.toDouble(),
                expectedForm: verb.v1,
                actualForm: res.recognized_text.isNotEmpty
                    ? res.recognized_text
                    : verb.v1,
                contextSentence: verb.exampleSentence,
              );
        }
      } else {
        if (mounted) setState(() => _evaluatingVerbId = null);
      }
    } else {
      // Start recording
      AppHaptics.medium();
      await rec.startRecording();
      if (mounted) {
        setState(() => _recordingVerbId = verb.id);
      }
    }
  }

  Future<void> _playSequence(IrregularVerb verb, {bool slow = false}) async {
    setState(() {
      _currentlyPlayingVerbId = verb.id;
    });

    final player = ref.read(audioPlayerProvider);
    // V1
    await player.playTts(verb.v1, slow: slow);
    await Future.delayed(Duration(milliseconds: slow ? 850 : 650));
    // V2
    if (mounted && _currentlyPlayingVerbId == verb.id) {
      await player.playTts(verb.v2, slow: slow);
      await Future.delayed(Duration(milliseconds: slow ? 850 : 650));
    }
    // V3
    if (mounted && _currentlyPlayingVerbId == verb.id) {
      await player.playTts(verb.v3, slow: slow);
    }

    if (mounted) {
      setState(() {
        if (_currentlyPlayingVerbId == verb.id) {
          _currentlyPlayingVerbId = null;
        }
      });
    }
  }

  Future<void> _playSingle(String text) async {
    final player = ref.read(audioPlayerProvider);
    await player.playTts(text);
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(irregularVerbsStatsProvider);
    final state = ref.watch(verbsLabNotifierProvider);
    final filteredVerbs = ref.watch(filteredIrregularVerbsProvider);
    // Prefetch premium: pre-genera el audio neural del NAS de lo visible.
    ref.read(audioPrefetchProvider).warm(
      filteredVerbs.expand((v) => [v.v1, v.v2, v.v3]),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matriz y Catálogo de Verbos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Presente • Pasado Simple • Participio Pasado',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _primaryAccent,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top Stats & Search Bar
          _buildTopControls(stats, state),
          // CEFR Filter Rail
          _buildCefrRail(state),
          // Filter Chips Row
          _buildGroupFilterChips(state),
          const SizedBox(height: 6),
          // List of Verbs
          Expanded(
            child: filteredVerbs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: filteredVerbs.length,
                    itemBuilder: (context, index) {
                      final verb = filteredVerbs[index];
                      final isExpanded = _expandedVerbIds.contains(verb.id);
                      final isFavorite = state.favoriteIds.contains(verb.id);
                      final metrics = state.metricsByVerb[verb.id] ?? const VerbProgressMetrics();
                      final isPlaying = _currentlyPlayingVerbId == verb.id;

                      return _buildVerbCard(
                        verb: verb,
                        isExpanded: isExpanded,
                        isFavorite: isFavorite,
                        metrics: metrics,
                        isPlaying: isPlaying,
                        isRecording: _recordingVerbId == verb.id,
                        isEvaluating: _evaluatingVerbId == verb.id,
                        recentScore: _recentVerbScores[verb.id],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls(VerbsLabStats stats, VerbsLabState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      color: AppTheme.surface,
      child: Column(
        children: [
          // Stat progress banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF99F6E4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'DOMINIO COMPUESTO',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _primaryAccent,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${stats.masteredCount} / ${stats.totalVerbs} Consolidados (${(stats.overallProgress * 100).round()}%)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _primaryAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.overallProgress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFCCFBF1),
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Search box
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: TabTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TabTheme.surfaceContainerHigh),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(verbsLabNotifierProvider.notifier).setSearchQuery(val);
              },
              style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar por verbo, pasado o significado...',
                hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppTheme.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(verbsLabNotifierProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCefrRail(VerbsLabState state) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 4, bottom: 2),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...TabTheme.cefrRail.map((lvl) {
            final isSelected = state.activeCefrRoute.toLowerCase() == lvl['id']!.toLowerCase() ||
                (state.activeCefrRoute == 'C1+' && lvl['id'] == 'C1');
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TabTheme.filterLevelPill(
                id: lvl['id']!,
                label: lvl['es']!,
                isSelected: isSelected,
                onTap: () {
                  AppHaptics.light();
                  final target = lvl['id'] == 'C1' ? 'C1+' : lvl['id']!;
                  if (state.activeCefrRoute == target) {
                    ref.read(verbsLabNotifierProvider.notifier).setActiveCefrRoute('all');
                  } else {
                    ref.read(verbsLabNotifierProvider.notifier).setActiveCefrRoute(target);
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGroupFilterChips(VerbsLabState state) {
    final groups = [
      {'id': 'all', 'label': 'Todos (${IrregularVerbsData.verbs.length})'},
      {'id': 'all_same', 'label': 'A-A-A (Idénticos)'},
      {'id': 'past_participle_same', 'label': 'A-B-B (Pasado=Participio)'},
      {'id': 'base_participle_same', 'label': 'A-B-A (Base=Participio)'},
      {'id': 'i_a_u', 'label': 'i — a — u'},
      {'id': 'ew_own', 'label': '-ew / -own'},
      {'id': 'en_participle', 'label': '-en (Participio)'},
      {'id': 'completely_irregular', 'label': 'Totalmente Irregulares'},
      {'id': 'senior_technical', 'label': 'Senior Technical'},
    ];

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groups.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final g = groups[index];
          final isSelected = state.selectedGroup == g['id'];

          return InkWell(
            onTap: () {
              AppHaptics.light();
              ref.read(verbsLabNotifierProvider.notifier).setSelectedGroup(g['id']!);
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? _primaryAccent : TabTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _primaryAccent : TabTheme.surfaceContainerHigh,
                ),
              ),
              child: Center(
                child: Text(
                  g['label']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerbCard({
    required IrregularVerb verb,
    required bool isExpanded,
    required bool isFavorite,
    required VerbProgressMetrics metrics,
    required bool isPlaying,
    required bool isRecording,
    required bool isEvaluating,
    double? recentScore,
  }) {
    final isMastered = metrics.isMastered;
    final displayScore = recentScore ?? (metrics.pronunciationAvgScore > 0 ? metrics.pronunciationAvgScore : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isMastered
              ? const Color(0xFF10B981).withValues(alpha: 0.35)
              : TabTheme.surfaceContainerHigh,
          width: isMastered ? 1.5 : 1.0,
        ),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isMastered
                ? const Color(0xFFECFDF5)
                : TabTheme.surfaceContainerLow.withValues(alpha: 0.5),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    verb.spanish,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0369A1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    verb.cefrLevel,
                    style: GoogleFonts.firaCode(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (verb.isTechRelevant) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tech',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                // Favorite Button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 20,
                    color: isFavorite ? const Color(0xFFF59E0B) : AppTheme.textSecondary,
                  ),
                  onPressed: () {
                    AppHaptics.light();
                    ref.read(verbsLabNotifierProvider.notifier).toggleFavorite(verb.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                // Mastered / Interview Ready Badges
                if (metrics.isInterviewReady)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                        const SizedBox(width: 3),
                        Text(
                          'STAR Ready',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isMastered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF10B981)),
                        const SizedBox(width: 3),
                        Text(
                          'Consolidado',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${(metrics.compositeMastery * 100).round()}%',
                      style: GoogleFonts.firaCode(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Stress Pattern Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              verb.stressSeparation,
              style: GoogleFonts.firaCode(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _primaryAccent,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 3 Columns: Presente / Pasado / Participio
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: _buildTenseBox(
                    title: 'Presente / Base',
                    word: verb.v1,
                    ipa: verb.ipaV1,
                    accentColor: const Color(0xFF0284C7),
                    onTap: () => _playSingle(verb.v1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTenseBox(
                    title: 'Pasado Simple',
                    word: verb.v2,
                    ipa: verb.ipaV2,
                    accentColor: const Color(0xFF8B5CF6),
                    onTap: () => _playSingle(verb.v2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTenseBox(
                    title: 'Participio Pasado',
                    word: verb.v3,
                    ipa: verb.ipaV3,
                    accentColor: const Color(0xFF10B981),
                    onTap: () => _playSingle(verb.v3),
                  ),
                ),
              ],
            ),
          ),

          // Direct Integrated Actions: Hear Model + Slow + Record & GOP + Info Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                // Hear Model (V1 -> V2 -> V3)
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: (isPlaying || isRecording || isEvaluating)
                        ? null
                        : () {
                            AppHaptics.light();
                            _playSequence(verb, slow: false);
                          },
                    icon: isPlaying
                        ? const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0D9488)),
                          )
                        : const Icon(Icons.volume_up_rounded, size: 16),
                    label: Text(
                      isPlaying ? 'Audio...' : 'Hear model',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryAccent,
                      side: const BorderSide(color: Color(0xFF99F6E4)),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Slow (0.8x)
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: (isPlaying || isRecording || isEvaluating)
                        ? null
                        : () {
                            AppHaptics.light();
                            _playSequence(verb, slow: true);
                          },
                    icon: const Icon(Icons.slow_motion_video_rounded, size: 14),
                    label: Text(
                      'Slow',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(color: TabTheme.surfaceContainerHigh),
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Record / Practicar
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: isEvaluating ? null : () => _toggleRecordVerb(verb),
                    icon: isEvaluating
                        ? const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 15),
                    label: Text(
                      isRecording
                          ? 'Detener'
                          : isEvaluating
                              ? 'Analizando'
                              : displayScore != null
                                  ? '${displayScore.round()}%'
                                  : 'Grabar',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecording
                          ? const Color(0xFFEF4444)
                          : (displayScore != null && displayScore >= 70)
                              ? const Color(0xFF059669)
                              : _primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Toggle Example Accordion
                IconButton.filledTonal(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.info_outline_rounded,
                    size: 18,
                    color: isExpanded ? _primaryAccent : AppTheme.textSecondary,
                  ),
                  tooltip: isExpanded ? 'Ocultar ejemplos' : 'Ver ejemplos de uso y tips',
                  style: IconButton.styleFrom(
                    backgroundColor: isExpanded ? const Color(0xFFCCFBF1) : TabTheme.surfaceContainerHigh,
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    AppHaptics.light();
                    setState(() {
                      if (isExpanded) {
                        _expandedVerbIds.remove(verb.id);
                      } else {
                        _expandedVerbIds.add(verb.id);
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // Accordion: Examples & Related Phrasal Verbs
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                border: Border(top: BorderSide(color: TabTheme.surfaceContainerHigh)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (verb.relatedPhrasalVerbs.isNotEmpty) ...[
                    Text(
                      'USOS TÉCNICOS / PHRASAL VERBS RELACIONADOS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD97706),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: verb.relatedPhrasalVerbs
                          .map((pv) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFDE68A)),
                                ),
                                child: Text(pv, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF92400E))),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (verb.usageTip != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Tip: ${verb.usageTip}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF92400E))),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Práctica Contextual Unificada (Estilo Gramática con cambio de frase dinámico |>)
                  ContextualPronunciationPracticeSheet(
                    key: ValueKey('irreg_inline_${verb.id}'),
                    isInline: true,
                    title: '${verb.v1} · ${verb.v2} · ${verb.v3}',
                    category: 'irregular_verbs',
                    accentColor: _primaryAccent,
                    expectedTerm: verb.v1,
                    expectedIpa: '${verb.ipaV1} ${verb.ipaV2} ${verb.ipaV3}',
                    phrases: [
                      PronunciationPhraseItem(
                        label: 'Past Simple (${verb.v2})',
                        phrase: verb.examplePastSentence,
                        phonetic: '${verb.v1} -> ${verb.v2}',
                        translation: verb.spanish,
                      ),
                      PronunciationPhraseItem(
                        label: 'Past Participle (${verb.v3})',
                        phrase: verb.exampleParticipleSentence,
                        phonetic: 'have ${verb.v3}',
                        translation: verb.spanish,
                      ),
                      if (verb.exampleSentence.isNotEmpty && verb.exampleSentence != verb.examplePastSentence)
                        PronunciationPhraseItem(
                          label: 'Infinitive / Base (${verb.v1})',
                          phrase: verb.exampleSentence,
                          phonetic: verb.ipaV1,
                          translation: verb.spanish,
                        ),
                      ..._generateWorkplaceScenariosForIrregularVerb(verb).map(
                        (scen) => PronunciationPhraseItem(
                          label: 'Escenario Laboral',
                          phrase: scen,
                          phonetic: '${verb.v2} / ${verb.v3}',
                          translation: verb.spanish,
                        ),
                      ),
                    ],
                    onAttemptRecorded: (score, phrase) {
                      if (score < 0) return; // offline: no cuenta como intento
                      ref.read(verbsLabNotifierProvider.notifier).recordAttempt(
                            verbId: verb.id,
                            exerciseType: 'sentence_practice',
                            isSuccess: score >= 65.0,
                            expectedForm: phrase,
                            actualForm: phrase,
                            contextSentence: phrase,
                          );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTenseBox({
    required String title,
    required String word,
    required String ipa,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        AppHaptics.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: TabTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              word,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ipa,
              textAlign: TextAlign.center,
              style: GoogleFonts.firaCode(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              'No se encontraron verbos',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Prueba con otra palabra o selecciona "Todos" en los filtros.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
