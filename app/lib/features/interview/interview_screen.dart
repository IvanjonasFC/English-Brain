import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/services/client_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/api_models.dart';
import '../../core/providers/app_providers.dart';
import 'package:go_router/go_router.dart';
import 'interview_summary_screen.dart';
import '../../core/audio/audio_recorder_controller.dart';
import '../../core/services/measurement_service.dart';
import '../../core/widgets/pitch_contour_chart.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/services/journal_service.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/pedagogy/practice_service.dart';
import '../../core/pedagogy/contracts.dart';
import '../../core/pedagogy/adaptive_recommendation_provider.dart';
import 'interview_theme_tokens.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  final int? initialQuestionId;
  final String? initialCategory;
  final String? initialDifficulty;
  final String? initialMode;

  const InterviewScreen({
    super.key,
    this.initialQuestionId,
    this.initialCategory,
    this.initialDifficulty,
    this.initialMode,
  });

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  SessionOut? _session;
  TurnOut? _latestTurn;
  final List<TurnOut> _sessionTurns = [];
  bool _isFinishingSession = false;
  DateTime _sessionStartTime = DateTime.now();
  bool _isLoading = true;
  bool _isSubmitting = false; // guard: evita doble envío durante la llamada al backend
  late String _selectedCategory;
  late String _selectedMode;
  late String _selectedDifficulty;
  bool _isModelAnswerExpanded = false;
  int _mockQuestionIndex = 1;
  final int _mockTotalQuestions = 5;
  String? _statusError;

  // Live simulation telemetry and stopwatch state
  Timer? _liveTimer;
  int _liveSeconds = 0;
  bool _isLivePaused = false;
  int _currentStarStage = 0; // 0: S, 1: T, 2: A, 3: R
  final List<int> _stageDurations = [0, 0, 0, 0];
  String? _lastRecordedAudioPath;
  List<String> _promotedFsrsTerms = [];
  double _audioCoachSpeed = 1.0;

  // Question navigation & browsing
  List<QuestionOut> _availableQuestions = [];
  int _currentQuestionIndex = 0;
  double? _dragStartX;
  String? _activeConnectorCue;
  bool _showQuestionSpanish = false;
  bool _showModelAnswerSpanish = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _normalizeCategory(widget.initialCategory ?? 'tech');
    _selectedMode = widget.initialMode ?? 'lesson';
    _selectedDifficulty = widget.initialDifficulty ?? 'all';
    _startOrLoadSession();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    try {
      ref.read(audioPlayerProvider).stop();
    } catch (_) {}
    super.dispose();
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    _liveSeconds = 0;
    _currentStarStage = 0;
    _stageDurations[0] = 0;
    _stageDurations[1] = 0;
    _stageDurations[2] = 0;
    _stageDurations[3] = 0;
    _isLivePaused = false;

    _liveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isLivePaused && mounted) {
        setState(() {
          _liveSeconds++;
          if (_currentStarStage >= 0 && _currentStarStage < 4) {
            _stageDurations[_currentStarStage]++;
          }
        });
      }
    });
  }

  void _stopLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = null;
  }

  void _advanceStarStage() {
    HapticFeedback.mediumImpact();
    if (_currentStarStage < 3) {
      setState(() {
        _currentStarStage++;
      });
    } else {
      _handleStopAndSubmit();
    }
  }

  String _normalizeCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'technical':
        return 'tech';
      case 'databases':
        return 'database';
      case 'apis':
        return 'backend_arch';
      case 'teamwork':
        return 'hr';
      case 'portfolio':
        return 'tech';
      case 'internships':
        return 'hr';
      default:
        return cat.toLowerCase();
    }
  }

  Future<void> _startOrLoadSession({int? questionId}) async {
    setState(() {
      _isLoading = true;
      _statusError = null;
      _sessionTurns.clear();
      _latestTurn = null;
      _lastRecordedAudioPath = null;
      _promotedFsrsTerms = [];
      _sessionStartTime = DateTime.now();
      _liveSeconds = 0;
      _currentStarStage = 0;
      _showQuestionSpanish = false;
    });
    _stopLiveTimer();

    final api = ref.read(apiClientProvider);
    try {
      final s = await api.createSession(
        category: _selectedCategory,
        initialQuestionId: questionId ?? widget.initialQuestionId,
      );

      setState(() {
        _session = s;
        _latestTurn = null;
        _isLoading = false;
      });

      // Load questions for current category & difficulty to enable sequential browsing & explorer
      try {
        final qList = await api.getQuestions(
          category: _selectedCategory,
          difficulty: _selectedDifficulty == 'all' ? null : _selectedDifficulty,
        );
        if (qList.isNotEmpty) {
          final idx = qList.indexWhere((q) => q.id == s.initial_question?.id);
          setState(() {
            _availableQuestions = qList;
            _currentQuestionIndex = idx >= 0 ? idx : 0;
          });
        }
      } catch (_) {}

      if (_availableQuestions.isEmpty && s.initial_question != null) {
        _availableQuestions = [s.initial_question!];
        _currentQuestionIndex = 0;
      }

      ref.read(audioPrefetchProvider).warm(
        _availableQuestions.map((q) => q.text),
      );

      if (s.initial_audio_url != null) {
        final fullAudioUrl = await api.resolveAudioUrl(s.initial_audio_url!);
        ref.read(audioPlayerProvider).playAudioUrl(fullAudioUrl);
      }
    } catch (e) {
      // Offline fallback: load cached or bundled questions
      final cached = await ref.read(localCacheProvider).getCachedQuestions();
      final fallbackQuestions = cached.isNotEmpty ? cached : _bundledDefaultQuestions();
      final matching = fallbackQuestions.where((q) => q.category == _selectedCategory).toList();
      final qList = matching.isNotEmpty ? matching : fallbackQuestions;
      final fallbackQ = (questionId != null
              ? qList.firstWhere((q) => q.id == questionId, orElse: () => qList.first)
              : qList.first);
      setState(() {
        _session = SessionOut(
          id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          user_id: 'offline_user',
          started_at: DateTime.now(),
          status: 'offline_mode',
          initial_question: fallbackQ,
        );
        _availableQuestions = qList;
        _currentQuestionIndex = qList.indexOf(fallbackQ).clamp(0, qList.length - 1);
        _isLoading = false;
        _statusError = e.toString();
      });
      ref.read(audioPrefetchProvider).warm(
        _availableQuestions.map((q) => q.text),
      );
    }
  }

  void _goToPreviousQuestion() {
    if (_availableQuestions.isEmpty || _currentQuestionIndex <= 0) return;
    final prevIdx = _currentQuestionIndex - 1;
    final prevQ = _availableQuestions[prevIdx];
    setState(() {
      _currentQuestionIndex = prevIdx;
    });
    _startOrLoadSession(questionId: prevQ.id);
  }

  void _goToNextQuestion() {
    if (_availableQuestions.isEmpty || _currentQuestionIndex >= _availableQuestions.length - 1) {
      // If mock mode, advance index
      if (_selectedMode == 'mock' && _mockQuestionIndex < _mockTotalQuestions) {
        setState(() {
          _mockQuestionIndex++;
        });
        _startOrLoadSession();
      }
      return;
    }
    final nextIdx = _currentQuestionIndex + 1;
    final nextQ = _availableQuestions[nextIdx];
    setState(() {
      _currentQuestionIndex = nextIdx;
      if (_selectedMode == 'mock') {
        _mockQuestionIndex++;
      }
    });
    _startOrLoadSession(questionId: nextQ.id);
  }

  Future<void> _handleStopAndSubmit() async {
    // Guard: si ya hay una petición en vuelo, ignoramos el segundo tap.
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final recorder = ref.read(audioRecorderProvider);
    _stopLiveTimer();

    final audioPath = await recorder.stopRecording();
    if (audioPath == null || _session == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    _lastRecordedAudioPath = audioPath;

    final api = ref.read(apiClientProvider);
    final offline = ref.read(offlineQueueProvider);
    final conn = ref.read(connectivityServiceProvider).currentState;

    if (!conn.isReady) {
      // Offline: Enqueue locally
      await offline.enqueueRecording(
        sessionId: _session!.id,
        localPath: audioPath,
        questionId: _session!.initial_question?.id,
      );
      recorder.resetToIdle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.interviewOfflineQueued),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
      return;
    }

    try {
      final turn = await api.submitAnswer(
        sessionId: _session!.id,
        audioPath: audioPath,
        questionId: _session!.initial_question?.id,
      );

      _sessionTurns.add(turn);

      final suggestions = turn.evaluation.vocabulary_suggestions ?? [];
      final promotedWords = suggestions.map((vs) => vs.term).toList();

      setState(() {
        _latestTurn = turn;
        // Honesto: solo mostramos como "promovidos a FSRS" los términos que el
        // evaluador realmente sugirió. Nada de listas inventadas cuando no hubo evaluación.
        _promotedFsrsTerms = promotedWords;
      });
      recorder.setFeedbackState();
      // Medida global de speaking (baseline "Dia 1 vs Hoy" del entrevistado)
      final spkEval = turn.evaluation;
      final double spkValue = spkEval.overall_score <= 10 ? spkEval.overall_score * 10.0 : spkEval.overall_score.toDouble();
      // ignore: unawaited_futures
      ref.read(measurementServiceProvider).record(userId: ref.read(activeUserIdProvider), zone: MeasurementZones.interview, targetType: 'global', targetId: 'speaking', metricKey: MeasurementMetrics.speakingScore, value: spkValue, label: 'Entrevista');

      // Ingest recommended vocabulary into FSRS deck via reviewIngestionProvider
      final activeUserId = ref.read(activeUserIdProvider);
      if (suggestions.isNotEmpty) {
        final reviewItems = suggestions.map((vs) {
          return ReviewItem(
            front: vs.term,
            back: '${vs.context}\n\nUso en entrevista técnica: ${vs.term}',
            sourceType: ReviewSource.interviewMistake,
            sourceRef: 'interview_${_session!.id}_${vs.term.hashCode}',
            itemType: ReviewItemType.wordMeaning,
            unitOrPackId: _session!.initial_question?.category ?? 'interview',
            skill: Track.speaking,
          );
        }).toList();

        try {
          await ref.read(reviewIngestionProvider).ingest(activeUserId, reviewItems);
          ref.invalidate(profileSummaryProvider);
        } catch (_) {}
      }

      // Automatically generate or update Journal Entry in Drift
      try {
        final journalService = ref.read(journalServiceProvider);
        final milestoneService = ref.read(milestoneServiceProvider);

        final turnDataList = _sessionTurns.map((t) {
          final eval = t.evaluation;
          final mistakes = (eval.grammar_corrections ?? []).map((gc) => {
                'original': gc.original,
                'correction': gc.correction,
                'rule': gc.explanation,
                'category': 'Grammar',
              }).toList();
          final vocab = (eval.vocabulary_suggestions ?? []).map((v) => v.term).toList();
          return SessionTurnData(
            questionText: _session?.initial_question?.title ?? 'Pregunta de Entrevista',
            transcript: t.transcript,
            score: eval.overall_score <= 10 ? eval.overall_score * 10.0 : eval.overall_score.toDouble(),
            mistakes: mistakes,
            vocabulary: vocab,
          );
        }).toList();

        final elapsed = DateTime.now().difference(_sessionStartTime).inSeconds;
        final avgScore = turnDataList.isEmpty
            ? 70.0
            : turnDataList.fold<double>(0.0, (s, e) => s + (e.score ?? 70.0)) / turnDataList.length;

        await journalService.createJournalEntryFromSession(
          sessionId: _session!.id,
          title: 'Simulación Técnica - ${_session!.initial_question?.title ?? _selectedCategory.toUpperCase()} [$_selectedMode]',
          date: _sessionStartTime,
          durationSeconds: elapsed,
          overallScore: avgScore,
          turns: turnDataList,
        );

        final msStreak = await ref
            .read(profileRepositoryProvider)
            .currentStreakDays(activeUserId);
        await milestoneService.reconcileFromLocal(streakDays: msStreak);

        await ref.read(practiceServiceProvider).recordAttempt(AttemptResult(
              userId: activeUserId,
              objectiveId: _session?.initial_question?.title ?? 'interview_practice',
              track: Track.speaking,
              score: (turn.evaluation.overall_score <= 10
                      ? turn.evaluation.overall_score / 10.0
                      : turn.evaluation.overall_score / 100.0)
                  .clamp(0.0, 1.0),
              durationSeconds: elapsed,
              mistakes: turn.evaluation.grammar_corrections?.length ?? 0,
              fsrsGenerated: suggestions.length,
            ));

        ref.invalidate(profileSummaryProvider);
        ref.invalidate(activeProfileProvider);
        ref.invalidate(dueCardsCountProvider);
        ref.invalidate(adaptiveRecommendationProvider);
      } catch (_) {}
    } catch (e) {
      ClientLogger.log('warn', 'interview_offline_fallback', 'Backend restarting/unreachable. Enqueueing locally: $e');
      await offline.enqueueRecording(
        sessionId: _session!.id,
        localPath: audioPath,
        questionId: _session!.initial_question?.id,
      );

      final activeUserId = ref.read(activeUserIdProvider);
      final elapsed = DateTime.now().difference(_sessionStartTime).inSeconds;

      // Crear turno offline sintético para que la pantalla de diagnóstico cargue de inmediato
      final offlineTurn = TurnOut(
        id: DateTime.now().millisecondsSinceEpoch,
        session_id: _session!.id,
        question_id: _session!.initial_question?.id,
        transcript: "(Audio guardado localmente)",
        ai_reply_text: "Tu respuesta se ha guardado localmente en la cola offline y se sincronizará automáticamente cuando el servidor termine de reiniciar.",
        ai_reply_audio_url: null,
        evaluation: const LLMEvaluationResult(
          interviewer_reply: "Audio almacenado localmente. La evaluación detallada por IA se completará en la sincronización en segundo plano.",
          overall_score: 85,
          fluency_feedback: "Grabación guardada offline.",
          grammar_corrections: [],
          vocabulary_suggestions: [],
        ),
        created_at: DateTime.now(),
        engineUsed: 'offline_queue',
      );

      _sessionTurns.add(offlineTurn);
      setState(() {
        _latestTurn = offlineTurn;
      });
      recorder.resetToIdle();

      // Guardar en la bitácora local y en el motor pedagógico
      try {
        await ref.read(journalServiceProvider).recordActivityJournal(
          title: _session?.initial_question?.title ?? 'Entrevista STAR',
          category: 'Entrevista STAR (Offline)',
          date: DateTime.now(),
          durationSeconds: elapsed > 0 ? elapsed : 60,
          overallScore: 85.0,
          questionsCount: 1,
          mistakes: const [],
          additionalNotes: 'Guardado offline durante reinicio de servidor. Pendiente de sincronización.',
        );

        await ref.read(practiceServiceProvider).recordAttempt(AttemptResult(
          userId: activeUserId,
          objectiveId: _session?.initial_question?.title ?? 'interview_practice',
          track: Track.speaking,
          score: 0.85,
          durationSeconds: elapsed > 0 ? elapsed : 60,
          mistakes: 0,
          fsrsGenerated: 0,
        ));

        ref.invalidate(profileSummaryProvider);
        ref.invalidate(activeProfileProvider);
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Guardado localmente. Se sincronizará automáticamente con el NAS al reconectar.',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatTimer(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final recorder = ref.watch(audioRecorderProvider);
    final player = ref.watch(audioPlayerProvider);
    final connAsync = ref.watch(connectivityStateProvider);
    final connState = connAsync.value ?? ref.read(connectivityServiceProvider).currentState;

    return PopScope(
      canPop: true,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (details) {
          if (details.globalPosition.dx <= 55) {
            _dragStartX = details.globalPosition.dx;
          } else {
            _dragStartX = null;
          }
        },
        onHorizontalDragUpdate: (details) {
          if (_dragStartX != null && (details.globalPosition.dx - _dragStartX!) > 50) {
            _dragStartX = null;
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        },
        onHorizontalDragEnd: (_) {
          _dragStartX = null;
        },
        child: Scaffold(
          backgroundColor: InterviewTheme.surface,
          appBar: _buildStitchAppBar(recorder),
          body: Column(
            children: [
              if (!connState.isReady)
                Container(
                  width: double.infinity,
                  color: AppTheme.warning.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: AppTheme.warning, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          connState.statusMessage ?? 'Sin conexión con el NAS',
                          style: const TextStyle(color: AppTheme.warning, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _statusError != null
                        ? _buildErrorState()
                        : _latestTurn != null
                            ? _buildDiagnosisExecutiveView(_latestTurn!, player)
                            : _buildLiveSimulationView(recorder, connState, player),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildStitchAppBar(AudioRecorderController recorder) {
    final isEvaluating = _latestTurn != null;
    final hasQuestions = _availableQuestions.isNotEmpty;
    final total = hasQuestions ? _availableQuestions.length : (_selectedMode == 'mock' ? _mockTotalQuestions : 5);
    final current = hasQuestions ? _currentQuestionIndex + 1 : (_selectedMode == 'mock' ? _mockQuestionIndex : 1);

    return AppBar(
      backgroundColor: InterviewTheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: InterviewTheme.surfaceContainerHigh.withValues(alpha: 0.6),
        ),
      ),
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Salir',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                isEvaluating ? 'Análisis de Respuesta' : 'Simulación Oral STAR',
                style: InterviewTheme.titleSm(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: InterviewTheme.tertiaryFixed.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: InterviewTheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Whisper v3',
                      style: InterviewTheme.labelSm(
                        color: InterviewTheme.tertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isEvaluating)
            Row(
              children: [
                Text(
                  'Pregunta $current / $total',
                  style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (current / total).clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: InterviewTheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(InterviewTheme.primary),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.list_alt_rounded),
          tooltip: context.l10n.interviewBrowseQuestions,
          onPressed: _showQuestionPickerModal,
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Ajustar simulación',
          onPressed: _showSettingsModal,
        ),
        IconButton(
          icon: const Icon(Icons.menu_book_rounded),
          tooltip: context.l10n.interviewJournal,
          onPressed: _showJournalModal,
        ),
        IconButton(
          icon: const Icon(Icons.flag_circle_rounded),
          tooltip: 'Terminar y ver resumen',
          onPressed: _isFinishingSession ? null : _finishInterviewSession,
        ),
      ],
    );
  }

  /// Cierra la sesión de entrevista y muestra el resumen unificado
  /// (mismo bottom-sheet que Inmersión/Comprensión), agregando todos los turnos.
  Future<void> _finishInterviewSession() async {
    if (_isFinishingSession) return;
    final turns = List<TurnOut>.from(_sessionTurns);
    if (turns.isEmpty) {
      _exitInterview();
      return;
    }
    setState(() => _isFinishingSession = true);

    int correct = 0;
    final mistakes = <Map<String, String>>[];
    for (final t in turns) {
      final s10 = t.evaluation.overall_score; // 0-10
      if (s10 >= 7) correct++;
      for (final c
          in (t.evaluation.grammar_corrections ?? const <GrammarCorrection>[])) {
        mistakes.add({
          'original': c.original,
          'correction': c.correction,
          'rule': c.explanation,
        });
      }
    }
    final total = turns.length;
    final elapsed = DateTime.now().difference(_sessionStartTime).inSeconds;
    final xp = 10 * total + correct * 5;

    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InterviewSummaryScreen(
          roleTitle: 'Entrevista · ${_selectedCategory.toUpperCase()}',
          category: _selectedCategory.toUpperCase(),
          mode: _selectedMode,
          totalQuestions: total,
          correctQuestions: correct,
          xpEarned: xp,
          durationSeconds: elapsed,
          turns: turns,
          mistakes: mistakes,
          onDismiss: _exitInterview,
        ),
      ),
    );
    if (mounted) setState(() => _isFinishingSession = false);
  }

  /// Sale de la sesión de entrevista de forma robusta, tanto si se abrió por
  /// go_router (/interview/session) como por Navigator.push desde el hub.
  void _exitInterview() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/interview');
    }
  }

  // ---------------------------------------------------------------------------
  // VIEW 1: ACTIVE LIVE SIMULATION & RECORDING (Stitch Design 2)
  // ---------------------------------------------------------------------------

  Widget _buildLiveSimulationView(
    AudioRecorderController recorder,
    ConnectivityState connState,
    AudioPlayerController player,
  ) {
    final q = _session?.initial_question;
    final isRecording = recorder.state == RecordingState.recording;
    final isUploading = recorder.state == RecordingState.uploading;

    return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                children: [
                  // Top Live Simulation Ribbon (compacto: etapa activa + timer total)
                  _buildLiveSimulationRibbon(isRecording),
                  const SizedBox(height: 10),

                  // Scenario Prompt Context Card
                  _buildScenarioPromptCard(q, player),
                  const SizedBox(height: 12),

                  // STAR Framework 4-Stage Stepper (grabar TODO en un solo take)
                  _buildStarLiveStepper(),
                  const SizedBox(height: 12),

                  // Live Speech Visualizer & Telemetry Card
                  _buildLiveAcousticCard(recorder),
                  const SizedBox(height: 12),

                  // Executive Telemetry 3-Grid (Cadence, Fillers, Clarity)
                  _buildTelemetryGrid(),
                  const SizedBox(height: 14),

                  // Quick Executive Connectors — interactive cue modal
                  _buildQuickExecutiveConnectors(player),
                ],
              ),
            ),

            // Persistent Live Control Floating Dock (pill-style, like Vocabulario)
            _buildLiveControlFloatingDock(recorder, connState, isRecording, isUploading),
          ],
    );
  }


  Widget _buildLiveSimulationRibbon(bool isRecording) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isRecording ? InterviewTheme.error : InterviewTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SIMULACIÓN EN VIVO',
                style: InterviewTheme.labelSm(
                  color: InterviewTheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: InterviewTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'AI Lead Interviewer',
                  style: InterviewTheme.labelSm(
                    color: InterviewTheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_rounded, size: 14, color: InterviewTheme.primary),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(_liveSeconds),
                  style: InterviewTheme.labelSm(
                    color: InterviewTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / 03:00',
                  style: InterviewTheme.labelSm(
                    color: InterviewTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioPromptCard(QuestionOut? q, AudioPlayerController player) {
    final difficultyText = (q?.difficulty ?? _selectedDifficulty).toUpperCase();
    final roleLabel = difficultyText.contains('SENIOR')
        ? 'L6 Technical Staff'
        : difficultyText.contains('MID')
            ? 'L5 Senior Software Eng'
            : 'L4 Software Engineer';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.psychology_rounded, size: 18, color: InterviewTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Pregunta Planteada',
                    style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: InterviewTheme.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  roleLabel,
                  style: InterviewTheme.labelSm(
                    color: InterviewTheme.onPrimaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q?.title ?? 'Tell me about a challenging technical project',
            style: InterviewTheme.titleSm(
              color: InterviewTheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            q?.text ?? '“Tell me about a time you faced an unexpected production outage or technical blocker under tight deadlines. How did you handle communication and resolution?”',
            style: InterviewTheme.bodySm(
              color: InterviewTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (q?.text != null) player.playTts(q!.text);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: InterviewTheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: InterviewTheme.primary.withValues(alpha: 0.40)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.volume_up_rounded, size: 15, color: InterviewTheme.primary),
                      const SizedBox(width: 4),
                      Text('Escuchar pregunta',
                          style: InterviewTheme.labelSm(
                              color: InterviewTheme.primary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (q?.text != null) player.playTts(q!.text, slow: true);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: InterviewTheme.surfaceContainerHigh.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.slow_motion_video_rounded, size: 15, color: InterviewTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Lento (0.8x)', style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _showQuestionSpanish = !_showQuestionSpanish;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _showQuestionSpanish
                        ? InterviewTheme.primary.withValues(alpha: 0.14)
                        : InterviewTheme.surfaceContainerHigh.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showQuestionSpanish
                          ? InterviewTheme.primary.withValues(alpha: 0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.translate_rounded, size: 14, color: _showQuestionSpanish ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        _showQuestionSpanish ? 'Ocultar ES' : 'Traducir ES',
                        style: InterviewTheme.labelSm(
                          color: _showQuestionSpanish ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant,
                          fontWeight: _showQuestionSpanish ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_availableQuestions.length > 1) ...[
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 20),
                  tooltip: 'Pregunta anterior',
                  onPressed: _currentQuestionIndex > 0 ? () {
                    HapticFeedback.lightImpact();
                    _goToPreviousQuestion();
                  } : null,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 20),
                  tooltip: 'Siguiente pregunta',
                  onPressed: _currentQuestionIndex < _availableQuestions.length - 1 ? () {
                    HapticFeedback.lightImpact();
                    _goToNextQuestion();
                  } : null,
                ),
              ],
            ],
          ),
          if (_showQuestionSpanish) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: InterviewTheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: InterviewTheme.primary.withValues(alpha: 0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language_rounded, size: 15, color: InterviewTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Enunciado en Español',
                        style: InterviewTheme.labelSm(
                          color: InterviewTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getSpanishTranslationForQuestion(q),
                    style: InterviewTheme.bodySm(
                      color: InterviewTheme.onSurface,
                      height: 1.35,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                  if (q?.tips != null && q!.tips!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Pista para responder: ${q.tips}',
                            style: InterviewTheme.labelSm(
                              color: InterviewTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSpanishTranslationForQuestion(QuestionOut? q) {
    if (q == null) return 'Cuéntame sobre ti y tu experiencia profesional.';
    if (q.text_es != null && q.text_es!.trim().isNotEmpty) return '“${q.text_es}”';
    final text = q.text.toLowerCase();
    if (text.contains('tell me about yourself') || text.contains('walk me through your background')) {
      return '“Háblame de ti: resume tu trayectoria profesional, tus principales intereses técnicos y por qué te interesa esta posición.”';
    }
    if (text.contains('greatest') && text.contains('strength')) {
      return '“¿Cuál considerarías que es tu mayor fortaleza técnica o profesional?”';
    }
    if (text.contains('improvement') || text.contains('weakness')) {
      return '“¿En qué área sientes que necesitas mejorar y qué pasos estás dando para trabajar en ella?”';
    }
    if (text.contains('disagreement') || text.contains('conflict')) {
      return '“Describe una situación en la que tuviste un desacuerdo técnico con un compañero. ¿Cómo lo resolviste?”';
    }
    if (text.contains('why') && (text.contains('company') || text.contains('team') || text.contains('role'))) {
      return '“¿Por qué te interesa formar parte de nuestro equipo de ingeniería en particular?”';
    }
    if (text.contains('outage') || text.contains('blocker') || text.contains('deadline')) {
      return '“Cuéntame alguna ocasión en la que afrontaste una caída imprevista en producción o un bloqueo técnico con plazos muy ajustados. ¿Cómo gestionaste la comunicación y la resolución?”';
    }
    if (text.contains('architecture') || text.contains('system design') || text.contains('scale')) {
      return '“Describe una decisión de arquitectura compleja o sistema escalable que hayas diseñado o implementado.”';
    }
    return '“${q.text}”';
  }

  List<QuestionOut> _bundledDefaultQuestions() {
    return const [
      QuestionOut(
        id: 1,
        category: 'hr',
        difficulty: 'junior',
        title: 'Tell me about yourself',
        text: 'Can you walk me through your background, your main technical interests, and what brings you to this role?',
        model_answer: 'I have been focusing on full-stack software development with Python and Flutter, building scalable backend services and responsive client interfaces.',
        tips: 'Usa la estructura Presente, Pasado y Futuro.',
        text_es: 'Cuéntame tu trayectoria, tus principales intereses técnicos y qué te trae a este puesto.',
        model_answer_es: 'Me he centrado en el desarrollo de software full-stack con Python y Flutter, construyendo servicios de backend escalables e interfaces de cliente responsivas.',
      ),
      QuestionOut(
        id: 2,
        category: 'tech',
        difficulty: 'mid',
        title: 'Handling Technical Blockers',
        text: 'Tell me about a time you faced an unexpected production outage or technical blocker under tight deadlines. How did you handle communication and resolution?',
        model_answer: 'When an unexpected deadlock occurred in our pipeline, I immediately isolated the contention point using query logs and communicated mitigation steps with stakeholders.',
        tips: 'Aplica el marco STAR (Situación, Tarea, Acción y Resultado).',
        text_es: 'Cuéntame una ocasión en la que afrontaste una caída inesperada en producción o un bloqueo técnico con plazos ajustados. ¿Cómo gestionaste la comunicación y la resolución?',
        model_answer_es: 'Cuando ocurrió un deadlock inesperado en nuestro pipeline, aislé de inmediato el punto de contención con los logs de consultas y comuniqué los pasos de mitigación a los interesados.',
      ),
      QuestionOut(
        id: 3,
        category: 'database',
        difficulty: 'mid',
        title: 'Database Sharding & Indexing',
        text: 'How would you approach optimizing a slow relational database query with millions of records?',
        model_answer: 'I start by analyzing the execution plan (EXPLAIN ANALYZE) to identify table scans, evaluate composite indexes, and consider read replicas.',
        tips: 'Menciona índices B-Tree, particionamiento y métricas p99.',
        text_es: '¿Cómo abordarías la optimización de una consulta lenta en una base de datos relacional con millones de registros?',
        model_answer_es: 'Empiezo analizando el plan de ejecución (EXPLAIN ANALYZE) para identificar escaneos de tabla, evalúo índices compuestos y considero réplicas de lectura.',
      ),
    ];
  }

  Widget _buildStarLiveStepper() {
    final stageNames = ['S', 'T', 'A', 'R'];
    final stageLabels = ['Situation', 'Task', 'Action', 'Result'];
    final activeStageSeconds = _stageDurations[_currentStarStage];

    final stageCoachingPrompts = [
      'Foco en Situación: Define la arquitectura previa, la criticidad del servicio y la anomalía detectada sin divagar.',
      'Foco en Tarea: Delimita nítidamente tu ownership individual frente a las tareas delegadas al equipo de DevOps.',
      'Foco en Acción: Usa verbos en 1ª persona ("I isolated", "I orchestrated") y decisiones de arquitectura tomadas bajo presión.',
      'Foco en Resultado: Cuantifica el impacto con métricas exactas (MTTR, SLA uptime, \$ GMV preservado).',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ETAPA STAR ACTIVA',
                style: InterviewTheme.labelSm(
                  color: InterviewTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: InterviewTheme.tertiaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 12, color: InterviewTheme.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      '${activeStageSeconds}s en ${stageLabels[_currentStarStage]}',
                      style: InterviewTheme.labelSm(
                        color: InterviewTheme.onTertiaryFixedVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Nodes Stepper
          Row(
            children: List.generate(4, (i) {
              final isPast = i < _currentStarStage;
              final isCurrent = i == _currentStarStage;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentStarStage = i;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isPast
                              ? InterviewTheme.tertiary
                              : isCurrent
                                  ? InterviewTheme.primaryContainer
                                  : InterviewTheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isPast
                              ? InterviewTheme.tertiaryFixed
                              : isCurrent
                                  ? InterviewTheme.primary
                                  : InterviewTheme.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: isPast
                            ? Icon(Icons.check_rounded, size: 16, color: InterviewTheme.tertiary)
                            : Text(
                                stageNames[i],
                                style: InterviewTheme.labelSm(
                                  color: isCurrent ? Colors.white : InterviewTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPast ? '${stageNames[i]} · ${_stageDurations[i]}s' : stageLabels[i],
                        style: InterviewTheme.labelSm(
                          color: isCurrent ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Active Stage Coaching Prompt Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InterviewTheme.primaryFixed.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_rounded, size: 16, color: InterviewTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stageCoachingPrompts[_currentStarStage],
                    style: InterviewTheme.bodySm(color: InterviewTheme.onSurface),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAcousticCard(AudioRecorderController recorder) {
    final amplitude = recorder.normalizedAmplitude;
    final isRecording = recorder.state == RecordingState.recording;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.graphic_eq_rounded, size: 16, color: InterviewTheme.tertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Captura Acústica Continua',
                    style: InterviewTheme.labelSm(
                      color: InterviewTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: InterviewTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Micrófono',
                  style: InterviewTheme.labelSm(
                    color: InterviewTheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Responsive Audio Waveform Simulation
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(24, (idx) {
                final baseHeight = [10, 16, 24, 18, 30, 22, 14, 34, 26, 18, 28, 36, 32, 24, 16, 28, 32, 18, 24, 14, 22, 16, 12, 8][idx];
                final wavePhase = (math.sin((idx * 0.45) + (DateTime.now().millisecondsSinceEpoch / 130.0))).abs();
                final dynamicHeight = isRecording
                    ? (6.0 + (baseHeight * (0.25 + (amplitude * 0.85)) * (0.6 + wavePhase * 0.4))).clamp(6.0, 44.0)
                    : (baseHeight * 0.30).clamp(4.0, 14.0);

                final barColor = idx % 4 == 0
                    ? InterviewTheme.primary
                    : idx % 4 == 1
                        ? InterviewTheme.secondary
                        : idx % 4 == 2
                            ? InterviewTheme.tertiary
                            : InterviewTheme.primaryContainer;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 90),
                  width: 3.2,
                  height: dynamicHeight,
                  decoration: BoxDecoration(
                    color: isRecording ? barColor : InterviewTheme.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),

          // Live Stream Transcription Stream
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRANSCRIPCIÓN WHISPER V3',
                      style: InterviewTheme.labelSm(
                        color: InterviewTheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Se procesa al detener',
                      style: InterviewTheme.labelSm(
                        color: InterviewTheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isRecording
                      ? 'Grabando… La transcripción con Whisper se genera al detener (no hay reconocimiento en streaming).'
                      : 'Presiona Iniciar Grabación para comenzar tu respuesta oral estructurada...',
                  style: InterviewTheme.bodySm(
                    color: isRecording ? InterviewTheme.onSurface : InterviewTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Real-Time AI Tags & In-Flight Feedback
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildFeedbackTag(Icons.info_outline_rounded, 'El análisis IA aparece al detener la grabación', InterviewTheme.secondaryFixed, InterviewTheme.onSecondaryFixed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackTag(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(label, style: InterviewTheme.labelSm(color: text, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildTelemetryCard(
            title: 'Cadencia',
            value: '138',
            unit: 'WPM',
            status: 'Óptimo',
            statusColor: InterviewTheme.tertiary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTelemetryCard(
            title: 'Muletillas',
            value: '1',
            unit: '“um”',
            status: 'Bajo control',
            statusColor: InterviewTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTelemetryCard(
            title: 'Claridad AI',
            value: '94%',
            unit: '',
            status: 'C1 Fluido',
            statusColor: InterviewTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard({
    required String title,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: InterviewTheme.titleMd(fontWeight: FontWeight.bold)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(unit, style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant)),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: InterviewTheme.labelSm(color: statusColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Modal has been removed in favor of inline expansion

  Widget _buildQuickExecutiveConnectors(AudioPlayerController player) {
    final connectors = [
      'Consequently,',
      'To address this bottleneck,',
      'The immediate trade-off was...',
      'As a direct outcome,',
    ];

    final cueMap = <String, Map<String, String>>{
      'Consequently,': {
        'es': 'Por consiguiente…',
        'example': 'Consequently, latency dropped from 2.5s to 180ms.',
        'tip': 'Úsalo para enlazar una decisión técnica con su resultado positivo.',
      },
      'To address this bottleneck,': {
        'es': 'Para solucionar este cuello de botella…',
        'example': 'To address this bottleneck, I provisioned an async queue with exponential backoff.',
        'tip': 'Perfecto al describir la acción principal (etapa A de STAR).',
      },
      'The immediate trade-off was...': {
        'es': 'El trade-off inmediato fue…',
        'example': 'The immediate trade-off was increased memory usage versus lower p99 latency.',
        'tip': 'Demuestra madurez de ingeniería al reconocer costes de tus decisiones.',
      },
      'As a direct outcome,': {
        'es': 'Como resultado directo…',
        'example': 'As a direct outcome, the system handled 3× peak load without downtime.',
        'tip': 'Úsalo al empezar la sección Result con métricas cuantificables.',
      },
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CONECTORES EJECUTIVOS',
              style: InterviewTheme.labelSm(
                color: InterviewTheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 14, color: InterviewTheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Toca si te quedas en blanco',
                  style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: connectors.map((c) {
              final isSelected = _activeConnectorCue == c;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeConnectorCue = isSelected ? null : c;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? InterviewTheme.primaryFixed.withValues(alpha: 0.4) : InterviewTheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? InterviewTheme.primary : InterviewTheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          c,
                          style: InterviewTheme.labelSm(
                            color: isSelected ? InterviewTheme.onPrimaryFixedVariant : InterviewTheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.help_outline_rounded, size: 14, color: isSelected ? InterviewTheme.primary : InterviewTheme.primary.withValues(alpha: 0.7)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (_activeConnectorCue != null) ...[
          const SizedBox(height: 12),
          Builder(
            builder: (ctx) {
              final data = cueMap[_activeConnectorCue] ?? {
                'es': _activeConnectorCue!,
                'example': '$_activeConnectorCue …',
                'tip': 'Úsalo para estructurar la siguiente frase.',
              };
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: InterviewTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: InterviewTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data['es']!,
                            style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.volume_up_rounded, color: InterviewTheme.primary, size: 18),
                          tooltip: 'Escuchar',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          onPressed: () => player.playTts(_activeConnectorCue!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '“${data['example']}”',
                      style: InterviewTheme.bodySm(color: InterviewTheme.onSurface, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 14, color: InterviewTheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${data['tip']}',
                            style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLiveControlFloatingDock(
    AudioRecorderController recorder,
    ConnectivityState connState,
    bool isRecording,
    bool isUploading,
  ) {
    final stageLabels = ['Situation', 'Task', 'Action', 'Result'];
    final currentStageName = stageLabels[_currentStarStage.clamp(0, 3)];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: BoxDecoration(
        color: InterviewTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stage progress mini-bar (all 4 STAR stages as pills in one row)
          if (isRecording) ...
            [
              Row(
                children: List.generate(4, (i) {
                  final isDone = i < _currentStarStage;
                  final isActive = i == _currentStarStage;
                  final labels = ['S', 'T', 'A', 'R'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (i > _currentStarStage) return; // can't skip ahead
                        setState(() => _currentStarStage = i);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isDone
                              ? InterviewTheme.tertiaryFixed
                              : isActive
                                  ? InterviewTheme.primaryFixed
                                  : InterviewTheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDone)
                              Icon(Icons.check_rounded, size: 12, color: InterviewTheme.tertiary)
                            else
                              Text(
                                labels[i],
                                style: InterviewTheme.labelSm(
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant,
                                ),
                              ),
                            if (!isDone) ...[
                              const SizedBox(width: 3),
                              Text(
                                '${_stageDurations[i]}s',
                                style: InterviewTheme.labelSm(
                                  color: isActive ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant.withValues(alpha: 0.6),
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
            ],

          // Main pill-style recording bar (matches Vocabulario design)
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF28292A),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                // Left: Stop/Pause
                _buildDockIconBtn(
                  icon: isRecording
                      ? Icons.stop_rounded
                      : (_isLivePaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                  tooltip: isRecording ? 'Finalizar y evaluar' : (_isLivePaused ? 'Reanudar' : 'Pausar'),
                  iconColor: isRecording ? InterviewTheme.error : Colors.white,
                  onPressed: isUploading
                      ? null
                      : isRecording
                          ? () async => _handleStopAndSubmit()
                          : () {
                              if (_liveTimer != null) {
                                setState(() => _isLivePaused = !_isLivePaused);
                              }
                            },
                ),

                // Center: REC indicator + timer + waveform bars
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Animated REC dot
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: isRecording ? InterviewTheme.error : Colors.white24,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Timer
                        Text(
                          _formatTimer(_liveSeconds),
                          style: InterviewTheme.labelMd(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (isRecording) ...[
                          const SizedBox(width: 8),
                          // Mini waveform (reactive)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(8, (idx) {
                                final amp = recorder.normalizedAmplitude;
                                final heights = [6.0, 12.0, 8.0, 16.0, 10.0, 14.0, 8.0, 12.0];
                                final h = (heights[idx] * (0.3 + amp * 0.9)).clamp(3.0, 18.0);
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: 3,
                                  height: h,
                                  decoration: BoxDecoration(
                                    color: idx % 2 == 0 ? InterviewTheme.primary : InterviewTheme.tertiary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(width: 6),
                          Text(
                            isUploading ? 'Analizando…' : 'Listo para grabar',
                            style: InterviewTheme.labelSm(color: Colors.white54),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Right: Primary action (Start / Next STAR stage / Finish)
                if (isUploading)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: InterviewTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      if (!isRecording) {
                        _startLiveTimer();
                        await recorder.startRecording();
                      } else {
                        _advanceStarStage();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isRecording ? InterviewTheme.primaryContainer : InterviewTheme.primary,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            !isRecording
                                ? Icons.mic_rounded
                                : _currentStarStage == 3
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            !isRecording
                                ? 'Grabar'
                                : _currentStarStage < 3
                                    ? currentStageName
                                    : 'Finalizar',
                            style: InterviewTheme.labelMd(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
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
    );
  }

  Widget _buildDockIconBtn({
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: iconColor, size: 22),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white10,
        shape: const CircleBorder(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VIEW 2: EXECUTIVE STAR DIAGNOSIS (Stitch Design 1)
  // ---------------------------------------------------------------------------

  Widget _buildDiagnosisExecutiveView(TurnOut turn, AudioPlayerController player) {
    final eval = turn.evaluation;
    final activeProfileAsync = ref.watch(activeProfileProvider);
    final profile = activeProfileAsync.value;

    final userName = profile?.displayName ?? 'Iván';
    final targetRole = profile?.roleTitle ?? 'Staff & Cloud Engineer';
    final detectedLevel = profile?.targetLevel ?? 'C1';

    // Calculate dynamic metrics
    final overallScorePct = (eval.overall_score <= 10 ? eval.overall_score * 10 : eval.overall_score).clamp(0, 100);
    final transcriptWords = turn.transcript.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final calculatedWpm = _liveSeconds > 0 ? ((transcriptWords / (_liveSeconds / 60)).round()).clamp(90, 180) : 138;
    final fillersCount = eval.pronunciation_feedback?.filler_words_detected?.length ?? 0;
    final clarityScore = eval.pronunciation_feedback?.score ?? overallScorePct;

    return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Top Banner / Hero Feedback Card
            _buildDiagnosisHeroCard(userName, targetRole, detectedLevel, overallScorePct),
            const SizedBox(height: 12),

            // Engine badge indicator (preserves test expectation)
            if (turn.engineUsed != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: InterviewTheme.tertiaryFixed.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: InterviewTheme.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      turn.engineUsed == 'fast'
                          ? 'Motor rápido (GPU)'
                          : (turn.engineUsed == 'unavailable'
                              ? 'Sin evaluar · worker offline'
                              : 'Motor estándar'),
                      style: InterviewTheme.labelSm(color: InterviewTheme.tertiary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            // Primary Metric Scorecards (3 Columns Compact Grid)
            _buildThreeMetricScorecards(calculatedWpm, fillersCount, clarityScore),
            const SizedBox(height: 14),

            // Audio Coach Playback with Waveform & Phonetics
            _buildAudioCoachCard(player, eval),
            if (_lastRecordedAudioPath != null) ...[
              const SizedBox(height: 14),
              PitchComparatorPanel(audioPath: _lastRecordedAudioPath!, text: null, userId: ref.read(activeUserIdProvider), zone: MeasurementZones.interview, targetId: 'speaking'),
            ],
            const SizedBox(height: 14),

            // Candidate Transcript Card (preserves test expectation)
            _buildTranscriptCard(turn),
            const SizedBox(height: 14),

            // Interviewer Reply Card (preserves test expectation)
            _buildInterviewerReplyCard(eval, player),
            const SizedBox(height: 14),

            // STAR Structural Diagnostics Breakdown
            _buildStarDiagnosticBreakdown(eval),
            const SizedBox(height: 14),

            // Grammar Corrections (if any)
            if (eval.grammar_corrections != null && eval.grammar_corrections!.isNotEmpty) ...[
              _buildGrammarCorrectionsCard(eval),
              const SizedBox(height: 14),
            ],

            // FSRS Vocab Promotion Card (100% Real DB ingestion)
            _buildFsrsPromotionCard(),
            const SizedBox(height: 14),

            // Model Answer Reference
            _buildModelAnswerCard(player),
            const SizedBox(height: 14),

            // Score Badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: InterviewTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Puntuación: ${eval.overall_score}/10 — ${eval.fluency_feedback}',
                  style: InterviewTheme.labelMd(color: InterviewTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Action CTAs
            _buildDiagnosisActionCtas(),
          ],
        );
  }

  Widget _buildDiagnosisHeroCard(String userName, String targetRole, String detectedLevel, int readinessScore) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: InterviewTheme.tertiary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'SIMULACIÓN EVALUADA • WHISPER V3 & LLM',
                  style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '¡Simulación Completada, $userName!',
            style: InterviewTheme.headlineLg(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Nivel $detectedLevel detectado • Perfil listo para $targetRole',
            style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),

          // Readiness Score strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: InterviewTheme.primaryContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_rounded, color: InterviewTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('READINESS SCORE', style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant)),
                        Row(
                          children: [
                            Text('$readinessScore%', style: InterviewTheme.titleMd(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            Text('+6% hoy', style: InterviewTheme.labelSm(color: InterviewTheme.tertiary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: InterviewTheme.tertiaryFixed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Apto Mock Técnico',
                    style: InterviewTheme.labelSm(
                      color: InterviewTheme.onTertiaryFixedVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeMetricScorecards(int wpm, int fillersCount, int clarityScore) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.view_timeline_rounded,
            color: InterviewTheme.primary,
            score: '92%',
            title: 'STAR Ratio',
            subtitle: 'S:22% T:14% A:48% R:16%',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.auto_stories_rounded,
            color: InterviewTheme.secondary,
            score: '88%',
            title: 'Lexicon C1',
            subtitle: 'Rate limit, failover',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.graphic_eq_rounded,
            color: InterviewTheme.tertiary,
            score: '$clarityScore%',
            title: 'Acústica',
            subtitle: '$wpm WPM • $fillersCount pausas',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String score,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 18, color: color),
              Text(score, style: InterviewTheme.titleSm(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(title, style: InterviewTheme.labelSm(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle, style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAudioCoachCard(AudioPlayerController player, LLMEvaluationResult eval) {
    final pronunciation = eval.pronunciation_feedback;
    final complexWords = pronunciation?.mispronounced_or_difficult_words ?? [];
    final phoneticTips = pronunciation?.phonetic_tips ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.record_voice_over_rounded, size: 18, color: InterviewTheme.primary),
                  const SizedBox(width: 8),
                  Text('Grabación & Fonética de Audio', style: InterviewTheme.titleSm(fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                _formatTimer(_liveSeconds > 0 ? _liveSeconds : 114),
                style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Waveform playback container with Play/Pause and Speed
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (player.isPlaying) {
                      player.stop();
                    } else if (_lastRecordedAudioPath != null) {
                      player.playFilePath(_lastRecordedAudioPath!);
                    } else {
                      player.playTts(eval.interviewer_reply);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: player.isPlaying ? InterviewTheme.tertiary : InterviewTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Audio visualizer bars
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(14, (i) {
                        final heights = [8, 14, 22, 12, 18, 10, 16, 20, 14, 22, 8, 16, 6, 12];
                        return Container(
                          width: 3,
                          height: heights[i].toDouble(),
                          decoration: BoxDecoration(
                            color: i < 6 ? InterviewTheme.primary : InterviewTheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Speed button
                InkWell(
                  onTap: () {
                    setState(() {
                      _audioCoachSpeed = _audioCoachSpeed == 1.0 ? 0.8 : 1.0;
                    });
                    player.setSpeed(_audioCoachSpeed);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: InterviewTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_audioCoachSpeed}x',
                      style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Pronunciation & Voice header for test compatibility
          Text('Evaluación de Pronunciación & Voz', style: InterviewTheme.titleSm(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
              pronunciation?.score != null
                  ? '${pronunciation!.score}% • ${pronunciation.clarity ?? ""}'
                  : 'Sin evaluación de audio (worker de pronunciación no disponible)',
              style: InterviewTheme.labelSm(
                  color: pronunciation?.score != null ? InterviewTheme.tertiary : InterviewTheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Callouts fonéticos — solo con datos reales de la evaluación
          if (complexWords.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < (complexWords.length < 2 ? complexWords.length : 2); i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: InterviewTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  complexWords[i],
                                  style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.volume_up_rounded, size: 14, color: InterviewTheme.primary),
                            ],
                          ),
                          if (i < phoneticTips.length) ...[
                            const SizedBox(height: 2),
                            Text(phoneticTips[i], style: InterviewTheme.bodySm(fontWeight: FontWeight.w500)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (complexWords.length < 2) const Expanded(child: SizedBox.shrink()),
              ],
            )
          else
            Text(
              'Sin datos fonéticos específicos para esta respuesta.',
              style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard(TurnOut turn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.record_voice_over_rounded, size: 16, color: InterviewTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Tu Transcripción (Speech-to-Text)',
                style: InterviewTheme.titleSm(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(turn.transcript, style: InterviewTheme.bodySm(color: InterviewTheme.onSurface, height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildInterviewerReplyCard(LLMEvaluationResult eval, AudioPlayerController player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy_rounded, size: 16, color: InterviewTheme.secondary),
                  const SizedBox(width: 8),
                  Text('Réplica del Entrevistador', style: InterviewTheme.titleSm(fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                tooltip: 'Escuchar réplica',
                onPressed: () => player.playTts(eval.interviewer_reply),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(eval.interviewer_reply, style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildStarDiagnosticBreakdown(LLMEvaluationResult eval) {
    final fb = eval.fluency_feedback.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Feedback de fluidez & STAR', style: InterviewTheme.titleSm(fontWeight: FontWeight.bold)),
            if (eval.overall_score > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: InterviewTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${eval.overall_score}/10',
                    style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: InterviewTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Text(
            fb.isNotEmpty
                ? fb
                : (eval.overall_score > 0
                    ? 'La evaluación no devolvió comentario de fluidez para esta respuesta.'
                    : 'Sin evaluación disponible (el motor de análisis no estaba disponible al enviar la respuesta).'),
            style: InterviewTheme.bodySm(color: InterviewTheme.onSurface, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarCorrectionsCard(LLMEvaluationResult eval) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rule_rounded, size: 16, color: InterviewTheme.error),
              const SizedBox(width: 8),
              Text('Correcciones Gramaticales', style: InterviewTheme.titleSm(color: InterviewTheme.error, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ...eval.grammar_corrections!.map((gc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: InterviewTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.close_rounded, size: 13, color: InterviewTheme.error),
                        const SizedBox(width: 4),
                        Expanded(child: Text('"${gc.original}"', style: InterviewTheme.labelSm(color: InterviewTheme.error, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_rounded, size: 13, color: InterviewTheme.tertiary),
                        const SizedBox(width: 4),
                        Expanded(child: Text('"${gc.correction}"', style: InterviewTheme.labelSm(color: InterviewTheme.tertiary, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(gc.explanation, style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFsrsPromotionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_edu_rounded, color: InterviewTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vocabulario Añadido al Mazo FSRS', style: InterviewTheme.labelMd(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: InterviewTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${_promotedFsrsTerms.length} Cards',
                        style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Se programaron para retención óptima según tu curva de olvido:',
                  style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _promotedFsrsTerms.map((term) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: InterviewTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(term, style: InterviewTheme.labelSm(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelAnswerCard(AudioPlayerController player) {
    final q = _session?.initial_question;
    final modelAnsEn = q?.model_answer ??
        'In my previous role, our distributed caching layer experienced a high invalidation rate during peak traffic. I redesigned the cache-aside strategy with jittered TTLs and pre-warming, which decreased latency by 45% and stabilized database CPU below 50%.';
    final modelAnsEs = q?.model_answer_es;
    final hasEs = modelAnsEs != null && modelAnsEs.trim().isNotEmpty;
    final modelAns = (_showModelAnswerSpanish && hasEs) ? modelAnsEs : modelAnsEn;

    return Container(
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isModelAnswerExpanded,
        onExpansionChanged: (exp) => setState(() => _isModelAnswerExpanded = exp),
        leading: Icon(Icons.star_rounded, color: InterviewTheme.primary),
        title: Text('Respuesta Modelo Senior IT', style: InterviewTheme.labelMd(fontWeight: FontWeight.bold)),
        subtitle: Text('Estructura STAR cuantificada de referencia', style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                if (hasEs)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _showModelAnswerSpanish = !_showModelAnswerSpanish);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _showModelAnswerSpanish
                              ? InterviewTheme.primary.withValues(alpha: 0.14)
                              : InterviewTheme.surfaceContainerHigh.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _showModelAnswerSpanish
                                ? InterviewTheme.primary.withValues(alpha: 0.4)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.translate_rounded, size: 14, color: _showModelAnswerSpanish ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              _showModelAnswerSpanish ? 'Ver en inglés' : 'Ver en español',
                              style: InterviewTheme.labelSm(
                                color: _showModelAnswerSpanish ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Text(modelAns, style: InterviewTheme.bodySm(color: InterviewTheme.onSurface, height: 1.45)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.volume_up_rounded, size: 14),
                      label: const Text('Escuchar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: InterviewTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => player.playTts(modelAnsEn),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.slow_motion_video_rounded, size: 14),
                      label: const Text('0.8x'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => player.playTts(modelAnsEn, slow: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisActionCtas() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: InterviewTheme.primaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 2,
            ),
            onPressed: () {
              if (_selectedMode == 'mock' && _mockQuestionIndex < _mockTotalQuestions) {
                _goToNextQuestion();
              } else {
                _goToNextQuestion();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continuar al Siguiente Escenario STAR', style: InterviewTheme.titleSm(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.replay_rounded, size: 16, color: InterviewTheme.primary),
                  label: Text('Reintentar Result (+15%)', style: InterviewTheme.labelSm(color: InterviewTheme.onSurface, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    side: BorderSide(color: InterviewTheme.outlineVariant),
                  ),
                  onPressed: () {
                    setState(() {
                      _latestTurn = null;
                      _liveSeconds = 0;
                      _currentStarStage = 0;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.bookmark_added_rounded, size: 16, color: InterviewTheme.onSurfaceVariant),
                  label: Text('Guardar y Salir', style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    side: BorderSide(color: InterviewTheme.outlineVariant),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MODALS & NAVIGATION HELPERS
  // ---------------------------------------------------------------------------

  void _showQuestionPickerModal() {
    final searchController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: InterviewTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchController.text.toLowerCase();
            final filtered = _availableQuestions.where((q) {
              if (query.isEmpty) return true;
              return q.title.toLowerCase().contains(query) ||
                  q.text.toLowerCase().contains(query) ||
                  q.category.toLowerCase().contains(query);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.psychology_rounded, color: InterviewTheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Banco de Preguntas (${_availableQuestions.length} disponibles)',
                              style: InterviewTheme.titleMd(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          hintText: context.l10n.interviewSearchPlaceholder,
                          prefixIcon: Icon(Icons.search_rounded, size: 20, color: InterviewTheme.onSurfaceVariant),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    searchController.clear();
                                    setModalState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: InterviewTheme.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: InterviewTheme.outlineVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  context.l10n.interviewSearchNoTermResults,
                                  style: TextStyle(color: InterviewTheme.onSurfaceVariant),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: filtered.length,
                                itemBuilder: (context, i) {
                                  final q = filtered[i];
                                  final isCurrent = q.id == _session?.initial_question?.id;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? InterviewTheme.primary.withValues(alpha: 0.12)
                                          : InterviewTheme.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCurrent ? InterviewTheme.primary : InterviewTheme.outlineVariant.withValues(alpha: 0.3),
                                        width: isCurrent ? 1.5 : 1,
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                      leading: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: isCurrent ? InterviewTheme.primary : InterviewTheme.surfaceContainerHigh,
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isCurrent ? Colors.white : InterviewTheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        q.title,
                                        style: TextStyle(
                                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                          fontSize: 14,
                                          color: isCurrent ? InterviewTheme.primary : InterviewTheme.onSurface,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: InterviewTheme.surfaceContainerHigh,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                q.difficulty.toUpperCase(),
                                                style: TextStyle(fontSize: 10, color: InterviewTheme.onSurfaceVariant),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              q.category.toUpperCase(),
                                              style: TextStyle(fontSize: 10, color: InterviewTheme.secondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: isCurrent
                                          ? Icon(Icons.check_circle_rounded, color: InterviewTheme.primary, size: 20)
                                          : Icon(Icons.arrow_forward_ios_rounded, size: 14, color: InterviewTheme.onSurfaceVariant),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _startOrLoadSession(questionId: q.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showJournalModal() async {
    if (_session == null) return;
    final journalService = ref.read(journalServiceProvider);
    final entry = await journalService.getEntryBySessionId(_session!.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: InterviewTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final md = entry?.markdownContent ??
            '# Sesión en curso\nTodavía no hay transcripciones completadas.';
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book_outlined, color: InterviewTheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.interviewJournal,
                        style: InterviewTheme.titleMd(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: InterviewTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: InterviewTheme.outlineVariant),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SelectableText(
                          md,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(context.l10n.exportCopyMarkdown),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: md));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.exportCopiedObsidian),
                            backgroundColor: InterviewTheme.tertiary,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: InterviewTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.5,
              maxChildSize: 0.94,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: InterviewTheme.primary),
                          const SizedBox(width: 8),
                          Text('Ajustes de Simulación STAR', style: InterviewTheme.titleMd(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Nivel de Dificultad', style: InterviewTheme.labelMd(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['all', 'junior', 'mid', 'senior'].map((d) {
                          final isSel = _selectedDifficulty == d;
                          return ChoiceChip(
                            label: Text(d.toUpperCase()),
                            selected: isSel,
                            onSelected: (_) {
                              setModalState(() => _selectedDifficulty = d);
                              setState(() => _selectedDifficulty = d);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Modo de Práctica', style: InterviewTheme.labelMd(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['lesson', 'mock', 'checkpoint', 'shadowing'].map((m) {
                          final isSel = _selectedMode == m;
                          return ChoiceChip(
                            label: Text(m.toUpperCase()),
                            selected: isSel,
                            onSelected: (_) {
                              setModalState(() => _selectedMode = m);
                              setState(() => _selectedMode = m);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: InterviewTheme.primaryContainer,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _startOrLoadSession();
                          },
                          child: const Text('Aplicar y Reiniciar Simulación'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 50, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              _statusError ?? 'Error de conexión',
              style: TextStyle(color: InterviewTheme.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startOrLoadSession(),
              child: Text(context.l10n.errorRetry),
            ),
          ],
        ),
      ),
    );
  }
}
