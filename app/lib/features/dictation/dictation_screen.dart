import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import '../../core/theme/app_theme.dart';

class DictationScreen extends StatelessWidget {
  const DictationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dictationTitle),
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
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones_rounded, size: 54, color: AppTheme.primaryLight),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.dictationHeading,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.dictationBody,
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
