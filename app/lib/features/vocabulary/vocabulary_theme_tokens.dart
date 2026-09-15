import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tab_theme.dart';

/// Vocabulary design tokens — delegates to TabTheme (green accent).
class VocabTheme {
  // ── Accent ────────────────────────────────────────────────────────────
  static Color get primary           => TabTheme.vocabulary.accent;
  static Color get primaryContainer  => TabTheme.vocabulary.containerHigh;
  static Color get onPrimary         => TabTheme.vocabulary.onAccent;
  static Color get onPrimaryContainer=> Colors.white;
  static Color get tertiary          => TabTheme.vocabulary.accent;
  static Color get tertiaryContainer => TabTheme.vocabulary.container;
  static Color get onTertiary        => TabTheme.vocabulary.onAccent;
  static const Color error           = Color(0xFFBA1A1A);
  static Color get secondary         => AppTheme.textSecondary;
  static const Color onSecondary     = Colors.white;

  // Fixed palette tints (derived from accent, no explicit Material3 fixed roles)
  static Color get primaryFixed      => TabTheme.vocabulary.container;
  static Color get primaryFixedDim   => TabTheme.vocabulary.containerHigh;
  static Color get onPrimaryFixed    => TabTheme.vocabulary.onContainer;
  static Color get onPrimaryFixedVariant => TabTheme.vocabulary.onContainer;
  static Color get tertiaryFixed     => TabTheme.vocabulary.container;
  static Color get tertiaryFixedDim  => TabTheme.vocabulary.containerHigh;
  static Color get onTertiaryFixed   => TabTheme.vocabulary.onContainer;
  static Color get onTertiaryFixedVariant => TabTheme.vocabulary.onContainer;
  static Color get secondaryFixed    => TabTheme.surfaceContainer;
  static Color get secondaryFixedDim => TabTheme.surfaceContainerHigh;

  // ── Surfaces ──────────────────────────────────────────────────────────
  static Color get surface                 => TabTheme.surface;
  static Color get surfaceDim             => TabTheme.surfaceContainerLow;
  static Color get surfaceBright          => TabTheme.surface;
  static Color get surfaceContainerLowest => TabTheme.surfaceContainerLowest;
  static Color get surfaceContainerLow    => TabTheme.surfaceContainerLow;
  static Color get surfaceContainer       => TabTheme.surfaceContainer;
  static Color get surfaceContainerHigh   => TabTheme.surfaceContainerHigh;
  static Color get surfaceContainerHighest=> TabTheme.surfaceContainerHighest;
  static Color get surfaceVariant         => TabTheme.surfaceContainerHigh;
  static Color get onSurface              => TabTheme.onSurface;
  static Color get onSurfaceVariant       => TabTheme.onSurfaceVariant;
  static Color get outline                => TabTheme.outline;
  static Color get outlineVariant         => TabTheme.outlineVariant;
  static Color get secondaryContainer     => TabTheme.surfaceContainer;
  static Color get onSecondaryContainer   => TabTheme.onSurface;
  static Color get errorContainer         => AppTheme.isLight ? const Color(0xFFFFDAD6) : const Color(0xFF561A18);
  static Color get onErrorContainer       => AppTheme.isLight ? const Color(0xFF93000A) : const Color(0xFFFFB4AB);

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
  static TextStyle bodySm({Color? color, FontWeight fontWeight = FontWeight.w400}) =>
      TabTheme.labelMd(color: color ?? TabTheme.onSurfaceVariant, fw: fontWeight);
  static TextStyle labelLg({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.labelLg(color: color, fw: fontWeight);
  static TextStyle labelMd({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.labelMd(color: color, fw: fontWeight);
  static TextStyle labelSm({Color? color, FontWeight fontWeight = FontWeight.w600}) =>
      TabTheme.labelSm(color: color, fw: fontWeight);
}
