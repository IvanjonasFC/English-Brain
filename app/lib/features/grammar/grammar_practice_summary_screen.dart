import 'package:flutter/material.dart';
import '../../core/widgets/glossy_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_theme.dart';
import 'grammar_theme_tokens.dart';
import 'grammar_models.dart';
import 'grammar_drill_runner.dart';

/// Pantalla de Resumen de Sesión Gramatical & Sincronización FSRS v5
/// Basada en el diseño Stitch "Gramática - Resumen de Práctica & FSRS".
class GrammarPracticeSummaryScreen extends ConsumerWidget {
  final GrammarUnit? unit;
  final int totalQuestions;
  final int correctAnswers;
  final String timeElapsed;
  final int xpEarned;
  final int fsrsRulesStored;
  final int phoneticClarityScore;
  final List<GrammarQuestion>? missedQuestions;

  const GrammarPracticeSummaryScreen({
    super.key,
    this.unit,
    this.totalQuestions = 5,
    this.correctAnswers = 5,
    this.timeElapsed = '3m 45s',
    this.xpEarned = 50,
    this.fsrsRulesStored = 4,
    this.phoneticClarityScore = 96,
    this.missedQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeIsLightProvider);
    final userProfileAsync = ref.watch(profileSummaryProvider);
    final profileData = userProfileAsync.asData?.value;
    final userName = profileData?.profile.displayName ?? 'Iván';
    final streak = profileData?.streakDays ?? 5;

    final unitTitle = unit != null
        ? unit!.title.replaceFirst(RegExp(r'^Unit \d+: '), '')
        : 'Past Simple vs Present Perfect';

    final precisionPct = totalQuestions > 0
        ? ((correctAnswers / totalQuestions) * 100).round()
        : 100;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Executive Warm Hero Card
              _buildHeroCard(userName, unitTitle, precisionPct),
              const SizedBox(height: 14),

              // AI Executive Coach Interview Tip (Consejo del Coach en primer plano)
              _buildAiCoachTip(),
              const SizedBox(height: 14),

              // Key Metrics: 2-Column Responsive Grid
              _buildMetricsGrid(precisionPct),
              const SizedBox(height: 14),

              // XP & Streak Status Strip
              _buildXpStreakStrip(streak),
              const SizedBox(height: 14),

              // FSRS v5 Memory Algorithm Synchronization Card
              _buildFsrsCard(context),
              const SizedBox(height: 18),

              // Detailed Rule Mastery Breakdown
              _buildRuleMasteryBreakdown(),
            ],
          ),
        ),
      ),
      // Persistent Sticky Bottom Action Dock
      bottomNavigationBar: _buildBottomActionDock(context),
    );
  }

  Widget _buildHeroCard(String userName, String unitTitle, int precisionPct) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GrammarTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.military_tech_rounded,
                  size: 26,
                  color: GrammarTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GrammarTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'CEFR BENCHMARK',
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '¡Sesión Gramatical Consolidada, $userName!',
            style: GrammarTheme.headlineSm(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Completaste $totalQuestions ejercicios de $unitTitle en $timeElapsed con alta cadencia ejecutiva.',
            style: GrammarTheme.bodyMd(),
          ),
          const SizedBox(height: 14),
          // CEFR Progression Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 20, color: GrammarTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Nivel Estructural: ',
                          style: GrammarTheme.labelMd(color: GrammarTheme.onSurface),
                        ),
                        TextSpan(
                          text: 'B1 → B2',
                          style: GrammarTheme.labelMd(
                            color: GrammarTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: GrammarTheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '+8% precisión',
                    style: GrammarTheme.labelSm(
                      color: GrammarTheme.tertiary,
                      fontWeight: FontWeight.w700,
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

  Widget _buildMetricsGrid(int precisionPct) {
    return Row(
      children: [
        // Metric 1: Precisión Verbal
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.spellcheck_rounded, size: 22, color: GrammarTheme.primary),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: GrammarTheme.primaryFixed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$correctAnswers/$totalQuestions Ok',
                        style: GrammarTheme.labelSm(
                          color: GrammarTheme.onPrimaryFixed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$precisionPct%',
                  style: GrammarTheme.displayMd(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Precisión Verbal',
                  style: GrammarTheme.titleSm(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Tiempos y acuerdos',
                  style: GrammarTheme.bodySm(),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: precisionPct / 100.0,
                    minHeight: 6,
                    backgroundColor: GrammarTheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(GrammarTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Metric 2: Claridad Fonética
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.mic_rounded, size: 22, color: GrammarTheme.tertiary),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: GrammarTheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Precisión Oral',
                        style: GrammarTheme.labelSm(
                          color: GrammarTheme.onSecondaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$phoneticClarityScore%',
                  style: GrammarTheme.displayMd(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Claridad Fonética',
                  style: GrammarTheme.titleSm(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Dicción y Fonética STAR',
                  style: GrammarTheme.bodySm(),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (phoneticClarityScore / 100.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: GrammarTheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(GrammarTheme.tertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildXpStreakStrip(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: GrammarTheme.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, size: 18, color: GrammarTheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                '+$xpEarned XP Ganados',
                style: GrammarTheme.titleSm(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded, size: 16, color: GrammarTheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Racha: $streak días',
                  style: GrammarTheme.labelMd(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFsrsCard(BuildContext context) {
    final int needsReinforce = missedQuestions?.length ?? (totalQuestions - correctAnswers);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.sync_rounded, size: 22, color: GrammarTheme.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALGORITMO FSRS V5',
                            style: GrammarTheme.labelSm(
                              color: GrammarTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Memoria Gramatical Sincronizada',
                            style: GrammarTheme.titleSm(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GrammarTheme.tertiaryFixed,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Estabilidad +0.40',
                  style: GrammarTheme.labelSm(
                    color: GrammarTheme.onTertiaryFixed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bucket 1: Long Term
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_rounded, size: 18, color: GrammarTheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$fsrsRulesStored reglas en largo plazo',
                        style: GrammarTheme.titleSm(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Próximo drill programado en 5 días bajo decaimiento óptimo.',
                        style: GrammarTheme.bodySm(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Bucket 2: Reinforcement
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GrammarTheme.primaryFixed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule_rounded, size: 18, color: GrammarTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$needsReinforce ${needsReinforce == 1 ? "regla" : "reglas"} para refuerzo prioritario',
                        style: GrammarTheme.titleSm(
                          color: GrammarTheme.onPrimaryFixedVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        needsReinforce > 0
                            ? 'Estructuras con fallo registradas en FSRS para repaso en 24 horas.'
                            : 'Sin fallos críticos; repaso preventivo programado bajo curva óptima.',
                        style: GrammarTheme.bodySm(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Button: Ver reglas en Mazo FSRS
          InkWell(
            onTap: () => context.go('/deck'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: GrammarTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.style_rounded, size: 18, color: GrammarTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ver reglas en Mazo FSRS',
                      style: GrammarTheme.labelLg(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: GrammarTheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleMasteryBreakdown() {
    final List<Map<String, dynamic>> rules = [];
    if (unit != null) {
      for (final ex in unit!.comparisonExamples) {
        final tip = ex['tip'] ?? '';
        final right = ex['right'] ?? '';
        final wrong = ex['wrong'] ?? '';
        if (tip.isNotEmpty) {
          final isMissed = missedQuestions?.any((q) => q.prompt.contains(right) || q.correctAnswer.contains(right)) ?? false;
          rules.add({
            'title': tip,
            'sub': '$right (Evitar: $wrong)',
            'pct': isMissed ? '70%' : '95%',
            'status': isMissed ? 'En progreso' : 'Dominado',
            'isDone': !isMissed,
          });
        }
      }
      if (rules.isEmpty) {
        for (final q in unit!.questions.take(3)) {
          final isMissed = missedQuestions?.contains(q) ?? false;
          rules.add({
            'title': q.spanishExplanation,
            'sub': q.prompt.replaceAll('_____', q.correctAnswer),
            'pct': isMissed ? '68%' : '96%',
            'status': isMissed ? 'En progreso' : 'Dominado',
            'isDone': !isMissed,
          });
        }
      }
    }
    if (rules.isEmpty) {
      rules.addAll([
        {
          'title': 'Past Simple con marcadores de tiempo',
          'sub': 'Yesterday, in 2022, last quarter',
          'pct': '98%',
          'status': 'Dominado',
          'isDone': true,
        },
        {
          'title': 'Present Perfect para SLA acumulado',
          'sub': 'Since Q3, for six consecutive sprints',
          'pct': '92%',
          'status': 'Dominado',
          'isDone': true,
        },
        {
          'title': 'Eliminación de Voz Pasiva',
          'sub': 'Ownership directo en formato STAR',
          'pct': '75%',
          'status': 'En progreso',
          'isDone': false,
        },
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'DESGLOSE DE REGLAS PRACTICADAS',
              style: GrammarTheme.labelSm(
                color: GrammarTheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${rules.length} Evaluadas',
              style: GrammarTheme.labelSm(
                color: GrammarTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...rules.map((r) {
          final isDone = r['isDone'] as bool;
          final color = isDone ? GrammarTheme.tertiary : GrammarTheme.primary;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: GrammarTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GrammarTheme.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDone ? Icons.done_all_rounded : Icons.autorenew_rounded,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['title'] as String,
                        style: GrammarTheme.titleSm(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        r['sub'] as String,
                        style: GrammarTheme.bodySm(),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      r['pct'] as String,
                      style: GrammarTheme.labelMd(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      r['status'] as String,
                      style: GrammarTheme.labelSm(color: color),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAiCoachTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrammarTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrammarTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: GrammarTheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Consejo Táctico para Entrevistas (STAR)',
                style: GrammarTheme.titleSm(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: GrammarTheme.primaryContainer, width: 3),
              ),
            ),
            child: Text(
              '“En tu próxima simulación STAR, recuerda enfatizar la terminación /t/ o /d/ en verbos regulares como \'orchestrated\' y \'migrated\'. Los hiring managers evalúan esa nitidez fonética como indicador de seguridad ejecutiva.”',
              style: GrammarTheme.bodyMd(
                color: GrammarTheme.onSurfaceVariant,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: GrammarTheme.surface.withValues(alpha: 0.95),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón 1: Continuar al Catálogo de Gramática
            GlossyButton(
              color: TabTheme.grammar.accent,
              height: 52,
              radius: 26,
              onPressed: () {
                HapticFeedback.lightImpact();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/grammar');
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continuar al Catálogo de Gramática'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Botón 2: Reforzar regla en Modo Relámpago
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () {
                  final targetUnit = unit ?? allGrammarUnits.first;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => GrammarDrillRunner(unit: targetUnit),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: GrammarTheme.surfaceContainerHigh,
                  foregroundColor: GrammarTheme.onSurface,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.offline_bolt_rounded,
                      size: 18,
                      color: GrammarTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Reforzar regla en Modo Relámpago',
                      style: GrammarTheme.titleSm(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

