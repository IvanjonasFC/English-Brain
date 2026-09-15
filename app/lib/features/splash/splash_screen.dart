import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla de Splash con animación que reúne los 6 colores representativos de cada módulo:
/// 1. Speaking (Naranja #E8833A)
/// 2. Vocabulario (Verde #3DAA72)
/// 3. Gramática (Azul #4A7FD6)
/// 4. Comprensión (Rosa #E11D48)
/// 5. Mazo FSRS (Púrpura #7C5CBF)
/// 6. Perfil (Ámbar #D97706)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _orbitAnim;
  late final Animation<double> _convergeAnim;
  late final Animation<double> _logoScaleAnim;
  late final Animation<double> _textFadeAnim;
  bool _navigated = false;

  final List<Color> _moduleColors = [
    const Color(0xFFEA8E51), // Speaking (Melocotón suave)
    const Color(0xFF56B588), // Vocabulary (Menta suave)
    const Color(0xFF6B9DE8), // Grammar (Azul cielo suave)
    const Color(0xFFDF7891), // Comprehension (Rosa empolvado suave)
    const Color(0xFF937CD8), // FSRS (Lavanda suave)
    const Color(0xFFE5A144), // Profile (Ámbar miel suave)
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 1. Órbita y rotación inicial (0.0 -> 0.45)
    _orbitAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );

    // 2. Convergencia hacia el centro (0.40 -> 0.75)
    _convergeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.75, curve: Curves.easeInOutBack),
    );

    // 3. Aparición y pulso del núcleo / logo central (0.65 -> 0.90)
    _logoScaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.90, curve: Curves.elasticOut),
    );

    // 4. Fade in de la tipografía de marca (0.75 -> 1.0)
    _textFadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
    );

    _controller.forward().then((_) => _finishAndNavigate());
  }

  Future<void> _finishAndNavigate() async {
    if (_navigated || !mounted) return;
    _navigated = true;
    final secure = ref.read(secureStorageProvider);
    final activeId = await secure.getActiveUserId();
    if (!mounted) return;
    if (activeId != null && activeId.isNotEmpty) {
      context.go('/');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = !AppTheme.isLight;
    final bg = isDark ? const Color(0xFF13100D) : const Color(0xFFFAF7F2);

    return Scaffold(
      backgroundColor: bg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _finishAndNavigate,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Aura de fusión multicolor central
                  if (_convergeAnim.value > 0.2)
                    Transform.scale(
                      scale: 1.0 + (_logoScaleAnim.value * 0.4),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8833A).withValues(alpha: 0.25 * _logoScaleAnim.value),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: const Color(0xFF4A7FD6).withValues(alpha: 0.20 * _logoScaleAnim.value),
                              blurRadius: 50,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Los 6 orbes orbitando y convergiendo hacia el centro
                  ...List.generate(_moduleColors.length, (idx) {
                    final angle = (idx * (2 * math.pi / _moduleColors.length)) +
                        (_controller.value * math.pi * 1.5);
                    final maxRadius = 75.0 * (1.0 - _convergeAnim.value);
                    final x = math.cos(angle) * maxRadius;
                    final y = math.sin(angle) * maxRadius;
                    final orbScale = (1.0 - (_convergeAnim.value * 0.6)).clamp(0.0, 1.2);
                    final orbAlpha = (1.0 - (_convergeAnim.value * 0.85)).clamp(0.0, 1.0);

                    return Transform.translate(
                      offset: Offset(x, y),
                      child: Transform.scale(
                        scale: orbScale * _orbitAnim.value,
                        child: Opacity(
                          opacity: orbAlpha,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _moduleColors[idx],
                              boxShadow: [
                                BoxShadow(
                                  color: _moduleColors[idx].withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Núcleo central con el icono de marca
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: _logoScaleAnim.value,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFEA8E51),
                                Color(0xFFDF7891),
                                Color(0xFF937CD8),
                                Color(0xFF6B9DE8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEA8E51).withValues(alpha: 0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 74,
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bg,
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/icon/icon_1024.png',
                                  width: 74,
                                  height: 74,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.psychology_rounded,
                                    size: 42,
                                    color: Color(0xFFD97736),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Opacity(
                        opacity: _textFadeAnim.value,
                        child: Column(
                          children: [
                            Text(
                              'English Brain',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI EXECUTIVE COACH',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
