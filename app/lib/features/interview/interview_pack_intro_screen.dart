import 'package:flutter/material.dart';
import '../../core/widgets/glossy_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/pedagogy/contracts.dart';
import '../../core/pedagogy/taxonomy.dart';
import '../../core/providers/app_providers.dart';
import 'providers/interview_packs_provider.dart';
import 'interview_theme_tokens.dart';
import 'interview_screen.dart';

class InterviewPackIntroScreen extends ConsumerStatefulWidget {
  final InterviewPack pack;

  const InterviewPackIntroScreen({
    super.key,
    required this.pack,
  });

  static String mapCategory(LearningScenario scenario) {
    switch (scenario) {
      case LearningScenario.foundations:
        return 'hr';
      case LearningScenario.dailyEnglish:
        return 'teamwork';
      case LearningScenario.workplaceEnglish:
        return 'portfolio';
      case LearningScenario.hrInterview:
        return 'hr';
      case LearningScenario.debugging:
        return 'debugging';
      case LearningScenario.systemsDesign:
        return 'system_design';
      case LearningScenario.technicalInterview:
        return 'technical';
      case LearningScenario.teamwork:
        return 'teamwork';
    }
  }

  static String mapDifficulty(DifficultyBand band) {
    switch (band) {
      case DifficultyBand.a2b1:
        return 'junior';
      case DifficultyBand.b1b2:
        return 'mid';
      case DifficultyBand.b2c1:
      case DifficultyBand.c1:
        return 'senior';
    }
  }

  static String mapMode(PracticeMode mode) {
    switch (mode) {
      case PracticeMode.guided:
        return 'lesson';
      case PracticeMode.mock:
        return 'mock';
      case PracticeMode.checkpoint:
        return 'checkpoint';
      case PracticeMode.shadowing:
        return 'shadowing';
    }
  }

  @override
  ConsumerState<InterviewPackIntroScreen> createState() => _InterviewPackIntroScreenState();
}

class _InterviewPackIntroScreenState extends ConsumerState<InterviewPackIntroScreen> {
  int _expandedStarIndex = 2; // Default expand 'Action' (highest weight)
  String _packFilterTab = 'all'; // 'all' | 'basics' | 'star'
  String? _expandedConnector;

  void _launchSession(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InterviewScreen(
          initialCategory: InterviewPackIntroScreen.mapCategory(widget.pack.scenario),
          initialDifficulty: InterviewPackIntroScreen.mapDifficulty(widget.pack.band),
          initialMode: InterviewPackIntroScreen.mapMode(widget.pack.mode),
          initialQuestionId: widget.pack.questionIds.isNotEmpty ? widget.pack.questionIds.first : null,
        ),
      ),
    );
  }

  void _openPackSelectorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: InterviewTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final allPacks = ref.watch(interviewPacksProvider).value ?? [];
            final filteredPacks = allPacks.where((p) {
              if (_packFilterTab == 'basics') {
                return p.band == DifficultyBand.a2b1 || p.band == DifficultyBand.b1b2 && (p.scenario == LearningScenario.foundations || p.scenario == LearningScenario.workplaceEnglish || p.scenario == LearningScenario.teamwork);
              }
              if (_packFilterTab == 'star') {
                return p.band == DifficultyBand.b2c1 || p.band == DifficultyBand.c1 || p.subtopic.contains('STAR');
              }
              return true;
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.82,
              maxChildSize: 0.95,
              minChildSize: 0.45,
              builder: (ctx, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: InterviewTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.record_voice_over_rounded, color: InterviewTheme.primary, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Packs de Expresión Oral & Entrevista',
                                  style: InterviewTheme.titleMd(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Practica inglés oral desde nivel básico (A1) hasta entrevistas STAR (C1)',
                                  style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Tabs (Todos / Aprender de Cero / Entrevistas STAR)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: InterviewTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _buildFilterTabItem(
                              title: 'Todos (${allPacks.length})',
                              tabKey: 'all',
                              currentKey: _packFilterTab,
                              onTap: () {
                                setModalState(() => _packFilterTab = 'all');
                                setState(() => _packFilterTab = 'all');
                              },
                            ),
                            _buildFilterTabItem(
                              title: 'Básico / A1-B1',
                              tabKey: 'basics',
                              currentKey: _packFilterTab,
                              onTap: () {
                                setModalState(() => _packFilterTab = 'basics');
                                setState(() => _packFilterTab = 'basics');
                              },
                            ),
                            _buildFilterTabItem(
                              title: 'STAR / B2-C1',
                              tabKey: 'star',
                              currentKey: _packFilterTab,
                              onTap: () {
                                setModalState(() => _packFilterTab = 'star');
                                setState(() => _packFilterTab = 'star');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),

                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredPacks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final p = filteredPacks[i];
                          final isSelected = p.id == widget.pack.id;
                          final isBasic = p.band == DifficultyBand.a2b1;

                          return InkWell(
                            onTap: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => InterviewPackIntroScreen(pack: p),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? InterviewTheme.primaryFixed.withValues(alpha: 0.45)
                                    : InterviewTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? InterviewTheme.primary : InterviewTheme.outlineVariant.withValues(alpha: 0.5),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isBasic ? InterviewTheme.secondaryFixed : InterviewTheme.tertiaryFixed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isBasic ? Icons.chat_bubble_outline_rounded : Icons.psychology_rounded,
                                      color: isBasic ? InterviewTheme.onSecondaryFixed : InterviewTheme.tertiary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                p.subtopic,
                                                style: InterviewTheme.titleSm(
                                                  fontWeight: FontWeight.w700,
                                                  color: InterviewTheme.onSurface,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isBasic ? InterviewTheme.secondaryFixed : InterviewTheme.tertiaryFixed,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                p.band.label,
                                                style: InterviewTheme.labelSm(
                                                  color: isBasic ? InterviewTheme.onSecondaryFixed : InterviewTheme.tertiary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${p.scenario.name.toUpperCase()} • ${p.estMinutes} min • ${p.feedbackType}',
                                          style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, color: InterviewTheme.primary, size: 22)
                                  else
                                    Icon(Icons.arrow_forward_ios_rounded, color: InterviewTheme.secondary, size: 14),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTabItem({
    required String title,
    required String tabKey,
    required String currentKey,
    required VoidCallback onTap,
  }) {
    final isSelected = tabKey == currentKey;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? InterviewTheme.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: InterviewTheme.labelSm(
              color: isSelected ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Modals have been removed in favor of inline expansion

  Map<String, String> _getConnectorDetails(String connector) {
    switch (connector) {
      case 'Consequently':
        return {
          'translation': 'Por consiguiente / En consecuencia',
          'example': 'Consequently, our p99 latency dropped from 2.5s down to 180ms.',
          'advice': 'Úsalo para enlazar una decisión técnica con el resultado positivo o aprendizaje.',
        };
      case 'To mitigate this risk':
        return {
          'translation': 'Para mitigar este riesgo',
          'example': 'To mitigate this risk, I implemented rate limiting and multi-zone backups.',
          'advice': 'Excelente cuando estés explicando la fase de Acción o prevención de errores.',
        };
      case 'As a direct outcome':
        return {
          'translation': 'Como resultado directo',
          'example': 'As a direct outcome, the system handled 3x peak load without downtime.',
          'advice': 'Ideal para empezar la sección Result con datos o métricas de negocio.',
        };
      case 'Under high constraints':
        return {
          'translation': 'Bajo fuertes restricciones',
          'example': 'Under high constraints, we prioritized data consistency over raw throughput.',
          'advice': 'Úsalo en la Situación para enfatizar la complejidad del desafío.',
        };
      case 'First of all,':
        return {
          'translation': 'En primer lugar / Para empezar',
          'example': 'First of all, my background is focused on software development and daily problem solving.',
          'advice': 'Perfecto para estructurar tu presentación personal desde el primer segundo.',
        };
      case 'In my daily routine,':
        return {
          'translation': 'En mi rutina diaria',
          'example': 'In my daily routine, I start by reviewing open PRs and aligning with the team.',
          'advice': 'Úsalo para describir hábitos y tareas habituales con naturalidad.',
        };
      case 'Currently, I am...':
        return {
          'translation': 'Actualmente estoy...',
          'example': 'Currently, I am working with modern APIs and mastering cloud architecture.',
          'advice': 'Sirve para hablar del presente sin mezclar tiempos verbales.',
        };
      case 'From my perspective,':
        return {
          'translation': 'Desde mi perspectiva / En mi opinión',
          'example': 'From my perspective, clear async communication helps avoid misunderstandings.',
          'advice': 'Muy útil en debates o reuniones para dar una opinión constructiva.',
        };
      case 'To address this bottleneck,':
        return {
          'translation': 'Para solucionar este cuello de botella',
          'example': 'To address this bottleneck, I provisioned an asynchronous queue with exponential backoff.',
          'advice': 'Úsalo cuando describas la acción clave frente a un problema.',
        };
      default:
        return {
          'translation': 'Conector estructurado',
          'example': '$connector we verified the core metrics.',
          'advice': 'Úsalo para darte 2 segundos para pensar y estructurar la siguiente frase.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final catName = InterviewPackIntroScreen.mapCategory(widget.pack.scenario).toUpperCase();
    final isEn = ref.watch(localeProvider).languageCode == 'en';

    return Scaffold(
      backgroundColor: InterviewTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Main Scrollable Content (Direct seamless layout with no top bar)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Card with Integrated Back Action and Architectural Gradient
                    _buildStitchHeroCard(catName, isEn),
                    const SizedBox(height: 18),

                    // Section: Core Interview Question / Objective
                    _buildSectionHeader(
                      title: isEn ? 'SESSION PROMPT / QUESTION' : 'PREGUNTA DE LA SESIÓN',
                      icon: Icons.flag_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildQuestionCard(),
                    const SizedBox(height: 20),

                    // Section: Guided Framework Allocation & Accordion
                    _buildStarGuidedSection(isEn),
                    const SizedBox(height: 20),

                    // Section: Tactical Connectors & Linguistic Toolkit (Interactivos)
                    _buildSectionHeader(
                      title: isEn ? 'RECOMMENDED CONNECTORS & SPEAKING CUES' : 'CONECTORES RECOMENDADOS & GUÍA ORAL',
                      icon: Icons.tips_and_updates_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildTacticalToolkitCard(),
                    const SizedBox(height: 20),

                    // Section: AI Acoustic & Scoring Engine Card
                    _buildAcousticEngineCard(isEn),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Persistent Floating Trigger CTA Dock
            _buildFloatingActionDock(context, isEn),
          ],
        ),
      ),
    );
  }

  Widget _buildStitchHeroCard(String catName, bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            InterviewTheme.primaryFixed.withValues(alpha: 0.85),
            InterviewTheme.surfaceContainerHigh,
            InterviewTheme.surfaceDim,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: InterviewTheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Action Row (Back Button + Badges + Pack Selector)
          Row(
            children: [
              // Back Button
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: InterviewTheme.surfaceContainerLowest,
                    border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: InterviewTheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badges
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildPill(
                        label: widget.pack.scenario.name.toUpperCase(),
                        icon: Icons.psychology_rounded,
                        color: InterviewTheme.primary,
                        bgColor: InterviewTheme.surfaceContainerLowest,
                      ),
                      const SizedBox(width: 6),
                      _buildPill(
                        label: widget.pack.band.label,
                        icon: Icons.analytics_rounded,
                        color: InterviewTheme.tertiary,
                        bgColor: InterviewTheme.tertiaryFixed,
                      ),
                      const SizedBox(width: 6),
                      _buildPill(
                        label: '${widget.pack.estMinutes} min',
                        icon: Icons.schedule_rounded,
                        color: InterviewTheme.onSurfaceVariant,
                        bgColor: InterviewTheme.surfaceContainerLowest,
                      ),
                      const SizedBox(width: 6),
                      _buildPill(
                        label: 'WHISPER V3',
                        icon: Icons.graphic_eq_rounded,
                        color: InterviewTheme.tertiary,
                        bgColor: InterviewTheme.surfaceContainerLowest,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Pack Selector
              InkWell(
                onTap: () => _openPackSelectorModal(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: InterviewTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz_rounded, size: 15, color: InterviewTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Pack',
                        style: InterviewTheme.labelSm(
                          color: InterviewTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.pack.subtopic,
            style: InterviewTheme.headlineLg(
              color: InterviewTheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _getPackHeroSubtitle(),
            style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _getPackHeroSubtitle() {
    switch (widget.pack.id) {
      case 'interview_foundations_a1':
        return 'Práctica oral guiada para aprender inglés de cero • Pronunciación clara y rutinas básicas';
      case 'interview_workplace_b1':
        return 'Expresión profesional para el entorno de trabajo • Herramientas técnicas y proyectos';
      case 'interview_teamwork_b1':
        return 'Dinámicas de equipo y reuniones ágiles • Expresar opiniones y acuerdos de forma natural';
      case 'general_small_talk':
        return 'Romper el hielo y mantener charlas ligeras • Saludos, preguntas de seguimiento y despedidas naturales';
      case 'general_travel_situations':
        return 'Desenvolverte en aeropuertos, hoteles y restaurantes • Pedir, resolver problemas y negociar con educación';
      case 'general_storytelling':
        return 'Narrar experiencias con fluidez y color • Estructura, tiempos del pasado y mantener la atención';
      case 'general_presenting':
        return 'Presentar ideas y persuadir con impacto • Estructura ejecutiva, argumentos y manejo de objeciones';
      default:
        return 'Simulación adaptativa de preguntas técnicas • Evaluación acústica de pausas y método STAR';
    }
  }

  Widget _buildPill({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: InterviewTheme.labelSm(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: InterviewTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: InterviewTheme.titleSm(
            color: InterviewTheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    final questionPrompt = _getQuestionPrompt(widget.pack.objectiveId);
    final advice = _getObjectiveAdvice(widget.pack.objectiveId);
    final isBasic = widget.pack.band == DifficultyBand.a2b1 || widget.pack.domain == 'general';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
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
              color: isBasic ? InterviewTheme.secondaryFixed : InterviewTheme.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBasic ? Icons.chat_rounded : Icons.record_voice_over_rounded,
              color: isBasic ? InterviewTheme.onSecondaryFixed : InterviewTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBasic ? 'Foundations Practice • Spoken English' : 'Behavioral Scenario • Core Technical',
                  style: InterviewTheme.labelSm(
                    color: isBasic ? InterviewTheme.secondary : InterviewTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“$questionPrompt”',
                  style: InterviewTheme.titleMd(
                    color: InterviewTheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  advice,
                  style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarGuidedSection(bool isEn) {
    final isBasic = widget.pack.band == DifficultyBand.a2b1 || widget.pack.domain == 'general';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.view_timeline_rounded, size: 18, color: InterviewTheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  isBasic ? 'ESTRUCTURA DE RESPUESTA GUIADA' : 'ESTRUCTURA STAR GUIADA',
                  style: InterviewTheme.labelMd(
                    color: InterviewTheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '100% Repartición Óptima',
              style: InterviewTheme.labelSm(
                color: InterviewTheme.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Allocation progress bar (20% S, 15% T, 50% A, 15% R)
        Container(
          height: 12,
          width: double.infinity,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: InterviewTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: InterviewTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: InterviewTheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 50,
                child: Container(
                  decoration: BoxDecoration(
                    color: InterviewTheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                flex: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: InterviewTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        if (isBasic) ...[
          _buildStarStepCard(
            index: 0,
            letter: '1',
            title: 'Introducción / Contexto',
            timeLabel: '20% del tiempo (~30s)',
            color: InterviewTheme.primaryFixed,
            textColor: InterviewTheme.onPrimaryFixed,
            description: 'Preséntate con frases simples: quién eres, de dónde eres y a qué te dedicas.',
            keyPhrasing: '“Hello, my name is Alex. I am a software enthusiast currently based in Madrid...”',
          ),
          const SizedBox(height: 6),
          _buildStarStepCard(
            index: 1,
            letter: '2',
            title: 'Rutina o Rol Actual',
            timeLabel: '30% del tiempo (~45s)',
            color: InterviewTheme.secondaryFixed,
            textColor: InterviewTheme.onSecondaryFixed,
            description: 'Usa Present Simple para describir lo que haces en tu día a día y las herramientas que usas.',
            keyPhrasing: '“In my daily routine, I usually review code, build small features, and learn new technologies...”',
          ),
          const SizedBox(height: 6),
          _buildStarStepCard(
            index: 2,
            letter: '3',
            title: 'Experiencia o Proyecto',
            timeLabel: '35% del tiempo (~50s)',
            color: InterviewTheme.tertiaryFixed,
            textColor: InterviewTheme.onTertiaryFixed,
            description: 'Cuenta algo que hayas construido recientemente usando verbos en Past Simple.',
            keyPhrasing: '“Recently, I built a small web app to track tasks. I used Flutter and connected it to an API...”',
          ),
          const SizedBox(height: 6),
          _buildStarStepCard(
            index: 3,
            letter: '4',
            title: 'Conclusión y Objetivos',
            timeLabel: '15% del tiempo (~20s)',
            color: InterviewTheme.primaryFixed,
            textColor: InterviewTheme.onPrimaryFixed,
            description: 'Cierra indicando tus metas de aprendizaje o por qué quieres mejorar tu inglés.',
            keyPhrasing: '“My goal is to practice speaking every day and be able to communicate fluently in English.”',
          ),
        ] else ...[
          _buildStarStepCard(
            index: 0,
            letter: 'S',
            title: 'Situation (Situación)',
            timeLabel: '20% del tiempo (~45s)',
            color: InterviewTheme.primaryFixed,
            textColor: InterviewTheme.onPrimaryFixed,
            description:
                'Define la arquitectura previa, la criticidad del servicio y la anomalía detectada. No expliques la historia entera de la compañía.',
            keyPhrasing: '“During peak black Friday traffic, our primary payment gateway experienced a cascading timeout...”',
          ),
          const SizedBox(height: 6),
          _buildStarStepCard(
            index: 1,
            letter: 'T',
            title: 'Task (Tarea)',
            timeLabel: '15% del tiempo (~30s)',
            color: InterviewTheme.secondaryFixed,
            textColor: InterviewTheme.onSecondaryFixed,
            description:
                'Tu ownership específico: aislar el cuello de botella y sincronizar stakeholders sin alarmar innecesariamente al cliente.',
            keyPhrasing: '“My responsibility was to isolate the bottleneck and sync stakeholders without escalating customer alarm.”',
          ),
          const SizedBox(height: 6),
          _buildStarStepCard(
            index: 2,
            letter: 'A',
            title: 'Action (Acción Técnica)',
            timeLabel: '50% del tiempo (~120s) • Máximo Peso Evaluado',
            color: InterviewTheme.tertiaryFixed,
            textColor: InterviewTheme.onTertiaryFixed,
            description:
                'Usa verbos en Past Simple para decisiones precisas y Present Perfect para aprendizajes que perduran. Detalla el triage, telemetría y contención.',
            keyPhrasing: '“I orchestrated an immediate traffic shed via rate limiters, provisioned read-replicas, and opened a cross-functional war room...”',
          ),
          const SizedBox(height: 6),
          _buildStarStepCard(
            index: 3,
            letter: 'R',
            title: 'Result (Resultado Medible)',
            timeLabel: '15% del tiempo (~35s)',
            color: InterviewTheme.primaryFixed,
            textColor: InterviewTheme.onPrimaryFixed,
            description:
                'Métricas cuantificables: MTTR reducido un 40%, 99.98% de transacciones retenidas y post-mortem adoptado por toda la división.',
            keyPhrasing: '“Métricas cuantificables: MTTR reducido un 40%, 99.98% de transacciones retenidas y post-mortem adoptado por toda la división.”',
          ),
        ],
      ],
    );
  }

  Widget _buildStarStepCard({
    required int index,
    required String letter,
    required String title,
    required String timeLabel,
    required Color color,
    required Color textColor,
    required String description,
    required String keyPhrasing,
  }) {
    final isExpanded = _expandedStarIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isExpanded ? InterviewTheme.primary.withValues(alpha: 0.3) : InterviewTheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedStarIndex = isExpanded ? -1 : index;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      letter,
                      style: InterviewTheme.labelSm(color: textColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: InterviewTheme.titleSm(fontWeight: FontWeight.w600)),
                        Text(timeLabel, style: InterviewTheme.labelSm(color: InterviewTheme.primary)),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: InterviewTheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(description, style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: InterviewTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PHRASING CLAVE:',
                              style: InterviewTheme.labelSm(
                                color: InterviewTheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              keyPhrasing,
                              style: InterviewTheme.bodySm(
                                color: InterviewTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTacticalToolkitCard() {
    final connectors = _getPackConnectors();
    final player = ref.read(audioPlayerProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toca cualquier conector si te quedas en blanco:',
                style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 14, color: InterviewTheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Asistente Oral',
                    style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: connectors.map((c) {
              final isSelected = _expandedConnector == c;
              return InkWell(
                onTap: () {
                  setState(() {
                    _expandedConnector = isSelected ? null : c;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? InterviewTheme.primaryFixed.withValues(alpha: 0.4) : InterviewTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? InterviewTheme.primary : InterviewTheme.primary.withValues(alpha: 0.3)),
                    boxShadow: [
                      if (!isSelected)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c,
                        style: InterviewTheme.labelSm(
                          color: isSelected ? InterviewTheme.onPrimaryFixedVariant : InterviewTheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.help_outline_rounded, size: 14, color: isSelected ? InterviewTheme.primary : InterviewTheme.onSurfaceVariant),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_expandedConnector != null) ...[
            const SizedBox(height: 14),
            Builder(
              builder: (ctx) {
                final data = _getConnectorDetails(_expandedConnector!);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: InterviewTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: InterviewTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              data['translation'] ?? '',
                              style: InterviewTheme.labelSm(color: InterviewTheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.volume_up_rounded, color: InterviewTheme.primary, size: 18),
                            tooltip: 'Escuchar',
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            onPressed: () => player.playTts(_expandedConnector!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '“${data['example']}”',
                        style: InterviewTheme.bodySm(color: InterviewTheme.onSurface, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 14, color: InterviewTheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${data['advice']}',
                              style: InterviewTheme.labelSm(color: InterviewTheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          _buildBulletTip('Los conectores te dan 2-3 segundos para organizar la siguiente idea sin recurrir a pausas vacías o silencios.'),
          const SizedBox(height: 6),
          _buildBulletTip('Comunica con convicción en 1ª persona (“I implemented”, “In my view”), manteniendo un ritmo pausado y claro.'),
        ],
      ),
    );
  }

  List<String> _getPackConnectors() {
    switch (widget.pack.id) {
      case 'interview_foundations_a1':
        return ['First of all,', 'In my daily routine,', 'Currently, I am...', 'For example,'];
      case 'interview_workplace_b1':
        return ['On a daily basis,', 'I primarily work with...', 'Recently, I built...', 'As a result,'];
      case 'interview_teamwork_b1':
        return ['From my perspective,', 'To build consensus,', 'In order to align,', 'Furthermore,'];
      case 'general_small_talk':
        return ['How\'s it going?', 'By the way,', 'Same here,', 'What about you?'];
      case 'general_travel_situations':
        return ['Excuse me,', 'Could you tell me…?', 'Would it be possible to…?', 'Thanks for your help.'];
      case 'general_storytelling':
        return ['At first,', 'Then,', 'Suddenly,', 'In the end,'];
      case 'general_presenting':
        return ['To begin with,', 'More importantly,', 'You might be wondering,', 'To sum up,'];
      default:
        return ['Consequently,', 'To mitigate this risk,', 'As a direct outcome,', 'Under high constraints,'];
    }
  }

  Widget _buildBulletTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 15, color: InterviewTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant)),
        ),
      ],
    );
  }

  Widget _buildAcousticEngineCard(bool isEn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: InterviewTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: InterviewTheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: InterviewTheme.tertiaryFixed,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.hearing_rounded, color: InterviewTheme.tertiary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Whisper AI Phonetics', style: InterviewTheme.titleSm(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: InterviewTheme.tertiary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.pack.feedbackType,
                        style: InterviewTheme.labelSm(color: InterviewTheme.tertiary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Análisis fonético de pausas, muletillas (fillers) y concordancia temporal.',
                  style: InterviewTheme.bodySm(color: InterviewTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: InterviewTheme.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Activo',
              style: InterviewTheme.labelSm(color: InterviewTheme.tertiary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionDock(BuildContext context, bool isEn) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: InterviewTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GlossyButton(
        color: InterviewTheme.primary,
        onPressed: () => _launchSession(context),
        height: 52,
        radius: 26,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                widget.pack.band == DifficultyBand.a2b1
                    ? 'Iniciar Práctica Oral Guiada'
                    : 'Iniciar Grabación STAR (Modo Simulación)',
                style: InterviewTheme.titleMd(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
  }

  String _getQuestionPrompt(String objectiveId) {
    switch (objectiveId) {
      case 'personal_intro_a1':
        return 'Can you introduce yourself, what you do, and describe your typical daily routine?';
      case 'describe_daily_work':
        return 'Describe your current role, the main tools and technologies you use, and a recent project you enjoyed working on.';
      case 'teamwork_collaboration':
        return 'How do you usually collaborate with your team, share feedback in meetings, and align on project priorities?';
      case 'tell_me_about_yourself':
        return 'Tell me about a time you faced an unexpected production outage or technical blocker under tight deadlines. How did you handle communication and resolution?';
      case 'describe_a_bug':
        return 'Walk me through a critical production bug you investigated. What was the root cause, immediate mitigation, and long-term fix?';
      case 'defend_tradeoffs':
        return 'Describe a major architectural trade-off you had to defend. How did you balance latency, throughput, and consistency?';
      case 'resolve_conflict':
        return 'Tell me about a technical disagreement you had with a team member or stakeholder. How did you build consensus?';
      case 'small_talk_social':
        return 'You join a video call a few minutes early with a colleague. Break the ice: greet them, make a light comment (weekend, weather, work) and ask them a question back.';
      case 'travel_real_situations':
        return 'You arrive at your hotel but there is a problem with your booking. Explain the situation politely, ask about the options, and agree on a solution.';
      case 'everyday_storytelling':
        return 'Tell me about a memorable trip or experience: set the scene, say what happened, how you felt, and why it stuck with you.';
      case 'presenting_persuading':
        return 'Give a two-minute pitch to convince your team to adopt an idea or tool: open with a hook, give two strong reasons, address one objection, and finish with a clear call to action.';
      default:
        return 'Tell me about a complex engineering challenge you solved under tight constraints.';
    }
  }

  String _getObjectiveAdvice(String objectiveId) {
    switch (objectiveId) {
      case 'personal_intro_a1':
        return 'Mantén frases cortas y claras. Usa el Present Simple y apóyate en conectores básicos como "First of all" o "In addition".';
      case 'describe_daily_work':
        return 'Combina el Present Simple para tus responsabilidades habituales con el Past Simple para logros y proyectos concretos.';
      case 'teamwork_collaboration':
        return 'Muestra empatía y comunicación clara con frases asertivas como "From my perspective" y "To build consensus".';
      case 'tell_me_about_yourself':
        return 'Conecta decisiones bajo presión con métricas tangibles (RTO, SLA, MTTR). Evita divagar en teoría técnica no aplicada.';
      case 'describe_a_bug':
        return 'Distingue con nitidez entre el workaround temporal y la solución definitiva a nivel de código o infraestructura.';
      case 'defend_tradeoffs':
        return 'Ningún diseño es perfecto: demuestra madurez evaluando costes, escalabilidad y complejidad operativa.';
      case 'resolve_conflict':
        return 'Comunica con diplomacia y foco en el beneficio del producto, evitando polarización interpersonal.';
      case 'small_talk_social':
        return 'Apóyate en frases hechas y preguntas de seguimiento. Mantén el tono relajado: "How\'s it going?", "Same here", "What about you?".';
      case 'travel_real_situations':
        return 'Sé educado pero directo. Usa peticiones indirectas ("Could you…?", "Would it be possible to…?") y confirma la solución al final.';
      case 'everyday_storytelling':
        return 'Da vida a la historia con Past Simple + Past Continuous y adjetivos. Marca las fases: "At first…", "Then…", "In the end…".';
      case 'presenting_persuading':
        return 'Señaliza la estructura ("First… Second… Finally…"), respalda con datos y anticipa objeciones ("You might be wondering…"). Cierra con una llamada a la acción clara.';
      default:
        return 'Estructura tu respuesta usando el método STAR para asegurar máximo impacto.';
    }
  }
}
