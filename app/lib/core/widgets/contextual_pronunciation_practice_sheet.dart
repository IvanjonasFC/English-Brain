import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../theme/tab_theme.dart';
import '../theme/app_haptics.dart';
import '../providers/app_providers.dart';
import '../models/api_models.dart';
import '../services/measurement_service.dart';
import '../audio/audio_recorder_controller.dart';
import '../widgets/pitch_contour_chart.dart';
import '../../features/phonetics/hvpt_exercise_screen.dart';

class PronunciationPhraseItem {
  final String phrase;
  final String label;
  final String? phonetic;
  final String? translation;

  const PronunciationPhraseItem({
    required this.phrase,
    required this.label,
    this.phonetic,
    this.translation,
  });
}

/// Modal / Bottom Sheet interactivo de práctica de pronunciación con múltiples frases,
/// audio nativo Kokoro/EdgeTTS, grabación, playback alumno, scoring fonético y entonación F0.
class ContextualPronunciationPracticeSheet extends ConsumerStatefulWidget {
  final String title;
  final String category; // 'irregular_verbs', 'phrasal_verbs', 'grammar', etc.
  final List<PronunciationPhraseItem> phrases;
  final String? expectedTerm;
  final String? expectedIpa;
  final Color accentColor;
  final bool isInline;
  final bool maskTextUntilRevealed;
  final Function(double score, String phrase)? onAttemptRecorded;

  const ContextualPronunciationPracticeSheet({
    super.key,
    required this.title,
    required this.category,
    required this.phrases,
    this.expectedTerm,
    this.expectedIpa,
    this.accentColor = const Color(0xFF0D9488),
    this.isInline = false,
    this.maskTextUntilRevealed = false,
    this.onAttemptRecorded,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String category,
    required List<PronunciationPhraseItem> phrases,
    String? expectedTerm,
    String? expectedIpa,
    Color accentColor = const Color(0xFF0D9488),
    Function(double score, String phrase)? onAttemptRecorded,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ContextualPronunciationPracticeSheet(
        title: title,
        category: category,
        phrases: phrases,
        expectedTerm: expectedTerm,
        expectedIpa: expectedIpa,
        accentColor: accentColor,
        onAttemptRecorded: onAttemptRecorded,
      ),
    );
  }

  @override
  ConsumerState<ContextualPronunciationPracticeSheet> createState() =>
      _ContextualPronunciationPracticeSheetState();
}

class _ContextualPronunciationPracticeSheetState
    extends ConsumerState<ContextualPronunciationPracticeSheet> {
  int _currentPhraseIdx = 0;
  bool _isPlayingModel = false;
  bool _isPlayingUser = false;
  bool _isEvaluating = false;
  bool _isTextRevealed = false;

  String? _lastUserAudioPath;
  PronunciationResult? _lastResult;
  String? _aiTip;
  bool _isTipLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  PronunciationPhraseItem get _currentPhrase =>
      widget.phrases[_currentPhraseIdx % widget.phrases.length];

  Future<void> _playModel({bool slow = false}) async {
    setState(() => _isPlayingModel = true);
    final player = ref.read(audioPlayerProvider);
    await player.playTts(_currentPhrase.phrase, slow: slow);
    if (mounted) setState(() => _isPlayingModel = false);
  }

  Future<void> _playUserRecording() async {
    if (_lastUserAudioPath == null) return;
    setState(() => _isPlayingUser = true);
    final player = ref.read(audioPlayerProvider);
    await player.playFilePath(_lastUserAudioPath!);
    if (mounted) setState(() => _isPlayingUser = false);
  }

  Future<void> _toggleRecording() async {
    final rec = ref.read(audioRecorderProvider);
    if (rec.state == RecordingState.recording) {
      // Detener y evaluar
      AppHaptics.medium();
      final path = await rec.stopRecording();
      if (path != null && mounted) {
        setState(() {
          _lastUserAudioPath = path;
          _isEvaluating = true;
          _lastResult = null;
          _aiTip = null;
        });
        await _evaluateAudio(path);
      }
    } else {
      // Iniciar grabación
      AppHaptics.light();
      setState(() {
        _lastResult = null;
        _aiTip = null;
      });
      await rec.startRecording();
    }
  }

  Future<void> _evaluateAudio(String path) async {
    final phrase = _currentPhrase.phrase;
    final ipa = _currentPhrase.phonetic ?? widget.expectedIpa;

    final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
      section: widget.category,
      audioPath: path,
      expectedTerm: phrase,
      expectedIpa: ipa,
      userId: ref.read(activeUserIdProvider),
      exerciseType: 'guided_sentence',
      category: widget.category,
    );
    if (!mounted) return;
    final res = out.result;
    if (out.isLive) {
      final ok = out.sttOk;
      setState(() {
        _isEvaluating = false;
        _lastResult = ok
            ? res
            : PronunciationResult(
                expected_term: res.expected_term,
                recognized_text: res.recognized_text,
                score: res.score,
                is_match: res.is_match,
                feedback: 'No se detectó audio claro. Intenta hablar más cerca del micrófono.',
                tip: res.tip,
                sttOk: false,
                wrongPhonemes: res.wrongPhonemes,
              );
      });

      if (ok) {
        widget.onAttemptRecorded?.call(res.score.toDouble(), phrase);
        if (res.score > 0) {
          final uid = ref.read(activeUserIdProvider);
          final target = (widget.expectedTerm != null && widget.expectedTerm!.trim().isNotEmpty) ? widget.expectedTerm! : phrase;
          // ignore: unawaited_futures
          ref.read(measurementServiceProvider).record(userId: uid, zone: widget.category, targetType: 'phrase', targetId: target, metricKey: MeasurementMetrics.pronunciationGop, value: res.score.toDouble(), audioUrl: res.audioUrl, label: target);
        }
        _fetchAiTip(phrase, ipa, res);
      }
    } else {
      // Sin conexión: la grabación quedó en la cola offline. Se mantiene el flujo
      // (avanza) como antes. NOTA: aquí se reporta 80 para no bloquear el avance;
      // es el "fake-80" a revisar si no se quiere que offline cuente como acierto.
      setState(() {
        _isEvaluating = false;
        _lastResult = PronunciationResult(
          expected_term: phrase,
          recognized_text: '',
          score: -1,
          is_match: false,
          sttOk: false,
          engineUsed: 'offline_queue',
          feedback: 'Grabación guardada sin conexión. Se evaluará al reconectar.',
        );
      });
      // Score centinela -1: los catálogos NO lo cuentan como acierto (score >= 65)
      // y los runners de sesión avanzan igual (ignoran el score).
      widget.onAttemptRecorded?.call(-1.0, phrase);
    }
  }

  Future<void> _fetchAiTip(String phrase, String? ipa, PronunciationResult res) async {
    setState(() => _isTipLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final tip = await api.getPronunciationTip(
        term: phrase,
        ipa: ipa,
        recognized: res.recognized_text,
        score: res.score,
        wrongPhonemes: res.wrongPhonemes,
        confidence: res.confidence,
      ).timeout(const Duration(seconds: 18));

      if (!mounted) return;
      setState(() {
        _isTipLoading = false;
        if (tip != null && tip.trim().isNotEmpty) {
          _aiTip = tip.trim();
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isTipLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = ref.watch(audioRecorderProvider);
    final isRecording = rec.state == RecordingState.recording;
    final phrase = _currentPhrase;
    final totalPhrases = widget.phrases.length;

    return Container(
      padding: EdgeInsets.only(
        left: widget.isInline ? 16 : 20,
        right: widget.isInline ? 16 : 20,
        top: widget.isInline ? 16 : 20,
        bottom: widget.isInline ? 16 : (MediaQuery.of(context).viewInsets.bottom + 24),
      ),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: widget.isInline ? BorderRadius.circular(18) : const BorderRadius.vertical(top: Radius.circular(24)),
        border: widget.isInline ? Border.all(color: widget.accentColor.withValues(alpha: 0.25), width: 1.5) : null,
      ),
      child: SingleChildScrollView(
        physics: widget.isInline ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isInline) ...[
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TabTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Header Row
            Row(
              children: [
                Icon(Icons.graphic_eq_rounded, color: widget.accentColor, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pronunciation Practice',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        widget.title,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TabTheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(_currentPhraseIdx % totalPhrases) + 1}/$totalPhrases',
                    style: GoogleFonts.firaCode(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
                if (!widget.isInline) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Active Phrase Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      color: widget.accentColor,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  phrase.label,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: widget.accentColor),
                                ),
                                if (widget.maskTextUntilRevealed)
                                  InkWell(
                                    onTap: () {
                                      AppHaptics.light();
                                      setState(() => _isTextRevealed = !_isTextRevealed);
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _isTextRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                            size: 14,
                                            color: widget.accentColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _isTextRevealed ? 'Ocultar' : 'Ver frase',
                                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: widget.accentColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (widget.maskTextUntilRevealed && !_isTextRevealed) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.headphones_rounded, size: 18, color: widget.accentColor),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Escucha el audio nativo y reproduce lo que oigas sin leer.',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: widget.accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Text(
                                '“${phrase.phrase}”',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                              if (phrase.phonetic != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  phrase.phonetic!,
                                  style: GoogleFonts.firaCode(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                              ],
                              if (phrase.translation != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  phrase.translation!,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Controls Row 1: Hear Model + Slow + Next Phrase
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPlayingModel ? null : () => _playModel(slow: false),
                    icon: Icon(_isPlayingModel ? Icons.graphic_eq_rounded : Icons.volume_up_rounded, size: 16),
                    label: const Text('Hear model'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPlayingModel ? null : () => _playModel(slow: true),
                    icon: const Icon(Icons.slow_motion_video_rounded, size: 16),
                    label: const Text('Slow (0.8x)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (totalPhrases > 1) ...[
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: () {
                      AppHaptics.light();
                      setState(() {
                        _currentPhraseIdx++;
                        _lastResult = null;
                        _lastUserAudioPath = null;
                        _aiTip = null;
                      });
                    },
                    icon: const Icon(Icons.skip_next_rounded, size: 20),
                    tooltip: 'Siguiente frase',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Controls Row 2: Record + Playback
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isEvaluating ? null : _toggleRecording,
                    icon: _isEvaluating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 18),
                    label: Text(
                      isRecording ? 'Detener y Evaluar' : (_isEvaluating ? 'Analizando con IA...' : 'Record (Grabar)'),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecording ? const Color(0xFFEF4444) : widget.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (_lastUserAudioPath != null) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _isPlayingUser ? null : _playUserRecording,
                    icon: Icon(_isPlayingUser ? Icons.volume_up_rounded : Icons.play_arrow_rounded, size: 16),
                    label: const Text('My recording'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),

            // Aviso OFFLINE (neutral, no cuenta como acierto)
            if (_lastResult != null &&
                _lastResult!.engineUsed == 'offline_queue') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: Color(0xFF6B7280), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Guardado sin conexión. Se evaluará automáticamente al '
                        'reconectar (no cuenta como acierto).',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: const Color(0xFF374151)),
                      ),
                    ),
                  ],
                ),
              ),
            ]
            // Evaluation Results Box
            else if (_lastResult != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lastResult!.score >= 70
                      ? const Color(0xFFF0FDF4)
                      : (_lastResult!.score >= 50 ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _lastResult!.score >= 70
                        ? const Color(0xFFBBF7D0)
                        : (_lastResult!.score >= 50 ? const Color(0xFFFDE68A) : const Color(0xFFFECACA)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _lastResult!.score >= 70 ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          color: _lastResult!.score >= 70
                              ? const Color(0xFF16A34A)
                              : (_lastResult!.score >= 50 ? const Color(0xFFD97706) : const Color(0xFFDC2626)),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Análisis de pronunciación: ${_lastResult!.score}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _lastResult!.score >= 70
                                ? const Color(0xFF14532D)
                                : (_lastResult!.score >= 50 ? const Color(0xFF92400E) : const Color(0xFF991B1B)),
                          ),
                        ),
                      ],
                    ),
                    if (_lastResult!.recognized_text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Te escuché: "${_lastResult!.recognized_text}"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textPrimary),
                      ),
                    ],
                    if (_lastResult!.wrongPhonemes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Sonidos a pulir:', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _lastResult!.wrongPhonemes.map((ph) {
                          final clean = ph.replaceAll('/', '').trim();
                          return ActionChip(
                            label: Text('/$clean/'),
                            labelStyle: GoogleFonts.firaCode(fontSize: 11, fontWeight: FontWeight.bold),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HvptExerciseScreen(targetPhoneme: clean),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    if (_isTipLoading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: widget.accentColor)),
                          const SizedBox(width: 6),
                          Text('Generando tip de pronunciación...', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ] else if (_aiTip != null) ...[
                      const SizedBox(height: 8),
                      Text('Tip: $_aiTip', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textPrimary, height: 1.35)),
                    ] else if (_lastResult!.feedback.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(_lastResult!.feedback, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textPrimary)),
                    ],
                  ],
                ),
              ),

              // Pitch & Intonation contour chart
              if (_lastUserAudioPath != null) ...[
                PitchComparatorPanel(
                  audioPath: _lastUserAudioPath!,
                  text: phrase.phrase,
                  userId: ref.read(activeUserIdProvider),
                  zone: widget.category,
                  targetId: widget.expectedTerm ?? phrase.phrase,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
