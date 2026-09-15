import 'package:flutter/painting.dart';

/// Design tokens: Border radius scale
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 100.0;

  // Semantic aliases
  static const double card = xl;
  static const double chip = sm;
  static const double input = lg;
  static const double modal = xxl;
  static const double button = lg;
  static const double badge = xs;

  // BorderRadius helpers
  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
  static BorderRadius get inputRadius => BorderRadius.circular(input);
  static BorderRadius get modalRadius => const BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
}
