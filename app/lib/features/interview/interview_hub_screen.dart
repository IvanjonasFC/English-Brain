import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/widgets/glossy_button.dart';
import '../../core/widgets/coach_marks.dart';
import '../../core/providers/app_providers.dart';
import '../../core/pedagogy/contracts.dart';
import '../../core/pedagogy/taxonomy.dart';
import 'interview_screen.dart';
import 'interview_pack_intro_screen.dart';
import 'providers/interview_packs_provider.dart';
import '../vocabulary/vocabulary_repository.dart' show Cefr;

/// Interview hub — estética Duolingo/Glassmorphism:
/// Selector de dominio (Inglés General / Tech), píldoras de nivel CEFR,
/// hero con gradiente adaptativo, y listado directo de todos los packs
/// con inicio inmediato en 1 solo tap sin pantallas intermedias.
class InterviewHubScreen extends ConsumerStatefulWidget {
  const InterviewHubScreen({super.key});

  @override
  ConsumerState<InterviewHubScreen> createState() => _InterviewHubScreenState();
}

class _InterviewHubScreenState extends ConsumerState<InterviewHubScreen> {
  final String _selectedMode = 'lesson';
  String _selectedLevel = 'all';
  bool _hasUserSelectedLevel = false;
  final String _selectedCategory = 'technical';
  String _selectedDomain = 'general'; // 'tech' vs 'general'

  final GlobalKey _kCoachToggle = GlobalKey();
  final GlobalKey _kCoachLevels = GlobalKey();
  final GlobalKey _kCoachHero = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowCoach());
  }

  Future<void> _maybeShowCoach() async {
    final cache = ref.read(localCacheProvider);
    if (await cache.hasSeenCoach('interview')) return;
    if (!mounted) return;
    await showCoachMarks(
      context,
      [
        CoachStep(
          targetKey: _kCoachToggle,
          title: 'Dos contextos de entrevista',
          body: 'Entrena entrevistas de RRHH y soft skills en Inglés General, o entrevistas técnicas de ingeniería en Tech / IT Executive.',
        ),
        CoachStep(
          targetKey: _kCoachLevels,
          title: 'Nivel de seniority profesional',
          body: 'Ajusta la profundidad de las respuestas desde Foundations (Junior) hasta Strategic (Staff / Lead / VP).',
        ),
        CoachStep(
          targetKey: _kCoachHero,
          title: 'Práctica adaptativa en tiempo real',
          body: 'Simula preguntas reales de entrevista con evaluación de fluidez, análisis STAR y vocabulario técnico clave.',
        ),
        const CoachStep(
          title: '4 Modos de entrenamiento',
          body: 'Elige entre Lección Guiada con pistas, Examen Checkpoint, Mock Interview multi-turno o Shadowing Senior para entrenar cadencia.',
        ),
      ],
      accent: TabTheme.speaking.accent,
    );
    await cache.markCoachSeen('interview');
  }

  final List<Map<String, dynamic>> _modes = [
    {'id': 'lesson', 'label': 'Lección Guiada', 'icon': Icons.school_rounded, 'desc': 'Pregunta con tips visibles y chips de vocabulario clave sugerido.'},
    {'id': 'checkpoint', 'label': 'Checkpoint Exam', 'icon': Icons.verified_rounded, 'desc': 'Examen formal sin ayudas para evaluar fluidez y desbloquear nivel.'},
    {'id': 'mock', 'label': 'Full Mock Interview', 'icon': Icons.groups_rounded, 'desc': 'Simulación multi-turno de 5 preguntas técnicas consecutivas.'},
    {'id': 'shadowing', 'label': 'Shadowing Senior', 'icon': Icons.record_voice_over_rounded, 'desc': 'Escucha y repite la respuesta modelo para entrenar cadencia y fonética.'},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'id': 'technical', 'label': 'Core Technical', 'icon': Icons.terminal_rounded, 'count': 35},
    {'id': 'hr', 'label': 'HR & Behavioral', 'icon': Icons.person_rounded, 'count': 20},
    {'id': 'debugging', 'label': 'Live Debugging', 'icon': Icons.bug_report_rounded, 'count': 20},
    {'id': 'databases', 'label': 'Databases & Storage', 'icon': Icons.storage_rounded, 'count': 15},
    {'id': 'apis', 'label': 'APIs & Microservices', 'icon': Icons.cloud_sync_rounded, 'count': 15},
    {'id': 'teamwork', 'label': 'Teamwork & Agile', 'icon': Icons.handshake_rounded, 'count': 15},
    {'id': 'devops', 'label': 'DevOps & CI/CD', 'icon': Icons.all_inclusive_rounded, 'count': 15},
    {'id': 'system_design', 'label': 'System Design & Scale', 'icon': Icons.schema_rounded, 'count': 15},
    {'id': 'ai_ml', 'label': 'AI & LLM Engineering', 'icon': Icons.auto_awesome_rounded, 'count': 15},
    {'id': 'security', 'label': 'Cybersecurity & Auth', 'icon': Icons.shield_rounded, 'count': 15},
    {'id': 'cloud_arch', 'label': 'Cloud Architecture', 'icon': Icons.cloud_done_rounded, 'count': 15},
    {'id': 'portfolio', 'label': 'Portfolio Projects', 'icon': Icons.folder_special_rounded, 'count': 10},
    {'id': 'internships', 'label': 'Internships & Career', 'icon': Icons.school_outlined, 'count': 10},
  ];

  List<Map<String, String>> get _levels => TabTheme.cefrRail;

  void _launchPack(InterviewPack pack) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterviewScreen(
          initialCategory: InterviewPackIntroScreen.mapCategory(pack.scenario),
          initialDifficulty: InterviewPackIntroScreen.mapDifficulty(pack.band),
          initialMode: InterviewPackIntroScreen.mapMode(pack.mode),
          initialQuestionId: pack.questionIds.isNotEmpty ? pack.questionIds.first : null,
        ),
      ),
    );
  }

  void _startInterview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterviewScreen(
          initialCategory: _recommendedCategoryId(),
          initialDifficulty: _difficultyForCefr(_selectedLevel),
          initialMode: _selectedMode,
        ),
      ),
    );
  }

  /// Categoría recomendada según el perfil (objetivo + rol). Antes era fija
  /// ('technical'); ahora se adapta al usuario para respaldar el badge
  /// "TU FOCO DE HOY · IA". Siempre devuelve un id existente en [_categories].
  String _recommendedCategoryId() {
    final profile = ref.read(activeProfileProvider).valueOrNull;
    final goal = (profile?.learningGoal ?? '').toLowerCase();
    final role = (profile?.roleTitle ?? '').toLowerCase();
    if (goal.contains('hr') || goal.contains('behavioral') || goal.contains('soft')) {
      return 'hr';
    }
    if (role.contains('devops') || role.contains('sre') || role.contains('cloud')) {
      return 'devops';
    }
    if (role.contains('data') || role.contains('ml') || role.contains(' ai')) {
      return 'ai_ml';
    }
    if (role.contains('secur') || role.contains('segur')) {
      return 'security';
    }
    return _selectedCategory; // fallback: Core Technical
  }

  String _difficultyForCefr(String cefrId) {
    switch (cefrId) {
      case 'A1-A2':
        return 'junior';
      case 'B1':
      case 'B2':
      case 'B1-B2':
        return 'mid';
      case 'B2-C1':
      case 'C1':
      case 'C1 Executive':
        return 'senior';
      default:
        return 'mid';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale.languageCode == 'en';

    final profile = ref.watch(activeProfileProvider).valueOrNull;
    if (!_hasUserSelectedLevel && profile != null) {
      _selectedLevel = TabTheme.defaultPillForUserLevel(profile.targetLevel);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => refreshInterview(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildTitleSection(isEn),
              const SizedBox(height: 16),
              KeyedSubtree(key: _kCoachToggle, child: _buildSegmentedToggle(isEn)),
              const SizedBox(height: 14),
              KeyedSubtree(key: _kCoachLevels, child: _levelPills()),
              const SizedBox(height: 18),
              KeyedSubtree(key: _kCoachHero, child: _hero()),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isEn ? 'Oral Practice & Interview Packs' : 'Packs de Expresión Oral & Entrevista',
                        style: TabTheme.titleMd(fw: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _packsSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isEn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Speaking & Interviews' : 'Speaking & Entrevistas',
          style: TabTheme.displayMd(fw: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          isEn
              ? 'Adaptive oral training with Whisper acoustic evaluation and STAR structure analysis for technical roles.'
              : 'Entrenamiento oral adaptativo con evaluación acústica Whisper y análisis de estructura STAR para roles técnicos.',
          style: TabTheme.bodyMd(),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(bool isEn) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedDomain = 'general'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedDomain == 'general'
                      ? TabTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _selectedDomain == 'general'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 17,
                      color: _selectedDomain == 'general'
                          ? TabTheme.speaking.accent
                          : TabTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'General English' : 'Inglés General',
                      style: TabTheme.labelMd(
                        color: _selectedDomain == 'general'
                            ? TabTheme.onSurface
                            : TabTheme.onSurfaceVariant,
                        fw: _selectedDomain == 'general'
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedDomain = 'tech'),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedDomain == 'tech'
                      ? TabTheme.surfaceContainerLowest
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _selectedDomain == 'tech'
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      size: 17,
                      color: _selectedDomain == 'tech'
                          ? TabTheme.speaking.accent
                          : TabTheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEn ? 'Tech / IT Executive' : 'Tech / IT Executive',
                      style: TabTheme.labelMd(
                        color: _selectedDomain == 'tech'
                            ? TabTheme.onSurface
                            : TabTheme.onSurfaceVariant,
                        fw: _selectedDomain == 'tech'
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelPills() {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _levels.map((lvl) {
          final isSelected = lvl['id'] == _selectedLevel;
          return TabTheme.filterLevelPill(
            id: lvl['id']!,
            label: isEn ? lvl['en']! : lvl['es']!,
            isSelected: isSelected,
            onTap: () => setState(() {
              if (_selectedLevel == lvl['id']!) {
                _selectedLevel = 'all';
              } else {
                _selectedLevel = lvl['id']!;
              }
              _hasUserSelectedLevel = true;
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _hero() {
    final accent = TabTheme.speaking.accent;
    final activeMode = _modes.firstWhere((m) => m['id'] == _selectedMode);
    final recCategoryId = _recommendedCategoryId();
    final activeCategory = _categories.firstWhere(
      (c) => c['id'] == recCategoryId,
      orElse: () => _categories.first,
    );
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: AppTheme.isLight ? 0.14 : 0.08),
                    accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TabTheme.aiFocusKicker(accent, isEn: isEn),
                    Icon(
                      Icons.record_voice_over_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isEn ? 'Adaptive STAR Simulation' : 'Simulación Adaptativa STAR',
                  style: TabTheme.headlineSm(fw: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activeMode['label']} • ${activeCategory['label']}. ${isEn ? 'Real-time Whisper acoustic evaluation and STAR analysis.' : 'Evaluación acústica Whisper y análisis de respuesta STAR.'}',
                  style: TabTheme.bodyMd(color: TabTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      isEn ? '• 5 adaptive questions' : '• 5 preguntas adaptativas',
                      style: TabTheme.labelSm(
                        color: accent,
                        fw: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: TabTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '12 min',
                          style: TabTheme.labelSm(
                            color: TabTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GlossyButton(
                  color: accent,
                  onPressed: _startInterview,
                  height: 52,
                  radius: 26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 6),
                      Text(isEn ? 'Start Adaptive Session' : 'Empezar práctica adaptativa'),
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

  Widget _packsSection() {
    final packsAsync = ref.watch(interviewPacksProvider);

    return packsAsync.when(
      data: (allPacks) {
        final filtered = allPacks.where((p) {
          final domainMatch = p.domain == _selectedDomain;
          final levelMatch = _selectedLevel == 'all' || Cefr.matchesPill(p.band.label, _selectedLevel);
          return domainMatch && levelMatch;
        }).toList();

        if (filtered.isEmpty) return _emptyPacksState();

        return Column(
          children: filtered.map(_packRow).toList(),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: TabTheme.speaking.accent)),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('Error cargando packs: $err', style: const TextStyle(color: AppTheme.error))),
      ),
    );
  }

  Widget _emptyPacksState() {
    final lvl = _levels.firstWhere((l) => l['id'] == _selectedLevel, orElse: () => _levels.first);
    final domainLabel = _selectedDomain == 'general' ? 'Inglés General' : 'Entrevista / Tech';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.auto_stories_rounded, size: 44, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
            const SizedBox(height: 14),
            Text('Sin packs de nivel ${lvl['es']} en $domainLabel',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Text('Prueba seleccionar "Todos" u otro nivel en las píldoras de arriba.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _packRow(InterviewPack pack) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isA1A2 = pack.band == DifficultyBand.a2b1;
    final iconColor = isA1A2 ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
    final iconBg = isA1A2 ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5);
    final iconData = isA1A2 ? Icons.chat_bubble_outline_rounded : Icons.psychology_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InterviewPackIntroScreen(pack: pack),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TabTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: TabTheme.surfaceContainerHigh),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera unificada: meta (min) + dificultad (CEFR) a la derecha.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TabTheme.cefrPill(
                      '${pack.band.label} • ${pack.domain == 'tech' ? 'Tech' : 'General'}'),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 3.5),
                      Text(
                        '${pack.estMinutes} min',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                pack.subtopic,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${pack.scenario.name.toUpperCase()} · ${pack.feedbackType}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => _launchPack(pack),
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    isEn ? 'Start oral practice' : 'Iniciar práctica oral',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TabTheme.speaking.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
