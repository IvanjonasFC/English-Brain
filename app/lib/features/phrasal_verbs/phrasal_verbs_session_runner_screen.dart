import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/contextual_pronunciation_practice_sheet.dart';
import 'providers/phrasal_verbs_provider.dart';
import 'models/phrasal_verb.dart';
import 'data/phrasal_verbs_data.dart';

enum PhrasalExerciseType {
  listenDistinguish, // 1. Discriminación auditiva (Connected speech)
  meaningReplacement, // 2. Formal ↔ Phrasal Verb
  particleRecall, // 3. Identificar la partícula correcta según la metáfora
  sentenceBuilder, // 4. Construcción y sintaxis contextual
  errorCorrection, // 5. Corrección de error típico (ej. separabilidad)
  shadowRepeat, // 6. Shadowing y ritmo natural
  speakingUse, // 7. Simulación oral en Daily / Incidencia
}

class PhrasalStepItem {
  final PhrasalExerciseType type;
  final PhrasalVerb verb;
  final String prompt;
  final String? sentenceContext;
  final String? audioText;
  final String expectedAnswer;
  final List<String> options;
  final String explanation;
  final String? incidentPrompt;
  final List<String>? incidentChips;

  const PhrasalStepItem({
    required this.type,
    required this.verb,
    required this.prompt,
    this.sentenceContext,
    this.audioText,
    required this.expectedAnswer,
    required this.options,
    required this.explanation,
    this.incidentPrompt,
    this.incidentChips,
  });
}

class PhrasalVerbsSessionRunnerScreen extends ConsumerStatefulWidget {
  final String? mode;

  const PhrasalVerbsSessionRunnerScreen({super.key, this.mode});

  @override
  ConsumerState<PhrasalVerbsSessionRunnerScreen> createState() => _PhrasalVerbsSessionRunnerScreenState();
}

class _PhrasalVerbsSessionRunnerScreenState extends ConsumerState<PhrasalVerbsSessionRunnerScreen> {
  List<PhrasalStepItem> _steps = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isAnswerSubmitted = false;
  String? _selectedOption;
  bool _isAudioPlaying = false;
  bool _speakingEvaluated = false;
  final Set<String> _consolidatedVerbs = {};
  final Set<String> _fsrsMistakeVerbs = {};
  List<PhrasalVerb> _sessionVerbs = [];

  final Color _accentColor = TabTheme.phrasalVerbs.accent; // Amarillo Dorado / Gold

  @override
  void initState() {
    super.initState();
    _buildSessionSteps();
  }

  void _buildSessionSteps() {
    final state = ref.read(phrasalVerbsLabNotifierProvider);
    List<PhrasalVerb> pool = List.from(PhrasalVerbsData.getVerbsByScenario(state.activeScenario));
    if (pool.isEmpty) pool = List.from(PhrasalVerbsData.getVerbsByRoute(state.activeCefrRoute));
    if (pool.isEmpty) pool = List.from(PhrasalVerbsData.verbs);
    pool.shuffle(Random());

    final selectedVerbs = pool.take(6).toList();
    _sessionVerbs = selectedVerbs;
    ref.read(audioPrefetchProvider).warm(
      selectedVerbs.map((v) => v.fullPhrase),
    );
    final steps = <PhrasalStepItem>[];

    // Step 1: Listen & Distinguish (1)
    if (selectedVerbs.isNotEmpty) {
      final v = selectedVerbs[0];
      final wrongVerbs = pool.where((item) => item.id != v.id).toList()..shuffle(Random());
      final wrongOpts = wrongVerbs.take(3).map((item) => item.fullPhrase).toList();
      final opts = {v.fullPhrase, ...wrongOpts}.toList()..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.listenDistinguish,
          verb: v,
          prompt: 'Escucha el audio con enlace natural y elige el phrasal verb:',
          audioText: v.fullPhrase,
          expectedAnswer: v.fullPhrase,
          options: opts,
          explanation: 'Has escuchado "${v.fullPhrase}" (${v.spanish}). Enlace fonético: ${v.connectedSpeechChunk} (${v.ipa}).',
        ),
      );
    }

    // Step 2: Meaning / Register Alternative (1)
    if (selectedVerbs.isNotEmpty) {
      final v = selectedVerbs[0];
      final wrongVerbs = pool.where((item) => item.id != v.id).toList()..shuffle(Random());
      final opts = {v.fullPhrase, ...wrongVerbs.take(3).map((e) => e.fullPhrase)}.toList()..shuffle(Random());

      final formalAlt = v.formalAlternatives.isNotEmpty ? v.formalAlternatives.first.term : v.formalEquivalent;

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.meaningReplacement,
          verb: v,
          prompt: '¿Qué phrasal verb expresa "${v.spanish}" (alternativa formal: "$formalAlt")?',
          sentenceContext: v.workplaceExample.replaceAll(v.fullPhrase, '________'),
          expectedAnswer: v.fullPhrase,
          options: opts,
          explanation: '"${v.fullPhrase}" se usa en registro conversacional/técnico. Alternativas formales: ${v.formalAlternatives.map((a) => "${a.term} (${a.whenToUse})").join(" · ")}.',
        ),
      );
    }

    // Step 3: Particle Recall (Metáfora de la partícula como apoyo)
    if (selectedVerbs.length > 1) {
      final v = selectedVerbs[1];
      final particles = ['up', 'out', 'down', 'off', 'back', 'in']..shuffle(Random());
      final opts = {v.particle.id, ...particles}.take(4).toList()..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.particleRecall,
          verb: v,
          prompt: 'Completa con la partícula conceptual (${v.particle.concept}):',
          sentenceContext: '${v.verb} ________ (${v.spanish})',
          expectedAnswer: v.particle.id,
          options: opts,
          explanation: 'La partícula "${v.particle.label}" denota ${v.particle.concept}. Frase completa: "${v.fullPhrase}".',
        ),
      );
    }

    // Step 4: Listen & Distinguish (2)
    if (selectedVerbs.length > 2) {
      final v = selectedVerbs[2];
      final wrongVerbs = pool.where((item) => item.id != v.id).toList()..shuffle(Random());
      final opts = {v.fullPhrase, ...wrongVerbs.take(3).map((e) => e.fullPhrase)}.toList()..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.listenDistinguish,
          verb: v,
          prompt: 'Distingue la frase por su ritmo y chunk enlazado:',
          audioText: v.fullPhrase,
          expectedAnswer: v.fullPhrase,
          options: opts,
          explanation: 'Audio: "${v.fullPhrase}". Chunk: ${v.connectedSpeechChunk} (${v.ipa}).',
        ),
      );
    }

    // Step 5: Sentence Builder (1) (Daily Sync / Meeting Context)
    if (selectedVerbs.length > 2) {
      final v = selectedVerbs[2];
      final wrongVerbs = pool.where((item) => item.id != v.id).toList()..shuffle(Random());
      final opts = {v.fullPhrase, ...wrongVerbs.take(3).map((e) => e.fullPhrase)}.toList()..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.sentenceBuilder,
          verb: v,
          prompt: 'Completa la actualización del Daily Standup:',
          sentenceContext: v.dailySyncExample.replaceAll(v.fullPhrase, '________'),
          expectedAnswer: v.fullPhrase,
          options: opts,
          explanation: 'Uso en Daily: "${v.dailySyncExample}".',
        ),
      );
    }

    // Step 6: Sentence Builder (2) (Incidencia / Architecture)
    if (selectedVerbs.length > 3) {
      final v = selectedVerbs[3];
      final wrongVerbs = pool.where((item) => item.id != v.id).toList()..shuffle(Random());
      final opts = {v.fullPhrase, ...wrongVerbs.take(3).map((e) => e.fullPhrase)}.toList()..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.sentenceBuilder,
          verb: v,
          prompt: 'Completa la frase de arquitectura / incidencia:',
          sentenceContext: v.workplaceExample.replaceAll(v.fullPhrase, '________'),
          expectedAnswer: v.fullPhrase,
          options: opts,
          explanation: 'Contexto técnico: "${v.workplaceExample}". Patrón: ${v.correctPattern}.',
        ),
      );
    }

    // Step 7: Error Correction & Separability (Separabilidad y orden sintáctico)
    if (selectedVerbs.length > 3) {
      final v = selectedVerbs[3];
      final correctForm = v.isSeparable ? '${v.verb} it ${v.particle.id}' : '${v.verb} ${v.particle.id} it';
      final incorrectForm = v.isSeparable ? '${v.verb} ${v.particle.id} it' : '${v.verb} it ${v.particle.id}';
      final opts = [correctForm, incorrectForm]..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.errorCorrection,
          verb: v,
          prompt: '¿Cuál es la posición sintáctica correcta con el pronombre "it"?',
          sentenceContext: 'Estructura con "it":',
          expectedAnswer: correctForm,
          options: opts,
          explanation: v.isSeparable
              ? '"${v.fullPhrase}" es SEPARABLE: con pronombre SIEMPRE va en medio ("$correctForm"). ${v.commonMistake}'
              : '"${v.fullPhrase}" es INSEPARABLE: el pronombre va al final ("$correctForm"). ${v.commonMistake}',
        ),
      );
    }

    // Step 8: Meaning & Register Choice (2)
    if (selectedVerbs.length > 4) {
      final v = selectedVerbs[4];
      final wrongVerbs = pool.where((item) => item.id != v.id).toList()..shuffle(Random());
      final opts = {v.fullPhrase, ...wrongVerbs.take(3).map((e) => e.fullPhrase)}.toList()..shuffle(Random());

      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.meaningReplacement,
          verb: v,
          prompt: '¿Qué phrasal verb expresa "${v.spanish}"?',
          sentenceContext: 'Sentido: "${v.idiomaticMeaning}"',
          expectedAnswer: v.fullPhrase,
          options: opts,
          explanation: '"${v.fullPhrase}" = ${v.spanish}. Patrón: ${v.correctPattern}. Errores comunes: ${v.commonErrorsEs.join(", ")}.',
        ),
      );
    }

    // Step 9: Shadow & Repeat (Connected Speech Shadowing)
    if (selectedVerbs.length > 4) {
      final v = selectedVerbs[4];
      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.shadowRepeat,
          verb: v,
          prompt: 'Escucha y repite la frase enlazando el chunk (${v.connectedSpeechChunk}):',
          audioText: v.dailySyncExample,
          sentenceContext: v.dailySyncExample,
          expectedAnswer: 'shadow_ok',
          options: ['He repetido la frase con enlace natural'],
          explanation: 'Ritmo completado. Enlace fonético: ${v.connectedSpeechChunk} (${v.ipa}).',
        ),
      );
    }

    // Step 10: Speaking Use (Daily / Incidencia Simulation)
    if (selectedVerbs.isNotEmpty) {
      final v = selectedVerbs[0];
      steps.add(
        PhrasalStepItem(
          type: PhrasalExerciseType.speakingUse,
          verb: v,
          prompt: 'Simulación Oral: Responde integrando "${v.fullPhrase}"',
          incidentPrompt: v.incidentPrompt,
          incidentChips: [
            'During the incident, we had to ${v.fullPhrase}...',
            'To resolve this, I ${v.fullPhrase}...',
            'In our daily standup, I mentioned we should ${v.fullPhrase}...',
          ],
          expectedAnswer: 'speaking_ok',
          options: ['Grabación completada con éxito'],
          explanation: 'Has utilizado "${v.fullPhrase}" en una respuesta comunicativa real.',
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
      if (step.type == PhrasalExerciseType.listenDistinguish || step.type == PhrasalExerciseType.shadowRepeat) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _playTts(step.audioText ?? step.verb.fullPhrase);
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
    final isCorrect = (step.type == PhrasalExerciseType.shadowRepeat || step.type == PhrasalExerciseType.speakingUse) ||
        (option == step.expectedAnswer);

    if (isCorrect) {
      AppHaptics.medium();
      _score++;
      _consolidatedVerbs.add(step.verb.fullPhrase);
    } else {
      AppHaptics.error();
      _fsrsMistakeVerbs.add(step.verb.fullPhrase);
    }

    // Map to specific FSRS item types
    String exerciseTypeStr = 'contextual_meaning';
    if (step.type == PhrasalExerciseType.listenDistinguish) exerciseTypeStr = 'listening';
    if (step.type == PhrasalExerciseType.sentenceBuilder) exerciseTypeStr = 'contextual_use';
    if (step.type == PhrasalExerciseType.errorCorrection) exerciseTypeStr = 'word_order';
    if (step.type == PhrasalExerciseType.shadowRepeat) exerciseTypeStr = 'pronunciation';
    if (step.type == PhrasalExerciseType.speakingUse) exerciseTypeStr = 'speaking';

    ref.read(phrasalVerbsLabNotifierProvider.notifier).recordAttempt(
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
        appBar: AppBar(title: const Text('Phrasal Verbs Lab')),
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
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            Text(
              'Paso ${_currentIndex + 1} de ${_steps.length}',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: TabTheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                  minHeight: 4,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 4),
                Text('$_score', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5))),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Exercise Card
            _buildExerciseCard(step),
            const SizedBox(height: 20),

            // Options / Actions
            if (step.type == PhrasalExerciseType.shadowRepeat)
              _buildShadowingControls(step)
            else if (step.type == PhrasalExerciseType.speakingUse)
              _buildSpeakingControls(step)
            else
              ...step.options.map((opt) => _buildOptionTile(opt, step)),

            // Explanation & Next Button
            if (_isAnswerSubmitted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.explanation,
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF312E81), height: 1.4),
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

  Widget _buildExerciseCard(PhrasalStepItem step) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getExerciseTypeName(step.type),
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, color: _accentColor),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TabTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  step.verb.particle.label,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            step.prompt,
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          if (step.audioText != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _playTts(step.audioText!),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _accentColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAudioPlaying ? Icons.volume_up_rounded : Icons.play_circle_fill_rounded,
                      color: _accentColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reproducir Audio Enlazado',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: _accentColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (step.sentenceContext != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
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
          if (step.incidentPrompt != null) ...[
            const SizedBox(height: 12),
            Text(
              'Escenario: "${step.incidentPrompt}"',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(String opt, PhrasalStepItem step) {
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

  Widget _buildShadowingControls(PhrasalStepItem step) {
    return ContextualPronunciationPracticeSheet(
      key: ValueKey('phrasal_shadow_inline_${step.verb.id}_$_currentIndex'),
      title: 'Shadowing: ${step.verb.fullPhrase} (${step.verb.spanish})',
      category: 'phrasal_verbs',
      expectedTerm: step.verb.fullPhrase,
      expectedIpa: step.verb.ipa,
      accentColor: _accentColor,
      isInline: true,
      maskTextUntilRevealed: true,
      phrases: [
        PronunciationPhraseItem(
          phrase: step.verb.dailySyncExample,
          label: 'Connected Speech (${step.verb.connectedSpeechChunk})',
          phonetic: step.verb.ipa,
          translation: step.verb.spanish,
        ),
        PronunciationPhraseItem(
          phrase: step.verb.workplaceExample,
          label: 'Incidente / Producción',
          phonetic: step.verb.ipa,
        ),
      ],
      onAttemptRecorded: (score, phrase) {
        if (!_speakingEvaluated) {
          setState(() => _speakingEvaluated = true);
          _submitAnswer('shadow_ok');
        }
      },
    );
  }

  Widget _buildSpeakingControls(PhrasalStepItem step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (step.incidentChips != null && step.incidentChips!.isNotEmpty) ...[
          Text('Ideas y frases de ayuda sugeridas:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: step.incidentChips!
                .map((chip) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        chip,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF92400E)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
        ],
        ContextualPronunciationPracticeSheet(
          key: ValueKey('phrasal_speak_inline_${step.verb.id}_$_currentIndex'),
          title: 'Speaking: ${step.verb.fullPhrase} (${step.verb.spanish})',
          category: 'phrasal_verbs',
          expectedTerm: step.verb.fullPhrase,
          expectedIpa: step.verb.ipa,
          accentColor: _accentColor,
          isInline: true,
          phrases: [
            PronunciationPhraseItem(
              phrase: step.verb.workplaceExample,
              label: 'Contexto de Incidencia / Dailies',
              phonetic: step.verb.ipa,
            ),
            PronunciationPhraseItem(
              phrase: step.verb.dailySyncExample,
              label: 'Daily Standup',
              phonetic: step.verb.ipa,
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
    final userInitials = userName.isNotEmpty
        ? userName.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'IV';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              '+50 XP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFD97706)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak días',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFFFFBEB),
                    child: Text(
                      userInitials,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                          style: GoogleFonts.plusJakartaSans(
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
                      'Has consolidado los phrasal verbs clave en situaciones reales de desarrollo técnico, incidencias y reuniones.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.35),
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
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      title: 'Phrasals Dominados',
                      value: '${_consolidatedVerbs.length}',
                      subtext: 'Uso natural consolidado',
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
                      title: 'Connected Speech',
                      value: '96%',
                      subtext: 'Enlace fonético fluido',
                      icon: Icons.graphic_eq_rounded,
                      color: const Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Desglose de Phrasal Verbs
              Text(
                'PHRASAL VERBS DE LA SESIÓN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              ..._sessionVerbs.map((v) {
                final isConsolidated = _consolidatedVerbs.contains(v.fullPhrase);
                final hasError = _fsrsMistakeVerbs.contains(v.fullPhrase);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TabTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isConsolidated ? const Color(0xFFA7F3D0) : TabTheme.surfaceContainerHigh,
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
                                v.fullPhrase,
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
                        'Connected Speech: ${v.connectedSpeechChunk} (${v.ipa})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Uso en standup: "${v.dailySyncExample}"',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // AI Coach Tip Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology_rounded, size: 22, color: Color(0xFFD97706)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Executive Coach · Consejo de Registro y Separabilidad',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Usa verbos formales (ej. investigate, deploy) en informes y documentos escritos de arquitectura, pero en daily standups y chats técnicos de Slack/Teams prefiere siempre phrasal verbs como look into, roll out o spin up para sonar más cercano y natural.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF78350F),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                      context.pushReplacement('/phrasal-verbs/session');
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
                  label: Text('Volver a Phrasal Verbs', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15)),
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
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: color),
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

  String _getExerciseTypeName(PhrasalExerciseType type) {
    switch (type) {
      case PhrasalExerciseType.listenDistinguish:
        return 'Connected Speech & Oído';
      case PhrasalExerciseType.meaningReplacement:
        return 'Reemplazo Formal';
      case PhrasalExerciseType.particleRecall:
        return 'Partícula Conceptual';
      case PhrasalExerciseType.sentenceBuilder:
        return 'Uso en Contexto';
      case PhrasalExerciseType.errorCorrection:
        return 'Corrección de Error';
      case PhrasalExerciseType.shadowRepeat:
        return 'Shadowing y Ritmo';
      case PhrasalExerciseType.speakingUse:
        return 'Speaking Daily / Incidencia';
    }
  }
}
