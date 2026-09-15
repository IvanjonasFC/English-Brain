import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/interview/interview_hub_screen.dart';
import '../../features/interview/interview_screen.dart';
import '../../features/interview/interview_pack_intro_screen.dart';
import '../../core/pedagogy/contracts.dart';
import '../../features/vocabulary/vocabulary_hub_screen.dart';
import '../../features/vocabulary/vocabulary_screen.dart';
import '../../features/vocabulary/vocabulary_practice_screen.dart';
import '../../features/vocabulary/vocabulary_practice_summary_screen.dart';
import '../../features/grammar/grammar_hub_screen.dart';
import '../../features/grammar/grammar_screen.dart';
import '../../features/grammar/grammar_models.dart';
import '../../features/grammar/grammar_practice_summary_screen.dart';
import '../../features/comprehension/comprehension_hub_screen.dart';
import '../../features/comprehension/comprehension_runner_screen.dart';
import '../../features/comprehension/comprehension_models.dart';
import '../../features/questions/questions_screen.dart';
import '../../features/deck/deck_screen.dart';
import '../../features/stats/stats_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/dictation/dictation_screen.dart';
import '../../features/shadowing/shadowing_screen.dart';
import '../../features/auth/account_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/free_talk/free_talk_screen.dart';
import '../../features/irregular_verbs/irregular_verbs_screen.dart';
import '../../features/irregular_verbs/verbs_lab_landing_screen.dart';
import '../../features/irregular_verbs/verbs_lab_session_runner_screen.dart';
import '../../features/phrasal_verbs/phrasal_verbs_landing_screen.dart';
import '../../features/phrasal_verbs/phrasal_verbs_catalog_screen.dart';
import '../../features/phrasal_verbs/phrasal_verbs_session_runner_screen.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../theme/tab_theme.dart';
import '../../l10n/app_localizations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    // Ruta desconocida -> pantalla amable con vuelta al inicio (nunca la
    // pantalla de error cruda de GoRouter). Robustez ante deep links rotos.
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_rounded, size: 56, color: Color(0xFF9AA0A6)),
              const SizedBox(height: 14),
              const Text('Vaya, esa pantalla no existe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('El enlace puede estar roto o desactualizado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B6B6B))),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
    redirect: (context, state) async {
      final location = state.uri.path;
      if (location == '/splash') return null;

      final secure = ref.read(secureStorageProvider);
      final activeUserId = await secure.getActiveUserId();
      final hasAccount = activeUserId != null && activeUserId.isNotEmpty;

      final isAuthScreen = location == '/login' || location == '/onboarding';

      if (!hasAccount && !isAuthScreen) {
        return '/login';
      }

      if (hasAccount && isAuthScreen) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const AccountScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/interview',
            builder: (context, state) => const InterviewHubScreen(),
            routes: [
              GoRoute(
                path: 'hub',
                builder: (context, state) => const InterviewHubScreen(),
              ),
              GoRoute(
                path: 'session',
                builder: (context, state) {
                  final qIdStr = state.uri.queryParameters['question_id'];
                  final qId = qIdStr != null ? int.tryParse(qIdStr) : null;
                  final cat = state.uri.queryParameters['category'];
                  final diff = state.uri.queryParameters['difficulty'];
                  final mode = state.uri.queryParameters['mode'];
                  return InterviewScreen(
                    initialQuestionId: qId,
                    initialCategory: cat,
                    initialDifficulty: diff,
                    initialMode: mode,
                  );
                },
              ),
              GoRoute(
                path: 'pack-intro',
                builder: (context, state) {
                  final pack = state.extra as InterviewPack?;
                  if (pack == null) {
                    return const InterviewHubScreen();
                  }
                  return InterviewPackIntroScreen(
                    pack: pack,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/vocabulary',
            builder: (context, state) => const VocabularyHubScreen(),
            routes: [
              GoRoute(
                path: 'pack',
                builder: (context, state) {
                  final packId = state.uri.queryParameters['pack_id'];
                  return VocabularyScreen(initialPackId: packId);
                },
              ),
              GoRoute(
                path: 'practice',
                builder: (context, state) {
                  final packId = state.uri.queryParameters['pack_id'] ?? 'backend';
                  return VocabularyPracticeScreen(packId: packId);
                },
              ),
              GoRoute(
                path: 'summary',
                builder: (context, state) {
                  final title = state.uri.queryParameters['title'] ??
                      'System Architecture & Scalability';
                  return VocabularyPracticeSummaryScreen(topicTitle: title);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/grammar',
            builder: (context, state) => const GrammarHubScreen(),
            routes: [
              GoRoute(
                path: 'guide',
                builder: (context, state) {
                  if (state.extra is GrammarUnit) {
                    return GrammarScreen(unit: state.extra as GrammarUnit);
                  }
                  final id = state.uri.queryParameters['id'];
                  if (id != null) {
                    final matched = allGrammarUnits.where((u) => u.id == id);
                    if (matched.isNotEmpty) {
                      return GrammarScreen(unit: matched.first);
                    }
                  }
                  return const GrammarScreen();
                },
              ),
              GoRoute(
                path: 'summary',
                builder: (context, state) => const GrammarPracticeSummaryScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/comprehension',
            builder: (context, state) => const ComprehensionHubScreen(),
            routes: [
              GoRoute(
                path: 'piece',
                builder: (context, state) {
                  final id = state.uri.queryParameters['id'] ?? '';
                  final mode = state.uri.queryParameters['mode'] == 'listening'
                      ? CompMode.listening
                      : CompMode.reading;
                  return ComprehensionRunnerScreen(pieceId: id, mode: mode);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/deck',
            builder: (context, state) {
              final autoStart = state.uri.queryParameters['start'] == 'true';
              final filter = state.uri.queryParameters['filter'];
              return DeckScreen(initialFilter: filter, autoStart: autoStart);
            },
          ),
          GoRoute(
            path: '/questions',
            builder: (context, state) => const QuestionsScreen(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/irregular-verbs',
            builder: (context, state) => const VerbsLabLandingScreen(),
            routes: [
              GoRoute(
                path: 'matrix',
                builder: (context, state) => const IrregularVerbsScreen(),
              ),
              GoRoute(
                path: 'session',
                builder: (context, state) {
                  final mode = state.uri.queryParameters['mode'];
                  return VerbsLabSessionRunnerScreen(mode: mode);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/phrasal-verbs',
            builder: (context, state) => const PhrasalVerbsLandingScreen(),
            routes: [
              GoRoute(
                path: 'catalog',
                builder: (context, state) => const PhrasalVerbsCatalogScreen(),
              ),
              GoRoute(
                path: 'session',
                builder: (context, state) {
                  final mode = state.uri.queryParameters['mode'];
                  return PhrasalVerbsSessionRunnerScreen(mode: mode);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/dictation',
        builder: (context, state) => const DictationScreen(),
      ),
      GoRoute(
        path: '/shadowing',
        builder: (context, state) => const ShadowingScreen(),
      ),
      GoRoute(
        path: '/free-talk',
        builder: (context, state) {
          final topic = state.uri.queryParameters['topic'];
          return FreeTalkScreen(initialTopic: topic);
        },
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/interview')) return 1;
    if (location.startsWith('/vocabulary')) return 2;
    if (location.startsWith('/grammar')) return 3;
    if (location.startsWith('/comprehension')) return 4;
    if (location.startsWith('/profile')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0: context.go('/'); break;
      case 1: context.go('/interview'); break;
      case 2: context.go('/vocabulary'); break;
      case 3: context.go('/grammar'); break;
      case 4: context.go('/comprehension'); break;
      case 5: context.go('/profile'); break;
    }
  }

  /// Returns the accent color for the currently active tab.
  Color _tabAccent(int index) {
    switch (index) {
      case 1: return TabTheme.speaking.accent;
      case 2: return TabTheme.vocabulary.accent;
      case 3: return TabTheme.grammar.accent;
      case 4: return TabTheme.comprehension.accent;
      default: return AppTheme.primary; // Inicio & Perfil
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeIsLightProvider);
    ref.watch(localeProvider);
    final currentIndex = _calculateSelectedIndex(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = _tabAccent(currentIndex);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppTheme.background,
          indicatorColor: accent.withValues(alpha: 0.16),
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              letterSpacing: -0.25,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accent : AppTheme.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: accent, size: 22);
            }
            return IconThemeData(color: AppTheme.textSecondary, size: 22);
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (idx) => _onItemTapped(idx, context),
          backgroundColor: AppTheme.background,
          indicatorColor: accent.withValues(alpha: 0.16),
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _dest(Icons.dashboard_outlined, Icons.dashboard_rounded, l10n.navHome, AppTheme.primary, currentIndex == 0),
            _dest(Icons.mic_none_rounded, Icons.mic_rounded, l10n.navInterview, TabTheme.speaking.accent, currentIndex == 1),
            _dest(Icons.auto_stories_outlined, Icons.auto_stories_rounded, l10n.navVocabulary, TabTheme.vocabulary.accent, currentIndex == 2),
            _dest(Icons.spellcheck_outlined, Icons.spellcheck_rounded, l10n.navGrammar, TabTheme.grammar.accent, currentIndex == 3),
            _dest(Icons.headphones_outlined, Icons.headphones_rounded, l10n.navComprehension, TabTheme.comprehension.accent, currentIndex == 4),
            _dest(Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile, AppTheme.primary, currentIndex == 5),
          ],
        ),
      ),
    );
  }

  NavigationDestination _dest(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    Color accent,
    bool selected,
  ) =>
      NavigationDestination(
        icon: Icon(outlinedIcon, color: AppTheme.textSecondary),
        selectedIcon: Icon(filledIcon, color: accent),
        label: label,
      );
}
