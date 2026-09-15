import 'package:flutter/services.dart';

/// Centralized tactile haptic feedback engine for a crisp, physical, premium UX.
class AppHaptics {
  AppHaptics._();

  /// Subtle tactile click for general button presses, tabs, chips, and pills.
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Firmer bump for state changes, recording toggles, card flips, and answer selections.
  static Future<void> medium() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Solid impact for session completions, badge unlocks, level ups, and milestones.
  static Future<void> heavy() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Delicate tick for sliding rails, CEFR chips, track switchers, and segment tabs.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Double impulse for wrong answers or pronunciation alerts.
  static Future<void> error() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
