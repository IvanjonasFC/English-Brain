import 'package:flutter/material.dart';

/// Botón primario reutilizable con el aspecto plano de siempre (relleno sólido
/// del color de la pantalla, esquinas redondeadas, texto blanco) MÁS una
/// animación de "hundimiento" al pulsar: se encoge un poco y pierde la sombra,
/// igual que los botones de audio/práctica. Conserva el ripple de Material.
///
/// Se colorea por pantalla con el accent de cada feature
/// (p.ej. `TabTheme.vocabulary.accent`, `TabTheme.grammar.accent`).
class GlossyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  /// Color base del botón — el "adaptado a su color" de cada ventana.
  final Color color;

  final double height;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool expand;

  const GlossyButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.color,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.radius = 26,
    this.expand = true,
  });

  @override
  State<GlossyButton> createState() => _GlossyButtonState();
}

class _GlossyButtonState extends State<GlossyButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    final Color base =
        enabled ? widget.color : widget.color.withValues(alpha: 0.45);
    final BorderRadius br = BorderRadius.circular(widget.radius);

    final Widget button = AnimatedScale(
      scale: _pressed ? 0.96 : 1.0, // hundimiento
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: br,
          boxShadow: (enabled && !_pressed)
              ? [
                  BoxShadow(
                    color: base.withValues(alpha: 0.35),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ]
              : const [], // al pulsar pierde la sombra -> sensación de hundir
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: _setPressed,
            borderRadius: br,
            splashColor: Colors.white.withValues(alpha: 0.18),
            highlightColor: Colors.black.withValues(alpha: 0.06),
            child: Padding(
              padding: widget.padding,
              child: Center(
                widthFactor: widget.expand ? null : 1.0,
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: Colors.white, size: 20),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
