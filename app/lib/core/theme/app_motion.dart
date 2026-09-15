import 'package:flutter/animation.dart';

/// Design tokens: Animation durations and curves
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration slower = Duration(milliseconds: 600);
  static const Duration page = Duration(milliseconds: 400);

  // Curves
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve flip = Curves.easeInOutCubic;

  // Semantic aliases
  static const Duration shimmer = slower;
  static const Duration cardFlip = slow;
  static const Duration buttonHover = fastest;
  static const Duration pageTransition = page;
  static const Duration snackbar = normal;
  static const Duration tooltip = fast;
}
