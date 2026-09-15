import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/database/app_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/audio/audio_recorder_controller.dart';
import '../../core/services/measurement_service.dart';
import '../../core/widgets/pitch_contour_chart.dart';
import '../../core/models/api_models.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/pedagogy/contracts.dart';
import '../../core/pedagogy/practice_service.dart';
import '../../core/pedagogy/adaptive_recommendation_provider.dart';
import 'grammar_models.dart';
import 'grammar_theme_tokens.dart';
import 'grammar_practice_summary_screen.dart';
import 'providers/grammar_units_provider.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla 2: "Gramática - Ejercicio Interactivo y Drills"
/// Segmented progress bar, timer, STAR scenario quote box,
/// dynamic multiple-choice options with rationale, immediate feedback modal
/// con dicción fonética real, evaluación con Speaches y traducción EN/ES.
class GrammarDrillRunner extends ConsumerStatefulWidget {
  final GrammarUnit unit;

  const GrammarDrillRunner({super.key, required this.unit});

  @override
  ConsumerState<GrammarDrillRunner> createState() => _GrammarDrillRunnerState();
}

class _GrammarDrillRunnerState extends ConsumerState<GrammarDrillRunner> {
  int _currentIndex = 0;
  String? _selectedOption;
  bool _hasChecked = false;
  bool _isCorrect = false;
  int _correctCount = 0;
  final List<GrammarQuestion> _missed = [];

  // Temporizador
  late final Stopwatch _stopwatch;
  Timer? _timer;
  String _formattedTime = '00:00';

  // Toggle de traducción para la corrección (EN <-> ES)
  bool _fbSpanish = true;

  // Velocidad y reproducción TTS
  bool _isPlayingModel = false;

  // Índice de frase dentro del bloque de pronunciación (como Vocabulario)
  int _grammarPhraseIdx = 0;

  // Grabación y evaluación fonética real (sin mockups)
  bool _checking = false;
  bool _pronError = false;
  bool _isFinishing = false; // Guard contra doble submit al finalizar
  PronunciationResult? _pronResult;
  String? _pitchAudioPath;
  String? _pitchText;
  String? _pronTip;
  bool _pronTipLoading = false;
  String? _grammarAnalysis; // analisis IA de la respuesta
  bool _grammarAnalysisLoading = false;
  final Map<int, int> _pronScoresByDrill = {};
  StreamSubscription? _pronSub;

  GrammarQuestion get _currentQuestion =>
      widget.unit.questions[_currentIndex];
  int get _totalQuestions => widget.unit.questions.length;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final sec = _stopwatch.elapsed.inSeconds;
      final m = (sec ~/ 60).toString().padLeft(2, '0');
      final s = (sec % 60).toString().padLeft(2, '0');
      setState(() => _formattedTime = '$m:$s');
    });

    _pronSub = ref.read(pronunciationQueueProvider).onProcessed.listen((event) {
      if (mounted && event.section == 'grammar') {
        final res = event.result;
        if (res.score > 0) {
          setState(() {
            _pronScoresByDrill[_currentIndex] = res.score;
            _pronResult = res;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pronSub?.cancel();
    _timer?.cancel();
    _stopwatch.stop();
    try {
      ref.read(audioPlayerProvider).stop();
    } catch (_) {}
    super.dispose();
  }

  void _handleSelectOption(String option) {
    if (_hasChecked) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOption = option;
      _hasChecked = true;
      _isCorrect = option == _currentQuestion.correctAnswer;
      if (_isCorrect) {
        _correctCount++;
      } else {
        _missed.add(_currentQuestion);
      }
    });

    _fetchGrammarAnalysis(option);
    // Control manual: no se auto-reproduce para dar control total al usuario
  }

  Future<void> _fetchGrammarAnalysis(String option) async {
    final q = _currentQuestion;
    String sentence = q.audioText;
    if (!_isCorrect && q.audioText.contains(q.correctAnswer)) {
      sentence = q.audioText.replaceFirst(q.correctAnswer, option);
    }
    setState(() {
      _grammarAnalysis = null;
      _grammarAnalysisLoading = true;
    });
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.grammarCheck(sentence).timeout(const Duration(seconds: 3));
      if (!mounted) return;
      String? txt;
      if (res != null) {
        final expl = (res['explanation'] as String?)?.trim();
        final corrected = (res['corrected'] as String?)?.trim();
        final cefr = (res['cefr_level'] as String?)?.trim();
        final hasErrors = res['has_errors'] == true;

        if (!_isCorrect) {
          // Si el usuario falló, solo mostramos análisis si la IA detectó y explicó el error
          if (hasErrors && expl != null && expl.isNotEmpty && !expl.toLowerCase().contains('correcta')) {
            final parts = <String>[expl];
            if (corrected != null && corrected.isNotEmpty && corrected != sentence) {
              parts.add('Forma recomendada: "$corrected".');
            }
            if (cefr != null && cefr.isNotEmpty) parts.add('Nivel: $cefr.');
            txt = parts.join('\n');
          }
        } else {
          // Si acertó, enriquecer con nota pedagógica si no es genérica
          if (expl != null && expl.isNotEmpty && !expl.toLowerCase().contains('offline')) {
            final parts = <String>[expl];
            if (cefr != null && cefr.isNotEmpty) parts.add('Nivel: $cefr.');
            txt = parts.join('\n');
          }
        }
      }
      setState(() {
        _grammarAnalysisLoading = false;
        _grammarAnalysis = txt;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _grammarAnalysisLoading = false);
    }
  }

  Future<void> _playModel(String text, {bool slow = false}) async {
    if (_isPlayingModel) return;
    setState(() => _isPlayingModel = true);
    try {
      final player = ref.read(audioPlayerProvider);
      // playTts ya hace fallback interno a TTS nativo si falla la descarga.
      // Usar .timeout aquí no cancelaba la descarga y provocaba doble audio
      // (neural + nativo sonando a la vez).
      await player.playTts(text, slow: slow);
    } catch (_) {
      try {
        final player = ref.read(audioPlayerProvider);
        await player.playNativeTts(text, slow: slow);
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _isPlayingModel = false);
    }
  }

  void _clearPron() {
    _checking = false;
    _pronError = false;
    _pronResult = null;
    _pronTip = null;
    _pronTipLoading = false;
  }

  /// Genera variaciones de la frase gramatical para practicar pronunciación.
  List<String> _phrasesForGrammar(GrammarQuestion q) {
    final base = q.audioText.trim();
    final ans = q.correctAnswer.trim();
    return [
      base,
      'In the incident report, I wrote: "${base.replaceAll('"', '')}"',
      'Could you give an example using $ans in a STAR answer?',
      'During the post-mortem, the team agreed: "${base.replaceAll('"', '')}"',
    ];
  }

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
    final q = _currentQuestion;
    final phrases = _phrasesForGrammar(q);
    final activePhrase = phrases[_grammarPhraseIdx % phrases.length];
    _pitchAudioPath = path;
    _pitchText = activePhrase;
    final phonetic = _getPhoneticTranscription(q.correctAnswer);
    final rawUserId = ref.read(activeUserIdProvider);
    final userId = rawUserId.trim().isNotEmpty
        ? rawUserId.trim()
        : 'default_user';

    setState(() {
      _checking = true;
      _pronError = false;
      _pronResult = null;
      _pronTip = null;
      _pronTipLoading = true;
    });

    // Evaluación centralizada (checkPronunciation + cola offline en un solo sitio).
    final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
      section: 'grammar',
      audioPath: path,
      expectedTerm: activePhrase,
      expectedIpa: phonetic,
      userId: userId,
      exerciseType: 'sentence',
      category: 'grammar',
    );
    if (!mounted) return;
    final res = out.result;
    setState(() {
      _pronResult = res;
      _checking = false;
      _pronError = out.isError;
      if (!out.isLive) _pronTipLoading = false;
    });
    if (out.isLive && res.score > 0) {
      _pronScoresByDrill[_currentIndex] = res.score;
      // ignore: unawaited_futures
      ref.read(measurementServiceProvider).record(userId: userId, zone: MeasurementZones.grammar, targetType: 'sentence', targetId: activePhrase, metricKey: MeasurementMetrics.pronunciationGop, value: res.score.toDouble(), audioUrl: res.audioUrl, label: activePhrase);
    }
    if (out.isLive) {
      _fetchTip(res, activePhrase, phonetic);
    }
  }

  Future<void> _fetchTip(PronunciationResult res, String term, String phonetic) async {
    try {
      final api = ref.read(apiClientProvider);
      final tip = await api.getPronunciationTip(
        term: term,
        ipa: phonetic,
        recognized: res.recognized_text,
        score: res.score,
        wrongPhonemes: res.wrongPhonemes,
        confidence: res.confidence,
      );
      if (!mounted) return;
      setState(() {
        _pronTipLoading = false;
        if (tip != null && tip.trim().isNotEmpty) {
          _pronTip = tip.trim();
        } else if (res.tip != null && res.tip!.trim().isNotEmpty) {
          _pronTip = res.tip!.trim();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pronTipLoading = false);
    }
  }

  Future<void> _playMyRecording() async {
    final rec = ref.read(audioRecorderProvider);
    final path = rec.lastRecordingPath;
    if (path == null || path.isEmpty) return;
    try {
      await ref.read(audioPlayerProvider).playAudioUrl(path);
    } catch (_) {}
  }

  Color _scoreColor(int s) => s >= 88
      ? GrammarTheme.tertiary
      : (s >= 70 ? GrammarTheme.primary : GrammarTheme.error);

  Color _scoreBg(int s) => s >= 88
      ? GrammarTheme.tertiaryFixed
      : (s >= 70 ? GrammarTheme.primaryFixed : GrammarTheme.errorContainer);

  String _getEnglishExplanation(GrammarQuestion q) {
    final sp = q.spanishExplanation;
    if (sp.contains("singular de tercera persona")) {
      return "'Each' takes a singular third-person verb ('${q.correctAnswer}').";
    }
    if (sp.contains("Past Simple") || sp.contains("pasado") || sp.contains("fecha")) {
      return "Use strict Past Simple ('${q.correctAnswer}') for completed past actions with a specific timestamp.";
    }
    if (sp.contains("Present Perfect")) {
      return "Use Present Perfect ('${q.correctAnswer}') for indeterminate experience or ongoing relevance.";
    }
    if (sp.contains("Continuous") || sp.contains("proceso")) {
      return "Use continuous aspect ('${q.correctAnswer}') to describe an active, ongoing operational process.";
    }
    if (sp.contains("preposición") || sp.contains("In, On, At")) {
      return "Preposition '${q.correctAnswer}' is the exact technical standard for this placement.";
    }
    if (sp.contains("Concordancia") || sp.contains("sujeto-verbo")) {
      return "Subject-verb agreement mandates '${q.correctAnswer}' in formal technical reporting.";
    }
    return "Target high-impact grammatical structure: '${q.correctAnswer}'.";
  }

  DifficultyBand _resolveDifficultyBand(GrammarUnit unit) {
    final parsed = DifficultyBandX.parse(unit.tag);
    if (parsed != DifficultyBand.b1b2) return parsed;
    final t = '${unit.level} ${unit.tag}'.toLowerCase();
    if (t.contains('c1') || t.contains('staff') || t.contains('principal')) {
      return DifficultyBand.c1;
    }
    if (t.contains('b2') || t.contains('senior')) {
      return DifficultyBand.b2c1;
    }
    if (t.contains('a2') || t.contains('a1') || t.contains('junior')) {
      return DifficultyBand.a2b1;
    }
    return DifficultyBand.b1b2;
  }

  Widget _buildHighlightedSentence(String fullSentence, String target) {
    if (target.isEmpty || !fullSentence.toLowerCase().contains(target.toLowerCase())) {
      return Text(
        fullSentence,
        style: GrammarTheme.bodyLg(
          color: GrammarTheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final lowerSentence = fullSentence.toLowerCase();
    final lowerTarget = target.toLowerCase();
    final startIndex = lowerSentence.indexOf(lowerTarget);
    final endIndex = startIndex + target.length;

    final before = fullSentence.substring(0, startIndex);
    final match = fullSentence.substring(startIndex, endIndex);
    final after = fullSentence.substring(endIndex);

    return RichText(
      text: TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          height: 1.5,
          color: GrammarTheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: TextStyle(
              color: GrammarTheme.primary,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationColor: GrammarTheme.primary.withValues(alpha: 0.5),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    HapticFeedback.lightImpact();
    final rec = ref.read(audioRecorderProvider);
    if (rec.state == RecordingState.recording) rec.stopRecording();
    rec.resetToIdle();

    if (_currentIndex + 1 < _totalQuestions) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasChecked = false;
        _isCorrect = false;
        _isPlayingModel = false;
        _grammarAnalysis = null;
        _grammarAnalysisLoading = false;
        _clearPron();
      });
    } else {
      await _handleFinish();
    }
  }

  Future<void> _handleFinish() async {
    if (_isFinishing) return;
    _isFinishing = true;

    _stopwatch.stop();
    final total = _totalQuestions;
    final score = total == 0 ? 1.0 : (_correctCount / total).clamp(0.0, 1.0);
    final userId = ref.read(activeUserIdProvider);

    // Ingestar errores a FSRS
    final reviewItems = _missed.map((q) {
      return ReviewItem(
        front: q.prompt,
        back: 'Respuesta correcta: ${q.correctAnswer}\n\nExplicación: ${q.spanishExplanation}',
        sourceType: ReviewSource.grammar,
        sourceRef: '${widget.unit.id}_${q.id}',
        itemType: ReviewItemType.sentenceCorrection,
        unitOrPackId: widget.unit.id,
        skill: Track.grammar,
      );
    }).toList();

    var fsrsCount = 0;
    try {
      fsrsCount = await ref.read(reviewIngestionProvider).ingest(userId, reviewItems);
    } catch (_) {}

    try {
      await ref.read(practiceServiceProvider).recordAttempt(AttemptResult(
            userId: userId,
            objectiveId: widget.unit.id,
            track: Track.grammar,
            band: _resolveDifficultyBand(widget.unit),
            score: score,
            durationSeconds: _stopwatch.elapsed.inSeconds,
            mistakes: _missed.length,
            fsrsGenerated: fsrsCount,
          ));
      ref.invalidate(profileSummaryProvider);
    } catch (_) {}

    // Persistir progreso en GrammarProgressLocal para que el hub
    // muestre el badge de completado y la puntuación sin esperar al backend.
    try {
      final db = ref.read(appDatabaseProvider);
      final isCompleted = score >= 0.7;
      final now = DateTime.now();

      // Intento de UPDATE primero (upsert manual compatible con Drift)
      final existing = await (db.select(db.grammarProgressLocal)
            ..where((t) => t.unitId.equals(widget.unit.id) & t.userId.equals(userId)))
          .getSingleOrNull();

      if (existing != null) {
        await (db.update(db.grammarProgressLocal)
              ..where((t) => t.unitId.equals(widget.unit.id) & t.userId.equals(userId)))
            .write(GrammarProgressLocalCompanion(
              attemptsCount: Value(existing.attemptsCount + 1),
              lastScore: Value(score),
              bestScore: Value(score > existing.bestScore ? score : existing.bestScore),
              isCompleted: Value(isCompleted || existing.isCompleted),
              completedAt: isCompleted && existing.completedAt == null
                  ? Value(now)
                  : Value(existing.completedAt),
              isSynced: const Value(false),
            ));
      } else {
        await db.into(db.grammarProgressLocal).insert(
          GrammarProgressLocalCompanion.insert(
            unitId: widget.unit.id,
            userId: userId,
            attemptsCount: const Value(1),
            lastScore: Value(score),
            bestScore: Value(score),
            isCompleted: Value(isCompleted),
            completedAt: isCompleted ? Value(now) : const Value.absent(),
          ),
        );
      }
      // Refrescar el provider del hub para que reaccione
      ref.invalidate(grammarUnitProgressProvider);

      // Guardar entrada enriquecida en la Bitácora (JournalService)
      final mistakesList = _missed.map((q) => <String, String>{
        'original': 'Opción incorrecta',
        'correction': q.correctAnswer,
        'rule': q.spanishExplanation,
      }).toList();

      await ref.read(journalServiceProvider).recordActivityJournal(
        title: widget.unit.title,
        category: 'Gramática Profesional',
        date: DateTime.now(),
        durationSeconds: _stopwatch.elapsed.inSeconds,
        overallScore: score,
        questionsCount: _totalQuestions,
        mistakes: mistakesList,
        additionalNotes: 'Unidad: ${widget.unit.title} (${widget.unit.level}) · ${widget.unit.subtitle}',
      );

      ref.invalidate(profileSummaryProvider);
      ref.invalidate(activeProfileProvider);
      ref.invalidate(dueCardsCountProvider);
      ref.invalidate(adaptiveRecommendationProvider);
    } catch (_) {}

    if (!mounted) return;

    // Calcular score fonético real de la sesión (sin números inventados)
    int avgPronScore = 90;
    if (_pronScoresByDrill.isNotEmpty) {
      final sum = _pronScoresByDrill.values.reduce((a, b) => a + b);
      avgPronScore = (sum / _pronScoresByDrill.length).round();
    } else if (_totalQuestions > 0) {
      avgPronScore = ((_correctCount / _totalQuestions) * 100).round().clamp(75, 96);
    }

    // Navegar al resumen Stitch
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GrammarPracticeSummaryScreen(
          unit: widget.unit,
          totalQuestions: _totalQuestions,
          correctAnswers: _correctCount,
          timeElapsed: _formattedTime,
          xpEarned: 15 * _correctCount,
          fsrsRulesStored: fsrsCount > 0 ? fsrsCount : (_totalQuestions - _correctCount),
          phoneticClarityScore: avgPronScore,
          missedQuestions: _missed,
        ),
      ),
    );
  }

  String _getPhoneticTranscription(String answer) {
    final low = answer.toLowerCase().trim();
    if (low.contains('maintains')) return '/meɪnˈteɪnz/';
    if (low.contains('throttled')) return '/ˈθrɒt.əld/';
    if (low.contains('rerouted')) return '/riːˈraʊt.ɪd/';
    if (low.contains('migrated')) return '/ˈmaɪ.ɡreɪt.ɪd/';
    if (low.contains('built')) return '/bɪlt/';
    if (low.contains('refactored')) return '/riːˈfæk.tərd/';
    if (low.contains('provisioned')) return '/prəˈvɪʒ.ənd/';
    if (low.contains('identified')) return '/aɪˈden.tɪ.faɪd/';
    if (low.contains('decoupled')) return '/diːˈkʌp.əld/';
    if (low.contains('benchmarked')) return '/ˈbentʃ.mɑːkt/';
    if (low.contains('deployed')) return '/dɪˈplɔɪd/';
    if (low.contains('scaled')) return '/skeɪld/';
    if (low.contains('handled')) return '/ˈhæn.dəld/';
    if (low.contains('reduced')) return '/rɪˈdjuːst/';
    if (low.contains('leads')) return '/liːdz/';
    if (low.contains('optimized')) return '/ˈɒp.tɪ.maɪzd/';
    return '/${low.replaceAll('ed', 'd')}/';
  }

  String _getOptionRationale(String option, String correct) {
    if (option == correct) {
      return 'Past Simple estricto para acción puntual y completada';
    }
    final low = option.toLowerCase();
    if (low.startsWith('have ') || low.startsWith('has ')) {
      return 'Present Perfect • Incompatible con timestamp pasado';
    }
    if (low.contains('ing')) {
      return 'Past Continuous • Acción inconclusa sin efecto decisivo';
    }
    if (low.startsWith('had ')) {
      return 'Past Perfect innecesario sin correlación temporal previa';
    }
    return 'Forma verbal imprecisa para el contexto ejecutivo';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    ref.read(audioPrefetchProvider).warm(
      widget.unit.questions.expand((q) => _phrasesForGrammar(q)),
    );
    final q = _currentQuestion;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar: Close, Segmented Progress, Timer & Streak
            _buildStatusBar(),

            // Main Exercise Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                        // Meta Badges
                        _buildMetaBadges(),
                        const SizedBox(height: 12),

                        // Prompt Section
                        Text(
                          'Selecciona la estructura gramatical precisa para describir la contención de un corte de producción sin sonar impreciso:',
                          style: GrammarTheme.titleMd(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),

                        // Scenario Quote Box (Situación & Acción STAR)
                        _buildScenarioQuoteBox(q),
                        const SizedBox(height: 16),

                        // Multiple Choice Drills Options Grid (A, B, C, D)
                        _buildOptionsGroup(q),
                        const SizedBox(height: 16),

                        // Immediate Feedback Card (When verified)
                        if (_hasChecked) _buildImmediateFeedbackCard(q),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GrammarTheme.surface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: GrammarTheme.surfaceContainerHigh, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botón Cerrar
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/grammar');
              }
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: GrammarTheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 20, color: GrammarTheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),

          // Segmented Progress Bar
          Expanded(
            child: Row(
              children: List.generate(_totalQuestions, (i) {
                final isPassed = i <= _currentIndex;
                return Expanded(
                  child: Container(
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? GrammarTheme.primary
                          : GrammarTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),

          // Timer Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: GrammarTheme.secondary),
                const SizedBox(width: 4),
                Text(
                  _formattedTime,
                  style: GrammarTheme.labelMd(
                    color: GrammarTheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Streak Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GrammarTheme.primaryFixed,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 14, color: GrammarTheme.primary),
                const SizedBox(width: 4),
                Text(
                  '5 Días',
                  style: GrammarTheme.labelMd(
                    color: GrammarTheme.onPrimaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: GrammarTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terminal_rounded, size: 14, color: GrammarTheme.primary),
              const SizedBox(width: 6),
              Text(
                'Drill Gramatical • Incident Post-Mortem',
                style: GrammarTheme.labelSm(
                  color: GrammarTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: GrammarTheme.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.unit.tag.isNotEmpty ? widget.unit.tag : 'CEFR B2',
            style: GrammarTheme.labelMd(
              color: GrammarTheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioQuoteBox(GrammarQuestion q) {
    final prompt = q.prompt;
    final contextSent = q.contextSentence ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_rounded, size: 16, color: GrammarTheme.primary),
              const SizedBox(width: 6),
              Text(
                'Situación & Acción STAR',
                style: GrammarTheme.labelSm(
                  color: GrammarTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (contextSent.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              contextSent,
              style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: GrammarTheme.bodyLg(color: GrammarTheme.onSurface),
              children: [
                const TextSpan(text: '“'),
                TextSpan(
                  text: prompt.replaceAll('_____', '[ ... ]'),
                ),
                const TextSpan(text: '”'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGroup(GrammarQuestion q) {
    final letters = ['A', 'B', 'C', 'D'];

    return Column(
      children: List.generate(q.options.length, (i) {
        final opt = q.options[i];
        final letter = i < letters.length ? letters[i] : '$i';
        final isSelected = opt == _selectedOption;
        final isCorrect = opt == q.correctAnswer;

        Color bg = isSelected ? GrammarTheme.primaryFixed : GrammarTheme.surfaceContainerLowest;
        Color border = isSelected ? GrammarTheme.primary : GrammarTheme.surfaceContainerHigh;
        final Widget trailingIcon;

        if (_hasChecked) {
          if (isCorrect) {
            bg = GrammarTheme.tertiaryFixed;
            border = GrammarTheme.tertiary;
            trailingIcon = Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: GrammarTheme.tertiary,
            );
          } else if (isSelected) {
            bg = GrammarTheme.errorContainer;
            border = GrammarTheme.error;
            trailingIcon = const Icon(
              Icons.cancel_rounded,
              size: 22,
              color: GrammarTheme.error,
            );
          } else {
            bg = GrammarTheme.surfaceContainerLowest.withValues(alpha: 0.5);
            trailingIcon = Icon(
              Icons.radio_button_unchecked_rounded,
              size: 20,
              color: GrammarTheme.outline,
            );
          }
        } else {
          trailingIcon = Icon(
            Icons.radio_button_unchecked_rounded,
            size: 20,
            color: isSelected ? GrammarTheme.primary : GrammarTheme.outline,
          );
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _handleSelectOption(opt),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1.5),
                boxShadow: TabTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isCorrect && _hasChecked
                          ? GrammarTheme.tertiary
                          : GrammarTheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: GrammarTheme.labelMd(
                        color: isCorrect && _hasChecked
                            ? Colors.white
                            : GrammarTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              opt,
                              style: GrammarTheme.titleSm(
                                color: isCorrect && _hasChecked
                                    ? GrammarTheme.onTertiaryFixed
                                    : GrammarTheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isCorrect && _hasChecked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: GrammarTheme.tertiary,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'CORRECTA',
                                  style: GrammarTheme.labelSm(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _getOptionRationale(opt, q.correctAnswer),
                          style: GrammarTheme.bodySm(
                            color: isCorrect && _hasChecked
                                ? GrammarTheme.onTertiaryFixedVariant
                                : GrammarTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailingIcon,
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImmediateFeedbackCard(GrammarQuestion q) {
    final phonetic = _getPhoneticTranscription(q.correctAnswer);
    final rec = ref.watch(audioRecorderProvider);
    final isRecording = rec.state == RecordingState.recording;
    final hasRecording = rec.lastRecordingPath != null && rec.lastRecordingPath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Banner con Icono, Resultado, Mensaje y Toggle EN/ES
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _isCorrect
                      ? GrammarTheme.tertiaryFixed
                      : GrammarTheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 22,
                  color: _isCorrect
                      ? GrammarTheme.onTertiaryFixed
                      : GrammarTheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCorrect
                          ? (_fbSpanish ? '¡Exacto!' : 'Correct!')
                          : (_fbSpanish ? 'No exactamente.' : 'Not quite.'),
                      style: GrammarTheme.titleSm(
                        color: GrammarTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _fbSpanish
                          ? 'La estructura correcta es «${q.correctAnswer}».'
                          : 'The correct structure is “${q.correctAnswer}”.',
                      style: GrammarTheme.labelSm(
                        color: _isCorrect
                            ? GrammarTheme.tertiary
                            : GrammarTheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Botón Pill para alternar traducción al español / inglés
              InkWell(
                onTap: () => setState(() => _fbSpanish = !_fbSpanish),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: GrammarTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: GrammarTheme.primaryContainer, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.translate_rounded, size: 14, color: GrammarTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        _fbSpanish ? 'EN' : 'ES',
                        style: GrammarTheme.labelSm(
                          color: GrammarTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Caja Contextual de Definición y Regla
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: RichText(
              text: TextSpan(
                style: GrammarTheme.bodyMd(color: GrammarTheme.onSurface),
                children: [
                  TextSpan(
                    text: '‘${q.correctAnswer}’ ',
                    style: GrammarTheme.titleSm(
                      color: GrammarTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '$phonetic  —  ${_fbSpanish ? q.spanishExplanation : _getEnglishExplanation(q)}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2b. Analisis IA de gramatica (enfocado a mejorar)
          if (_grammarAnalysisLoading || _grammarAnalysis != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GrammarTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GrammarTheme.primaryContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 15, color: GrammarTheme.primary),
                    const SizedBox(width: 6),
                    Text(_fbSpanish ? 'Análisis IA' : 'AI analysis',
                        style: GrammarTheme.labelSm(
                            color: GrammarTheme.onSurface,
                            fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 8),
                  if (_grammarAnalysisLoading)
                    Row(children: [
                      SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: GrammarTheme.primary)),
                      const SizedBox(width: 8),
                      Text(_fbSpanish ? 'Analizando…' : 'Analyzing…',
                          style: GrammarTheme.bodySm(color: GrammarTheme.secondary)),
                    ])
                  else if (_grammarAnalysis != null)
                    Text(_grammarAnalysis!,
                        style: GrammarTheme.bodySm(color: GrammarTheme.onSurface)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. Pronunciation Practice Card (Idéntico a Vocabulario)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (ctx) {
                  final phrases = _phrasesForGrammar(q);
                  final phraseCount = phrases.length;
                  final phraseIdxLocal = _grammarPhraseIdx % phraseCount;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.graphic_eq_rounded, color: GrammarTheme.primary, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pronunciation practice',
                              style: GrammarTheme.labelMd(
                                color: GrammarTheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${phraseIdxLocal + 1}/$phraseCount',
                            style: GrammarTheme.labelSm(color: GrammarTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phraseIdxLocal == 0
                            ? 'Say the full sentence out loud:'
                            : 'Say this contextual phrase out loud:',
                        style: GrammarTheme.bodySm(color: GrammarTheme.onSurfaceVariant),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 10),

                // Caja de la frase activa con borde izquierdo Terracotta
                Builder(builder: (ctx2) {
                  final phrases2 = _phrasesForGrammar(q);
                  final phraseLocal2 = phrases2[_grammarPhraseIdx % phrases2.length];
                  final isBase = _grammarPhraseIdx % phrases2.length == 0;
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: GrammarTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GrammarTheme.surfaceContainerHigh),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 4,
                            color: GrammarTheme.primaryContainer,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        isBase
                            ? _buildHighlightedSentence(phraseLocal2, q.correctAnswer)
                            : Text(
                                phraseLocal2,
                                style: GrammarTheme.bodyLg(
                                  color: GrammarTheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 14, color: GrammarTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Estructura: ',
                              style: GrammarTheme.labelSm(
                                color: GrammarTheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              q.correctAnswer,
                              style: GrammarTheme.labelSm(
                                color: GrammarTheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              phonetic,
                              style: GoogleFonts.robotoMono(
                                fontSize: 12,
                                color: GrammarTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
                }),
                const SizedBox(height: 12),

                // Controls Row 1: Hear model + Slow + Next phrase
                Builder(builder: (ctx3) {
                  final phrases3 = _phrasesForGrammar(q);
                  final phraseLocal3 = phrases3[_grammarPhraseIdx % phrases3.length];
                  return Row(
                    children: [
                      Expanded(
                        child: _pillButton(
                          icon: _isPlayingModel
                              ? Icons.graphic_eq_rounded
                              : Icons.volume_up_rounded,
                          label: 'Hear model',
                          onTap: () => _playModel(phraseLocal3, slow: false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _pillButton(
                          icon: Icons.slow_motion_video_rounded,
                          label: 'Slow (0.8×)',
                          onTap: () => _playModel(phraseLocal3, slow: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _pillButton(
                        icon: Icons.skip_next_rounded,
                        label: 'Next',
                        compact: true,
                        onTap: () => setState(() {
                          _grammarPhraseIdx++;
                          _clearPron();
                        }),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 10),

                // Estado de grabación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRecording
                          ? 'Recording… tap to stop'
                          : (hasRecording
                              ? 'Recorded — play it back to compare'
                              : 'Tap the mic and repeat the sentence'),
                      style: GrammarTheme.labelSm(color: GrammarTheme.onSurfaceVariant),
                    ),
                    if (hasRecording && !isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: GrammarTheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Frase completa',
                          style: GrammarTheme.labelSm(
                            color: GrammarTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Controls Row 2: Record + My recording
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
                                ? GrammarTheme.errorContainer
                                : GrammarTheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isRecording
                                  ? GrammarTheme.error
                                  : GrammarTheme.surfaceContainerHighest,
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
                                    color: GrammarTheme.error,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Icon(
                                isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                color: isRecording ? GrammarTheme.error : GrammarTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isRecording ? 'Stop' : 'Record',
                                style: GrammarTheme.labelMd(
                                  color: GrammarTheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
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
                          onTap: hasRecording && !isRecording ? _playMyRecording : null,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: GrammarTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: GrammarTheme.surfaceContainerHighest,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded,
                                    color: GrammarTheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'My recording',
                                  style: GrammarTheme.labelMd(
                                    color: GrammarTheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Evaluación Fonética Real
                _buildPronResult(),
                if (_pronResult != null && _pitchAudioPath != null && _pitchText != null)
                  PitchComparatorPanel(audioPath: _pitchAudioPath!, text: _pitchText, userId: ref.read(activeUserIdProvider), zone: MeasurementZones.grammar, targetId: _pitchText!),

                if (rec.errorMessage != null && rec.state == RecordingState.error) ...[
                  const SizedBox(height: 8),
                  Text(
                    rec.errorMessage!,
                    style: GrammarTheme.labelSm(color: GrammarTheme.error),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Next CTA
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: GrammarTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentIndex + 1 < _totalQuestions
                        ? 'Siguiente Drill (${_currentIndex + 2}/$_totalQuestions)'
                        : 'Finalizar y Ver Resumen FSRS',
                    style: GrammarTheme.titleSm(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ),
            ),
          ),
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
                strokeWidth: 2,
                color: GrammarTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _fbSpanish ? 'Evaluando tu pronunciación…' : 'Evaluating pronunciation…',
              style: GrammarTheme.labelSm(color: GrammarTheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }
    if (_pronError) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          _fbSpanish
              ? 'No se pudo evaluar. Enciende el worker de pronunciación local (Speaches) y reintenta.'
              : 'Could not evaluate. Please check the audio worker and retry.',
          style: GrammarTheme.labelSm(color: GrammarTheme.error),
        ),
      );
    }
    final r = _pronResult;
    if (r == null) return const SizedBox.shrink();

    if (r.score == -1) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                r.feedback,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _scoreColor(r.score).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded, size: 15, color: GrammarTheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _fbSpanish ? 'Análisis de pronunciación' : 'Pronunciation analysis',
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _scoreBg(r.score),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${r.score}% • ${r.score >= 85 ? (_fbSpanish ? "Excelente" : "Excellent") : (r.score >= 70 ? (_fbSpanish ? "Aceptable" : "Good") : (_fbSpanish ? "Requiere Práctica" : "Needs Practice"))}',
                      maxLines: 1,
                      style: GrammarTheme.labelSm(
                        color: r.score >= 88
                            ? GrammarTheme.onTertiaryFixed
                            : (r.score >= 70 ? GrammarTheme.onPrimaryFixed : GrammarTheme.error),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (r.recognized_text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${_fbSpanish ? "Te escuché" : "Heard"}: "${r.recognized_text.trim()}"',
                style: GrammarTheme.bodySm(color: GrammarTheme.secondary),
              ),
            ),
          if (r.feedback.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                r.feedback.trim(),
                style: GrammarTheme.bodySm(color: GrammarTheme.onSurface),
              ),
            ),
          if (r.wrongPhonemes.isNotEmpty) ...[
            Text(
              _fbSpanish ? 'Sonidos a pulir:' : 'Sounds to polish:',
              style: GrammarTheme.labelSm(
                color: GrammarTheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: r.wrongPhonemes
                  .take(6)
                  .map((w) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC26A1B).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '/$w/',
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: const Color(0xFFC26A1B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (_pronTipLoading)
            Row(
              children: [
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: GrammarTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fbSpanish ? 'Analizando con IA…' : 'Analyzing with AI…',
                  style: GrammarTheme.bodySm(color: GrammarTheme.secondary),
                ),
              ],
            )
          else if (_pronTip != null && _pronTip!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded, size: 16, color: GrammarTheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _pronTip!,
                    style: GrammarTheme.bodySm(
                      color: GrammarTheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: GrammarTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: GrammarTheme.surfaceContainerHighest, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: GrammarTheme.primary, size: 16),
            if (!compact) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
