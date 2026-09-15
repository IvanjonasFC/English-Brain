import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_providers.dart';
import '../../core/audio/audio_recorder_controller.dart';
import '../../core/services/measurement_service.dart';
import '../../core/widgets/pitch_contour_chart.dart';
import '../../core/models/api_models.dart';
import 'vocabulary_theme_tokens.dart';
import 'vocabulary_screen.dart';
import 'vocabulary_practice_summary_screen.dart';
import '../../core/pedagogy/practice_engine.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/pedagogy/practice_service.dart';
import 'vocabulary_repository.dart' as vrepo;
import '../../core/pedagogy/contracts.dart';
import '../phonetics/hvpt_exercise_screen.dart';
import '../../core/audio/voice_selection.dart';
import '../../core/theme/app_theme.dart';

/// A single functional multiple-choice exercise built from real pack data.
class _Ex {
  final VocabularyItem item;
  final List<String> options; // 4 candidate terms (shuffled)
  final int correctIndex;
  const _Ex({
    required this.item,
    required this.options,
    required this.correctIndex,
  });
}

class VocabularyPracticeScreen extends ConsumerStatefulWidget {
  final String packId;
  const VocabularyPracticeScreen({super.key, required this.packId});

  @override
  ConsumerState<VocabularyPracticeScreen> createState() =>
      _VocabularyPracticeScreenState();
}

class _VocabularyPracticeScreenState
    extends ConsumerState<VocabularyPracticeScreen>
    with SingleTickerProviderStateMixin {
  // Session timer (counts up = real elapsed time).
  int _elapsedSeconds = 0;
  Timer? _sessionTimer;

  late List<_Ex> _exercises;
  int _currentStep = 0;

  // Answer state for the current exercise.
  int? _selectedOption; // null until the user answers
  bool _answered = false;
  int _correctCount = 0;
  // Términos fallados en la sesión -> se ingieren al mazo FSRS al terminar.
  final List<VocabularyItem> _missed = [];

  // Pronunciation drill state.
  int _phraseIdx = 0;
  bool _isPlayingModel = false;

  // Feedback shown in Spanish (true) or English (false); flippable per exercise.
  bool _fbSpanish = false;

  // Pronunciation evaluation state (wired to /api/pronunciation/check).
  String get _userId => ref.read(activeUserIdProvider);
  final Map<String, int> _pronScoresByTerm = {};
  final List<Map<String, dynamic>> _evaluatedTerms = [];
  bool _checking = false;
  bool _pronError = false;
  bool _isFinishing = false; // Guard contra doble click al terminar sesión
  PronunciationResult? _pronResult;
  String? _pitchAudioPath;
  String? _pitchText;
  String? _pronTip;
  StreamSubscription? _pronSub;

  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _buildExercises();
    unawaited(_loadFsrsReview());
    _startTimer();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pronSub = ref.read(pronunciationQueueProvider).onProcessed.listen((event) {
      if (mounted && event.section == 'vocabulary') {
        final res = event.result;
        if (res.score > 0) {
          setState(() {
            _pronScoresByTerm[event.term] = res.score;
            if (_ex.item.term == event.term || _currentPhrase == event.term) {
              _pronResult = res;
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pronSub?.cancel();
    _sessionTimer?.cancel();
    _waveformController.dispose();
    // Make sure we never leave the mic or audio player open when leaving the screen.
    try {
      final rec = ref.read(audioRecorderProvider);
      if (rec.state == RecordingState.recording) {
        rec.stopRecording();
      }
    } catch (_) {}
    try {
      ref.read(audioPlayerProvider).stop();
    } catch (_) {}
    super.dispose();
  }

  void _buildExercises({List<VocabularyItem> spaced = const []}) {
    final pool = getVocabularyItemsForPack(widget.packId);
    ref.read(audioPrefetchProvider).warm(
      pool.expand((it) => [it.term, it.exampleSentence]),
      voice: AppVoices.vocabulary,
    );
    final rnd = Random(widget.packId.hashCode ^ 0x5f3759df);
    // Route selection through the adaptive PracticeEngine (interleaving +
    // CEFR band from the pack level) instead of a flat shuffle. FSRS-due
    // pools can be injected as recentReview/spacedReview here later.
    final objectiveId = 'vocab_${widget.packId}';
    final candidates = [
      for (final it in pool)
        CandidateItem(
          id: it.term,
          exerciseType: ExerciseType.recognition,
          contentType: ContentType.drill,
          objectiveId: objectiveId,
          band: DifficultyBandX.parse(it.level),
        ),
    ];
    final spacedCands = [
      for (final it in spaced)
        CandidateItem(
          id: it.term,
          exerciseType: ExerciseType.recognition,
          contentType: ContentType.review,
          objectiveId: 'vocab_review',
          band: DifficultyBandX.parse(it.level),
        ),
    ];
    const engine = PracticeEngine();
    final plan = engine.compose(PracticeRequest(
      userId: _userId,
      track: Track.vocabulary,
      minutes: 8,
      currentObjectiveId: objectiveId,
      phase: ObjectivePhase.learning,
      newItems: candidates,
      spacedReview: spacedCands,
      seed: widget.packId.hashCode ^ 0x5f3759df,
    ));
    final byTerm = {
      for (final it in pool) it.term: it,
      for (final it in spaced) it.term: it,
    };
    var chosen = plan.items
        .map((c) => byTerm[c.id])
        .whereType<VocabularyItem>()
        .toList();
    if (chosen.isEmpty) {
      chosen = (List<VocabularyItem>.from(pool)..shuffle(rnd))
          .take(min(10, pool.length))
          .toList();
    }

    _exercises = chosen.map((it) {
      final distractors = pool.where((o) => o.term != it.term).toList()
        ..shuffle(rnd);
      final opts = <String>[it.term];
      for (final d in distractors) {
        if (opts.length >= 4) break;
        if (!opts.contains(d.term)) opts.add(d.term);
      }
      opts.shuffle(rnd);
      return _Ex(item: it, options: opts, correctIndex: opts.indexOf(it.term));
    }).toList();

    if (_exercises.isEmpty) {
      // Extreme fallback so the screen never crashes on an empty pack.
      const fallback = VocabularyItem(
        term: 'bottleneck',
        phonetic: '/ˈbɒt.əl.nek/',
        partOfSpeech: 'Noun',
        category: 'System',
        level: 'B2',
        definition:
            'A point in a system where flow is restricted, reducing overall throughput.',
        spanishDefinition: 'Cuello de botella del sistema.',
        spanishNote: '',
        exampleSentence:
            'The database replica became our main bottleneck during peak traffic.',
      );
      _exercises = [
        const _Ex(
          item: fallback,
          options: ['bottleneck', 'throughput', 'latency', 'backoff'],
          correctIndex: 0,
        ),
      ];
    }
  }

  /// Best-effort: mezcla cartas FSRS vencidas de OTROS packs (repaso
  /// espaciado transversal) en la sesion. Silencioso si no hay ninguna o
  /// si offline; nunca interrumpe una sesion ya empezada.
  Future<void> _loadFsrsReview() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final rows = await db.select(db.cardsLocal).get();
      if (rows.isEmpty || !mounted) return;
      final now = DateTime.now();
      final all = <String, VocabularyItem>{};
      for (final pk in vrepo.VocabularyRepository.packs) {
        for (final it in getVocabularyItemsForPack(pk.id)) {
          all[it.term] = it;
        }
      }
      final due = <VocabularyItem>[];
      final seen = <String>{};
      for (final c in rows) {
        final isVocab = c.skill == 'vocabulary' || c.sourceType.contains('vocab');
        final crossPack = c.unitOrPackId != widget.packId;
        final dueNow = !c.dueDate.isAfter(now);
        if (isVocab && crossPack && dueNow) {
          final it = all[c.front];
          if (it != null && seen.add(it.term)) due.add(it);
        }
      }
      if (due.isEmpty || !mounted) return;
      if (_currentStep != 0 || _answered) return;
      setState(() => _buildExercises(spaced: due.take(6).toList()));
    } catch (_) {
      // Sin cartas / offline: la sesion pack-only es suficiente.
    }
  }

  void _startTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  String get _formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  _Ex get _ex => _exercises[_currentStep];
  int get _totalSteps => _exercises.length;

  /// Practice phrases for the pronunciation drill: the bare word first, then
  /// several useful, functional sentences using it.
  List<String> _phrasesFor(VocabularyItem it) {
    final t = it.term;
    final phrases = <String>[t];
    if (it.exampleSentence.trim().isNotEmpty) {
      phrases.add(it.exampleSentence.trim());
    }
    phrases.add('In my last project, I relied on $t to keep the system stable.');
    phrases.add('Could you explain $t to a junior engineer in one sentence?');
    phrases.add('During the interview, I described how $t improved performance.');
    return phrases;
  }

  String _clozeSentence(VocabularyItem it) {
    final s = it.exampleSentence;
    if (s.isEmpty) return '';
    final idx = s.toLowerCase().indexOf(it.term.toLowerCase());
    if (idx < 0) return s;
    return '${s.substring(0, idx)}______${s.substring(idx + it.term.length)}';
  }

  void _onAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      _phraseIdx = 0;
      // Default the correction to the app language; user can flip it.
      _fbSpanish = ref.read(localeProvider).languageCode != 'en';
      final wasCorrect = index == _ex.correctIndex;
      if (wasCorrect) {
        _correctCount++;
      } else {
        _missed.add(_ex.item);
      }

      final term = _ex.item.term;
      final sub = _ex.item.spanishDefinition.isNotEmpty ? _ex.item.spanishDefinition : _ex.item.definition;
      final score = wasCorrect ? 92 : 68;
      if (!_evaluatedTerms.any((t) => t['term'] == term)) {
        _evaluatedTerms.add({
          'term': term,
          'sub': sub,
          'percent': '$score%',
          'delta': wasCorrect ? '(+12%)' : '(+4%)',
          'badge': wasCorrect ? 'Dominado' : 'En Progreso',
          'isMastered': wasCorrect,
        });
      }
    });
  }

  /// Ingiere los términos fallados como cartas FSRS en el mazo transversal
  /// (offline-first), igual que hace gramática. Refs capturadas mientras
  /// el widget sigue montado; no bloquea la navegación al resumen.
  void _ingestMissed() {
    if (_missed.isEmpty) return;
    final userId = _userId;
    final service = ref.read(reviewIngestionProvider);
    final items = _missed
        .map((it) => ReviewItem(
              front: it.term,
              back: it.spanishDefinition.isNotEmpty
                  ? '${it.definition}\n\n${it.spanishDefinition}'
                  : it.definition,
              sourceType: ReviewSource.vocabulary,
              sourceRef: '${widget.packId}_${it.term.hashCode}',
              itemType: ReviewItemType.wordMeaning,
              unitOrPackId: widget.packId,
              skill: Track.vocabulary,
            ))
        .toList();
    unawaited(Future(() async {
      try {
        await service.ingest(userId, items);
      } catch (_) {}
    }));
  }

  void _next() {
    if (_isFinishing) return;

    // Stop any running mic before leaving the exercise.
    final rec = ref.read(audioRecorderProvider);
    if (rec.state == RecordingState.recording) rec.stopRecording();
    rec.resetToIdle();

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _selectedOption = null;
        _answered = false;
        _phraseIdx = 0;
        _clearPron();
      });
    } else {
      _isFinishing = true;
      _sessionTimer?.cancel();
      _ingestMissed();
      final userId = _userId;
      final elapsed = _elapsedSeconds > 0 ? _elapsedSeconds : 60;
      unawaited(Future(() async {
        try {
          await ref.read(practiceServiceProvider).recordAttempt(
            AttemptResult(
              userId: userId,
              objectiveId: widget.packId,
              track: Track.vocabulary,
              score: _totalSteps > 0 ? (_correctCount / _totalSteps) : 1.0,
              durationSeconds: elapsed,
              mistakes: _missed.length,
              fsrsGenerated: _missed.length,
            ),
          );
          ref.invalidate(profileSummaryProvider);
          ref.invalidate(activeProfileProvider);
        } catch (_) {}
      }));

      int avgPronScore = 90;
      if (_pronScoresByTerm.isNotEmpty) {
        final sum = _pronScoresByTerm.values.reduce((a, b) => a + b);
        avgPronScore = (sum / _pronScoresByTerm.length).round();
      } else if (_totalSteps > 0) {
        avgPronScore = ((_correctCount / _totalSteps) * 100).round().clamp(65, 98);
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VocabularyPracticeSummaryScreen(
            topicTitle: _ex.item.category,
            totalExercises: _totalSteps,
            correctExercises: _correctCount,
            timeElapsed: _formattedTime,
            avgPronunciationScore: avgPronScore,
            practicedTerms: _evaluatedTerms,
          ),
        ),
      );
    }
  }

  Future<void> _playModel(String text, {bool slow = false}) async {
    setState(() => _isPlayingModel = true);
    try {
      final player = ref.read(audioPlayerProvider);
      await player.playTts(text, slow: slow, voice: AppVoices.vocabulary);
    } catch (_) {
      // ignore playback errors silently in the drill
    }
    if (mounted) setState(() => _isPlayingModel = false);
  }

  void _clearPron() {
    _checking = false;
    _pronError = false;
    _pronResult = null;
    _pronTip = null;
  }

  List<String> _currentPhrases() => _phrasesFor(_ex.item);
  bool get _isWordPhrase =>
      _phraseIdx % _currentPhrases().length == 0;
  String get _currentPhrase =>
      _currentPhrases()[_phraseIdx % _currentPhrases().length];

  Future<void> _toggleRecording() async {
    final rec = ref.read(audioRecorderProvider);
    if (rec.state == RecordingState.recording) {
      final path = await rec.stopRecording();
      if (path != null && path.isNotEmpty) {
        await _evaluate(path);
      }
    } else {
      setState(_clearPron);
      await rec.startRecording();
    }
  }

  Future<void> _evaluate(String path) async {
    final it = _ex.item;
    final isWord = _isWordPhrase;
    _pitchAudioPath = path;
    _pitchText = isWord ? it.term : _currentPhrase;
    setState(() {
      _checking = true;
      _pronError = false;
      _pronResult = null;
      _pronTip = null;
    });
    final termToEval = isWord ? it.term : _currentPhrase;
    final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
      section: 'vocabulary',
      audioPath: path,
      expectedTerm: termToEval,
      expectedIpa: isWord ? it.phonetic : null,
      userId: _userId,
      exerciseType: isWord ? 'single_word' : 'short_phrase',
      category: it.category,
    );
    if (!mounted) return;
    final res = out.result;
    setState(() {
      _pronResult = res;
      _checking = false;
      _pronError = out.isError;
    });
    if (out.isLive && res.score > 0) {
      _pronScoresByTerm[it.term] = res.score;
      // ignore: unawaited_futures
      ref.read(measurementServiceProvider).record(userId: _userId, zone: MeasurementZones.vocabulary, targetType: isWord ? 'word' : 'phrase', targetId: isWord ? it.term : _currentPhrase, metricKey: MeasurementMetrics.pronunciationGop, value: res.score.toDouble(), audioUrl: res.audioUrl, label: isWord ? it.term : _currentPhrase);
      final idx = _evaluatedTerms.indexWhere((t) => t['term'] == it.term);
      if (idx >= 0) {
        _evaluatedTerms[idx]['percent'] = '${res.score}%';
        _evaluatedTerms[idx]['badge'] = res.score >= 85 ? 'Dominado' : 'En Progreso';
        _evaluatedTerms[idx]['isMastered'] = res.score >= 85;
      }
    }
    if (out.isLive) _fetchTip(res, it); // non-blocking
  }

  Future<void> _fetchTip(PronunciationResult res, VocabularyItem it) async {
    try {
      final api = ref.read(apiClientProvider);
      final tip = await api.getPronunciationTip(
        term: it.term,
        ipa: it.phonetic,
        recognized: res.recognized_text,
        score: res.score,
        wrongPhonemes: res.wrongPhonemes,
        confidence: res.confidence,
      );
      if (!mounted) return;
      if (tip != null && tip.trim().isNotEmpty) {
        setState(() => _pronTip = tip.trim());
      }
    } catch (_) {}
  }

  Color _scoreColor(int s) => s >= 88
      ? VocabTheme.tertiary
      : (s >= 70 ? VocabTheme.primary : VocabTheme.error);
  Color _scoreBg(int s) => s >= 88
      ? VocabTheme.tertiaryFixed
      : (s >= 70 ? VocabTheme.primaryFixed : VocabTheme.errorContainer);

  Future<void> _playMyRecording() async {
    final rec = ref.read(audioRecorderProvider);
    final path = rec.lastRecordingPath;
    if (path == null || path.isEmpty) return;
    try {
      await ref.read(audioPlayerProvider).playAudioUrl(path);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final locale = ref.watch(localeProvider);
    final isEn = locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: VocabTheme.surface.withValues(alpha: 0.95),
            border: Border(
              bottom:
                  BorderSide(color: VocabTheme.surfaceContainerHigh, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/vocabulary');
                      }
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VocabTheme.surfaceContainer,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: VocabTheme.onSurface, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn
                                  ? 'Active Practice Session'
                                  : 'Sesión Activa de Práctica',
                              style:
                                  VocabTheme.titleSm(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '${_currentStep + 1} / $_totalSteps',
                              style: VocabTheme.labelSm(
                                color: VocabTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (_currentStep + 1) / _totalSteps,
                            backgroundColor: VocabTheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                VocabTheme.primaryContainer),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSessionMetaBar(),
              const SizedBox(height: 16),
              _buildMainExerciseCard(),
              if (_answered) ...[
                const SizedBox(height: 16),
                _buildFeedbackAndPronunciation(),
              ],
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: VocabTheme.surface.withValues(alpha: 0.95),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _answered ? _next : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: VocabTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: VocabTheme.surfaceContainerHighest,
              disabledForegroundColor: VocabTheme.onSurfaceVariant,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              elevation: _answered ? 2 : 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  !_answered
                      ? (isEn ? 'Select an answer' : 'Selecciona una respuesta')
                      : (_currentStep < _totalSteps - 1
                          ? (isEn ? 'Next exercise' : 'Siguiente ejercicio')
                          : (isEn ? 'See summary' : 'Ver resumen')),
                  style: VocabTheme.titleSm(
                    color: _answered
                        ? Colors.white
                        : VocabTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_answered) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionMetaBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: VocabTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: VocabTheme.tertiary, size: 18),
              const SizedBox(width: 4),
              Text(
                '$_correctCount',
                style: VocabTheme.labelMd(
                    color: VocabTheme.onSurface, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: List.generate(_totalSteps, (index) {
              Color barColor;
              if (index < _currentStep) {
                barColor = VocabTheme.primary;
              } else if (index == _currentStep) {
                barColor = VocabTheme.primaryContainer;
              } else {
                barColor = VocabTheme.surfaceContainerHighest;
              }
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 5,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: VocabTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded,
                  color: VocabTheme.secondary, size: 16),
              const SizedBox(width: 4),
              Text(
                _formattedTime,
                style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: VocabTheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainExerciseCard() {
    final it = _ex.item;
    final cloze = _clozeSentence(it);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  it.category.toUpperCase(),
                  style: VocabTheme.labelSm(
                      color: VocabTheme.primary, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: VocabTheme.tertiaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  it.level,
                  style: VocabTheme.labelSm(
                      color: VocabTheme.onTertiaryFixed,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // English prompt.
          Text(
            'Read the definition and pick the exact term that fits the sentence:',
            style: VocabTheme.titleMd(
                color: VocabTheme.onSurface, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          // Definition (the real clue), in English.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VocabTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              it.definition,
              style: VocabTheme.bodyMd(color: VocabTheme.onSurface),
            ),
          ),
          if (cloze.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: VocabTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: VocabTheme.surfaceContainerHigh),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      color: VocabTheme.primaryContainer,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          '“$cloze”',
                          style: VocabTheme.bodyLg(color: VocabTheme.onSurface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Column(
            children: List.generate(_ex.options.length, (i) {
              return Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                child: _buildOptionTile(i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(int index) {
    final letter = String.fromCharCode(65 + index); // A, B, C, D
    final title = _ex.options[index];
    final isSelected = _selectedOption == index;
    final isCorrect = index == _ex.correctIndex;

    Color bgColor = VocabTheme.surfaceContainerLow;
    Color borderColor = Colors.transparent;
    Color letterBg = VocabTheme.surfaceContainerHighest;
    Color letterColor = VocabTheme.onSurfaceVariant;
    Widget? trailing;
    double opacity = 1.0;

    if (!_answered) {
      // Neutral, fully interactive.
    } else if (isCorrect) {
      bgColor = VocabTheme.tertiaryFixed;
      borderColor = VocabTheme.tertiary;
      letterBg = VocabTheme.tertiary;
      letterColor = VocabTheme.onTertiary;
      trailing = Icon(Icons.check_rounded,
          color: VocabTheme.tertiary, size: 20);
    } else if (isSelected) {
      bgColor = VocabTheme.errorContainer;
      borderColor = VocabTheme.error;
      letterBg = VocabTheme.error;
      letterColor = Colors.white;
      trailing =
          const Icon(Icons.close_rounded, color: VocabTheme.error, size: 20);
    } else {
      opacity = 0.5;
    }

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: _answered ? null : () => _onAnswer(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: letterBg),
                      child: Center(
                        child: Text(
                          letter,
                          style: VocabTheme.labelSm(
                              color: letterColor,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: VocabTheme.titleSm(
                          color: VocabTheme.onSurface,
                          fontWeight: (_answered && (isCorrect || isSelected))
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackAndPronunciation() {
    final it = _ex.item;
    final correct = _selectedOption == _ex.correctIndex;
    final hasEs = it.spanishDefinition.trim().isNotEmpty;
    final es = _fbSpanish && hasEs;
    final defText = es ? it.spanishDefinition : it.definition;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: correct
                      ? VocabTheme.tertiaryFixed
                      : VocabTheme.errorContainer,
                ),
                child: Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: correct ? VocabTheme.tertiary : VocabTheme.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      correct
                          ? (es ? '¡Correcto!' : 'Correct!')
                          : (es ? 'No exactamente.' : 'Not quite.'),
                      style: VocabTheme.titleSm(
                          color: VocabTheme.onSurface,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      es
                          ? 'El término correcto es «${it.term}».'
                          : (correct
                              ? 'The right term is “${it.term}”.'
                              : 'The correct term is “${it.term}”.'),
                      style: VocabTheme.labelSm(
                          color: correct
                              ? VocabTheme.tertiary
                              : VocabTheme.error,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              // Flip / translate the correction EN <-> ES.
              if (hasEs)
                InkWell(
                  onTap: () => setState(() => _fbSpanish = !_fbSpanish),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: VocabTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: VocabTheme.primaryContainer, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.translate_rounded,
                            size: 14, color: VocabTheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          es ? 'EN' : 'ES',
                          style: VocabTheme.labelSm(
                              color: VocabTheme.primary,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VocabTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(
                style: VocabTheme.bodyMd(color: VocabTheme.onSurface),
                children: [
                  TextSpan(
                    text: '‘${it.term}’ ',
                    style: VocabTheme.titleSm(
                        color: VocabTheme.primary,
                        fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: '${it.phonetic}  —  $defText'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPronunciationDrill(it),
        ],
      ),
    );
  }

  Widget _buildPronunciationDrill(VocabularyItem it) {
    final phrases = _phrasesFor(it);
    final phrase = phrases[_phraseIdx % phrases.length];
    final isWord = _phraseIdx % phrases.length == 0;

    final rec = ref.watch(audioRecorderProvider);
    final isRecording = rec.state == RecordingState.recording;
    final hasRecording =
        (rec.lastRecordingPath != null && rec.lastRecordingPath!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded,
                  color: VocabTheme.primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Pronunciation practice',
                  style: VocabTheme.labelMd(
                      color: VocabTheme.onSurface,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${(_phraseIdx % phrases.length) + 1}/${phrases.length}',
                style: VocabTheme.labelSm(color: VocabTheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isWord
                ? 'Say the word out loud:'
                : 'Say this full sentence out loud:',
            style: VocabTheme.bodySm(color: VocabTheme.secondary),
          ),
          const SizedBox(height: 10),
          // The phrase to practise.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: VocabTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: VocabTheme.surfaceContainerHigh),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: VocabTheme.primaryContainer,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isWord ? it.term : '“$phrase”',
                            style: VocabTheme.bodyLg(
                                color: VocabTheme.onSurface,
                                fontWeight: isWord ? FontWeight.w800 : FontWeight.w500),
                          ),
                          if (isWord) ...[
                            const SizedBox(height: 4),
                            Text(
                              it.phonetic,
                              style: GoogleFonts.robotoMono(
                                  fontSize: 13, color: VocabTheme.secondary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Controls row 1: hear model + more sentences.
          Row(
            children: [
              Expanded(
                child: _pillButton(
                  icon: _isPlayingModel
                      ? Icons.graphic_eq_rounded
                      : Icons.volume_up_rounded,
                  label: 'Hear model',
                  onTap: () => _playModel(phrase, slow: false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _pillButton(
                  icon: Icons.slow_motion_video_rounded,
                  label: 'Slow (0.8×)',
                  onTap: () => _playModel(phrase, slow: true),
                ),
              ),
              const SizedBox(width: 8),
              _pillButton(
                icon: Icons.skip_next_rounded,
                label: 'Next',
                compact: true,
                onTap: () => setState(() {
                  _phraseIdx++;
                  _clearPron();
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Live IPA guide.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRecording
                    ? 'Recording… tap to stop'
                    : (hasRecording
                        ? 'Recorded — play it back to compare'
                        : 'Tap the mic and repeat'),
                style: VocabTheme.labelSm(color: VocabTheme.secondary),
              ),
              if (isWord)
                Text(
                  it.phonetic,
                  style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: VocabTheme.secondary,
                      letterSpacing: 1),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Controls row 2: record + play back.
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _toggleRecording,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isRecording
                          ? VocabTheme.errorContainer
                          : VocabTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isRecording
                            ? VocabTheme.error
                            : VocabTheme.surfaceContainerHighest,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRecording) ...[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: VocabTheme.error),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: isRecording
                              ? VocabTheme.error
                              : VocabTheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isRecording ? 'Stop' : 'Record',
                          style: VocabTheme.labelMd(
                              color: VocabTheme.onSurface,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Opacity(
                  opacity: hasRecording && !isRecording ? 1.0 : 0.45,
                  child: InkWell(
                    onTap: hasRecording && !isRecording
                        ? _playMyRecording
                        : null,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: VocabTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: VocabTheme.surfaceContainerHighest,
                            width: 1),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: VocabTheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'My recording',
                            style: VocabTheme.labelMd(
                                color: VocabTheme.onSurface,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildPronResult(),
          if (_pronResult != null && _pitchAudioPath != null && _pitchText != null)
            PitchComparatorPanel(audioPath: _pitchAudioPath!, text: _pitchText, voice: AppVoices.vocabulary, userId: _userId, zone: MeasurementZones.vocabulary, targetId: _pitchText!),
          if (rec.errorMessage != null && rec.state == RecordingState.error) ...[
            const SizedBox(height: 8),
            Text(
              rec.errorMessage!,
              style: VocabTheme.labelSm(color: VocabTheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPronResult() {
    if (_checking) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: VocabTheme.primary),
            ),
            const SizedBox(width: 10),
            Text('Evaluando tu pronunciación…',
                style: VocabTheme.labelSm(color: VocabTheme.secondary)),
          ],
        ),
      );
    }
    if (_pronError) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          'No se pudo evaluar. Enciende el worker de pronunciación '
          '(portátil/Speaches) y reintenta.',
          style: VocabTheme.labelSm(color: VocabTheme.error),
        ),
      );
    }
    final r = _pronResult;
    if (r == null) return const SizedBox.shrink();
    final color = _scoreColor(r.score);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _scoreBg(r.score),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${r.score} / 100',
                  style: VocabTheme.labelMd(
                      color: color, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const Spacer(),
              if (r.engineUsed.isNotEmpty && r.engineUsed != 'unavailable')
                Text(r.engineUsed,
                    style: VocabTheme.labelSm(color: VocabTheme.secondary)),
            ],
          ),
          if (r.recognized_text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Heard: “${r.recognized_text}”',
                style: VocabTheme.bodySm(color: VocabTheme.secondary)),
          ],
          const SizedBox(height: 6),
          Text(r.feedback,
              style: VocabTheme.bodySm(color: VocabTheme.onSurface)),
          if (r.wrongPhonemes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.wrongPhonemes.take(6).map((w) {
                final cleanSymbol = w.replaceAll('/', '').trim();
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
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: VocabTheme.errorContainer,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: VocabTheme.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.hearing_rounded, size: 12, color: VocabTheme.error),
                          const SizedBox(width: 4),
                          Text(
                            w,
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: VocabTheme.error,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 8, color: VocabTheme.error),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 16, color: VocabTheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: _pronTip == null
                    ? Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: VocabTheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Text('Consejo IA en camino…',
                              style: VocabTheme.labelSm(
                                  color: VocabTheme.secondary)),
                        ],
                      )
                    : Text(_pronTip!,
                        style: VocabTheme.bodySm(color: VocabTheme.onSurface)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: VocabTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: VocabTheme.surfaceContainerHighest, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: VocabTheme.primary, size: 16),
            if (!compact) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: VocabTheme.labelSm(
                      color: VocabTheme.onSurface,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
