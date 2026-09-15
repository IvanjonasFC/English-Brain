import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/coach_marks.dart';
import 'providers/irregular_verbs_provider.dart';
import 'models/irregular_verb.dart';

class VerbsLabLandingScreen extends ConsumerStatefulWidget {
  const VerbsLabLandingScreen({super.key});

  @override
  ConsumerState<VerbsLabLandingScreen> createState() => _VerbsLabLandingScreenState();
}

class _VerbsLabLandingScreenState extends ConsumerState<VerbsLabLandingScreen> {
  final GlobalKey _kCoachCefr = GlobalKey();
  final GlobalKey _kCoachHero = GlobalKey();
  final GlobalKey _kCoachQuickDrills = GlobalKey();
  final GlobalKey _kCoachMatrix = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('irregular_verbs_lab')) return;
    if (!mounted) return;
    const accentColor = Color(0xFF0D9488);
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachCefr,
          title: 'Rutas por Nivel CEFR',
          body: 'Elige tu nivel de partida (A1 a C1+). Los verbos están seleccionados y adaptados para situaciones reales de trabajo y roles de software.',
        ),
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Sesión Guiada Adaptativa',
          body: 'Combina discriminación auditiva, corrección de errores, construcción en frase y speaking STAR en una sola sesión enfocada.',
        ),
        CoachStep(
          targetKey: _kCoachQuickDrills,
          title: 'Entrenamientos de Reflejo',
          body: 'Ejercicios rápidos de Pasado bajo presión, Participios y Tiempos Perfectos para responder sin titubear.',
        ),
        CoachStep(
          targetKey: _kCoachMatrix,
          title: 'Matriz Completa de Verbos',
          body: 'Explora todos los verbos organizados por patrones fonéticos (A-B-B, i-a-u, etc.) con audios nativos y análisis de pronunciación.',
        ),
      ],
      accent: accentColor,
    );
    await cache.markCoachSeen('irregular_verbs_lab');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verbsLabNotifierProvider);
    final stats = ref.watch(irregularVerbsStatsProvider);
    final routeVerbs = ref.watch(activeRouteVerbsProvider);
    final routeInfo = CefrRouteInfo.forBand(state.activeCefrRoute);

    const accentColor = Color(0xFF0D9488); // Teal Tecnológico C1

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
              'Verbs Lab',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Forma, oído y uso real en entrevistas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: KeyedSubtree(
              key: _kCoachMatrix,
              child: InkWell(
                onTap: () {
                  AppHaptics.light();
                  context.push('/irregular-verbs/matrix');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: AppTheme.isLight ? const Color(0xFFE6F7F5) : const Color(0xFF132E2B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        size: 19,
                        color: AppTheme.isLight ? const Color(0xFF0F766E) : const Color(0xFF5EEAD4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Matriz',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.isLight ? const Color(0xFF0F766E) : const Color(0xFFCCFBF1),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CEFR Difficulty Level Rail Canónico
            KeyedSubtree(
              key: _kCoachCefr,
              child: _buildCefrSelector(context, ref, state),
            ),
            const SizedBox(height: 16),

            // 1. HERO DOMINANTE: Continuar mi ruta
            KeyedSubtree(
              key: _kCoachHero,
              child: _buildContinueRouteHero(context, state, stats, routeInfo, routeVerbs, accentColor),
            ),
            const SizedBox(height: 16),

            // MINI BARRA DE PROGRESO DE HABILIDADES
            _buildMiniMetricsBar(stats, accentColor),
            const SizedBox(height: 22),

            // 2. PRÁCTICA RÁPIDA (Cards Secundarias Compactas)
            _buildSectionHeader('PRÁCTICA RÁPIDA DE REFLEJOS', Icons.bolt_rounded, const Color(0xFFD97706)),
            const SizedBox(height: 10),
            KeyedSubtree(
              key: _kCoachQuickDrills,
              child: _buildQuickDrillsSection(context, ref, accentColor),
            ),
            const SizedBox(height: 20),

            // 3. PRONUNCIACIÓN Y OÍDO (HVPT & Contrastes)
            _buildSectionHeader('PRONUNCIACIÓN Y OÍDO (HVPT)', Icons.headphones_rounded, const Color(0xFF0D9488)),
            const SizedBox(height: 10),
            _buildPronunciationAndEarSection(context, ref, accentColor),
            const SizedBox(height: 20),

            // 4. APLICACIÓN REAL (Mini STAR & Incidencias)
            _buildSectionHeader('TRANSFERENCIA A ENTREVISTA (STAR)', Icons.record_voice_over_rounded, const Color(0xFF0D9488)),
            const SizedBox(height: 10),
            _buildRealApplicationSection(context, ref, accentColor),
          ],
        ),
      ),
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
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCefrSelector(
    BuildContext context,
    WidgetRef ref,
    VerbsLabState state,
  ) {
    return Wrap(
      spacing: 0,
      runSpacing: 8,
      children: TabTheme.cefrRail.map((lvl) {
          final isSelected = state.activeCefrRoute.toLowerCase() == lvl['id']!.toLowerCase() ||
              (state.activeCefrRoute == 'C1+' && lvl['id'] == 'C1');
          return TabTheme.filterLevelPill(
            id: lvl['id']!,
            label: lvl['es']!,
            isSelected: isSelected,
            onTap: () {
              AppHaptics.light();
              final target = lvl['id'] == 'C1' ? 'C1+' : lvl['id']!;
              if (state.activeCefrRoute == target) {
                ref.read(verbsLabNotifierProvider.notifier).setActiveCefrRoute('all');
              } else {
                ref.read(verbsLabNotifierProvider.notifier).setActiveCefrRoute(target);
              }
            },
          );
        }).toList(),
    );
  }

  Widget _buildContinueRouteHero(
    BuildContext context,
    VerbsLabState state,
    VerbsLabStats stats,
    CefrRouteInfo routeInfo,
    List<IrregularVerb> routeVerbs,
    Color accentColor,
  ) {
    final todayVerbs = routeVerbs.take(3).map((v) => v.v2).join(', ');

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
          // Top row: Badges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TabTheme.aiFocusKicker(
                accentColor,
                isEn: ref.watch(localeProvider).languageCode == 'en',
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      '${stats.routeMastered} / ${stats.routeTotal} Consolidados',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF065F46)),
                    ),
                  ),
                  if (stats.routeInterviewReady > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Color(0xFFD97706)),
                          const SizedBox(width: 3),
                          Text(
                            '${stats.routeInterviewReady} STAR',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route Title & Communicative Goal
          Text(
            routeInfo.title,
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            routeInfo.communicativeGoal,
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 10),

          // Today's preview
          Text(
            'Hoy practicarás formas como: $todayVerbs',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
          ),

          // Optional notice for C1+
          if (routeInfo.isOptional && routeInfo.badgeNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF99F6E4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0F766E)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routeInfo.badgeNote!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF0F766E), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stats.routeProgress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 18),

          // Dominant Hero CTA - Verde realzado de la app
          ElevatedButton(
            onPressed: () {
              AppHaptics.medium();
              context.push('/irregular-verbs/session');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Continuar · 5 min',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricsBar(VerbsLabStats stats, Color accentColor) {
    final formsPct = (stats.formsScore * 100).round();
    final listeningPct = (stats.listeningScore * 100).round();
    final speakingPct = (stats.speakingScore * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniMetricItem('Recuperación (Forms)', '$formsPct%', const Color(0xFF0D9488)),
          Container(width: 1, height: 26, color: TabTheme.surfaceContainerHigh),
          _buildMiniMetricItem('Oído (Listening)', '$listeningPct%', const Color(0xFF2563EB)),
          Container(width: 1, height: 26, color: TabTheme.surfaceContainerHigh),
          _buildMiniMetricItem('Expresión (Speaking)', '$speakingPct%', const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildMiniMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.firaCode(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildQuickDrillsSection(BuildContext context, WidgetRef ref, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryCompactCard(
            title: 'Pasado bajo presión',
            subtitle: 'Pasado Simple instantáneo',
            icon: Icons.timer_outlined,
            color: const Color(0xFFD97706),
            onTap: () {
              AppHaptics.light();
              context.push('/irregular-verbs/session?mode=v2');
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSecondaryCompactCard(
            title: 'Participio y Perfectos',
            subtitle: '"I have ________..."',
            icon: Icons.done_all_rounded,
            color: const Color(0xFF0D9488),
            onTap: () {
              AppHaptics.light();
              context.push('/irregular-verbs/session?mode=v3');
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSecondaryCompactCard(
            title: 'Errores FSRS',
            subtitle: 'Refuerzo de fallos',
            icon: Icons.replay_rounded,
            color: const Color(0xFFDC2626),
            onTap: () {
              AppHaptics.light();
              context.push('/irregular-verbs/session?mode=mistakes');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPronunciationAndEarSection(BuildContext context, WidgetRef ref, Color accentColor) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.spatial_audio_off_rounded, color: Color(0xFF0D9488), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contrastes Fonéticos Clave',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      'Distingue y pronuncia: read /red/ vs /riːd/, built (/t/ final) y thought (/θ/)',
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
              context.push('/irregular-verbs/session?mode=listening');
            },
            icon: const Icon(Icons.graphic_eq_rounded, size: 16),
            label: const Text('Entrenar Oído y Voz (HVPT)'),
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

  Widget _buildRealApplicationSection(BuildContext context, WidgetRef ref, Color accentColor) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: Color(0xFF0D9488), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Respuestas STAR de Proyecto',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      '"Tell me about something you built or a critical incident you led"',
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
              AppHaptics.medium();
              context.push('/irregular-verbs/session?mode=speaking');
            },
            icon: const Icon(Icons.mic_rounded, size: 16),
            label: const Text('Simular Respuesta STAR (20-45s)'),
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

  Widget _buildSecondaryCompactCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: TabTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TabTheme.surfaceContainerHigh),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
