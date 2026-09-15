import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/api_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/pedagogy/adaptive_recommendation_provider.dart';

/// Mazo de Repaso (FSRS) — panel/dashboard con estadísticas, precisión,
/// mejora diaria y recomendación del Coach IA, y el flujo de repaso con
/// tarjeta y calificación FSRS. Local-first, sin cuelgues.
class DeckScreen extends ConsumerStatefulWidget {
  final String? initialFilter;
  final bool autoStart;
  const DeckScreen({super.key, this.initialFilter, this.autoStart = false});

  @override
  ConsumerState<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends ConsumerState<DeckScreen> {
  List<CardOut> _all = [];
  String _filter = 'all';
  String _selectedTrack = 'tech';
  int _index = 0;
  bool _flipped = false;
  bool _showFrontEs = false;
  bool _loading = true;
  bool _reviewing = false;

  // Estadísticas
  int _totalReviews = 0;
  int _reviewedToday = 0;
  int? _accuracy; // %
  final Map<String, int> _againByOrigin = {};

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter ?? 'all';
    _reviewing = widget.autoStart;
    _init();
  }

  Future<void> _init() async {
    await _loadLocal();
    _refresh();
  }

  List<CardOut> get _due =>
      _all.where((c) => !c.due_date.isAfter(DateTime.now())).toList();

  List<CardOut> get _cards {
    final base = _due.isNotEmpty ? _due : _all;
    if (_filter == 'all') return base;
    return base.where((c) {
      final o = c.effectiveOrigin;
      if (_filter == 'interview') return o == 'interview' || o == 'speaking';
      return o == _filter;
    }).toList();
  }

  Future<void> _loadLocal() async {
    final db = ref.read(appDatabaseProvider);
    List<CardOut> loaded = [];
    try {
      final rows = await db.select(db.cardsLocal).get();
      loaded = rows.map(_fromLocal).toList();
    } catch (_) {}
    _sortDueFirst(loaded);
    await _loadStats(loaded);
    if (!mounted) return;
    setState(() {
      _all = loaded;
      _loading = false;
      _index = 0;
      _flipped = false;
      _showFrontEs = false;
    });
  }

  Future<void> _loadStats(List<CardOut> cards) async {
    final db = ref.read(appDatabaseProvider);
    try {
      final logs = await db.select(db.reviewLogsLocal).get();
      final now = DateTime.now();
      final byId = {for (final c in cards) c.id: c.effectiveOrigin};
      int good = 0, today = 0;
      _againByOrigin.clear();
      for (final l in logs) {
        if (l.rating >= 3) good++;
        if (l.review.year == now.year &&
            l.review.month == now.month &&
            l.review.day == now.day) {
          today++;
        }
        if (l.rating == 1) {
          final o = byId[l.cardId] ?? 'vocabulary';
          _againByOrigin[o] = (_againByOrigin[o] ?? 0) + 1;
        }
      }
      _totalReviews = logs.length;
      _reviewedToday = today;
      _accuracy = logs.isEmpty ? null : (good / logs.length * 100).round();
    } catch (_) {}
  }

  Future<void> _refresh() async {
    final api = ref.read(apiClientProvider);
    final db = ref.read(appDatabaseProvider);
    try {
      final remote = await api.getCards(dueOnly: false);
      for (final card in remote) {
        try {
          await db.into(db.cardsLocal).insertOnConflictUpdate(
                CardsLocalCompanion.insert(
                  id: drift.Value(card.id),
                  mistakeId: drift.Value(card.mistake_id),
                  front: card.front,
                  back: card.back,
                  stability: card.stability,
                  difficulty: card.difficulty,
                  elapsedDays: 0,
                  scheduledDays: 1,
                  reps: card.reps,
                  lapses: card.lapses,
                  state: card.state,
                  lastReview: drift.Value(card.last_review),
                  dueDate: card.due_date,
                  updatedAt: DateTime.now(),
                  sourceType: drift.Value(card.sourceType ?? 'interview_mistake'),
                  itemType: drift.Value(card.itemType ?? 'sentence_correction'),
                  unitOrPackId: drift.Value(card.unitOrPackId),
                  skill: drift.Value(card.skill ?? 'speaking'),
                ),
              );
        } catch (_) {}
      }
      await _loadLocal();
    } catch (_) {}
  }

  CardOut _fromLocal(CardsLocalData c) => CardOut(
        id: c.id,
        mistake_id: c.mistakeId,
        front: c.front,
        back: c.back,
        state: c.state,
        difficulty: c.difficulty,
        stability: c.stability,
        due_date: c.dueDate,
        last_review: c.lastReview,
        reps: c.reps,
        lapses: c.lapses,
        sourceType: c.sourceType,
        itemType: c.itemType,
        unitOrPackId: c.unitOrPackId,
        skill: c.skill,
      );

  void _sortDueFirst(List<CardOut> list) {
    final now = DateTime.now();
    list.sort((a, b) {
      final aDue = !a.due_date.isAfter(now);
      final bDue = !b.due_date.isAfter(now);
      if (aDue && !bDue) return -1;
      if (!aDue && bDue) return 1;
      final d = b.due_date.compareTo(a.due_date);
      if (d != 0) return d;
      return a.stability.compareTo(b.stability);
    });
  }

  Future<void> _rate(int rating) async {
    HapticFeedback.mediumImpact();
    final list = _cards;
    if (list.isEmpty || _index >= list.length) return;
    final card = list[_index];
    final api = ref.read(apiClientProvider);
    final db = ref.read(appDatabaseProvider);
    final milestones = ref.read(milestoneServiceProvider);

    try {
      final updated = await api.reviewCard(card.id, rating);
      final scheduled = updated.due_date.difference(DateTime.now()).inDays;
      await db.into(db.reviewLogsLocal).insert(ReviewLogsLocalCompanion.insert(
            cardId: card.id,
            rating: rating,
            state: updated.state,
            due: updated.due_date,
            stability: updated.stability,
            difficulty: updated.difficulty,
            elapsedDays: 0,
            lastElapsedDays: 0,
            scheduledDays: scheduled > 0 ? scheduled : 1,
            review: DateTime.now(),
            isSynced: const drift.Value(true),
          ));
    } catch (_) {
      await db.into(db.reviewLogsLocal).insert(ReviewLogsLocalCompanion.insert(
            cardId: card.id,
            rating: rating,
            state: card.state,
            due: card.due_date.add(Duration(days: rating == 1 ? 1 : 3)),
            stability: card.stability,
            difficulty: card.difficulty,
            elapsedDays: 0,
            lastElapsedDays: 0,
            scheduledDays: rating == 1 ? 1 : 3,
            review: DateTime.now(),
            isSynced: const drift.Value(false),
          ));
    }

    try {
      final msStreak = await ref
          .read(profileRepositoryProvider)
          .currentStreakDays(ref.read(activeUserIdProvider));
      await milestones.reconcileFromLocal(streakDays: msStreak);

      if (_index + 1 >= _cards.length) {
        final userId = ref.read(activeUserIdProvider);
        final repo = ref.read(profileRepositoryProvider);
        await repo.logLearningActivity(
          userId: userId,
          xp: _cards.length * 5 + 10,
          minutes: (_cards.length * 0.5).ceil().clamp(1, 30),
          sessions: 1,
          words: _cards.length,
        );

        await ref.read(journalServiceProvider).recordActivityJournal(
          title: 'Repaso Espaciado FSRS (${_cards.length} conceptos)',
          category: 'Repaso FSRS',
          date: DateTime.now(),
          durationSeconds: _cards.length * 30,
          overallScore: 95.0,
          questionsCount: _cards.length,
          additionalNotes: 'Se han consolidado ${_cards.length} conceptos clave en memoria a largo plazo.',
        );

        ref.invalidate(profileSummaryProvider);
        ref.invalidate(activeProfileProvider);
        ref.invalidate(dueCardsCountProvider);
        ref.invalidate(adaptiveRecommendationProvider);
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _flipped = false;
      _showFrontEs = false;
      _index++;
    });
  }

  Color _originColor(String o) {
    switch (o) {
      case 'grammar':
        return TabTheme.grammar.accent;
      case 'interview':
      case 'speaking':
        return TabTheme.speaking.accent;
      case 'listening':
        return AppTheme.primary;
      default:
        return TabTheme.vocabulary.accent;
    }
  }

  String _originLabel(String o) {
    switch (o) {
      case 'grammar':
        return 'Gramática';
      case 'interview':
      case 'speaking':
        return 'Entrevista';
      case 'listening':
        return 'Listening';
      default:
        return 'Vocabulario';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TabTheme.background,
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(color: TabTheme.fsrs.accent))
            : (_reviewing ? _reviewFlow() : _dashboard()),
      ),
    );
  }

  // ===================== DASHBOARD (STITCH SPEC) =====================
  Widget _dashboard() {
    final due = _due.length;
    final totalCards = _all.length;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    // AI Coach recommendation based on weakest origin
    String recoText;
    Color recoColor = TabTheme.fsrs.accent;
    if (_totalReviews == 0) {
      recoText = isEn
          ? 'No review data yet. Practice in Vocabulary, Grammar, or Interview and your mistakes will automatically generate smart cards here.'
          : 'Aún no tienes datos de repaso. Practica en cualquier módulo y tus fallos crearán tarjetas inteligentes aquí.';
    } else if (_againByOrigin.isEmpty) {
      recoText = isEn
          ? 'Outstanding stability! No significant weak spots detected. Keep up your daily review streak to solidify retention.'
          : '¡Excelente estabilidad! No hay un punto débil claro. Mantén la constancia diaria para fijar la retención.';
      recoColor = AppTheme.success;
    } else {
      final weak = _againByOrigin.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      recoColor = _originColor(weak);
      recoText = isEn
          ? 'Priority focus area: ${_originLabel(weak)}. You had ${_againByOrigin[weak]} lapses. Strengthen this track today.'
          : 'Tu punto débil es ${_originLabel(weak)}: fallaste ${_againByOrigin[weak]} veces. Refuerza ese módulo hoy.';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        // 1. Clean Top Header Block (with Back Button)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 4),
              child: InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: TabTheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(color: TabTheme.surfaceContainerHigh),
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: TabTheme.onSurface, size: 20),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEn ? 'FSRS Memory Deck' : 'Mazo de Repaso FSRS',
                    style: TabTheme.displayMd(fw: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEn
                        ? 'Adaptive spaced repetition to maximize long-term memory for technical lexicon and STAR syntax.'
                        : 'Algoritmo adaptativo para optimizar la retención a largo plazo de vocabulario técnico y gramática STAR.',
                    style: TabTheme.bodyMd(),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Track Segmented Switcher (General English vs Tech / IT Executive)
        _buildTrackSwitcher(isEn),

        const SizedBox(height: 14),

        // 2. Filter Rail (All, Vocab, Grammar, Speaking)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('all', isEn ? 'All Cards' : 'Todas', Icons.dashboard_outlined, totalCards),
              const SizedBox(width: 8),
              _filterChip('vocabulary', isEn ? 'Tech Vocab' : 'Vocabulario', Icons.auto_stories_outlined,
                  _all.where((c) => c.effectiveOrigin == 'vocabulary').length),
              const SizedBox(width: 8),
              _filterChip('grammar', isEn ? 'STAR Grammar' : 'Gramática', Icons.spellcheck_rounded,
                  _all.where((c) => c.effectiveOrigin == 'grammar').length),
              const SizedBox(width: 8),
              _filterChip('interview', isEn ? 'Interviews' : 'Entrevistas', Icons.mic_rounded,
                  _all.where((c) => c.effectiveOrigin == 'interview' || c.effectiveOrigin == 'speaking').length),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 3. Hero Retention Matrix Card
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: TabTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TabTheme.surfaceContainerHigh),
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
                        TabTheme.fsrs.accent.withValues(alpha: AppTheme.isLight ? 0.14 : 0.08),
                        TabTheme.fsrs.accent.withValues(alpha: 0.0),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: TabTheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isEn ? 'ACTIVE MEMORY STATUS' : 'ESTADO DE MEMORIA ACTIVA',
                            style: TabTheme.labelSm(
                              color: TabTheme.fsrs.accent,
                              fw: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.layers_rounded,
                          color: TabTheme.fsrs.accent,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      due > 0
                          ? (isEn ? '$due Flashcards Ready for Review' : '$due Tarjetas Listas para Repaso')
                          : (isEn ? 'Memory Schedule Up to Date' : '¡Mazo al día! Sin repasos pendientes'),
                      style: TabTheme.headlineSm(fw: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      due > 0
                          ? (isEn
                              ? 'Reviewing now boosts memory consolidation by 3.2x before the forgetting curve triggers.'
                              : 'Repasar ahora multiplica por 3.2x la consolidación antes de que la curva del olvido actúe.')
                          : (isEn
                              ? 'Great job! Your memory stability is protected across all active learning tracks.'
                              : '¡Buen trabajo! La estabilidad de tus términos y reglas gramaticales está consolidada.'),
                      style: TabTheme.bodyMd(color: TabTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          due > 0
                              ? (isEn ? '• $due cards pending' : '• $due tarjetas pendientes')
                              : (isEn ? '• 0 cards pending' : '• 0 tarjetas pendientes'),
                          style: TabTheme.labelSm(
                            color: TabTheme.fsrs.accent,
                            fw: FontWeight.w700,
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
                              color: TabTheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${(due * 0.5).ceil().clamp(1, 60)} min',
                              style: TabTheme.labelSm(
                                color: TabTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: due == 0
                            ? (_cards.isEmpty
                                ? null
                                : () => setState(() {
                                      _reviewing = true;
                                      _index = 0;
                                      _flipped = false;
                                    }))
                            : () => setState(() {
                                  _reviewing = true;
                                  _index = 0;
                                  _flipped = false;
                                }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TabTheme.fsrs.accent,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              due == 0 ? Icons.replay_rounded : Icons.play_arrow_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              due == 0
                                  ? (isEn ? 'Practice Deck Again' : 'Repasar Mazo de Nuevo')
                                  : (isEn ? 'Start FSRS Review ($due)' : 'Empezar Repaso FSRS ($due)'),
                              style: TabTheme.titleSm(
                                color: Colors.white,
                                fw: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. Bento Grid de Telemetría (4 KPIs Clave)
        _sectionTitle(isEn ? 'Memory Telemetry & Metrics' : 'Telemetría y Métricas FSRS'),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              value: '$due',
              label: isEn ? 'Due Today' : 'Pendientes',
              icon: Icons.schedule_rounded,
              color: TabTheme.fsrs.accent,
            ),
            const SizedBox(width: 12),
            _statCard(
              value: '$_reviewedToday',
              label: isEn ? 'Reviewed Today' : 'Repasadas Hoy',
              icon: Icons.today_rounded,
              color: TabTheme.speaking.accent,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard(
              value: _accuracy == null ? '—' : '$_accuracy%',
              label: isEn ? 'Recall Accuracy' : 'Tasa de Aciertos',
              icon: Icons.track_changes_rounded,
              color: AppTheme.success,
            ),
            const SizedBox(width: 12),
            _statCard(
              value: '$_totalReviews',
              label: isEn ? 'Total Reviews' : 'Total Repasos',
              icon: Icons.style_rounded,
              color: TabTheme.grammar.accent,
            ),
          ],
        ),

        const SizedBox(height: 22),

        // 5. Coach IA · Diagnóstico Cognitivo
        _sectionTitle(isEn ? 'AI Retention Coach' : 'Coach IA · Diagnóstico Cognitivo'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TabTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TabTheme.surfaceContainerHigh),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: recoColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: recoColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recoText,
                  style: TabTheme.bodyMd(color: TabTheme.onSurface),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        // 6. Accuracy Progress Bar
        _sectionTitle(isEn ? 'Retention Quality Score' : 'Calidad de Retención y Respuestas'),
        const SizedBox(height: 10),
        _accuracyBar(),
      ],
    );
  }

  Widget _filterChip(String id, String label, IconData icon, int count) {
    final isSelected = _filter == id;
    return InkWell(
      onTap: () => setState(() => _filter = id),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? TabTheme.fsrs.accent : TabTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? TabTheme.fsrs.accent : TabTheme.surfaceContainerHigh,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : TabTheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TabTheme.labelSm(
                color: isSelected ? Colors.white : TabTheme.onSurfaceVariant,
                fw: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackSwitcher(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTrack = 'general'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTrack == 'general'
                      ? TabTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _selectedTrack == 'general'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 17,
                      color: _selectedTrack == 'general'
                          ? TabTheme.fsrs.accent
                          : TabTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'General English' : 'Inglés General',
                      style: TabTheme.labelMd(
                        color: _selectedTrack == 'general'
                            ? TabTheme.onSurface
                            : TabTheme.onSurfaceVariant,
                        fw: _selectedTrack == 'general'
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
              onTap: () => setState(() => _selectedTrack = 'tech'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTrack == 'tech'
                      ? TabTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _selectedTrack == 'tech'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      size: 17,
                      color: _selectedTrack == 'tech'
                          ? TabTheme.fsrs.accent
                          : TabTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'Tech / IT Executive' : 'Tech / IT Executive',
                      style: TabTheme.labelMd(
                        color: _selectedTrack == 'tech'
                            ? TabTheme.onSurface
                            : TabTheme.onSurfaceVariant,
                        fw: _selectedTrack == 'tech'
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

  Widget _statCard({required String value, required String label, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TabTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TabTheme.surfaceContainerHigh),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value, style: TabTheme.displayMd(color: TabTheme.onSurface, fw: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: TabTheme.labelMd(color: TabTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _accuracyBar() {
    final acc = (_accuracy ?? 0) / 100.0;
    final color = acc >= 0.8
        ? AppTheme.success
        : (acc >= 0.5 ? AppTheme.warning : AppTheme.error);
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _accuracy == null
                    ? (isEn ? 'No review history yet' : 'Sin datos de repaso aún')
                    : (isEn ? 'Retention Precision (Good/Easy)' : 'Aciertos FSRS (Bien / Fácil)'),
                style: TabTheme.titleSm(color: TabTheme.onSurface),
              ),
              const Spacer(),
              Text(
                _accuracy == null ? '—' : '$_accuracy%',
                style: TabTheme.titleSm(color: color, fw: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _accuracy == null ? 0.02 : acc.clamp(0.02, 1.0),
              minHeight: 8,
              backgroundColor: TabTheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
        t,
        style: TabTheme.titleMd(fw: FontWeight.w700, color: TabTheme.onSurface),
      );

  Widget _reviewFlow() {
    final list = _cards;
    if (list.isEmpty || _index >= list.length) return _doneState(list.length);
    final card = list[_index];
    final origin = card.effectiveOrigin;
    final accentColor = _originColor(origin);
    final progress = ((_index) / list.length).clamp(0.0, 1.0);
    final doneWidth = progress > 0 ? progress : 0.02;

    return Column(
      children: [
        // ── Sub-header (same pattern as other hubs — no AppBar) ──────────
        Container(
          color: TabTheme.background,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => setState(() => _reviewing = false),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: TabTheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, color: TabTheme.onSurface, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('FSRS v5 Engine',
                                style: TabTheme.labelSm(color: TabTheme.fsrs.accent, fw: FontWeight.w800)),
                            const SizedBox(width: 6),
                            Container(width: 5, height: 5,
                                decoration: BoxDecoration(color: TabTheme.fsrs.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(_originLabel(origin),
                                style: TabTheme.labelSm(color: TabTheme.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Tarjeta ${_index + 1} de ${list.length}',
                            style: TabTheme.titleSm(color: TabTheme.onSurface)),
                      ],
                    ),
                  ),
                  // Origin badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.layers_rounded, size: 14, color: accentColor),
                        const SizedBox(width: 4),
                        Text(_originLabel(origin).toUpperCase(),
                            style: TabTheme.labelSm(color: accentColor, fw: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Segmented progress pipeline
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: doneWidth,
                  minHeight: 6,
                  backgroundColor: TabTheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(TabTheme.fsrs.accent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // ── Scrollable card body ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardContent(card, origin, accentColor),
                const SizedBox(height: 14),
                if (_flipped) _buildRatingPanel(card)
                else _buildRevealButton(origin, accentColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Old _buildReviewHeader removed – inlined in _reviewFlow above

  Widget _buildCardContent(CardOut card, String origin, Color accentColor) {
    // Derive a CEFR band label from skill/unitOrPackId for the category chip
    final categoryLabel = _deriveCategoryLabel(card);
    final stabPct = (card.stability / (card.stability + 14) * 100).round().clamp(0, 100);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top pill controls row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Audio pill
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(audioPlayerProvider).playTts(card.front);
                  },
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up_rounded, size: 16, color: accentColor),
                        const SizedBox(width: 5),
                        Text('Escuchar', style: TabTheme.labelSm(color: accentColor, fw: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Traducir (ES) pill
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _showFrontEs = !_showFrontEs);
                  },
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _showFrontEs ? accentColor.withValues(alpha: 0.20) : TabTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: accentColor.withValues(alpha: _showFrontEs ? 0.60 : 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.translate_rounded, size: 14, color: accentColor),
                        const SizedBox(width: 5),
                        Text(
                          _showFrontEs ? 'Ocultar ES' : 'Traducir al español',
                          style: TabTheme.labelSm(color: accentColor, fw: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Category label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TabTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    categoryLabel.toUpperCase(),
                    style: TabTheme.labelSm(
                      color: TabTheme.onSurfaceVariant.withValues(alpha: 0.8),
                      fw: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.bookmark_border_rounded, color: TabTheme.outline, size: 20),
              ],
            ),
          ),
          // ── Front term ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              card.front,
              style: TabTheme.displayMd(fw: FontWeight.w700, color: TabTheme.onSurface),
            ),
          ),
          // ── Spanish Translation Box (on demand) ────────────────────────
          if (_showFrontEs)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.translate_rounded, size: 16, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRADUCCIÓN & CONTEXTO (ES)',
                              style: TabTheme.labelSm(color: accentColor, fw: FontWeight.w800).copyWith(fontSize: 10)),
                          const SizedBox(height: 4),
                          Text(
                            _getSpanishTranslation(card),
                            style: TabTheme.bodyMd(color: TabTheme.onSurface, fw: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Stability indicator ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Text(
              'Estabilidad: $stabPct% · Repasos: ${card.reps} · Fallos: ${card.lapses}',
              style: TabTheme.bodyMd(color: TabTheme.onSurfaceVariant),
            ),
          ),
          // ── Speech drill pill ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TabTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic_rounded, color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Probar en voz alta', style: TabTheme.titleSm(color: TabTheme.onSurface)),
                        Text('Lee la tarjeta antes de voltearla', style: TabTheme.labelSm(color: TabTheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: TabTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text('Grabar', style: TabTheme.labelMd(color: TabTheme.onSurface)),
                  ),
                ],
              ),
            ),
          ),
          // ── Back / answer section (shown only when _flipped) ──────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _flipped ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Divider
                  Divider(color: TabTheme.outlineVariant.withValues(alpha: 0.4), height: 20),
                  // Translation / answer block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TabTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 4, height: 4, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(
                              (origin == 'interview' || origin == 'speaking')
                                  ? 'EQUIVALENTE EJECUTIVO'
                                  : 'RESPUESTA & EXPLICACIÓN',
                              style: TabTheme.labelSm(color: accentColor, fw: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(card.back,
                            style: TabTheme.titleMd(color: TabTheme.onSurface, fw: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (origin == 'interview' || origin == 'speaking') ...[
                    const SizedBox(height: 10),
                    // STAR tip
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: TabTheme.fsrs.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.psychology_rounded, color: TabTheme.fsrs.accent, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mnemotecnia STAR', style: TabTheme.labelSm(color: TabTheme.onSurface, fw: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  'Al usar este elemento en entrevistas, contextualízalo con la fórmula STAR: Situación → Tarea → Acción → Resultado.',
                                  style: TabTheme.bodyMd(color: TabTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSpanishTranslation(CardOut card) {
    final back = card.back.trim();
    if (back.isNotEmpty) {
      if (back.contains('Explicación:')) {
        final parts = back.split('Explicación:');
        if (parts.length > 1 && parts[1].trim().isNotEmpty) {
          return parts[1].trim();
        }
      }
      return back;
    }
    return 'Contexto y traducción disponibles al revelar la tarjeta.';
  }

  String _deriveCategoryLabel(CardOut card) {
    final pack = card.unitOrPackId ?? '';
    final skill = card.skill ?? '';
    if (pack.isNotEmpty) return pack.replaceAll('-', ' ').replaceAll('_', ' ');
    if (skill.isNotEmpty) return skill;
    return _originLabel(card.effectiveOrigin);
  }

  Widget _buildRevealButton(String origin, Color accentColor) {
    final isInterview = origin == 'interview' || origin == 'speaking';
    final label = isInterview
        ? 'Ver Traducción y Mnemotecnia STAR'
        : 'Ver Respuesta y Explicación';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          setState(() => _flipped = true);
        },
        icon: const Icon(Icons.visibility_rounded, color: Colors.white, size: 18),
        label: Text(
          label,
          style: TabTheme.labelLg(color: Colors.white, fw: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildRatingPanel(CardOut card) {
    // Estimate next-interval days per grade (simplified heuristic based on stability)
    String intervalLabel(int grade) {
      if (grade == 1) return '< 10 min';
      final s = card.stability;
      final days = grade == 2
          ? (s * 0.4).clamp(1.0, 3.0).toStringAsFixed(1)
          : grade == 3
              ? (s * 1.2).clamp(2.0, 14.0).toStringAsFixed(1)
              : (s * 2.5).clamp(4.0, 30.0).toStringAsFixed(1);
      return '$days d';
    }

    Widget gradeBtn(String label, int grade, Color bg, Color fg) {
      return Expanded(
        child: GestureDetector(
          onTap: () => _rate(grade),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(intervalLabel(grade),
                    style: TabTheme.labelSm(color: fg, fw: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(label, style: TabTheme.titleSm(color: fg, fw: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Grade $grade', style: TabTheme.labelSm(color: fg.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ),
      );
    }

    final stabPct = (card.stability / (card.stability + 14) * 100).round().clamp(0, 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calculate_outlined, size: 15, color: TabTheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text('CALIFICACIÓN DE RETENCIÓN FSRS',
                style: TabTheme.labelSm(color: TabTheme.onSurfaceVariant, fw: FontWeight.w700)),
            const Spacer(),
            Text('Estabilidad: $stabPct%',
                style: TabTheme.labelSm(color: TabTheme.fsrs.accent, fw: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            gradeBtn('Repetir', 1,
                AppTheme.error.withValues(alpha: 0.15), AppTheme.error),
            const SizedBox(width: 6),
            gradeBtn('Difícil', 2,
                TabTheme.speaking.accent.withValues(alpha: 0.15), TabTheme.speaking.accent),
            const SizedBox(width: 6),
            gradeBtn('Bien', 3,
                TabTheme.surfaceContainerHigh, TabTheme.onSurface),
            const SizedBox(width: 6),
            gradeBtn('Fácil', 4,
                TabTheme.fsrs.accent.withValues(alpha: 0.15), TabTheme.fsrs.accent),
          ],
        ),
      ],
    );
  }



  Widget _doneState(int total) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: TabTheme.fsrs.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration_rounded, size: 40, color: TabTheme.fsrs.accent),
            ),
            const SizedBox(height: 20),
            Text('¡Repaso completado!',
                style: TabTheme.headlineSm(color: TabTheme.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Buen trabajo. Vuelve mañana para consolidar la memoria a largo plazo.',
              textAlign: TextAlign.center,
              style: TabTheme.bodyMd(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _reviewing = false;
                    _loading = true;
                  });
                  _init();
                },
                icon: Icon(Icons.dashboard_rounded, color: TabTheme.fsrs.onAccent),
                label: Text('Ver mi panel',
                    style: TabTheme.labelLg(
                        color: TabTheme.fsrs.onAccent, fw: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TabTheme.fsrs.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




