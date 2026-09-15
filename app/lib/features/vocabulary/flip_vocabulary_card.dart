import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/api_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/audio/audio_player_controller.dart';
import '../../core/widgets/ai_feedback_card.dart';
import '../phonetics/hvpt_exercise_screen.dart';
import '../../core/theme/app_haptics.dart';
import 'vocabulary_screen.dart' show VocabularyItem;
import '../../core/audio/voice_selection.dart';



class FlipVocabularyCard extends ConsumerStatefulWidget {
  final VocabularyItem item;
  final bool isAddedToFsrs;
  final VoidCallback onAddToFsrs;

  const FlipVocabularyCard({
    super.key,
    required this.item,
    required this.isAddedToFsrs,
    required this.onAddToFsrs,
  });

  @override
  ConsumerState<FlipVocabularyCard> createState() => _FlipVocabularyCardState();
}

class _FlipVocabularyCardState extends ConsumerState<FlipVocabularyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool _isRecordingThis = false;
  bool _isEvaluating = false;
  PronunciationResult? _pronunciationResult;
  String? _pronTip;
  bool _tipLoading = false;
  StreamSubscription? _pronSub;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _pronSub = ref.read(pronunciationQueueProvider).onProcessed.listen((event) {
      if (mounted && event.section == 'vocabulary' && event.term == widget.item.term) {
        setState(() {
          _pronunciationResult = event.result;
        });
      }
    });
  }

  @override
  void dispose() {
    _pronSub?.cancel();
    _flipController.dispose();
    super.dispose();
  }

  void _toggleCard() {
    AppHaptics.medium();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  Future<void> _startRecordingPronunciation() async {
    AppHaptics.medium();
    final recorder = ref.read(audioRecorderProvider);
    await recorder.startRecording();
    setState(() {
      _isRecordingThis = true;
      _pronunciationResult = null;
      _pronTip = null;
      _tipLoading = false;
    });
  }

  Future<void> _stopAndCheckPronunciation() async {
    final recorder = ref.read(audioRecorderProvider);
    final audioPath = await recorder.stopRecording();
    setState(() {
      _isRecordingThis = false;
    });

    if (audioPath == null) return;

    setState(() {
      _isEvaluating = true;
    });

    final api = ref.read(apiClientProvider);
    // Evaluación centralizada (checkPronunciation + cola offline en un solo sitio).
    final out = await ref.read(pronunciationEvaluatorProvider).evaluate(
      section: 'vocabulary',
      audioPath: audioPath,
      expectedTerm: widget.item.term,
      expectedIpa: widget.item.phonetic,
      userId: ref.read(activeUserIdProvider),
      exerciseType: 'single_word',
      category: widget.item.category,
    );
    final res = out.result;
    if (out.isLive) {
      if (res.score >= 80) {
        AppHaptics.medium();
      } else {
        AppHaptics.light();
      }
    }
    // Nota + semáforo AL INSTANTE
    if (mounted) {
      setState(() {
        _isEvaluating = false;
        _pronunciationResult = res;
        _tipLoading = out.sttOk; // solo cargamos consejo si hubo evaluación válida
      });
    }
    // Consejo IA en segundo plano (no bloquea)
    if (out.sttOk) {
      api
          .getPronunciationTip(
        term: widget.item.term,
        ipa: widget.item.phonetic,
        recognized: res.recognized_text,
        score: res.score,
        wrongPhonemes: res.wrongPhonemes,
        confidence: res.confidence,
      )
          .then((t) {
        if (mounted) {
          setState(() {
            _pronTip = t;
            _tipLoading = false;
          });
        }
      });
    }
    recorder.resetToIdle();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(audioPlayerProvider);
    final isPlayingThis = player.currentlyPlayingText == widget.item.term;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final angle = _flipAnimation.value * math.pi;
        final isFront = angle < (math.pi / 2);

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(angle),
          child: isFront
              ? _buildFrontCard(player, isPlayingThis)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi), // Reverse mirror
                  child: _buildBackCard(),
                ),
        );
      },
    );
  }

  // ================= CARA A: INGLÉS, FONÉTICA, AUDIO Y PRONUNCIACIÓN =================
  Widget _buildFrontCard(AudioPlayerController player, bool isPlayingThis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: TTS Audio, Term, IPA, and FSRS bookmark
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Neural Audio Dual Speed
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isPlayingThis ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                      tooltip: context.l10n.ttsListenNativeVocab,
                      onPressed: () => player.playTts(widget.item.term, voice: AppVoices.vocabulary),
                    ),
                    IconButton(
                      icon: Icon(Icons.auto_awesome_rounded, color: TabTheme.vocabulary.accent, size: 20),
                      tooltip: 'Definición con IA',
                      onPressed: () => showAiVocabularySheet(context, ref, widget.item.term),
                    ),
                    InkWell(
                      onTap: () => player.playTts(widget.item.term, slow: true, voice: AppVoices.vocabulary),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "0.8x",
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Term, Phonetic & Part of Speech
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.term,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.item.phonetic,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "• ${widget.item.partOfSpeech}",
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick FSRS Save
              IconButton(
                icon: Icon(
                  widget.isAddedToFsrs ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                  color: widget.isAddedToFsrs ? AppTheme.success : AppTheme.primary,
                  size: 24,
                ),
                tooltip: widget.isAddedToFsrs ? "Guardada en FSRS" : "Añadir a Repaso FSRS",
                onPressed: widget.isAddedToFsrs ? null : widget.onAddToFsrs,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Definition in English
          Text(
            widget.item.definition,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Real Technical Example sentence
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: AppTheme.primary, width: 3.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "\"${widget.item.exampleSentence}\"",
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.textSecondary),
                  tooltip: context.l10n.ttsListenFullPhrase,
                  onPressed: () => player.playTts(widget.item.exampleSentence, voice: AppVoices.vocabulary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ================= SECCIÓN: PROBAR MI PRONUNCIACIÓN (MICROPHONE CHECK) =================
          _buildPronunciationSection(),
          const SizedBox(height: 12),

          // Bottom Bar: Flip Card to Spanish action
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _toggleCard,
              icon: const Icon(Icons.flip_to_back_rounded, size: 17, color: Color(0xFF38BDF8)),
              label: Text(
                context.l10n.vocabFlipCardHint,
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CARA B: ESPAÑOL, TRADUCCIÓN, DEFINICIÓN Y MNEMOTECNIA =================
  Widget _buildBackCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surface,
            AppTheme.surfaceLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Spanish badge & Return button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.translate_rounded, size: 13, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.vocabTranslationContext,
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _toggleCard,
                icon: Icon(Icons.flip_to_front_rounded, size: 16, color: AppTheme.textSecondary),
                label: Text(
                  context.l10n.actionBack,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Term in Spanish
          Text(
            widget.item.term,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Categoría: ${widget.item.category} • ${widget.item.level}",
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),

          // Spanish Definition / Meaning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.vocabDefinitionEquiv,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.item.spanishDefinition.isNotEmpty
                      ? widget.item.spanishDefinition
                      : widget.item.spanishNote,
                  style: TextStyle(fontSize: 13.5, height: 1.45, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mnemonic Tip Box (El tip para acordarse)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.vocabMnemonicTip,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.spanishNote,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bottom Bar in Back Card: FSRS button + Flip Back
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: widget.isAddedToFsrs ? null : widget.onAddToFsrs,
                icon: Icon(
                  widget.isAddedToFsrs ? Icons.check_circle_rounded : Icons.add_rounded,
                  size: 16,
                  color: widget.isAddedToFsrs ? AppTheme.success : AppTheme.textPrimary,
                ),
                label: Text(
                  widget.isAddedToFsrs ? "Guardado en FSRS" : "Añadir a FSRS",
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isAddedToFsrs ? AppTheme.success : AppTheme.textPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: widget.isAddedToFsrs ? AppTheme.success : AppTheme.border),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleCard,
                icon: const Icon(Icons.rotate_left_rounded, size: 16),
                label: Text(context.l10n.vocabBackToEnglish, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= WIDGET: SECCIÓN DE PRÁCTICA DE PRONUNCIACIÓN CON VOZ =================
  Widget _buildPronunciationSection() {
    if (_isEvaluating) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.vocabAnalyzingWhisper,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    if (_isRecordingThis) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.vocabRecordingPrompt,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _stopAndCheckPronunciation,
              icon: const Icon(Icons.stop_rounded, size: 16),
              label: Text(context.l10n.actionCheck, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result Feedback if evaluated
        if (_pronunciationResult != null) ...[
          if (_pronunciationResult!.score == -1) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Color(0xFF3B82F6), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pronunciationResult!.feedback,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6)),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _pronunciationResult!.is_match
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _pronunciationResult!.is_match
                      ? const Color(0xFF10B981).withValues(alpha: 0.4)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                ),
              ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _pronunciationResult!.is_match ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: _pronunciationResult!.is_match ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Precisión: ${_pronunciationResult!.score}%",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _pronunciationResult!.is_match
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Builder(builder: (_) {
                            final cf = _pronunciationResult!.confidence;
                            final cc = cf >= 0.8
                                ? AppTheme.success
                                : (cf >= 0.5 ? AppTheme.warning : AppTheme.error);
                            final lbl = cf >= 0.8 ? 'Fiable' : (cf >= 0.5 ? 'Media' : 'Baja');
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cc.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Container(
                                    width: 7, height: 7,
                                    decoration: BoxDecoration(color: cc, shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(lbl,
                                    style: TextStyle(
                                        fontSize: 10.5, fontWeight: FontWeight.bold, color: cc)),
                              ]),
                            );
                          }),
                          if (_pronunciationResult!.recognized_text.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Oído: \"${_pronunciationResult!.recognized_text}\"",
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _pronunciationResult!.feedback,
                        style: TextStyle(fontSize: 12, color: AppTheme.textPrimary, height: 1.3),
                      ),
                      if (_pronunciationResult!.wrongPhonemes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: _pronunciationResult!.wrongPhonemes
                              .take(6)
                              .map((w) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.error.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppTheme.error.withValues(alpha: 0.4),
                                          width: 1),
                                    ),
                                    child: Text(
                                      "/$w/",
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.error),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                      if (_tipLoading) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            SizedBox(
                                width: 12, height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: TabTheme.fsrs.accent)),
                            const SizedBox(width: 8),
                            Text('Generando consejo…',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ] else if ((_pronTip ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 13, color: TabTheme.fsrs.accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _pronTip!,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.textSecondary,
                                    height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_pronunciationResult!.wrongPhonemes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => HvptExerciseScreen(
                                  targetPhoneme: _pronunciationResult!.wrongPhonemes.first,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: TabTheme.fsrs.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: TabTheme.fsrs.accent.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.headphones_rounded, size: 14, color: TabTheme.fsrs.accent),
                                const SizedBox(width: 6),
                                Text(
                                  'Entrenar /${_pronunciationResult!.wrongPhonemes.first}/ con pares mínimos',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TabTheme.fsrs.accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 16, color: AppTheme.textSecondary),
                  tooltip: context.l10n.vocabRetryPronunciation,
                  onPressed: _startRecordingPronunciation,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
        ] else ...[
          // Default: Action button to record
          InkWell(
            onTap: _startRecordingPronunciation,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic_rounded, color: Color(0xFFFBBF24), size: 16),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.vocabTestPronunciation,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}


