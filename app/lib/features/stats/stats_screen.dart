import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';
import '../../core/models/api_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  // Acento de la pantalla (miel/ámbar, como la pestaña Perfil).
  static final _accent = TabTheme.profile;

  StatsOut? _stats;
  WeeklyReportOut? _weeklyReport;
  List<JournalEntry> _journalEntries = [];
  List<UserMilestonesLocalData> _milestones = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Fallback local (sin backend): racha y metricas calculadas desde la BD local
  int _localStreak = 0;
  int _localSessions = 0;
  int _localAnswers = 0;
  int _localCards = 0;

  @override
  void initState() {
    super.initState();
    _loadAllProgressData();
  }

  Future<void> _loadAllProgressData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final api = ref.read(apiClientProvider);
    final journalService = ref.read(journalServiceProvider);
    final milestoneService = ref.read(milestoneServiceProvider);
    final db = ref.read(appDatabaseProvider);
    final userId = ref.read(activeUserIdProvider);

    // Racha y metricas locales SIEMPRE (funcionan sin conexion). Asi la parte
    // superior (racha) y las tarjetas de metricas nunca desaparecen offline.
    int localStreak = 0, localSessions = 0, localAnswers = 0, localCards = 0;
    try {
      localStreak =
          await ref.read(profileRepositoryProvider).currentStreakDays(userId);
      final journalsForCounts = await journalService.getJournalEntries();
      localSessions =
          journalsForCounts.where((j) => !j.sessionId.startsWith('act_')).length;
      localAnswers =
          journalsForCounts.fold<int>(0, (sum, j) => sum + j.questionsCount);
      localCards = (await db.select(db.reviewLogsLocal).get()).length;
      // Reconcilia los hitos con el estado real local: al abrir Progreso los
      // hitos reflejan cualquier actividad, no solo mazo/entrevista.
      await milestoneService.reconcileFromLocal(streakDays: localStreak);
    } catch (_) {}

    try {
      final s = await api.getStats();
      WeeklyReportOut? wr;
      try {
        wr = await api.getWeeklyReport();
      } catch (_) {}

      try {
        await milestoneService.reconcileFromLocal(
          streakDays: localStreak,
          extraSessions: s.total_sessions,
          extraCards: s.total_cards,
        );
      } catch (_) {}
      final journals = await journalService.getJournalEntries();
      final ms = await milestoneService.getAllMilestones();

      setState(() {
        _stats = s;
        _weeklyReport = wr;
        _journalEntries = journals;
        _milestones = ms;
        _localStreak = localStreak;
        _localSessions = localSessions;
        _localAnswers = localAnswers;
        _localCards = localCards;
        _isLoading = false;
      });
    } catch (e) {
      // Offline: cargamos diario, hitos y metricas locales (nada desaparece).
      try {
        final journals = await journalService.getJournalEntries();
        final ms = await milestoneService.getAllMilestones();
        setState(() {
          _journalEntries = journals;
          _milestones = ms;
          _localStreak = localStreak;
          _localSessions = localSessions;
          _localAnswers = localAnswers;
          _localCards = localCards;
          _isLoading = false;
        });
      } catch (_) {
        setState(() {
          _localStreak = localStreak;
          _localSessions = localSessions;
          _localAnswers = localAnswers;
          _localCards = localCards;
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // ── Helpers de estilo (estetica Home) ─────────────────────────────────

  /// Tarjeta base con la misma estetica que las tarjetas del Home.
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
        boxShadow: TabTheme.cardShadow,
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: _accent.accent, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(title, style: TabTheme.titleSm(fw: FontWeight.w700)),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── Dialogos / modales (sin cambios funcionales) ──────────────────────

  void _showEfSetDialog() {
    final efMilestone = _milestones.firstWhere(
      (m) => m.id == 'ef_set_score',
      orElse: () => const UserMilestonesLocalData(
        id: 'ef_set_score',
        title: 'Certificación EF SET',
        description: 'Resultado registrado',
        achieved: false,
      ),
    );

    final controller = TextEditingController(text: efMilestone.value ?? 'C1 - 65/100');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: _accent.accent),
            const SizedBox(width: 8),
            Text(context.l10n.statsLogEfset),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.statsEfsetHelp,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: context.l10n.statsLevelScore,
                hintText: 'C1 - 65/100',
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                final milestoneService = ref.read(milestoneServiceProvider);
                await milestoneService.setEfSetScore(val);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadAllProgressData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.statsEfsetUpdated),
                      backgroundColor: _accent.accent,
                    ),
                  );
                }
              }
            },
            child: Text(context.l10n.actionSave),
          ),
        ],
      ),
    );
  }

  void _showMarkdownExportModal(String markdown, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_rounded, color: _accent.accent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: TabTheme.outlineVariant),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: SelectableText(
                          markdown,
                          style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              height: 1.4,
                              color: AppTheme.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(context.l10n.exportCopyMarkdown),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: markdown));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.statsReportCopied),
                            backgroundColor: _accent.accent,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TabTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_errorMessage != null && _stats == null && _journalEntries.isEmpty)
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadAllProgressData,
                  color: _accent.accent,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeader(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                        child: Column(
                          children: [
                            _buildHeroCard(_stats?.streak_days ?? _localStreak),
                            const SizedBox(height: 16),
                            _buildWeeklyErrorComparisonCard(),
                            const SizedBox(height: 16),
                            _buildPracticeSummaryCard(),
                            const SizedBox(height: 16),
                            _buildMilestonesSection(),
                            const SizedBox(height: 16),
                            _buildObsidianExportCard(),
                            const SizedBox(height: 16),
                            _buildSessionTimeline(),
                            if (_stats != null) ...[
                              const SizedBox(height: 16),
                              _buildWeeklyChart(_stats!),
                              const SizedBox(height: 16),
                              _buildMistakesCategoryCard(_stats!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.error),
            const SizedBox(height: 12),
            Text(_errorMessage ?? '', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadAllProgressData, child: Text(context.l10n.errorRetry)),
          ],
        ),
      ),
    );
  }

  /// Cabecera propia (sin AppBar): titulo centrado + hint de sincronizacion.
  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    final offline = _stats == null;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPad + 18, 20, 6),
      child: Column(
        children: [
          Text(
            context.l10n.statsTitle,
            textAlign: TextAlign.center,
            style: TabTheme.displayMd(),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                offline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                size: 13,
                color: offline ? AppTheme.textSecondary : _accent.accent,
              ),
              const SizedBox(width: 6),
              Text(
                offline ? 'Datos locales' : 'Sincronizado',
                style: TabTheme.labelSm(
                    color: offline ? AppTheme.textSecondary : _accent.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Hero: racha + 3 metricas utiles (Sesiones / Respuestas / Tarjetas),
  /// con blobs y estetica de la tarjeta principal del Home.
  Widget _buildHeroCard(int streakDays) {
    final sessions = _stats?.total_sessions ?? _localSessions;
    final answers = _stats?.total_turns ?? _localAnswers;
    final cards = _stats?.total_cards ?? _localCards;

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
          Positioned(
            right: -46,
            top: -46,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accent.accent.withValues(alpha: AppTheme.isLight ? 0.20 : 0.14),
              ),
            ),
          ),
          Positioned(
            left: -38,
            bottom: -46,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: AppTheme.isLight ? 0.14 : 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _accent.container,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_fire_department_rounded,
                          size: 30, color: _accent.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streakDays ${streakDays == 1 ? 'día' : 'días'} de racha',
                            style: TabTheme.headlineSm(fw: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.statsHabitTip,
                            style: TabTheme.bodyMd(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _heroStat('Sesiones', sessions, Icons.forum_rounded, TabTheme.speaking.accent)),
                    const SizedBox(width: 10),
                    Expanded(child: _heroStat('Respuestas', answers, Icons.mic_rounded, TabTheme.comprehension.accent)),
                    const SizedBox(width: 10),
                    Expanded(child: _heroStat('Tarjetas', cards, Icons.style_rounded, TabTheme.fsrs.accent)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLowest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text('$value', style: TabTheme.titleMd(fw: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TabTheme.labelSm(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  /// Resumen de practica calculado desde el diario LOCAL (funciona offline y
  /// refleja TODA la actividad): media de puntuacion, minutos practicados esta
  /// semana y en total, y reparto por area.
  Widget _buildPracticeSummaryCard() {
    if (_journalEntries.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final avgScore = _journalEntries.fold<double>(0, (a, e) => a + e.overallScore) /
        _journalEntries.length;
    final totalMin = _journalEntries.fold<int>(0, (a, e) => a + e.durationSeconds) ~/ 60;
    final weekMin = _journalEntries
            .where((e) => e.date.isAfter(weekAgo))
            .fold<int>(0, (a, e) => a + e.durationSeconds) ~/
        60;

    // Reparto por area (normalizando la categoria del diario a un area corta).
    final Map<String, int> byArea = {};
    for (final e in _journalEntries) {
      byArea.update(_areaOf(e), (v) => v + 1, ifAbsent: () => 1);
    }
    final areas = byArea.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.insights_rounded, 'Resumen de práctica'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _miniStat('Media', avgScore.toStringAsFixed(0), '/100', TabTheme.grammar.accent)),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('Esta semana', '$weekMin', 'min', _accent.accent)),
              const SizedBox(width: 10),
              Expanded(child: _miniStat('Total', '$totalMin', 'min', TabTheme.fsrs.accent)),
            ],
          ),
          if (areas.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Reparto por área', style: TabTheme.labelMd(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: areas.map((a) {
                final c = _areaColor(a.key);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${a.key} · ${a.value}', style: TabTheme.labelSm(color: AppTheme.textPrimary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Column(
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(text: value, style: TabTheme.titleMd(fw: FontWeight.w700, color: color)),
              TextSpan(text: ' $unit', style: TabTheme.labelSm(color: AppTheme.textSecondary)),
            ]),
          ),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TabTheme.labelSm(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  String _areaOf(JournalEntry e) {
    // Las entrevistas usan createJournalEntryFromSession (sessionId != act_).
    if (!e.sessionId.startsWith('act_')) return 'Speaking';
    // El resto guarda su area en el markdown ("**Area:** `<categoria>`").
    final md = e.markdownContent.toLowerCase();
    if (md.contains('gram')) return 'Gramática';
    if (md.contains('lectura') || md.contains('comprens') || md.contains('inmersi')) return 'Comprensión';
    if (md.contains('vocab')) return 'Vocabulario';
    if (md.contains('fsrs') || md.contains('repaso')) return 'Repaso';
    if (md.contains('entrevista') || md.contains('simulaci') || md.contains('star')) return 'Speaking';
    return 'Otros';
  }

  Color _areaColor(String area) {
    switch (area) {
      case 'Gramática':
        return TabTheme.grammar.accent;
      case 'Comprensión':
        return TabTheme.comprehension.accent;
      case 'Vocabulario':
        return TabTheme.vocabulary.accent;
      case 'Repaso':
        return TabTheme.fsrs.accent;
      case 'Speaking':
        return TabTheme.speaking.accent;
      default:
        return _accent.accent;
    }
  }

  Widget _buildObsidianExportCard() {
    return _card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent.container,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_stories_rounded, color: _accent.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.statsWeeklyReportObsidian,
                    style: TabTheme.titleSm(fw: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(context.l10n.statsWeeklyReportSub,
                    style: TabTheme.bodySm(color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.download_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: _accent.container,
              foregroundColor: _accent.accent,
            ),
            tooltip: context.l10n.actionExport,
            onPressed: () async {
              final journalService = ref.read(journalServiceProvider);
              final md = await journalService.fetchWeeklyReportMarkdown();
              _showMarkdownExportModal(md, 'Informe Semanal para Obsidian');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyErrorComparisonCard() {
    // Combinamos el backend con el diario LOCAL (que registra los errores de
    // todas las actividades: gramatica, comprension, vocabulario, entrevista).
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    int localThis = 0, localLast = 0;
    for (final e in _journalEntries) {
      if (e.date.isAfter(weekAgo)) {
        localThis += e.mistakesCount;
      } else if (e.date.isAfter(twoWeeksAgo)) {
        localLast += e.mistakesCount;
      }
    }
    final backThis = _weeklyReport?.mistakes_this_week ?? 0;
    final backLast = _weeklyReport?.mistakes_last_week ?? 0;
    final thisWeek = localThis > backThis ? localThis : backThis;
    final lastWeek = localLast > backLast ? localLast : backLast;
    final diff = thisWeek - lastWeek;

    Color badgeColor = AppTheme.textSecondary;
    String badgeText = '$thisWeek errores esta semana';
    IconData badgeIcon = Icons.remove_rounded;

    if (lastWeek > 0) {
      if (diff < 0) {
        badgeColor = TabTheme.vocabulary.accent;
        badgeText = '${diff.abs()} errores menos que la semana anterior';
        badgeIcon = Icons.trending_down_rounded;
      } else if (diff > 0) {
        badgeColor = AppTheme.warning;
        badgeText = '$diff errores más que la semana anterior';
        badgeIcon = Icons.trending_up_rounded;
      } else {
        badgeText = 'Mismo nivel de errores que la semana pasada ($thisWeek)';
      }
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.compare_arrows_rounded, context.l10n.statsWeeklyErrorComparison),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _weekBox('$thisWeek', context.l10n.statsThisWeek, AppTheme.textPrimary)),
              const SizedBox(width: 12),
              Expanded(child: _weekBox('$lastWeek', context.l10n.statsLastWeek, AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(badgeIcon, color: badgeColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(badgeText,
                      style: TabTheme.labelMd(color: badgeColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekBox(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TabTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TabTheme.surfaceContainerHigh),
      ),
      child: Column(
        children: [
          Text(value, style: TabTheme.displayMd(color: valueColor)),
          const SizedBox(height: 2),
          Text(label, style: TabTheme.labelSm(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.emoji_events_rounded,
            context.l10n.statsMilestones,
            trailing: TextButton.icon(
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: Text(context.l10n.statsEfsetNote, style: const TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(foregroundColor: _accent.accent),
              onPressed: _showEfSetDialog,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _milestones.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final m = _milestones[idx];
                final isUnlocked = m.achieved;

                return Container(
                  width: 158,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnlocked ? _accent.container : TabTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUnlocked ? _accent.accent.withValues(alpha: 0.5) : TabTheme.surfaceContainerHigh,
                      width: isUnlocked ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                            color: isUnlocked ? _accent.accent : AppTheme.textSecondary,
                            size: 18,
                          ),
                          const Spacer(),
                          if (isUnlocked && m.value != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _accent.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                m.value!,
                                style: TabTheme.labelSm(color: _accent.accent),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        m.title,
                        style: TabTheme.titleSm(
                            fw: FontWeight.w700,
                            color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.description,
                        style: TabTheme.bodySm(color: AppTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTimeline() {
    if (_journalEntries.isEmpty) {
      return _card(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.history_edu_rounded, size: 34, color: _accent.accent),
            const SizedBox(height: 10),
            Text(context.l10n.statsNoSessions,
                style: TabTheme.titleSm(fw: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              context.l10n.statsNoSessionsSub,
              textAlign: TextAlign.center,
              style: TabTheme.bodySm(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.timeline_rounded, context.l10n.statsTimeline),
          const SizedBox(height: 12),
          ..._journalEntries.take(10).map((entry) {
            final minutes = entry.durationSeconds ~/ 60;
            final seconds = entry.durationSeconds % 60;
            final score = entry.overallScore;
            final scoreColor = score >= 80
                ? TabTheme.vocabulary.accent
                : (score >= 60 ? _accent.accent : AppTheme.warning);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TabTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TabTheme.surfaceContainerHigh),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showMarkdownExportModal(entry.markdownContent, entry.title),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        score.toStringAsFixed(0),
                        style: TabTheme.titleSm(fw: FontWeight.w700, color: scoreColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.title,
                              style: TabTheme.titleSm(fw: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(
                            '${dateFormat.format(entry.date)} • ${minutes}m ${seconds}s • ${entry.mistakesCount} err.',
                            style: TabTheme.bodySm(color: AppTheme.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.file_copy_outlined, color: _accent.accent, size: 20),
                      tooltip: context.l10n.exportCopyMarkdownObsidian,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: entry.markdownContent));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.statsNoteCopied),
                            backgroundColor: _accent.accent,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(StatsOut stats) {
    final activity = stats.weekly_activity;
    double maxTurns = 5.0;
    for (final a in activity) {
      final t = (a['turns'] as num?)?.toDouble() ?? 0.0;
      if (t > maxTurns) maxTurns = t;
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.bar_chart_rounded, context.l10n.statsAnswerActivity7d),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: RepaintBoundary(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxTurns + 2,
                  barTouchData: const BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < activity.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                activity[idx]['day']?.toString() ?? '',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(activity.length, (idx) {
                    final turns = (activity[idx]['turns'] as num?)?.toDouble() ?? 0.0;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: turns,
                          color: turns > 0 ? _accent.accent : TabTheme.surfaceContainerHigh,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMistakesCategoryCard(StatsOut stats) {
    final cat = stats.mistakes_by_category;
    final total = stats.total_mistakes;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.donut_small_rounded,
            context.l10n.statsErrorsBreakdown,
            trailing: Text('$total errores',
                style: TabTheme.labelSm(color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 16),
          if (cat.isEmpty)
            Text('Sin errores registrados todavía.',
                style: TabTheme.bodySm(color: AppTheme.textSecondary)),
          ...cat.entries.map((e) {
            final count = e.value;
            final percent = total > 0 ? count / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key.toUpperCase(), style: TabTheme.labelMd()),
                      Text('$count (${(percent * 100).toStringAsFixed(0)}%)',
                          style: TabTheme.bodySm(color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 7,
                      backgroundColor: TabTheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation<Color>(_categoryColor(e.key)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _categoryColor(String key) {
    switch (key.toLowerCase()) {
      case 'grammar':
        return TabTheme.grammar.accent;
      case 'vocabulary':
        return TabTheme.vocabulary.accent;
      case 'pronunciation':
        return TabTheme.speaking.accent;
      default:
        return _accent.accent;
    }
  }
}
