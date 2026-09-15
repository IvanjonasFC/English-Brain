import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/widgets/glossy_button.dart';
import 'comprehension_theme_tokens.dart';

/// Pantalla global de Resumen de Sesión para Inmersión Auditiva y Lectura Comprensiva.
/// Mantiene la misma estructura premium y completa que Gramática y Vocabulario:
/// - Sin barra superior redundante con la 'X'.
/// - Consejo del Coach Pedagógico en primer plano arriba.
/// - Hero card, métricas clave, XP, racha, sincronización FSRS v5 y Bitácora.
/// - Botones de acción fijos en la parte inferior.
class ComprehensionSummaryScreen extends ConsumerWidget {
  final String passageTitle;
  final String category;
  final String band;
  final int totalQuestions;
  final int correctAnswers;
  final String timeElapsed;
  final int xpEarned;
  final List<Map<String, String>> mistakes;
  final List<String> keywords;

  const ComprehensionSummaryScreen({
    super.key,
    required this.passageTitle,
    this.category = 'Inmersión Auditiva',
    this.band = 'B1',
    this.totalQuestions = 4,
    this.correctAnswers = 4,
    this.timeElapsed = '2m 0s',
    this.xpEarned = 30,
    this.mistakes = const [],
    this.keywords = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeIsLightProvider);
    final userProfileAsync = ref.watch(profileSummaryProvider);
    final profileData = userProfileAsync.asData?.value;
    final userName = profileData?.profile.displayName ?? 'Iván';
    final streak = profileData?.streakDays ?? 0;

    final precisionPct = totalQuestions > 0
        ? ((correctAnswers / totalQuestions) * 100).round()
        : 100;

    final isListening = category.toLowerCase().contains('auditiva') ||
        category.toLowerCase().contains('listening');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Card Principal
              _buildHeroCard(userName, precisionPct, isListening),
              const SizedBox(height: 14),

              // 2. Consejo del Coach Pedagógico (En primer plano arriba)
              _buildAiCoachTip(precisionPct, isListening),
              const SizedBox(height: 14),

              // 3. Grid de Métricas Clave (2 Columnas)
              _buildMetricsGrid(precisionPct, isListening),
              const SizedBox(height: 14),

              // 4. Franja de XP Ganado & Racha
              _buildXpStreakStrip(streak),
              const SizedBox(height: 14),

              // 5. Algoritmo FSRS v5 & Memoria Auditiva
              _buildFsrsCard(),
              const SizedBox(height: 14),

              // 6. Bitácora Pedagógica
              _buildBitacoraCard(),

              // 7. Desglose de Errores (si los hubo)
              if (mistakes.isNotEmpty) ...[
                const SizedBox(height: 18),
                _buildMistakesBreakdown(),
              ],
            ],
          ),
        ),
      ),
      // Botonera fija inferior
      bottomNavigationBar: _buildBottomActionDock(context),
    );
  }

  Widget _buildHeroCard(String userName, int precisionPct, bool isListening) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CompTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CompTheme.surfaceContainerHigh),
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
                  color: CompTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isListening ? Icons.headphones_rounded : Icons.auto_stories_rounded,
                  size: 24,
                  color: CompTheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CompTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'CEFR BENCHMARK $band',
                  style: CompTheme.labelSm(
                    color: CompTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '¡$category Consolidada, $userName!',
            style: CompTheme.headlineSm(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Completaste $totalQuestions preguntas de "$passageTitle" en $timeElapsed con alta retención contextual.',
            style: CompTheme.bodyMd(),
          ),
          const SizedBox(height: 14),
          // Barra de nivel estructural
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: CompTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CompTheme.surfaceContainerHigh),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 20, color: CompTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Comprensión Global: ',
                          style: CompTheme.labelMd(color: CompTheme.onSurface),
                        ),
                        TextSpan(
                          text: '$precisionPct%',
                          style: CompTheme.labelMd(
                            color: CompTheme.primary,
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
                    color: CompTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '+$xpEarned XP',
                    style: CompTheme.labelSm(
                      color: CompTheme.primary,
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

  Widget _buildAiCoachTip(int precisionPct, bool isListening) {
    final String tipText;
    if (precisionPct >= 80) {
      tipText = isListening
          ? '“Excelente agudeza auditiva. Has captado tanto el significado literal como los matices implícitos del interlocutor. En próximas sesiones, mantén el foco en entonaciones y palabras de transición como \'however\' y \'therefore\'.”'
          : '“Gran capacidad de lectura analítica y síntesis. Has extraído las ideas secundarias y el tono del texto sin vacilación. Estás listo para textos de mayor densidad técnica.”';
    } else if (precisionPct >= 50) {
      tipText = isListening
          ? '“Buen progreso en la práctica. El Coach sugiere prestar especial atención a los conectores clave y a la entonación de oraciones compuestas. Cuando escuches pausas, identifica si introducen una objeción o un ejemplo.”'
          : '“Comprensión general sólida, pero algunos detalles específicos requirieron inferencia. Te sugerimos reubicar los párrafos donde aparecen las palabras clave antes de seleccionar tu respuesta.”';
    } else {
      tipText = isListening
          ? '“Recomendación: vuelve a escuchar el audio a velocidad reducida (0.8x) activando la transcripción para sincronizar la fonética nativa con el vocabulario clave antes de responder.”'
          : '“Te recomendamos volver a leer el texto identificando primero el vocabulario no familiar en tu mazo de repaso para asegurar una base sólida.”';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CompTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CompTheme.surfaceContainerHigh),
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
                  color: CompTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                'Consejo del Coach de Inmersión',
                style: CompTheme.titleSm(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: CompTheme.primary, width: 3),
              ),
            ),
            child: Text(
              tipText,
              style: CompTheme.bodyMd(
                color: CompTheme.onSurfaceVariant,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(int precisionPct, bool isListening) {
    return Row(
      children: [
        // Métrica 1: Precisión Global
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CompTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CompTheme.surfaceContainerHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      isListening ? Icons.hearing_rounded : Icons.fact_check_rounded,
                      size: 22,
                      color: CompTheme.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: CompTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$correctAnswers/$totalQuestions Ok',
                        style: CompTheme.labelSm(
                          color: CompTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$precisionPct%',
                  style: CompTheme.displayMd(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Precisión Global',
                  style: CompTheme.titleSm(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Respuestas correctas',
                  style: CompTheme.bodySm(),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (precisionPct / 100.0).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: CompTheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(CompTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Métrica 2: Duración y Ritmo
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CompTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CompTheme.surfaceContainerHigh),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.timer_outlined, size: 22, color: TabTheme.vocabulary.accent),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TabTheme.vocabulary.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Cadencia',
                        style: CompTheme.labelSm(
                          color: TabTheme.vocabulary.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  timeElapsed,
                  style: CompTheme.displayMd(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Tiempo de Sesión',
                  style: CompTheme.titleSm(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$totalQuestions preguntas analizadas',
                  style: CompTheme.bodySm(),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 6,
                    backgroundColor: CompTheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(TabTheme.vocabulary.accent),
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
        color: CompTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CompTheme.surfaceContainerHigh),
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
                  color: CompTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, size: 18, color: CompTheme.primary),
              ),
              const SizedBox(width: 8),
              Text(
                '+$xpEarned XP Ganados',
                style: CompTheme.titleSm(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CompTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded, size: 16, color: CompTheme.primary),
                const SizedBox(width: 4),
                Text(
                  'Racha: $streak días',
                  style: CompTheme.labelMd(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFsrsCard() {
    final hasErrors = mistakes.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasErrors
            ? const Color(0xFFBA1A1A).withValues(alpha: 0.06)
            : CompTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasErrors
              ? const Color(0xFFBA1A1A).withValues(alpha: 0.25)
              : CompTheme.surfaceContainerHigh,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: hasErrors
                  ? const Color(0xFFBA1A1A).withValues(alpha: 0.12)
                  : CompTheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sync_rounded,
              size: 20,
              color: hasErrors ? const Color(0xFFBA1A1A) : CompTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasErrors
                      ? '${mistakes.length} error(es) enviados a Repaso Espaciado (FSRS)'
                      : 'Memoria Auditiva Sincronizada con FSRS v5',
                  style: CompTheme.titleSm(
                    color: hasErrors ? const Color(0xFFBA1A1A) : CompTheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasErrors
                      ? 'El algoritmo programará estos conceptos para que los consolides en tus próximas sesiones.'
                      : 'Todos los conceptos y palabras clave de la lectura se consolidaron en tu memoria a largo plazo.',
                  style: CompTheme.bodySm(
                    color: hasErrors
                        ? const Color(0xFFBA1A1A).withValues(alpha: 0.85)
                        : CompTheme.onSurfaceVariant,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: CompTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CompTheme.surfaceContainerHigh),
      ),
      child: Row(
        children: [
          Icon(Icons.menu_book_rounded, size: 20, color: CompTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Entrada guardada automáticamente en tu Bitácora pedagógica.',
              style: CompTheme.bodySm(color: CompTheme.onSurface),
            ),
          ),
          Icon(Icons.check_circle_rounded, size: 18, color: CompTheme.primary),
        ],
      ),
    );
  }

  Widget _buildMistakesBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preguntas para Reforzar',
          style: CompTheme.titleMd(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...mistakes.map((m) {
          final orig = m['original'] ?? '';
          final corr = m['correction'] ?? '';
          final rule = m['rule'] ?? '';
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CompTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBA1A1A).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rule.isNotEmpty) ...[
                  Text(
                    rule,
                    style: CompTheme.labelSm(
                      color: const Color(0xFFBA1A1A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (orig.isNotEmpty) ...[
                  Text(
                    'Tu respuesta: $orig',
                    style: CompTheme.bodySm(color: CompTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                ],
                if (corr.isNotEmpty)
                  Text(
                    '💡 $corr',
                    style: CompTheme.bodySm(
                      color: CompTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomActionDock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: CompTheme.surface.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: CompTheme.surfaceContainerHigh)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón 1: Continuar al Catálogo de Inmersión
            GlossyButton(
              color: TabTheme.comprehension.accent,
              height: 52,
              onPressed: () {
                if (context.mounted) {
                  context.go('/comprehension');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continuar al Catálogo de Inmersión',
                    style: CompTheme.labelLg(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
            // Botón 2 (Opcional): Si hubo errores, botón para repasar
            if (mistakes.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: CompTheme.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.style_rounded, size: 18),
                  label: Text(
                    'Reforzar errores en el Mazo (FSRS)',
                    style: CompTheme.labelMd(
                      color: CompTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    if (context.mounted) {
                      context.go('/deck');
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
