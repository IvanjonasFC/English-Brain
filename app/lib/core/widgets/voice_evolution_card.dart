import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/measurement_service.dart';
import '../models/measurement_models.dart';
import 'baseline_comparison_card.dart';

/// Sección de perfil "Tu evolución de voz": muestra, por cada zona y métrica donde el
/// usuario ha grabado, su media actual, la mejora media vs Día 1, y las mejores mejoras
/// con su comparación de audio. Añadir zonas/métricas nuevas no requiere tocar esta UI.
class VoiceEvolutionCard extends ConsumerWidget {
  const VoiceEvolutionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(voiceMeasurementProfileProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.graphic_eq_rounded, size: 20, color: Color(0xFFD97736)),
              SizedBox(width: 8),
              Text(
                'Tu evolución de voz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Compara cómo pronunciabas el Día 1 con cómo lo haces hoy.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const Text(
              'No se pudo cargar tu evolución ahora mismo.',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return const _EmptyState();
              }
              return Column(
                children: [
                  for (final e in entries) _ZoneMetricBlock(entry: e),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ZoneMetricBlock extends StatelessWidget {
  final MeasurementProfileEntry entry;
  const _ZoneMetricBlock({required this.entry});

  @override
  Widget build(BuildContext context) {
    final metric = MeasurementMetrics.describe(entry.metricKey);
    final improved = metric.higherIsBetter ? entry.avgDelta >= 0 : entry.avgDelta <= 0;
    final accent = entry.avgDelta == 0
        ? const Color(0xFF64748B)
        : (improved ? const Color(0xFF10B981) : const Color(0xFFEF4444));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${MeasurementZones.label(entry.zone)} · ${metric.label}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              Text(
                'media ${entry.avgLatest.toStringAsFixed(0)}  ·  '
                '${entry.avgDelta > 0 ? '+' : ''}${entry.avgDelta.toStringAsFixed(0)} vs Día 1',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final c in entry.topImprovements.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BaselineComparisonCard(data: c),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Aún no hay medidas de voz. Graba tu voz en Vocabulario, Gramática, '
        'Comprensión o Entrevista y aquí verás tu evolución "Día 1 vs Hoy".',
        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
    );
  }
}
