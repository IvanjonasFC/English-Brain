import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/measurement_service.dart';
import '../models/measurement_models.dart';

/// Tarjeta reutilizable "Día 1 vs Hoy": muestra el baseline inicial y el último de un
/// ítem, con la mejora (delta) y dos botones para escuchar cada grabación.
/// Se usa igual en cualquier zona y con cualquier métrica.
class BaselineComparisonCard extends ConsumerWidget {
  final MeasurementComparison data;
  final String? title;

  const BaselineComparisonCard({super.key, required this.data, this.title});

  Future<void> _play(WidgetRef ref, String? path) async {
    final svc = ref.read(measurementServiceProvider);
    final url = await svc.resolveAudioUrl(path);
    if (url == null) return;
    await ref.read(audioPlayerProvider).playAudioUrl(url);
  }

  String _daysAgo(DateTime? d) {
    if (d == null) return '';
    final days = DateTime.now().difference(d).inDays;
    if (days <= 0) return 'hoy';
    if (days == 1) return 'hace 1 día';
    if (days < 30) return 'hace $days días';
    final months = (days / 30).floor();
    return months == 1 ? 'hace 1 mes' : 'hace $months meses';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metric = MeasurementMetrics.describe(data.metricKey);
    final delta = data.deltaValue;
    final improved = metric.higherIsBetter ? delta >= 0 : delta <= 0;
    final Color accent = delta == 0
        ? const Color(0xFF64748B)
        : (improved ? const Color(0xFF10B981) : const Color(0xFFEF4444));
    final String deltaLabel =
        '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(0)} ${metric.unit}';
    final String heading = title ?? data.label ?? data.targetId ?? metric.label;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (data.hasProgress)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    deltaLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${metric.label} · ${data.attempts} ${data.attempts == 1 ? 'intento' : 'intentos'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _AudioPill(
                  label: 'Día 1',
                  sublabel: data.baselineValue > 0
                      ? '${data.baselineValue.toStringAsFixed(0)} · ${_daysAgo(data.baselineCreatedAt)}'
                      : _daysAgo(data.baselineCreatedAt),
                  color: const Color(0xFF64748B),
                  hasAudio: (data.baselineAudioUrl ?? '').isNotEmpty,
                  onTap: () => _play(ref, data.baselineAudioUrl),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AudioPill(
                  label: 'Hoy',
                  sublabel: data.latestValue > 0 ? data.latestValue.toStringAsFixed(0) : '',
                  color: accent,
                  hasAudio: (data.latestAudioUrl ?? '').isNotEmpty,
                  onTap: () => _play(ref, data.latestAudioUrl),
                ),
              ),
            ],
          ),
          if (!data.hasProgress) ...[
            const SizedBox(height: 8),
            const Text(
              'Vuelve a practicar este ítem y aquí escucharás tu evolución.',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AudioPill extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final bool hasAudio;
  final VoidCallback onTap;

  const _AudioPill({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.hasAudio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: hasAudio ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: hasAudio ? color.withValues(alpha: 0.10) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasAudio ? color.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasAudio ? Icons.play_arrow_rounded : Icons.volume_off_rounded,
              size: 18,
              color: hasAudio ? color : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: hasAudio ? color : const Color(0xFF94A3B8),
                  ),
                ),
                if (sublabel.isNotEmpty)
                  Text(
                    sublabel,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
