import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/tab_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/pedagogy/contracts.dart';
import '../../core/pedagogy/content_seeds.dart';
import '../../core/pedagogy/practice_engine.dart';
import '../../core/pedagogy/practice_service.dart';
import '../../l10n/app_localizations.dart';

class GrammarPracticeScreen extends ConsumerStatefulWidget {
  final String unitId;
  final int minutes;

  const GrammarPracticeScreen({
    super.key,
    required this.unitId,
    this.minutes = 8,
  });

  @override
  ConsumerState<GrammarPracticeScreen> createState() =>
      _GrammarPracticeScreenState();
}

class _GrammarExercise {
  final Map<String, dynamic> drill;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  _GrammarExercise({
    required this.drill,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });
}

class _GrammarPracticeScreenState
    extends ConsumerState<GrammarPracticeScreen> {
  late final GrammarUnitDef _unit;
  late final List<_GrammarExercise> _exercises;
  final DateTime _startedAt = DateTime.now();

  int _index = 0;
  int _correct = 0;
  int? _selected;
  bool _answered = false;
  final List<Map<String, dynamic>> _missed = [];
  bool _finished = false;
  bool _isSubmitting = false;
  int _ingested = 0;
  PracticeImprovement? _improvement;

  @override
  void initState() {
    super.initState();
    final found = ContentSeeds.getGrammarUnitById(widget.unitId);
    _unit = found ?? ContentSeeds.pastSimpleForProjects;
    _exercises = _buildExercises(_unit);
  }

  List<_GrammarExercise> _buildExercises(GrammarUnitDef unit) {
    if (unit.drills.isEmpty) return [];

    final candidates = <CandidateItem>[];
    for (var i = 0; i < unit.drills.length; i++) {
      candidates.add(CandidateItem(
        id: '$i',
        exerciseType: ExerciseType.recognition,
        contentType: ContentType.drill,
        objectiveId: unit.objectiveId,
        band: unit.band,
      ));
    }

    const engine = PracticeEngine();
    final plan = engine.compose(PracticeRequest(
      userId: ref.read(activeUserIdProvider),
      track: Track.grammar,
      minutes: widget.minutes,
      currentObjectiveId: unit.objectiveId,
      phase: ObjectivePhase.learning,
      newItems: candidates,
    ));

    final exercises = <_GrammarExercise>[];
    for (final c in plan.items) {
      final drillIndex = int.parse(c.id) % unit.drills.length;
      final drill = unit.drills[drillIndex];
      exercises.add(_makeExercise(drill));
    }
    return exercises;
  }

  _GrammarExercise _makeExercise(Map<String, dynamic> drill) {
    final prompt = drill['prompt'] as String;
    final answer = (drill['answer'] ?? '').toString().trim();
    final rawOptions = drill['options'] as List?;

    List<String> options;
    if (rawOptions != null && rawOptions.isNotEmpty) {
      options = rawOptions.map((e) => e.toString()).toList();
      if (!options.contains(answer)) {
        options.insert(0, answer);
      }
    } else {
      // Generate sensible distractors for common verb / connector answers
      options = _generateDistractors(answer);
    }

    // Shuffle options while tracking correct answer
    final rng = Random(prompt.hashCode);
    options.shuffle(rng);
    final correctIndex = options.indexOf(answer);

    return _GrammarExercise(
      drill: drill,
      prompt: prompt,
      options: options,
      correctIndex: correctIndex >= 0 ? correctIndex : 0,
    );
  }

  List<String> _generateDistractors(String answer) {
    final low = answer.toLowerCase();
    if (low == 'fixed') return ['fixed', 'fixes', 'fixing', 'have fixed'];
    if (low == 'chose') return ['chose', 'choose', 'chosen', 'have chosen'];
    if (low == 'as') return ['as', 'so', 'because', 'for'];
    if (low == 'shipped') return ['shipped', 'have shipped', 'ship', 'shipping'];
    if (low == 'since') return ['since', 'for', 'during', 'from'];
    if (low == 'will') return ['will', 'would', 'would have', 'had'];
    if (low == 'had had') return ['had had', 'would have had', 'have had', 'had'];
    if (low.endsWith('ed')) {
      final base = low.substring(0, low.length - 2);
      return [answer, base, '${base}ing', 'have $answer'];
    }
    return [answer, 'was $answer', 'did $answer', 'is $answer'];
  }

  void _answer(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (i == _exercises[_index].correctIndex) {
        _correct++;
      } else {
        _missed.add(_exercises[_index].drill);
      }
    });
  }

  Future<void> _next() async {
    if (_index + 1 < _exercises.length) {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    } else {
      await _onDone();
    }
  }

  Future<void> _onDone() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final total = _exercises.length;
    final score = total == 0 ? 0.0 : (_correct / total).clamp(0.0, 1.0);
    final userId = ref.read(activeUserIdProvider);

    final items = _missed.map((d) {
      final prompt = (d['prompt'] ?? '') as String;
      final answer = (d['answer'] ?? '') as String;
      return ReviewItem(
        front: prompt,
        back: 'Respuesta correcta: $answer\n\nRegla: ${_unit.guidebook}',
        sourceType: ReviewSource.grammar,
        sourceRef: '${_unit.id}_${prompt.hashCode}',
        itemType: ReviewItemType.sentenceCorrection,
        unitOrPackId: _unit.id,
        skill: Track.grammar,
      );
    }).toList();

    var ingested = 0;
    try {
      ingested = await ref.read(reviewIngestionProvider).ingest(userId, items);
    } catch (_) {}

    PracticeImprovement? improvement;
    try {
      improvement = await ref.read(practiceServiceProvider).recordAttempt(AttemptResult(
            userId: userId,
            objectiveId: _unit.objectiveId,
            track: Track.grammar,
            band: _unit.band,
            score: score,
            durationSeconds: DateTime.now().difference(_startedAt).inSeconds,
            mistakes: _missed.length,
            fsrsGenerated: ingested,
          ));
      ref.invalidate(profileSummaryProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _finished = true;
      _isSubmitting = false;
      _ingested = ingested;
      _improvement = improvement;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${_unit.title} · Práctica'),
        backgroundColor: AppTheme.surface,
      ),
      body: _exercises.isEmpty
          ? Center(
              child: Text(
                'No hay ejercicios configurados para esta unidad.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : _finished
              ? _buildCompletion(l10n)
              : _buildExercise(l10n),
    );
  }

  Widget _buildExercise(AppLocalizations l10n) {
    final ex = _exercises[_index];
    final progress = (_index + 1) / _exercises.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceLight,
            color: TabTheme.grammar.accent,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Drill ${_index + 1} de ${_exercises.length}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TabTheme.grammar.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _unit.band.label,
                  style: TextStyle(color: TabTheme.grammar.accent, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrammar,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderGrammar),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: TabTheme.grammar.accent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'COMPLETA O CORRIGE LA FRASE',
                      style: TextStyle(
                        color: TabTheme.grammar.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  ex.prompt,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Selecciona la opción correcta:',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: ex.options.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _optionTile(ex, i),
            ),
          ),
          if (_answered) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TabTheme.grammar.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _index + 1 < _exercises.length ? l10n.actionNext : l10n.actionFinish,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionTile(_GrammarExercise ex, int i) {
    Color border = AppTheme.borderGrammar;
    Color bg = AppTheme.surface;
    IconData? indicatorIcon;
    Color? indicatorColor;

    if (_answered) {
      if (i == ex.correctIndex) {
        border = AppTheme.success;
        bg = AppTheme.success.withValues(alpha: 0.15);
        indicatorIcon = Icons.check_circle_rounded;
        indicatorColor = AppTheme.success;
      } else if (i == _selected) {
        border = AppTheme.error;
        bg = AppTheme.error.withValues(alpha: 0.15);
        indicatorIcon = Icons.cancel_rounded;
        indicatorColor = AppTheme.error;
      }
    }

    return InkWell(
      onTap: () => _answer(i),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ex.options[i],
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (indicatorIcon != null)
              Icon(indicatorIcon, color: indicatorColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletion(AppLocalizations l10n) {
    final total = _exercises.length;
    final pct = ((_correct / total) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: TabTheme.grammar.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: TabTheme.grammar.accent.withValues(alpha: 0.4)),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: TabTheme.grammar.accent, size: 56),
          ),
          const SizedBox(height: 20),
          Text(
            '¡Sesión de Gramática Completada!',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$_correct / $total correctos · $pct% de precisión',
            style: TextStyle(color: TabTheme.grammar.accent, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Mini speaking prompt (requirement B1 / criterion 3)
          if (_unit.miniSpeakingPrompts.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceInterview,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderInterview),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic_rounded, color: TabTheme.speaking.accent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'MINI RETO DE SPEAKING',
                        style: TextStyle(
                          color: TabTheme.speaking.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _unit.miniSpeakingPrompts.first,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ðŸ’¡ Tip: Intenta responder en voz alta usando la regla practicada antes de continuar.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // "What you improved" block
          if (_improvement != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TabTheme.grammar.accent.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: TabTheme.grammar.accent, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Qué has mejorado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TabTheme.grammar.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _improvement!.deltaPercent,
                          style: TextStyle(
                            color: TabTheme.grammar.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricTile(
                        icon: Icons.auto_graph_rounded,
                        label: 'Dominio',
                        value: '${(_improvement!.newMastery * 100).toStringAsFixed(0)}%',
                        color: TabTheme.grammar.accent,
                      ),
                      _buildMetricTile(
                        icon: Icons.bolt_rounded,
                        label: 'XP Ganado',
                        value: '+${_improvement!.xpGained}',
                        color: const Color(0xFFFBBF24),
                      ),
                      _buildMetricTile(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Racha',
                        value: '${_improvement!.streak}d',
                        color: const Color(0xFFF97316),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Ingestion status badge
          if (_ingested > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: TabTheme.fsrs.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderFsrs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.style_rounded, color: TabTheme.fsrs.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$_ingested errores añadidos al mazo FSRS',
                    style: TextStyle(color: TabTheme.fsrs.accent, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: TabTheme.grammar.accent,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                l10n.actionFinish,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}


