import 'package:flutter/material.dart';
import '../../core/extensions/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Hero Icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(
                        Icons.record_voice_over_rounded,
                        size: 40,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenido a\nEnglish Brain',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.onboardingHeroSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Feature 1: Local AI Coach
                  _buildFeatureRow(
                    context,
                    icon: Icons.psychology_rounded,
                    color: AppTheme.primary,
                    title: 'Entrevistador Local Inteligente',
                    description:
                        'Simula entrevistas técnicas y de RRHH usando Ollama (Qwen 2.5) con transcripción y síntesis de voz en tu propio hardware.',
                  ),
                  const SizedBox(height: 20),

                  // Feature 2: FSRS Spaced Repetition
                  _buildFeatureRow(
                    context,
                    icon: Icons.style_rounded,
                    color: AppTheme.secondary,
                    title: 'Repaso Espaciado FSRS',
                    description:
                        'Convierte cada error gramatical y sugerencia de vocabulario en tarjetas de estudio con el algoritmo de última generación FSRS.',
                  ),
                  const SizedBox(height: 20),

                  // Feature 3: Full Privacy & Offline
                  _buildFeatureRow(
                    context,
                    icon: Icons.shield_rounded,
                    color: AppTheme.success,
                    title: 'Privacidad Total y Red Resiliente',
                    description:
                        'Tus respuestas nunca salen de tu red. Compatible con tu LAN local, túnel WireGuard cifrado y sincronización offline.',
                  ),
                  const SizedBox(height: 40),

                  // Get Started Button
                  FilledButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: Text(context.l10n.onboardingConfigAndStart),
                    onPressed: () async {
                      // Mark onboarding completed in cache
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_completed', true);
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
