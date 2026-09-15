import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';

/// Comprehension (Reading & Listening) design tokens — delegates to TabTheme
/// (teal accent), mirroring GrammarTheme so the tab feels native.
class CompTheme {
  // ── Accent ────────────────────────────────────────────────────────────
  static Color get primary            => TabTheme.comprehension.accent;
  static Color get primaryContainer   => TabTheme.comprehension.containerHigh;
  static Color get onPrimary          => TabTheme.comprehension.onAccent;
  static Color get onPrimaryContainer => Colors.white;
  static Color get tertiary           => TabTheme.comprehension.accent;
  static Color get tertiaryContainer  => TabTheme.comprehension.container;
  static Color get onTertiary         => TabTheme.comprehension.onAccent;
  static const Color error            = Color(0xFFBA1A1A);
  static Color get secondary          => AppTheme.textSecondary;

  // Container tints
  static Color get container          => TabTheme.comprehension.container;
  static Color get containerHigh      => TabTheme.comprehension.containerHigh;
  static Color get onContainer        => TabTheme.comprehension.onContainer;
  static Color get secondaryContainer => TabTheme.surfaceContainer;
  static Color get onSecondaryContainer => TabTheme.onSurface;

  // ── Surfaces ──────────────────────────────────────────────────────────
  static Color get surface                 => TabTheme.surface;
  static Color get surfaceContainerLowest  => TabTheme.surfaceContainerLowest;
  static Color get surfaceContainerLow     => TabTheme.surfaceContainerLow;
  static Color get surfaceContainer        => TabTheme.surfaceContainer;
  static Color get surfaceContainerHigh    => TabTheme.surfaceContainerHigh;
  static Color get surfaceContainerHighest => TabTheme.surfaceContainerHighest;
  static Color get onSurface               => TabTheme.onSurface;
  static Color get onSurfaceVariant        => TabTheme.onSurfaceVariant;
  static Color get outline                 => TabTheme.outline;
  static Color get outlineVariant          => TabTheme.outlineVariant;
  static Color get errorContainer   => AppTheme.isLight ? const Color(0xFFFFDAD6) : const Color(0xFF561A18);
  static Color get onErrorContainer => AppTheme.isLight ? const Color(0xFF93000A) : const Color(0xFFFFB4AB);

  // ── Typography (delegates to TabTheme) ────────────────────────────────
  static TextStyle displayMd({Color? color, FontWeight fontWeight = FontWeight.w700}) =>
      TabTheme.displayMd(color: color, fw: fontWeight);
  static TextStyle headlineSm({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.headlineSm(color: color, fw: fontWeight);
  static TextStyle titleMd({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.titleMd(color: color, fw: fontWeight);
  static TextStyle titleSm({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.titleSm(color: color, fw: fontWeight);
  static TextStyle bodyLg({Color? color, FontWeight fontWeight = FontWeight.w400}) =>
      TabTheme.bodyLg(color: color, fw: fontWeight);
  static TextStyle bodyMd({Color? color, FontWeight fontWeight = FontWeight.w400}) =>
      TabTheme.bodyMd(color: color, fw: fontWeight);
  static TextStyle bodySm({Color? color, FontWeight fontWeight = FontWeight.w400, FontStyle? fontStyle}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 0,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color ?? onSurfaceVariant,
      );
  static TextStyle labelLg({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.labelLg(color: color, fw: fontWeight);
  static TextStyle labelMd({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.labelMd(color: color, fw: fontWeight);
  static TextStyle labelSm({Color? color, FontWeight fontWeight = FontWeight.w700}) =>
      TabTheme.labelSm(color: color, fw: fontWeight);
}
