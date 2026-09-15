import 'package:flutter/material.dart';
import '../../core/widgets/glossy_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import 'vocabulary_theme_tokens.dart';

/// Pantalla 3: "Vocabulario - Resumen de Práctica & FSRS"
/// Presenta el Bento Grid de KPIs, impacto del algoritmo FSRS v5,
/// delta de dominio de términos y feedback del AI Executive Coach.
class VocabularyPracticeSummaryScreen extends ConsumerStatefulWidget {
  final String topicTitle;
  final int totalExercises;
  final int correctExercises;
  final String timeElapsed;
  final int? avgPronunciationScore;
  final List<Map<String, dynamic>>? practicedTerms;

  const VocabularyPracticeSummaryScreen({
    super.key,
    this.topicTitle = 'System Architecture & Scalability',
    this.totalExercises = 10,
    this.correctExercises = 9,
    this.timeElapsed = '5m 42s',
    this.avgPronunciationScore,
    this.practicedTerms,
  });

  @override
  ConsumerState<VocabularyPracticeSummaryScreen> createState() =>
      _VocabularyPracticeSummaryScreenState();
}

class _VocabularyPracticeSummaryScreenState
    extends ConsumerState<VocabularyPracticeSummaryScreen> {
  bool _hasSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistSession();
    });
  }

  Future<void> _persistSession() async {
    if (_hasSaved) return;
    _hasSaved = true;
    try {
      final userId = ref.read(activeUserIdProvider);
      final repo = ref.read(profileRepositoryProvider);
      final db = ref.read(appDatabaseProvider);

      final xp = widget.correctExercises * 10 + 15;
      final parsedMinutes = _parseMinutes(widget.timeElapsed);

      // 1. Registrar actividad diaria y sumar XP al usuario
      await repo.logLearningActivity(
        userId: userId,
        xp: xp,
        minutes: parsedMinutes > 0 ? parsedMinutes : 5,
        sessions: 1,
        words: widget.practicedTerms?.length ?? widget.totalExercises,
      );

      // 2. Persistir progreso de cada término en SQLite local (FSRS / mastery)
      if (widget.practicedTerms != null) {
        for (final t in widget.practicedTerms!) {
          final term = t['term'] as String? ?? '';
          if (term.isEmpty) continue;
          final scoreStr = (t['percent'] as String? ?? '85%').replaceAll('%', '');
          final score = double.tryParse(scoreStr) ?? 85.0;
          final isMastered = (t['isMastered'] as bool?) ?? (score >= 80);

          await db.into(db.vocabularyProgressLocal).insert(
            VocabularyProgressLocalCompanion.insert(
              packId: widget.topicTitle,
              wordId: term,
              userId: userId,
              masteryLevel: Value(isMastered ? 3 : 1),
              reviewCount: const Value(1),
              pronunciationScore: Value(score),
              isMastered: Value(isMastered),
              lastReviewedAt: Value(DateTime.now()),
              isSynced: const Value(false),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      }

      // 3. Guardar entrada enriquecida en la Bitácora (JournalService)
      final vocabList = widget.practicedTerms?.map((t) => t['term'] as String? ?? '').where((s) => s.isNotEmpty).toList() ?? [];
      final mistakesList = <Map<String, String>>[];
      if (widget.practicedTerms != null) {
        for (final t in widget.practicedTerms!) {
          final isMastered = (t['isMastered'] as bool?) ?? true;
          if (!isMastered) {
            mistakesList.add({
              'original': t['term'] as String? ?? '',
              'correction': 'Término a consolidar en FSRS',
              'rule': 'Vocabulario: ${t['term']}',
            });
          }
        }
      }

      await ref.read(journalServiceProvider).recordActivityJournal(
        title: widget.topicTitle,
        category: 'Vocabulario Profesional',
        date: DateTime.now(),
        durationSeconds: parsedMinutes * 60,
        overallScore: widget.totalExercises > 0
            ? (widget.correctExercises / widget.totalExercises) * 100
            : 100.0,
        questionsCount: widget.totalExercises,
        mistakes: mistakesList,
        vocabulary: vocabList,
        additionalNotes: 'Tema: ${widget.topicTitle}. Precisión: ${((widget.correctExercises / (widget.totalExercises == 0 ? 1 : widget.totalExercises)) * 100).round()}%.',
      );

      // 4. Invalidar providers de perfil, racha y recomendador IA
      ref.invalidate(profileSummaryProvider);
      ref.invalidate(activeProfileProvider);
      ref.invalidate(pronunciationProgressProvider);
      ref.invalidate(dueCardsCountProvider);
    } catch (e) {
      debugPrint('[Summary] Error guardando progreso: $e');
    }
  }

  int _parseMinutes(String timeStr) {
    try {
      if (timeStr.contains('m')) {
        final parts = timeStr.split('m');
        return int.tryParse(parts[0].trim()) ?? 5;
      }
      return 5;
    } catch (_) {
      return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Celebration Aura & Hero Card
              _buildHeroCard(),

              const SizedBox(height: 16),

              // 2. AI Executive Coach Takeaway Card (Consejo del Coach en primer plano)
              _buildAiCoachCard(),

              const SizedBox(height: 20),

              // 3. Performance Highlights: Bento Grid
              _buildBentoGrid(),

              const SizedBox(height: 20),

              // 4. FSRS Algorithm Impact Card
              _buildFsrsCard(),

              const SizedBox(height: 20),

              // 5. Vocabulary Mastery Delta List
              _buildMasteryDeltaList(),
            ],
          ),
        ),
      ),
      // Sticky Bottom Actions
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: VocabTheme.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón Principal
            GlossyButton(
              color: VocabTheme.primary,
              height: 52,
              radius: 26,
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/vocabulary');
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continuar a Módulos'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Botón Secundario Tonal
            SizedBox(
              width: double.infinity,
              height: 46,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Iniciando sesión relámpago con 2 términos a reforzar...'),
                      backgroundColor: VocabTheme.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: VocabTheme.surfaceContainerHigh,
                  foregroundColor: VocabTheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt_rounded,
                        color: VocabTheme.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Repasar 2 fallos en Modo Relámpago',
                      style: VocabTheme.titleSm(
                        color: VocabTheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient Blobs
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VocabTheme.primaryFixed.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VocabTheme.tertiaryFixed.withValues(alpha: 0.35),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: VocabTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: VocabTheme.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'SESIÓN COMPLETADA',
                        style: VocabTheme.labelSm(
                          color: VocabTheme.onPrimaryFixed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  '¡Práctica Consolidada, Iván!',
                  style: VocabTheme.displayMd(
                    color: VocabTheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                RichText(
                  text: TextSpan(
                    style: VocabTheme.bodyMd(color: VocabTheme.secondary),
                    children: [
                      const TextSpan(text: 'Has completado '),
                      TextSpan(
                        text: '${widget.totalExercises} ejercicios',
                        style: VocabTheme.bodyMd(
                          color: VocabTheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' de ${widget.topicTitle} en '),
                      TextSpan(
                        text: widget.timeElapsed,
                        style: VocabTheme.bodyMd(
                          color: VocabTheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Milestone Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: VocabTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech_rounded,
                        size: 17,
                        color: VocabTheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'C2 Vocabulary Drill • Technical Interview Readiness',
                        style: VocabTheme.labelSm(
                          color: VocabTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildBentoGrid() {
    final profileData = ref.watch(profileSummaryProvider).asData?.value;
    final int pronScore = widget.avgPronunciationScore ??
        profileData?.speakingClarityScore ??
        (widget.totalExercises > 0
            ? ((widget.correctExercises / widget.totalExercises) * 100).round().clamp(65, 98)
            : 92);
    final int streak = profileData?.streakDays ?? 5;
    final int xp = widget.correctExercises * 10 + 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Métricas de Rendimiento',
              style: VocabTheme.titleSm(
                color: VocabTheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'STAR Benchmark',
              style: VocabTheme.labelSm(color: VocabTheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // KPI 1: Precisión Léxica
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VocabTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.gps_fixed_rounded,
                          color: VocabTheme.tertiary,
                          size: 22,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: VocabTheme.tertiaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+5% vs ant.',
                            style: VocabTheme.labelSm(
                              color: VocabTheme.onTertiaryFixedVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${((widget.correctExercises / (widget.totalExercises == 0 ? 1 : widget.totalExercises)) * 100).round()}%',
                      style: VocabTheme.displayMd(
                        color: VocabTheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Precisión Léxica',
                      style: VocabTheme.labelMd(
                        color: VocabTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.correctExercises}/${widget.totalExercises} primer intento',
                      style: VocabTheme.bodySm(color: VocabTheme.secondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // KPI 2: Pronunciación Whisper
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VocabTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: VocabTheme.primary,
                          size: 22,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: VocabTheme.primaryFixed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Whisper v3',
                            style: VocabTheme.labelSm(
                              color: VocabTheme.onPrimaryFixedVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$pronScore%',
                      style: VocabTheme.displayMd(
                        color: VocabTheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Pronunciación',
                      style: VocabTheme.labelMd(
                        color: VocabTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Entonación ejecutiva',
                      style: VocabTheme.bodySm(color: VocabTheme.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // KPI 3: XP & Racha (Full Width)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VocabTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VocabTheme.primaryFixed,
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: VocabTheme.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+$xp XP Obtenidos',
                        style: VocabTheme.titleMd(
                          color: VocabTheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Racha de $streak días consecutivos',
                        style: VocabTheme.bodySm(color: VocabTheme.secondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: VocabTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: VocabTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nivel 8 Tech',
                      style: VocabTheme.labelSm(
                        color: VocabTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFsrsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VocabTheme.secondaryFixed,
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: VocabTheme.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memoria a Largo Plazo',
                        style: VocabTheme.titleSm(
                          color: VocabTheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Algoritmo FSRS v5 • Actualizado',
                        style: VocabTheme.bodySm(color: VocabTheme.secondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: VocabTheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ESTABILIDAD +0.34',
                  style: VocabTheme.labelSm(
                    color: VocabTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Internal Breakdown Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: VocabTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Item 1: Promovidos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VocabTheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '8 términos promovidos',
                                style: VocabTheme.bodyMd(
                                  color: VocabTheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'En 4.5 días',
                                style: VocabTheme.labelSm(
                                  color: VocabTheme.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Consolidados en 'Memoria Estable'. Próximo ciclo de repaso espaciado optimizado.",
                            style:
                                VocabTheme.bodySm(color: VocabTheme.secondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Segmented Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: SizedBox(
                    height: 7,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: Container(color: VocabTheme.tertiary),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(color: VocabTheme.primaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Item 2: Refuerzo Temprano
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: VocabTheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '2 para refuerzo temprano',
                                style: VocabTheme.bodyMd(
                                  color: VocabTheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'En 18 horas',
                                style: VocabTheme.labelSm(
                                  color: VocabTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              style: VocabTheme.bodySm(
                                  color: VocabTheme.onSurfaceVariant),
                              children: [
                                TextSpan(
                                  text: 'Throughput',
                                  style: VocabTheme.bodySm(
                                    color: VocabTheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: ' y '),
                                TextSpan(
                                  text: 'Circuit Breaker',
                                  style: VocabTheme.bodySm(
                                    color: VocabTheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(
                                    text: ' identificados con vacilación.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Botón ver en mazo FSRS
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                context.push('/deck');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: VocabTheme.surfaceContainerHigh,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_rounded,
                      size: 18, color: VocabTheme.onSurface),
                  const SizedBox(width: 6),
                  Text(
                    'Ver en Mazo FSRS',
                    style: VocabTheme.labelMd(
                      color: VocabTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: VocabTheme.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryDeltaList() {
    final terms = widget.practicedTerms != null && widget.practicedTerms!.isNotEmpty
        ? widget.practicedTerms!
        : [
            {
              'term': widget.topicTitle,
              'sub': 'Arquitectura & Conceptos Clave',
              'percent': '${((widget.correctExercises / (widget.totalExercises == 0 ? 1 : widget.totalExercises)) * 100).round()}%',
              'delta': '(+14%)',
              'badge': widget.correctExercises >= (widget.totalExercises * 0.8) ? 'Dominado' : 'En Progreso',
              'isMastered': widget.correctExercises >= (widget.totalExercises * 0.8),
            },
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Evolución de Términos',
              style: VocabTheme.titleSm(
                color: VocabTheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Delta de Sesión',
              style: VocabTheme.labelSm(color: VocabTheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: terms.map((t) {
            final isMastered = t['isMastered'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: VocabTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                          shape: BoxShape.circle,
                          color: isMastered
                              ? VocabTheme.tertiaryFixed
                              : VocabTheme.secondaryFixed,
                        ),
                        child: Icon(
                          isMastered
                              ? Icons.check_circle_rounded
                              : Icons.timelapse_rounded,
                          color: isMastered
                              ? VocabTheme.tertiary
                              : VocabTheme.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['term'] as String,
                            style: VocabTheme.titleSm(
                              color: VocabTheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t['sub'] as String,
                            style:
                                VocabTheme.bodySm(color: VocabTheme.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Text(
                            t['percent'] as String,
                            style: VocabTheme.labelLg(
                              color: VocabTheme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t['delta'] as String,
                            style: VocabTheme.labelSm(
                              color: isMastered
                                  ? VocabTheme.tertiary
                                  : VocabTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isMastered
                              ? VocabTheme.tertiaryFixed
                              : VocabTheme.primaryFixed,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t['badge'] as String,
                          style: VocabTheme.labelSm(
                            color: isMastered
                                ? VocabTheme.onTertiaryFixedVariant
                                : VocabTheme.onPrimaryFixedVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAiCoachCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VocabTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: VocabTheme.primaryContainer,
            ),
            child: Icon(
              Icons.record_voice_over_rounded,
              color: VocabTheme.onPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Coach • Clave de Entrevista',
                      style: VocabTheme.labelLg(
                        color: VocabTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: VocabTheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: VocabTheme.bodyMd(color: VocabTheme.onSurfaceVariant),
                    children: [
                      const TextSpan(
                          text:
                              '“En tu última respuesta hablaste con excelente ritmo estructural (STAR). Para '),
                      TextSpan(
                        text: '‘Throughput’',
                        style: VocabTheme.bodyMd(
                          color: VocabTheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                          text: ', enfatiza el diptongo alargado '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: VocabTheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '/ˈθruːˌpʊt/',
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: VocabTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                          text:
                              ' para proyectar máxima naturalidad frente a directores de ingeniería de EE.UU.”'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
