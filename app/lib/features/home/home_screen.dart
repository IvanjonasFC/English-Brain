import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/theme/app_haptics.dart';
import '../../core/widgets/coach_marks.dart';
import '../phonetics/hvpt_exercise_screen.dart';
import '../phonetics/widgets/phoneme_heatmap_widget.dart';
import '../irregular_verbs/providers/irregular_verbs_provider.dart';
import '../phrasal_verbs/providers/phrasal_verbs_provider.dart';

// --- Home Theme Tokens (Stitch) ---
class HomeTheme {
  static Color get surface => AppTheme.surface;
  static Color get onSurface => AppTheme.textPrimary;
  static Color get onSurfaceVariant => AppTheme.textSecondary;
  
  static Color get surfaceContainerLowest => TabTheme.surfaceContainerLowest;
  static Color get surfaceContainerLow => TabTheme.surfaceContainerLow;
  static Color get surfaceContainer => TabTheme.surfaceContainer;
  static Color get surfaceContainerHigh => TabTheme.surfaceContainerHigh;
  static Color get surfaceContainerHighest => TabTheme.surfaceContainerHighest;
  static Color get outlineVariant => TabTheme.outlineVariant;

  static Color get primary => TabTheme.speaking.accent;
  static Color get onPrimary => const Color(0xFFFFFFFF);
  static Color get primaryFixed => TabTheme.speaking.container;
  static Color get onPrimaryFixed => TabTheme.speaking.accent;
  static Color get primaryContainer => TabTheme.speaking.containerHigh;

  static Color get secondary => AppTheme.isLight ? const Color(0xFF545F73) : const Color(0xFF9CB8E8);
  static Color get secondaryFixed => AppTheme.isLight ? const Color(0xFFD8E3FB) : const Color(0xFF1F2B3E);
  static Color get onSecondaryFixed => AppTheme.isLight ? const Color(0xFF111C2D) : const Color(0xFFD8E3FB);
  static Color get secondaryContainer => AppTheme.isLight ? const Color(0xFFD5E0F8) : const Color(0xFF25334A);
  static Color get onSecondaryContainer => AppTheme.isLight ? const Color(0xFF586377) : const Color(0xFF9CB8E8);

  static Color get tertiary => AppTheme.isLight ? const Color(0xFF3D6654) : const Color(0xFF7FC3A0);
  static Color get tertiaryFixed => AppTheme.isLight ? const Color(0xFFBFEDD5) : const Color(0xFF142B20);
  static Color get onTertiaryFixed => AppTheme.isLight ? const Color(0xFF002115) : const Color(0xFFBFEDD5);
  static Color get tertiaryContainer => AppTheme.isLight ? const Color(0xFF6F9A86) : const Color(0xFF1C3D2E);
  static Color get onTertiaryContainer => AppTheme.isLight ? const Color(0xFF033122) : const Color(0xFF7FC3A0);

  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -0.72, height: 1.22);
  static TextStyle get displayMd => GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.56, height: 1.28);
  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.24, height: 1.33);
  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.20, height: 1.4);
  static TextStyle get titleMd => GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.5);
  static TextStyle get titleSm => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.14, height: 1.42);
  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.16, height: 1.5);
  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.14, height: 1.42);
  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.24, height: 1.33);
  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.14, height: 1.42);
  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.24, height: 1.33);
  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.4, height: 1.4);
}

// --- Modelos ---
class _Level {
  final String label;
  final double progress;
  const _Level(this.label, this.progress);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _kCoachHero = GlobalKey();
  final GlobalKey _kCoachFsrs = GlobalKey();
  final GlobalKey _kCoachIrregularVerbs = GlobalKey();
  final GlobalKey _kCoachPhrasalVerbs = GlobalKey();
  final GlobalKey _kCoachPhonetics = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('home')) return;
    if (!mounted) return;
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Tu panel de control diario',
          body: 'Revisa tu nivel objetivo, tu racha activa y tu índice de preparación general (Readiness) adaptado a tu perfil profesional.',
        ),
        CoachStep(
          targetKey: _kCoachFsrs,
          title: 'Repaso Espaciado Inteligente (FSRS)',
          body: 'Algoritmo de memoria a largo plazo que calcula matemáticamente cuándo estás a punto de olvidar un término técnico para repasarlo en el momento óptimo.',
        ),
        CoachStep(
          targetKey: _kCoachIrregularVerbs,
          title: 'Laboratorio de Verbos Irregulares',
          body: 'Aprende conjugaciones clasificadas por familias fonéticas, entrena discriminación auditiva y practica pronunciación nativa con feedback instantáneo.',
        ),
        CoachStep(
          targetKey: _kCoachPhrasalVerbs,
          title: 'Phrasal Verbs for Work & Tech',
          body: 'Domina los verbos frasales esenciales para dailies, deploys, incidentes y arquitectura técnica, con reglas de separabilidad y connected speech.',
        ),
        CoachStep(
          targetKey: _kCoachPhonetics,
          title: 'Laboratorio Fonético (HVPT)',
          body: 'Reentrena tu corteza auditiva mediante pares mínimos sutiles con audio neuronal y visualiza tu progreso en el mapa de calor de 44 fonemas.',
        ),
      ],
      accent: HomeTheme.primary,
    );
    await cache.markCoachSeen('home');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final summary = ref.watch(profileSummaryProvider).valueOrNull;
    final dueCards = ref.watch(dueCardsCountProvider).valueOrNull ?? 0;

    final name = (profile?.displayName ?? '').trim();
    final firstName = name.isEmpty ? 'Iván' : name.split(' ').first;
    final streak = profile?.streakDays ?? 0;
    final target = profile?.targetLevel ?? 'B2';
    final goal = profile?.learningGoal ?? 'interview_prep';
    final role = profile?.roleTitle ?? 'Software Engineer';

    final completed = summary?.completedUnits ?? 0;
    final words = summary?.masteredWords ?? 0;
    final sessions = summary?.totalSessions ?? 0;

    // Nivel estimado por área (adaptativo con el progreso real, 0 baseline)
    final g = _estimate(completed, const [2, 5, 10, 17]);
    final v = _estimate(words, const [10, 50, 150, 350]);
    final s = _estimate(sessions, const [1, 5, 15, 30]);

    // Readiness average
    final readinessProgress = ((g.progress + v.progress + s.progress) / 3 * 100).round().clamp(0, 100);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: HomeTheme.primary,
          onRefresh: () async {
            ref.invalidate(profileSummaryProvider);
            ref.invalidate(activeProfileProvider);
            ref.invalidate(dueCardsCountProvider);
            await ref.read(profileSummaryProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(top: 20, bottom: 40, left: 16, right: 16),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            children: [
              KeyedSubtree(
                key: _kCoachHero,
                child: _buildHero(context, firstName, target, streak, readinessProgress, goal, role),
              ),
              const SizedBox(height: 24),
              KeyedSubtree(
                key: _kCoachFsrs,
                child: _buildFsrsSection(context, dueCards, words, streak),
              ),
              const SizedBox(height: 24),
              KeyedSubtree(
                key: _kCoachIrregularVerbs,
                child: _buildIrregularVerbsSection(context, ref),
              ),
              const SizedBox(height: 24),
              KeyedSubtree(
                key: _kCoachPhrasalVerbs,
                child: _buildPhrasalVerbsSection(context, ref),
              ),
              const SizedBox(height: 24),
              KeyedSubtree(
                key: _kCoachPhonetics,
                child: _buildPhoneticLaboratorioCard(context, ref),
              ),
              const SizedBox(height: 24),
              _buildFreeTalkSection(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  _Level _estimate(int value, List<int> t) {
    if (value <= 0) {
      return const _Level('A1', 0.0);
    }
    String label;
    if (value >= t[3]) {
      label = 'C1';
    } else if (value >= t[2]) {
      label = 'B2';
    } else if (value >= t[1]) {
      label = 'B1';
    } else if (value >= t[0]) {
      label = 'A2';
    } else {
      label = 'A1';
    }
    final progress = (value / t[3]).clamp(0.0, 1.0).toDouble();
    return _Level(label, progress);
  }

  Widget _buildHero(BuildContext context, String name, String target, int streak, int readiness, String goal, String role) {
    // Dynamic Route based on Learning Goal
    String routeTitle;
    String routeSubtitle;
    String routeUrl;
    String routeMinutes = '12 min';

    switch (goal) {
      case 'technical_career':
      case 'system_design':
        routeTitle = 'System Architecture & Resiliency';
        routeSubtitle = 'Justifica trade-offs de alta disponibilidad, latencia y partición de datos.';
        routeUrl = '/interview/pack-intro?pack_id=system_design';
        routeMinutes = '15 min';
        break;
      case 'daily_meetings':
      case 'workplace':
        routeTitle = 'Agile Standups & Sprint Blockers';
        routeSubtitle = 'Comunica el estado de tus entregables, dependencias e impedimentos con fluidez.';
        routeUrl = '/interview/pack-intro?pack_id=agile_rituals';
        routeMinutes = '10 min';
        break;
      case 'client_negotiation':
        routeTitle = 'Stakeholder Scope & SLA Negotiation';
        routeSubtitle = 'Defiende plazos y acuerdos de servicio usando diplomacia y asertividad técnica.';
        routeUrl = '/interview/pack-intro?pack_id=client_negotiation';
        routeMinutes = '14 min';
        break;
      case 'daily_fluency':
      case 'general_fluency':
        routeTitle = 'Daily Fluency & Natural Phrasing';
        routeSubtitle = 'Elimina muletillas y gana agilidad expresándote en situaciones cotidianas.';
        routeUrl = '/comprehension';
        routeMinutes = '10 min';
        break;
      case 'interviews':
        routeTitle = 'Behavioral & Core Technical (STAR)';
        routeSubtitle = 'Entrena respuestas de impacto usando el marco STAR ante preguntas clave.';
        routeUrl = '/interview/session?mode=mock';
        routeMinutes = '15 min';
        break;
      case 'all_around':
      case 'interview_prep':
      default:
        routeTitle = 'Incident Management & RCA (STAR)';
        routeSubtitle = 'Defiende un post-mortem técnico estructurado usando el método STAR bajo presión.';
        routeUrl = '/interview/pack-intro?pack_id=devops';
        routeMinutes = '12 min';
        break;
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          // Background blobs
          Positioned(
            right: -48,
            top: -48,
            child: Container(
              width: 192,
              height: 192,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HomeTheme.primaryFixed.withValues(alpha: AppTheme.isLight ? 0.45 : 0.2),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: HomeTheme.secondaryFixed.withValues(alpha: AppTheme.isLight ? 0.45 : 0.2),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Hola, $name', style: HomeTheme.headlineSm.copyWith(color: HomeTheme.onSurface)),
                            const SizedBox(width: 6),
                            Icon(Icons.waving_hand_rounded, size: 20, color: HomeTheme.primary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/stats'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: HomeTheme.primaryFixed,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_fire_department_rounded, color: HomeTheme.primary, size: 14),
                                    const SizedBox(width: 2),
                                    Text('${streak}d', style: HomeTheme.labelSm.copyWith(color: HomeTheme.onPrimaryFixed)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: HomeTheme.tertiaryFixed,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.insights_rounded, color: HomeTheme.tertiary, size: 14),
                                  const SizedBox(width: 2),
                                  Text(target, style: HomeTheme.labelSm.copyWith(color: HomeTheme.onTertiaryFixed)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.push('/stats'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: HomeTheme.secondaryFixed,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.timeline_rounded, color: HomeTheme.secondary, size: 13),
                                    const SizedBox(width: 3),
                                    Text('Progreso', style: HomeTheme.labelSm.copyWith(color: HomeTheme.onSecondaryFixed)),
                                    const SizedBox(width: 1),
                                    Icon(Icons.chevron_right_rounded, color: HomeTheme.onSecondaryFixed, size: 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/stats'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: HomeTheme.tertiaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded, color: HomeTheme.tertiary, size: 18),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('READINESS', style: HomeTheme.labelSm.copyWith(color: HomeTheme.onTertiaryContainer, fontSize: 8)),
                                Text('$readiness%', style: HomeTheme.titleSm.copyWith(color: HomeTheme.onTertiaryContainer, height: 1.0)),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.chevron_right_rounded, color: HomeTheme.onTertiaryContainer, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Hero Session Banner (Adaptive to goal)
                Container(
                  padding: const EdgeInsets.all(20),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TabTheme.aiFocusKicker(
                            TabTheme.speaking.accent,
                            isEn: Localizations.localeOf(context).languageCode == 'en',
                          ),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 16, color: HomeTheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(routeMinutes, style: HomeTheme.labelSm.copyWith(color: HomeTheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(routeTitle, style: HomeTheme.titleMd.copyWith(color: HomeTheme.onSurface, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(routeSubtitle, style: HomeTheme.bodySm.copyWith(color: HomeTheme.onSurfaceVariant)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppTheme.isLight
                                      ? [const Color(0xFFF29B63), const Color(0xFFEA8E51)]
                                      : [const Color(0xFFF7B489), const Color(0xFFEA8E51)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEA8E51).withValues(alpha: AppTheme.isLight ? 0.30 : 0.20),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => context.go(routeUrl),
                                  borderRadius: BorderRadius.circular(999),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.play_arrow_rounded, size: 22, color: Colors.white),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Iniciar Sesión',
                                          style: HomeTheme.labelLg.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildIrregularVerbsSection(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final stats = ref.watch(irregularVerbsStatsProvider);
    const accentColor = Color(0xFF0D9488); // Teal Tecnológico C1

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.isLight ? const Color(0xFFF0FDFA) : const Color(0xFF134E4A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF99F6E4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_stories_rounded, size: 14, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            isEn ? 'IRREGULAR VERBS MATRIX' : 'MATRIZ DE VERBOS IRREGULARES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: stats.masteredCount > 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: stats.masteredCount > 0 ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        '${stats.masteredCount} / ${stats.totalVerbs} Dominados',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: stats.masteredCount > 0 ? const Color(0xFF059669) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'Master Irregular Verbs' : 'Domina los Verbos Irregulares',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HomeTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Master conjugation patterns (A-A-A, A-B-B, i-a-u), native IPA pronunciation and audio sequences to speak without hesitation.'
                      : 'Practica la matriz de conjugación interactiva, la pronunciación nativa de cada tiempo y audios encadenados para no dudar al hablar.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: HomeTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Verbos Dominados', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('${stats.masteredCount}', style: GoogleFonts.firaCode(fontSize: 15, fontWeight: FontWeight.bold, color: accentColor)),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text('Patrones Clave', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('8 Grupos', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: HomeTheme.onSurface)),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text('Audio y Fonética', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('Kokoro HD', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppHaptics.medium();
                          context.push('/irregular-verbs');
                        },
                        icon: const Icon(Icons.auto_stories_rounded, size: 20),
                        label: Text(
                          isEn ? 'Explore Verbs Matrix' : 'Explorar Matriz de Verbos',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: () {
                        AppHaptics.light();
                        context.push('/irregular-verbs');
                      },
                      icon: const Icon(Icons.sports_esports_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: accentColor.withValues(alpha: 0.12),
                        foregroundColor: accentColor,
                        padding: const EdgeInsets.all(13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhrasalVerbsSection(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final phrasalState = ref.watch(phrasalVerbsLabNotifierProvider);
    final allVerbs = ref.watch(allPhrasalVerbsProvider);

    int masteredCount = 0;
    int interviewReadyCount = 0;
    for (final v in allVerbs) {
      final m = phrasalState.metricsByVerb[v.id];
      if (m != null) {
        if (m.isMastered) masteredCount++;
        if (m.isInterviewReady) interviewReadyCount++;
      }
    }
    final totalCount = allVerbs.length;
    final accentColor = TabTheme.phrasalVerbs.accent; // Amarillo Dorado / Gold

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFEF08A), width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hub_rounded,
                            size: 14,
                            color: Color(0xFF854D0E),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isEn ? 'PHRASAL VERBS FOR WORK & TECH' : 'PHRASAL VERBS FOR WORK & TECH',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF854D0E),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: masteredCount > 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: masteredCount > 0 ? const Color(0xFFA7F3D0) : const Color(0xFFFEF08A),
                        ),
                      ),
                      child: Text(
                        '$masteredCount / $totalCount Consolidados',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: masteredCount > 0 ? const Color(0xFF059669) : const Color(0xFF854D0E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'Phrasal Verbs for Work & Tech' : 'Phrasal Verbs for Work & Tech',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HomeTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Rutas guiadas por situaciones comunicativas reales: reuniones diarias, deploys, incidencias, debugging y decisiones técnicas con connected speech.'
                      : 'Rutas guiadas por situaciones comunicativas reales: reuniones diarias, deploys, incidencias, debugging y decisiones técnicas con connected speech.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: HomeTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Bar (Unified with other cards)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Consolidados', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text(
                            '$masteredCount',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text('Rutas Laborales', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('7 Escenarios', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: HomeTheme.onSurface)),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text('STAR Ready', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('$interviewReadyCount listos', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppHaptics.medium();
                          context.push('/phrasal-verbs');
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
                        label: Text(
                          isEn ? 'Open Phrasal Verbs Lab' : 'Entrenar Situaciones Reales',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filledTonal(
                      onPressed: () {
                        AppHaptics.light();
                        context.push('/phrasal-verbs/catalog');
                      },
                      icon: const Icon(Icons.explore_outlined, size: 20),
                      tooltip: 'Explorar Mapa de Partículas',
                      style: IconButton.styleFrom(
                        backgroundColor: accentColor.withValues(alpha: 0.12),
                        foregroundColor: accentColor,
                        padding: const EdgeInsets.all(13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneticLaboratorioCard(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final progressAsync = ref.watch(userPhonemeProgressStreamProvider);
    final records = progressAsync.valueOrNull ?? [];

    int mastered = 0;
    for (final r in records) {
      if (r.attempts >= 8 && r.recencyWeightedGop >= 80) {
        mastered++;
      }
    }
    final totalAttempts = records.fold<int>(0, (sum, r) => sum + r.attempts);
    final meanScore = records.isEmpty
        ? 0
        : (records.fold<double>(0, (sum, r) => sum + r.recencyWeightedGop) / records.length).round();

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.25), width: 1.5),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0284C7).withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F9FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.graphic_eq_rounded, size: 14, color: Color(0xFF0284C7)),
                          const SizedBox(width: 4),
                          Text(
                            isEn ? 'NEURAL PHONETICS C1' : 'LABORATORIO FONÉTICO C1',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0284C7),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        '$mastered / 44 Fonemas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'High-Variability Ear Training (HVPT)' : 'Entrenamiento Auditivo y Oído Nativo (HVPT)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HomeTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Retune your temporal cortex to distinguish subtle English minimal pairs (/ɪ/ vs /iː/, /θ/ vs /s/, /v/ vs /b/) synthesized with studio neural voices.'
                      : 'Recondiciona tu corteza auditiva para distinguir contrastes nativos que no existen en español mediante pares mínimos con voz neuronal de estudio.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: HomeTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Sensibilidad Media', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('$meanScore%', style: GoogleFonts.firaCode(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0284C7))),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text('Ensayos Totales', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('$totalAttempts', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: HomeTheme.onSurface)),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text('Motor Acústico', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('Kokoro HD', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppHaptics.medium();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HvptExerciseScreen()),
                          );
                        },
                        icon: const Icon(Icons.hearing_rounded, size: 20),
                        label: Text(
                          isEn ? 'Start HVPT Session (2 min)' : 'Entrenar Oído A/B (2 min)',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFsrsSection(BuildContext context, int dueCards, int masteredWords, int streakDays) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    const accentColor = Color(0xFF6366F1); // Indigo / Morado FSRS

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.isLight ? const Color(0xFFEEF2FF) : const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.layers_rounded, size: 14, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            isEn ? 'SPACED REPETITION (FSRS)' : 'REPASO ESPACIADO INTELIGENTE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: dueCards > 0 ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: dueCards > 0 ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Text(
                        dueCards > 0
                            ? '$dueCards ${isEn ? "Due Today" : "Pendientes"}'
                            : (isEn ? 'Deck up to date' : 'Mazo al día'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: dueCards > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'Smart Flashcard Review (FSRS v4)' : 'Mazo de Flashcards y Memoria a Largo Plazo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HomeTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Consolidate technical vocabulary and active STAR phrases with optimal spaced intervals before memory decay occurs.'
                      : 'Consolida vocabulario técnico y estructuras STAR mediante repetición espaciada FSRS calculada antes de la curva del olvido.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: HomeTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats Bar (idéntico a Laboratorio Fonético)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            isEn ? 'Due for Review' : 'Por Repasar',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dueCards',
                            style: GoogleFonts.firaCode(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text(
                            isEn ? 'Retention Goal' : 'Retención Meta',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '92%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 26, color: const Color(0xFFE2E8F0)),
                      Column(
                        children: [
                          Text(
                            isEn ? 'Mastered Words' : 'Términos Clave',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: HomeTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$masteredWords',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: HomeTheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          AppHaptics.medium();
                          context.go('/deck?start=true');
                        },
                        icon: Icon(
                          dueCards > 0 ? Icons.play_arrow_rounded : Icons.replay_rounded,
                          size: 20,
                        ),
                        label: Text(
                          dueCards > 0
                              ? (isEn ? 'Start Review ($dueCards)' : 'Iniciar Repaso ($dueCards)')
                              : (isEn ? 'Review Deck' : 'Repasar Flashcards'),
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        AppHaptics.selection();
                        context.go('/deck');
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.isLight ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
                        foregroundColor: HomeTheme.onSurfaceVariant,
                        padding: const EdgeInsets.all(13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: AppTheme.isLight ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      tooltip: isEn ? 'Deck details & metrics' : 'Ver métricas del mazo',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeTalkSection(BuildContext context, WidgetRef ref) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    const accentColor = Color(0xFF7C3AED);

    final quickTopics = [
      {'label': '💼 Daily Standup', 'topic': 'Daily Standup Updates'},
      {'label': '💻 System Design', 'topic': 'System Architecture & Tech Choices'},
      {'label': '🤝 Salary & Offer', 'topic': 'Salary Negotiation & Career Goals'},
      {'label': '🐛 Incident Postmortem', 'topic': 'Debugging a Production Incident'},
      {'label': '☕ Casual Tech Chat', 'topic': 'Casual Tech & Hobbies'},
    ];

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.isLight ? const Color(0xFFF5F3FF) : const Color(0xFF2E1065),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFDDD6FE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.smart_toy_rounded, size: 14, color: accentColor),
                          const SizedBox(width: 4),
                          Text(
                            isEn ? 'AI FREE TALK & VOICE' : 'CONVERSACIÓN LIBRE CON IA',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'IA Online',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  isEn ? 'AI Real-Time Free Talk' : 'Práctica Libre & Simulación Oral',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: HomeTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Practice open-ended English conversation with intelligent AI. Get instant CEFR grammar corrections, natural phrasing suggestions, and high-fidelity Kokoro TTS voice.'
                      : 'Habla o escribe libremente sobre cualquier tema o situación laboral. Recibe correcciones gramaticales en vivo, mejores alternativas C1/C2 y audio neuronal nativo.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: HomeTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickTopics.map((item) {
                    return InkWell(
                      onTap: () {
                        AppHaptics.selection();
                        context.push('/free-talk?topic=${Uri.encodeComponent(item['topic']!)}');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.isLight ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          item['label']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: HomeTheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AppHaptics.medium();
                      context.push('/free-talk');
                    },
                    icon: const Icon(Icons.mic_none_rounded, size: 20),
                    label: Text(
                      isEn ? 'Start AI Free Talk Session' : 'Iniciar Conversación con IA',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
}
