import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Tokens de diseño reactivos para Entrevistas STAR, que respetan el tema claro/oscuro
/// de AppTheme y la paleta Material 3 / Plus Jakarta Sans de Fluence y Stitch.
class InterviewTheme {
  // Paleta de acentos adaptativos (Material 3 + AppTheme)
  static Color get primary => AppTheme.isLight ? const Color(0xFF994703) : const Color(0xFFF2A65A);
  static Color get primaryContainer => AppTheme.isLight ? const Color(0xFFD97736) : const Color(0xFFF8C471);
  static Color get tertiary => AppTheme.isLight ? const Color(0xFF3D6654) : const Color(0xFF7FC3A0);
  static Color get tertiaryContainer => AppTheme.isLight ? const Color(0xFF6F9A86) : const Color(0xFFA9DBC2);
  static Color get onPrimary => AppTheme.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1C1611);
  static Color get onPrimaryContainer => AppTheme.isLight ? const Color(0xFF491D00) : const Color(0xFF321200);
  static Color get onTertiary => AppTheme.isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1C1611);
  static const Color error = Color(0xFFBA1A1A);

  // Paleta fija / chips según Stitch
  static Color get primaryFixed => AppTheme.isLight ? const Color(0xFFFFDBC9) : const Color(0xFF4A2818);
  static Color get primaryFixedDim => AppTheme.isLight ? const Color(0xFFFFB68C) : const Color(0xFF6B3A22);
  static Color get onPrimaryFixed => AppTheme.isLight ? const Color(0xFF321200) : const Color(0xFFFFDBC9);
  static Color get onPrimaryFixedVariant => AppTheme.isLight ? const Color(0xFF753400) : const Color(0xFFF8C471);

  static Color get tertiaryFixed => AppTheme.isLight ? const Color(0xFFBFEDD5) : const Color(0xFF1E3D30);
  static Color get tertiaryFixedDim => AppTheme.isLight ? const Color(0xFFA4D0BA) : const Color(0xFF2F5E4B);
  static Color get onTertiaryFixed => AppTheme.isLight ? const Color(0xFF002115) : const Color(0xFFBCECD2);
  static Color get onTertiaryFixedVariant => AppTheme.isLight ? const Color(0xFF254E3D) : const Color(0xFF8FCBA0);

  static Color get secondary => AppTheme.textSecondary;
  static Color get secondaryContainer => AppTheme.isLight ? const Color(0xFFD5E0F8) : const Color(0xFF273449);
  static Color get secondaryFixed => AppTheme.isLight ? const Color(0xFFD8E3FB) : const Color(0xFF1E2838);
  static Color get secondaryFixedDim => AppTheme.isLight ? const Color(0xFFBCC7DE) : const Color(0xFF344560);
  static Color get onSecondaryFixed => AppTheme.isLight ? const Color(0xFF111C2D) : const Color(0xFFD8E3FB);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static Color get onSecondaryContainer => AppTheme.isLight ? const Color(0xFF586377) : const Color(0xFFC0D3F8);

  // Superficies y fondos dinámicos
  static Color get surface => AppTheme.isLight ? const Color(0xFFFBF9F5) : AppTheme.background;
  static Color get surfaceDim => AppTheme.isLight ? const Color(0xFFDBDAD6) : const Color(0xFF1F1A15);
  static Color get surfaceBright => AppTheme.isLight ? const Color(0xFFFBF9F5) : AppTheme.surfaceLight;
  static Color get surfaceContainerLowest => AppTheme.isLight ? const Color(0xFFFFFFFF) : AppTheme.surface;
  static Color get surfaceContainerLow => AppTheme.isLight ? const Color(0xFFF5F3EF) : AppTheme.surface;
  static Color get surfaceContainer => AppTheme.isLight ? const Color(0xFFEFEEEA) : AppTheme.surfaceLight;
  static Color get surfaceContainerHigh => AppTheme.isLight ? const Color(0xFFEAE8E4) : AppTheme.border;
  static Color get surfaceContainerHighest => AppTheme.isLight ? const Color(0xFFE4E2DE) : AppTheme.border;
  static Color get surfaceVariant => AppTheme.isLight ? const Color(0xFFE4E2DE) : AppTheme.border;

  // Textos y contornos dinámicos
  static Color get onSurface => AppTheme.textPrimary;
  static Color get onSurfaceVariant => AppTheme.isLight ? const Color(0xFF554339) : AppTheme.textSecondary;
  static Color get outline => AppTheme.isLight ? const Color(0xFF887367) : AppTheme.border;
  static Color get outlineVariant => AppTheme.isLight ? const Color(0xFFDBC1B4) : AppTheme.border;

  // Estados de error
  static Color get errorContainer => AppTheme.isLight ? const Color(0xFFFFDAD6) : const Color(0xFF561A18);
  static Color get onErrorContainer => AppTheme.isLight ? const Color(0xFF93000A) : const Color(0xFFFFB4AB);

  // Tipografías con Plus Jakarta Sans adaptativas
  static TextStyle displayMd({Color? color, FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: fontWeight,
      letterSpacing: -0.5,
      color: color ?? onSurface,
    );
  }

  static TextStyle headlineLg({Color? color, FontWeight fontWeight = FontWeight.w700}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: fontWeight,
      letterSpacing: -0.4,
      color: color ?? onSurface,
    );
  }

  static TextStyle headlineSm({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: fontWeight,
      letterSpacing: -0.2,
      color: color ?? onSurface,
    );
  }

  static TextStyle titleMd({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: fontWeight,
      letterSpacing: -0.1,
      color: color ?? onSurface,
    );
  }

  static TextStyle titleSm({Color? color, FontWeight fontWeight = FontWeight.w600}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: fontWeight,
      letterSpacing: 0,
      color: color ?? onSurface,
    );
  }

  static TextStyle bodyLg({Color? color, FontWeight fontWeight = FontWeight.w400, double? height}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: fontWeight,
      color: color ?? onSurface,
      height: height ?? 1.45,
    );
  }

  static TextStyle bodyMd({Color? color, FontWeight fontWeight = FontWeight.w400, double? height}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: fontWeight,
      color: color ?? onSurface,
      height: height ?? 1.4,
    );
  }

  static TextStyle bodySm({Color? color, FontWeight fontWeight = FontWeight.w400, double? height}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: fontWeight,
      color: color ?? onSurfaceVariant,
      height: height ?? 1.35,
    );
  }

  static TextStyle labelLg({Color? color, FontWeight fontWeight = FontWeight.w600, double? letterSpacing}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color ?? onSurface,
    );
  }

  static TextStyle labelMd({Color? color, FontWeight fontWeight = FontWeight.w600, double? letterSpacing}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color ?? onSurfaceVariant,
    );
  }

  static TextStyle labelSm({Color? color, FontWeight fontWeight = FontWeight.w700, double? letterSpacing}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 9.5,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing ?? 0.3,
      color: color ?? onSurfaceVariant,
    );
  }
}
