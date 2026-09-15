import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glossy_button.dart';

/// Test inicial de nivel: ~10 preguntas de dificultad creciente (gramática +
/// vocabulario) que estiman el nivel CEFR. Se devuelve el nivel ('A2'..'C1')
/// vía Navigator.pop, o null si el usuario lo salta.
class PlacementTestScreen extends StatefulWidget {
  final String displayName;
  const PlacementTestScreen({super.key, required this.displayName});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementQuestion {
  final String prompt;
  final List<String> options;
  final int correct;
  final int weight; // 1=A2/B1, 2=B1/B2, 3=B2/C1 — dificultad
  const _PlacementQuestion(this.prompt, this.options, this.correct, this.weight);
}

const List<_PlacementQuestion> _kQuestions = [
  _PlacementQuestion('She ___ to the office every day.',
      ['go', 'goes', 'going', 'gone'], 1, 1),
  _PlacementQuestion('I have worked here ___ 2019.',
      ['since', 'for', 'from', 'during'], 0, 1),
  _PlacementQuestion('Choose the correct: "There ___ many bugs in the release."',
      ['is', 'was', 'are', 'be'], 2, 1),
  _PlacementQuestion('If the server ___ down, we lose requests.',
      ['go', 'goes', 'went', 'gone'], 1, 2),
  _PlacementQuestion('The deploy ___ already been approved.',
      ['have', 'has', 'is', 'had'], 1, 2),
  _PlacementQuestion('Pick the best synonym for "mitigate" (reduce impact):',
      ['increase', 'ignore', 'alleviate', 'delay'], 2, 2),
  _PlacementQuestion('We need to ___ the root cause before shipping.',
      ['adress', 'address', 'adress to', 'addressing'], 1, 2),
  _PlacementQuestion('"By next quarter, we ___ migrated the whole stack."',
      ['will', 'will be', 'will have', 'have'], 2, 3),
  _PlacementQuestion('Choose the most precise: "The outage was ___ by a memory leak."',
      ['caused', 'made', 'done', 'produced'], 0, 3),
  _PlacementQuestion('Best executive phrasing:',
      [
        'We fixed the thing fast.',
        'We resolved the incident within the agreed SLA.',
        'The problem is gone now.',
        'It works again, no worries.'
      ],
      1,
      3),
];

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  int _idx = 0;
  int? _selected;
  final List<bool> _results = [];

  void _answer(int i) {
    if (_selected != null) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = i);
  }

  void _next() {
    if (_selected == null) return;
    HapticFeedback.lightImpact();
    final q = _kQuestions[_idx];
    _results.add(_selected == q.correct);
    if (_idx + 1 < _kQuestions.length) {
      setState(() {
        _idx++;
        _selected = null;
      });
    } else {
      Navigator.of(context).pop(_computeLevel());
    }
  }

  /// Puntúa por dificultad y mapea a CEFR.
  String _computeLevel() {
    int score = 0;
    int max = 0;
    for (var i = 0; i < _kQuestions.length; i++) {
      final w = _kQuestions[i].weight;
      max += w;
      if (i < _results.length && _results[i]) score += w;
    }
    final pct = max == 0 ? 0.0 : score / max;
    if (pct >= 0.85) return 'C1';
    if (pct >= 0.65) return 'B2';
    if (pct >= 0.40) return 'B1';
    return 'A2';
  }

  @override
  Widget build(BuildContext context) {
    final q = _kQuestions[_idx];
    final total = _kQuestions.length;
    final progress = (_idx + (_selected != null ? 1 : 0)) / total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Test de nivel',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text('Saltar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Text('Pregunta ${_idx + 1} de $total',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 24),
              Text(q.prompt,
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: q.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final chosen = _selected == i;
                    final isAnswerPhase = _selected != null;
                    final isCorrect = i == q.correct;
                    Color border = AppTheme.surfaceLight;
                    Color bg = AppTheme.surface;
                    if (isAnswerPhase) {
                      if (isCorrect) {
                        border = const Color(0xFF2E9E6B);
                        bg = const Color(0xFF2E9E6B).withValues(alpha: 0.10);
                      } else if (chosen) {
                        border = const Color(0xFFC0392B);
                        bg = const Color(0xFFC0392B).withValues(alpha: 0.10);
                      }
                    }
                    return InkWell(
                      onTap: () => _answer(i),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(q.options[i],
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            if (isAnswerPhase && isCorrect)
                              const Icon(Icons.check_circle_rounded,
                                  color: Color(0xFF2E9E6B), size: 22)
                            else if (isAnswerPhase && chosen)
                              const Icon(Icons.cancel_rounded,
                                  color: Color(0xFFC0392B), size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              GlossyButton(
                color: AppTheme.primary,
                onPressed: _selected == null ? null : _next,
                height: 52,
                radius: 26,
                child: Text(_idx + 1 < total ? 'Siguiente' : 'Ver mi nivel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
