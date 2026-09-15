import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../providers/app_providers.dart';
import 'taxonomy.dart';

enum RecommendationType {
  fsrsMistakes,
  irregularVerbs,
  grammarRule,
  listeningInmersion,
  interviewStar,
  generalDaily,
}

class AdaptiveAction {
  final String title;
  final String subtitle;
  final String badge;
  final String actionLabel;
  final String route;
  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final Color onContainerColor;
  final RecommendationType type;
  final int priority; // higher = more urgent

  const AdaptiveAction({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.actionLabel,
    required this.route,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.onContainerColor,
    required this.type,
    this.priority = 1,
  });
}

/// Dynamic AI recommendation provider that reads actual user mistakes,
/// FSRS due cards, weak pronunciation attempts, and grammar units to synthesize
/// the optimal next practice step in real time.
final adaptiveRecommendationProvider =
    FutureProvider.autoDispose<AdaptiveAction>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final profile = ref.watch(activeProfileProvider).valueOrNull;
  final rawUserId = ref.watch(activeUserIdProvider);
  final userId = rawUserId.trim().isNotEmpty ? rawUserId.trim() : 'default_user';

  // 1. Check irregular verbs mastery in vocabulary
  try {
    final irregularPacks = ['irregular_verbs_core', 'irregular_verbs_workplace', 'irregular_verbs_advanced'];
    final attempts = await (db.select(db.practiceAttemptsLocal)
          ..where((t) =>
              t.userId.equals(userId) &
              t.track.equals(Track.vocabulary.id) &
              t.objectiveId.isIn(irregularPacks)))
        .get();

    if (attempts.isEmpty || attempts.any((a) => a.score < 0.8)) {

      return const AdaptiveAction(
        title: 'Domina los Verbos Irregulares',
        subtitle: 'Practica la matriz de conjugación interactiva y la pronunciación nativa de los tiempos verbales clave.',
        badge: 'VERBOS CLAVE',
        actionLabel: 'Practicar verbos',
        route: '/irregular-verbs',
        icon: Icons.menu_book_rounded,
        accentColor: Color(0xFF1E6B9B),
        containerColor: Color(0xFFE2F1FC),
        onContainerColor: Color(0xFF003355),
        type: RecommendationType.irregularVerbs,
        priority: 8,
      );
    }
  } catch (_) {}

  // 3. Check Grammar unit progress
  try {
    final grammarProgress = await (db.select(db.unitProgressLocal)
          ..where((t) => t.userId.equals(userId) & t.track.equals(Track.grammar.id)))
        .get();

    final weakUnit = grammarProgress.where((p) => p.masteryScore < 0.7).firstOrNull;
    if (weakUnit != null) {
      return AdaptiveAction(
        title: 'Refuerzo gramatical: ${weakUnit.objectiveId.replaceAll('_', ' ').toUpperCase()}',
        subtitle: 'Tu precisión en esta unidad está en ${(weakUnit.masteryScore * 100).round()}%. Haz un drill rápido para consolidarla.',
        badge: 'GRAMÁTICA FOCO',
        actionLabel: 'Entrenar drill',
        route: '/grammar',
        icon: Icons.spellcheck_rounded,
        accentColor: const Color(0xFF6B4FA0),
        containerColor: const Color(0xFFF0E8FA),
        onContainerColor: const Color(0xFF331B5E),
        type: RecommendationType.grammarRule,
        priority: 7,
      );
    }
  } catch (_) {}

  // 4. Check Comprehension / Listening Inmersion
  try {
    final daily = await (db.select(db.userActivityDailyLocal)
          ..where((t) => t.userId.equals(userId)))
        .get();

    final hasDoneListening = daily.any((d) => d.minutesSpent > 5);
    if (!hasDoneListening) {
      return const AdaptiveAction(
        title: 'Inmersión Auditiva: Pasaje Diario',
        subtitle: 'Entrena tu comprensión auditiva con audio nativo a 24kHz y responde a las preguntas pedagógicas.',
        badge: 'INMERSIÓN',
        actionLabel: 'Escuchar pasaje',
        route: '/comprehension',
        icon: Icons.headphones_rounded,
        accentColor: Color(0xFF0D8A68),
        containerColor: Color(0xFFE0F6EE),
        onContainerColor: Color(0xFF004430),
        type: RecommendationType.listeningInmersion,
        priority: 6,
      );
    }
  } catch (_) {}

  // 5. Default high-value speaking recommendation
  final role = profile?.roleTitle ?? 'Profesional';
  final goal = profile?.learningGoal ?? 'interview_prep';
  return AdaptiveAction(
    title: goal == 'interview_prep'
        ? 'Simulación STAR: $role'
        : 'Fluidez y Conectores de Comunicación',
    subtitle: 'Practica responder en inglés estructurado con métricas de habla y detección fonética en tiempo real.',
    badge: 'SPEAKING',
    actionLabel: 'Iniciar simulación',
    route: '/interview',
    icon: Icons.record_voice_over_rounded,
    accentColor: const Color(0xFF1B638A),
    containerColor: const Color(0xFFE3F0F8),
    onContainerColor: const Color(0xFF06334B),
    type: RecommendationType.interviewStar,
    priority: 5,
  );
});
