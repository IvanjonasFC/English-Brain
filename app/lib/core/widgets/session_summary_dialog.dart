import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../pedagogy/adaptive_recommendation_provider.dart';

class SessionSummaryData {
  final String title;
  final String category;
  final int totalQuestions;
  final int correctQuestions;
  final int xpEarned;
  final int durationSeconds;
  final List<Map<String, String>> mistakes;
  final String? pedagogicalFeedback;

  const SessionSummaryData({
    required this.title,
    required this.category,
    required this.totalQuestions,
    required this.correctQuestions,
    required this.xpEarned,
    required this.durationSeconds,
    this.mistakes = const [],
    this.pedagogicalFeedback,
  });

  double get accuracy => totalQuestions > 0 ? (correctQuestions / totalQuestions) * 100 : 100.0;
  int get mistakesCount => totalQuestions - correctQuestions;
}

class SessionSummaryDialog extends ConsumerWidget {
  final SessionSummaryData data;
  final VoidCallback? onDismiss;

  const SessionSummaryDialog({
    super.key,
    required this.data,
    this.onDismiss,
  });

  static Future<void> show(BuildContext context, SessionSummaryData data, {VoidCallback? onDismiss}) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => SessionSummaryDialog(data: data, onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracy = data.accuracy;
    final isGreat = accuracy >= 80;
    final isGood = accuracy >= 60 && accuracy < 80;

    final primaryColor = isGreat
        ? const Color(0xFF0D8A68)
        : (isGood ? const Color(0xFFE59819) : const Color(0xFFE05638));
    final containerColor = isGreat
        ? const Color(0xFFE0F6EE)
        : (isGood ? const Color(0xFFFEF4E6) : const Color(0xFFFDE8E4));

    final minutes = data.durationSeconds ~/ 60;
    final seconds = data.durationSeconds % 60;
    final durationStr = '${minutes}m ${seconds}s';

    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2024) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header con icono de logro
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: containerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isGreat
                        ? Icons.emoji_events_rounded
                        : (isGood ? Icons.thumb_up_alt_rounded : Icons.fitness_center_rounded),
                    size: 38,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isGreat ? '¡Sesión Completada con Éxito!' : '¡Práctica Finalizada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1E2024),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data.category} · ${data.title}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 18),

              // KPI Row: Precisión, XP, Tiempo, Bitácora
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Precisión',
                      value: '${accuracy.round()}%',
                      color: primaryColor,
                      containerColor: containerColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'XP Ganado',
                      value: '+${data.xpEarned}',
                      color: const Color(0xFF3B82F6),
                      containerColor: const Color(0xFFEFF6FF),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      label: 'Duración',
                      value: durationStr,
                      color: const Color(0xFF8B5CF6),
                      containerColor: const Color(0xFFF5F3FF),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // AI Coach Advice Card (Consejo del Coach en primer plano)
              _buildCoachAdviceCard(isDark, primaryColor),
              const SizedBox(height: 14),

              // Bitácora info badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book_rounded, size: 20, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Entrada guardada automáticamente en tu Bitácora pedagógica.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Errores derivados a FSRS (si los hay)
              if (data.mistakes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sync_problem_rounded, size: 18, color: Color(0xFFDC2626)),
                          const SizedBox(width: 8),
                          Text(
                            '${data.mistakes.length} error(es) enviados a Repaso Espaciado (FSRS)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'El algoritmo programará estos conceptos para que los consolides en tus próximas sesiones.',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF991B1B).withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Botones de acción
              Row(
                children: [
                  if (data.mistakes.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _invalidateState(ref);
                          Navigator.of(context).pop();
                          context.go('/deck');
                        },
                        icon: const Icon(Icons.style_rounded, size: 18),
                        label: const Text('Repasar errores'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _invalidateState(ref);
                        Navigator.of(context).pop();
                        if (onDismiss != null) {
                          onDismiss!();
                        } else {
                          context.go('/');
                        }
                      },
                      icon: const Icon(Icons.check_circle_rounded),
                      label: const Text('Continuar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _invalidateState(WidgetRef ref) {
    ref.invalidate(activeProfileProvider);
    ref.invalidate(profileSummaryProvider);
    ref.invalidate(dueCardsCountProvider);
    ref.invalidate(adaptiveRecommendationProvider);
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required Color color,
    required Color containerColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : containerColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachAdviceCard(bool isDark, Color accentColor) {
    final advice = (data.pedagogicalFeedback != null && data.pedagogicalFeedback!.trim().isNotEmpty)
        ? data.pedagogicalFeedback!
        : (data.accuracy >= 80
            ? '¡Excelente rendimiento y retención! El Coach recomienda mantener esta cadencia y conectar ideas usando transiciones como "Furthermore" o "Consequently".'
            : (data.accuracy >= 50
                ? 'Buen progreso en la práctica. El Coach sugiere prestar especial atención a los conectores clave y a la entonación de oraciones complejas.'
                : 'Sesión de consolidación intensiva. El Coach ha programado estos conceptos prioritariamente en tu mazo de Repaso Espaciado para fijar las estructuras.'));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242730) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Color(0xFF6366F1),
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
                    const Text(
                      'CONSEJO DEL COACH IA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: const Color(0xFF6366F1).withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  advice,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF334155),
                    fontStyle: FontStyle.italic,
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
