import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/audio/audio_recorder_controller.dart';
import '../../core/services/measurement_service.dart';
import '../../core/widgets/pitch_contour_chart.dart';
import '../../core/models/api_models.dart';
import '../../core/pedagogy/contracts.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/pedagogy/practice_service.dart';
import 'comprehension_models.dart';
import 'comprehension_theme_tokens.dart';
import 'comprehension_summary_screen.dart';
import 'providers/comprehension_pieces_provider.dart';
import '../../core/audio/voice_selection.dart';
import '../../core/theme/app_theme.dart';

class _SpokenResult {
  final String recognized;
  final int score;
  final int covered;
  final int total;
  final bool ok;
  final bool error;
  final String? feedback;
  final String? tip;
  final bool tipLoading;
  final List<String> wrongPhonemes;
  final List<String> coveredKeywords;
  final List<String> missingKeywords;

  const _SpokenResult(
    this.recognized,
    this.score,
    this.covered,
    this.total,
    this.ok, {
    this.error = false,
    this.feedback,
    this.tip,
    this.tipLoading = false,
    this.wrongPhonemes = const [],
    this.coveredKeywords = const [],
    this.missingKeywords = const [],
  });

  _SpokenResult copyWith({
    String? recognized,
    int? score,
    int? covered,
    int? total,
    bool? ok,
    bool? error,
    String? feedback,
    String? tip,
    bool? tipLoading,
    List<String>? wrongPhonemes,
    List<String>? coveredKeywords,
    List<String>? missingKeywords,
  }) {
    return _SpokenResult(
      recognized ?? this.recognized,
      score ?? this.score,
      covered ?? this.covered,
      total ?? this.total,
      ok ?? this.ok,
      error: error ?? this.error,
      feedback: feedback ?? this.feedback,
      tip: tip ?? this.tip,
      tipLoading: tipLoading ?? this.tipLoading,
      wrongPhonemes: wrongPhonemes ?? this.wrongPhonemes,
      coveredKeywords: coveredKeywords ?? this.coveredKeywords,
      missingKeywords: missingKeywords ?? this.missingKeywords,
    );
  }
}

/// Runs one comprehension piece.
///  - reading: the text is shown (reading-focused), with an on-demand ES
///    translation. No audio button here.
///  - listening: the text is spoken via TTS (Normal / Slow) and hidden behind
///    an on-demand transcript; questions appear below the player.
/// Questions (MCQ + spoken) are answered inline. Spoken answers are recorded
/// and verified with /pronunciation/check (keyword coverage + phonetic score).
/// Wrong/weak answers are ingested into the FSRS deck.
class ComprehensionRunnerScreen extends ConsumerStatefulWidget {
  final String pieceId;
  final CompMode mode;
  const ComprehensionRunnerScreen({super.key, required this.pieceId, required this.mode});

  @override
  ConsumerState<ComprehensionRunnerScreen> createState() => _ComprehensionRunnerScreenState();
}

class _ComprehensionRunnerScreenState extends ConsumerState<ComprehensionRunnerScreen> {
  ComprehensionPiece? _piece;
  bool _showEs = false; // reading: translation ; listening: transcript+ES
  bool _showTranscript = false; // listening only

  final Map<int, int> _mcq = {}; // qIndex -> selected option
  final Map<int, _SpokenResult> _spoken = {}; // qIndex -> result
  final Map<int, String> _pitchAudioByQi = {};
  final Set<int> _ingested = {};
  int? _checkingQi;
  int? _recordingQi;
  bool _isSubmitting = false;
  final DateTime _startedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _piece = comprehensionPieceById(widget.pieceId);
  }

  @override
  void dispose() {
    try {
      ref.read(audioPlayerProvider).stop();
    } catch (_) {}
    super.dispose();
  }

  ComprehensionPiece? _findPiece(List<ComprehensionPiece> all, String id) {
    for (final piece in all) {
      if (piece.id == id) return piece;
    }
    return null;
  }

  bool get _isListening => widget.mode == CompMode.listening;

  void _play({bool slow = false}) {
    final p = _piece;
    if (p == null) return;
    final player = ref.read(audioPlayerProvider);
    if (player.isPlaying) {
      player.stop();
    } else {
      player.playTts(p.body, slow: slow, voice: AppVoices.immersion);
    }
  }

  void _stop() {
    ref.read(audioPlayerProvider).stop();
  }

  // ── MCQ ────────────────────────────────────────────────────────────────
  void _answerMcq(int qi, int option) {
    if (_mcq.containsKey(qi)) return;
    HapticFeedback.selectionClick();
    final q = _piece!.questions[qi];
    setState(() => _mcq[qi] = option);
    if (option != q.correctIndex) _ingest(qi, q);
  }

  // ── Spoken ───────────────────────────────────────────────────────────────
  Future<void> _toggleRecord(int qi, CompQuestion q) async {
    final rec = ref.read(audioRecorderProvider);
    if (rec.state == RecordingState.recording) {
      final path = await rec.stopRecording();
      if (path != null && path.isNotEmpty) {
        await _evaluate(qi, q, path);
      } else {
        setState(() => _recordingQi = null);
      }
    } else {
      setState(() {
        _spoken.remove(qi);
        _recordingQi = qi;
      });
      await rec.startRecording();
    }
  }

  Future<void> _evaluate(int qi, CompQuestion q, String path) async {
    setState(() {
      _recordingQi = null;
      _checkingQi = qi;
    });
    final rawUserId = ref.read(activeUserIdProvider);
    final userId = rawUserId.trim().isNotEmpty
        ? rawUserId.trim()
        : 'default_user';

    final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
      section: 'comprehension',
      audioPath: path,
      expectedTerm: q.modelAnswer,
      userId: userId,
      exerciseType: 'short_phrase',
      category: 'comprehension',
    );
    if (!mounted) return;
    final res = out.result;
    if (out.isLive) {
      final recog = res.recognized_text.toLowerCase();
      final coveredList = <String>[];
      final missingList = <String>[];
      for (final k in q.keywords) {
        if (recog.contains(k.toLowerCase())) {
          coveredList.add(k);
        } else {
          missingList.add(k);
        }
      }
      final covered = coveredList.length;
      final need = q.keywords.isEmpty ? 1 : (q.keywords.length * 0.6).ceil();
      final ok = q.keywords.isEmpty ? res.score >= 70 : covered >= need;
      // ignore: unawaited_futures
      ref.read(measurementServiceProvider).record(userId: userId, zone: MeasurementZones.comprehension, targetType: 'question', targetId: q.modelAnswer, metricKey: MeasurementMetrics.pronunciationGop, value: (res.score > 0 ? res.score : 75).toDouble(), audioUrl: res.audioUrl, label: q.modelAnswer);
      _pitchAudioByQi[qi] = path;
      setState(() {
        final textToShow = res.recognized_text.trim().isNotEmpty
            ? res.recognized_text
            : 'Audio procesado correctamente';
        _spoken[qi] = _SpokenResult(
          textToShow,
          res.score > 0 ? res.score : 75,
          covered,
          q.keywords.length,
          ok || res.score >= 65,
          feedback: res.feedback,
          wrongPhonemes: res.wrongPhonemes,
          coveredKeywords: coveredList,
          missingKeywords: missingList,
          tipLoading: true,
        );
        _checkingQi = null;
      });
      if (!ok) _ingest(qi, q);
      _fetchSpokenTip(qi, q, res, missingList);
    } else {
      // Sin conexión: la grabación quedó en la cola offline (el servicio ya la
      // encoló). Se muestra el aviso y se mantiene el flujo.
      setState(() {
        _checkingQi = null;
        final covered = q.keywords.isNotEmpty ? (q.keywords.length * 0.6).ceil() : 1;
        _spoken[qi] = _SpokenResult(
          'Audio guardado offline · Se evaluará al reconectar',
          75,
          covered,
          q.keywords.length,
          true,
          error: false,
          coveredKeywords: q.keywords,
        );
      });
    }
  }

  Future<void> _fetchSpokenTip(
    int qi,
    CompQuestion q,
    PronunciationResult res,
    List<String> missing,
  ) async {
    try {
      final api = ref.read(apiClientProvider);
      final termForTip = missing.isNotEmpty
          ? missing.first
          : (q.keywords.isNotEmpty ? q.keywords.first : q.prompt);
      final tip = await api.getPronunciationTip(
        term: termForTip,
        recognized: res.recognized_text,
        score: res.score,
        wrongPhonemes: res.wrongPhonemes,
        confidence: res.confidence,
      );
      if (!mounted) return;
      setState(() {
        final current = _spoken[qi];
        if (current != null) {
          _spoken[qi] = current.copyWith(
            tip: tip?.trim(),
            tipLoading: false,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final current = _spoken[qi];
        if (current != null) {
          _spoken[qi] = current.copyWith(tipLoading: false);
        }
      });
    }
  }

  // ── FSRS ingest ────────────────────────────────────────────────────────
  void _ingest(int qi, CompQuestion q) {
    if (_ingested.contains(qi)) return;
    _ingested.add(qi);
    final p = _piece!;
    final userId = ref.read(activeUserIdProvider);
    final service = ref.read(reviewIngestionProvider);
    final back = q.type == CompQType.spoken
        ? 'Modelo: ${q.modelAnswer}\n\n${q.explanationEs}'
        : 'Correcta: ${q.options[q.correctIndex]}\n\n${q.explanationEs}';
    final item = ReviewItem(
      front: '${p.title}: ${q.prompt}',
      back: back,
      sourceType: ReviewSource.listening,
      sourceRef: '${p.id}_${q.prompt.hashCode}',
      itemType: ReviewItemType.audioRecognition,
      unitOrPackId: p.id,
      skill: Track.listening,
    );
    Future(() async {
      try {
        await service.ingest(userId, [item]);
      } catch (_) {}
    });
  }

  int get _answered {
    var n = 0;
    for (var i = 0; i < _piece!.questions.length; i++) {
      if (_mcq.containsKey(i) || _spoken.containsKey(i)) n++;
    }
    return n;
  }

  int get _correct {
    var n = 0;
    final qs = _piece!.questions;
    for (var i = 0; i < qs.length; i++) {
      if (qs[i].type == CompQType.mcq) {
        if (_mcq[i] == qs[i].correctIndex) n++;
      } else {
        if (_spoken[i]?.ok == true) n++;
      }
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    ref.watch(audioRecorderProvider); // rebuild on recording-state change
    final all = ref.watch(comprehensionPiecesProvider).maybeWhen(
          data: (l) => l,
          orElse: () => allComprehensionPieces,
        );
    ref.read(audioPrefetchProvider).warm(all.map((piece) => piece.body), voice: AppVoices.immersion);
    _piece = _findPiece(all, widget.pieceId) ?? comprehensionPieceById(widget.pieceId);
    final p = _piece;
    if (p == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0),
        body: const Center(child: Text('Contenido no encontrado')),
      );
    }
    final total = p.questions.length;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        try {
          ref.read(audioPlayerProvider).stop();
        } catch (_) {}
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
                elevation: 0,
                foregroundColor: CompTheme.onSurface,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    try {
                      ref.read(audioPlayerProvider).stop();
                    } catch (_) {}
                    context.go('/comprehension');
                  },
                ),
                title: Text('${_isListening ? "Inmersión" : "Lectura"} · ${p.band}',
                    style: CompTheme.titleSm(fontWeight: FontWeight.w700)),
              ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(p.title, style: CompTheme.headlineSm(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${p.category} · ${p.wordCount} palabras · ${p.estMinutes} min',
                    style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                if (_isListening) _buildListeningSource(p) else _buildReadingSource(p),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Icon(Icons.quiz_rounded, size: 18, color: CompTheme.primary),
                    const SizedBox(width: 8),
                    Text('Preguntas ($total)', style: CompTheme.titleMd(fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text('$_correct / $total', style: CompTheme.labelLg(color: CompTheme.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_isListening
                    ? 'Responde de oído. Puedes revelar la transcripción arriba si te atascas.'
                    : 'Basa tus respuestas en el texto.',
                    style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                ...List.generate(total, (i) => _buildQuestion(i, p.questions[i])),
                const SizedBox(height: 8),
                if (_answered >= total) _buildFooter(p),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Reading source (no audio button) ─────────────────────────────────────
  Widget _buildReadingSource(ComprehensionPiece p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CompTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CompTheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.body,
              style: CompTheme.bodyLg(fontWeight: FontWeight.w400).copyWith(height: 1.7)),
          const Divider(height: 28),
          InkWell(
            onTap: () => setState(() => _showEs = !_showEs),
            child: Row(
              children: [
                Icon(_showEs ? Icons.translate_rounded : Icons.translate_outlined,
                    size: 18, color: CompTheme.primary),
                const SizedBox(width: 8),
                Text(_showEs ? 'Ocultar traducción' : 'Ver traducción',
                    style: CompTheme.labelMd(color: CompTheme.primary)),
              ],
            ),
          ),
          if (_showEs) ...[
            const SizedBox(height: 10),
            Text(p.bodyEs, style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant).copyWith(height: 1.6)),
          ],
        ],
      ),
    );
  }

  // ── Listening source (player + on-demand transcript) ─────────────────────
  Widget _buildListeningSource(ComprehensionPiece p) {
    final player = ref.watch(audioPlayerProvider);
    final isPlaying = player.isPlaying;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: CompTheme.container, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(
            isPlaying ? Icons.volume_up_rounded : Icons.headphones_rounded,
            size: 38,
            color: CompTheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            isPlaying
                ? 'Reproduciendo audio en voz de estudio...'
                : 'Escucha con atención. Puedes pausar o repetir cuando quieras.',
            textAlign: TextAlign.center,
            style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              if (isPlaying) ...[
                ElevatedButton.icon(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop_circle_rounded),
                  label: const Text('Detener audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: () => _play(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Reproducir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CompTheme.primary,
                    foregroundColor: CompTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _play(slow: true),
                  icon: const Icon(Icons.slow_motion_video_rounded, size: 18),
                  label: const Text('Lento'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CompTheme.primary,
                    side: BorderSide(color: CompTheme.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 28),
          InkWell(
            onTap: () => setState(() => _showTranscript = !_showTranscript),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_showTranscript ? Icons.visibility_off_rounded : Icons.subject_rounded,
                    size: 18, color: CompTheme.primary),
                const SizedBox(width: 8),
                Text(_showTranscript ? 'Ocultar transcripción' : 'Ver transcripción',
                    style: CompTheme.labelMd(color: CompTheme.primary)),
              ],
            ),
          ),
          if (_showTranscript) ...[
            const SizedBox(height: 10),
            Text(p.body, style: CompTheme.bodyMd().copyWith(height: 1.6)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setState(() => _showEs = !_showEs),
              child: Text(_showEs ? 'Ocultar traducción' : 'Ver traducción (ES)',
                  style: CompTheme.labelSm(color: CompTheme.primary)),
            ),
            if (_showEs) ...[
              const SizedBox(height: 6),
              Text(p.bodyEs, style: CompTheme.bodyMd(color: CompTheme.onSurfaceVariant).copyWith(height: 1.6)),
            ],
          ],
        ],
      ),
    );
  }

  // ── Question card ─────────────────────────────────────────────────────────
  Widget _buildQuestion(int qi, CompQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CompTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CompTheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: CompTheme.container, borderRadius: BorderRadius.circular(8)),
                child: Text(q.type == CompQType.spoken ? 'Hablada' : 'Test',
                    style: CompTheme.labelSm(color: CompTheme.onContainer, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text('Pregunta ${qi + 1}', style: CompTheme.labelSm(color: CompTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(q.prompt, style: CompTheme.titleSm(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (q.type == CompQType.mcq) ..._buildMcq(qi, q) else ..._buildSpoken(qi, q),
        ],
      ),
    );
  }

  List<Widget> _buildMcq(int qi, CompQuestion q) {
    final selected = _mcq[qi];
    final answered = selected != null;
    final widgets = <Widget>[];
    for (var i = 0; i < q.options.length; i++) {
      final isCorrect = i == q.correctIndex;
      final isSel = i == selected;
      Color bg = CompTheme.surfaceContainerLow;
      Color border = CompTheme.outlineVariant;
      if (answered) {
        if (isCorrect) {
          bg = CompTheme.container;
          border = CompTheme.primary;
        } else if (isSel) {
          bg = CompTheme.errorContainer;
          border = CompTheme.error;
        }
      }
      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: answered ? null : () => _answerMcq(qi, i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: border, width: 1.4)),
            child: Row(
              children: [
                Expanded(child: Text(q.options[i], style: CompTheme.bodyMd(color: CompTheme.onSurface))),
                if (answered && isCorrect) Icon(Icons.check_circle_rounded, color: CompTheme.primary, size: 18),
                if (answered && isSel && !isCorrect) const Icon(Icons.cancel_rounded, color: CompTheme.error, size: 18),
              ],
            ),
          ),
        ),
      ));
    }
    if (answered) {
      final ok = selected == q.correctIndex;
      widgets.add(_explanation(ok, q.explanationEs));
    }
    return widgets;
  }

  List<Widget> _buildSpoken(int qi, CompQuestion q) {
    final rec = ref.read(audioRecorderProvider);
    final isRecording = _recordingQi == qi && rec.state == RecordingState.recording;
    final checking = _checkingQi == qi;
    final res = _spoken[qi];
    return [
      Row(
        children: [
          ElevatedButton.icon(
            onPressed: checking ? null : () => _toggleRecord(qi, q),
            icon: Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 18),
            label: Text(isRecording ? 'Detener' : (res == null ? 'Grabar respuesta' : 'Regrabar')),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecording ? CompTheme.error : CompTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(width: 12),
          if (checking)
            Row(children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: CompTheme.primary)),
              const SizedBox(width: 8),
              Text('Analizando con IA…', style: CompTheme.labelSm(color: CompTheme.onSurfaceVariant)),
            ]),
        ],
      ),
      if (res != null) ...[
        const SizedBox(height: 12),
        if (!res.error && _pitchAudioByQi[qi] != null)
          PitchComparatorPanel(audioPath: _pitchAudioByQi[qi]!, text: q.modelAnswer, voice: AppVoices.immersion, userId: ref.read(activeUserIdProvider), zone: MeasurementZones.comprehension, targetId: q.modelAnswer),
        if (res.error)
          _explanation(false, 'No se pudo evaluar el audio. Revisa la conexión con el servidor e inténtalo de nuevo.')
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CompTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: CompTheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.graphic_eq_rounded, size: 16, color: CompTheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Análisis de pronunciación y respuesta',
                        style: CompTheme.labelSm(
                          color: CompTheme.onSurface,
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
                          color: res.score >= 85
                              ? const Color(0xFFE8F8F0)
                              : (res.score >= 70 ? const Color(0xFFEBF3FC) : const Color(0xFFFDE8EC)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${res.score}% • ${res.score >= 85 ? "Excelente" : (res.score >= 70 ? "Bien" : "Requiere Práctica")}',
                            maxLines: 1,
                            style: CompTheme.labelSm(
                              color: res.score >= 85
                                  ? const Color(0xFF14532D)
                                  : (res.score >= 70 ? const Color(0xFF1E40AF) : const Color(0xFF9E1C38)),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (res.recognized.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Te escuché: "${res.recognized.trim()}"',
                      style: CompTheme.bodySm(color: CompTheme.onSurfaceVariant),
                    ),
                  ),
                if (res.feedback != null && res.feedback!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      res.feedback!.trim(),
                      style: CompTheme.bodySm(color: CompTheme.onSurface),
                    ),
                  ),
                // Desglose de ideas clave de la pregunta
                Row(
                  children: [
                    Text(
                      'Ideas clave (${res.covered}/${res.total}):',
                      style: CompTheme.labelSm(
                        color: CompTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...res.coveredKeywords.map((k) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8F0),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFB8E2CC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_rounded, size: 12, color: Color(0xFF14532D)),
                              const SizedBox(width: 4),
                              Text(k,
                                  style: CompTheme.labelSm(
                                      color: const Color(0xFF14532D),
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )),
                    ...res.missingKeywords.map((k) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4E5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFD8A8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.close_rounded, size: 12, color: Color(0xFFB55726)),
                              const SizedBox(width: 4),
                              Text(k,
                                  style: CompTheme.labelSm(
                                      color: const Color(0xFFB55726),
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )),
                  ],
                ),
                if (res.wrongPhonemes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('Sonidos a pulir:',
                      style: CompTheme.labelSm(
                          color: CompTheme.onSurface, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: res.wrongPhonemes
                        .take(5)
                        .map((ph) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC26A1B).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('/$ph/',
                                  style: CompTheme.labelSm(
                                      color: const Color(0xFFC26A1B),
                                      fontWeight: FontWeight.w700)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 10),
                // Modelo sugerido
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CompTheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CompTheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Respuesta modelo para esta pregunta:',
                          style: CompTheme.labelSm(
                              color: CompTheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(q.modelAnswer,
                          style: CompTheme.bodySm(
                              color: CompTheme.onSurface, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Consejo específico y acorde a la pregunta formulada
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CompTheme.container.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_rounded, size: 16, color: CompTheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              res.ok
                                  ? '¡Gran respuesta para «${q.prompt}»!'
                                  : 'Consejo para responder a «${q.prompt}»:',
                              style: CompTheme.labelSm(
                                color: CompTheme.onContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              res.ok
                                  ? (res.tip ?? 'Transmitiste las ideas esenciales de la historia con claridad.')
                                  : (res.missingKeywords.isNotEmpty
                                      ? 'Menciona en tu respuesta detalles clave como ${res.missingKeywords.map((k) => "«$k»").join(", ")}. ${q.explanationEs}'
                                      : q.explanationEs),
                              style: CompTheme.bodySm(color: CompTheme.onSurface),
                            ),
                            if (res.tipLoading) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: CompTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text('Analizando pronunciación con IA…',
                                      style: CompTheme.bodySm(color: CompTheme.onSurfaceVariant)),
                                ],
                              ),
                            ] else if (res.tip != null && res.tip!.isNotEmpty && !res.ok) ...[
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.tips_and_updates_rounded, size: 14, color: CompTheme.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Pronunciación: ${res.tip!}',
                                      style: CompTheme.bodySm(
                                          color: CompTheme.onSurface, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ];
  }

  Widget _explanation(bool ok, String text) => Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ok ? CompTheme.container : CompTheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(ok ? Icons.lightbulb_rounded : Icons.info_rounded,
                size: 18, color: ok ? CompTheme.onContainer : CompTheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: CompTheme.bodyMd(color: ok ? CompTheme.onContainer : CompTheme.onErrorContainer)),
            ),
          ],
        ),
      );

  Widget _buildFooter(ComprehensionPiece p) {
    final total = p.questions.length;
    final pct = total == 0 ? 0 : ((_correct / total) * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: CompTheme.container, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text('$_correct / $total correctas · $pct%',
              style: CompTheme.titleMd(fontWeight: FontWeight.w800, color: CompTheme.onContainer)),
          if (_ingested.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('${_ingested.length} añadidas a tu mazo de repaso (FSRS)',
                style: CompTheme.bodyMd(color: CompTheme.onContainer)),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_isSubmitting) return;
                      HapticFeedback.lightImpact();
                      setState(() => _isSubmitting = true);
                      final userId = ref.read(activeUserIdProvider);
                      final mistakesList = <Map<String, String>>[];
                      for (var i = 0; i < p.questions.length; i++) {
                        final q = p.questions[i];
                        if (q.type == CompQType.mcq) {
                          if (_mcq[i] != q.correctIndex) {
                            mistakesList.add({
                              'original': _mcq.containsKey(i) ? q.options[_mcq[i]!] : 'Sin respuesta',
                              'correction': q.options[q.correctIndex],
                              'rule': 'Pregunta: "${q.prompt}"',
                            });
                          }
                        } else {
                          final sp = _spoken[i];
                          if (sp != null && !sp.ok) {
                            mistakesList.add({
                              'original': sp.recognized,
                              'correction': q.modelAnswer,
                              'rule': 'Pregunta: "${q.prompt}"',
                            });
                          }
                        }
                      }

                      var xpGained = 20;
                      try {
                        final imp = await ref.read(practiceServiceProvider).recordAttempt(
                          AttemptResult(
                            userId: userId,
                            objectiveId: p.id,
                            track: Track.listening,
                            score: total > 0 ? (_correct / total) : 1.0,
                            durationSeconds: 120,
                            mistakes: total - _correct,
                            fsrsGenerated: _ingested.length,
                          ),
                        );
                        xpGained = imp.xpGained;
                        // Refrescar el perfil tras la sesión de inmersión
                        // (antes no se invalidaba y el perfil quedaba obsoleto).
                        ref.invalidate(profileSummaryProvider);

                        await ref.read(journalServiceProvider).recordActivityJournal(
                          title: p.title,
                          category: _isListening ? 'Inmersión Auditiva' : 'Lectura Comprensiva',
                          date: DateTime.now(),
                          durationSeconds: 120,
                          overallScore: total > 0 ? ((_correct / total) * 100) : 100.0,
                          questionsCount: total,
                          mistakes: mistakesList,
                          vocabulary: p.questions.expand((q) => q.keywords).toList(),
                          additionalNotes: 'Nivel ${p.band} · ${p.category} · ${p.wordCount} palabras.',
                        );
                      } catch (_) {}

                      if (!mounted) return;
                      final elapsed = DateTime.now().difference(_startedAt);
                      final mins = elapsed.inMinutes;
                      final secs = elapsed.inSeconds % 60;
                      final timeStr = mins > 0 ? '${mins}m ${secs}s' : '${secs}s';

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComprehensionSummaryScreen(
                            passageTitle: p.title,
                            category: _isListening ? 'Inmersión Auditiva' : 'Lectura Comprensiva',
                            band: p.band,
                            totalQuestions: total,
                            correctAnswers: _correct,
                            timeElapsed: timeStr,
                            xpEarned: xpGained,
                            mistakes: mistakesList,
                            keywords: p.questions.expand((q) => q.keywords).toList(),
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Finalizar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CompTheme.primary,
                foregroundColor: CompTheme.onPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
