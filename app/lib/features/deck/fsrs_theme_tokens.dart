import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Tokens de diseño reactivos para FSRS, que respetan el tema claro/oscuro
/// de AppTheme y la paleta Material 3 / Plus Jakarta Sans de Fluence.
class FsrsTheme {
  // Paleta de acentos adaptativos (Material 3 + AppTheme)
  static Color get primary => AppTheme.isLight ? const Color(0xFF5E35B1) : const Color(0xFFC3A5E0);
  static Color get primaryContainer => AppTheme.isLight ? const Color(0xFF7E57C2) : const Color(0xFFDBC6EF);
  static Color get tertiary => AppTheme.isLight ? const Color(0xFFE53935) : const Color(0xFFEF9A9A);
  static Color get tertiaryContainer => AppTheme.isLight ? const Color(0xFFEF5350) : const Color(0xFFFFCDD2);
  static Color get onPrimary => AppTheme.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E1826);
  static Color get onPrimaryContainer => AppTheme.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF3A2E4E);
  static Color get onTertiary => AppTheme.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1E1826);
  static const Color error = Color(0xFFBA1A1A);

  // Paleta dinámica según tema (AppTheme.isLight)
  static Color get primaryFixed => AppTheme.isLight ? const Color(0xFFEDE7F6) : const Color(0xFF311B92);
  static Color get primaryFixedDim => AppTheme.isLight ? const Color(0xFFD1C4E9) : const Color(0xFF4527A0);
  static Color get onPrimaryFixed => AppTheme.isLight ? const Color(0xFF311B92) : const Color(0xFFEDE7F6);
  static Color get onPrimaryFixedVariant => AppTheme.isLight ? const Color(0xFF4527A0) : const Color(0xFFDBC6EF);

  static Color get secondary => AppTheme.textSecondary;

  // Superficies y fondos dinámicos según AppTheme.isLight
  static Color get surface => AppTheme.isLight ? const Color(0xFFF8F5FB) : AppTheme.background;
  static Color get surfaceDim => AppTheme.isLight ? const Color(0xFFDFD8E8) : const Color(0xFF18151B);
  static Color get surfaceBright => AppTheme.isLight ? const Color(0xFFF8F5FB) : AppTheme.surfaceLight;
  static Color get surfaceContainerLowest => AppTheme.isLight ? const Color(0xFFFFFFFF) : AppTheme.surface;
  static Color get surfaceContainerLow => AppTheme.isLight ? const Color(0xFFF4EFF8) : AppTheme.surface;
  static Color get surfaceContainer => AppTheme.isLight ? const Color(0xFFEBE3F2) : AppTheme.surfaceLight;
  static Color get surfaceContainerHigh => AppTheme.isLight ? const Color(0xFFE3D9ED) : AppTheme.border;
  static Color get surfaceContainerHighest => AppTheme.isLight ? const Color(0xFFDCD1E7) : AppTheme.border;
  static Color get surfaceVariant => AppTheme.isLight ? const Color(0xFFDCD1E7) : AppTheme.border;

  // Textos y contornos dinámicos
  static Color get onSurface => AppTheme.textPrimary;
  static Color get onSurfaceVariant => AppTheme.isLight ? const Color(0xFF49454E) : AppTheme.textSecondary;
  static Color get outline => AppTheme.isLight ? const Color(0xFF79747E) : AppTheme.border;
  static Color get outlineVariant => AppTheme.isLight ? const Color(0xFFCAC4D0) : AppTheme.border;

  // Tipografías con Plus Jakarta Sans adaptativas
  static TextStyle displayMd({Color? color, FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 24,
      height: 1.25,
      letterSpacing: -0.4,
      fontWeight: fontWeight,
      color: color ?? onSurface,
    );
  }

  static TextStyle headlineSm({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      height: 1.35,
      letterSpacing: -0.2,
      fontWeight: fontWeight,
      color: color ?? onSurface,
    );
  }

  static TextStyle titleMd({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      height: 1.4,
      letterSpacing: -0.1,
      fontWeight: fontWeight,
      color: color ?? onSurface,
    );
  }

  static TextStyle titleSmall({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.4,
      letterSpacing: -0.1,
      fontWeight: fontWeight,
      color: color ?? onSurface,
    );
  }

  static TextStyle bodyMd({Color? color, FontWeight fontWeight = FontWeight.w400}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.45,
      letterSpacing: 0,
      fontWeight: fontWeight,
      color: color ?? onSurfaceVariant,
    );
  }

  static TextStyle labelLg({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0.1,
      fontWeight: fontWeight,
      color: color ?? onSurface,
    );
  }

  static TextStyle labelMd({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      height: 1.4,
      letterSpacing: 0.2,
      fontWeight: fontWeight,
      color: color ?? onSurfaceVariant,
    );
  }

  static TextStyle labelSm({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      height: 1.4,
      letterSpacing: 0.3,
      fontWeight: fontWeight,
      color: color ?? onSurfaceVariant,
    );
  }
}
