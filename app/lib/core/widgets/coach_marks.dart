import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Un paso del tutorial. Si [targetKey] apunta a un widget visible, se dibuja
/// un "foco" (spotlight) recortado sobre él; si no, el paso se muestra como
/// tarjeta centrada (degradación robusta, nunca rompe).
class CoachStep {
  final GlobalKey? targetKey;
  final String title;
  final String body;
  final double radius;
  const CoachStep({
    this.targetKey,
    required this.title,
    required this.body,
    this.radius = 14,
  });
}

/// Muestra una secuencia de coach-marks superpuestos. Devuelve cuando el
/// usuario termina o salta. Reutilizable en cualquier pantalla.
///
/// Robusto: la tarjeta SIEMPRE cabe en pantalla; si el texto es largo, su
/// cuerpo hace scroll y el botón queda fijo y visible. Con háptica y
/// transiciones animadas entre pasos.
Future<void> showCoachMarks(
  BuildContext context,
  List<CoachStep> steps, {
  Color accent = const Color(0xFF56B588),
}) async {
  if (steps.isEmpty) return;
  final overlay = Overlay.of(context);
  final completer = Completer<void>();
  late OverlayEntry entry;
  int index = 0;

  void close() {
    if (entry.mounted) entry.remove();
    if (!completer.isCompleted) completer.complete();
  }

  void goNext() {
    if (index + 1 < steps.length) {
      HapticFeedback.selectionClick();
      index++;
      entry.markNeedsBuild();
    } else {
      HapticFeedback.mediumImpact();
      close();
    }
  }

  void skip() {
    HapticFeedback.selectionClick();
    close();
  }

  entry = OverlayEntry(
    builder: (ctx) {
      return _CoachLayer(
        key: ValueKey<int>(index),
        step: steps[index],
        index: index,
        total: steps.length,
        accent: accent,
        onNext: goNext,
        onSkip: skip,
      );
    },
  );
  HapticFeedback.lightImpact(); // vibración sutil al abrir la guía
  overlay.insert(entry);
  return completer.future;
}

class _CoachLayer extends StatelessWidget {
  final CoachStep step;
  final int index;
  final int total;
  final Color accent;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CoachLayer({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.accent,
    required this.onNext,
    required this.onSkip,
  });

  Rect? _targetRect() {
    final key = step.targetKey;
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;
    if (size.width <= 0 || size.height <= 0) return null;
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screen = mq.size;
    final safeTop = mq.padding.top;
    final safeBottom = mq.padding.bottom;

    Rect? rect = _targetRect();
    Rect? hole;
    if (rect != null) {
      hole = Rect.fromLTRB(
        (rect.left - 8).clamp(0.0, screen.width),
        (rect.top - 8).clamp(0.0, screen.height),
        (rect.right + 8).clamp(0.0, screen.width),
        (rect.bottom + 8).clamp(0.0, screen.height),
      );
    }

    // Colocación robusta: debajo del hueco si hay sitio, si no encima, si no
    // centrada. En TODOS los casos la altura se acota al espacio disponible y
    // el cuerpo hace scroll -> el botón siempre queda visible.
    double? topPos;
    double? bottomPos;
    bool centered = false;
    double maxH;

    if (hole != null) {
      final roomBelow = screen.height - hole.bottom - safeBottom - 30;
      final roomAbove = hole.top - safeTop - 30;
      if (roomBelow >= 170 || roomBelow >= roomAbove) {
        topPos = hole.bottom + 14;
        maxH = screen.height - topPos - safeBottom - 16;
      } else {
        bottomPos = screen.height - (hole.top - 14);
        maxH = (hole.top - 14) - safeTop - 8;
      }
    } else {
      centered = true;
      maxH = screen.height * 0.8;
    }
    maxH = maxH.clamp(150.0, screen.height * 0.85);

    final card = _CoachCard(
      title: step.title,
      body: step.body,
      index: index,
      total: total,
      accent: accent,
      maxHeight: maxH,
      onNext: onNext,
      onSkip: onSkip,
    );

    // Transición fluida (fade + leve escala/desplazamiento) al cambiar de paso.
    final animatedCard = TweenAnimationBuilder<double>(
      key: ValueKey<int>(index),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 12),
            child: Transform.scale(scale: 0.98 + 0.02 * t, child: child),
          ),
        );
      },
      child: card,
    );

    return Stack(
      children: [
        // Scrim con recorte animado; tocar fuera avanza.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onNext,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, t, _) => CustomPaint(
                painter: _ScrimPainter(
                    hole: hole, radius: step.radius, opacity: 0.72 * t),
              ),
            ),
          ),
        ),
        if (hole != null)
          Positioned(
            left: hole.left,
            top: hole.top,
            width: hole.width,
            height: hole.height,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(step.radius),
                  border: Border.all(color: accent, width: 2),
                ),
              ),
            ),
          ),
        if (topPos != null)
          Positioned(left: 16, right: 16, top: topPos, child: animatedCard)
        else if (bottomPos != null)
          Positioned(
              left: 16, right: 16, bottom: bottomPos, child: animatedCard)
        else if (centered)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: animatedCard,
              ),
            ),
          ),
      ],
    );
  }
}

class _ScrimPainter extends CustomPainter {
  final Rect? hole;
  final double radius;
  final double opacity;
  const _ScrimPainter({this.hole, this.radius = 14, this.opacity = 0.72});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: opacity);
    final full = Path()..addRect(Offset.zero & size);
    if (hole == null) {
      canvas.drawPath(full, paint);
      return;
    }
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(hole!, Radius.circular(radius)));
    final diff = Path.combine(PathOperation.difference, full, holePath);
    canvas.drawPath(diff, paint);
  }

  @override
  bool shouldRepaint(covariant _ScrimPainter old) =>
      old.hole != hole || old.radius != radius || old.opacity != opacity;
}

class _CoachCard extends StatelessWidget {
  final String title;
  final String body;
  final int index;
  final int total;
  final Color accent;
  final double maxHeight;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _CoachCard({
    required this.title,
    required this.body,
    required this.index,
    required this.total,
    required this.accent,
    required this.maxHeight,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final last = index + 1 >= total;
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera fija: contador + Saltar
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${index + 1}/$total',
                        style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onSkip,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text('Saltar',
                          style: TextStyle(
                              color: Color(0xFF8A8A8A), fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Cuerpo con scroll (si el texto es largo, se desplaza dentro).
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Color(0xFF1B1B1B),
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(body,
                          style: const TextStyle(
                              color: Color(0xFF4A4A4A),
                              fontSize: 14,
                              height: 1.35)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Botón SIEMPRE visible (fijo abajo).
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onNext,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(last ? 'Entendido' : 'Siguiente',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(width: 6),
                          Icon(
                              last
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 17),
                        ],
                      ),
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
