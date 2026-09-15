import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/voice_selection.dart';
import '../providers/app_providers.dart';
import '../models/pitch_models.dart';

const Color _kRefColor = Color(0xFF3B82F6);   // nativo (azul)
const Color _kUserColor = Color(0xFFF59E0B);  // alumno (amarillo/ámbar)

/// Dibuja una o dos curvas de entonacion normalizadas superpuestas.
class PitchContourChart extends StatelessWidget {
  final List<double> refCurve;
  final List<double> userCurve;
  final double height;

  const PitchContourChart({
    super.key,
    required this.userCurve,
    this.refCurve = const [],
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _PitchPainter(refCurve: refCurve, userCurve: userCurve),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  final List<double> refCurve;
  final List<double> userCurve;

  _PitchPainter({required this.refCurve, required this.userCurve});

  static const double _range = 2.5; // z-normalizado, recortado a +-2.5

  Path _pathFor(List<double> c, Size size) {
    final path = Path();
    if (c.length < 2) return path;
    for (int i = 0; i < c.length; i++) {
      final x = size.width * (i / (c.length - 1));
      final v = c[i].clamp(-_range, _range);
      final y = size.height * (0.5 - (v / (_range * 2)));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF8FAFC);
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    canvas.drawRRect(rrect, bg);

    // Linea central (media)
    final grid = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), grid);

    if (refCurve.length >= 2) {
      canvas.drawPath(
        _pathFor(refCurve, size),
        Paint()
          ..color = _kRefColor.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
    if (userCurve.length >= 2) {
      canvas.drawPath(
        _pathFor(userCurve, size),
        Paint()
          ..color = _kUserColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PitchPainter old) =>
      old.refCurve != refCurve || old.userCurve != userCurve;
}

/// Panel autocontenido: recibe la ruta del audio grabado y el texto objetivo,
/// pide el analisis al backend y dibuja la comparacion de entonacion.
/// Si se pasan userId/zone/targetId y hay similitud, registra la medida 'pitch_similarity'.
class PitchComparatorPanel extends ConsumerStatefulWidget {
  final String audioPath;
  final String? text;         // texto objetivo (null => solo curva del alumno)
  final String voice;
  final String? userId;
  final String? zone;
  final String? targetId;

  const PitchComparatorPanel({
    super.key,
    required this.audioPath,
    this.text,
    this.voice = 'en-US-GuyNeural',
    this.userId,
    this.zone,
    this.targetId,
  });

  @override
  ConsumerState<PitchComparatorPanel> createState() => _PitchComparatorPanelState();
}

class _PitchComparatorPanelState extends ConsumerState<PitchComparatorPanel> {
  bool _loading = true;
  PitchComparison? _result;
  String? _forPath;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  @override
  void didUpdateWidget(covariant PitchComparatorPanel old) {
    super.didUpdateWidget(old);
    if (old.audioPath != widget.audioPath) {
      _analyze();
    }
  }

  Future<void> _analyze() async {
    _forPath = widget.audioPath;
    setState(() {
      _loading = true;
      _result = null;
    });
    PitchComparison? res;
    try {
      res = await ref.read(apiClientProvider).analyzePitch(
            audioPath: widget.audioPath,
            text: widget.text,
            voice: AppVoices.resolve(widget.voice, widget.text ?? ''),
          );
    } catch (_) {
      res = null;
    }
    if (!mounted || _forPath != widget.audioPath) return;
    // Registrar la medida de entonacion si procede (best-effort).
    if (res != null &&
        res.similarity != null &&
        widget.userId != null &&
        widget.zone != null &&
        widget.targetId != null) {
      // ignore: unawaited_futures
      ref.read(measurementServiceProvider).record(
            userId: widget.userId!,
            zone: widget.zone!,
            targetId: widget.targetId!,
            metricKey: 'pitch_similarity',
            value: res.similarity!,
            targetType: 'word',
            label: widget.text,
          );
    }
    setState(() {
      _loading = false;
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart_rounded, size: 18, color: Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Entonación y acento',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
              ),
              if (_result?.similarity != null) _simChip(_result!.similarity!),
            ],
          ),
          const SizedBox(height: 10),
          _body(),
        ],
      ),
    );
  }

  Widget _simChip(double sim) {
    final Color c = sim >= 75
        ? const Color(0xFF10B981)
        : (sim >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text('${sim.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c)),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 10),
            Text('Analizando tu entonación…', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      );
    }
    final r = _result;
    if (r == null || !r.ok) {
      final msg = (r != null && r.available == false)
          ? 'El comparador de entonación aún no está activo en el servidor.'
          : (r?.reason == 'no_voice'
              ? 'No se detectó voz clara para analizar la entonación. Habla un poco más alto y vocaliza.'
              : 'No se pudo analizar la entonación esta vez.');
      return Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PitchContourChart(userCurve: r.userCurve, refCurve: r.refCurve),
        const SizedBox(height: 8),
        Row(
          children: [
            if (r.hasReference) ...[
              _legendDot(_kRefColor, 'Nativo'),
              const SizedBox(width: 14),
            ],
            _legendDot(_kUserColor, 'Tú'),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          r.hasReference
              ? 'Compara la forma de tu tono con la del hablante nativo: cuánto subes y bajas la voz en cada parte.'
              : 'Tu curva de entonación: cómo sube y baja tu tono al hablar.',
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 4, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
      ],
    );
  }
}
