import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/coach_marks.dart';
import 'models/phrasal_verb.dart';
import 'providers/phrasal_verbs_provider.dart';

class PhrasalVerbsLandingScreen extends ConsumerStatefulWidget {
  const PhrasalVerbsLandingScreen({super.key});

  @override
  ConsumerState<PhrasalVerbsLandingScreen> createState() => _PhrasalVerbsLandingScreenState();
}

class _PhrasalVerbsLandingScreenState extends ConsumerState<PhrasalVerbsLandingScreen> {
  final GlobalKey _kCoachScenario = GlobalKey();
  final GlobalKey _kCoachHero = GlobalKey();
  final GlobalKey _kCoachQuickPractice = GlobalKey();
  final GlobalKey _kCoachParticles = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('phrasal_verbs_lab')) return;
    if (!mounted) return;
    final Color accentColor = TabTheme.phrasalVerbs.accent; // Amarillo Dorado / Gold
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachScenario,
          title: 'Escenarios Reales de Trabajo',
          body: 'Organizados por situaciones laborales auténticas: Reuniones y Dailies, Deploys e Infraestructura, Debugging e Incidencias y Negociación Técnica.',
        ),
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Sesión Guiada de Phrasal Verbs',
          body: 'Entrena reconocimiento en contexto, reglas de separabilidad gramatical y producción oral con Connected Speech.',
        ),
        CoachStep(
          targetKey: _kCoachQuickPractice,
          title: 'Separabilidad y Reflejos',
          body: 'Aprende instintivamente cuándo un pronombre u objeto debe colocarse en medio del phrasal verb o al final.',
        ),
        CoachStep(
          targetKey: _kCoachParticles,
          title: 'Explorador por Partículas',
          body: 'Navega por partículas clave (up, down, off, out...) para entender su lógica espacial y metafórica en inglés.',
        ),
      ],
      accent: accentColor,
    );
    await cache.markCoachSeen('phrasal_verbs_lab');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(phrasalVerbsLabNotifierProvider);
    final scenarioVerbs = ref.watch(activeScenarioPhrasalVerbsProvider);
    final stats = ref.watch(phrasalVerbsStatsProvider);

    final Color accentColor = TabTheme.phrasalVerbs.accent; // Amarillo Dorado / Gold

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phrasal Verbs for Work & Tech',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Situaciones reales, dailies, incidencias y arquitectura',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: KeyedSubtree(
              key: _kCoachParticles,
              child: InkWell(
                onTap: () {
                  AppHaptics.light();
                  context.push('/phrasal-verbs/catalog');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF9C3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFEF08A),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 19,
                        color: accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Partículas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF854D0E),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Selector de Escenario Comunicativo (Eje Principal)
              KeyedSubtree(
                key: _kCoachScenario,
                child: _buildScenarioSelector(context, ref, state.activeScenario, accentColor),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // 2. HERO CARD DOMINANTE: Continuar mi ruta
              // ==========================================
              KeyedSubtree(
                key: _kCoachHero,
                child: _buildDominantHeroCard(
                  context: context,
                  ref: ref,
                  scenario: state.activeScenario,
                  scenarioVerbs: scenarioVerbs,
                  stats: stats,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(height: 16),

              // Mini Barra de Progreso de Habilidades
              _buildMiniMetricsBar(stats, accentColor),
              const SizedBox(height: 24),

              // ==========================================
              // 3. Practica rapida (Cards Secundarias Compactas)
              // ==========================================
              _buildSectionHeader('PRÁCTICA RÁPIDA DE REFLEJOS', Icons.bolt_rounded, const Color(0xFFD97706)),
              const SizedBox(height: 12),
              KeyedSubtree(
                key: _kCoachQuickPractice,
                child: _buildQuickPracticeCards(context, accentColor),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // 4. Pronunciacion y oido (HVPT & Connected Speech)
              // ==========================================
              _buildSectionHeader('PRONUNCIACIÓN Y OÍDO (CONNECTED SPEECH)', Icons.headphones_rounded, const Color(0xFF0D9488)),
              const SizedBox(height: 12),
              _buildListeningPronunciationCard(context, scenarioVerbs, accentColor),
              const SizedBox(height: 24),

              // ==========================================
              // 5. Aplicacion real (Mini Standup / Incidente)
              // ==========================================
              _buildSectionHeader('TRANSFERENCIA A SITUACIONES REALES (STAR)', Icons.record_voice_over_rounded, const Color(0xFFD97706)),
              const SizedBox(height: 12),
              _buildRealApplicationCard(context, state.activeScenario, accentColor),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioSelector(
    BuildContext context,
    WidgetRef ref,
    PhrasalScenario activeScenario,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              Row(
                children: [
                  Icon(Icons.layers_rounded, size: 16, color: accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'Escenario Profesional:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFEF08A)),
                ),
                child: Text(
                  activeScenario.cefr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF854D0E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Todos los escenarios visibles a la vez (varias filas), sin scroll
          // horizontal oculto: mismo estilo de pill que Verbs Lab.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PhrasalScenario.values.map((s) {
              final isSelected = s == activeScenario;
              return _scenarioPill(
                label: s.shortLabel,
                isSelected: isSelected,
                accentColor: accentColor,
                onTap: () {
                  AppHaptics.selection();
                  ref.read(phrasalVerbsLabNotifierProvider.notifier).setActiveScenario(s);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _scenarioPill({
    required String label,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? accentColor : accentColor.withValues(alpha: 0.30),
            width: isSelected ? 1.2 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : accentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDominantHeroCard({
    required BuildContext context,
    required WidgetRef ref,
    required PhrasalScenario scenario,
    required List<PhrasalVerb> scenarioVerbs,
    required PhrasalVerbsStats stats,
    required Color accentColor,
  }) {
    final todayChunks = scenarioVerbs.take(3).map((v) => v.fullPhrase).join(', ');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.28), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Badge & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabTheme.aiFocusKicker(
                accentColor,
                isEn: ref.watch(localeProvider).languageCode == 'en',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  '${stats.scenarioMastered} / ${stats.scenarioTotal} Consolidados',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            scenario.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // Communicative Goal
          Text(
            scenario.communicativeGoal,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Today Practice Chunks
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFEF08A)),
            ),
            child: Row(
              children: [
                Icon(Icons.psychology_rounded, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hoy practicarás: $todayChunks',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF854D0E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Dominant CTA Button (Solid Vibrant with White Text)
          ElevatedButton(
            onPressed: () {
              AppHaptics.medium();
              context.push('/phrasal-verbs/session');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Continuar · 5 min',
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricsBar(PhrasalVerbsStats stats, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricColumn('Significado', '${(stats.meaningScore * 100).toInt()}%', accentColor),
          Container(width: 1, height: 26, color: TabTheme.surfaceContainerHigh),
          _buildMetricColumn('Contexto', '${(stats.contextScore * 100).toInt()}%', const Color(0xFF2563EB)),
          Container(width: 1, height: 26, color: TabTheme.surfaceContainerHigh),
          _buildMetricColumn('Listening', '${(stats.listeningScore * 100).toInt()}%', const Color(0xFF0D9488)),
          Container(width: 1, height: 26, color: TabTheme.surfaceContainerHigh),
          _buildMetricColumn('Orden', '${(stats.wordOrderScore * 100).toInt()}%', const Color(0xFFD97706)),
          Container(width: 1, height: 26, color: TabTheme.surfaceContainerHigh),
          _buildMetricColumn('Speaking', '${(stats.speakingScore * 100).toInt()}%', const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.firaCode(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPracticeCards(BuildContext context, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context: context,
            title: 'Orden y Separabilidad',
            subtitle: 'roll it back vs *roll back it',
            icon: Icons.swap_horiz_rounded,
            color: accentColor,
            onTap: () {
              AppHaptics.light();
              context.push('/phrasal-verbs/session?mode=separability');
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionCard(
            context: context,
            title: 'Significado Contextual',
            subtitle: 'Deduccion en escenario',
            icon: Icons.lightbulb_outline_rounded,
            color: const Color(0xFF2563EB),
            onTap: () {
              AppHaptics.light();
              context.push('/phrasal-verbs/session?mode=meaning');
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionCard(
            context: context,
            title: 'Errores FSRS',
            subtitle: 'Repaso adaptativo',
            icon: Icons.sync_problem_rounded,
            color: const Color(0xFFDC2626),
            onTap: () {
              AppHaptics.light();
              context.push('/phrasal-verbs/session?mode=mistakes');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: TabTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TabTheme.surfaceContainerHigh),
          boxShadow: TabTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningPronunciationCard(
    BuildContext context,
    List<PhrasalVerb> scenarioVerbs,
    Color accentColor,
  ) {
    final sampleVerb = scenarioVerbs.isNotEmpty ? scenarioVerbs.first : null;
    final chunkPreview = sampleVerb?.connectedSpeechChunk ?? 'spin‿up';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.headphones_rounded, size: 18, color: Color(0xFF0D9488)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected Speech & HVPT',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Enlace fonético natural: $chunkPreview (0.8x / 1.0x / 1.1x)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              AppHaptics.light();
              context.push('/phrasal-verbs/session?mode=listening');
            },
            icon: const Icon(Icons.graphic_eq_rounded, size: 16, color: Colors.white),
            label: const Text('Entrenar Oído y Connected Speech'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealApplicationCard(
    BuildContext context,
    PhrasalScenario scenario,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.record_voice_over_rounded, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mini Standup & Incident Prompt',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Responde oralmente usando phrasal verbs en ${scenario.title.toLowerCase()}.',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              AppHaptics.light();
              context.push('/phrasal-verbs/session?mode=speaking');
            },
            icon: const Icon(Icons.mic_rounded, size: 16, color: Colors.white),
            label: const Text('Simular Standup / Incidencia (Oral)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(double.infinity, 38),
            ),
          ),
        ],
      ),
    );
  }
}

