import 'package:flutter/material.dart';
import '../theme/tab_theme.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppPillVariant { filled, outlined, ghost }

/// Reusable pill/chip for categories, difficulty labels, and status badges.
class AppPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final AppPillVariant variant;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.variant = AppPillVariant.ghost,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case AppPillVariant.filled:
        bgColor = isSelected ? color : color.withValues(alpha: 0.90);
        textColor = (bgColor.computeLuminance() > 0.4) ? const Color(0xFF1E293B) : Colors.white;
        break;
      case AppPillVariant.outlined:
        bgColor = isSelected ? color.withValues(alpha: 0.15) : Colors.transparent;
        textColor = color;
        border = Border.all(color: color, width: isSelected ? 1.5 : 1.0);
        break;
      case AppPillVariant.ghost:
        bgColor = color.withValues(alpha: 0.12);
        textColor = color;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty pill with semantic colors
class DifficultyPill extends StatelessWidget {
  final String difficulty;
  const DifficultyPill({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return TabTheme.cefrPill(difficulty);
  }
}


