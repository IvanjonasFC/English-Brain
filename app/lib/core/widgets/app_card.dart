import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Base card widget using centralized design tokens.
/// Replaces ad-hoc Container+BoxDecoration patterns throughout the app.
class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding,
    this.onTap,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: gradient == null ? (backgroundColor ?? AppTheme.surface) : null,
          gradient: gradient,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: borderColor ?? AppTheme.border,
            width: borderWidth,
          ),
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}

/// Module-themed card with gradient accent left border.
class AppAccentCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppAccentCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.backgroundColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3.5,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
