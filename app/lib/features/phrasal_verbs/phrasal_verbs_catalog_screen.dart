import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/contextual_pronunciation_practice_sheet.dart';
import 'providers/phrasal_verbs_provider.dart';
import 'models/phrasal_verb.dart';

class PhrasalVerbsCatalogScreen extends ConsumerStatefulWidget {
  const PhrasalVerbsCatalogScreen({super.key});

  @override
  ConsumerState<PhrasalVerbsCatalogScreen> createState() => _PhrasalVerbsCatalogScreenState();
}

class _PhrasalVerbsCatalogScreenState extends ConsumerState<PhrasalVerbsCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Color _accentColor = TabTheme.phrasalVerbs.accent; // Amarillo Dorado / Gold

  String? _currentlyPlayingVerbId;
  String? _recordingVerbId;
  String? _evaluatingVerbId;
  final Set<String> _expandedVerbIds = {};
  final Map<String, double> _recentVerbScores = {};
  final Map<String, String> _recentFeedback = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _playPhrasalAudio(PhrasalVerb verb, {bool slow = false}) async {
    setState(() {
      _currentlyPlayingVerbId = verb.id;
    });

    final player = ref.read(audioPlayerProvider);
    await player.playTts(verb.fullPhrase, slow: slow);

    if (mounted) {
      setState(() {
        if (_currentlyPlayingVerbId == verb.id) {
          _currentlyPlayingVerbId = null;
        }
      });
    }
  }

  Future<void> _toggleRecordVerb(PhrasalVerb verb) async {
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
        // Evaluación centralizada: en vivo, o cola offline + aviso (antes fallaba
        // en silencio).
        final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
          section: 'phrasal_verbs',
          audioPath: path,
          expectedTerm: verb.fullPhrase,
          expectedIpa: verb.ipa,
          userId: ref.read(activeUserIdProvider),
          exerciseType: 'phrasal_verbs_catalog',
          category: 'phrasal_verbs',
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
          ref.read(phrasalVerbsLabNotifierProvider.notifier).recordAttempt(
                verbId: verb.id,
                exerciseType: 'pronunciation',
                isSuccess: res.score >= 65,
                pronunciationScore: res.score.toDouble(),
                expectedForm: verb.fullPhrase,
                actualForm: res.recognized_text.isNotEmpty
                    ? res.recognized_text
                    : verb.fullPhrase,
                contextSentence: verb.dailySyncExample,
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

  List<String> _generateWorkplaceScenariosForPhrasalVerb(PhrasalVerb verb) {
    final p = verb.fullPhrase;
    return [
      'Let us $p before pushing the latest commit to production.',
      'We need to $p with the platform team regarding the Kubernetes ingress.',
      'During yesterday\'s retro, the team agreed to $p to reduce technical debt.',
      'Can you $p with the backend lead about the database migration latency?',
      'The staff engineer suggested we $p to avoid distributed lock deadlocks.',
      'Our team will $p during the morning standup to unblock the PR review.',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = ref.watch(filteredPhrasalVerbsProvider);
    // Prefetch premium: pre-genera el audio neural del NAS de lo visible.
    ref.read(audioPrefetchProvider).warm(
      filteredList.map((v) => v.fullPhrase),
    );
    final state = ref.watch(phrasalVerbsLabNotifierProvider);

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
              'Catálogo de Phrasal Verbs',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Situaciones reales, connected speech y separabilidad',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _accentColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => ref.read(phrasalVerbsLabNotifierProvider.notifier).setSearchQuery(q),
                style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Buscar por phrasal verb, español o término...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(phrasalVerbsLabNotifierProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: TabTheme.surfaceContainerLowest,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: TabTheme.surfaceContainerHigh),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: TabTheme.surfaceContainerHigh),
                  ),
                ),
              ),
            ),

            // 1.5 CEFR Level Filter Row
            _buildCefrFilterRow(state.activeCefrRoute),

            // 2. Particle Filter Chips (Secondary Map)
            _buildParticleFilterRow(state.selectedParticle),

            // 3. Status Filter Chips (All / Mastered / Favorites / Mistakes)
            _buildStatusFilterRow(state.statusFilter),

            const SizedBox(height: 8),

            // 4. List of Phrasal Verbs
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        'No se encontraron phrasal verbs con los filtros actuales.',
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final verb = filteredList[index];
                        final metrics = state.metricsByVerb[verb.id];
                        final isFav = state.favoriteIds.contains(verb.id);
                        final isExpanded = _expandedVerbIds.contains(verb.id);
                        final isPlaying = _currentlyPlayingVerbId == verb.id;
                        final isRecording = _recordingVerbId == verb.id;
                        final isEvaluating = _evaluatingVerbId == verb.id;
                        final recentScore = _recentVerbScores[verb.id];

                        return _buildPhrasalVerbCard(
                          verb: verb,
                          metrics: metrics,
                          isFav: isFav,
                          isExpanded: isExpanded,
                          isPlaying: isPlaying,
                          isRecording: isRecording,
                          isEvaluating: isEvaluating,
                          recentScore: recentScore,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCefrFilterRow(String activeRoute) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: TabTheme.cefrRail.map((lvl) {
          final isSelected = activeRoute.toLowerCase() == lvl['id']!.toLowerCase() ||
              (activeRoute == 'C1+' && lvl['id'] == 'C1');
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: TabTheme.filterLevelPill(
              id: lvl['id']!,
              label: lvl['es']!,
              isSelected: isSelected,
              onTap: () {
                AppHaptics.light();
                final target = lvl['id'] == 'C1' ? 'C1+' : lvl['id']!;
                if (activeRoute == target) {
                  ref.read(phrasalVerbsLabNotifierProvider.notifier).setActiveCefrRoute('all');
                } else {
                  ref.read(phrasalVerbsLabNotifierProvider.notifier).setActiveCefrRoute(target);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildParticleFilterRow(String selectedParticle) {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildParticleChip(
            label: 'TODAS',
            isSelected: selectedParticle == 'all',
            onTap: () {
              AppHaptics.light();
              ref.read(phrasalVerbsLabNotifierProvider.notifier).setSelectedParticle('all');
            },
          ),
          ...PhrasalParticle.values.map(
            (p) => _buildParticleChip(
              label: p.label,
              isSelected: selectedParticle == p.id,
              onTap: () {
                AppHaptics.light();
                ref.read(phrasalVerbsLabNotifierProvider.notifier).setSelectedParticle(p.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? _accentColor : TabTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? _accentColor : TabTheme.surfaceContainerHigh,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterRow(String statusFilter) {
    final filters = [
      {'key': 'all', 'label': 'Todos'},
      {'key': 'mastered', 'label': 'Consolidados'},
      {'key': 'inProgress', 'label': 'En progreso'},
      {'key': 'favorites', 'label': 'Favoritos'},
      {'key': 'mistakes', 'label': 'Errores FSRS'},
    ];

    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          final isSelected = statusFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                AppHaptics.light();
                ref.read(phrasalVerbsLabNotifierProvider.notifier).setStatusFilter(f['key'] as String);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? _accentColor.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? _accentColor : TabTheme.surfaceContainerHigh,
                  ),
                ),
                child: Text(
                  f['label'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? _accentColor : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhrasalVerbCard({
    required PhrasalVerb verb,
    required PhrasalVerbMetrics? metrics,
    required bool isFav,
    required bool isExpanded,
    required bool isPlaying,
    required bool isRecording,
    required bool isEvaluating,
    double? recentScore,
  }) {
    final isMastered = metrics?.isMastered ?? false;
    final isInterviewReady = metrics?.isInterviewReady ?? false;
    final displayScore = recentScore ?? (metrics?.pronunciationAvgScore != null && metrics!.pronunciationAvgScore > 0 ? metrics.pronunciationAvgScore : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isInterviewReady
              ? _accentColor.withValues(alpha: 0.6)
              : (isMastered ? const Color(0xFF10B981).withValues(alpha: 0.5) : TabTheme.surfaceContainerHigh),
          width: (isMastered || isInterviewReady) ? 1.5 : 1.0,
        ),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isMastered
                ? const Color(0xFFECFDF5)
                : TabTheme.surfaceContainerLow.withValues(alpha: 0.5),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    children: [
                      Text(
                        verb.fullPhrase,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          verb.particle.label,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: _accentColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: TabTheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          verb.cefrLevel,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        ),
                      ),
                      if (isInterviewReady)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'STAR Ready',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: _accentColor),
                          ),
                        )
                      else if (isMastered)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            'Consolidado',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFav ? const Color(0xFFF59E0B) : AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    AppHaptics.light();
                    ref.read(phrasalVerbsLabNotifierProvider.notifier).toggleFavorite(verb.id);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Spanish & Connected Speech
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Row(
              children: [
                Text(
                  verb.spanish,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: _accentColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${verb.connectedSpeechChunk}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Direct Inline Actions: Hear model + Slow + Record & GOP + Info Toggle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                // Hear Model
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: (isPlaying || isRecording || isEvaluating)
                        ? null
                        : () {
                            AppHaptics.light();
                            _playPhrasalAudio(verb, slow: false);
                          },
                    icon: isPlaying
                        ? SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor),
                          )
                        : const Icon(Icons.volume_up_rounded, size: 16),
                    label: Text(
                      isPlaying ? 'Audio...' : 'Hear model',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accentColor,
                      side: BorderSide(color: _accentColor.withValues(alpha: 0.3)),
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
                            _playPhrasalAudio(verb, slow: true);
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
                              : _accentColor,
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
                    color: isExpanded ? _accentColor : AppTheme.textSecondary,
                  ),
                  tooltip: isExpanded ? 'Ocultar detalles' : 'Ver escenario, ejemplos y registro',
                  style: IconButton.styleFrom(
                    backgroundColor: isExpanded ? _accentColor.withValues(alpha: 0.12) : TabTheme.surfaceContainerHigh,
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

          // Expanded Accordion
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Escenario: ',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                      Expanded(
                        child: Text('${verb.scenario.title} · ${verb.idiomaticMeaning}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('Patrón: ',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: _accentColor)),
                      Expanded(
                        child: Text(verb.correctPattern,
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _accentColor)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: verb.isSeparable ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          verb.isSeparable ? 'Separable' : 'Inseparable',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: verb.isSeparable ? const Color(0xFF065F46) : _accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (verb.formalAlternatives.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registro formal: ',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                        Expanded(
                          child: Text(
                            verb.formalAlternatives.map((a) => '${a.term} (${a.whenToUse})').join(' | '),
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: const Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (verb.usageTip.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Tip: ${verb.usageTip}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _accentColor)),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Práctica Contextual Unificada (Estilo Gramática con cambio de frase dinámico |>)
                  ContextualPronunciationPracticeSheet(
                    key: ValueKey('phrasal_inline_${verb.id}'),
                    isInline: true,
                    title: verb.fullPhrase,
                    category: 'phrasal_verbs',
                    accentColor: _accentColor,
                    expectedTerm: verb.fullPhrase,
                    expectedIpa: verb.ipa,
                    phrases: [
                      PronunciationPhraseItem(
                        label: 'Daily Sync',
                        phrase: verb.dailySyncExample,
                        phonetic: verb.connectedSpeechChunk,
                        translation: verb.spanish,
                      ),
                      PronunciationPhraseItem(
                        label: 'Workplace / Incidencia',
                        phrase: verb.workplaceExample,
                        phonetic: verb.connectedSpeechChunk,
                        translation: verb.spanish,
                      ),
                      ..._generateWorkplaceScenariosForPhrasalVerb(verb).map(
                        (scen) => PronunciationPhraseItem(
                          label: 'Escenario Laboral',
                          phrase: scen,
                          phonetic: verb.connectedSpeechChunk,
                          translation: verb.spanish,
                        ),
                      ),
                    ],
                    onAttemptRecorded: (score, phrase) {
                      if (score < 0) return; // offline: no cuenta como intento
                      ref.read(phrasalVerbsLabNotifierProvider.notifier).recordAttempt(
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
}

