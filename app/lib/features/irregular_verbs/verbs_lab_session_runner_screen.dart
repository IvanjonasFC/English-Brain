import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/contextual_pronunciation_practice_sheet.dart';
import 'models/irregular_verb.dart';
import 'data/irregular_verbs_data.dart';
import 'providers/irregular_verbs_provider.dart';

enum LabExerciseType {
  listenDistinguish, // 2 steps
  recallForm, // 3 steps
  sentenceBuilder, // 2 steps
  errorCorrection, // 1 step
  shadowRepeat, // 1 step
  speakingUse, // 1 step
}

class LabStepItem {
  final LabExerciseType type;
  final IrregularVerb verb;
  final String prompt;
  final String? audioText;
  final String expectedAnswer;
  final List<String> options;
  final String explanation;
  final String? sentenceContext;
  final String? starPrompt;
  final List<String>? starChips;

  const LabStepItem({
    required this.type,
    required this.verb,
    required this.prompt,
    this.audioText,
    required this.expectedAnswer,
    required this.options,
    required this.explanation,
    this.sentenceContext,
    this.starPrompt,
    this.starChips,
  });
}

class VerbsLabSessionRunnerScreen extends ConsumerStatefulWidget {
  final String? mode; // 'route' | 'v2' | 'v3' | 'mistakes' | 'listening' | 'speaking'

  const VerbsLabSessionRunnerScreen({super.key, this.mode});

  @override
  ConsumerState<VerbsLabSessionRunnerScreen> createState() => _VerbsLabSessionRunnerScreenState();
}

class _VerbsLabSessionRunnerScreenState extends ConsumerState<VerbsLabSessionRunnerScreen> {
  List<LabStepItem> _steps = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswerSubmitted = false;
  String? _selectedOption;
  bool _isAudioPlaying = false;
  bool _speakingEvaluated = false;
  final List<IrregularVerb> _sessionVerbs = [];
  final Set<String> _consolidatedVerbs = {};
  final Set<String> _fsrsMistakeVerbs = {};

  final Color _accentColor = const Color(0xFF0D9488); // Teal Tecnológico C1

  @override
  void initState() {
    super.initState();
    _buildSessionSteps();
  }

  void _buildSessionSteps() {
    final state = ref.read(verbsLabNotifierProvider);
    List<IrregularVerb> pool = List.from(IrregularVerbsData.getVerbsByRoute(state.activeCefrRoute));
    if (pool.isEmpty) pool = List.from(IrregularVerbsData.verbs);
    pool.shuffle(Random());

    final selectedVerbs = pool.take(6).toList();
    _sessionVerbs.clear();
    _sessionVerbs.addAll(selectedVerbs);
    ref.read(audioPrefetchProvider).warm(
      selectedVerbs.expand((v) => [v.v1, v.v2, v.v3]),
    );
    final steps = <LabStepItem>[];

    // Step 1: Listen & Distinguish (1)
    if (selectedVerbs.isNotEmpty) {
      final v = selectedVerbs[0];
      final isV2 = Random().nextBool();
      final targetForm = isV2 ? v.v2 : v.v3;
      final wrongForms = <String>{v.v1, isV2 ? v.v3 : v.v2, '${v.v1}ed', '${v.v1}en'}
          .where((f) => f != targetForm)
          .toList()
        ..shuffle(Random());
      final opts = <String>{targetForm, ...wrongForms.take(3)}.toList()..shuffle(Random());
      steps.add(
        LabStepItem(
          type: LabExerciseType.listenDistinguish,
          verb: v,
          prompt: 'Escucha el audio y selecciona la forma exacta que has oído:',
          audioText: targetForm,
          expectedAnswer: targetForm,
          options: opts,
          explanation:
              'Has escuchado "$targetForm" (${isV2 ? 'Past Simple' : 'Past Participle'} de ${v.v1}). Secuencia completa: ${v.v1} (${v.ipaV1}) → ${v.v2} (${v.ipaV2}) → ${v.v3} (${v.ipaV3}). Patrón: ${v.group.label}.',
        ),
      );
    }

    // Step 2: Recall Form (1) - Past Simple
    if (selectedVerbs.isNotEmpty) {
      final v = selectedVerbs[0];
      final rawOpts = <String>{v.v2, v.v1, '${v.v1}ed', v.v3, '${v.v1}d'}
          .where((opt) => opt.isNotEmpty)
          .toList();
      final opts = rawOpts.take(4).toList()..shuffle(Random());
      steps.add(
        LabStepItem(
          type: LabExerciseType.recallForm,
          verb: v,
          prompt: 'Completa la frase con la forma de Pasado Simple (Past Simple):',
          sentenceContext: v.examplePastSentence.replaceAll(v.v2, '________'),
          expectedAnswer: v.v2,
          options: opts,
          explanation:
              'Past Simple: Usamos "${v.v2}" (${v.ipaV2}) para acciones finalizadas en un momento concreto. Frase modelo: "${v.examplePastSentence}". ${v.commonMistake != null ? "Cuidado con el error común: ${v.commonMistake}." : ""}',
        ),
      );
    }

    // Step 3: Recall Form (2) - Past Participle
    if (selectedVerbs.length > 1) {
      final v = selectedVerbs[1];
      final rawOpts = <String>{v.v3, v.v1, '${v.v1}ed', v.v2, '${v.v1}ing'}
          .where((opt) => opt.isNotEmpty)
          .toList();
      final opts = rawOpts.take(4).toList()..shuffle(Random());
      steps.add(
        LabStepItem(
          type: LabExerciseType.recallForm,
          verb: v,
          prompt: 'Completa la frase en Present Perfect con el Participio Pasado (Past Participle):',
          sentenceContext: v.exampleParticipleSentence.replaceAll(v.v3, '________'),
          expectedAnswer: v.v3,
          options: opts,
          explanation:
              'Participio Pasado: En Present Perfect y Pasiva usamos have/has + "${v.v3}" (${v.ipaV3}). Frase técnica: "${v.exampleParticipleSentence}". Patrón: ${v.group.label}.',
        ),
      );
    }

    // Step 4: Listen & Distinguish (2)
    if (selectedVerbs.length > 2) {
      final v = selectedVerbs[2];
      final isV1 = Random().nextBool();
      final targetForm = isV1 ? v.v1 : v.v2;
      final rawOpts = <String>{targetForm, isV1 ? v.v2 : v.v1, v.v3, '${v.v1}ing'}
          .where((opt) => opt != targetForm)
          .toList();
      final opts = <String>{targetForm, ...rawOpts.take(3)}.toList()..shuffle(Random());
      steps.add(
        LabStepItem(
          type: LabExerciseType.listenDistinguish,
          verb: v,
          prompt: 'Distingue entre Infinitivo / Presente y Pasado Simple:',
          audioText: targetForm,
          expectedAnswer: targetForm,
          options: opts,
          explanation:
              'Audio reproducido: "$targetForm". Fonética precisa: ${isV1 ? v.ipaV1 : v.ipaV2}. Observa la apertura vocálica para diferenciar claramente el tiempo verbal en reuniones.',
        ),
      );
    }

    // Step 5: Sentence Builder (1) - Garantizar opciones únicas y relevantes
    if (selectedVerbs.length > 2) {
      final v = selectedVerbs[2];
      final correctSentence = v.examplePastSentence;
      final distractor1 = correctSentence.replaceAll(v.v2, '${v.v1}ed');
      final distractor2 = correctSentence.replaceAll(v.v2, v.v1);
      final distractor3 = (v.v2 != v.v3)
          ? correctSentence.replaceAll(v.v2, v.v3)
          : correctSentence.replaceAll(v.v2, '${v.v1}ing');
      
      final uniqueOptions = <String>{correctSentence, distractor1, distractor2, distractor3}
          .where((s) => s.isNotEmpty)
          .toList()
        ..shuffle(Random());

      steps.add(
        LabStepItem(
          type: LabExerciseType.sentenceBuilder,
          verb: v,
          prompt: '¿Qué opción estructura correctamente la acción en Pasado Simple?',
          sentenceContext: 'Español: "${v.spanish}" (Acción técnica finalizada)',
          expectedAnswer: correctSentence,
          options: uniqueOptions.take(3).toList(),
          explanation:
              'Estructura correcta: "$correctSentence". En Pasado Simple empleamos la forma irregular "${v.v2}" (${v.ipaV2}). ${v.usageTip ?? ""}',
        ),
      );
    }

    // Step 6: Error Correction (1)
    if (selectedVerbs.length > 3) {
      final v = selectedVerbs[3];
      final wrongVerb = v.commonMistake != null ? v.commonMistake!.split('->').first.trim() : '${v.v1}ed';
      final wrongSentence = v.examplePastSentence.replaceAll(v.v2, wrongVerb);
      final rawOpts = <String>{v.v2, wrongVerb, v.v1, v.v3}.toList()..shuffle(Random());
      steps.add(
        LabStepItem(
          type: LabExerciseType.errorCorrection,
          verb: v,
          prompt: 'Detecta el error común en esta frase y selecciona la corrección correcta:',
          sentenceContext: 'Frase con error: "$wrongSentence"',
          expectedAnswer: v.v2,
          options: rawOpts,
          explanation:
              'Corrección: "${v.examplePastSentence}". El verbo "${v.v1}" es irregular (${v.v1} → ${v.v2} → ${v.v3}), por lo que nunca se regulariza con "-ed" ($wrongVerb).',
        ),
      );
    }

    // Step 7: Recall Form (3) - Contexto Técnico STAR
    if (selectedVerbs.length > 3) {
      final v = selectedVerbs[3];
      final rawOpts = <String>{v.v2, v.v3, v.v1, '${v.v1}ed'}.toList()..shuffle(Random());
      steps.add(
        LabStepItem(
          type: LabExerciseType.recallForm,
          verb: v,
          prompt: 'Selecciona la forma adecuada para esta situación de entrega técnica:',
          sentenceContext: v.examplePastSentence.replaceAll(v.v2, '________'),
          expectedAnswer: v.v2,
          options: rawOpts,
          explanation:
              'Forma requerida: "${v.v2}" (${v.ipaV2}). Contexto STAR profesional: ${v.starContext ?? v.examplePastSentence}.',
        ),
      );
    }

    // Step 8: Sentence Builder (2) - Garantizar que NUNCA haya opciones duplicadas cuando v2 == v3
    if (selectedVerbs.length > 4) {
      final v = selectedVerbs[4];
      final correctSentence = v.exampleParticipleSentence;
      final distractor1 = correctSentence.replaceAll(v.v3, v.v1);
      final distractor2 = correctSentence.replaceAll(v.v3, '${v.v1}ed');
      final distractor3 = (v.v2 != v.v3)
          ? correctSentence.replaceAll(v.v3, v.v2)
          : correctSentence.replaceAll(' have ', ' had been ').replaceAll(' were ', ' was ');

      final uniqueOptions = <String>{correctSentence, distractor1, distractor2, distractor3}
          .where((s) => s != correctSentence || s == correctSentence)
          .toSet()
          .toList()
        ..shuffle(Random());

      steps.add(
        LabStepItem(
          type: LabExerciseType.sentenceBuilder,
          verb: v,
          prompt: 'Elige la estructura correcta en Present Perfect / Pasiva:',
          sentenceContext: 'Acción completada con impacto directo en el presente del proyecto.',
          expectedAnswer: correctSentence,
          options: uniqueOptions.take(3).toList(),
          explanation:
              'En Present Perfect empleamos have/has + Participio (${v.v3}): "$correctSentence". Pronunciación del participio: ${v.ipaV3}.',
        ),
      );
    }

    // Step 9: Shadow & Repeat (1) - Fonética y Entonación
    if (selectedVerbs.length > 4) {
      final v = selectedVerbs[4];
      steps.add(
        LabStepItem(
          type: LabExerciseType.shadowRepeat,
          verb: v,
          prompt: 'Entrenamiento de Shadowing: Escucha la frase nativa, imita el ritmo y evalúa tu pronunciación.',
          audioText: v.examplePastSentence,
          expectedAnswer: 'repeat_ok',
          options: ['¡Listo! He practicado la repetición oral'],
          explanation:
              'Frase modelo: "${v.examplePastSentence}". Patrón de acentuación: ${v.stressSeparation}. Enlace y consonante final: ${v.ipaV2}.',
        ),
      );
    }

    // Step 10: Speaking Use (Mini STAR Prompt)
    if (selectedVerbs.isNotEmpty) {
      final v = selectedVerbs[0];
      steps.add(
        LabStepItem(
          type: LabExerciseType.speakingUse,
          verb: v,
          prompt: 'Mini STAR Speaking: Responde oralmente integrando "${v.v2}" (${v.ipaV2}) o "${v.v3}" (${v.ipaV3}):',
          starPrompt: v.starContext ?? 'Describe an achievement or technical decision where you used "${v.v2}".',
          starChips: [
            'In my previous project, I ${v.v2}...',
            'We have ${v.v3} a robust solution...',
            'To resolve this incident, I ${v.v2}...',
          ],
          expectedAnswer: 'speaking_ok',
          options: ['Respuesta registrada y evaluada con éxito'],
          explanation:
              '¡Excelente aplicación! Has conectado "${v.v2}" en un contexto comunicativo estructurado según el método STAR.',
        ),
      );
    }

    setState(() {
      _steps = steps;
      _currentIndex = 0;
      _score = 0;
      _isAnswerSubmitted = false;
      _selectedOption = null;
    });

    _autoplayAudioIfApplicable();
  }

  void _autoplayAudioIfApplicable() {
    if (_currentIndex < _steps.length) {
      final step = _steps[_currentIndex];
      if (step.type == LabExerciseType.listenDistinguish || step.type == LabExerciseType.shadowRepeat) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _playTts(step.audioText ?? step.verb.v1);
        });
      }
    }
  }

  Future<void> _playTts(String text, {bool slow = false}) async {
    setState(() => _isAudioPlaying = true);
    final player = ref.read(audioPlayerProvider);
    await player.playTts(text, slow: slow);
    if (mounted) setState(() => _isAudioPlaying = false);
  }

  void _submitAnswer(String option) {
    if (_isAnswerSubmitted) return;
    final step = _steps[_currentIndex];
    final isCorrect = (step.type == LabExerciseType.shadowRepeat || step.type == LabExerciseType.speakingUse) ||
        (option == step.expectedAnswer);

    if (isCorrect) {
      AppHaptics.medium();
      _score++;
      _consolidatedVerbs.add(step.verb.v1);
    } else {
      AppHaptics.error();
      _fsrsMistakeVerbs.add(step.verb.v1);
    }

    // Record attempt in provider & Drift FSRS
    String exerciseTypeStr = 'form_recall';
    if (step.type == LabExerciseType.listenDistinguish) exerciseTypeStr = 'listening';
    if (step.type == LabExerciseType.sentenceBuilder) exerciseTypeStr = 'sentence_usage';
    if (step.type == LabExerciseType.shadowRepeat) exerciseTypeStr = 'pronunciation';
    if (step.type == LabExerciseType.speakingUse) exerciseTypeStr = 'speaking';

    ref.read(verbsLabNotifierProvider.notifier).recordAttempt(
          verbId: step.verb.id,
          exerciseType: exerciseTypeStr,
          isSuccess: isCorrect,
          expectedForm: step.expectedAnswer,
          actualForm: option,
          contextSentence: step.sentenceContext,
        );

    setState(() {
      _selectedOption = option;
      _isAnswerSubmitted = true;
    });
  }

  void _nextStep() {
    if (_currentIndex + 1 < _steps.length) {
      setState(() {
        _currentIndex++;
        _isAnswerSubmitted = false;
        _selectedOption = null;
        _speakingEvaluated = false;
      });
      _autoplayAudioIfApplicable();
    } else {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(title: const Text('Verbs Lab')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentIndex >= _steps.length) {
      return _buildCompletionScreen();
    }

    final step = _steps[_currentIndex];
    final progress = (_currentIndex + 1) / _steps.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paso ${_currentIndex + 1} de ${_steps.length}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
                Text(
                  _getExerciseTypeName(step.type),
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: _accentColor),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: TabTheme.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Exercise Card
            _buildExerciseCard(step),
            const SizedBox(height: 20),

            // Options / Actions
            if (step.type == LabExerciseType.shadowRepeat)
              _buildShadowingControls(step)
            else if (step.type == LabExerciseType.speakingUse)
              _buildSpeakingControls(step)
            else
              ...step.options.map((opt) => _buildOptionTile(opt, step)),

            // Explanation & Next Button
            if (_isAnswerSubmitted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF99F6E4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.explanation,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF134E4A), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _currentIndex + 1 < _steps.length ? 'Siguiente Ejercicio →' : 'Ver Resultados de Sesión',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(LabStepItem step) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step.verb.v1.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: _accentColor),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${step.verb.spanish})',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const Spacer(),
              if (step.audioText != null)
                IconButton.filledTonal(
                  onPressed: () => _playTts(step.audioText!),
                  icon: Icon(
                    _isAudioPlaying ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _accentColor.withValues(alpha: 0.12),
                    foregroundColor: _accentColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.prompt,
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          if (step.sentenceContext != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TabTheme.surfaceContainerHigh),
              ),
              child: Text(
                step.sentenceContext!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (step.starPrompt != null) ...[
            const SizedBox(height: 12),
            Text(
              step.starPrompt!,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(String opt, LabStepItem step) {
    final isSelected = _selectedOption == opt;
    final isCorrect = opt == step.expectedAnswer;

    Color bgColor = TabTheme.surfaceContainerLowest;
    Color borderColor = TabTheme.surfaceContainerHigh;
    Color textColor = AppTheme.textPrimary;

    if (_isAnswerSubmitted) {
      if (isCorrect) {
        bgColor = const Color(0xFFECFDF5);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF065F46);
      } else if (isSelected) {
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFF991B1B);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: _isAnswerSubmitted ? null : () => _submitAnswer(opt),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  opt,
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),
              if (_isAnswerSubmitted && isCorrect)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
              else if (_isAnswerSubmitted && isSelected)
                const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShadowingControls(LabStepItem step) {
    return ContextualPronunciationPracticeSheet(
      key: ValueKey('shadow_inline_${step.verb.id}_$_currentIndex'),
      title: 'Shadowing: ${step.verb.v1} (${step.verb.v2} / ${step.verb.v3})',
      category: 'irregular_verbs',
      expectedTerm: step.verb.v2,
      expectedIpa: step.verb.ipaV2,
      accentColor: _accentColor,
      isInline: true,
      maskTextUntilRevealed: true,
      phrases: [
        PronunciationPhraseItem(
          phrase: step.verb.examplePastSentence,
          label: 'Past Simple (${step.verb.v2})',
          phonetic: step.verb.ipaV2,
          translation: step.verb.spanish,
        ),
        PronunciationPhraseItem(
          phrase: step.verb.exampleParticipleSentence,
          label: 'Past Participle (${step.verb.v3})',
          phonetic: step.verb.ipaV3,
        ),
      ],
      onAttemptRecorded: (score, phrase) {
        if (!_speakingEvaluated) {
          setState(() => _speakingEvaluated = true);
          _submitAnswer('repeat_ok');
        }
      },
    );
  }

  Widget _buildSpeakingControls(LabStepItem step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (step.starChips != null && step.starChips!.isNotEmpty) ...[
          Text('Frases de ayuda estructuradas (STAR):', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: step.starChips!
                .map((chip) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF99F6E4)),
                      ),
                      child: Text(chip, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
        ],
        ContextualPronunciationPracticeSheet(
          key: ValueKey('star_inline_${step.verb.id}_$_currentIndex'),
          title: 'Mini STAR: ${step.verb.v1} (${step.verb.v2} / ${step.verb.v3})',
          category: 'irregular_verbs',
          expectedTerm: step.verb.v2,
          expectedIpa: step.verb.ipaV2,
          accentColor: _accentColor,
          isInline: true,
          phrases: [
            if (step.starChips != null && step.starChips!.isNotEmpty)
              ...step.starChips!.map((c) => PronunciationPhraseItem(
                    phrase: c,
                    label: 'Estructura STAR',
                    phonetic: step.verb.ipaV2,
                  ))
            else
              PronunciationPhraseItem(
                phrase: step.verb.examplePastSentence,
                label: 'Past Simple',
                phonetic: step.verb.ipaV2,
              ),
          ],
          onAttemptRecorded: (score, phrase) {
            if (!_speakingEvaluated) {
              setState(() => _speakingEvaluated = true);
              _submitAnswer('speaking_ok');
            }
          },
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    final pct = (_score / _steps.length * 100).round();
    final userProfileAsync = ref.watch(profileSummaryProvider);
    final profileData = userProfileAsync.asData?.value;
    final userName = profileData?.profile.displayName ?? 'Iván';
    final streak = profileData?.streakDays ?? 5;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: TabTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentColor.withValues(alpha: 0.28), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                              const SizedBox(width: 5),
                              Text(
                                'SESIÓN COMPLETADA',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF065F46),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$pct% Precisión',
                          style: GoogleFonts.firaCode(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: pct >= 80 ? const Color(0xFF059669) : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¡Excelente trabajo, $userName!',
                      style: GoogleFonts.plusJakartaSans(fontSize: 21, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Has completado los 10 pasos multimodales de Verbs Lab consolidando formas, discriminación auditiva y uso en respuestas STAR.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // AI Coach Tip Card (En primer plano arriba)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF99F6E4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology_rounded, size: 22, color: Color(0xFF0D9488)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Executive Coach · Consejo de Transferencia',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'En tus entrevistas técnicas o daily standups, usa Past Simple (${_sessionVerbs.take(2).map((v) => v.v2).join(", ")}) para decisiones concretas cerradas y Present Perfect (have + ${_sessionVerbs.take(2).map((v) => v.v3).join(", ")}) para el estado actual de tus despliegues o sistemas.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF134E4A),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Metrics Grid (2x2)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Precisión Global',
                      value: '$pct%',
                      subtext: '$_score de ${_steps.length} aciertos',
                      icon: Icons.track_changes_rounded,
                      color: const Color(0xFF0D9488),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Formas Dominadas',
                      value: '${_consolidatedVerbs.length}',
                      subtext: 'Verbos integrados',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Sincronizados FSRS',
                      value: '${_fsrsMistakeVerbs.length}',
                      subtext: 'Repaso en 12h',
                      icon: Icons.sync_rounded,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Claridad Fonética',
                      value: '95%',
                      subtext: 'Contrastes vocálicos',
                      icon: Icons.spatial_audio_off_rounded,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Franja de XP & Racha
              _buildXpStreakStrip(streak),
              const SizedBox(height: 18),

              // Desglose detallado de verbos practicados
              Text(
                'DESGLOSE DE VERBOS TRABAJADOS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ..._sessionVerbs.map((v) {
                final isConsolidated = _consolidatedVerbs.contains(v.v1);
                final hasError = _fsrsMistakeVerbs.contains(v.v1);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TabTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasError
                          ? const Color(0xFFFDE68A)
                          : isConsolidated
                              ? const Color(0xFFA7F3D0)
                              : TabTheme.surfaceContainerHigh,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                v.v1.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${v.spanish})',
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: hasError ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hasError ? 'Repaso FSRS' : 'Consolidado',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: hasError ? const Color(0xFF92400E) : const Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${v.v1} (${v.ipaV1}) → ${v.v2} (${v.ipaV2}) → ${v.v3} (${v.ipaV3})',
                        style: GoogleFonts.firaCode(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ejemplo técnico: "${v.examplePastSentence}"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: TabTheme.surfaceContainerLowest,
          border: Border(top: BorderSide(color: TabTheme.surfaceContainerHigh)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (_fsrsMistakeVerbs.isNotEmpty) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppHaptics.light();
                      context.pushReplacement('/irregular-verbs/session?mode=mistakes');
                    },
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('Repasar Fallos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      side: const BorderSide(color: Color(0xFFD97706)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppHaptics.medium();
                    ref.invalidate(profileSummaryProvider);
                    context.pop();
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 20),
                  label: Text('Volver a Verbs Lab', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.firaCode(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getExerciseTypeName(LabExerciseType type) {
    switch (type) {
      case LabExerciseType.listenDistinguish:
        return 'Discriminación Auditiva';
      case LabExerciseType.recallForm:
        return 'Recuperación Pasado / Participio';
      case LabExerciseType.sentenceBuilder:
        return 'Construcción en Frase';
      case LabExerciseType.errorCorrection:
        return 'Corrección de Error';
      case LabExerciseType.shadowRepeat:
        return 'Shadowing y Ritmo';
      case LabExerciseType.speakingUse:
        return 'Mini STAR Speaking';
    }
  }

  Widget _buildXpStreakStrip(int streak) {
    final xpEarned = _score * 5 + 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 4),
                Text(
                  '+$xpEarned XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFDC2626)),
                const SizedBox(width: 4),
                Text(
                  '$streak días racha',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Sesión validada',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}
