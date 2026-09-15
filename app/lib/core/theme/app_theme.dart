import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== Acentos (fijos, validos en claro y oscuro) =====
  static const Color primary = Color(0xFFF2A65A);
  static const Color primaryLight = Color(0xFFF8C471);
  static const Color secondary = Color(0xFFF6C08A);
  static const Color accent = Color(0xFFF2A65A);

  static const Color interviewAmber = Color(0xFFF3B274);
  static const Color interviewLight = Color(0xFFF8CE9E);
  static const Color vocabTeal = Color(0xFF7FC3A0);
  static const Color vocabLight = Color(0xFFA9DBC2);
  static const Color grammarSlate = Color(0xFF9CB8E8);
  static const Color grammarLight = Color(0xFFC1D4F2);
  static const Color fsrsViolet = Color(0xFFC3A5E0);
  static const Color fsrsLight = Color(0xFFDBC6EF);

  static const Color success = Color(0xFF8FCBA0);
  static const Color warning = Color(0xFFF5C97B);
  static const Color error = Color(0xFFE8918C);

  // ===== Neutros y superficies de modulo (mutables segun tema) =====
  static bool isLight = false;
  static Color background = _dBackground;
  static Color surface = _dSurface;
  static Color surfaceLight = _dSurfaceLight;
  static Color border = _dBorder;
  static Color textPrimary = _dTextPrimary;
  static Color textSecondary = _dTextSecondary;
  static Color surfaceInterview = _dSurfaceInterview;
  static Color borderInterview = _dBorderInterview;
  static Color surfaceVocab = _dSurfaceVocab;
  static Color borderVocab = _dBorderVocab;
  static Color surfaceGrammar = _dSurfaceGrammar;
  static Color borderGrammar = _dBorderGrammar;
  static Color surfaceFsrs = _dSurfaceFsrs;
  static Color borderFsrs = _dBorderFsrs;

  // Oscuro
  static const Color _dBackground = Color(0xFF1C1611);
  static const Color _dSurface = Color(0xFF26201A);
  static const Color _dSurfaceLight = Color(0xFF322A22);
  static const Color _dBorder = Color(0xFF40382E);
  static const Color _dTextPrimary = Color(0xFFF3EEE7);
  static const Color _dTextSecondary = Color(0xFFAAA298);
  static const Color _dSurfaceInterview = Color(0xFF241A10);
  static const Color _dBorderInterview = Color(0xFF4A3418);
  static const Color _dSurfaceVocab = Color(0xFF14201A);
  static const Color _dBorderVocab = Color(0xFF2C4438);
  static const Color _dSurfaceGrammar = Color(0xFF171B26);
  static const Color _dBorderGrammar = Color(0xFF303A50);
  static const Color _dSurfaceFsrs = Color(0xFF1E1826);
  static const Color _dBorderFsrs = Color(0xFF3A2E4E);
  // Claro
  static const Color _lBackground = Color(0xFFFAF5EF);
  static const Color _lSurface = Color(0xFFFFFFFF);
  static const Color _lSurfaceLight = Color(0xFFF1EAE0);
  static const Color _lBorder = Color(0xFFE6DCCE);
  static const Color _lTextPrimary = Color(0xFF0F172A);
  static const Color _lTextSecondary = Color(0xFF475569);
  static const Color _lSurfaceInterview = Color(0xFFFBEFE0);
  static const Color _lBorderInterview = Color(0xFFF0D9BE);
  static const Color _lSurfaceVocab = Color(0xFFE6F4EC);
  static const Color _lBorderVocab = Color(0xFFC9E6D6);
  static const Color _lSurfaceGrammar = Color(0xFFE8EFFB);
  static const Color _lBorderGrammar = Color(0xFFCDDAF2);
  static const Color _lSurfaceFsrs = Color(0xFFF1E9FA);
  static const Color _lBorderFsrs = Color(0xFFDECDF0);

  static void applyLight(bool light) {
    isLight = light;
    background = light ? _lBackground : _dBackground;
    surface = light ? _lSurface : _dSurface;
    surfaceLight = light ? _lSurfaceLight : _dSurfaceLight;
    border = light ? _lBorder : _dBorder;
    textPrimary = light ? _lTextPrimary : _dTextPrimary;
    textSecondary = light ? _lTextSecondary : _dTextSecondary;
    surfaceInterview = light ? _lSurfaceInterview : _dSurfaceInterview;
    borderInterview = light ? _lBorderInterview : _dBorderInterview;
    surfaceVocab = light ? _lSurfaceVocab : _dSurfaceVocab;
    borderVocab = light ? _lBorderVocab : _dBorderVocab;
    surfaceGrammar = light ? _lSurfaceGrammar : _dSurfaceGrammar;
    borderGrammar = light ? _lBorderGrammar : _dBorderGrammar;
    surfaceFsrs = light ? _lSurfaceFsrs : _dSurfaceFsrs;
    borderFsrs = light ? _lBorderFsrs : _dBorderFsrs;
  }

  static ThemeData get theme {
    final brightness = isLight ? Brightness.light : Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      onPrimary: Colors.black,
      onSurface: textPrimary,
      secondaryContainer: secondary,
      onSecondaryContainer: Colors.black,
    );

    // Global Typography: Plus Jakarta Sans for all headings, body, and labels
    final baseTextTheme = (isLight ? ThemeData.light() : ThemeData.dark()).textTheme;
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme).copyWith(
      headlineLarge: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.bold, color: textPrimary),
      headlineMedium: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      headlineSmall: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
      titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: textPrimary, height: 1.5),
      bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: textSecondary, height: 1.4),
      labelLarge: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: primary,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: primary);
          }
          return GoogleFonts.plusJakartaSans(fontSize: 12, color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.black, size: 22);
          }
          return IconThemeData(color: textSecondary, size: 22);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary.withValues(alpha: 0.2);
            }
            return surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primary;
            }
            return textSecondary;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 13),
        labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
