import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/theme/app_theme.dart';

class ShadowingScreen extends StatelessWidget {
  const ShadowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.shadowingTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.graphic_eq_rounded, size: 54, color: AppTheme.accent),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.shadowingHeading,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.shadowingBody,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
