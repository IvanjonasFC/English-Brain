import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// Estados del orbe de conversacion por voz de Free Talk.
enum FreeTalkOrbState {
  /// En reposo, listo para que el usuario hable.
  idle,

  /// Grabando la voz del usuario.
  listening,

  /// Lito procesando / generando la respuesta.
  thinking,

  /// Lito reproduciendo su respuesta en audio.
  speaking,
}

/// Home tipo "mural" para Free Talk: conversacion por voz centrada en un orbe
/// calido, pensada para practicar fonetica y pronunciacion.
///
/// Es PURAMENTE presentacional: no conoce el recorder, la API ni la medicion.
/// El padre (free_talk_screen) le pasa [state] + callbacks, por lo que este
/// widget vive en su propio archivo y no colisiona con la logica del screen.
class FreeTalkHomeView extends StatefulWidget {
  const FreeTalkHomeView({
    super.key,
    required this.state,
    required this.onOrbTap,
    this.title = '¡Hola!',
    this.subtitle,
    this.lastReply,
    this.topicLabel,
    this.onOpenTopics,
    this.onToggleText,
    this.onShowTranscript,
  });

  /// Estado actual del orbe (controla animacion, icono y texto).
  final FreeTalkOrbState state;

  /// Empezar / parar de hablar. Es la accion principal (tocar el orbe).
  final VoidCallback onOrbTap;

  /// Titulo grande de bienvenida, ej. "¡Hola, Ivan!".
  final String title;

  /// Linea secundaria opcional (si null, se deriva del estado).
  final String? subtitle;

  /// Ultimo mensaje de Lito para dar contexto (pill "util"). Si null, se oculta.
  final String? lastReply;

  /// Tema actual, ej. "Tech Architecture & Trade-offs".
  final String? topicLabel;

  /// Abrir el selector de temas.
  final VoidCallback? onOpenTopics;

  /// Alternar el modo texto (entrada por teclado como respaldo).
  final VoidCallback? onToggleText;

  /// Ver la transcripcion / feedback pedagogico del turno.
  final VoidCallback? onShowTranscript;

  @override
  State<FreeTalkHomeView> createState() => _FreeTalkHomeViewState();
}

class _FreeTalkHomeViewState extends State<FreeTalkHomeView>
    with TickerProviderStateMixin {
  late final AnimationController _breathe; // respiracion continua
  late final AnimationController _ripple; // ondas (listening / speaking)
  late final AnimationController _spin; // giro suave (thinking)

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _ripple = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _breathe.dispose();
    _ripple.dispose();
    _spin.dispose();
    super.dispose();
  }

  /// Bilingüe por locale de la app (ES/EN), sin depender de ARB. Si el idioma
  /// no es español, cae a inglés. Se puede migrar a `context.l10n` más adelante.
  bool get _isEs => Localizations.localeOf(context).languageCode == 'es';

  String get _statusLine {
    switch (widget.state) {
      case FreeTalkOrbState.idle:
        return widget.subtitle ??
            (_isEs ? 'Listo cuando quieras' : 'Ready when you are');
      case FreeTalkOrbState.listening:
        return _isEs ? 'Escuchando tu voz…' : 'Listening…';
      case FreeTalkOrbState.thinking:
        return _isEs ? 'Lito está pensando…' : 'Lito is thinking…';
      case FreeTalkOrbState.speaking:
        return _isEs ? 'Lito está hablando' : 'Lito is speaking';
    }
  }

  String get _hintLine {
    switch (widget.state) {
      case FreeTalkOrbState.idle:
        return _isEs ? 'Toca el orbe y habla en inglés' : 'Tap the orb and speak';
      case FreeTalkOrbState.listening:
        return _isEs ? 'Toca de nuevo para enviar' : 'Tap again to send';
      case FreeTalkOrbState.thinking:
        return _isEs ? 'Un momento…' : 'One moment…';
      case FreeTalkOrbState.speaking:
        return _isEs ? 'Escucha la pronunciación nativa' : 'Listen to native pronunciation';
    }
  }

  IconData get _orbIcon {
    switch (widget.state) {
      case FreeTalkOrbState.idle:
        return Icons.mic_none_rounded;
      case FreeTalkOrbState.listening:
        return Icons.graphic_eq_rounded;
      case FreeTalkOrbState.thinking:
        return Icons.more_horiz_rounded;
      case FreeTalkOrbState.speaking:
        return Icons.volume_up_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      color: AppTheme.background,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Orbe responsive: ~44% del ancho, acotado para movil/tablet/web.
            final orbSize = (constraints.maxWidth * 0.62).clamp(180.0, 300.0);

            return Column(
              children: [
                const Spacer(flex: 2),
                _buildTopicChip(isDark),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _statusLine,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                const Spacer(flex: 1),
                // ===== ORBE =====
                SizedBox(
                  width: orbSize + 80,
                  height: orbSize + 80,
                  child: Center(
                    child: GestureDetector(
                      onTap: widget.onOrbTap,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_breathe, _ripple, _spin]),
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(orbSize + 80, orbSize + 80),
                            painter: _OrbPainter(
                              coreSize: orbSize,
                              breathe: _breathe.value,
                              ripple: _ripple.value,
                              spin: _spin.value,
                              state: widget.state,
                              core: AppTheme.primary,
                              coreLight: AppTheme.primaryLight,
                            ),
                            child: SizedBox(
                              width: orbSize + 80,
                              height: orbSize + 80,
                              child: Center(
                                child: Icon(
                                  _orbIcon,
                                  size: orbSize * 0.24,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _hintLine,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildLastReply(isDark),
                const Spacer(flex: 2),
                _buildActionBar(isDark),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopicChip(bool isDark) {
    if (widget.topicLabel == null || widget.topicLabel!.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onOpenTopics,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.topic_outlined, size: 14, color: AppTheme.primary),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  widget.topicLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastReply(bool isDark) {
    final reply = widget.lastReply?.trim();
    if (reply == null || reply.isEmpty) {
      return const SizedBox(height: 0);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(reply),
        margin: const EdgeInsets.symmetric(horizontal: 28),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          reply,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SoftAction(
          icon: Icons.tune_rounded,
          label: _isEs ? 'Temas' : 'Topics',
          onTap: widget.onOpenTopics,
        ),
        _SoftAction(
          icon: Icons.keyboard_rounded,
          label: _isEs ? 'Texto' : 'Text',
          onTap: widget.onToggleText,
        ),
        _SoftAction(
          icon: Icons.forum_outlined,
          label: _isEs ? 'Transcripción' : 'Transcript',
          onTap: widget.onShowTranscript,
        ),
      ],
    );
  }
}

/// Boton secundario suave (estilo mural: icono redondo + etiqueta).
class _SoftAction extends StatelessWidget {
  const _SoftAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Icon(icon, size: 20, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinta el orbe calido: glow, ondas reactivas y nucleo con gradiente radial
/// desplazado para dar sensacion "liquida".
class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.coreSize,
    required this.breathe,
    required this.ripple,
    required this.spin,
    required this.state,
    required this.core,
    required this.coreLight,
  });

  final double coreSize;
  final double breathe; // 0..1 (reverse)
  final double ripple; // 0..1 (loop)
  final double spin; // 0..1 (loop)
  final FreeTalkOrbState state;
  final Color core;
  final Color coreLight;

  bool get _rings =>
      state == FreeTalkOrbState.listening || state == FreeTalkOrbState.speaking;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Respiracion: el nucleo late suave; mas intenso al escuchar.
    final beat = state == FreeTalkOrbState.listening ? 0.10 : 0.045;
    final coreRadius = (coreSize / 2) * (1 + beat * (breathe - 0.5) * 2);

    // ===== Glow exterior =====
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          core.withValues(alpha: 0.34),
          core.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius * 1.7))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, coreRadius * 1.55, glow);

    // ===== Ondas reactivas (listening / speaking) =====
    if (_rings) {
      const count = 3;
      for (var i = 0; i < count; i++) {
        final phase = (ripple + i / count) % 1.0;
        final r = coreRadius * (1.0 + phase * 0.75);
        final alpha = (1.0 - phase) * 0.42;
        final ringPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = core.withValues(alpha: alpha);
        canvas.drawCircle(center, r, ringPaint);
      }
    }

    // ===== Arco giratorio (thinking) =====
    if (state == FreeTalkOrbState.thinking) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.2
        ..color = core.withValues(alpha: 0.55);
      final rect = Rect.fromCircle(center: center, radius: coreRadius * 1.16);
      canvas.drawArc(rect, spin * 2 * math.pi, math.pi * 0.6, false, arcPaint);
      canvas.drawArc(
          rect, spin * 2 * math.pi + math.pi, math.pi * 0.4, false, arcPaint);
    }

    // ===== Nucleo con gradiente radial desplazado (efecto liquido) =====
    final dx = math.cos(spin * 2 * math.pi) * coreRadius * 0.22;
    final dy = math.sin(spin * 2 * math.pi) * coreRadius * 0.22;
    final corePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.95,
        colors: [coreLight, core],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: center.translate(dx, dy),
          radius: coreRadius,
        ),
      );
    canvas.drawCircle(center, coreRadius, corePaint);

    // ===== Brillo especular =====
    final highlight = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center.translate(-coreRadius * 0.3, -coreRadius * 0.34),
          radius: coreRadius * 0.55,
        ),
      );
    canvas.drawCircle(
      center.translate(-coreRadius * 0.28, -coreRadius * 0.3),
      coreRadius * 0.5,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.breathe != breathe ||
      old.ripple != ripple ||
      old.spin != spin ||
      old.state != state;
}
