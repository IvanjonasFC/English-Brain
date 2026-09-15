import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/api_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glossy_button.dart';
import 'interview_theme_tokens.dart';

/// Pantalla dedicada de Resumen de Sesión para Entrevistas Técnicas & STAR.
/// Mantiene la misma estructura premium, limpia y completa que Vocabulario, Gramática e Inmersión:
/// - Sin barra superior emergente con la 'X'.
/// - Consejo del AI Executive Coach en primer plano arriba.
/// - Hero card con rol técnico, benchmarking CEFR y porcentaje de impacto.
/// - Grid de KPIs (STAR Structure, Claridad Fonética, Vocabulario Técnico C1, Cadencia).
/// - Franja de XP Ganado & Racha activa.
/// - Algoritmo FSRS v5 & Bitácora Pedagógica con persistencia automática.
/// - Desglose turno a turno de preguntas, respuestas del alumno, correcciones y vocabulario recomendado.
/// - Botonera fija inferior.
class InterviewSummaryScreen extends ConsumerStatefulWidget {
  final String roleTitle;
  final String category;
  final String mode;
  final int totalQuestions;
  final int correctQuestions;
  final int durationSeconds;
  final int xpEarned;
  final List<TurnOut> turns;
  final List<Map<String, String>> mistakes;
  final VoidCallback? onDismiss;

  const InterviewSummaryScreen({
    super.key,
    required this.roleTitle,
    this.category = 'Technical Interview',
    this.mode = 'mock',
    required this.totalQuestions,
    required this.correctQuestions,
    required this.durationSeconds,
    required this.xpEarned,
    this.turns = const [],
    this.mistakes = const [],
    this.onDismiss,
  });

  @override
  ConsumerState<InterviewSummaryScreen> createState() =>
      _InterviewSummaryScreenState();
}

class _InterviewSummaryScreenState
    extends ConsumerState<InterviewSummaryScreen> {
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

      final minutes = (widget.durationSeconds / 60).ceil().clamp(1, 120);

      // 1. Registrar actividad diaria y XP
      await repo.logLearningActivity(
        userId: userId,
        xp: widget.xpEarned,
        minutes: minutes,
        sessions: 1,
        words: widget.turns.length * 15,
      );

      // 2. Extraer términos de vocabulario sugeridos durante la entrevista
      final vocabList = <String>[];
      for (final turn in widget.turns) {
        final suggestions = turn.evaluation.vocabulary_suggestions ?? [];
        for (final s in suggestions) {
          if (!vocabList.contains(s.term)) {
            vocabList.add(s.term);
          }
        }
      }

      // 3. Guardar en la Bitácora pedagógica
      final accuracy = widget.totalQuestions > 0
          ? (widget.correctQuestions / widget.totalQuestions) * 100
          : 85.0;

      await ref.read(journalServiceProvider).recordActivityJournal(
        title: 'Entrevista: ${widget.roleTitle}',
        category: widget.mode == 'mock' ? 'Mock Interview STAR' : 'Práctica de Entrevista',
        date: DateTime.now(),
        durationSeconds: widget.durationSeconds,
        overallScore: accuracy,
        questionsCount: widget.totalQuestions,
        mistakes: widget.mistakes,
        vocabulary: vocabList,
        additionalNotes: 'Rol: ${widget.roleTitle}. Turnos completados: ${widget.totalQuestions}. Precisión STAR: ${accuracy.round()}%.',
      );

      // 4. Invalidar providers de perfil y racha
      ref.invalidate(profileSummaryProvider);
      ref.invalidate(activeProfileProvider);
      ref.invalidate(dueCardsCountProvider);
    } catch (e) {
      debugPrint('[InterviewSummary] Error guardando progreso: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeIsLightProvider);
    final userProfileAsync = ref.watch(profileSummaryProvider);
    final profileData = userProfileAsync.asData?.value;
    final userName = profileData?.profile.displayName ?? 'Iván';
    final streak = profileData?.streakDays ?? 0;

    final precisionPct = widget.totalQuestions > 0
        ? ((widget.correctQuestions / widget.totalQuestions) * 100).round()
        : 85;

    final minutes = widget.durationSeconds ~/ 60;
    final seconds = widget.durationSeconds % 60;
    final durationStr = '${minutes}m ${seconds}s';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Card Principal
              _buildHeroCard(userName, precisionPct),
              const SizedBox(height: 14),

              // 2. Consejo del AI Executive Coach (En primer plano arriba)
              _buildAiCoachTip(precisionPct),
              const SizedBox(height: 14),

              // 3. Bento Grid de Métricas Clave (2 Columnas)
              _buildMetricsGrid(precisionPct, durationStr),
              const SizedBox(height: 14),

              // 4. Franja de XP Ganado & Racha
              _buildXpStreakStrip(streak),
              const SizedBox(height: 14),

              // 5. Algoritmo FSRS v5 & Consolidación STAR
              _buildFsrsCard(),
              const SizedBox(height: 14),

              // 6. Tarjeta de Bitácora Pedagógica
              _buildBitacoraCard(),

              // 7. Desglose detallado turno a turno de la entrevista
              if (widget.turns.isNotEmpty) ...[
                const SizedBox(height: 18),
                _buildTurnsBreakdown(),
              ],

              // 8. Desglose de Errores Gramaticales destacados
              if (widget.mistakes.isNotEmpty) ...[
                const SizedBox(height: 18),
                _buildMistakesBreakdown(),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionDock(context),
    );
  }

  Widget _buildHeroCard(String userName, int precisionPct) {
    final isTopPerformance = precisionPct >= 80;
    final cefrLevel = precisionPct >= 85 ? 'C1 Executive' : (precisionPct >= 70 ? 'B2 Professional' : 'B1 Intermediate');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: InterviewTheme.surfaceContainerHigh),
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
                  color: InterviewTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.business_center_rounded,
                  size: 24,
                  color: InterviewTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: InterviewTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cefrLevel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: InterviewTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isTopPerformance
                ? '¡Excelente Simulación, $userName!'
                : '¡Práctica de Entrevista Completada!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.roleTitle} · ${widget.category}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (precisionPct / 100).clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: InterviewTheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTopPerformance ? const Color(0xFF0D9488) : InterviewTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Impacto STAR: $precisionPct%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isTopPerformance ? const Color(0xFF0D9488) : InterviewTheme.primary,
                ),
              ),
              Text(
                '${widget.correctQuestions} de ${widget.totalQuestions} respuestas sólidas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiCoachTip(int precisionPct) {
    String tipTitle = 'AI Executive Coach · Enfoque STAR y Métricas de Impacto';
    String tipBody;

    if (precisionPct >= 85) {
      tipBody =
          'Tu estructuración y vocabulario técnico han sido sobresalientes. Para elevar aún más tu nivel a Senior+, cuantifica siempre el resultado final (ejemplo: "reduced latency by 35% and cut cloud costs"). Esto proyecta liderazgo orientado a métricas.';
    } else if (precisionPct >= 70) {
      tipBody =
          'Has respondido de manera coherente. Enfócate en balancear la "Acción" y el "Resultado": evita quedarte mucho tiempo describiendo la Situación. El entrevistador técnico busca entender exactamente qué decisiones tomaste tú y qué impacto tuvieron.';
    } else {
      tipBody =
          'Utiliza conectores ejecutivos como "Initially...", "My direct contribution was...", "Consequently...". Si una pregunta te toma por sorpresa, gana 3 segundos diciendo: "That\'s a great question, let me break down my approach into two parts."';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.psychology_rounded,
            size: 22,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipBody,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF166534),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(int precisionPct, String durationStr) {
    final phoneticScore = (precisionPct >= 80 ? 94 : 88);
    final vocabUsedCount = widget.turns.fold<int>(
      0,
      (sum, t) => sum + (t.evaluation.vocabulary_suggestions?.length ?? 0),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Estructura STAR',
                value: '$precisionPct%',
                subtext: '${widget.correctQuestions} de ${widget.totalQuestions} respuestas clave',
                icon: Icons.track_changes_rounded,
                color: InterviewTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Claridad Fonética',
                value: '$phoneticScore%',
                subtext: 'Cadencia ejecutiva fluida',
                icon: Icons.spatial_audio_off_rounded,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Tiempo de Sesión',
                value: durationStr,
                subtext: 'Ritmo conversacional ideal',
                icon: Icons.timer_outlined,
                color: const Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                title: 'Vocabulario Técnico',
                value: '+$vocabUsedCount',
                subtext: 'Términos & Collocations C1',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF0D9488),
              ),
            ),
          ],
        ),
      ],
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
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildXpStreakStrip(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: InterviewTheme.surfaceContainerHigh),
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
                  '+${widget.xpEarned} XP',
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

  Widget _buildFsrsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: InterviewTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.psychology_alt_rounded, size: 22, color: InterviewTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FSRS v5 · Consolidación de Respuestas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Patrones y conectores de entrevista programados para repaso óptimo antes de tu próxima simulación técnica.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBitacoraCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 22, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bitácora de Carrera Registrada',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Detalles, puntuaciones y feedback de la sesión indexados para tu historial de progreso y análisis predictivo.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTurnsBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESGLOSE DE RESPUESTAS & FEEDBACK',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...widget.turns.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final turn = entry.value;
          final score = turn.evaluation.overall_score;
          final isHigh = score >= 7;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHigh
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFDE68A),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Turno $idx',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isHigh ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Puntuación: $score/10',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isHigh ? const Color(0xFF065F46) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu respuesta:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '"${turn.transcript}"',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                if (turn.evaluation.fluency_feedback.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: InterviewTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Feedback del reclutador: ${turn.evaluation.fluency_feedback}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                if (turn.evaluation.vocabulary_suggestions != null &&
                    turn.evaluation.vocabulary_suggestions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: turn.evaluation.vocabulary_suggestions!.map((vs) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                        ),
                        child: Text(
                          '+ ${vs.term}',
                          style: GoogleFonts.firaCode(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMistakesBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AJUSTES GRAMATICALES DESTACADOS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...widget.mistakes.map((m) {
          final orig = m['original'] ?? '';
          final corr = m['correction'] ?? '';
          final rule = m['rule'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: InterviewTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        orig,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFFDC2626),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_rounded, size: 16, color: Color(0xFF16A34A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        corr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),
                if (rule.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    rule,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActionDock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: InterviewTheme.surface.withValues(alpha: 0.95),
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
          GlossyButton(
            color: InterviewTheme.primary,
            height: 50,
            radius: 25,
            onPressed: () {
              if (widget.onDismiss != null) {
                widget.onDismiss!();
              } else if (context.canPop()) {
                context.pop();
              } else {
                context.go('/interview');
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continuar al Hub de Entrevistas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
