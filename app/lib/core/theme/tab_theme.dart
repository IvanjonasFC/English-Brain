import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TabAccent: accent palette for a single tab
// ─────────────────────────────────────────────────────────────────────────────
class TabAccent {
  final Color _light;
  final Color _dark;

  const TabAccent(this._light, this._dark);

  /// Main accent — icon, button fill, progress, active indicator
  Color get accent => AppTheme.isLight ? _light : _dark;

  /// Tinted container — card bg, chips, subtle fills
  Color get container =>
      AppTheme.isLight ? _light.withValues(alpha: 0.12) : _dark.withValues(alpha: 0.18);

  /// Deeper container for hover/selected
  Color get containerHigh =>
      AppTheme.isLight ? _light.withValues(alpha: 0.22) : _dark.withValues(alpha: 0.30);

  /// Text / icon on accent-filled surface
  Color get onAccent => Colors.white;

  /// Text / icon on container surface
  Color get onContainer => accent;
}

class CefrPillStyle {
  final Color background;
  final Color pastelBackground;
  final Color text;
  final Color dot;

  const CefrPillStyle({
    required this.background,
    required this.pastelBackground,
    required this.text,
    required this.dot,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// TabTheme: shared surfaces, per-tab accents, Plus Jakarta Sans typography
// ─────────────────────────────────────────────────────────────────────────────
class TabTheme {
  TabTheme._();

  // ── Per-tab accents (Paleta Pastel Armónica) ───────────────────────────
  static const speaking   = TabAccent(Color(0xFFEA8E51), Color(0xFFF7B489)); // Melocotón / Naranja suave
  static const vocabulary = TabAccent(Color(0xFF56B588), Color(0xFF86D9B6)); // Menta / Salvia suave
  static const grammar    = TabAccent(Color(0xFF6B9DE8), Color(0xFF9EC2F7)); // Azul cielo / Cerúleo suave
  static const fsrs       = TabAccent(Color(0xFF937CD8), Color(0xFFBEAEEF)); // Lavanda / Lila suave
  static const irregularVerbs = TabAccent(Color(0xFF0D9488), Color(0xFF2DD4BF)); // Teal Tecnológico
  static const phrasalVerbs   = TabAccent(Color(0xFFCA8A04), Color(0xFFFACC15)); // Amarillo Dorado / Gold
  static const comprehension = TabAccent(Color(0xFFDF7891), Color(0xFFF4A8BA)); // Rosa suave / Empolvado
  static const profile    = TabAccent(Color(0xFFE5A144), Color(0xFFF3C47E)); // Miel / Ámbar dorado suave

  // ── Shared neutral surface tokens (delegates to AppTheme) ─────────────
  static Color get background => AppTheme.background;
  static Color get surface    => AppTheme.surface;

  static Color get surfaceContainerLowest =>
      AppTheme.isLight ? const Color(0xFFFFFFFF) : AppTheme.surface;
  static Color get surfaceContainerLow =>
      AppTheme.isLight ? const Color(0xFFF6F2EA) : const Color(0xFF201A14);
  static Color get surfaceContainer =>
      AppTheme.isLight ? const Color(0xFFEFEADF) : AppTheme.surfaceLight;
  static Color get surfaceContainerHigh =>
      AppTheme.isLight ? const Color(0xFFE6E0D4) : AppTheme.border;
  static Color get surfaceContainerHighest =>
      AppTheme.isLight ? const Color(0xFFDDD8CC) : const Color(0xFF3A3127);

  static Color get onSurface        => AppTheme.textPrimary;
  static Color get onSurfaceVariant => AppTheme.textSecondary;
  static Color get outline          => AppTheme.border;
  static Color get outlineVariant   =>
      AppTheme.isLight ? const Color(0xFFD8D2C8) : AppTheme.border;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppTheme.isLight ? 0.03 : 0.22),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  // ── Typography — Plus Jakarta Sans ────────────────────────────────────
  static TextStyle displayMd({Color? color, FontWeight fw = FontWeight.w700}) =>
      GoogleFonts.plusJakartaSans(fontSize: 24, height: 1.25, letterSpacing: -0.4, fontWeight: fw, color: color ?? onSurface);

  static TextStyle headlineSm({Color? color, FontWeight fw = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(fontSize: 18, height: 1.35, letterSpacing: -0.2, fontWeight: fw, color: color ?? onSurface);

  static TextStyle titleMd({Color? color, FontWeight fw = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.4, letterSpacing: -0.1, fontWeight: fw, color: color ?? onSurface);

  static TextStyle titleSm({Color? color, FontWeight fw = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4, letterSpacing: -0.05, fontWeight: fw, color: color ?? onSurface);

  static TextStyle bodyLg({Color? color, FontWeight fw = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.5, letterSpacing: 0, fontWeight: fw, color: color ?? onSurface);

  static TextStyle bodyMd({Color? color, FontWeight fw = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.45, letterSpacing: 0, fontWeight: fw, color: color ?? onSurface);

  static TextStyle bodySm({Color? color, FontWeight fw = FontWeight.w400}) =>
      GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.4, letterSpacing: 0.1, fontWeight: fw, color: color ?? onSurfaceVariant);

  static TextStyle labelLg({Color? color, FontWeight fw = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.4, letterSpacing: 0.1, fontWeight: fw, color: color ?? onSurface);

  static TextStyle labelMd({Color? color, FontWeight fw = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.4, letterSpacing: 0.15, fontWeight: fw, color: color ?? onSurfaceVariant);

  static TextStyle labelSm({Color? color, FontWeight fw = FontWeight.w600}) =>
      GoogleFonts.plusJakartaSans(fontSize: 11, height: 1.4, letterSpacing: 0.3, fontWeight: fw, color: color ?? onSurfaceVariant);

  // ── CEFR difficulty badge & rail system ─────────────────────────────────
  /// Rail CEFR CANÓNICO — única fuente de verdad de la agrupación de dificultad
  /// Rail CEFR CANÓNICO — única fuente de verdad de la agrupación de dificultad
  /// en TODAS las ventanas (Vocabulario, Gramática, Inmersión, Speaking).
  /// Contiene exclusivamente los selectores por dificultad.
  static const List<Map<String, String>> cefrRail = [
    {'id': 'A1-A2', 'es': 'A1 - A2', 'en': 'A1 - A2'},
    {'id': 'B1-B2', 'es': 'B1 - B2', 'en': 'B1 - B2'},
    {'id': 'B2-C1', 'es': 'B2 - C1', 'en': 'B2 - C1'},
    {'id': 'C1', 'es': 'C1 Executive', 'en': 'C1 Executive'},
  ];


  static CefrPillStyle cefrStyle(String level) {
    final l = level.trim().toUpperCase();
    if (l == 'ALL' || l == 'TODOS') {
      return const CefrPillStyle(
        background: Color(0xFF64748B),
        pastelBackground: Color(0xFFF1F5F9),
        text: Color(0xFF334155),
        dot: Color(0xFF64748B),
      );
    }
    if (l.contains('C2')) {
      // Rosa Suave (Inmersión / Maestría)
      return const CefrPillStyle(
        background: Color(0xFFDF7891),
        pastelBackground: Color(0xFFFAF0F3),
        text: Color(0xFF8E2A42),
        dot: Color(0xFFDF7891),
      );
    }
    if (l.contains('STRATEGIC') || (l.contains('C1') && !l.contains('B2-C1') && !l.contains('B2 - C1')) || l.contains('LEAD') || l.contains('LEVEL 4')) {
      // Lavanda / Lila Suave (Strategic C1 Executive)
      return const CefrPillStyle(
        background: Color(0xFF937CD8),
        pastelBackground: Color(0xFFF4F0FB),
        text: Color(0xFF533E91),
        dot: Color(0xFF937CD8),
      );
    } else if (l.contains('B2-C1') || l.contains('B2 - C1') || l.contains('ARCHITECTURE') || l.contains('SENIOR') || l.contains('LEVEL 3')) {
      // Melocotón / Naranja Suave (Architecture B2-C1 — Idéntico a la pestaña Speaking / Entrevista)
      return const CefrPillStyle(
        background: Color(0xFFEA8E51),
        pastelBackground: Color(0xFFFDF3EB),
        text: Color(0xFF9E4E18),
        dot: Color(0xFFEA8E51),
      );
    } else if (l.contains('B1-B2') || l.contains('B1 - B2') || l.contains('SYSTEMS') || l.contains('MID') || l.contains('LEVEL 2') || l.contains('B1')) {
      // Azul Cielo / Cerúleo Suave (Systems B1-B2 — Idéntico a la pestaña Gramática)
      return const CefrPillStyle(
        background: Color(0xFF6B9DE8),
        pastelBackground: Color(0xFFEEF4FD),
        text: Color(0xFF24579F),
        dot: Color(0xFF6B9DE8),
      );
    } else if (l.contains('B2')) {
      // Naranja suave para B2 puro
      return const CefrPillStyle(
        background: Color(0xFFEA8E51),
        pastelBackground: Color(0xFFFDF3EB),
        text: Color(0xFF9E4E18),
        dot: Color(0xFFEA8E51),
      );
    } else if (l.contains('A1') || l.contains('A2') || l.contains('FOUNDATIONS') || l.contains('JUNIOR') || l.contains('LEVEL 1')) {
      // Menta / Salvia Suave (Foundations A1-A2 — Idéntico a la pestaña Vocabulario)
      return const CefrPillStyle(
        background: Color(0xFF56B588),
        pastelBackground: Color(0xFFEBF7F1),
        text: Color(0xFF23724C),
        dot: Color(0xFF56B588),
      );
    }
    return const CefrPillStyle(
      background: Color(0xFF6B9DE8),
      pastelBackground: Color(0xFFEEF4FD),
      text: Color(0xFF24579F),
      dot: Color(0xFF6B9DE8),
    );
  }

  static Color cefrColor(String level) => cefrStyle(level).background;

  static Widget cefrPill(String level, {double fontSize = 11, bool showDot = true, bool filled = false}) {
    final style = cefrStyle(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showDot ? 8.5 : 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: filled
            ? style.background
            : (AppTheme.isLight ? style.pastelBackground : style.dot.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled
              ? style.background
              : style.dot.withValues(alpha: AppTheme.isLight ? 0.35 : 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: filled ? Colors.white : style.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            level,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : style.text,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  static Widget topicPill(
    String topic, {
    double fontSize = 11,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? 8 : 8,
        vertical: 2.5,
      ),
      decoration: BoxDecoration(
        color: surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2.5,
              color: iconColor ?? onSurfaceVariant,
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            topic,
            style: GoogleFonts.plusJakartaSans(
              fontSize: fontSize,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  static Widget filterLevelPill({
    required String id,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final style = cefrStyle(id.toLowerCase() == 'all' || id.toLowerCase() == 'todos' ? 'ALL' : (label.isNotEmpty ? label : id));
    final isAll = id.toLowerCase() == 'all' || id.toLowerCase() == 'todos';

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _BouncyPress(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
          decoration: BoxDecoration(
            color: isSelected
                ? style.background // Relleno sólido adaptado
                : (AppTheme.isLight ? style.pastelBackground : style.dot.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected
                  ? style.background
                  : style.dot.withValues(alpha: AppTheme.isLight ? 0.35 : 0.22),
              width: isSelected ? 1.2 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: style.background.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isAll) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : style.dot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5.5),
              ],
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isAll ? (AppTheme.isLight ? const Color(0xFF475569) : Colors.white70) : style.text),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Determina automáticamente el ID de píldora según el nivel CEFR del usuario
  static String defaultPillForUserLevel(String? userLevel) {
    if (userLevel == null || userLevel.isEmpty) return 'A1-A2';
    final l = userLevel.trim().toUpperCase();
    // Devuelve SIEMPRE un id del rail canónico de 4 cubos.
    if (l.contains('C2')) return 'C1';
    if (l.contains('C1')) return l.contains('B2') ? 'B2-C1' : 'C1';
    if (l.contains('B1') || l.contains('B2')) return 'B1-B2';
    if (l.contains('A1') || l.contains('A2')) return 'A1-A2';
    if (l.contains('JUNIOR') || l.contains('FOUNDATIONS')) return 'A1-A2';
    if (l.contains('MID') || l.contains('SYSTEMS')) return 'B1-B2';
    if (l.contains('SENIOR') || l.contains('ARCHITECTURE')) return 'B2-C1';
    if (l.contains('STRATEGIC') || l.contains('LEAD')) return 'C1';
    return 'A1-A2';
  }

  /// Determina el nivel de entrevista según el nivel CEFR del usuario
  static String defaultInterviewLevelForUserLevel(String? userLevel) {
    if (userLevel == null || userLevel.isEmpty) return 'junior';
    final l = userLevel.trim().toUpperCase();
    if (l.contains('A1') || l.contains('A2')) return 'junior';
    if (l == 'B1') return 'mid';
    if (l == 'B2') return 'senior';
    if (l.contains('C1') || l.contains('C2')) return 'strategic';
    return 'junior';
  }

  // ── Convenience decorations ────────────────────────────────────────────
  static BoxDecoration card({Color? color, double radius = 20}) => BoxDecoration(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: AppTheme.isLight ? 0.04 : 0.12), blurRadius: 16, offset: const Offset(0, 4))],
      );

  static ButtonStyle filledButton(TabAccent tab, {double radius = 16}) =>
      ElevatedButton.styleFrom(
        backgroundColor: tab.accent,
        foregroundColor: tab.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      );

  // ── Kicker UNIFICADO de recomendación IA ────────────────────────────────
  /// Etiqueta ÚNICA de la recomendación adaptativa en TODAS las ventanas
  /// (los 4 hubs del nav + los laboratorios de Home). Antes cada pantalla ponía
  /// un texto distinto ("UNIDAD PRIORITARIA", "HISTORIA PRIORITARIA",
  /// "RUTA RECOMENDADA"…). Ahora todas usan la misma familia, tintada con el
  /// accent del módulo para mantener su identidad de color.
  static const String aiFocusLabelEs = 'TU FOCO DE HOY · IA';
  static const String aiFocusLabelEn = "TODAY'S FOCUS · AI";

  /// Pill unificada del "foco de hoy". [accent] = color del módulo.
  static Widget aiFocusKicker(Color accent, {required bool isEn}) {
    final Color bg = accent.withValues(alpha: AppTheme.isLight ? 0.12 : 0.20);
    final Color borderCol = accent.withValues(alpha: AppTheme.isLight ? 0.38 : 0.48);
    final Color fg = AppTheme.isLight
        ? Color.lerp(accent, Colors.black, 0.18)!
        : Color.lerp(accent, Colors.white, 0.28)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            isEn ? aiFocusLabelEn : aiFocusLabelEs,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncyPress extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyPress({required this.child, required this.onTap});

  @override
  State<_BouncyPress> createState() => _BouncyPressState();
}

class _BouncyPressState extends State<_BouncyPress> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
