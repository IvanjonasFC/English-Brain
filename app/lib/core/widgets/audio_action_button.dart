import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

enum AudioButtonState { idle, playing, paused, recording, uploading }

/// Unified audio action button used across vocabulary, interview, and shadowing.
class AudioActionButton extends StatelessWidget {
  final AudioButtonState state;
  final VoidCallback? onTap;
  final Color? accentColor;
  final String? label;
  final double size;

  const AudioActionButton({
    super.key,
    required this.state,
    this.onTap,
    this.accentColor,
    this.label,
    this.size = 52,
  });

  IconData get _icon {
    switch (state) {
      case AudioButtonState.idle:
        return Icons.play_circle_rounded;
      case AudioButtonState.playing:
        return Icons.pause_circle_rounded;
      case AudioButtonState.paused:
        return Icons.play_circle_rounded;
      case AudioButtonState.recording:
        return Icons.stop_rounded;
      case AudioButtonState.uploading:
        return Icons.cloud_upload_rounded;
    }
  }

  bool get _isAnimated => state == AudioButtonState.recording || state == AudioButtonState.uploading;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _isAnimated ? color.withValues(alpha: 0.25) : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isAnimated ? color : color.withValues(alpha: 0.5),
                width: _isAnimated ? 2.0 : 1.5,
              ),
              boxShadow: _isAnimated
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 16,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: state == AudioButtonState.uploading
                ? SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(_icon, color: color, size: size * 0.45),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              label!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Speed selector button for audio playback
class AudioSpeedButton extends StatelessWidget {
  final double speed;
  final bool isActive;
  final VoidCallback? onTap;

  const AudioSpeedButton({
    super.key,
    required this.speed,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.20)
              : AppTheme.surface,
          borderRadius: AppRadius.chipRadius,
          border: Border.all(
            color: isActive ? AppTheme.primary : AppTheme.border,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          '${speed}x',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
